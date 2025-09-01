/// Test runner utility for executing all project tests
Class Tests.TestRunner
{

/// Run all project structure and configuration tests
ClassMethod RunAllTests(verbose As %Boolean = 1) As %Status
{
    Set status = $$$OK
    
    Write !, "================================================"
    Write !, "ObjectScript Design Patterns - Test Suite"
    Write !, "================================================"
    Write !, "Starting test execution at ", $ZDATETIME($HOROLOG, 3)
    Write !, ""
    
    // Set test directory
    Set testDir = "tests"
    
    // Run tests
    Try {
        // Run structure tests
        Write !, "Running Project Structure Tests..."
        Write !, "--------------------------------"
        Set status = ##class(%UnitTest.Manager).RunTest(testDir_"/ProjectStructureTest", "/nodelete")
        If $$$ISERR(status) {
            Write !, "ERROR: Project Structure Tests failed"
            Return status
        }
        
        // Run configuration tests
        Write !, ""
        Write !, "Running Configuration Validation Tests..."
        Write !, "----------------------------------------"
        Set status = ##class(%UnitTest.Manager).RunTest(testDir_"/ConfigurationValidationTest", "/nodelete")
        If $$$ISERR(status) {
            Write !, "ERROR: Configuration Validation Tests failed"
            Return status
        }
        
        Write !, ""
        Write !, "================================================"
        Write !, "All tests completed successfully!"
        Write !, "================================================"
        
    } Catch ex {
        Set status = ex.AsStatus()
        Write !, "ERROR during test execution: ", $SYSTEM.Status.GetErrorText(status)
    }
    
    Return status
}

/// Run specific test class
ClassMethod RunTestClass(className As %String) As %Status
{
    Set status = $$$OK
    
    Write !, "Running test class: ", className
    Write !, "--------------------------------"
    
    Try {
        Set status = ##class(%UnitTest.Manager).RunTest("tests/"_className, "/nodelete")
    } Catch ex {
        Set status = ex.AsStatus()
        Write !, "ERROR: ", $SYSTEM.Status.GetErrorText(status)
    }
    
    Return status
}

/// Validate project setup without running full tests
ClassMethod ValidateSetup() As %Status
{
    Set status = $$$OK
    Set errors = 0
    
    Write !, "================================================"
    Write !, "Project Setup Validation"
    Write !, "================================================"
    Write !
    
    // Check critical directories
    Write "Checking directory structure... "
    Set dirs = $LISTBUILD(
        "src",
        "docs", 
        "tests",
        "examples",
        ".vscode",
        "src/Patterns",
        "src/Patterns/GoF",
        "src/Patterns/PoEAA"
    )
    
    Set ptr = 0
    Set allDirsExist = 1
    While $LISTNEXT(dirs, ptr, dir) {
        If '##class(%File).DirectoryExists(dir) {
            If allDirsExist Write "[FAILED]"
            Write !, "  Missing directory: ", dir
            Set allDirsExist = 0
            Set errors = errors + 1
        }
    }
    If allDirsExist Write "[OK]"
    Write !
    
    // Check critical files
    Write "Checking configuration files... "
    Set files = $LISTBUILD(
        "README.md",
        "LICENSE",
        ".gitignore",
        "module.xml",
        ".editorconfig",
        "objectscript-design-patterns.code-workspace",
        ".vscode/settings.json",
        ".vscode/launch.json",
        ".vscode/extensions.json"
    )
    
    Set ptr = 0
    Set allFilesExist = 1
    While $LISTNEXT(files, ptr, file) {
        If '##class(%File).Exists(file) {
            If allFilesExist Write "[FAILED]"
            Write !, "  Missing file: ", file
            Set allFilesExist = 0
            Set errors = errors + 1
        }
    }
    If allFilesExist Write "[OK]"
    Write !
    
    // Check documentation
    Write "Checking documentation... "
    Set docs = $LISTBUILD(
        "docs/guides/getting-started.md",
        "docs/guides/installation.md",
        "docs/guides/contributing.md"
    )
    
    Set ptr = 0
    Set allDocsExist = 1
    While $LISTNEXT(docs, ptr, doc) {
        If '##class(%File).Exists(doc) {
            If allDocsExist Write "[FAILED]"
            Write !, "  Missing documentation: ", doc
            Set allDocsExist = 0
            Set errors = errors + 1
        }
    }
    If allDocsExist Write "[OK]"
    Write !
    
    // Summary
    Write !, "================================================"
    If errors = 0 {
        Write !, "✓ Validation PASSED - All components present"
    } Else {
        Write !, "✗ Validation FAILED - ", errors, " issue(s) found"
        Set status = $$$ERROR($$$GeneralError, errors_" validation errors found")
    }
    Write !, "================================================"
    Write !
    
    Return status
}

/// Generate test report
ClassMethod GenerateReport(outputFile As %String = "test-report.txt") As %Status
{
    Set status = $$$OK
    
    Try {
        Set file = ##class(%Stream.FileCharacter).%New()
        Set file.Filename = outputFile
        
        Do file.WriteLine("ObjectScript Design Patterns - Test Report")
        Do file.WriteLine("==========================================")
        Do file.WriteLine("Generated: "_$ZDATETIME($HOROLOG, 3))
        Do file.WriteLine("")
        
        // Run validation
        Set validationStatus = ..ValidateSetup()
        
        Do file.WriteLine("Setup Validation: "_$SELECT($$$ISOK(validationStatus):"PASSED", 1:"FAILED"))
        Do file.WriteLine("")
        
        // List test classes
        Do file.WriteLine("Test Classes:")
        Do file.WriteLine("- Tests.ProjectStructureTest")
        Do file.WriteLine("- Tests.ConfigurationValidationTest")
        Do file.WriteLine("- Tests.TestRunner")
        Do file.WriteLine("")
        
        // Project statistics
        Do file.WriteLine("Project Statistics:")
        Do file.WriteLine("- Pattern Categories: GoF (Creational, Structural, Behavioral), PoEAA")
        Do file.WriteLine("- Documentation: Guides, API docs, Pattern docs")
        Do file.WriteLine("- Examples: Basic, Advanced, Real-world")
        Do file.WriteLine("")
        
        Set status = file.%Save()
        
        If $$$ISOK(status) {
            Write !, "Test report generated: ", outputFile
        } Else {
            Write !, "Failed to generate report: ", $SYSTEM.Status.GetErrorText(status)
        }
        
    } Catch ex {
        Set status = ex.AsStatus()
    }
    
    Return status
}

/// Clean test artifacts
ClassMethod CleanTestArtifacts() As %Status
{
    Write !, "Cleaning test artifacts..."
    
    // Remove test report if exists
    If ##class(%File).Exists("test-report.txt") {
        Do ##class(%File).Delete("test-report.txt")
        Write !, "  Removed test-report.txt"
    }
    
    Write !, "Test artifacts cleaned"
    Return $$$OK
}

/// Display help information
ClassMethod Help()
{
    Write !, "ObjectScript Design Patterns - Test Runner"
    Write !, "=========================================="
    Write !, ""
    Write !, "Available commands:"
    Write !, "  Do ##class(Tests.TestRunner).RunAllTests()      - Run all tests"
    Write !, "  Do ##class(Tests.TestRunner).ValidateSetup()    - Quick validation"
    Write !, "  Do ##class(Tests.TestRunner).GenerateReport()   - Generate test report"
    Write !, "  Do ##class(Tests.TestRunner).RunTestClass(name) - Run specific test"
    Write !, "  Do ##class(Tests.TestRunner).CleanTestArtifacts() - Clean test files"
    Write !, "  Do ##class(Tests.TestRunner).Help()            - Show this help"
    Write !, ""
}

}
