Class Patterns.Test.Unit.GoF.Structural.StructuralTestRunner
{

/// Run all Structural pattern tests and report status
ClassMethod RunAll() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting Structural pattern tests; "
    
    // List of Structural test classes
    Set tests = $LISTBUILD(
        "Patterns.Test.Unit.GoF.Structural.AdapterTest",
        "Patterns.Test.Unit.GoF.Structural.BridgeTest",
        "Patterns.Test.Unit.GoF.Structural.CompositeTest",
        "Patterns.Test.Unit.GoF.Structural.DecoratorTest",
        "Patterns.Test.Unit.GoF.Structural.FacadeTest",
        "Patterns.Test.Unit.GoF.Structural.FlyweightTest",
        "Patterns.Test.Unit.GoF.Structural.ProxyTest"
    )
    
    Set totalTests = 0
    Set totalPassed = 0
    Set totalFailed = 0
    
    Write !, "=== STRUCTURAL PATTERN TEST RESULTS ===", !
    
    For i = 1:1:$LISTLENGTH(tests) {
        Set testClass = $LIST(tests, i)
        Set ^ClineDebug = ^ClineDebug _ "Testing " _ testClass _ "; "
        
        // Check if class exists
        If '##class(%Dictionary.ClassDefinition).%ExistsId(testClass) {
            Write !, testClass, " - CLASS NOT FOUND"
            Set ^ClineDebug = ^ClineDebug _ testClass _ " not found; "
            Continue
        }
        
        // Get test methods
        Set query = ##class(%SQL.Statement).%New()
        Set sql = "SELECT Name FROM %Dictionary.MethodDefinition WHERE parent = ? AND Name %STARTSWITH 'Test'"
        Set tSC = query.%Prepare(sql)
        If $$$ISERR(tSC) Continue
        
        Set result = query.%Execute(testClass)
        Set classTests = 0
        Set classPassed = 0
        Set classFailed = 0
        
        While result.%Next() {
            Set methodName = result.%Get("Name")
            Set classTests = classTests + 1
            Set totalTests = totalTests + 1
            
            // Create instance and run test
            Try {
                Set testInstance = $CLASSMETHOD(testClass, "%New")
                
                // Run the test method
                Set passed = $METHOD(testInstance, methodName)
                
                If passed {
                    Set classPassed = classPassed + 1
                    Set totalPassed = totalPassed + 1
                } Else {
                    Set classFailed = classFailed + 1
                    Set totalFailed = totalFailed + 1
                }
            }
            Catch ex {
                Set classFailed = classFailed + 1
                Set totalFailed = totalFailed + 1
                Set ^ClineDebug = ^ClineDebug _ "Error in " _ methodName _ ": " _ ex.DisplayString() _ "; "
            }
        }
        
        Write !, $PIECE(testClass, ".", $LENGTH(testClass, ".")), ": ", classPassed, "/", classTests, " passed"
        If classFailed > 0 {
            Write " (", classFailed, " FAILED)"
        }
    }
    
    Write !, !, "=== TOTAL STRUCTURAL TESTS: ", totalPassed, "/", totalTests, " passed ==="
    If totalFailed > 0 {
        Write !, "!!! ", totalFailed, " TESTS FAILED !!!"
    }
    
    Set ^ClineDebug = ^ClineDebug _ "Total: " _ totalPassed _ "/" _ totalTests _ " passed"
    
    Quit $$$OK
}

}
