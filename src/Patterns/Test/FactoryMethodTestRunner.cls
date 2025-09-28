/// Temporary test runner for FactoryMethod pattern tests
Class Patterns.Test.FactoryMethodTestRunner
{

/// Run FactoryMethod tests and return results
ClassMethod RunTests() As %String
{
    Set result = ""
    Set ^ClineDebug = ""
    
    Try {
        // Create test instance
        Set test = ##class(Patterns.Test.Unit.GoF.Creational.FactoryMethodTest).%New()
        
        Set result = result _ "=== FactoryMethod Tests ===" _ $Char(13,10)
        
        // Test 1: TestAbstractFactoryInstantiation
        Try {
            Do test.TestAbstractFactoryInstantiation()
            Set result = result _ "✓ TestAbstractFactoryInstantiation passed" _ $Char(13,10)
        } Catch ex1 {
            Set result = result _ "✗ TestAbstractFactoryInstantiation failed: " _ ex1.DisplayString() _ $Char(13,10)
        }
        
        // Test 2: TestConcreteFactoryACreatesProductA
        Try {
            Do test.TestConcreteFactoryACreatesProductA()
            Set result = result _ "✓ TestConcreteFactoryACreatesProductA passed" _ $Char(13,10)
        } Catch ex2 {
            Set result = result _ "✗ TestConcreteFactoryACreatesProductA failed: " _ ex2.DisplayString() _ $Char(13,10)
        }
        
        // Test 3: TestConcreteFactoryBCreatesProductB
        Try {
            Do test.TestConcreteFactoryBCreatesProductB()
            Set result = result _ "✓ TestConcreteFactoryBCreatesProductB passed" _ $Char(13,10)
        } Catch ex3 {
            Set result = result _ "✗ TestConcreteFactoryBCreatesProductB failed: " _ ex3.DisplayString() _ $Char(13,10)
        }
        
        // Test 4: TestFactoryMethodDelegation
        Try {
            Do test.TestFactoryMethodDelegation()
            Set result = result _ "✓ TestFactoryMethodDelegation passed" _ $Char(13,10)
        } Catch ex4 {
            Set result = result _ "✗ TestFactoryMethodDelegation failed: " _ ex4.DisplayString() _ $Char(13,10)
        }
        
        // Test 5: TestProductPolymorphism
        Try {
            Do test.TestProductPolymorphism()
            Set result = result _ "✓ TestProductPolymorphism passed" _ $Char(13,10)
        } Catch ex5 {
            Set result = result _ "✗ TestProductPolymorphism failed: " _ ex5.DisplayString() _ $Char(13,10)
        }
        
        // Test 6: TestAbstractPatientRecordFactory
        Try {
            Do test.TestAbstractPatientRecordFactory()
            Set result = result _ "✓ TestAbstractPatientRecordFactory passed" _ $Char(13,10)
        } Catch ex6 {
            Set result = result _ "✗ TestAbstractPatientRecordFactory failed: " _ ex6.DisplayString() _ $Char(13,10)
        }
        
        // Test 7: TestInpatientRecordFactory
        Try {
            Do test.TestInpatientRecordFactory()
            Set result = result _ "✓ TestInpatientRecordFactory passed" _ $Char(13,10)
        } Catch ex7 {
            Set result = result _ "✗ TestInpatientRecordFactory failed: " _ ex7.DisplayString() _ $Char(13,10)
        }
        
        // Test 8: TestOutpatientRecordFactory
        Try {
            Do test.TestOutpatientRecordFactory()
            Set result = result _ "✓ TestOutpatientRecordFactory passed" _ $Char(13,10)
        } Catch ex8 {
            Set result = result _ "✗ TestOutpatientRecordFactory failed: " _ ex8.DisplayString() _ $Char(13,10)
        }
        
        // Test 9: TestEmergencyRecordFactory
        Try {
            Do test.TestEmergencyRecordFactory()
            Set result = result _ "✓ TestEmergencyRecordFactory passed" _ $Char(13,10)
        } Catch ex9 {
            Set result = result _ "✗ TestEmergencyRecordFactory failed: " _ ex9.DisplayString() _ $Char(13,10)
        }
        
        // Test 10: TestPatientRecordPolymorphism
        Try {
            Do test.TestPatientRecordPolymorphism()
            Set result = result _ "✓ TestPatientRecordPolymorphism passed" _ $Char(13,10)
        } Catch ex10 {
            Set result = result _ "✗ TestPatientRecordPolymorphism failed: " _ ex10.DisplayString() _ $Char(13,10)
        }
        
    } Catch mainEx {
        Set result = "ERROR: Failed to run tests - " _ mainEx.DisplayString()
    }
    
    // Add debug info if available
    If ^ClineDebug '= "" {
        Set result = result _ $Char(13,10) _ "Debug Info: " _ ^ClineDebug
    }
    
    Quit result
}

}
