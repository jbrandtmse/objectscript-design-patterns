/// Debug test for ColleagueRegistry
Class Patterns.Test.ColleagueRegistryDebugTest Extends %RegisteredObject
{

/// Test direct colleague registration
ClassMethod TestDirectRegistration() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "=== Direct Registration Test ===; "
    
    // Create registry
    Set registry = ##class(Patterns.GoF.Behavioral.ColleagueRegistry).%New()
    Set ^ClineDebug = ^ClineDebug _ "Registry created: " _ $ISOBJECT(registry) _ "; "
    
    // Create test colleague
    Set colleague1 = ##class(Patterns.Examples.EmergencyDepartment).%New()
    Set ^ClineDebug = ^ClineDebug _ "Colleague created: " _ $ISOBJECT(colleague1) _ "; "
    
    // Test direct storage without metadata
    Do registry.Colleagues.SetAt(colleague1, "TEST001")
    Set ^ClineDebug = ^ClineDebug _ "Direct SetAt done; "
    
    // Check if it was stored
    Set retrieved = registry.Colleagues.GetAt("TEST001")
    Set ^ClineDebug = ^ClineDebug _ "Direct retrieval: " _ $ISOBJECT(retrieved) _ "; "
    
    // Test ActiveStatus array
    Do registry.ActiveStatus.SetAt(1, "TEST001")
    Set ^ClineDebug = ^ClineDebug _ "ActiveStatus SetAt done; "
    
    Set isActive = registry.ActiveStatus.GetAt("TEST001")
    Set ^ClineDebug = ^ClineDebug _ "Active status: " _ isActive _ "; "
    
    // Test with metadata
    Set metadata1 = {"department": "Emergency", "priority": "high"}
    Set ^ClineDebug = ^ClineDebug _ "Metadata created: " _ $ISOBJECT(metadata1) _ "; "
    
    Try {
        Set jsonStr = metadata1.%ToJSON()
        Set ^ClineDebug = ^ClineDebug _ "JSON conversion OK; "
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "JSON ERROR: " _ ex.DisplayString() _ "; "
    }
    
    Quit $$$OK
}

/// Run the test
ClassMethod Run() As %Status
{
    Do ..TestDirectRegistration()
    Write !, "Debug output in ^ClineDebug", !
    Quit $$$OK
}

}
