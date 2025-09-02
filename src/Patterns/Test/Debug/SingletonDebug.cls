/// Debug class to test Singleton implementation
Class Patterns.Test.Debug.SingletonDebug Extends %RegisteredObject
{

/// Test the basic Singleton functionality
ClassMethod TestSingleton() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ""
    
    Try {
        // Clear any existing instances
        Set ^ClineDebug = ^ClineDebug _ "Resetting Singleton; "
        Do ##class(Patterns.GoF.Creational.Singleton).Reset()
        
        // Test 1: Get first instance
        Set ^ClineDebug = ^ClineDebug _ "Getting first instance; "
        Set instance1 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
        If '$ISOBJECT(instance1) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: First instance is not an object; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "First instance OK; "
        
        // Test 2: Get second instance - should be same
        Set ^ClineDebug = ^ClineDebug _ "Getting second instance; "
        Set instance2 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
        If '$ISOBJECT(instance2) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Second instance is not an object; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Second instance OK; "
        
        // Test 3: Check they are the same instance (using IsSameInstance method)
        Set ^ClineDebug = ^ClineDebug _ "Checking equality; "
        If 'instance1.IsSameInstance(instance2) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Instances are not the same (different IDs); "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Instances are the same (same ID); "
        
        // Test 4: Test ConfigurationManager
        Set ^ClineDebug = ^ClineDebug _ "Testing ConfigurationManager; "
        Set config1 = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
        If '$ISOBJECT(config1) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Config instance is not an object; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Config instance OK; "
        
        // Test 5: Set and get a setting
        Set ^ClineDebug = ^ClineDebug _ "Testing settings; "
        Do config1.SetSetting("TestKey", "TestValue")
        Set value = config1.GetSetting("TestKey")
        If value '= "TestValue" {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Setting not preserved, got: "_value_"; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Settings OK; "
        
        // Test 6: Get second config instance - should have same settings
        Set ^ClineDebug = ^ClineDebug _ "Testing config persistence; "
        Set config2 = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
        Set value2 = config2.GetSetting("TestKey")
        If value2 '= "TestValue" {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Setting not preserved in second instance, got: "_value2_"; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Config persistence OK; "
        
        // Test 7: Verify same instance (using IsSameInstance method)
        If 'config1.IsSameInstance(config2) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Config instances are not the same (different IDs); "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "Config instances are the same (same ID); "
        
        Set ^ClineDebug = ^ClineDebug _ "ALL TESTS PASSED!"
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "EXCEPTION: "_ex.DisplayString()_"; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Run the test and display results
ClassMethod RunTest() As %Status
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Run the test
    Set tSC = ..TestSingleton()
    
    // Display results
    Write "Test Status: "_$SELECT($$$ISOK(tSC):"OK", 1:"ERROR"),!
    Write "Debug Log:",!
    Write ^ClineDebug,!
    
    Quit tSC
}

}
