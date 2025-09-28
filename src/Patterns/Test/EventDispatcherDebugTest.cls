/// Debug test for EventDispatcher
Class Patterns.Test.EventDispatcherDebugTest Extends %RegisteredObject
{

/// Test AddFilter method existence
ClassMethod TestAddFilter() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "Testing EventDispatcher AddFilter method...", !
        
        // Create dispatcher
        Set dispatcher = ##class(Patterns.GoF.Behavioral.EventDispatcher).%New()
        Write "Dispatcher created: ", $ISOBJECT(dispatcher), !
        
        // Test if AddFilter exists by trying to call it
        Set filter = {"minPriority": 75}
        Write "Filter created: ", $ISOBJECT(filter), !
        
        // Try direct method call
        Write "Attempting to call AddFilter...", !
        Set tSC = dispatcher.AddFilter("TEST_FILTER", filter)
        Write "AddFilter result: ", $SYSTEM.Status.GetErrorText(tSC), !
        
        // Test PassesFilter
        Set event = ##class(Patterns.GoF.Behavioral.Event).%New()
        Set event.Priority = 80
        Write "Testing PassesFilter with priority 80...", !
        Set passes = dispatcher.PassesFilter(event, "TEST_FILTER")
        Write "Event passes filter: ", passes, !
        
    } Catch ex {
        Write "ERROR: ", ex.DisplayString(), !
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Run the debug test
ClassMethod Run() As %Status
{
    Do ..TestAddFilter()
    Quit $$$OK
}

}
