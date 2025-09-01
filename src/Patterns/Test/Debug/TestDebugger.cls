Class Patterns.Test.Debug.TestDebugger
{

/// Debug method to test BasicTest instantiation
ClassMethod DebugBasicTest() As %Status
{
    Set tSC = $$$OK
    
    // Clear debug global
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "Starting BasicTest debug; "
        
        // Try to create an instance of BasicTest
        Set test = ##class(Patterns.Test.Example.BasicTest).%New()
        
        If $ISOBJECT(test) {
            Set ^ClineDebug = ^ClineDebug _ "BasicTest instance created successfully; "
            
            // Try to run a simple test method
            Set ^ClineDebug = ^ClineDebug _ "Calling TestSimpleAssertion; "
            Do test.TestSimpleAssertion()
            Set ^ClineDebug = ^ClineDebug _ "TestSimpleAssertion completed; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Failed to create BasicTest instance; "
        }
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "Error: " _ ex.DisplayString() _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Debug TestCase instantiation directly
ClassMethod DebugTestCase() As %Status
{
    Set tSC = $$$OK
    
    // Clear debug global
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "Starting TestCase debug; "
        
        // Try to create an instance of TestCase
        Set ^ClineDebug = ^ClineDebug _ "Creating TestCase with empty initvalue; "
        Set test = ##class(Patterns.Test.TestCase).%New("")
        
        If $ISOBJECT(test) {
            Set ^ClineDebug = ^ClineDebug _ "TestCase instance created successfully; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Failed to create TestCase instance; "
        }
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "Error: " _ ex.DisplayString() _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
