/// Debug class to test Chain of Responsibility compilation
Class Patterns.Test.Unit.GoF.Behavioral.ChainDebugTest Extends %RegisteredObject
{

/// Simple test method
ClassMethod TestCompilation() As %String
{
    Set result = ""
    
    Try {
        // Test if the class exists
        If ##class(%Dictionary.ClassDefinition).%ExistsId("Patterns.Test.Unit.GoF.Behavioral.ChainOfResponsibilityTest") {
            Set result = result _ "Class exists; "
            
            // Check for TestChainFormation method
            If ##class(%Dictionary.MethodDefinition).%ExistsId("Patterns.Test.Unit.GoF.Behavioral.ChainOfResponsibilityTest||TestChainFormation") {
                Set result = result _ "TestChainFormation exists; "
                
                // Get method definition
                Set methodDef = ##class(%Dictionary.MethodDefinition).%OpenId("Patterns.Test.Unit.GoF.Behavioral.ChainOfResponsibilityTest||TestChainFormation")
                Set result = result _ "ReturnType=" _ methodDef.ReturnType _ "; "
            } Else {
                Set result = result _ "TestChainFormation NOT found; "
            }
        } Else {
            Set result = result _ "Class NOT found; "
        }
    }
    Catch ex {
        Set result = result _ "Error: " _ ex.DisplayString()
    }
    
    Quit result
}

/// List all test methods in the class
ClassMethod ListTestMethods() As %String
{
    Set result = ""
    Set className = "Patterns.Test.Unit.GoF.Behavioral.ChainOfResponsibilityTest"
    
    Try {
        // Open class definition
        Set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(className)
        If $IsObject(classDef) {
            Set key = ""
            For {
                Set method = classDef.Methods.GetNext(.key)
                If key = "" Quit
                If $Extract(method.Name, 1, 4) = "Test" {
                    Set result = result _ method.Name _ "(" _ method.ReturnType _ "); "
                }
            }
        }
    }
    Catch ex {
        Set result = "Error: " _ ex.DisplayString()
    }
    
    Quit result
}

/// Debug specific test failures
ClassMethod DebugTestFailure(pTestName As %String) As %String
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting debug for " _ pTestName _ "; "
    
    Try {
        If pTestName = "TestChainFormation" {
            Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
            Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
            Do tNurse.SetNext(tDoctor)
            
            Set ^ClineDebug = ^ClineDebug _ "Nurse.NextHandler=" _ $IsObject(tNurse.NextHandler) _ "; "
            If $IsObject(tNurse.NextHandler) {
                Set ^ClineDebug = ^ClineDebug _ "NextHandler.HandlerName=" _ tNurse.NextHandler.HandlerName _ "; "
            }
            Set ^ClineDebug = ^ClineDebug _ "GetChainLength=" _ tNurse.GetChainLength() _ "; "
            Set ^ClineDebug = ^ClineDebug _ "GetChainInfo=" _ tNurse.GetChainInfo() _ "; "
            Set tSC = tNurse.ValidateChain()
            Set ^ClineDebug = ^ClineDebug _ "ValidateChain=" _ $System.Status.DisplayError(tSC) _ "; "
        }
        ElseIf pTestName = "TestCircularChainPrevention" {
            Set tHandler1 = ##class(Patterns.GoF.Behavioral.ConcreteHandler).%New("Handler1", 10)
            Set tHandler2 = ##class(Patterns.GoF.Behavioral.ConcreteHandler).%New("Handler2", 20)
            Set tHandler3 = ##class(Patterns.GoF.Behavioral.ConcreteHandler).%New("Handler3", 30)
            
            Do tHandler1.SetNext(tHandler2)
            Do tHandler2.SetNext(tHandler3)
            Do tHandler3.SetNext(tHandler1)
            
            Set tSC = tHandler1.ValidateChain()
            Set ^ClineDebug = ^ClineDebug _ "CircularValidation=" _ $System.Status.DisplayError(tSC) _ "; "
            Set ^ClineDebug = ^ClineDebug _ "ErrorText=" _ $System.Status.GetErrorText(tSC) _ "; "
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "Exception: " _ ex.DisplayString()
    }
    
    Quit ^ClineDebug
}

}
