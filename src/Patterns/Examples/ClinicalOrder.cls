/// Healthcare Example - Clinical Order (Receiver)
/// 
/// Purpose:
/// Represents a clinical order in a healthcare system that can be created,
/// modified, cancelled, and have its state managed for undo/redo operations.
/// This class acts as a Receiver in the Command pattern.
/// 
/// Responsibilities:
/// - Maintain order state (Draft, Pending, Active, Completed, Cancelled)
/// - Store order details (patient, provider, order items)
/// - Support state snapshots for undo/redo
/// - Validate state transitions
/// - Provide audit trail of changes
/// 
/// @see Patterns.GoF.Behavioral.Receiver
/// @since 1.0.0
Class Patterns.Examples.ClinicalOrder Extends Patterns.GoF.Behavioral.Receiver
{

// ===== PARAMETERS =====

/// Valid order states
Parameter STATEDRAFT = "Draft";

Parameter STATEPENDING = "Pending";

Parameter STATEACTIVE = "Active";

Parameter STATECOMPLETED = "Completed";

Parameter STATECANCELLED = "Cancelled";

// ===== PROPERTIES =====

/// Unique order identifier
Property OrderId As %String [ InitialExpression = {$ZCONVERT($SYSTEM.Util.CreateGUID(), "L")} ];

/// Patient identifier
Property PatientId As %String;

/// Patient name
Property PatientName As %String(MAXLEN = 200);

/// Provider identifier
Property ProviderId As %String;

/// Provider name
Property ProviderName As %String(MAXLEN = 200);

/// Order type (Lab, Medication, Imaging, Procedure)
Property OrderType As %String;

/// Order description
Property Description As %String(MAXLEN = 500);

/// Current order state
Property State As %String [ InitialExpression = {..#STATEDRAFT} ];

/// Order priority (Routine, Urgent, STAT)
Property Priority As %String [ InitialExpression = "Routine" ];

/// Order date/time
Property OrderDateTime As %TimeStamp;

/// Scheduled date/time for execution
Property ScheduledDateTime As %TimeStamp;

/// Completion date/time
Property CompletedDateTime As %TimeStamp;

/// Cancellation reason
Property CancellationReason As %String(MAXLEN = 500);

/// Order items (tests, medications, procedures)
Property OrderItems As list Of %String;

/// Clinical notes
Property ClinicalNotes As %String(MAXLEN = 2000);

/// Audit trail of all changes
Property AuditTrail As list Of %String;

/// Approval status
Property IsApproved As %Boolean [ InitialExpression = 0 ];

/// Approver ID
Property ApproverId As %String;

/// Approval timestamp
Property ApprovalDateTime As %TimeStamp;

// ===== CONSTRUCTORS/DESTRUCTORS =====

/// Constructor - Initialize the clinical order
/// 
/// @param pPatientId Patient identifier
/// @param pProviderId Provider identifier
/// @param pOrderType Type of order
/// @return Status code
Method %OnNew(pPatientId As %String = "", pProviderId As %String = "", pOrderType As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Call parent constructor
        Set tSC = ##super()
        If $$$ISERR(tSC) Quit
        
        // Initialize properties
        Set ..PatientId = pPatientId
        Set ..ProviderId = pProviderId
        Set ..OrderType = pOrderType
        Set ..OrderDateTime = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        Set ..State = ..#STATEDRAFT
        
        // Add initial audit entry
        Do ..AddAuditEntry("Order created")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Get the current state of the order
/// 
/// @return Dynamic object containing order state
Method GetState() As %DynamicObject
{
    // Get base state from parent
    Set tState = ##super()
    
    // Add order-specific state
    Set tState.orderId = ..OrderId
    Set tState.patientId = ..PatientId
    Set tState.patientName = ..PatientName
    Set tState.providerId = ..ProviderId
    Set tState.providerName = ..ProviderName
    Set tState.orderType = ..OrderType
    Set tState.description = ..Description
    Set tState.state = ..State
    Set tState.priority = ..Priority
    Set tState.orderDateTime = ..OrderDateTime
    Set tState.scheduledDateTime = ..ScheduledDateTime
    Set tState.completedDateTime = ..CompletedDateTime
    Set tState.cancellationReason = ..CancellationReason
    Set tState.clinicalNotes = ..ClinicalNotes
    Set tState.isApproved = ..IsApproved
    Set tState.approverId = ..ApproverId
    Set tState.approvalDateTime = ..ApprovalDateTime
    
    // Convert order items to array
    Set tState.orderItems = []
    For i = 1:1:..OrderItems.Count() {
        Do tState.orderItems.%Push(..OrderItems.GetAt(i))
    }
    
    Quit tState
}

/// Restore the order to a previous state
/// 
/// @param pState The state to restore
/// @return Status code
Method RestoreState(pState As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Restore base state
        Set tSC = ##super(pState)
        If $$$ISERR(tSC) Quit
        
        // Restore order-specific state
        If pState.%IsDefined("orderId") { Set ..OrderId = pState.orderId }
        If pState.%IsDefined("patientId") { Set ..PatientId = pState.patientId }
        If pState.%IsDefined("patientName") { Set ..PatientName = pState.patientName }
        If pState.%IsDefined("providerId") { Set ..ProviderId = pState.providerId }
        If pState.%IsDefined("providerName") { Set ..ProviderName = pState.providerName }
        If pState.%IsDefined("orderType") { Set ..OrderType = pState.orderType }
        If pState.%IsDefined("description") { Set ..Description = pState.description }
        If pState.%IsDefined("state") { Set ..State = pState.state }
        If pState.%IsDefined("priority") { Set ..Priority = pState.priority }
        If pState.%IsDefined("orderDateTime") { Set ..OrderDateTime = pState.orderDateTime }
        If pState.%IsDefined("scheduledDateTime") { Set ..ScheduledDateTime = pState.scheduledDateTime }
        If pState.%IsDefined("completedDateTime") { Set ..CompletedDateTime = pState.completedDateTime }
        If pState.%IsDefined("cancellationReason") { Set ..CancellationReason = pState.cancellationReason }
        If pState.%IsDefined("clinicalNotes") { Set ..ClinicalNotes = pState.clinicalNotes }
        If pState.%IsDefined("isApproved") { Set ..IsApproved = pState.isApproved }
        If pState.%IsDefined("approverId") { Set ..ApproverId = pState.approverId }
        If pState.%IsDefined("approvalDateTime") { Set ..ApprovalDateTime = pState.approvalDateTime }
        
        // Restore order items
        If pState.%IsDefined("orderItems") {
            Do ..OrderItems.Clear()
            Set tIterator = pState.orderItems.%GetIterator()
            While tIterator.%GetNext(.tKey, .tValue) {
                Do ..OrderItems.Insert(tValue)
            }
        }
        
        // Add audit entry for restoration
        Do ..AddAuditEntry("State restored")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Submit the order (transition from Draft to Pending)
/// 
/// @return Status code
Method Submit() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate state transition
        If ..State '= ..#STATEDRAFT {
            Set tSC = $$$ERROR($$$GeneralError, "Can only submit orders in Draft state")
            Quit
        }
        
        // Update state
        Set ..State = ..#STATEPENDING
        Set ..StateVersion = ..StateVersion + 1
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Add audit entry
        Do ..AddAuditEntry("Order submitted")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Approve the order
/// 
/// @param pApproverId ID of the approver
/// @return Status code
Method Approve(pApproverId As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate state
        If ..State '= ..#STATEPENDING {
            Set tSC = $$$ERROR($$$GeneralError, "Can only approve orders in Pending state")
            Quit
        }
        
        // Update approval information
        Set ..IsApproved = 1
        Set ..ApproverId = pApproverId
        Set ..ApprovalDateTime = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Transition to Active state
        Set ..State = ..#STATEACTIVE
        Set ..StateVersion = ..StateVersion + 1
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Add audit entry
        Do ..AddAuditEntry("Order approved by " _ pApproverId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Cancel the order
/// 
/// @param pReason Cancellation reason
/// @return Status code
Method Cancel(pReason As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate state - cannot cancel completed orders
        If ..State = ..#STATECOMPLETED {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot cancel completed orders")
            Quit
        }
        
        // Update state
        Set ..State = ..#STATECANCELLED
        Set ..CancellationReason = pReason
        Set ..StateVersion = ..StateVersion + 1
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Add audit entry
        Do ..AddAuditEntry("Order cancelled: " _ pReason)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Complete the order
/// 
/// @return Status code
Method Complete() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate state
        If ..State '= ..#STATEACTIVE {
            Set tSC = $$$ERROR($$$GeneralError, "Can only complete active orders")
            Quit
        }
        
        // Update state
        Set ..State = ..#STATECOMPLETED
        Set ..CompletedDateTime = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        Set ..StateVersion = ..StateVersion + 1
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Add audit entry
        Do ..AddAuditEntry("Order completed")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Add an item to the order
/// 
/// @param pItem The item to add
/// @return Status code
Method AddOrderItem(pItem As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Can only add items in Draft state
        If ..State '= ..#STATEDRAFT {
            Set tSC = $$$ERROR($$$GeneralError, "Can only add items to orders in Draft state")
            Quit
        }
        
        Do ..OrderItems.Insert(pItem)
        Set ..StateVersion = ..StateVersion + 1
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Add audit entry
        Do ..AddAuditEntry("Item added: " _ pItem)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Remove an item from the order
/// 
/// @param pIndex Index of the item to remove
/// @return Status code
Method RemoveOrderItem(pIndex As %Integer) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Can only remove items in Draft state
        If ..State '= ..#STATEDRAFT {
            Set tSC = $$$ERROR($$$GeneralError, "Can only remove items from orders in Draft state")
            Quit
        }
        
        If (pIndex < 1) || (pIndex > ..OrderItems.Count()) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid item index")
            Quit
        }
        
        Set tItem = ..OrderItems.GetAt(pIndex)
        Do ..OrderItems.RemoveAt(pIndex)
        Set ..StateVersion = ..StateVersion + 1
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Add audit entry
        Do ..AddAuditEntry("Item removed: " _ tItem)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Set the order priority
/// 
/// @param pPriority New priority (Routine, Urgent, STAT)
/// @return Status code
Method SetPriority(pPriority As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate priority
        If (pPriority '= "Routine") && (pPriority '= "Urgent") && (pPriority '= "STAT") {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid priority: " _ pPriority)
            Quit
        }
        
        Set tOldPriority = ..Priority
        Set ..Priority = pPriority
        Set ..StateVersion = ..StateVersion + 1
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Add audit entry
        Do ..AddAuditEntry("Priority changed from " _ tOldPriority _ " to " _ pPriority)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate that an operation can be performed
/// 
/// @param pOperation The operation to validate
/// @param pParameters Parameters for the operation
/// @return Boolean indicating if operation is valid
Method ValidateOperation(pOperation As %String, pParameters As %DynamicObject = "") As %Boolean
{
    // Check base validity
    If '##super(pOperation, pParameters) {
        Quit 0
    }
    
    // Check operation-specific rules
    Set tValid = 1
    
    If pOperation = "Submit" {
        Set tValid = (..State = ..#STATEDRAFT)
    } ElseIf pOperation = "Approve" {
        Set tValid = (..State = ..#STATEPENDING)
    } ElseIf pOperation = "Cancel" {
        Set tValid = (..State '= ..#STATECOMPLETED) && (..State '= ..#STATECANCELLED)
    } ElseIf pOperation = "Complete" {
        Set tValid = (..State = ..#STATEACTIVE)
    } ElseIf pOperation = "AddItem" {
        Set tValid = (..State = ..#STATEDRAFT)
    } ElseIf pOperation = "RemoveItem" {
        Set tValid = (..State = ..#STATEDRAFT)
    }
    
    Quit tValid
}

// ===== PRIVATE METHODS =====

/// Add an entry to the audit trail
/// 
/// @param pEntry The audit entry to add
Method AddAuditEntry(pEntry As %String)
{
    Set tTimestamp = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
    Set tAuditEntry = tTimestamp _ " | " _ pEntry
    Do ..AuditTrail.Insert(tAuditEntry)
}

// ===== CLASS METHODS =====

/// Create a sample clinical order for testing
/// 
/// @return New clinical order instance
ClassMethod CreateSampleOrder() As ClinicalOrder
{
    Set tOrder = ..%New("PAT001", "DOC001", "Lab")
    Set tOrder.PatientName = "John Doe"
    Set tOrder.ProviderName = "Dr. Smith"
    Set tOrder.Description = "Complete Blood Count with Differential"
    Do tOrder.AddOrderItem("CBC with Differential")
    Do tOrder.AddOrderItem("Basic Metabolic Panel")
    Set tOrder.ClinicalNotes = "Patient presenting with fatigue and weakness"
    
    Quit tOrder
}

}
