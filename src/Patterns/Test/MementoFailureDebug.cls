/// Debug test for failing Memento tests
Class Patterns.Test.MementoFailureDebug Extends %RegisteredObject
{

ClassMethod DebugBasicSaveRestore() As %Status
{
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "TestBasicSaveRestore debug; "
        
        // Create originator with initial state
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("TEST001")
        Set ^ClineDebug = ^ClineDebug _ "Originator created; "
        
        Set tOriginator.PatientName = "John Doe"
        Set tOriginator.Diagnosis = "Initial diagnosis"
        Set tOriginator.TreatmentPlan = "Initial treatment"
        Set ^ClineDebug = ^ClineDebug _ "Initial state set; "
        
        // Save state to memento
        Set tMemento1 = tOriginator.CreateMemento("Initial save")
        Set ^ClineDebug = ^ClineDebug _ "Memento created=" _ $IsObject(tMemento1) _ "; "
        
        // Modify originator state
        Set tOriginator.Diagnosis = "Updated diagnosis"
        Do tOriginator.AddMedication("Aspirin", "testuser")
        Set ^ClineDebug = ^ClineDebug _ "State modified; "
        Set ^ClineDebug = ^ClineDebug _ "Meds count after add=" _ tOriginator.Medications.Count() _ "; "
        
        // Restore from memento
        Set tSC = tOriginator.RestoreFromMemento(tMemento1)
        Set ^ClineDebug = ^ClineDebug _ "Restore status=" _ $System.Status.GetErrorText(tSC) _ "; "
        
        // Verify restoration
        Set ^ClineDebug = ^ClineDebug _ "After restore: "
        Set ^ClineDebug = ^ClineDebug _ "Diagnosis='" _ tOriginator.Diagnosis _ "'; "
        Set ^ClineDebug = ^ClineDebug _ "Medications.Count=" _ tOriginator.Medications.Count() _ "; "
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "EXCEPTION: " _ ex.DisplayString() _ "; "
    }
    
    Set ^ClineDebug = ^ClineDebug _ "DONE"
    Quit $$$OK
}

ClassMethod DebugMementoIntegrity() As %Status
{
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "TestMementoIntegrity debug; "
        
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("TEST008")
        Set tOriginator.PatientName = "Integrity Test"
        Set tOriginator.Diagnosis = "Test diagnosis"
        
        // Create memento
        Set tMemento = tOriginator.CreateMemento("Integrity test")
        Set ^ClineDebug = ^ClineDebug _ "Memento created=" _ $IsObject(tMemento) _ "; "
        
        If $IsObject(tMemento) && tMemento.%IsA("Patterns.Examples.PatientRecordMemento") {
            Set ^ClineDebug = ^ClineDebug _ "Is PatientRecordMemento; "
            
            // Check integrity
            Set tIntegrity = tMemento.VerifyIntegrity()
            Set ^ClineDebug = ^ClineDebug _ "VerifyIntegrity=" _ tIntegrity _ "; "
            
            // Get patient data
            Set tRetrievedData = tMemento.GetPatientData()
            Set ^ClineDebug = ^ClineDebug _ "GetPatientData='" _ tRetrievedData _ "'; "
            Set ^ClineDebug = ^ClineDebug _ "Data empty=" _ (tRetrievedData = "") _ "; "
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "EXCEPTION: " _ ex.DisplayString() _ "; "
    }
    
    Set ^ClineDebug = ^ClineDebug _ "DONE"
    Quit $$$OK
}

ClassMethod DebugAuditTrail() As %Status
{
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "TestAuditTrail debug; "
        
        Set tCaretaker = ##class(Patterns.Examples.PatientRecordCaretaker).%New("TEST009")
        Set ^ClineDebug = ^ClineDebug _ "Caretaker created; "
        
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("TEST009")
        
        // Create some activity
        Set tMemento = tOriginator.CreateMemento("Audit test")
        Do tCaretaker.AddVersion(tMemento)
        Set ^ClineDebug = ^ClineDebug _ "Version added; "
        
        // Get audit trail
        Set tSC = tCaretaker.GetAuditTrail(.tTrail)
        Set ^ClineDebug = ^ClineDebug _ "GetAuditTrail status=" _ $System.Status.GetErrorText(tSC) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Trail is object=" _ $IsObject(tTrail) _ "; "
        
        If $IsObject(tTrail) {
            Set ^ClineDebug = ^ClineDebug _ "Trail size=" _ tTrail.%Size() _ "; "
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "EXCEPTION: " _ ex.DisplayString() _ "; "
    }
    
    Set ^ClineDebug = ^ClineDebug _ "DONE"
    Quit $$$OK
}

ClassMethod RunAll() As %Status
{
    Do ..DebugBasicSaveRestore()
    Write "Basic Save/Restore debug complete",!
    
    Do ..DebugMementoIntegrity()  
    Write "Memento Integrity debug complete",!
    
    Do ..DebugAuditTrail()
    Write "Audit Trail debug complete",!
    
    Write "All debug info saved to ^ClineDebug",!
    Quit $$$OK
}

}
