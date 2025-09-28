/// Simple fixes for remaining Memento test failures
Class Patterns.Test.MementoSimpleFix Extends %RegisteredObject
{

/// Create test helper to ensure proper memento creation
ClassMethod TestMementoCreation() As %Status
{
    Set tSC = $$$OK
    
    // Test direct creation
    Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("TEST999")
    Set tOriginator.PatientName = "Test Patient"
    Set tOriginator.Diagnosis = "Test Diagnosis"
    
    // Debug the creation process
    Write !,"Testing CreateMemento..."
    Set tMemento = tOriginator.CreateMemento("Debug Test")
    Write !,"Memento created: ", $IsObject(tMemento)
    
    If $IsObject(tMemento) {
        Write !,"Memento class: ", tMemento.%ClassName(1)
        Write !,"Memento state: ", tMemento.GetState()
    }
    
    Quit tSC
}

/// Fix for audit trail issue
ClassMethod FixAuditTrail() As %Status
{
    // The issue is that audit trail entries exist but aren't being retrieved properly
    // Let's check if the global is being populated
    Set tPatientID = "TEST009"
    
    // Check existing audit entries
    Set tCount = 0
    Set tIndex = ""
    For {
        Set tIndex = $Order(^Patterns.PatientAudit(tPatientID, tIndex))
        Quit:tIndex=""
        Set tCount = tCount + 1
        Write !,"Found audit entry: ", tIndex
    }
    Write !,"Total audit entries: ", tCount
    
    Quit $$$OK
}

/// Check version limit enforcement
ClassMethod CheckVersionLimits() As %Status
{
    Set tCaretaker = ##class(Patterns.Examples.PatientRecordCaretaker).%New("LIMITTEST")
    Set tCaretaker.MaxVersions = 3
    Set tCaretaker.AutoArchive = 0  // Disable archiving to test limit
    
    Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("LIMITTEST")
    
    // Add 5 versions
    For i=1:1:5 {
        Set tOriginator.Diagnosis = "Version " _ i
        Set tMemento = tOriginator.CreateMemento("Version " _ i)
        If $IsObject(tMemento) {
            Do tCaretaker.AddVersion(tMemento)
        }
    }
    
    Write !,"Version history count: ", tCaretaker.VersionHistory.Count()
    Write !,"Should be <= MaxVersions (3)"
    
    Quit $$$OK
}

}
