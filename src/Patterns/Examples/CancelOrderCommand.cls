/// <html>
/// <h1>CancelOrderCommand</h1>
/// <p>Command implementation for cancelling clinical orders.</p>
/// <p>This command demonstrates safe order cancellation with validation,
/// reason tracking, and the ability to undo cancellations.</p>
/// </html>
Class Patterns.Examples.CancelOrderCommand Extends Patterns.GoF.Behavioral.Command
{

/// Reason for cancellation
Property CancellationReason As %String;

/// Who authorized the cancellation
Property AuthorizedBy As %String;

/// Whether to notify provider
Property NotifyProvider As %Boolean;

/// Original order status before cancellation
Property OriginalStatus As %String;

/// Create a new cancel order command
Method %OnNew(pReceiver As Patterns.GoF.Behavioral.Receiver, pParameters As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Call parent constructor
        Set tSC = ##super(pReceiver, pParameters)
        If $$$ISERR(tSC) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to initialize parent Command: "_$System.Status.GetErrorText(tSC))
            Quit
        }
        
        // Extract parameters if provided
        If $ISOBJECT(pParameters) {
            If pParameters.%IsDefined("cancellationReason") {
                Set ..CancellationReason = pParameters.cancellationReason
            }
            If pParameters.%IsDefined("authorizedBy") {
                Set ..AuthorizedBy = pParameters.authorizedBy
            }
            If pParameters.%IsDefined("notifyProvider") {
                Set ..NotifyProvider = pParameters.notifyProvider
            } Else {
                Set ..NotifyProvider = 1  // Default to notify
            }
        }
        
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Execute the order cancellation
Method Execute() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate receiver is a ClinicalOrder
        If '..Receiver.%IsA("Patterns.Examples.ClinicalOrder") {
            Set tSC = $$$ERROR($$$GeneralError, "Receiver must be a ClinicalOrder")
            Quit
        }
        
        // Cast to ClinicalOrder
        Set tOrder = ..Receiver
        
        // Store current state for undo
        Set ..PreviousState = tOrder.GetState()
        
        // Store original status
        Set ..OriginalStatus = tOrder.Status
        
        // Validate cancellation is allowed
        Set tSC = ..ValidateCancellation(tOrder)
        If $$$ISERR(tSC) Quit
        
        // Validate reason is provided
        If ..CancellationReason = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Cancellation reason is required")
            Quit
        }
        
        // Update order to cancelled status
        Set tOrder.Status = "Cancelled"
        
        // Build cancellation details
        Set tCancellationDetails = {}
        Set tCancellationDetails."originalStatus" = ..OriginalStatus
        Set tCancellationDetails."reason" = ..CancellationReason
        Set tCancellationDetails."authorizedBy" = $SELECT(..AuthorizedBy'="":..AuthorizedBy, 1:$USERNAME)
        Set tCancellationDetails."cancelledAt" = $ZDATETIME($HOROLOG, 3)
        Set tCancellationDetails."notificationSent" = ..NotifyProvider
        
        // Store cancellation details in order
        Set tOrder.OrderDetails = tCancellationDetails.%ToJSON()
        
        // Update timestamps
        Set tOrder.CompletedDate = $ZDATETIME($HOROLOG, 3)
        
        // Add to audit log
        Do tOrder.AddToAuditLog("Order cancelled - Reason: "_..CancellationReason_" - Authorized by: "_tCancellationDetails."authorizedBy")
        
        // Send notifications if required
        If ..NotifyProvider {
            Do ..SendCancellationNotification(tOrder)
        }
        
        // Handle status-specific cancellation logic
        Set tSC = ..HandleStatusSpecificCancellation(tOrder)
        If $$$ISERR(tSC) Quit
        
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Undo the order cancellation (restore to previous status)
Method Undo() As %Status
{
    Set tSC = $$$OK
    Try {
        If ..PreviousState = "" {
            Set tSC = $$$ERROR($$$GeneralError, "No previous state to restore")
            Quit
        }
        
        // Restore previous state
        Set tSC = ..Receiver.RestoreState(..PreviousState)
        If $$$ISERR(tSC) Quit
        
        // Add to audit log
        Do ..Receiver.AddToAuditLog("Order cancellation reversed - Restored to status: "_..OriginalStatus)
        
        // Send notification about restoration
        If ..NotifyProvider {
            Do ..SendRestorationNotification(..Receiver)
        }
        
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Validate that the order can be cancelled
Method ValidateCancellation(pOrder As Patterns.Examples.ClinicalOrder) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    // Cannot cancel already completed orders
    If pOrder.Status = "Completed" {
        Set tSC = $$$ERROR($$$GeneralError, "Cannot cancel completed orders")
        Quit tSC
    }
    
    // Cannot cancel already cancelled orders
    If pOrder.Status = "Cancelled" {
        Set tSC = $$$ERROR($$$GeneralError, "Order is already cancelled")
        Quit tSC
    }
    
    // Check if order is in process (Active status)
    If pOrder.Status = "Active" {
        // For active orders, check if results are already available
        // In real system, would check lab system or other integration points
        Do pOrder.AddToAuditLog("WARNING: Cancelling active order - Results may already be in process")
        
        // Check order type for specific validation
        If pOrder.OrderType = "Lab" {
            Do pOrder.AddToAuditLog("Lab cancellation request - Specimen collection status should be verified")
        }
        ElseIf pOrder.OrderType = "Imaging" {
            Do pOrder.AddToAuditLog("Imaging cancellation request - Check if patient already in radiology")
        }
        ElseIf pOrder.OrderType = "Medication" {
            Do pOrder.AddToAuditLog("Medication cancellation request - Verify medication not already dispensed")
        }
    }
    
    // Check authorization level for STAT orders
    If pOrder.Priority = "STAT" {
        If ..AuthorizedBy = "" {
            Set tSC = $$$ERROR($$$GeneralError, "STAT order cancellation requires explicit authorization")
            Quit tSC
        }
        Do pOrder.AddToAuditLog("STAT order cancellation authorized by: "_..AuthorizedBy)
    }
    
    Quit tSC
}

/// Handle status-specific cancellation logic
Method HandleStatusSpecificCancellation(pOrder As Patterns.Examples.ClinicalOrder) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    // Different handling based on original status
    If ..OriginalStatus = "Draft" {
        Do pOrder.AddToAuditLog("Draft order discarded")
    }
    ElseIf ..OriginalStatus = "Pending" {
        Do pOrder.AddToAuditLog("Pending order cancelled before processing")
        // Remove from work queues
        Do ..RemoveFromWorkQueue(pOrder)
    }
    ElseIf ..OriginalStatus = "Active" {
        Do pOrder.AddToAuditLog("Active order cancelled - Manual intervention may be required")
        // Send high-priority notification
        Do ..SendUrgentCancellationAlert(pOrder)
    }
    
    Quit tSC
}

/// Send cancellation notification
Method SendCancellationNotification(pOrder As Patterns.Examples.ClinicalOrder) [ Private ]
{
    // In real system, would integrate with notification service
    Do pOrder.AddToAuditLog("Cancellation notification sent to ordering provider")
    
    // Log notification details
    Set tNotification = "Order #"_pOrder.OrderID_" cancelled"
    Set tNotification = tNotification_" | Type: "_pOrder.OrderType
    Set tNotification = tNotification_" | Reason: "_..CancellationReason
    
    Do pOrder.AddToAuditLog("Notification: "_tNotification)
}

/// Send restoration notification (when undo is performed)
Method SendRestorationNotification(pOrder As Patterns.Examples.ClinicalOrder) [ Private ]
{
    // In real system, would integrate with notification service
    Do pOrder.AddToAuditLog("Order restoration notification sent to provider")
    
    Set tNotification = "Order #"_pOrder.OrderID_" restored from cancellation"
    Do pOrder.AddToAuditLog("Notification: "_tNotification)
}

/// Remove order from work queue
Method RemoveFromWorkQueue(pOrder As Patterns.Examples.ClinicalOrder) [ Private ]
{
    // In real system, would interface with work queue systems
    Do pOrder.AddToAuditLog("Order removed from active work queues")
    
    If pOrder.OrderType = "Lab" {
        Do pOrder.AddToAuditLog("Removed from laboratory work list")
    }
    ElseIf pOrder.OrderType = "Imaging" {
        Do pOrder.AddToAuditLog("Removed from radiology modality work list")
    }
    ElseIf pOrder.OrderType = "Medication" {
        Do pOrder.AddToAuditLog("Removed from pharmacy queue")
    }
}

/// Send urgent cancellation alert for active orders
Method SendUrgentCancellationAlert(pOrder As Patterns.Examples.ClinicalOrder) [ Private ]
{
    // High-priority alert for active order cancellation
    Do pOrder.AddToAuditLog("URGENT: Active order cancellation alert sent")
    
    // Department-specific alerts
    If pOrder.OrderType = "Lab" {
        Do pOrder.AddToAuditLog("Alert sent to laboratory - Stop processing if specimen received")
    }
    ElseIf pOrder.OrderType = "Imaging" {
        Do pOrder.AddToAuditLog("Alert sent to radiology - Cancel scheduled exam")
    }
    ElseIf pOrder.OrderType = "Medication" {
        Do pOrder.AddToAuditLog("Alert sent to pharmacy - Do not dispense medication")
    }
}

/// Create a standard cancellation command
ClassMethod CreateCancellation(pReceiver As Patterns.Examples.ClinicalOrder, pReason As %String) As CancelOrderCommand
{
    Set tParams = {}
    Set tParams.cancellationReason = pReason
    Set tParams.authorizedBy = $USERNAME
    Set tParams.notifyProvider = 1
    Quit ##class(CancelOrderCommand).%New(pReceiver, tParams)
}

/// Create a system-initiated cancellation (e.g., duplicate order detection)
ClassMethod CreateSystemCancellation(pReceiver As Patterns.Examples.ClinicalOrder, pReason As %String) As CancelOrderCommand
{
    Set tParams = {}
    Set tParams.cancellationReason = "System: "_pReason
    Set tParams.authorizedBy = "SYSTEM"
    Set tParams.notifyProvider = 1
    Quit ##class(CancelOrderCommand).%New(pReceiver, tParams)
}

/// Create a patient-requested cancellation
ClassMethod CreatePatientCancellation(pReceiver As Patterns.Examples.ClinicalOrder) As CancelOrderCommand
{
    Set tParams = {}
    Set tParams.cancellationReason = "Patient declined/refused order"
    Set tParams.authorizedBy = $USERNAME
    Set tParams.notifyProvider = 1
    Quit ##class(CancelOrderCommand).%New(pReceiver, tParams)
}

/// Create a clinical cancellation (replaced by new order)
ClassMethod CreateSupersededCancellation(pReceiver As Patterns.Examples.ClinicalOrder, pNewOrderID As %String) As CancelOrderCommand
{
    Set tReason = "Order superseded by new order #"_pNewOrderID
    Set tParams = {}
    Set tParams.cancellationReason = tReason
    Set tParams.authorizedBy = $USERNAME
    Set tParams.notifyProvider = 1
    Quit ##class(CancelOrderCommand).%New(pReceiver, tParams)
}

}
