/// Helper class to test FactoryMethod pattern
Class Patterns.Test.FactoryMethodTestHelper Extends %RegisteredObject
{

/// Test if FactoryMethod pattern works
ClassMethod TestFactoryMethod() As %String
{
    Set result = ""
    Set ^ClineDebug = ""
    
    Try {
        // Test ConcreteFactoryA
        Set factoryA = ##class(Patterns.GoF.Creational.ConcreteFactoryA).%New()
        If '$IsObject(factoryA) {
            Set result = result _ "ERROR: Could not create ConcreteFactoryA; "
            Set ^ClineDebug = ^ClineDebug _ "ConcreteFactoryA creation failed; "
        } Else {
            Set productA = factoryA.FactoryMethod()
            If '$IsObject(productA) {
                Set result = result _ "ERROR: ConcreteFactoryA.FactoryMethod() failed; "
                Set ^ClineDebug = ^ClineDebug _ "ProductA creation failed; "
            } Else {
                Set result = result _ "ConcreteFactoryA works; "
                Set ^ClineDebug = ^ClineDebug _ "ProductA created successfully; "
            }
        }
        
        // Test ConcreteFactoryB
        Set factoryB = ##class(Patterns.GoF.Creational.ConcreteFactoryB).%New()
        If '$IsObject(factoryB) {
            Set result = result _ "ERROR: Could not create ConcreteFactoryB; "
            Set ^ClineDebug = ^ClineDebug _ "ConcreteFactoryB creation failed; "
        } Else {
            Set productB = factoryB.FactoryMethod()
            If '$IsObject(productB) {
                Set result = result _ "ERROR: ConcreteFactoryB.FactoryMethod() failed; "
                Set ^ClineDebug = ^ClineDebug _ "ProductB creation failed; "
            } Else {
                Set result = result _ "ConcreteFactoryB works; "
                Set ^ClineDebug = ^ClineDebug _ "ProductB created successfully; "
            }
        }
        
    } Catch ex {
        Set result = result _ "EXCEPTION: " _ ex.DisplayString() _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Exception: " _ ex.DisplayString() _ "; "
    }
    
    If result = "" {
        Set result = "All tests passed!"
    }
    
    Quit result
}

}
