/// Registration State - Patient Demographics and Contact Information
/// 
/// Purpose:
/// Handles patient registration including demographics and contact information collection.
/// This is the second state in the admission workflow after pre-admission.
/// 
/// Responsibilities:
/// - Collect patient demographics
/// - Record contact information
/// - Assign patient room/bed
/// - Transition to Triage state when complete
Class Patterns.Examples.RegistrationState Extends Patterns.Examples.AdmissionState
{

/// Handle state-specific requests
Method HandleStateSpecificRequest(pContext As Patterns.Examples.PatientAdmissionContext, pRequest As %String)
{
    Set tResponse = ""
    
    If pRequest = "SET_DEMOGRAPHICS" {
        Set pContext.StateData("DemographicsCollected") = 1
        Set pContext.StateData("DemographicsTime") = $ZDATETIME($HOROLOG, 3)
        Quit "Demographics recorded successfully"
        
    } ElseIf pRequest = "SET_CONTACT_INFO" {
        Set pContext.StateData("ContactInfoCollected") = 1
        Set pContext.StateData("EmergencyContact") = $GET(pContext.StateData("EmergencyContact"), "Not provided")
        Quit "Contact information recorded"
        
    } ElseIf pRequest = "ASSIGN_BED" {
        Set tBedNumber = "B" _ $RANDOM(100) _ "-" _ $RANDOM(999)
        Set pContext.StateData("AssignedBed") = tBedNumber
        Set pContext.StateData("BedAssignedTime") = $ZDATETIME($HOROLOG, 3)
        Quit "Assigned to bed: " _ tBedNumber
        
    } ElseIf pRequest = "CREATE_WRISTBAND" {
        Set pContext.StateData("WristbandCreated") = 1
        Set pContext.StateData("WristbandID") = "WB-" _ pContext.PatientID _ "-" _ $PIECE($HOROLOG, ",", 1)
        Quit "Patient wristband created: " _ pContext.StateData("WristbandID")
        
    } ElseIf pRequest = "CHECK_REQUIREMENTS" {
        Set tSC = ..ValidateStateRequirements(pContext)
        If $$$ISOK(tSC) {
            Quit "All registration requirements met"
        } Else {
            Quit "Registration requirements not met: " _ $System.Status.GetErrorText(tSC)
        }
        
    } Else {
        Quit "Unknown registration request: " _ pRequest
    }
}

/// Transition to the next state (Triage)
Method TransitionToNextState(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    // Validate requirements first
    Set tSC = ..ValidateStateRequirements(pContext)
    If $$$ISERR(tSC) {
        Quit tSC
    }
    
    // Create Triage state
    Set tNextState = ##class(Patterns.Examples.TriageState).%New()
    
    // Transition to Triage
    Set tSC = pContext.TransitionTo(tNextState)
    
    Quit tSC
}

/// Validate registration requirements
Method ValidateStateRequirements(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    // Check demographics collected
    If '$GET(pContext.StateData("DemographicsCollected"), 0) {
        Quit $$$ERROR($$$GeneralError, "Patient demographics not collected")
    }
    
    // Check contact information
    If '$GET(pContext.StateData("ContactInfoCollected"), 0) {
        Quit $$$ERROR($$$GeneralError, "Contact information not collected")
    }
    
    // Check bed assignment (not required for emergency cases)
    If pContext.Priority '= 1 {
        If '$DATA(pContext.StateData("AssignedBed")) {
            Quit $$$ERROR($$$GeneralError, "Bed not assigned")
        }
    }
    
    // Check wristband created
    If '$GET(pContext.StateData("WristbandCreated"), 0) {
        Quit $$$ERROR($$$GeneralError, "Patient wristband not created")
    }
    
    Quit tSC
}

/// Get allowed transitions from this state
Method GetAllowedTransitions() As %String
{
    // Registration can go to Triage, back to PreAdmission, or emergency override to Treatment
    Quit "Patterns.Examples.TriageState,Patterns.Examples.PreAdmissionState,Patterns.Examples.TreatmentState"
}

/// Handle entry into registration state
Method OnEntry(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // Initialize registration checklist
    Set pContext.StateData("RegistrationStarted") = $ZDATETIME($HOROLOG, 3)
    Set pContext.StateData("DemographicsCollected") = 0
    Set pContext.StateData("ContactInfoCollected") = 0
    Set pContext.StateData("WristbandCreated") = 0
    
    // Add admission note if this is a PatientAdmissionContext
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Do pContext.AddAdmissionNote("Registration process started")
    }
    
    Quit tSC
}

/// Handle exit from registration state
Method OnExit(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // Record completion
    Set pContext.StateData("RegistrationCompleted") = $ZDATETIME($HOROLOG, 3)
    
    // Add admission note if this is a PatientAdmissionContext
    Set tBed = $GET(pContext.StateData("AssignedBed"), "TBD")
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Do pContext.AddAdmissionNote("Registration completed, bed: " _ tBed _ ", proceeding to triage")
    }
    
    Quit tSC
}

}
