/// Debug test for regulatory snapshot functionality
Class Patterns.Test.RegulatorySnapshotDebugTest Extends %RegisteredObject
{

/// Debug the regulatory snapshot issue
ClassMethod DebugRegulatorySnapshot() As %Status
{
    Set tSC = $$$OK
    
    Write !, "=== Regulatory Snapshot Debug Test ==="
    
    // Create caretaker and originator
    Set tCaretaker = ##class(Patterns.Examples.PatientRecordCaretaker).%New("DEBUG001")
    Write !, "Caretaker created: ", $IsObject(tCaretaker)
    
    Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("DEBUG001")
    Write !, "Originator created: ", $IsObject(tOriginator)
    
    Set tOriginator.PatientName = "Debug Patient"
    Set tOriginator.Diagnosis = "Initial diagnosis"
    
    // Create regular version first
    Write !, !,"Creating regular memento..."
    Set tMemento1 = tOriginator.CreateMemento("Regular save")
    Write !, "Memento1 created: ", $IsObject(tMemento1)
    Write !, "Memento1 type: ", tMemento1.%ClassName(1)
    Write !, "Memento1 IsRegulatorySnapshot (before add): ", tMemento1.IsRegulatorySnapshot
    
    Do tCaretaker.AddVersion(tMemento1)
    Write !, "Memento1 added to caretaker"
    Write !, "Current version: ", tCaretaker.CurrentVersion
    
    // Create regulatory snapshot
    Write !, !, "Creating regulatory memento..."
    Set tOriginator.Diagnosis = "Regulatory diagnosis"
    Set tMemento2 = tOriginator.CreateMemento("Regulatory requirement")
    Write !, "Memento2 created: ", $IsObject(tMemento2)
    Write !, "Memento2 type: ", tMemento2.%ClassName(1)
    
    // Mark as regulatory
    Write !, "Marking as regulatory..."
    Set tSC = tMemento2.MarkAsRegulatorySnapshot()
    Write !, "MarkAsRegulatorySnapshot status: ", $System.Status.GetErrorText(tSC)
    Write !, "Memento2 IsRegulatorySnapshot (after mark): ", tMemento2.IsRegulatorySnapshot
    
    // Add to caretaker
    Do tCaretaker.AddVersion(tMemento2)
    Write !, "Memento2 added to caretaker"
    Write !, "Current version: ", tCaretaker.CurrentVersion
    Write !, "VersionHistory count: ", tCaretaker.VersionHistory.Count()
    
    // Verify the memento was marked as regulatory
    Write !, !, "Verifying memento2 regulatory status..."
    Write !, "Memento2 IsRegulatorySnapshot (after add): ", tMemento2.IsRegulatorySnapshot
    
    // Get last memento from history
    Write !, !, "Retrieving last memento from history..."
    Set tLastMemento = tCaretaker.VersionHistory.GetAt(tCaretaker.VersionHistory.Count())
    Write !, "Last memento retrieved: ", $IsObject(tLastMemento)
    
    If $IsObject(tLastMemento) {
        Write !, "Last memento type: ", tLastMemento.%ClassName(1)
        Write !, "Last memento %IsA check: ", tLastMemento.%IsA("Patterns.Examples.PatientRecordMemento")
        
        // Direct property access
        Write !, "Last memento IsRegulatorySnapshot: ", tLastMemento.IsRegulatorySnapshot
        
        // Check if it's the same object
        Write !, "Is same object as memento2: ", (tLastMemento = tMemento2)
        
        // Check version
        Write !, "Last memento version: ", tLastMemento.Version
        Write !, "Memento2 version: ", tMemento2.Version
    }
    
    // Check regulatory versions tracking
    Write !, !, "Checking RegulatoryVersions tracking..."
    Set tVersion = ""
    For {
        Set tVersion = $Order(tCaretaker.RegulatoryVersions(tVersion))
        Quit:tVersion=""
        Write !, "Regulatory version tracked: ", tVersion
    }
    
    Write !, !, "=== End Debug Test ==="
    
    Quit tSC
}

/// Run the debug test
ClassMethod Run()
{
    Do ..DebugRegulatorySnapshot()
}

}
