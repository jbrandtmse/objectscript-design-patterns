/// Detailed debug test for Memento issues
Class Patterns.Test.MementoDebugDetailed Extends %RegisteredObject
{

ClassMethod RunDebug() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "Starting debug; "
        
        // Test PatientRecordMemento directly first
        Set ^ClineDebug = ^ClineDebug _ "Test direct memento creation; "
        Set tTestMem = ##class(Patterns.Examples.PatientRecordMemento).%New("Test State", {})
        If $IsObject(tTestMem) {
            Set ^ClineDebug = ^ClineDebug _ "Direct creation OK; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Direct creation FAILED; "
        }
        
        // Test factory method
        Set ^ClineDebug = ^ClineDebug _ "Test factory method; "
        Set tFactoryMem = ##class(Patterns.Examples.PatientRecordMemento).CreateWithMetadata("State", {}, "CheckpointName", {})
        If $IsObject(tFactoryMem) {
            Set ^ClineDebug = ^ClineDebug _ "Factory OK; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Factory FAILED; "
        }
        
        // Now test through originator
        Set ^ClineDebug = ^ClineDebug _ "Test via originator; "
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("TEST001")
        If $IsObject(tOriginator) {
            Set ^ClineDebug = ^ClineDebug _ "Originator OK; "
            
            Set tOriginator.PatientName = "Test"
            Set tOriginator.Diagnosis = "Test"
            
            // Debug the CreateMemento call
            Set ^ClineDebug = ^ClineDebug _ "Call CreateMemento; "
            
            // Get the state strings first
            Set tState = tOriginator.GetStateString()
            Set ^ClineDebug = ^ClineDebug _ "State='" _ tState _ "'; "
            
            Set tStateData = tOriginator.GetStateData()
            Set ^ClineDebug = ^ClineDebug _ "StateData=" _ $Select($IsObject(tStateData):"object", 1:"not-object") _ "; "
            
            // Now call CreateMemento
            Set tMemento = tOriginator.CreateMemento("Debug")
            If $IsObject(tMemento) {
                Set ^ClineDebug = ^ClineDebug _ "Memento created OK; "
            } Else {
                Set ^ClineDebug = ^ClineDebug _ "Memento creation FAILED; "
            }
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "EXCEPTION: " _ ex.DisplayString() _ "; "
    }
    
    Set ^ClineDebug = ^ClineDebug _ "END"
    
    Quit tSC
}

}
