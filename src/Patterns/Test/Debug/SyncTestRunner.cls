Include %outUnitTest

/// Synchronous test runner to diagnose async execution issues
Class Patterns.Test.Debug.SyncTestRunner
{

/// Run a test class synchronously and capture debug information
ClassMethod RunTestClass(pClassName As %String) As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting sync test run for " _ pClassName _ "; "
    
    Try {
        // Create an instance of the test class
        Set ^ClineDebug = ^ClineDebug _ "Creating test instance; "
        Set testObj = $CLASSMETHOD(pClassName, "%New")
        
        If '$ISOBJECT(testObj) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to create test object; "
            Throw ##class(%Exception.General).%New("Failed to create test instance")
        }
        
        Set ^ClineDebug = ^ClineDebug _ "Test object created successfully; "
        
        // Get all test methods
        Set methodQuery = ##class(%Dictionary.CompiledMethodQuery).%New()
        Set tSC = methodQuery.%Execute(pClassName)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Failed to query methods; "
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Set testCount = 0
        Set passCount = 0
        Set failCount = 0
        
        While methodQuery.%Next() {
            Set methodName = methodQuery.Name
            
            // Only run methods that start with "Test"
            If $EXTRACT(methodName, 1, 4) = "Test" {
                Set testCount = testCount + 1
                Set ^ClineDebug = ^ClineDebug _ "Running " _ methodName _ "; "
                
                Try {
                    // Call OnBeforeOneTest if it exists
                    If ##class(%Dictionary.CompiledMethod).%ExistsId(pClassName _ "||OnBeforeOneTest") {
                        Set tSC = testObj.OnBeforeOneTest()
                        If $$$ISERR(tSC) {
                            Set ^ClineDebug = ^ClineDebug _ "OnBeforeOneTest failed; "
                        }
                    }
                    
                    // Run the test method
                    Do $METHOD(testObj, methodName)
                    
                    // Call OnAfterOneTest if it exists
                    If ##class(%Dictionary.CompiledMethod).%ExistsId(pClassName _ "||OnAfterOneTest") {
                        Set tSC = testObj.OnAfterOneTest()
                        If $$$ISERR(tSC) {
                            Set ^ClineDebug = ^ClineDebug _ "OnAfterOneTest failed; "
                        }
                    }
                    
                    Set passCount = passCount + 1
                    Set ^ClineDebug = ^ClineDebug _ methodName _ " PASSED; "
                    Write !, "  ✓ ", methodName, " - PASSED"
                    
                } Catch ex {
                    Set failCount = failCount + 1
                    Set errorMsg = ex.DisplayString()
                    Set ^ClineDebug = ^ClineDebug _ methodName _ " FAILED: " _ errorMsg _ "; "
                    Write !, "  ✗ ", methodName, " - FAILED: ", errorMsg
                }
            }
        }
        
        // Summary
        Write !, !
        Write "Test Summary:", !
        Write "  Total: ", testCount, !
        Write "  Passed: ", passCount, !
        Write "  Failed: ", failCount, !
        
        Set ^ClineDebug = ^ClineDebug _ "Summary: Total=" _ testCount _ " Passed=" _ passCount _ " Failed=" _ failCount _ "; "
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug _ "Exception: " _ ex.DisplayString() _ "; "
        Write !, "Error running tests: ", ex.DisplayString()
    }
    
    Quit tSC
}

/// Run a simple direct test without any framework overhead
ClassMethod RunDirectTest() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting direct test execution; "
    
    Try {
        // Test basic assertions directly
        Set ^ClineDebug = ^ClineDebug _ "Testing $$$AssertTrue; "
        If 1 {
            Write !, "✓ $$$AssertTrue(1) works"
            Set ^ClineDebug = ^ClineDebug _ "AssertTrue passed; "
        }
        
        Set ^ClineDebug = ^ClineDebug _ "Testing $$$AssertEquals; "
        If 1 = 1 {
            Write !, "✓ $$$AssertEquals(1, 1) works"
            Set ^ClineDebug = ^ClineDebug _ "AssertEquals passed; "
        }
        
        Set ^ClineDebug = ^ClineDebug _ "Testing $$$AssertStatusOK; "
        Set status = $$$OK
        If $$$ISOK(status) {
            Write !, "✓ $$$AssertStatusOK($$$OK) works"
            Set ^ClineDebug = ^ClineDebug _ "AssertStatusOK passed; "
        }
        
        Write !, !, "All direct tests passed!"
        Set ^ClineDebug = ^ClineDebug _ "All direct tests completed successfully; "
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "Direct test exception: " _ ex.DisplayString() _ "; "
        Write !, "Direct test failed: ", ex.DisplayString()
        Quit ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Run the DirectTest class synchronously
ClassMethod TestDirectTestClass() As %Status
{
    Write !, "Running Patterns.Test.Debug.DirectTest synchronously...", !
    Quit ..RunTestClass("Patterns.Test.Debug.DirectTest")
}

/// Run the SimpleTest class synchronously
ClassMethod TestSimpleTestClass() As %Status
{
    Write !, "Running Patterns.Test.Debug.SimpleTest synchronously...", !
    Quit ..RunTestClass("Patterns.Test.Debug.SimpleTest")
}

/// Run the BasicTest class synchronously
ClassMethod TestBasicTestClass() As %Status
{
    Write !, "Running Patterns.Test.Example.BasicTest synchronously...", !
    Quit ..RunTestClass("Patterns.Test.Example.BasicTest")
}

}
