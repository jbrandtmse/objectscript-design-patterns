/// Triage State - Initial Medical Assessment
/// 
/// Purpose:
/// Handles initial medical assessment and priority assignment.
/// This is the third state in the admission workflow after registration.
/// 
/// Responsibilities:
/// - Perform initial medical assessment
/// - Record vital signs
/// - Assign medical priority level
/// - Transition to Consultation state when complete
Class Patterns.Examples.TriageState Extends Patterns.Examples.AdmissionState
{

/// Handle state-specific requests
Method HandleStateSpecificRequest(pContext As Patterns.Examples.PatientAdmissionContext, pRequest As %String)
{
    Set tResponse = ""
    
    If pRequest = "RECORD_VITALS" {
        // Record vital signs
        Set pContext.StateData("VitalsRecorded") = 1
        Set pContext.StateData("VitalsTime") = $ZDATETIME($HOROLOG, 3)
        Set pContext.StateData("BloodPressure") = $GET(pContext.StateData("BloodPressure"), "120/80")
        Set pContext.StateData("Temperature") = $GET(pContext.StateData("Temperature"), "98.6F")
        Set pContext.StateData("HeartRate") = $GET(pContext.StateData("HeartRate"), "72")
        Quit "Vital signs recorded"
        
    } ElseIf pRequest = "ASSESS_SYMPTOMS" {
        Set pContext.StateData("SymptomsAssessed") = 1
        Set pContext.StateData("ChiefComplaint") = $GET(pContext.StateData("ChiefComplaint"), "General checkup")
        Set pContext.StateData("PainLevel") = $GET(pContext.StateData("PainLevel"), 0)
        Quit "Symptoms assessed and documented"
        
    } ElseIf pRequest = "ASSIGN_PRIORITY" {
        // Assign priority based on assessment
        Set tPainLevel = $GET(pContext.StateData("PainLevel"), 0)
        
        If tPainLevel >= 8 {
            Set pContext.Priority = 1  // Emergency
        } ElseIf tPainLevel >= 5 {
            Set pContext.Priority = 2  // Urgent
        } Else {
            Set pContext.Priority = 3  // Standard
        }
        
        Set pContext.StateData("PriorityAssigned") = 1
        Set pContext.StateData("Priority") = pContext.Priority
        Quit "Priority assigned: " _ $CASE(pContext.Priority, 1:"EMERGENCY", 2:"URGENT", 3:"STANDARD", :"UNKNOWN")
        
    } ElseIf pRequest = "REQUEST_TESTS" {
        Set pContext.StateData("TestsRequested") = 1
        Set tTestList = "Blood Work, X-Ray"
        Set pContext.StateData("RequestedTests") = tTestList
        Quit "Tests requested: " _ tTestList
        
    } ElseIf pRequest = "CHECK_REQUIREMENTS" {
        Set tSC = ..ValidateStateRequirements(pContext)
        If $$$ISOK(tSC) {
            Quit "All triage requirements met"
        } Else {
            Quit "Triage requirements not met: " _ $System.Status.GetErrorText(tSC)
        }
        
    } Else {
        Quit "Unknown triage request: " _ pRequest
    }
}

/// Transition to the next state (Consultation)
Method TransitionToNextState(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    // Validate requirements first
    Set tSC = ..ValidateStateRequirements(pContext)
    If $$$ISERR(tSC) {
        Quit tSC
    }
    
    // High priority cases may skip consultation
    If pContext.Priority = 1 {
        Set tNextState = ##class(Patterns.Examples.TreatmentState).%New()
        Do pContext.AddAdmissionNote("EMERGENCY: Skipping consultation, proceeding directly to treatment")
    } Else {
        Set tNextState = ##class(Patterns.Examples.ConsultationState).%New()
    }
    
    // Transition to next state
    Set tSC = pContext.TransitionTo(tNextState)
    
    Quit tSC
}

/// Validate triage requirements
Method ValidateStateRequirements(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    // Check vital signs recorded
    If '$GET(pContext.StateData("VitalsRecorded"), 0) {
        Quit $$$ERROR($$$GeneralError, "Vital signs not recorded")
    }
    
    // Check symptoms assessed
    If '$GET(pContext.StateData("SymptomsAssessed"), 0) {
        Quit $$$ERROR($$$GeneralError, "Symptoms not assessed")
    }
    
    // Check priority assigned
    If '$GET(pContext.StateData("PriorityAssigned"), 0) {
        Quit $$$ERROR($$$GeneralError, "Medical priority not assigned")
    }
    
    Quit tSC
}

/// Get allowed transitions from this state
Method GetAllowedTransitions() As %String
{
    // Triage can go to Consultation or directly to Treatment for emergencies
    Quit "Patterns.Examples.ConsultationState,Patterns.Examples.TreatmentState"
}

/// Handle entry into triage state
Method OnEntry(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // Initialize triage checklist
    Set pContext.StateData("TriageStarted") = $ZDATETIME($HOROLOG, 3)
    Set pContext.StateData("VitalsRecorded") = 0
    Set pContext.StateData("SymptomsAssessed") = 0
    Set pContext.StateData("PriorityAssigned") = 0
    
    // Nurse assignment
    Set tNurseID = "RN-" _ $RANDOM(100)
    Set pContext.StateData("TriageNurse") = tNurseID
    
    // Add admission note if this is a PatientAdmissionContext
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Do pContext.AddAdmissionNote("Triage assessment started by " _ tNurseID)
    }
    
    Quit tSC
}

/// Handle exit from triage state
Method OnExit(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // Record completion
    Set pContext.StateData("TriageCompleted") = $ZDATETIME($HOROLOG, 3)
    
    // Add admission note with priority if this is a PatientAdmissionContext
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Set tPriority = $CASE(pContext.Priority, 1:"EMERGENCY", 2:"URGENT", 3:"STANDARD", :"UNKNOWN")
        Do pContext.AddAdmissionNote("Triage completed, priority: " _ tPriority)
    }
    
    Quit tSC
}

}
