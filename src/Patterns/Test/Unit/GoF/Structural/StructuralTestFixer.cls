Class Patterns.Test.Unit.GoF.Structural.StructuralTestFixer
{

/// Fix all Structural pattern test classes to have proper %OnNew and return values
ClassMethod FixAll() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting Structural test fixes; "
    
    // List of test classes to fix
    Set tests = $LISTBUILD(
        "Patterns.Test.Unit.GoF.Structural.AdapterTest",
        "Patterns.Test.Unit.GoF.Structural.BridgeTest",
        "Patterns.Test.Unit.GoF.Structural.CompositeTest",
        "Patterns.Test.Unit.GoF.Structural.DecoratorTest",
        "Patterns.Test.Unit.GoF.Structural.FacadeTest",
        "Patterns.Test.Unit.GoF.Structural.FlyweightTest",
        "Patterns.Test.Unit.GoF.Structural.ProxyTest"
    )
    
    Write !, "=== FIXING STRUCTURAL PATTERN TESTS ===", !
    
    For i = 1:1:$LISTLENGTH(tests) {
        Set testClass = $LIST(tests, i)
        Write !, "Fixing ", testClass, "..."
        
        // Check if class exists
        If '##class(%Dictionary.ClassDefinition).%ExistsId(testClass) {
            Write " - CLASS NOT FOUND"
            Continue
        }
        
        // Fix %OnNew constructor
        Set tSC = ..AddOnNewConstructor(testClass)
        If $$$ISERR(tSC) {
            Write " - Error adding %OnNew: ", $SYSTEM.Status.GetErrorText(tSC)
            Continue
        }
        
        // Fix test method return values
        Set tSC = ..FixTestMethodReturns(testClass)
        If $$$ISERR(tSC) {
            Write " - Error fixing returns: ", $SYSTEM.Status.GetErrorText(tSC)
            Continue
        }
        
        Write " - FIXED"
        Set ^ClineDebug = ^ClineDebug _ testClass _ " fixed; "
    }
    
    Write !, !, "=== COMPILING FIXED TESTS ===", !
    
    // Compile all fixed tests
    For i = 1:1:$LISTLENGTH(tests) {
        Set testClass = $LIST(tests, i)
        Write !, "Compiling ", testClass, "..."
        Set tSC = $SYSTEM.OBJ.Compile(testClass, "bckry")
        If $$$ISERR(tSC) {
            Write " - COMPILATION ERROR"
        } Else {
            Write " - OK"
        }
    }
    
    Write !, !, "=== ALL STRUCTURAL TEST FIXES COMPLETE ===", !
    
    Quit $$$OK
}

/// Add proper %OnNew constructor to test class
ClassMethod AddOnNewConstructor(pClassName As %String) As %Status
{
    // Check if %OnNew already exists
    If ##class(%Dictionary.MethodDefinition).%ExistsId(pClassName_"||%OnNew") {
        // Delete existing %OnNew
        Set tSC = ##class(%Dictionary.MethodDefinition).%DeleteId(pClassName_"||%OnNew")
        If $$$ISERR(tSC) Quit tSC
    }
    
    // Create new %OnNew method
    Set tMethod = ##class(%Dictionary.MethodDefinition).%New()
    Set tMethod.parent = pClassName
    Set tMethod.Name = "%OnNew"
    Set tMethod.ReturnType = "%Status"
    Set tMethod.FormalSpec = "initvalue:%String="""
    Set tMethod.Description = "Constructor - properly handle initvalue parameter from parent class"
    
    // Add implementation
    Set tMethod.Implementation = ##class(%Stream.TmpCharacter).%New()
    Do tMethod.Implementation.WriteLine("    // Call parent constructor with initvalue parameter")
    Do tMethod.Implementation.WriteLine("    Set tSC = ##super(initvalue)")
    Do tMethod.Implementation.WriteLine("    If $$$ISERR(tSC) Quit tSC")
    Do tMethod.Implementation.WriteLine("    ")
    Do tMethod.Implementation.WriteLine("    Quit $$$OK")
    
    Set tSC = tMethod.%Save()
    Quit tSC
}

/// Fix test methods to return Boolean instead of %Status
ClassMethod FixTestMethodReturns(pClassName As %String) As %Status
{
    Set tSC = $$$OK
    
    // Get all test methods
    Set query = ##class(%SQL.Statement).%New()
    Set sql = "SELECT Name FROM %Dictionary.MethodDefinition WHERE parent = ? AND Name %STARTSWITH 'Test'"
    Set tSC = query.%Prepare(sql)
    If $$$ISERR(tSC) Quit tSC
    
    Set result = query.%Execute(pClassName)
    
    While result.%Next() {
        Set methodName = result.%Get("Name")
        
        // Get the method definition
        Set tMethod = ##class(%Dictionary.MethodDefinition).%OpenId(pClassName_"||"_methodName)
        If '$IsObject(tMethod) Continue
        
        // Get the implementation
        Set impl = tMethod.Implementation
        If '$IsObject(impl) Continue
        
        // Read all lines
        Set lines = ""
        Do impl.Rewind()
        While 'impl.AtEnd {
            Set line = impl.ReadLine()
            Set lines = lines _ line _ $CHAR(13,10)
        }
        
        // Replace "Quit $$$OK" with "Quit 1"
        Set lines = $REPLACE(lines, "Quit $$$OK", "Quit 1")
        
        // If no "Quit 1" at end, add it
        If lines '[ "Quit 1" {
            // Remove trailing whitespace
            While $EXTRACT(lines, *) = $CHAR(13) || ($EXTRACT(lines, *) = $CHAR(10)) {
                Set lines = $EXTRACT(lines, 1, *-1)
            }
            Set lines = lines _ $CHAR(13,10) _ "    Quit 1"
        }
        
        // Update the implementation
        Set impl = ##class(%Stream.TmpCharacter).%New()
        Do impl.Write(lines)
        Set tMethod.Implementation = impl
        
        Set tSC = tMethod.%Save()
        If $$$ISERR(tSC) Quit
    }
    
    Quit tSC
}

}
