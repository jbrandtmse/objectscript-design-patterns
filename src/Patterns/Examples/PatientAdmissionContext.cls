/// Healthcare Patient Admission Context
/// 
/// Purpose:
/// Manages the patient admission workflow by maintaining the current state
/// and delegating admission operations to the appropriate state handler.
/// 
/// Healthcare Workflow:
/// Typical patient admission flow:
/// PreAdmission -> Registration -> Triage -> Consultation -> Treatment -> Discharge
/// 
/// Features:
/// - Maintains patient information throughout admission
/// - Tracks admission workflow state
/// - Provides audit trail of state transitions
/// - Handles emergency overrides
/// - Manages admission timeouts
Class Patterns.Examples.PatientAdmissionContext Extends Patterns.GoF.Behavioral.StateContext
{

// ===== PROPERTIES =====

/// Patient identifier
Property PatientID As %String;

/// Patient name
Property PatientName As %String;

/// Admission date/time
Property AdmissionTime As %TimeStamp;

/// Current admission priority (1=Emergency, 2=Urgent, 3=Standard)
Property Priority As %Integer [ InitialExpression = 3 ];

/// Insurance verification status
Property InsuranceVerified As %Boolean [ InitialExpression = 0 ];

/// Assigned physician
Property AssignedPhysician As %String;

/// Admission notes
Property AdmissionNotes As list Of %String;

// ===== CONSTRUCTOR =====

/// Initialize patient admission context with proper parent signature
Method %OnNew(pInitialState As Patterns.GoF.Behavioral.State = "") As %Status
{
    // Call parent constructor with the initial state
    Set tSC = ##super(pInitialState)
    If $$$ISERR(tSC) Quit tSC
    
    // If no initial state provided, use PreAdmission as default
    If pInitialState = "" {
        Set tInitialState = ##class(Patterns.Examples.PreAdmissionState).%New()
        Set tSC = ..TransitionTo(tInitialState)
        If $$$ISERR(tSC) Quit tSC
    }
    
    // Enable logging for healthcare audit
    Set ..EnableLogging = 1
    
    // Set default timeout (2 hours per state)
    Set ..TimeoutDuration = 7200
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Initialize patient information
/// 
/// @param pPatientID The patient identifier
/// @param pPatientName The patient name
/// @return %Status indicating success or failure
Method InitializePatient(pPatientID As %String = "", pPatientName As %String = "") As %Status
{
    Set tSC = $$$OK
    
    // Set patient information
    Set ..PatientID = pPatientID
    Set ..PatientName = pPatientName
    Set ..AdmissionTime = $ZDATETIME($HOROLOG, 3)
    
    // Initialize state data
    Set ..StateData("PatientID") = pPatientID
    Set ..StateData("PatientName") = pPatientName
    Set ..StateData("AdmissionTime") = ..AdmissionTime
    
    Quit tSC
}

/// Process admission request
/// 
/// @param pRequest The admission request type
/// @return Response from processing the request
Method ProcessAdmission(pRequest As %String)
{
    Set tResponse = ..Request(pRequest)
    
    // Update state data with current context
    Set ..StateData("Priority") = ..Priority
    Set ..StateData("InsuranceVerified") = ..InsuranceVerified
    Set ..StateData("AssignedPhysician") = ..AssignedPhysician
    
    Quit tResponse
}

/// Move to next state in admission workflow
/// 
/// @return %Status indicating success or failure
Method MoveToNextState() As %Status
{
    Set tSC = $$$OK
    
    If '$IsObject(..CurrentState) {
        Quit $$$ERROR($$$GeneralError, "No current state set")
    }
    
    // Request transition to next state
    Set tResponse = ..Request("NEXT")
    
    If tResponse [ "Cannot transition" {
        Quit $$$ERROR($$$GeneralError, tResponse)
    }
    
    Quit tSC
}

/// Emergency override to skip to treatment
/// 
/// @return %Status indicating success or failure
Method EmergencyOverride() As %Status
{
    Set tSC = $$$OK
    
    // Set emergency priority
    Set ..Priority = 1
    Set ..StateData("Priority") = 1
    Set ..StateData("EmergencyOverride") = 1
    
    // Log emergency override
    Set tLogEntry = $ZDATETIME($HOROLOG, 3) _ " | EMERGENCY OVERRIDE | Patient: " _ ..PatientID
    Set ^Patterns.Admission.EmergencyLog($INCREMENT(^Patterns.Admission.EmergencyLog)) = tLogEntry
    
    // Transition directly to Treatment state
    Set tTreatmentState = ##class(Patterns.Examples.TreatmentState).%New()
    Set tSC = ..TransitionTo(tTreatmentState)
    
    Quit tSC
}

/// Complete admission process
/// 
/// @return %Status indicating success or failure
Method CompleteAdmission() As %Status
{
    Set tSC = $$$OK
    
    // Verify we're in discharge state
    If ..GetCurrentStateName() '= "Patterns.Examples.DischargeState" {
        Quit $$$ERROR($$$GeneralError, "Cannot complete admission - not in Discharge state")
    }
    
    // Process discharge
    Set tResponse = ..Request("COMPLETE")
    
    // Generate admission summary
    Do ..GenerateAdmissionSummary()
    
    Quit tSC
}

/// Add admission note
/// 
/// @param pNote The note to add
Method AddAdmissionNote(pNote As %String)
{
    Set tTimestamp = $ZDATETIME($HOROLOG, 3)
    Set tFormattedNote = tTimestamp _ " | " _ ..GetCurrentStateName() _ " | " _ pNote
    Do ..AdmissionNotes.Insert(tFormattedNote)
    
    // Also store in state data
    Set tNoteKey = $INCREMENT(..StateData("NoteCount"))
    Set ..StateData("Note", tNoteKey) = tFormattedNote
}

/// Get admission status summary
/// 
/// @return %String Status summary
Method GetAdmissionStatus() As %String
{
    Set tStatus = "=== ADMISSION STATUS ==="
    Set tStatus = tStatus _ $CHAR(10) _ "Patient: " _ ..PatientName _ " (ID: " _ ..PatientID _ ")"
    Set tStatus = tStatus _ $CHAR(10) _ "Current State: " _ ..GetCurrentStateName()
    Set tStatus = tStatus _ $CHAR(10) _ "Priority: " _ $CASE(..Priority, 1:"EMERGENCY", 2:"URGENT", 3:"STANDARD", :"UNKNOWN")
    Set tStatus = tStatus _ $CHAR(10) _ "Admission Time: " _ ..AdmissionTime
    Set tStatus = tStatus _ $CHAR(10) _ "Insurance Verified: " _ $SELECT(..InsuranceVerified:"YES", 1:"NO")
    Set tStatus = tStatus _ $CHAR(10) _ "Assigned Physician: " _ $SELECT(..AssignedPhysician="":"Not assigned", 1:..AssignedPhysician)
    Set tStatus = tStatus _ $CHAR(10) _ "State History: " _ ..GetHistoryString()
    Set tStatus = tStatus _ $CHAR(10) _ "Total Transitions: " _ ..TransitionCount
    
    Quit tStatus
}

/// Validate admission data
/// 
/// @return %Status indicating if data is valid
Method ValidateAdmissionData() As %Status
{
    Set tSC = $$$OK
    
    // Check required fields
    If ..PatientID = "" {
        Quit $$$ERROR($$$GeneralError, "Patient ID is required")
    }
    
    If ..PatientName = "" {
        Quit $$$ERROR($$$GeneralError, "Patient name is required")
    }
    
    // Validate priority
    If (..Priority < 1) || (..Priority > 3) {
        Quit $$$ERROR($$$GeneralError, "Invalid priority level")
    }
    
    // Additional validation based on current state
    If $IsObject(..CurrentState) {
        Set tSC = ..CurrentState.ValidateState($this)
    }
    
    Quit tSC
}

// ===== PRIVATE METHODS =====

/// Generate admission summary report
Method GenerateAdmissionSummary() [ Private ]
{
    Set tSummary = "=== ADMISSION SUMMARY REPORT ==="
    Set tSummary = tSummary _ $CHAR(10) _ "Generated: " _ $ZDATETIME($HOROLOG, 3)
    Set tSummary = tSummary _ $CHAR(10) _ $CHAR(10) _ "PATIENT INFORMATION:"
    Set tSummary = tSummary _ $CHAR(10) _ "  Patient ID: " _ ..PatientID
    Set tSummary = tSummary _ $CHAR(10) _ "  Patient Name: " _ ..PatientName
    Set tSummary = tSummary _ $CHAR(10) _ "  Admission Time: " _ ..AdmissionTime
    
    // Calculate total admission duration
    Set tCurrentTime = $ZDATETIME($HOROLOG, 3)
    Set tDurationSeconds = $ZDATETIME($ZDATETIMEH(tCurrentTime), -2) - $ZDATETIME($ZDATETIMEH(..AdmissionTime), -2)
    Set tDurationHours = tDurationSeconds \ 3600
    Set tDurationMinutes = (tDurationSeconds # 3600) \ 60
    Set tSummary = tSummary _ $CHAR(10) _ "  Total Duration: " _ tDurationHours _ " hours, " _ tDurationMinutes _ " minutes"
    
    Set tSummary = tSummary _ $CHAR(10) _ $CHAR(10) _ "WORKFLOW SUMMARY:"
    Set tSummary = tSummary _ $CHAR(10) _ "  Priority Level: " _ $CASE(..Priority, 1:"EMERGENCY", 2:"URGENT", 3:"STANDARD", :"UNKNOWN")
    Set tSummary = tSummary _ $CHAR(10) _ "  Total State Transitions: " _ ..TransitionCount
    Set tSummary = tSummary _ $CHAR(10) _ "  State Progression: " _ ..GetHistoryString()
    
    // Add state durations
    Set tSummary = tSummary _ $CHAR(10) _ $CHAR(10) _ "STATE DURATIONS:"
    Set tStateList = ..GetHistoryString()
    For i = 1:1:$LENGTH(tStateList, " -> ") {
        Set tStateName = $PIECE(tStateList, " -> ", i)
        Set tDuration = $GET(..StateData("StateDuration", tStateName), "N/A")
        Set tSummary = tSummary _ $CHAR(10) _ "  " _ tStateName _ ": " _ tDuration
    }
    
    // Add admission notes
    If ..AdmissionNotes.Count() > 0 {
        Set tSummary = tSummary _ $CHAR(10) _ $CHAR(10) _ "ADMISSION NOTES:"
        For i = 1:1:..AdmissionNotes.Count() {
            Set tSummary = tSummary _ $CHAR(10) _ "  " _ ..AdmissionNotes.GetAt(i)
        }
    }
    
    // Save summary to global
    Set ^Patterns.Admission.Summary(..PatientID, $HOROLOG) = tSummary
    
    // Also create a printable version
    Set ^Patterns.Admission.Reports(..PatientID, "Latest") = tSummary
}

}
