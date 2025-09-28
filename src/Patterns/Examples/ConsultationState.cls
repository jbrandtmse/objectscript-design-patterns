/// Consultation State - Doctor Examination
/// 
/// Purpose:
/// Handles doctor consultation, examination, and diagnosis.
/// This is the fourth state in the admission workflow after triage (for non-emergency cases).
/// 
/// Responsibilities:
/// - Assign physician
/// - Perform medical examination
/// - Make diagnosis
/// - Create treatment plan
/// - Transition to Treatment state when complete
Class Patterns.Examples.ConsultationState Extends Patterns.Examples.AdmissionState
{

/// Handle state-specific requests
Method HandleStateSpecificRequest(pContext As Patterns.Examples.PatientAdmissionContext, pRequest As %String)
{
    Set tResponse = ""
    
    If pRequest = "ASSIGN_PHYSICIAN" {
        Set tPhysicianID = "MD-" _ $RANDOM(100)
        Set pContext.AssignedPhysician = tPhysicianID
        Set pContext.StateData("PhysicianAssigned") = 1
        Set pContext.StateData("AssignedPhysician") = tPhysicianID
        Set pContext.StateData("PhysicianAssignedTime") = $ZDATETIME($HOROLOG, 3)
        Quit "Physician assigned: " _ tPhysicianID
        
    } ElseIf pRequest = "PERFORM_EXAMINATION" {
        Set pContext.StateData("ExaminationPerformed") = 1
        Set pContext.StateData("ExaminationTime") = $ZDATETIME($HOROLOG, 3)
        Set pContext.StateData("ExaminationFindings") = $GET(pContext.StateData("ExaminationFindings"), "Normal examination")
        Quit "Physical examination completed"
        
    } ElseIf pRequest = "MAKE_DIAGNOSIS" {
        Set pContext.StateData("DiagnosisMade") = 1
        Set tDiagnosisCode = "ICD-" _ $RANDOM(999) _ "." _ $RANDOM(99)
        Set pContext.StateData("DiagnosisCode") = tDiagnosisCode
        Set pContext.StateData("DiagnosisDescription") = $GET(pContext.StateData("DiagnosisDescription"), "General medical condition")
        Set pContext.StateData("DiagnosisTime") = $ZDATETIME($HOROLOG, 3)
        Quit "Diagnosis: " _ tDiagnosisCode _ " - " _ pContext.StateData("DiagnosisDescription")
        
    } ElseIf pRequest = "CREATE_TREATMENT_PLAN" {
        Set pContext.StateData("TreatmentPlanCreated") = 1
        Set pContext.StateData("TreatmentPlan") = $GET(pContext.StateData("TreatmentPlan"), "Standard treatment protocol")
        Set pContext.StateData("EstimatedTreatmentTime") = $GET(pContext.StateData("EstimatedTreatmentTime"), "2 hours")
        Quit "Treatment plan created"
        
    } ElseIf pRequest = "ORDER_MEDICATIONS" {
        Set pContext.StateData("MedicationsOrdered") = 1
        Set tMedList = $GET(pContext.StateData("MedicationList"), "Standard medication set")
        Set pContext.StateData("MedicationList") = tMedList
        Set pContext.StateData("MedicationOrderTime") = $ZDATETIME($HOROLOG, 3)
        Quit "Medications ordered: " _ tMedList
        
    } ElseIf pRequest = "CHECK_REQUIREMENTS" {
        Set tSC = ..ValidateStateRequirements(pContext)
        If $$$ISOK(tSC) {
            Quit "All consultation requirements met"
        } Else {
            Quit "Consultation requirements not met: " _ $System.Status.GetErrorText(tSC)
        }
        
    } Else {
        Quit "Unknown consultation request: " _ pRequest
    }
}

/// Transition to the next state (Treatment)
Method TransitionToNextState(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    // Validate requirements first
    Set tSC = ..ValidateStateRequirements(pContext)
    If $$$ISERR(tSC) {
        Quit tSC
    }
    
    // Create Treatment state
    Set tNextState = ##class(Patterns.Examples.TreatmentState).%New()
    
    // Transition to Treatment
    Set tSC = pContext.TransitionTo(tNextState)
    
    Quit tSC
}

/// Validate consultation requirements
Method ValidateStateRequirements(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    // Check physician assigned
    If '$GET(pContext.StateData("PhysicianAssigned"), 0) {
        Quit $$$ERROR($$$GeneralError, "Physician not assigned")
    }
    
    // Check examination performed
    If '$GET(pContext.StateData("ExaminationPerformed"), 0) {
        Quit $$$ERROR($$$GeneralError, "Examination not performed")
    }
    
    // Check diagnosis made
    If '$GET(pContext.StateData("DiagnosisMade"), 0) {
        Quit $$$ERROR($$$GeneralError, "Diagnosis not made")
    }
    
    // Check treatment plan created
    If '$GET(pContext.StateData("TreatmentPlanCreated"), 0) {
        Quit $$$ERROR($$$GeneralError, "Treatment plan not created")
    }
    
    Quit tSC
}

/// Get allowed transitions from this state
Method GetAllowedTransitions() As %String
{
    // Consultation typically goes to Treatment
    Quit "Patterns.Examples.TreatmentState"
}

/// Handle entry into consultation state
Method OnEntry(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // Initialize consultation checklist
    Set pContext.StateData("ConsultationStarted") = $ZDATETIME($HOROLOG, 3)
    Set pContext.StateData("PhysicianAssigned") = 0
    Set pContext.StateData("ExaminationPerformed") = 0
    Set pContext.StateData("DiagnosisMade") = 0
    Set pContext.StateData("TreatmentPlanCreated") = 0
    
    // Add admission note if this is a PatientAdmissionContext
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Do pContext.AddAdmissionNote("Doctor consultation started")
    }
    
    Quit tSC
}

/// Handle exit from consultation state
Method OnExit(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // Record completion
    Set pContext.StateData("ConsultationCompleted") = $ZDATETIME($HOROLOG, 3)
    
    // Add admission note with diagnosis if this is a PatientAdmissionContext
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Set tDiagnosis = $GET(pContext.StateData("DiagnosisCode"), "TBD")
        Do pContext.AddAdmissionNote("Consultation completed, diagnosis: " _ tDiagnosis _ ", proceeding to treatment")
    }
    
    Quit tSC
}

}
