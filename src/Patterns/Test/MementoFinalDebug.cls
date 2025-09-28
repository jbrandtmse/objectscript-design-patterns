/// Debug test for remaining Memento test failures
Class Patterns.Test.MementoFinalDebug Extends %RegisteredObject
{

/// Debug checkpoint limits issue
ClassMethod DebugCheckpointLimits() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting DebugCheckpointLimits; "
    
    Try {
        Set tCaretaker = ##class(Patterns.Examples.PatientRecordCaretaker).%New("DEBUGLIMITS")
        Set tCaretaker.MaxVersions = 3
        Set ^ClineDebug = ^ClineDebug_"MaxVersions set to 3; "
        
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("DEBUGLIMITS")
        
        // Create 5 versions
        For i=1:1:5 {
            Set tOriginator.Diagnosis = "Version "_i
            Set tMemento = tOriginator.CreateMemento("Save "_i)
            If $IsObject(tMemento) {
                Do tCaretaker.AddVersion(tMemento)
                Set ^ClineDebug = ^ClineDebug_"Added version "_i_", VersionHistory.Count()="_tCaretaker.VersionHistory.Count()_"; "
            }
        }
        
        Set ^ClineDebug = ^ClineDebug_"Final VersionHistory.Count()="_tCaretaker.VersionHistory.Count()_"; "
        Set ^ClineDebug = ^ClineDebug_"CurrentVersion="_tCaretaker.CurrentVersion_"; "
        
        // Check what's in the history
        For j=1:1:tCaretaker.VersionHistory.Count() {
            Set tMem = tCaretaker.VersionHistory.GetAt(j)
            If $IsObject(tMem) {
                Set ^ClineDebug = ^ClineDebug_"Position "_j_": Version="_tMem.Version_"; "
            }
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit $$$OK
}

/// Debug memento integrity issue
ClassMethod DebugIntegrity() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting DebugIntegrity; "
    
    Try {
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("DEBUGINTEG")
        Set tOriginator.PatientName = "Integrity Test"
        Set tOriginator.Diagnosis = "Test diagnosis"
        
        Set tMemento = tOriginator.CreateMemento("Integrity test")
        Set ^ClineDebug = ^ClineDebug_"Memento created: "_$IsObject(tMemento)_"; "
        
        If $IsObject(tMemento) {
            // Check initial hash
            Set ^ClineDebug = ^ClineDebug_"DataHash property exists: "_($PROPERTY(tMemento,"DataHash")'="")_"; "
            Set ^ClineDebug = ^ClineDebug_"PatientData property exists: "_($PROPERTY(tMemento,"PatientData")'="")_"; "
            
            // Try VerifyIntegrity
            Set tIntegrity = tMemento.VerifyIntegrity()
            Set ^ClineDebug = ^ClineDebug_"VerifyIntegrity result: "_tIntegrity_"; "
            
            // Try GetPatientData
            Set tData = tMemento.GetPatientData()
            Set ^ClineDebug = ^ClineDebug_"GetPatientData returned: "_(tData'="")_"; "
            
            // Check if the hash calculation works
            Set tTestHash1 = tMemento.CalculateHash("test")
            Set tTestHash2 = tMemento.CalculateHash("test")
            Set ^ClineDebug = ^ClineDebug_"Hash consistency check: "_(tTestHash1=tTestHash2)_"; "
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit $$$OK
}

/// Debug regulatory snapshot issue
ClassMethod DebugRegulatory() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting DebugRegulatory; "
    
    Try {
        Set tCaretaker = ##class(Patterns.Examples.PatientRecordCaretaker).%New("DEBUGREG")
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("DEBUGREG")
        Set tOriginator.PatientName = "Regulatory Patient"
        
        // Create regular version
        Set tMemento1 = tOriginator.CreateMemento("Regular save")
        Set ^ClineDebug = ^ClineDebug_"Regular memento created: "_$IsObject(tMemento1)_"; "
        Do tCaretaker.AddVersion(tMemento1)
        
        // Create regulatory snapshot
        Set tMemento2 = tOriginator.CreateMemento("Regulatory requirement")
        Set ^ClineDebug = ^ClineDebug_"Regulatory memento created: "_$IsObject(tMemento2)_"; "
        Set ^ClineDebug = ^ClineDebug_"IsRegulatorySnapshot before: "_tMemento2.IsRegulatorySnapshot_"; "
        
        Set tSC = tCaretaker.CreateRegulatorySnapshot(tMemento2, "HIPAA Audit")
        Set ^ClineDebug = ^ClineDebug_"CreateRegulatorySnapshot status: "_$$$ISOK(tSC)_"; "
        Set ^ClineDebug = ^ClineDebug_"IsRegulatorySnapshot after: "_tMemento2.IsRegulatorySnapshot_"; "
        
        // Check if it's in the history
        Set tLastMemento = tCaretaker.VersionHistory.GetAt(tCaretaker.VersionHistory.Count())
        If $IsObject(tLastMemento) {
            Set ^ClineDebug = ^ClineDebug_"Last memento in history IsRegulatorySnapshot: "_tLastMemento.IsRegulatorySnapshot_"; "
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit $$$OK
}

/// Run all debug tests
ClassMethod RunAllDebug() As %Status
{
    Write "Running Memento Final Debug Tests...",!
    
    Write !,"1. Testing Checkpoint Limits...",!
    Do ..DebugCheckpointLimits()
    Write "Debug output: ",^ClineDebug,!!
    
    Write "2. Testing Memento Integrity...",!
    Do ..DebugIntegrity()
    Write "Debug output: ",^ClineDebug,!!
    
    Write "3. Testing Regulatory Snapshots...",!
    Do ..DebugRegulatory()
    Write "Debug output: ",^ClineDebug,!!
    
    Quit $$$OK
}

}
