/// Pre-Admission State - Initial Patient Intake
/// 
/// Purpose:
/// Handles initial patient intake including insurance verification and consent forms.
/// This is the first state in the admission workflow.
/// 
/// Responsibilities:
/// - Verify insurance coverage
/// - Collect consent forms
/// - Initial patient data collection
/// - Transition to Registration state when complete
Class Patterns.Examples.PreAdmissionState Extends Patterns.Examples.AdmissionState
{

/// Handle state-specific requests
Method HandleStateSpecificRequest(pContext As Patterns.Examples.PatientAdmissionContext, pRequest As %String)
{
    Set tResponse = ""
    
    If pRequest = "VERIFY_INSURANCE" {
        Set pContext.InsuranceVerified = 1
        Set pContext.StateData("InsuranceVerified") = 1
        Set pContext.StateData("InsuranceVerifiedTime") = $ZDATETIME($HOROLOG, 3)
        Quit "Insurance verified successfully"
        
    } ElseIf pRequest = "COLLECT_CONSENT" {
        Set pContext.StateData("ConsentCollected") = 1
        Set pContext.StateData("ConsentTime") = $ZDATETIME($HOROLOG, 3)
        Quit "Consent forms collected"
        
    } ElseIf pRequest = "CHECK_REQUIREMENTS" {
        Set tSC = ..ValidateStateRequirements(pContext)
        If $$$ISOK(tSC) {
            Quit "All pre-admission requirements met"
        } Else {
            Quit "Pre-admission requirements not met: " _ $System.Status.GetErrorText(tSC)
        }
        
    } Else {
        Quit "Unknown pre-admission request: " _ pRequest
    }
}

/// Transition to the next state (Registration)
Method TransitionToNextState(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    // Validate requirements first
    Set tSC = ..ValidateStateRequirements(pContext)
    If $$$ISERR(tSC) {
        Quit tSC
    }
    
    // Create Registration state
    Set tNextState = ##class(Patterns.Examples.RegistrationState).%New()
    
    // Transition to Registration
    Set tSC = pContext.TransitionTo(tNextState)
    
    Quit tSC
}

/// Validate pre-admission requirements
Method ValidateStateRequirements(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    // Check insurance verification
    If 'pContext.InsuranceVerified {
        Quit $$$ERROR($$$GeneralError, "Insurance not verified")
    }
    
    // Check consent forms
    If '$GET(pContext.StateData("ConsentCollected"), 0) {
        Quit $$$ERROR($$$GeneralError, "Consent forms not collected")
    }
    
    // Check patient data
    If pContext.PatientID = "" {
        Quit $$$ERROR($$$GeneralError, "Patient ID not set")
    }
    
    If pContext.PatientName = "" {
        Quit $$$ERROR($$$GeneralError, "Patient name not set")
    }
    
    Quit tSC
}

/// Get allowed transitions from this state
Method GetAllowedTransitions() As %String
{
    // Pre-admission can only go to Registration (or emergency override to Treatment)
    Quit "Patterns.Examples.RegistrationState,Patterns.Examples.TreatmentState"
}

/// Handle entry into pre-admission state
Method OnEntry(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // Initialize pre-admission checklist
    Set pContext.StateData("PreAdmissionStarted") = $ZDATETIME($HOROLOG, 3)
    Set pContext.StateData("InsuranceVerified") = 0
    Set pContext.StateData("ConsentCollected") = 0
    
    // Add admission note if this is a PatientAdmissionContext
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Do pContext.AddAdmissionNote("Pre-admission process started")
    }
    
    Quit tSC
}

/// Handle exit from pre-admission state
Method OnExit(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // Record completion
    Set pContext.StateData("PreAdmissionCompleted") = $ZDATETIME($HOROLOG, 3)
    
    // Add admission note if this is a PatientAdmissionContext
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Do pContext.AddAdmissionNote("Pre-admission completed, proceeding to registration")
    }
    
    Quit tSC
}

}
