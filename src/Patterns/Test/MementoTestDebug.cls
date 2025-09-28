/// Debug test for Memento issues
Class Patterns.Test.MementoTestDebug Extends %RegisteredObject
{

ClassMethod RunDebug() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "Creating PatientRecordOriginator; "
        
        // Test basic originator creation
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("DEBUG001")
        If '$IsObject(tOriginator) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Originator not created; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Originator created OK; "
        
        // Set some data
        Set tOriginator.PatientName = "Test Patient"
        Set tOriginator.Diagnosis = "Test Diagnosis"
        Set ^ClineDebug = ^ClineDebug _ "Data set; "
        
        // Try to create memento
        Set ^ClineDebug = ^ClineDebug _ "Creating memento; "
        Set tMemento = tOriginator.CreateMemento("Debug Test")
        If '$IsObject(tMemento) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Memento not created; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Memento created; "
        Set ^ClineDebug = ^ClineDebug _ "Memento class: " _ tMemento.%ClassName(1) _ "; "
        
        // Test memento methods
        If tMemento.%IsA("Patterns.Examples.PatientRecordMemento") {
            Set ^ClineDebug = ^ClineDebug _ "Is PatientRecordMemento; "
            
            // Test methods that might cause INVALID OREF
            Try {
                Set tIntegrity = tMemento.VerifyIntegrity()
                Set ^ClineDebug = ^ClineDebug _ "VerifyIntegrity=" _ tIntegrity _ "; "
            } Catch ex {
                Set ^ClineDebug = ^ClineDebug _ "VerifyIntegrity ERROR: " _ ex.DisplayString() _ "; "
            }
            
            Try {
                Set tSize = tMemento.GetSizeInBytes()
                Set ^ClineDebug = ^ClineDebug _ "Size=" _ tSize _ "; "
            } Catch ex {
                Set ^ClineDebug = ^ClineDebug _ "GetSizeInBytes ERROR: " _ ex.DisplayString() _ "; "
            }
            
            Try {
                // Test CreateDelta - this needs another memento
                Set tMemento2 = tOriginator.CreateMemento("Second")
                If $IsObject(tMemento2) {
                    Set tDelta = tMemento2.CreateDelta(tMemento)
                    Set ^ClineDebug = ^ClineDebug _ "CreateDelta result: " _ $Select($IsObject(tDelta):"object", 1:"not object") _ "; "
                }
            } Catch ex {
                Set ^ClineDebug = ^ClineDebug _ "CreateDelta ERROR: " _ ex.DisplayString() _ "; "
            }
            
            Try {
                // Test CompareWith
                Set tComp = tMemento.CompareWith(tMemento)  
                Set ^ClineDebug = ^ClineDebug _ "CompareWith result: " _ $Select($IsObject(tComp):"object", 1:"not object") _ "; "
            } Catch ex {
                Set ^ClineDebug = ^ClineDebug _ "CompareWith ERROR: " _ ex.DisplayString() _ "; "
            }
        }
        
        // Test base Memento class
        Set ^ClineDebug = ^ClineDebug _ "Testing base Memento; "
        Set tBaseMem = ##class(Patterns.GoF.Behavioral.Memento).%New("test", {})
        If '$IsObject(tBaseMem) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Base memento not created; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Base memento created; "
            Set tState = tBaseMem.GetState()
            Set ^ClineDebug = ^ClineDebug _ "GetState=" _ tState _ "; "
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "EXCEPTION: " _ ex.DisplayString() _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Set ^ClineDebug = ^ClineDebug _ "DONE"
    
    Write "Debug info saved to ^ClineDebug",!
    Write "Use get_global tool to retrieve",!
    
    Quit tSC
}

}
