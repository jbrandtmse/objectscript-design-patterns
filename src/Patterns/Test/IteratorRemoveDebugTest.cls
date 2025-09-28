/// Debug test for Iterator Remove operation
Class Patterns.Test.IteratorRemoveDebugTest Extends %RegisteredObject
{

/// Test remove operation with detailed debugging
ClassMethod TestRemove() As %String
{
    Set ^ClineDebug = ""
    Set result = ""
    
    Try {
        // Create list with 5 elements
        Set tList = ##class(%ListOfDataTypes).%New()
        For i=1:1:5 {
            Do tList.Insert("Item" _ i)
        }
        Set ^ClineDebug = ^ClineDebug _ "Initial count: " _ tList.Count() _ "; "
        
        // Create iterator
        Set tIterator = ##class(Patterns.GoF.Behavioral.ListIterator).%New(tList)
        
        // Move to second element
        Set tItem1 = tIterator.Next()
        Set ^ClineDebug = ^ClineDebug _ "First item: " _ tItem1 _ "; "
        
        Set tItem2 = tIterator.Next()
        Set ^ClineDebug = ^ClineDebug _ "Second item: " _ tItem2 _ "; "
        
        // Remove current element (should remove Item2)
        Set tSC = tIterator.Remove()
        
        If $$$ISOK(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Remove succeeded; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Remove failed: " _ $System.Status.GetErrorText(tSC) _ "; "
        }
        
        // Check count after removal
        Set newCount = tList.Count()
        Set ^ClineDebug = ^ClineDebug _ "Count after removal: " _ newCount _ "; "
        
        // Check what's left in the list
        For i=1:1:tList.Count() {
            Set ^ClineDebug = ^ClineDebug _ "Item " _ i _ ": " _ tList.GetAt(i) _ "; "
        }
        
        // Final result
        If newCount = 4 {
            Set result = "SUCCESS: List has 4 elements after removal"
        } Else {
            Set result = "FAILURE: List has " _ newCount _ " elements, expected 4"
        }
        
    } Catch ex {
        Set result = "EXCEPTION: " _ ex.DisplayString()
        Set ^ClineDebug = ^ClineDebug _ "Exception: " _ ex.DisplayString() _ "; "
    }
    
    Quit result
}

}
