Class Patterns.Test.Unit.GoF.AllTestsRunner
{

/// Run all GoF pattern tests and provide comprehensive summary
ClassMethod RunAll() As %Status
{
    Write !, "="*70
    Write !, "=== GANG OF FOUR DESIGN PATTERNS TEST SUMMARY ==="
    Write !, "="*70, !
    
    Set totalTests = 0
    Set totalPassed = 0
    Set totalFailed = 0
    
    // BEHAVIORAL PATTERNS
    Write !, "BEHAVIORAL PATTERNS:", !
    Write "-"*50, !
    
    // Chain of Responsibility
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Behavioral.ChainOfResponsibilityTest")
    Write "Chain of Responsibility: ", result, !
    Set $PIECE(counts, ",", 1) = result
    
    // Command
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Behavioral.CommandTest")
    Write "Command: ", result, !
    Set $PIECE(counts, ",", 2) = result
    
    // Observer
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Behavioral.ObserverTest")
    Write "Observer: ", result, !
    Set $PIECE(counts, ",", 3) = result
    
    // CREATIONAL PATTERNS
    Write !, "CREATIONAL PATTERNS:", !
    Write "-"*50, !
    
    // Singleton
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Creational.SingletonTest")
    Write "Singleton: ", result, !
    Set $PIECE(counts, ",", 4) = result
    
    // Factory Method
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Creational.FactoryMethodTest")
    Write "Factory Method: ", result, !
    Set $PIECE(counts, ",", 5) = result
    
    // Abstract Factory
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Creational.AbstractFactoryTest")
    Write "Abstract Factory: ", result, !
    Set $PIECE(counts, ",", 6) = result
    
    // Builder
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Creational.BuilderTest")
    Write "Builder: ", result, !
    Set $PIECE(counts, ",", 7) = result
    
    // Prototype
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Creational.PrototypeTest")
    Write "Prototype: ", result, !
    Set $PIECE(counts, ",", 8) = result
    
    // STRUCTURAL PATTERNS
    Write !, "STRUCTURAL PATTERNS:", !
    Write "-"*50, !
    
    // Adapter
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Structural.AdapterTest")
    Write "Adapter: ", result, !
    Set $PIECE(counts, ",", 9) = result
    
    // Bridge
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Structural.BridgeTest")
    Write "Bridge: ", result, !
    Set $PIECE(counts, ",", 10) = result
    
    // Composite
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Structural.CompositeTest")
    Write "Composite: ", result, !
    Set $PIECE(counts, ",", 11) = result
    
    // Decorator
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Structural.DecoratorTest")
    Write "Decorator: ", result, !
    Set $PIECE(counts, ",", 12) = result
    
    // Facade
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Structural.FacadeTest")
    Write "Facade: ", result, !
    Set $PIECE(counts, ",", 13) = result
    
    // Flyweight
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Structural.FlyweightTest")
    Write "Flyweight: ", result, !
    Set $PIECE(counts, ",", 14) = result
    
    // Proxy
    Set result = ..RunTestClass("Patterns.Test.Unit.GoF.Structural.ProxyTest")
    Write "Proxy: ", result, !
    Set $PIECE(counts, ",", 15) = result
    
    // Calculate totals
    For i = 1:1:15 {
        Set res = $PIECE(counts, ",", i)
        If res '= "" {
            Set passed = +$PIECE(res, "/", 1)
            Set tests = +$PIECE($PIECE(res, "/", 2), " ", 1)
            Set totalTests = totalTests + tests
            Set totalPassed = totalPassed + passed
            Set totalFailed = totalFailed + (tests - passed)
        }
    }
    
    // Final summary
    Write !, "="*70
    Write !, "FINAL SUMMARY:", !
    Write "Total Tests: ", totalTests, !
    Write "Passed: ", totalPassed, " (", $FNUMBER(totalPassed/totalTests*100, "", 1), "%)", !
    Write "Failed: ", totalFailed, " (", $FNUMBER(totalFailed/totalTests*100, "", 1), "%)", !
    
    If totalFailed = 0 {
        Write !, "*** ALL TESTS PASSING! ***", !
    } Else {
        Write !, "*** ", totalFailed, " TESTS NEED ATTENTION ***", !
    }
    
    Write "="*70, !
    
    Quit $$$OK
}

/// Run a single test class and return results
ClassMethod RunTestClass(pClassName As %String) As %String
{
    Set result = ""
    
    // Check if class exists
    If '##class(%Dictionary.ClassDefinition).%ExistsId(pClassName) {
        Quit "CLASS NOT FOUND"
    }
    
    // Get test methods
    Set query = ##class(%SQL.Statement).%New()
    Set sql = "SELECT Name FROM %Dictionary.MethodDefinition WHERE parent = ? AND Name %STARTSWITH 'Test'"
    Set tSC = query.%Prepare(sql)
    If $$$ISERR(tSC) Quit "QUERY ERROR"
    
    Set rs = query.%Execute(pClassName)
    Set testCount = 0
    Set passCount = 0
    Set failCount = 0
    
    While rs.%Next() {
        Set methodName = rs.%Get("Name")
        Set testCount = testCount + 1
        
        // Try to run test
        Try {
            Set testInstance = $CLASSMETHOD(pClassName, "%New")
            Set passed = $METHOD(testInstance, methodName)
            
            If passed {
                Set passCount = passCount + 1
            } Else {
                Set failCount = failCount + 1
            }
        }
        Catch ex {
            Set failCount = failCount + 1
        }
    }
    
    If testCount = 0 {
        Quit "NO TESTS FOUND"
    }
    
    Set result = passCount _ "/" _ testCount _ " passing"
    If failCount > 0 {
        Set result = result _ " (" _ failCount _ " FAILED)"
    }
    
    Quit result
}

}
