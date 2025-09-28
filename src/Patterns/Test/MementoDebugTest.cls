/// Debug test for Memento pattern issues
Class Patterns.Test.MementoDebugTest Extends %RegisteredObject
{

/// Debug test to isolate issues
ClassMethod RunDebugTest() As %Status
{
    Set tSC = $$$OK
    
    Write !, "=== Memento Pattern Debug Test ==="
    
    Try {
        // Test 1: Basic Memento creation
        Write !, "Test 1: Basic Memento creation"
        Set tMemento = ##class(Patterns.GoF.Behavioral.Memento).%New("test state", {})
        If $IsObject(tMemento) {
            Write !, "  ✓ Basic Memento created"
        } Else {
            Write !, "  ✗ Failed to create basic Memento"
        }
        
        // Test 2: PatientRecordOriginator creation
        Write !, "Test 2: PatientRecordOriginator creation"
        Set tOriginator = ##class(Patterns.Examples.PatientRecordOriginator).%New("TEST001")
        If $IsObject(tOriginator) {
            Write !, "  ✓ PatientRecordOriginator created"
            Set tOriginator.PatientName = "Test Patient"
            Set tOriginator.Diagnosis = "Test Diagnosis"
            
            // Test 3: CreateMemento method
            Write !, "Test 3: CreateMemento method"
            Set tMemento2 = tOriginator.CreateMemento("Debug checkpoint")
            If $IsObject(tMemento2) {
                Write !, "  ✓ CreateMemento returned object"
                Write !, "  Class: ", tMemento2.%ClassName(1)
            } Else {
                Write !, "  ✗ CreateMemento returned null"
            }
        } Else {
            Write !, "  ✗ Failed to create PatientRecordOriginator"
        }
        
        // Test 4: PatientRecordMemento factory method
        Write !, "Test 4: PatientRecordMemento factory method"
        Set tState = "{""patient"":""test""}"
        Set tStateData = {}
        Set tCheckpoint = "test"
        Set tMeta = {}
        Set tMeta.user = "testuser"
        Set tMemento3 = ##class(Patterns.Examples.PatientRecordMemento).CreateWithMetadata(
            tState, tStateData, tCheckpoint, tMeta)
        If $IsObject(tMemento3) {
            Write !, "  ✓ CreateWithMetadata returned object"
        } Else {
            Write !, "  ✗ CreateWithMetadata returned null"
        }
        
        // Test 5: MementoHistory CheckpointOrder access
        Write !, "Test 5: MementoHistory CheckpointOrder access"
        Set tHistory = ##class(Patterns.GoF.Behavioral.MementoHistory).%New()
        // Try to access CheckpointOrder property
        Set tOrder = tHistory.CheckpointOrder
        If $IsObject(tOrder) {
            Write !, "  ✓ CheckpointOrder is accessible: ", tOrder.Count()
        } Else {
            Write !, "  ✗ CheckpointOrder is not accessible"
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "ERROR: ", ex.DisplayString()
    }
    
    Write !, "=== Debug Test Complete ==="
    
    Quit tSC
}

/// Test simple unit test method
ClassMethod TestSimpleMethod() As %Boolean
{
    // This simulates a unit test method
    Set tResult = 1
    
    // Test basic assertion
    If 1 = 1 {
        Set tResult = 1
    } Else {
        Set tResult = 0
    }
    
    Quit tResult
}

}
