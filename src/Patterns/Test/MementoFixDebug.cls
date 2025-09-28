/// Debug class to fix failing Memento tests
Class Patterns.Test.MementoFixDebug Extends %RegisteredObject
{

/// Debug TestAuditTrail issue
ClassMethod DebugAuditTrail() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ^ClineDebug_"=== TestAuditTrail Debug ===; "
    
    Try {
        // Create caretaker
        Set tCaretaker = ##class(Patterns.Examples.PatientRecordCaretaker).%New("TEST009")
        Set ^ClineDebug = ^ClineDebug_"Caretaker created: "_$IsObject(tCaretaker)_"; "
        
        // Create originator
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("TEST009")
        Set ^ClineDebug = ^ClineDebug_"Originator created: "_$IsObject(tOriginator)_"; "
        
        // Create memento
        Set tMemento = tOriginator.CreateMemento("Audit test")
        Set ^ClineDebug = ^ClineDebug_"Memento created: "_$IsObject(tMemento)_"; "
        
        // Add version
        Do tCaretaker.AddVersion(tMemento)
        Set ^ClineDebug = ^ClineDebug_"Version added; "
        
        // Get audit trail
        Set tSC = tCaretaker.GetAuditTrail(.tTrail)
        Set ^ClineDebug = ^ClineDebug_"GetAuditTrail status: "_$System.Status.GetErrorText(tSC)_"; "
        Set ^ClineDebug = ^ClineDebug_"Trail object: "_$IsObject(tTrail)_"; "
        
        If $IsObject(tTrail) {
            Set ^ClineDebug = ^ClineDebug_"Trail size: "_tTrail.%Size()_"; "
            Set iter = tTrail.%GetIterator()
            While iter.%GetNext(.key, .value) {
                Set ^ClineDebug = ^ClineDebug_"Entry["_key_"]: "_value_"; "
            }
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Debug TestBasicSaveRestore issue
ClassMethod DebugBasicRestore() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ^ClineDebug_"=== TestBasicSaveRestore Debug ===; "
    
    Try {
        // Create originator with initial state
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("TEST001")
        Set ^ClineDebug = ^ClineDebug_"Originator created; "
        
        Set tOriginator.PatientName = "John Doe"
        Set tOriginator.Diagnosis = "Initial diagnosis"
        Set tOriginator.TreatmentPlan = "Initial treatment"
        Set ^ClineDebug = ^ClineDebug_"Initial state set; "
        
        // Save state to memento
        Set tMemento1 = tOriginator.CreateMemento("Initial save")
        Set ^ClineDebug = ^ClineDebug_"Memento created: "_$IsObject(tMemento1)_"; "
        
        // Get state data before change
        If $IsObject(tMemento1) {
            Set tState = tMemento1.GetState()
            Set ^ClineDebug = ^ClineDebug_"Memento state length: "_$Length(tState)_"; "
            
            Set tData = tMemento1.GetPatientData()
            If $IsObject(tData) {
                Set ^ClineDebug = ^ClineDebug_"Saved diagnosis: "_tData.%Get("Diagnosis","")_"; "
            }
        }
        
        // Modify originator state
        Set tOriginator.Diagnosis = "Updated diagnosis"
        Do tOriginator.AddMedication("Aspirin", "testuser")
        Set ^ClineDebug = ^ClineDebug_"State modified; "
        
        // Check modified state
        Set ^ClineDebug = ^ClineDebug_"Modified diagnosis: "_tOriginator.Diagnosis_"; "
        Set ^ClineDebug = ^ClineDebug_"Medications count: "_tOriginator.Medications.Count()_"; "
        
        // Restore from memento
        Set tSC = tOriginator.RestoreFromMemento(tMemento1)
        Set ^ClineDebug = ^ClineDebug_"Restore status: "_$System.Status.GetErrorText(tSC)_"; "
        
        // Check restored state
        Set ^ClineDebug = ^ClineDebug_"Restored diagnosis: "_tOriginator.Diagnosis_"; "
        Set ^ClineDebug = ^ClineDebug_"Restored medications count: "_tOriginator.Medications.Count()_"; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Debug TestCheckpointLimits issue
ClassMethod DebugCheckpointLimits() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ^ClineDebug_"=== TestCheckpointLimits Debug ===; "
    
    Try {
        Set tCaretaker = ##class(Patterns.Examples.PatientRecordCaretaker).%New("TEST004")
        Set ^ClineDebug = ^ClineDebug_"Caretaker created; "
        
        Set tCaretaker.MaxVersions = 3
        Set ^ClineDebug = ^ClineDebug_"MaxVersions set to 3; "
        
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("TEST004")
        
        // Create more versions than limit
        For i=1:1:5 {
            Set tOriginator.Diagnosis = "Version "_i
            Set tMemento = tOriginator.CreateMemento("Save "_i)
            If $IsObject(tMemento) {
                Do tCaretaker.AddVersion(tMemento)
                Set ^ClineDebug = ^ClineDebug_"Added version "_i_"; "
            }
        }
        
        Set ^ClineDebug = ^ClineDebug_"VersionHistory count: "_tCaretaker.VersionHistory.Count()_"; "
        Set ^ClineDebug = ^ClineDebug_"CurrentVersion: "_tCaretaker.CurrentVersion_"; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Run all debug tests
ClassMethod RunDebug() As %Status
{
    Set ^ClineDebug = ""
    
    Do ..DebugAuditTrail()
    Do ..DebugBasicRestore()
    Do ..DebugCheckpointLimits()
    
    Write !,"Debug output in ^ClineDebug"
    Quit $$$OK
}

}
