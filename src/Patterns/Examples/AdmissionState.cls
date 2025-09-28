/// Healthcare Patient Admission State - Abstract Base Class
/// 
/// Purpose:
/// Abstract base class for all patient admission workflow states.
/// Each concrete state represents a stage in the patient admission process.
/// 
/// Healthcare Context:
/// Patient admission follows a workflow with distinct states:
/// - PreAdmission: Insurance verification, consent forms
/// - Registration: Patient demographics, contact info
/// - Triage: Initial assessment, priority assignment
/// - Consultation: Doctor examination, diagnosis
/// - Treatment: Medical procedures, medications
/// - Discharge: Final documentation, follow-up scheduling
Class Patterns.Examples.AdmissionState Extends Patterns.GoF.Behavioral.State [ Abstract ]
{

/// Patient data associated with admission
Property PatientData [ MultiDimensional ];

/// Handle admission request in this state
/// 
/// @param pContext The patient admission context
/// @param pRequest The admission request type
/// @return Response from handling the request
Method Handle(pContext As Patterns.GoF.Behavioral.StateContext, pRequest As %String)
{
    Set tAdmissionContext = pContext
    Set tResponse = ""
    
    // Handle common requests
    If pRequest = "STATUS" {
        Quit ..GetStateStatus(tAdmissionContext)
    } ElseIf pRequest = "VALIDATE" {
        Set tSC = ..ValidateStateRequirements(tAdmissionContext)
        If $$$ISOK(tSC) {
            Quit "Validation successful"
        } Else {
            Quit "Validation failed: " _ $System.Status.GetErrorText(tSC)
        }
    } ElseIf pRequest = "NEXT" {
        Set tSC = ..TransitionToNextState(tAdmissionContext)
        If $$$ISOK(tSC) {
            Quit "Transitioned to next state"
        } Else {
            Quit "Cannot transition: " _ $System.Status.GetErrorText(tSC)
        }
    } Else {
        // Delegate to concrete state implementation
        Quit ..HandleStateSpecificRequest(tAdmissionContext, pRequest)
    }
}

/// Handle state-specific requests
/// 
/// @param pContext The patient admission context
/// @param pRequest The specific request
/// @return Response from handling the request
Method HandleStateSpecificRequest(pContext As Patterns.Examples.PatientAdmissionContext, pRequest As %String) [ Abstract ]
{
    Quit ""
}

/// Transition to the next state in workflow
/// 
/// @param pContext The patient admission context
/// @return %Status indicating success or failure
Method TransitionToNextState(pContext As Patterns.Examples.PatientAdmissionContext) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Validate state requirements before transition
/// 
/// @param pContext The patient admission context
/// @return %Status indicating if requirements are met
Method ValidateStateRequirements(pContext As Patterns.Examples.PatientAdmissionContext) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Get the status of current state
/// 
/// @param pContext The patient admission context
/// @return %String Status description
Method GetStateStatus(pContext As Patterns.Examples.PatientAdmissionContext) As %String
{
    Set tStatus = "State: " _ ..GetStateName()
    Set tStatus = tStatus _ " | Patient ID: " _ pContext.StateData("PatientID")
    Set tStatus = tStatus _ " | Admission Time: " _ pContext.StateData("AdmissionTime")
    Quit tStatus
}

/// Called when entering this admission state
Method OnEntry(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = $$$OK
    
    // Log state entry
    Do ..LogStateChange(pContext, "ENTRY")
    
    // Set state entry time - use concatenated key for MultiDimensional property
    Set tKey = "StateEntryTime:" _ ..GetStateName()
    Set pContext.StateData(tKey) = $ZDATETIME($HOROLOG, 3)
    
    Quit tSC
}

/// Called when exiting this admission state
Method OnExit(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = $$$OK
    
    // Log state exit
    Do ..LogStateChange(pContext, "EXIT")
    
    // Calculate time spent in state - use concatenated key for MultiDimensional property
    Set tEntryKey = "StateEntryTime:" _ ..GetStateName()
    Set tEntryTime = $GET(pContext.StateData(tEntryKey))
    If tEntryTime '= "" {
        Set tExitTime = $ZDATETIME($HOROLOG, 3)
        Set tDuration = $SYSTEM.SQL.DATEDIFF("s", tEntryTime, tExitTime)
        Set tDurationKey = "StateDuration:" _ ..GetStateName()
        Set pContext.StateData(tDurationKey) = tDuration _ " seconds"
    }
    
    Quit tSC
}

/// Log state change for audit trail
/// 
/// @param pContext The patient admission context
/// @param pAction The action (ENTRY/EXIT)
Method LogStateChange(pContext As Patterns.GoF.Behavioral.StateContext, pAction As %String) [ Private ]
{
    Set tPatientID = $GET(pContext.StateData("PatientID"), "UNKNOWN")
    Set tTimestamp = $ZDATETIME($HOROLOG, 3)
    Set tLogEntry = tTimestamp _ " | Patient: " _ tPatientID _ " | State: " _ ..GetStateName() _ " | Action: " _ pAction
    
    // Add to audit trail
    Set tAuditKey = $INCREMENT(^Patterns.Admission.AuditTrail)
    Set ^Patterns.Admission.AuditTrail(tAuditKey) = tLogEntry
    
    // Also add to patient-specific audit
    Set ^Patterns.Admission.PatientAudit(tPatientID, tAuditKey) = tLogEntry
}

/// Check if transition to target state is allowed
Method CanTransitionTo(pTargetState As Patterns.GoF.Behavioral.State) As %Boolean
{
    // Get allowed transitions for this state
    Set tAllowedTransitions = ..GetAllowedTransitions()
    Set tTargetName = pTargetState.GetStateName()
    Set tIsAllowed = 0
    
    // Check if target is in allowed list
    For i = 1:1:$LENGTH(tAllowedTransitions, ",") {
        If $PIECE(tAllowedTransitions, ",", i) = tTargetName {
            Set tIsAllowed = 1
            Quit
        }
    }
    
    Quit tIsAllowed
}

/// Get comma-delimited list of allowed transitions
/// 
/// @return %String Comma-delimited state names
Method GetAllowedTransitions() As %String [ Abstract ]
{
    Quit ""
}

/// Handle timeout in admission state
Method OnTimeout(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = $$$OK
    
    // Log timeout
    Do ..LogStateChange(pContext, "TIMEOUT")
    
    // Send alert
    Set tPatientID = $GET(pContext.StateData("PatientID"))
    Set tAlert = "TIMEOUT ALERT: Patient " _ tPatientID _ " has been in " _ ..GetStateName() _ " state too long"
    Set ^Patterns.Admission.Alerts($INCREMENT(^Patterns.Admission.Alerts)) = tAlert
    
    Quit tSC
}

/// Validate admission state consistency
Method ValidateState(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = $$$OK
    
    // Check required patient data
    If '$DATA(pContext.StateData("PatientID")) {
        Quit $$$ERROR($$$GeneralError, "Missing PatientID in state data")
    }
    
    // Validate state-specific requirements
    Set tSC = ..ValidateStateRequirements(pContext)
    
    Quit tSC
}

}
