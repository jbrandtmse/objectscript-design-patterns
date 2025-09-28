/// Discharge State - Patient Discharge Process
/// 
/// Purpose:
/// Handles patient discharge including final documentation and follow-up scheduling.
/// This is the final state in the admission workflow.
/// 
/// Responsibilities:
/// - Complete discharge documentation
/// - Schedule follow-up appointments
/// - Provide discharge instructions
/// - Generate discharge summary
Class Patterns.Examples.DischargeState Extends Patterns.Examples.AdmissionState
{

/// Handle state-specific requests
Method HandleStateSpecificRequest(pContext As Patterns.Examples.PatientAdmissionContext, pRequest As %String)
{
    Set tResponse = ""
    
    If pRequest = "PREPARE_DISCHARGE_SUMMARY" {
        Set pContext.StateData("DischargeSummaryPrepared") = 1
        Set pContext.StateData("DischargeSummaryTime") = $ZDATETIME($HOROLOG, 3)
        Set tSummaryID = "DS-" _ pContext.PatientID _ "-" _ $PIECE($HOROLOG, ",", 1)
        Set pContext.StateData("DischargeSummaryID") = tSummaryID
        Quit "Discharge summary prepared: " _ tSummaryID
        
    } ElseIf pRequest = "SCHEDULE_FOLLOWUP" {
        Set pContext.StateData("FollowupScheduled") = 1
        Set tDaysAhead = 7 + $RANDOM(14)
        Set tFollowupDate = $ZDATETIME($HOROLOG + tDaysAhead, 3)
        Set pContext.StateData("FollowupDate") = tFollowupDate
        Set pContext.StateData("FollowupDoctor") = $GET(pContext.AssignedPhysician, "Primary Care")
        Quit "Follow-up scheduled for " _ tFollowupDate
        
    } ElseIf pRequest = "PROVIDE_INSTRUCTIONS" {
        Set pContext.StateData("InstructionsProvided") = 1
        Set pContext.StateData("InstructionsTime") = $ZDATETIME($HOROLOG, 3)
        Set tInstructions = $GET(pContext.StateData("DischargeInstructions"), "Standard discharge instructions")
        Set pContext.StateData("DischargeInstructions") = tInstructions
        Quit "Discharge instructions provided to patient"
        
    } ElseIf pRequest = "PRESCRIBE_MEDICATIONS" {
        Set pContext.StateData("PrescriptionsGiven") = 1
        Set tRxNumber = "RX-" _ $RANDOM(999999)
        Set pContext.StateData("PrescriptionNumber") = tRxNumber
        Set pContext.StateData("PrescriptionList") = $GET(pContext.StateData("PrescriptionList"), "Standard medications")
        Quit "Prescriptions provided: " _ tRxNumber
        
    } ElseIf pRequest = "COMPLETE" {
        Set tSC = ..ValidateStateRequirements(pContext)
        If $$$ISOK(tSC) {
            Set pContext.StateData("DischargeCompleted") = 1
            Set pContext.StateData("DischargeTime") = $ZDATETIME($HOROLOG, 3)
            Quit "Discharge completed successfully"
        } Else {
            Quit "Cannot complete discharge: " _ $System.Status.GetErrorText(tSC)
        }
        
    } ElseIf pRequest = "CHECK_REQUIREMENTS" {
        Set tSC = ..ValidateStateRequirements(pContext)
        If $$$ISOK(tSC) {
            Quit "All discharge requirements met"
        } Else {
            Quit "Discharge requirements not met: " _ $System.Status.GetErrorText(tSC)
        }
        
    } Else {
        Quit "Unknown discharge request: " _ pRequest
    }
}

/// Transition to the next state (none - this is terminal)
Method TransitionToNextState(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    // Discharge is the final state
    Quit $$$ERROR($$$GeneralError, "Discharge is the final state - no transition available")
}

/// Validate discharge requirements
Method ValidateStateRequirements(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    // Check discharge summary prepared
    If '$GET(pContext.StateData("DischargeSummaryPrepared"), 0) {
        Quit $$$ERROR($$$GeneralError, "Discharge summary not prepared")
    }
    
    // Check follow-up scheduled (if needed)
    If pContext.Priority '= 3 {  // Not standard priority
        If '$GET(pContext.StateData("FollowupScheduled"), 0) {
            Quit $$$ERROR($$$GeneralError, "Follow-up appointment not scheduled")
        }
    }
    
    // Check instructions provided
    If '$GET(pContext.StateData("InstructionsProvided"), 0) {
        Quit $$$ERROR($$$GeneralError, "Discharge instructions not provided")
    }
    
    // Check prescriptions (if medications were ordered)
    If $GET(pContext.StateData("MedicationsOrdered"), 0) {
        If '$GET(pContext.StateData("PrescriptionsGiven"), 0) {
            Quit $$$ERROR($$$GeneralError, "Prescriptions not provided")
        }
    }
    
    Quit tSC
}

/// Get allowed transitions from this state
Method GetAllowedTransitions() As %String
{
    // Discharge is terminal state - no transitions allowed
    Quit ""
}

/// Handle entry into discharge state
Method OnEntry(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // Initialize discharge checklist
    Set pContext.StateData("DischargeStarted") = $ZDATETIME($HOROLOG, 3)
    Set pContext.StateData("DischargeSummaryPrepared") = 0
    Set pContext.StateData("FollowupScheduled") = 0
    Set pContext.StateData("InstructionsProvided") = 0
    Set pContext.StateData("PrescriptionsGiven") = 0
    
    // Assign discharge coordinator
    Set tCoordinatorID = "DC-" _ $RANDOM(100)
    Set pContext.StateData("DischargeCoordinator") = tCoordinatorID
    
    // Add admission note if this is a PatientAdmissionContext
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Do pContext.AddAdmissionNote("Discharge process started by " _ tCoordinatorID)
    }
    
    Quit tSC
}

/// Handle exit from discharge state
Method OnExit(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Set tSC = ##super(pContext)
    
    // This should not normally be called as discharge is terminal
    // But we implement it for completeness
    
    // Record completion
    Set pContext.StateData("DischargeFinalized") = $ZDATETIME($HOROLOG, 3)
    
    // Add final admission note if this is a PatientAdmissionContext
    If $CLASSNAME(pContext) = "Patterns.Examples.PatientAdmissionContext" {
        Do pContext.AddAdmissionNote("Patient discharged from facility")
    }
    
    Quit tSC
}

/// Special method to finalize discharge
Method FinalizeDischarge(pContext As Patterns.Examples.PatientAdmissionContext) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate all requirements
        Set tSC = ..ValidateStateRequirements(pContext)
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        // Mark as completed
        Set pContext.StateData("DischargeCompleted") = 1
        Set pContext.StateData("DischargeTime") = $ZDATETIME($HOROLOG, 3)
        
        // Generate final report
        Do pContext.GenerateAdmissionSummary()
        
        // Clear active admission flag
        Set pContext.StateData("AdmissionActive") = 0
        
        // Log completion
        Set tLogEntry = $ZDATETIME($HOROLOG, 3) _ " | DISCHARGE COMPLETE | Patient: " _ pContext.PatientID
        Set ^Patterns.Admission.DischargeLog($INCREMENT(^Patterns.Admission.DischargeLog)) = tLogEntry
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
