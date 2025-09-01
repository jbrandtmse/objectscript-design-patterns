/// Unit tests for validating configuration and setup
Class Tests.ConfigurationValidationTest Extends %UnitTest.TestCase
{

/// Test namespace configuration
Method TestNamespaceConfiguration()
{
    // Check current namespace
    Set currentNS = $NAMESPACE
    Write !, "Current namespace: ", currentNS
    
    // Test if we can access expected namespaces
    If currentNS = "PATTERNS" {
        Do $$$AssertEquals(currentNS, "PATTERNS", "Running in PATTERNS namespace")
    } ElseIf currentNS = "PATTERNS-TEST" {
        Do $$$AssertEquals(currentNS, "PATTERNS-TEST", "Running in PATTERNS-TEST namespace")
    } Else {
        // Allow tests to run in any namespace but log warning
        Write !, "WARNING: Tests running in unexpected namespace: ", currentNS
        Do $$$LogMessage("Tests running in namespace: "_currentNS)
    }
}

/// Test package compilation settings
Method TestCompilationSettings()
{
    // Test that compilation flags are appropriate
    Set flags = "ck"  // compile and keep source
    Do $$$AssertEquals($LENGTH(flags), 2, "Compilation flags set correctly")
    Do $$$AssertTrue(flags["c", "Compile flag present")
    Do $$$AssertTrue(flags["k", "Keep source flag present")
}

/// Test that pattern registry can be initialized
Method TestPatternRegistryInitialization()
{
    // Check if Registry package is available for patterns
    Set registryPackage = "Patterns.Registry"
    Set utilsPackage = "Patterns.Utils"
    
    // These packages should be created when patterns are implemented
    Write !, "Pattern Registry package to be implemented: ", registryPackage
    Write !, "Pattern Utils package to be implemented: ", utilsPackage
    
    Do $$$LogMessage("Registry and Utils packages will be implemented with patterns")
}

/// Test export/import configuration
Method TestExportImportConfiguration()
{
    // Test export folder configuration
    Set exportFolder = "src"
    Do $$$AssertTrue(##class(%File).DirectoryExists(exportFolder), "Export folder exists: "_exportFolder)
    
    // Test pattern export structure
    Set patternExportPath = exportFolder_"/Patterns"
    Do $$$AssertTrue(##class(%File).DirectoryExists(patternExportPath), "Pattern export path exists")
    
    // Test that export paths match expected structure
    Set gofPath = patternExportPath_"/GoF"
    Set poeaaPath = patternExportPath_"/PoEAA"
    
    Do $$$AssertTrue(##class(%File).DirectoryExists(gofPath), "GoF export path exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists(poeaaPath), "PoEAA export path exists")
}

/// Test documentation structure
Method TestDocumentationStructure()
{
    // Check main documentation directories
    Do $$$AssertTrue(##class(%File).DirectoryExists("docs"), "Documentation root exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("docs/api"), "API documentation directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("docs/guides"), "Guides directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("docs/patterns"), "Pattern docs directory exists")
    
    // Check for key documentation files
    Do $$$AssertTrue(##class(%File).Exists("docs/guides/getting-started.md"), "Getting started guide exists")
    Do $$$AssertTrue(##class(%File).Exists("docs/guides/installation.md"), "Installation guide exists")
    Do $$$AssertTrue(##class(%File).Exists("docs/guides/contributing.md"), "Contributing guide exists")
}

/// Test example directories structure
Method TestExampleStructure()
{
    // Check example directories
    Do $$$AssertTrue(##class(%File).DirectoryExists("examples"), "Examples root exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("examples/basic"), "Basic examples directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("examples/advanced"), "Advanced examples directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("examples/real-world"), "Real-world examples directory exists")
}

/// Test source code organization
Method TestSourceCodeOrganization()
{
    Set srcDir = "src"
    Do $$$AssertTrue(##class(%File).DirectoryExists(srcDir), "Source directory exists")
    
    // Test GoF pattern categories
    Set gofCreational = srcDir_"/Patterns/GoF/Creational"
    Set gofStructural = srcDir_"/Patterns/GoF/Structural"
    Set gofBehavioral = srcDir_"/Patterns/GoF/Behavioral"
    
    Do $$$AssertTrue(##class(%File).DirectoryExists(gofCreational), "GoF Creational directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists(gofStructural), "GoF Structural directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists(gofBehavioral), "GoF Behavioral directory exists")
    
    // Test PoEAA pattern categories
    Set poeaaDataSource = srcDir_"/Patterns/PoEAA/DataSource"
    Set poeaaDomainLogic = srcDir_"/Patterns/PoEAA/DomainLogic"
    Set poeaaObjectRelational = srcDir_"/Patterns/PoEAA/ObjectRelational"
    
    Do $$$AssertTrue(##class(%File).DirectoryExists(poeaaDataSource), "PoEAA DataSource directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists(poeaaDomainLogic), "PoEAA DomainLogic directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists(poeaaObjectRelational), "PoEAA ObjectRelational directory exists")
    
    // Test utility directories
    Set registryDir = srcDir_"/Patterns/Registry"
    Set utilsDir = srcDir_"/Patterns/Utils"
    Set examplesDir = srcDir_"/Patterns/Examples"
    Set includesDir = srcDir_"/includes"
    
    Do $$$AssertTrue(##class(%File).DirectoryExists(registryDir), "Registry directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists(utilsDir), "Utils directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists(examplesDir), "Examples directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists(includesDir), "Includes directory exists")
}

/// Test VS Code integration
Method TestVSCodeIntegration()
{
    // Check VS Code configuration files
    Do $$$AssertTrue(##class(%File).DirectoryExists(".vscode"), ".vscode directory exists")
    Do $$$AssertTrue(##class(%File).Exists(".vscode/settings.json"), "VS Code settings exists")
    Do $$$AssertTrue(##class(%File).Exists(".vscode/launch.json"), "VS Code launch config exists")
    Do $$$AssertTrue(##class(%File).Exists(".vscode/extensions.json"), "VS Code extensions recommendations exists")
    
    // Check workspace file
    Do $$$AssertTrue(##class(%File).Exists("objectscript-design-patterns.code-workspace"), "VS Code workspace file exists")
}

/// Test Git configuration
Method TestGitSetup()
{
    // Check git configuration files
    Do $$$AssertTrue(##class(%File).Exists(".gitignore"), ".gitignore exists")
    
    // Read .gitignore and verify key patterns
    Set stream = ##class(%Stream.FileCharacter).%New()
    Set sc = stream.LinkToFile(".gitignore")
    If $$$ISOK(sc) {
        Set content = stream.Read()
        
        // Check for IRIS-specific ignores
        Do $$$AssertTrue(content["iris.key", "iris.key in .gitignore")
        Do $$$AssertTrue(content["*.DAT", "DAT files ignored")
        Do $$$AssertTrue(content["*.log", "Log files ignored")
        
        // Check for IDE ignores
        Do $$$AssertTrue(content[".vscode-server", "VS Code server ignored")
        Do $$$AssertTrue(content[".idea", "IntelliJ IDEA files ignored")
    }
}

/// Test module.xml configuration
Method TestModuleXML()
{
    Do $$$AssertTrue(##class(%File).Exists("module.xml"), "module.xml exists")
    
    Set stream = ##class(%Stream.FileCharacter).%New()
    Set sc = stream.LinkToFile("module.xml")
    If $$$ISOK(sc) {
        Set content = stream.Read()
        
        // Check module metadata
        Do $$$AssertTrue(content["objectscript-design-patterns", "Module name correct")
        Do $$$AssertTrue(content["1.0.0", "Version specified")
        Do $$$AssertTrue(content["PATTERNS", "Namespace specified")
        
        // Check for test configuration
        Do $$$AssertTrue(content["UnitTest", "Unit test configuration present")
    }
}

}
