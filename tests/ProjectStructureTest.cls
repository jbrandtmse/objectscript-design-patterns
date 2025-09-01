/// Unit tests for validating project structure and configuration
Class Tests.ProjectStructureTest Extends %UnitTest.TestCase
{

/// Test that all required directories exist
Method TestDirectoryStructure()
{
    // Test for main directories
    Do $$$AssertTrue(##class(%File).DirectoryExists("src"), "src directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("docs"), "docs directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("tests"), "tests directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("examples"), "examples directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists(".vscode"), ".vscode directory exists")
    
    // Test for pattern directories
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns"), "src/Patterns directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/GoF"), "GoF patterns directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/GoF/Creational"), "Creational patterns directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/GoF/Structural"), "Structural patterns directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/GoF/Behavioral"), "Behavioral patterns directory exists")
    
    // Test for PoEAA directories
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/PoEAA"), "PoEAA patterns directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/PoEAA/DataSource"), "DataSource patterns directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/PoEAA/DomainLogic"), "DomainLogic patterns directory exists")
    
    // Test for utility directories
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/Registry"), "Registry directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/Utils"), "Utils directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("src/Patterns/Examples"), "Examples directory exists")
    
    // Test for documentation directories
    Do $$$AssertTrue(##class(%File).DirectoryExists("docs/api"), "API documentation directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("docs/guides"), "Guides directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("docs/patterns"), "Patterns documentation directory exists")
    Do $$$AssertTrue(##class(%File).DirectoryExists("docs/architecture"), "Architecture documentation directory exists")
}

/// Test that all required configuration files exist
Method TestConfigurationFiles()
{
    // Root configuration files
    Do $$$AssertTrue(##class(%File).Exists("README.md"), "README.md exists")
    Do $$$AssertTrue(##class(%File).Exists("LICENSE"), "LICENSE file exists")
    Do $$$AssertTrue(##class(%File).Exists(".gitignore"), ".gitignore exists")
    Do $$$AssertTrue(##class(%File).Exists("module.xml"), "module.xml exists")
    Do $$$AssertTrue(##class(%File).Exists(".editorconfig"), ".editorconfig exists")
    Do $$$AssertTrue(##class(%File).Exists("objectscript-design-patterns.code-workspace"), "VS Code workspace file exists")
    
    // VS Code configuration files
    Do $$$AssertTrue(##class(%File).Exists(".vscode/settings.json"), "VS Code settings.json exists")
    Do $$$AssertTrue(##class(%File).Exists(".vscode/launch.json"), "VS Code launch.json exists")
    Do $$$AssertTrue(##class(%File).Exists(".vscode/extensions.json"), "VS Code extensions.json exists")
    
    // Documentation files
    Do $$$AssertTrue(##class(%File).Exists("docs/guides/getting-started.md"), "Getting Started guide exists")
    Do $$$AssertTrue(##class(%File).Exists("docs/guides/installation.md"), "Installation guide exists")
    Do $$$AssertTrue(##class(%File).Exists("docs/guides/contributing.md"), "Contributing guide exists")
}

/// Test that the module.xml is valid and contains required elements
Method TestModuleConfiguration()
{
    Set moduleFile = "module.xml"
    Do $$$AssertTrue(##class(%File).Exists(moduleFile), "module.xml exists")
    
    If ##class(%File).Exists(moduleFile) {
        // Read the module.xml content
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set sc = stream.LinkToFile(moduleFile)
        Do $$$AssertStatusOK(sc, "Can read module.xml")
        
        Set content = stream.Read()
        
        // Check for required elements
        Do $$$AssertTrue(content["<Module", "Module element exists")
        Do $$$AssertTrue(content["name=""objectscript-design-patterns""", "Module name is correct")
        Do $$$AssertTrue(content["<Namespace", "Namespace configuration exists")
        Do $$$AssertTrue(content["Name=""PATTERNS""", "PATTERNS namespace defined")
        Do $$$AssertTrue(content["<Dependencies>", "Dependencies section exists")
        Do $$$AssertTrue(content["<SystemRequirements>", "System requirements defined")
    }
}

/// Test VS Code configuration validity
Method TestVSCodeConfiguration()
{
    Set settingsFile = ".vscode/settings.json"
    Do $$$AssertTrue(##class(%File).Exists(settingsFile), "VS Code settings.json exists")
    
    If ##class(%File).Exists(settingsFile) {
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set sc = stream.LinkToFile(settingsFile)
        Do $$$AssertStatusOK(sc, "Can read settings.json")
        
        Set content = stream.Read()
        
        // Check for required ObjectScript settings
        Do $$$AssertTrue(content["objectscript.conn", "ObjectScript connection settings present")
        Do $$$AssertTrue(content["""PATTERNS""", "PATTERNS namespace configured")
        Do $$$AssertTrue(content["objectscript.export", "Export settings configured")
    }
}

/// Test that README.md contains required sections
Method TestReadmeContent()
{
    Set readmeFile = "README.md"
    Do $$$AssertTrue(##class(%File).Exists(readmeFile), "README.md exists")
    
    If ##class(%File).Exists(readmeFile) {
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set sc = stream.LinkToFile(readmeFile)
        Do $$$AssertStatusOK(sc, "Can read README.md")
        
        Set content = stream.Read()
        
        // Check for required sections
        Do $$$AssertTrue(content["# ObjectScript Design Patterns", "Project title present")
        Do $$$AssertTrue(content["## Features", "Features section present")
        Do $$$AssertTrue(content["## Quick Start", "Quick Start section present")
        Do $$$AssertTrue(content["## Pattern Categories", "Pattern Categories section present")
        Do $$$AssertTrue(content["## Installation", "Installation section present")
        Do $$$AssertTrue(content["## Contributing", "Contributing section present")
        Do $$$AssertTrue(content["## License", "License section present")
    }
}

/// Test Git configuration
Method TestGitConfiguration()
{
    Set gitignoreFile = ".gitignore"
    Do $$$AssertTrue(##class(%File).Exists(gitignoreFile), ".gitignore exists")
    
    If ##class(%File).Exists(gitignoreFile) {
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set sc = stream.LinkToFile(gitignoreFile)
        Do $$$AssertStatusOK(sc, "Can read .gitignore")
        
        Set content = stream.Read()
        
        // Check for IRIS-specific entries
        Do $$$AssertTrue(content["iris.key", "iris.key ignored")
        Do $$$AssertTrue(content["*.log", "Log files ignored")
        Do $$$AssertTrue(content["*.DAT", "DAT files ignored")
        Do $$$AssertTrue(content["node_modules", "node_modules ignored")
        Do $$$AssertTrue(content[".vscode-server", "VS Code server files ignored")
    }
}

/// Test license file
Method TestLicenseFile()
{
    Set licenseFile = "LICENSE"
    Do $$$AssertTrue(##class(%File).Exists(licenseFile), "LICENSE file exists")
    
    If ##class(%File).Exists(licenseFile) {
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set sc = stream.LinkToFile(licenseFile)
        Do $$$AssertStatusOK(sc, "Can read LICENSE")
        
        Set content = stream.Read()
        
        // Check it's MIT License
        Do $$$AssertTrue(content["MIT License", "MIT License header present")
        Do $$$AssertTrue(content["2024", "Copyright year present")
    }
}

/// Test EditorConfig file
Method TestEditorConfig()
{
    Set editorConfigFile = ".editorconfig"
    Do $$$AssertTrue(##class(%File).Exists(editorConfigFile), ".editorconfig exists")
    
    If ##class(%File).Exists(editorConfigFile) {
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set sc = stream.LinkToFile(editorConfigFile)
        Do $$$AssertStatusOK(sc, "Can read .editorconfig")
        
        Set content = stream.Read()
        
        // Check for ObjectScript configuration
        Do $$$AssertTrue(content["[*.{cls,mac,int,inc}]", "ObjectScript file patterns configured")
        Do $$$AssertTrue(content["indent_size = 4", "Indent size set to 4")
        Do $$$AssertTrue(content["charset = utf-8", "UTF-8 charset configured")
    }
}

}
