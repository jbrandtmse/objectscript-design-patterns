Include %sySystem

/// Unit Tests for Gang of Four State Pattern
/// 
/// Purpose:
/// Comprehensive test suite for State pattern implementation including:
/// - Basic state transitions
/// - Invalid transition handling
/// - State-specific behavior
/// - Guard conditions
/// - Entry/exit actions
/// - State history tracking
/// - State persistence/restoration
/// - Healthcare workflow example testing
Class Patterns.Test.Unit.GoF.Behavioral.StateTest Extends %UnitTest.TestCase
{

// ===== TEST FIXTURES =====

/// Create a simple test context
Method CreateTestContext() As Patterns.GoF.Behavioral.StateContext
{
    Set tContext = ##class(Patterns.GoF.Behavioral.StateContext).%New()
    Quit tContext
}

/// Create a patient admission context
Method CreatePatientContext() As Patterns.Examples.PatientAdmissionContext
{
    Set tContext = ##class(Patterns.Examples.PatientAdmissionContext).%New()
    Do tContext.InitializePatient("PAT001", "John Doe")
    Quit tContext
}

// ===== BASIC STATE TESTS =====

/// Test basic state context creation
Method TestStateContextCreation()
{
    Set tContext = ..CreateTestContext()
    
    Do $$$AssertTrue($IsObject(tContext), "Context created successfully")
    Do $$$AssertEquals(tContext.TransitionCount, 0, "Initial transition count is 0")
    Do $$$AssertEquals(tContext.GetCurrentStateName(), "", "No initial state set")
    
    Quit 1
}

/// Test state transition mechanism
Method TestBasicStateTransition()
{
    // Create patient context (has initial state)
    Set tContext = ..CreatePatientContext()
    
    Do $$$AssertTrue($IsObject(tContext), "Patient context created")
    Do $$$AssertEquals(tContext.GetCurrentStateName(), "Patterns.Examples.PreAdmissionState", "Initial state is PreAdmission")
    Do $$$AssertEquals(tContext.TransitionCount, 1, "One transition occurred (to initial state)")
    
    // Process pre-admission requirements
    Set tResponse = tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do $$$AssertTrue(tResponse [ "verified", "Insurance verification processed")
    
    Set tResponse = tContext.ProcessAdmission("COLLECT_CONSENT")
    Do $$$AssertTrue(tResponse [ "collected", "Consent forms collected")
    
    // Transition to next state
    Set tSC = tContext.MoveToNextState()
    Do $$$AssertStatusOK(tSC, "Transition to Registration successful")
    Do $$$AssertEquals(tContext.GetCurrentStateName(), "Patterns.Examples.RegistrationState", "Now in Registration state")
    Do $$$AssertEquals(tContext.TransitionCount, 2, "Two transitions total")
    
    Quit 1
}

/// Test invalid state transitions
Method TestInvalidStateTransition()
{
    Set tContext = ..CreatePatientContext()
    
    // Try to move to next state without meeting requirements
    Set tSC = tContext.MoveToNextState()
    Do $$$AssertStatusNotOK(tSC, "Cannot transition without meeting requirements")
    
    // Verify still in original state
    Do $$$AssertEquals(tContext.GetCurrentStateName(), "Patterns.Examples.PreAdmissionState", "Still in PreAdmission state")
    
    Quit 1
}

// ===== STATE-SPECIFIC BEHAVIOR TESTS =====

/// Test state-specific request handling
Method TestStateSpecificBehavior()
{
    Set tContext = ..CreatePatientContext()
    
    // Test PreAdmission state behavior
    Set tResponse = tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do $$$AssertTrue(tResponse [ "verified", "PreAdmission handles insurance verification")
    
    // Complete pre-admission and move to registration
    Do tContext.ProcessAdmission("COLLECT_CONSENT")
    Set tSC = tContext.MoveToNextState()
    Do $$$AssertStatusOK(tSC, "Moved to Registration")
    
    // Test Registration state behavior
    Set tResponse = tContext.ProcessAdmission("SET_DEMOGRAPHICS")
    Do $$$AssertTrue(tResponse [ "recorded", "Registration handles demographics")
    
    Set tResponse = tContext.ProcessAdmission("ASSIGN_BED")
    Do $$$AssertTrue(tResponse [ "Assigned to bed", "Registration assigns bed")
    
    Quit 1
}

/// Test state validation requirements
Method TestStateValidationRequirements()
{
    Set tContext = ..CreatePatientContext()
    
    // Check initial requirements
    Set tResponse = tContext.ProcessAdmission("CHECK_REQUIREMENTS")
    Do $$$AssertTrue(tResponse [ "not met", "Initial requirements not met")
    
    // Fulfill requirements
    Do tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do tContext.ProcessAdmission("COLLECT_CONSENT")
    
    // Check again
    Set tResponse = tContext.ProcessAdmission("CHECK_REQUIREMENTS")
    Do $$$AssertTrue(tResponse [ "requirements met", "Requirements now met")
    
    Quit 1
}

// ===== GUARD CONDITIONS TESTS =====

/// Test guard conditions for transitions
Method TestGuardConditions()
{
    Set tContext = ..CreatePatientContext()
    
    // Complete pre-admission
    Do tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do tContext.ProcessAdmission("COLLECT_CONSENT")
    Do tContext.MoveToNextState()
    
    // Complete registration
    Do tContext.ProcessAdmission("SET_DEMOGRAPHICS")
    Do tContext.ProcessAdmission("SET_CONTACT_INFO")
    Do tContext.ProcessAdmission("ASSIGN_BED")
    Do tContext.ProcessAdmission("CREATE_WRISTBAND")
    Do tContext.MoveToNextState()
    
    // Now in Triage - test priority-based transition
    Do tContext.ProcessAdmission("RECORD_VITALS")
    Do tContext.ProcessAdmission("ASSESS_SYMPTOMS")
    
    // Set high priority (emergency)
    Set tContext.StateData("PainLevel") = 9
    Do tContext.ProcessAdmission("ASSIGN_PRIORITY")
    
    // Should skip consultation for emergency
    Set tSC = tContext.MoveToNextState()
    Do $$$AssertStatusOK(tSC, "Emergency transition successful")
    Do $$$AssertEquals(tContext.GetCurrentStateName(), "Patterns.Examples.TreatmentState", "Skipped to Treatment for emergency")
    
    Quit 1
}

// ===== ENTRY/EXIT ACTIONS TESTS =====

/// Test state entry and exit actions
Method TestEntryExitActions()
{
    Set tContext = ..CreatePatientContext()
    
    // Check entry action was executed
    Do $$$AssertTrue($DATA(tContext.StateData("PreAdmissionStarted")), "Entry action set start time")
    
    // Complete pre-admission and transition
    Do tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do tContext.ProcessAdmission("COLLECT_CONSENT")
    Set tSC = tContext.MoveToNextState()
    Do $$$AssertStatusOK(tSC, "Transition successful")
    
    // Check exit action was executed
    Do $$$AssertTrue($DATA(tContext.StateData("PreAdmissionCompleted")), "Exit action set completion time")
    
    // Check new state entry action
    Do $$$AssertTrue($DATA(tContext.StateData("RegistrationStarted")), "Registration entry action executed")
    
    Quit 1
}

// ===== STATE HISTORY TESTS =====

/// Test state history tracking
Method TestStateHistory()
{
    Set tContext = ..CreatePatientContext()
    
    // Make several transitions
    Do tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do tContext.ProcessAdmission("COLLECT_CONSENT")
    Do tContext.MoveToNextState()
    
    Do tContext.ProcessAdmission("SET_DEMOGRAPHICS")
    Do tContext.ProcessAdmission("SET_CONTACT_INFO")
    Do tContext.ProcessAdmission("ASSIGN_BED")
    Do tContext.ProcessAdmission("CREATE_WRISTBAND")
    Do tContext.MoveToNextState()
    
    // Check history
    Set tHistory = tContext.GetHistoryString()
    Do $$$AssertTrue(tHistory [ "PreAdmissionState", "History contains PreAdmission")
    Do $$$AssertTrue(tHistory [ "RegistrationState", "History contains Registration")
    Do $$$AssertTrue(tHistory [ "TriageState", "History contains Triage")
    
    Do $$$AssertEquals(tContext.StateHistory.Count(), 3, "History has 3 entries")
    
    Quit 1
}

/// Test state rollback capability
Method TestStateRollback()
{
    Set tContext = ..CreatePatientContext()
    
    // Save initial state
    Set tInitialState = tContext.GetCurrentStateName()
    
    // Transition to next state
    Do tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do tContext.ProcessAdmission("COLLECT_CONSENT")
    Do tContext.MoveToNextState()
    
    Set tSecondState = tContext.GetCurrentStateName()
    Do $$$AssertNotEquals(tSecondState, tInitialState, "State changed")
    
    // Rollback
    Set tSC = tContext.RollbackToPreviousState()
    Do $$$AssertStatusOK(tSC, "Rollback successful")
    Do $$$AssertEquals(tContext.GetCurrentStateName(), tInitialState, "Rolled back to previous state")
    
    Quit 1
}

// ===== PERSISTENCE TESTS =====

/// Test state persistence and restoration
Method TestStatePersistence()
{
    Set tContext = ..CreatePatientContext()
    Set tKey = "TEST_" _ $RANDOM(9999)
    
    // Make some state changes
    Do tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do tContext.ProcessAdmission("COLLECT_CONSENT")
    Do tContext.MoveToNextState()
    
    // Save state
    Set tSC = tContext.SaveState(tKey)
    Do $$$AssertStatusOK(tSC, "State saved successfully")
    
    // Create new context and load state
    Set tNewContext = ##class(Patterns.GoF.Behavioral.StateContext).%New()
    Set tSC = tNewContext.LoadState(tKey)
    Do $$$AssertStatusOK(tSC, "State loaded successfully")
    
    // Verify loaded data
    Do $$$AssertEquals(tNewContext.TransitionCount, tContext.TransitionCount, "Transition count restored")
    Do $$$AssertEquals(tNewContext.StateHistory.Count(), tContext.StateHistory.Count(), "History restored")
    
    // Clean up
    Kill ^Patterns.State.Saved(tKey)
    
    Quit 1
}

// ===== HEALTHCARE WORKFLOW TESTS =====

/// Test complete patient admission workflow
Method TestCompleteAdmissionWorkflow()
{
    Set tContext = ..CreatePatientContext()
    
    // Pre-Admission
    Do tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do tContext.ProcessAdmission("COLLECT_CONSENT")
    Do tContext.MoveToNextState()
    
    // Registration
    Do tContext.ProcessAdmission("SET_DEMOGRAPHICS")
    Do tContext.ProcessAdmission("SET_CONTACT_INFO")
    Do tContext.ProcessAdmission("ASSIGN_BED")
    Do tContext.ProcessAdmission("CREATE_WRISTBAND")
    Do tContext.MoveToNextState()
    
    // Triage
    Do tContext.ProcessAdmission("RECORD_VITALS")
    Do tContext.ProcessAdmission("ASSESS_SYMPTOMS")
    Do tContext.ProcessAdmission("ASSIGN_PRIORITY")
    Do tContext.MoveToNextState()
    
    // Consultation (non-emergency path)
    Do $$$AssertEquals(tContext.GetCurrentStateName(), "Patterns.Examples.ConsultationState", "In Consultation state")
    Do tContext.ProcessAdmission("ASSIGN_PHYSICIAN")
    Do tContext.ProcessAdmission("PERFORM_EXAMINATION")
    Do tContext.ProcessAdmission("MAKE_DIAGNOSIS")
    Do tContext.ProcessAdmission("CREATE_TREATMENT_PLAN")
    Do tContext.MoveToNextState()
    
    // Treatment
    Do $$$AssertEquals(tContext.GetCurrentStateName(), "Patterns.Examples.TreatmentState", "In Treatment state")
    Do tContext.ProcessAdmission("ADMINISTER_MEDICATION")
    Do tContext.ProcessAdmission("MONITOR_PROGRESS")
    Do tContext.ProcessAdmission("ASSESS_DISCHARGE_READY")
    Do tContext.MoveToNextState()
    
    // Discharge
    Do $$$AssertEquals(tContext.GetCurrentStateName(), "Patterns.Examples.DischargeState", "In Discharge state")
    Do tContext.ProcessAdmission("PREPARE_DISCHARGE_SUMMARY")
    Do tContext.ProcessAdmission("PROVIDE_INSTRUCTIONS")
    
    // Verify can't transition from terminal state
    Set tSC = tContext.MoveToNextState()
    Do $$$AssertStatusNotOK(tSC, "Cannot transition from Discharge state")
    
    Quit 1
}

/// Test emergency override workflow
Method TestEmergencyOverride()
{
    Set tContext = ..CreatePatientContext()
    
    // Trigger emergency override
    Set tSC = tContext.EmergencyOverride()
    Do $$$AssertStatusOK(tSC, "Emergency override successful")
    
    // Verify jumped to Treatment
    Do $$$AssertEquals(tContext.GetCurrentStateName(), "Patterns.Examples.TreatmentState", "Jumped to Treatment state")
    Do $$$AssertEquals(tContext.Priority, 1, "Priority set to emergency")
    Do $$$AssertTrue($GET(tContext.StateData("EmergencyOverride")), "Emergency flag set")
    
    Quit 1
}

// ===== TIMEOUT HANDLING TESTS =====

/// Test state timeout handling
Method TestStateTimeout()
{
    Set tContext = ..CreatePatientContext()
    
    // Set short timeout
    Set tContext.TimeoutDuration = 1
    
    // Get initial state for re-use
    Set tState = tContext.CurrentState
    
    // Wait for timeout
    Hang 2
    
    // Trigger timeout check via request which calls CheckTimeout
    Do tContext.Request("STATUS")
    
    // Check if timeout was handled (check alert was generated)
    Do $$$AssertTrue($DATA(^Patterns.Admission.Alerts), "Timeout alert created")
    
    // Clean up
    Kill ^Patterns.Admission.Alerts
    
    Quit 1
}

// ===== CONCURRENT ACCESS TESTS =====

/// Test concurrent state access handling
Method TestConcurrentStateAccess()
{
    Set tContext = ..CreatePatientContext()
    
    // Simulate concurrent access by checking state consistency
    Set tState1 = tContext.GetCurrentStateName()
    
    // Make changes
    Do tContext.ProcessAdmission("VERIFY_INSURANCE")
    
    // Verify state hasn't changed unexpectedly
    Set tState2 = tContext.GetCurrentStateName()
    Do $$$AssertEquals(tState1, tState2, "State remains consistent")
    
    // Verify data integrity
    Do $$$AssertTrue(tContext.InsuranceVerified, "State data updated correctly")
    
    Quit 1
}

// ===== PERFORMANCE TESTS =====

/// Test state transition performance
Method TestStateTransitionPerformance()
{
    Set tContext = ..CreateTestContext()
    Set tInitialCount = tContext.TransitionCount
    Set tStartTime = $PIECE($HOROLOG, ",", 2)
    
    // Perform multiple transitions
    For i = 1:1:10 {
        Set tState = ##class(Patterns.Examples.PreAdmissionState).%New()
        Do tContext.TransitionTo(tState)
        Set tState = ##class(Patterns.Examples.RegistrationState).%New()
        Do tContext.TransitionTo(tState)
    }
    
    Set tEndTime = $PIECE($HOROLOG, ",", 2)
    Set tElapsed = tEndTime - tStartTime
    Set tFinalCount = tContext.TransitionCount
    Set tTransitionsMade = tFinalCount - tInitialCount
    
    // Should complete 20 transitions in under 1 second
    Do $$$AssertTrue(tElapsed < 1, "Transitions completed quickly (" _ tElapsed _ " seconds)")
    Do $$$AssertEquals(tTransitionsMade, 20, "All transitions counted")
    
    Quit 1
}

// ===== ERROR RECOVERY TESTS =====

/// Test error recovery in state transitions
Method TestErrorRecovery()
{
    Set tContext = ..CreatePatientContext()
    
    // Try invalid transition
    Set tInvalidState = ""
    Set tSC = tContext.TransitionTo(tInvalidState)
    Do $$$AssertStatusNotOK(tSC, "Invalid transition rejected")
    
    // Verify context still functional
    Set tResponse = tContext.ProcessAdmission("STATUS")
    Do $$$AssertTrue(tResponse [ "PreAdmissionState", "Context still in valid state")
    
    // Can still make valid transitions
    Do tContext.ProcessAdmission("VERIFY_INSURANCE")
    Do tContext.ProcessAdmission("COLLECT_CONSENT")
    Set tSC = tContext.MoveToNextState()
    Do $$$AssertStatusOK(tSC, "Valid transition works after error")
    
    Quit 1
}

// ===== CLEANUP =====

/// Clean up after tests
Method OnAfterAllTests() As %Status
{
    // Clean up test globals
    Kill ^Patterns.State.TransitionLog
    Kill ^Patterns.State.Saved
    Kill ^Patterns.Admission.AuditTrail
    Kill ^Patterns.Admission.PatientAudit
    Kill ^Patterns.Admission.EmergencyLog
    Kill ^Patterns.Admission.DischargeLog
    Kill ^Patterns.Admission.Summary
    Kill ^Patterns.Admission.Reports
    Kill ^Patterns.Admission.Alerts
    
    Quit $$$OK
}

}
