/// Debug test for SingletonStorage
Class Patterns.Test.Debug.SingletonStorageDebug Extends %RegisteredObject
{

/// Test the SingletonStorage implementation
ClassMethod TestStorage() As %Boolean
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting SingletonStorage test; "
    
    // Get first storage instance
    Set storage1 = ##class(Patterns.GoF.Creational.SingletonStorage).GetStorage()
    Set ^ClineDebug = ^ClineDebug _ "Got storage1: " _ $ISOBJECT(storage1) _ "; "
    
    // Get second storage instance
    Set storage2 = ##class(Patterns.GoF.Creational.SingletonStorage).GetStorage()
    Set ^ClineDebug = ^ClineDebug _ "Got storage2: " _ $ISOBJECT(storage2) _ "; "
    
    // Check if they're the same instance using IsSameStorage method
    Set areSame = storage1.IsSameStorage(storage2)
    Set ^ClineDebug = ^ClineDebug _ "Storage instances same (by ID): " _ areSame _ "; "
    
    // Store a test value in storage1 - use SingletonStorage itself as test object
    Set testObj = ##class(Patterns.GoF.Creational.SingletonStorage).%New()
    Do storage1.SetInstance("TestClass", testObj)
    Set ^ClineDebug = ^ClineDebug _ "Stored test object in storage1; "
    
    // Try to retrieve from storage2
    Set hasIt = storage2.HasInstance("TestClass")
    Set ^ClineDebug = ^ClineDebug _ "Storage2 has TestClass: " _ hasIt _ "; "
    
    // Get third storage instance to test persistence
    Set storage3 = ##class(Patterns.GoF.Creational.SingletonStorage).GetStorage()
    Set hasIt3 = storage3.HasInstance("TestClass")
    Set ^ClineDebug = ^ClineDebug _ "Storage3 has TestClass: " _ hasIt3 _ "; "
    
    Return areSame && hasIt && hasIt3
}

/// Run the test
ClassMethod RunTest() As %Boolean
{
    Write "Testing SingletonStorage implementation...", !
    Set result = ..TestStorage()
    Write "Test ", $SELECT(result:"PASSED",1:"FAILED"), !
    Write "Debug output: ", ^ClineDebug, !
    Return result
}

}
