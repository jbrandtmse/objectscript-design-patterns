/// ObserverDebug: Debug class to verify Observer pattern implementation
/// <p>
/// This class provides debug methods to test the Observer pattern
/// implementation without using the %UnitTest framework.
/// </p>
Class Patterns.Test.Debug.ObserverDebug
{

/// Test the basic Observer pattern implementation
ClassMethod TestBasicObserver() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "Starting Basic Observer Test; "
        
        // Create subject
        Set subject = ##class(Patterns.GoF.Behavioral.Observer.Subject).%New()
        Set ^ClineDebug = ^ClineDebug _ "Subject created; "
        
        // Create observers
        Set observerA = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserverA).%New()
        Set observerB = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserverB).%New()
        Set ^ClineDebug = ^ClineDebug _ "Observers created; "
        
        // Attach observers
        Set tSC = subject.Attach(observerA)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to attach observerA; "
            Quit
        }
        Set tSC = subject.Attach(observerB)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to attach observerB; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Observers attached (count: " _ subject.GetObserverCount() _ "); "
        
        // Test notification
        Set tSC = subject.SetState("State1")
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to set state; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "State set to State1; "
        
        // Check observer states
        Set stateA = observerA.GetObservedState()
        Set stateB = observerB.GetLastProcessedState()
        Set ^ClineDebug = ^ClineDebug _ "ObserverA state: " _ stateA _ "; "
        Set ^ClineDebug = ^ClineDebug _ "ObserverB state: " _ stateB _ "; "
        
        // Test detach
        Set tSC = subject.Detach(observerA)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to detach observerA; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "ObserverA detached (count: " _ subject.GetObserverCount() _ "); "
        
        // Test notification after detach
        Set tSC = subject.SetState("State2")
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to set state2; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "State set to State2; "
        
        Set stateA = observerA.GetObservedState()
        Set stateB = observerB.GetLastProcessedState()
        Set ^ClineDebug = ^ClineDebug _ "ObserverA state (should be State1): " _ stateA _ "; "
        Set ^ClineDebug = ^ClineDebug _ "ObserverB state (should be State2): " _ stateB _ "; "
        
        Set ^ClineDebug = ^ClineDebug _ "Basic Observer Test completed successfully; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug _ "Error: " _ $System.Status.GetErrorText(tSC) _ "; "
    }
    
    Quit tSC
}

/// Test the healthcare example implementation
ClassMethod TestHealthcareExample() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "Starting Healthcare Example Test; "
        
        // Create vital signs monitor (subject)
        Set monitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("Patient123")
        Set ^ClineDebug = ^ClineDebug _ "VitalSignsMonitor created for Patient123; "
        
        // Create observers
        Set nurse = ##class(Patterns.Examples.NurseStation).%New("Station A")
        Set doctor = ##class(Patterns.Examples.DoctorPager).%New("Dr. Smith")
        Set medRecord = ##class(Patterns.Examples.MedicalRecord).%New("Patient123")
        Set ^ClineDebug = ^ClineDebug _ "Healthcare observers created; "
        
        // Attach observers
        Set tSC = monitor.RegisterObserver(nurse)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to register nurse; "
            Quit
        }
        Set tSC = monitor.RegisterObserver(doctor)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to register doctor; "
            Quit
        }
        Set tSC = monitor.RegisterObserver(medRecord)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to register medRecord; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "All observers registered; "
        
        // Test normal vital signs
        Set tSC = monitor.UpdateVitals(120, 80, 70, 98.6, 16)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to update normal vitals; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Normal vitals updated (120/80, HR:70, Temp:98.6, RR:16); "
        
        // Check alert levels
        Set nurseAlert = nurse.GetAlertLevel()
        Set doctorAlert = doctor.GetAlertLevel()
        Set ^ClineDebug = ^ClineDebug _ "Normal vitals - Nurse alert: " _ nurseAlert _ ", Doctor alert: " _ doctorAlert _ "; "
        
        // Test warning level vital signs
        Set tSC = monitor.UpdateVitals(145, 95, 105, 99.5, 22)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to update warning vitals; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Warning vitals updated (145/95, HR:105, Temp:99.5, RR:22); "
        
        Set nurseAlert = nurse.GetAlertLevel()
        Set doctorAlert = doctor.GetAlertLevel()
        Set ^ClineDebug = ^ClineDebug _ "Warning vitals - Nurse alert: " _ nurseAlert _ ", Doctor alert: " _ doctorAlert _ "; "
        
        // Test critical vital signs
        Set tSC = monitor.UpdateVitals(180, 120, 140, 103.5, 30)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to update critical vitals; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Critical vitals updated (180/120, HR:140, Temp:103.5, RR:30); "
        
        Set nurseAlert = nurse.GetAlertLevel()
        Set doctorAlert = doctor.GetAlertLevel()
        Set ^ClineDebug = ^ClineDebug _ "Critical vitals - Nurse alert: " _ nurseAlert _ ", Doctor alert: " _ doctorAlert _ "; "
        
        // Check medical record entries
        Set entryCount = medRecord.GetEntryCount()
        Set ^ClineDebug = ^ClineDebug _ "Medical record has " _ entryCount _ " entries; "
        
        Set ^ClineDebug = ^ClineDebug _ "Healthcare Example Test completed successfully; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug _ "Error: " _ $System.Status.GetErrorText(tSC) _ "; "
    }
    
    Quit tSC
}

}
