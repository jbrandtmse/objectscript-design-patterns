/// Utility to fix Chain of Responsibility tests directly in IRIS
Class Patterns.Test.Unit.GoF.Behavioral.ChainTestFixer Extends %RegisteredObject
{

/// Fix all test methods in ChainOfResponsibilityTest to return Boolean
ClassMethod FixTests() As %Status
{
    Set tSC = $$$OK
    Set className = "Patterns.Test.Unit.GoF.Behavioral.ChainOfResponsibilityTest"
    
    Try {
        // Open class definition
        Set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(className)
        If '$IsObject(classDef) {
            Set tSC = $$$ERROR($$$GeneralError, "Class not found: " _ className)
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Fix each test method
        Set key = ""
        For {
            Set method = classDef.Methods.GetNext(.key)
            If key = "" Quit
            
            // Only fix Test* methods
            If $Extract(method.Name, 1, 4) = "Test" {
                // Set return type to %Boolean if not already set
                If method.ReturnType '= "%Boolean" {
                    Set method.ReturnType = "%Boolean"
                }
                
                // Check if method has "Quit 1" at the end
                Set implementation = method.Implementation
                If '$IsObject(implementation) {
                    Set implementation = ##class(%Stream.TmpCharacter).%New()
                    Set method.Implementation = implementation
                }
                
                // Read implementation
                Set code = ""
                Do implementation.Rewind()
                While 'implementation.AtEnd {
                    Set line = implementation.ReadLine()
                    Set code = code _ line _ $Char(13,10)
                }
                
                // Check if ends with Quit 1
                If code '[ "Quit 1" {
                    // Add Quit 1 before closing brace if needed
                    Set code = $Replace(code, "}", "    Quit 1" _ $Char(13,10) _ "}")
                    
                    // Clear and rewrite implementation
                    Do implementation.Clear()
                    Do implementation.Write(code)
                }
            }
        }
        
        // Save the class
        Set tSC = classDef.%Save()
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Compile the class
        Set tSC = $System.OBJ.Compile(className, "ckf")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check test methods
ClassMethod CheckTests() As %String
{
    Set result = ""
    Set className = "Patterns.Test.Unit.GoF.Behavioral.ChainOfResponsibilityTest"
    
    Try {
        Set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(className)
        If $IsObject(classDef) {
            Set key = ""
            Set count = 0
            For {
                Set method = classDef.Methods.GetNext(.key)
                If key = "" Quit
                
                If $Extract(method.Name, 1, 4) = "Test" {
                    Set count = count + 1
                    Set hasReturn = (method.ReturnType = "%Boolean")
                    
                    // Check implementation for Quit 1
                    Set hasQuit = 0
                    If $IsObject(method.Implementation) {
                        Do method.Implementation.Rewind()
                        While 'method.Implementation.AtEnd {
                            Set line = method.Implementation.ReadLine()
                            If line [ "Quit 1" Set hasQuit = 1
                        }
                    }
                    
                    Set result = result _ method.Name _ ": ReturnType=" _ method.ReturnType _ ", HasQuit=" _ hasQuit _ "; "
                }
            }
            Set result = "Found " _ count _ " test methods: " _ result
        } Else {
            Set result = "Class not found"
        }
    }
    Catch ex {
        Set result = "Error: " _ ex.DisplayString()
    }
    
    Quit result
}

}
