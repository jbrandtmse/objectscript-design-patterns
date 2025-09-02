/// Simple test to verify process-private global behavior with object references
Class Patterns.Test.Debug.SimpleGlobalTest Extends %RegisteredObject
{

/// Test if process-private globals can store object references
ClassMethod TestProcessPrivateGlobal() As %Status
{
    Set ^ClineDebug = ""
    
    // Create a simple object
    Set ^ClineDebug = ^ClineDebug _ "Creating object; "
    Set obj1 = ##class(%ArrayOfDataTypes).%New()
    Do obj1.SetAt("TestValue", "TestKey")
    
    // Store in process-private global
    Set ^ClineDebug = ^ClineDebug _ "Storing in PPG; "
    Set ^||TestObject = obj1
    
    // Retrieve from process-private global
    Set ^ClineDebug = ^ClineDebug _ "Retrieving from PPG; "
    Set obj2 = ^||TestObject
    
    // Check if it's valid
    If $ISOBJECT(obj2) {
        Set ^ClineDebug = ^ClineDebug _ "Retrieved object is valid; "
        
        // Check if we can access data
        Set value = obj2.GetAt("TestKey")
        Set ^ClineDebug = ^ClineDebug _ "Retrieved value: "_value_"; "
        
        // Check object equality
        If obj1 = obj2 {
            Set ^ClineDebug = ^ClineDebug _ "Objects are equal; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Objects are NOT equal; "
        }
    } Else {
        Set ^ClineDebug = ^ClineDebug _ "Retrieved object is NOT valid; "
    }
    
    // Clean up
    Kill ^||TestObject
    
    Quit $$$OK
}

}
