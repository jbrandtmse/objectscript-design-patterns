/// <html>
/// <h1>MedicationOrderCommand</h1>
/// <p>Command implementation for ordering medications in a healthcare system.</p>
/// <p>This command demonstrates the Command Pattern for medication workflow,
/// including dosing, frequency, route, and duration management.</p>
/// </html>
Class Patterns.Examples.MedicationOrderCommand Extends Patterns.GoF.Behavioral.Command
{

/// Medication name
Property MedicationName As %String;

/// Dosage amount
Property Dosage As %String;

/// Frequency (e.g., "BID", "TID", "Q6H")
Property Frequency As %String;

/// Route of administration (e.g., "PO", "IV", "IM")
Property Route As %String;

/// Duration in days
Property Duration As %Integer;

/// PRN (as needed) flag
Property IsPRN As %Boolean;

/// PRN reason if applicable
Property PRNReason As %String;

/// Create a new medication order command
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
            // Get medication details
            If pParameters.%IsDefined("medicationName") {
                Set ..MedicationName = pParameters.medicationName
            }
            If pParameters.%IsDefined("dosage") {
                Set ..Dosage = pParameters.dosage
            }
            If pParameters.%IsDefined("frequency") {
                Set ..Frequency = pParameters.frequency
            }
            If pParameters.%IsDefined("route") {
                Set ..Route = pParameters.route
            } Else {
                Set ..Route = "PO"  // Default to oral
            }
            If pParameters.%IsDefined("duration") {
                Set ..Duration = pParameters.duration
            } Else {
                Set ..Duration = 7  // Default 7 days
            }
            If pParameters.%IsDefined("isPRN") {
                Set ..IsPRN = pParameters.isPRN
            }
            If pParameters.%IsDefined("prnReason") {
                Set ..PRNReason = pParameters.prnReason
            }
        }
        
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Execute the medication order command
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
        
        // Validate medication name
        If ..MedicationName = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Medication name is required")
            Quit
        }
        
        // Store current state for undo
        Set ..PreviousState = tOrder.GetState()
        
        // Build order description
        Set tDescription = ..MedicationName_" "_..Dosage_" "_..Route_" "_..Frequency
        If ..Duration > 0 {
            Set tDescription = tDescription_" for "_..Duration_" days"
        }
        If ..IsPRN {
            Set tDescription = tDescription_" PRN"
            If ..PRNReason '= "" {
                Set tDescription = tDescription_" for "_..PRNReason
            }
        }
        
        // Set order properties
        Set tOrder.OrderType = "Medication"
        Set tOrder.Description = tDescription
        
        // Add medication details to order items
        Do tOrder.OrderItems.Insert(..MedicationName _ " " _ ..Dosage _ " " _ ..Route _ " " _ ..Frequency)
        
        // Update state to Pending (using Submit method to follow proper workflow)
        If tOrder.State = tOrder.#STATEDRAFT {
            Set tSC = tOrder.Submit()
            If $$$ISERR(tSC) Quit
        }
        
        // Set default priority if not set
        If tOrder.Priority = "" {
            Set tOrder.Priority = "Routine"
        }
        
        // Add to audit log (using the correct method name)
        Do tOrder.AddAuditEntry("Medication order placed: "_tDescription)
        
        // Validate medication (in real system would check formulary, interactions, etc.)
        Set tSC = ..ValidateMedication()
        If $$$ISERR(tSC) Quit
        
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Undo the medication order
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
        Do ..Receiver.AddAuditEntry("Medication order undone")
        
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get medication details as JSON
Method GetMedicationDetails() As %String
{
    Set tDetails = {}
    Set tDetails.medication = ..MedicationName
    Set tDetails.dosage = ..Dosage
    Set tDetails.frequency = ..Frequency
    Set tDetails.route = ..Route
    Set tDetails.duration = ..Duration
    Set tDetails.isPRN = ..IsPRN
    If ..IsPRN && (..PRNReason '= "") {
        Set tDetails.prnReason = ..PRNReason
    }
    Set tDetails.orderedAt = $ZDATETIME($HOROLOG, 3)
    
    Quit tDetails.%ToJSON()
}

/// Validate medication safety
Method ValidateMedication() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    // Basic validation
    If ..MedicationName = "" {
        Set tSC = $$$ERROR($$$GeneralError, "Medication name required")
        Quit tSC
    }
    
    If ..Dosage = "" {
        Set tSC = $$$ERROR($$$GeneralError, "Dosage required")
        Quit tSC
    }
    
    If ..Frequency = "" {
        Set tSC = $$$ERROR($$$GeneralError, "Frequency required")
        Quit tSC
    }
    
    // In real system would:
    // - Check drug formulary
    // - Check for drug interactions
    // - Verify dosage is within safe limits
    // - Check patient allergies
    // - Verify route is appropriate for medication
    
    // Log validation  
    Do ..Receiver.AddAuditEntry("Medication validated: "_..MedicationName)
    
    Quit tSC
}

/// Create a common medication order (Aspirin)
ClassMethod CreateAspirin(pReceiver As Patterns.Examples.ClinicalOrder) As MedicationOrderCommand
{
    Set tParams = {}
    Set tParams.medicationName = "Aspirin"
    Set tParams.dosage = "81mg"
    Set tParams.frequency = "Daily"
    Set tParams.route = "PO"
    Set tParams.duration = 0  // Ongoing
    Quit ##class(MedicationOrderCommand).%New(pReceiver, tParams)
}

/// Create an antibiotic order
ClassMethod CreateAntibiotic(pReceiver As Patterns.Examples.ClinicalOrder, pAntibiotic As %String = "Amoxicillin") As MedicationOrderCommand
{
    Set tParams = {}
    Set tParams.medicationName = pAntibiotic
    Set tParams.dosage = "500mg"
    Set tParams.frequency = "TID"
    Set tParams.route = "PO"
    Set tParams.duration = 10
    Quit ##class(MedicationOrderCommand).%New(pReceiver, tParams)
}

/// Create a pain medication order
ClassMethod CreatePainMedication(pReceiver As Patterns.Examples.ClinicalOrder, pSeverity As %String = "Moderate") As MedicationOrderCommand
{
    Set tParams = {}
    
    If pSeverity = "Mild" {
        Set tParams.medicationName = "Acetaminophen"
        Set tParams.dosage = "500mg"
        Set tParams.frequency = "Q6H"
    }
    ElseIf pSeverity = "Moderate" {
        Set tParams.medicationName = "Ibuprofen"
        Set tParams.dosage = "400mg"
        Set tParams.frequency = "Q6H"
    }
    Else {
        Set tParams.medicationName = "Tramadol"
        Set tParams.dosage = "50mg"
        Set tParams.frequency = "Q6H"
    }
    
    Set tParams.route = "PO"
    Set tParams.isPRN = 1
    Set tParams.prnReason = "Pain"
    Set tParams.duration = 5
    
    Quit ##class(MedicationOrderCommand).%New(pReceiver, tParams)
}

/// Create a common medication order
ClassMethod CreateCommonMedication(pReceiver As Patterns.Examples.ClinicalOrder, pMedication As %String) As MedicationOrderCommand
{
    Set tParams = {}
    
    // Common medication presets
    If pMedication = "Aspirin" {
        Set tParams.medicationName = "Aspirin"
        Set tParams.dosage = "81mg"
        Set tParams.frequency = "Daily"
        Set tParams.route = "PO"
        Set tParams.duration = 0
    }
    ElseIf pMedication = "Metformin" {
        Set tParams.medicationName = "Metformin"
        Set tParams.dosage = "500mg"
        Set tParams.frequency = "BID"
        Set tParams.route = "PO"
        Set tParams.duration = 0
    }
    ElseIf pMedication = "Lisinopril" {
        Set tParams.medicationName = "Lisinopril"
        Set tParams.dosage = "10mg"
        Set tParams.frequency = "Daily"
        Set tParams.route = "PO"
        Set tParams.duration = 0
    }
    ElseIf pMedication = "Atorvastatin" {
        Set tParams.medicationName = "Atorvastatin"
        Set tParams.dosage = "20mg"
        Set tParams.frequency = "QHS"
        Set tParams.route = "PO"
        Set tParams.duration = 0
    }
    Else {
        // Default generic medication
        Set tParams.medicationName = pMedication
        Set tParams.dosage = "Dose TBD"
        Set tParams.frequency = "Frequency TBD"
        Set tParams.route = "PO"
        Set tParams.duration = 7
    }
    
    Quit ##class(MedicationOrderCommand).%New(pReceiver, tParams)
}

}
