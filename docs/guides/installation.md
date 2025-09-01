# Installation Guide

This guide provides detailed instructions for installing and configuring the ObjectScript Design Patterns Library in your InterSystems IRIS environment.

## System Requirements

### Minimum Requirements
- **InterSystems IRIS**: Version 2023.1 or higher
- **Operating System**: Windows, Linux, or macOS
- **Memory**: 4GB RAM minimum (8GB recommended)
- **Disk Space**: 100MB for pattern library files
- **Network**: Internet connection for downloading dependencies

### Development Tools
- **VS Code** with InterSystems ObjectScript Extension (recommended)
- **Git** for version control
- **Docker** (optional) for containerized development

## Installation Methods

### Method 1: Direct Import (Recommended)

#### Step 1: Download the Repository

```bash
# Clone via HTTPS
git clone https://github.com/yourusername/objectscript-design-patterns.git

# Or download as ZIP from GitHub and extract
```

#### Step 2: Connect to IRIS

Using IRIS Terminal:
```objectscript
// Switch to desired namespace
ZN "USER"

// Or create a new namespace
Do ##class(Config.Namespaces).Create("PATTERNS", "PATTERNS")
```

#### Step 3: Import Source Files

```objectscript
// Import all classes with compile
Set dir = "C:/path/to/objectscript-design-patterns/src"
Do $System.OBJ.LoadDir(dir, "ck", .errors, 1)

// Check for errors
If $Data(errors) {
    Write "Errors during import:", !
    Set key = ""
    For {
        Set key = $Order(errors(key))
        Quit:key=""
        Write key, ": ", errors(key), !
    }
} Else {
    Write "Import successful!", !
}
```

### Method 2: Using InterSystems Package Manager (ZPM)

```objectscript
// Install ZPM if not already installed
zpm "install objectscript-design-patterns"
```

### Method 3: VS Code Integration

1. Open VS Code
2. Install InterSystems ObjectScript Extension
3. Configure connection to IRIS:

```json
// .vscode/settings.json
{
    "objectscript.conn": {
        "server": "localhost",
        "port": 1972,
        "ns": "PATTERNS",
        "username": "your-username",
        "password": "your-password",
        "active": true
    }
}
```

4. Open Command Palette (Ctrl/Cmd + Shift + P)
5. Run "ObjectScript: Import Current File" for each source file

### Method 4: Docker Installation

```bash
# Build the Docker image
cd objectscript-design-patterns
docker build -t iris-patterns .

# Run the container
docker run -d \
  --name iris-patterns \
  -p 52773:52773 \
  -p 1972:1972 \
  iris-patterns

# Import patterns into running container
docker exec iris-patterns iris session iris -U PATTERNS < import-script.cos
```

## Namespace Configuration

### Creating Dedicated Namespaces

```objectscript
// Create production namespace
Set props("Globals") = "PATTERNS"
Set props("Routines") = "PATTERNS"
Do ##class(Config.Namespaces).Create("PATTERNS", .props)

// Create test namespace
Set props("Globals") = "PATTERNS-TEST"
Set props("Routines") = "PATTERNS-TEST"
Do ##class(Config.Namespaces).Create("PATTERNS-TEST", .props)
```

### Setting Up Global Mappings

```objectscript
// Map pattern registry global
Do ##class(Config.MapGlobals).Create("PATTERNS", "Patterns.Registry", "PATTERNS")
Do ##class(Config.MapGlobals).Create("PATTERNS", "Patterns.Config", "PATTERNS")
```

### Package Mappings

```objectscript
// Map Patterns package to other namespaces if needed
Do ##class(Config.MapPackages).Create("USER", "Patterns", "PATTERNS")
```

## Verification Steps

### 1. Verify Class Compilation

```objectscript
// Check if classes are compiled
Do $System.OBJ.CompilePackage("Patterns", "ck")

// List all pattern classes
Do $System.OBJ.ShowClasses("Patterns.*")
```

### 2. Run Installation Tests

```objectscript
// Run basic verification
Set sc = ##class(Patterns.Utils.Validator).VerifyInstallation()
If $$$ISOK(sc) {
    Write "Installation verified successfully!", !
} Else {
    Do $System.Status.DisplayError(sc)
}
```

### 3. Initialize Pattern Registry

```objectscript
// Initialize the pattern registry
Set registry = ##class(Patterns.Registry.Manager).GetInstance()
Do registry.Initialize()
Do registry.LoadPatterns()

// Verify patterns are loaded
Write "Loaded patterns: ", registry.GetPatternCount(), !
```

## Environment-Specific Setup

### Development Environment

```objectscript
// Enable development mode
Set ^Patterns.Config("Environment") = "Development"
Set ^Patterns.Config("Debug") = 1
Set ^Patterns.Config("LogLevel") = "TRACE"
```

### Production Environment

```objectscript
// Configure for production
Set ^Patterns.Config("Environment") = "Production"
Set ^Patterns.Config("Debug") = 0
Set ^Patterns.Config("LogLevel") = "ERROR"
Set ^Patterns.Config("CacheEnabled") = 1
```

### Testing Environment

```objectscript
// Configure for testing
Set ^Patterns.Config("Environment") = "Testing"
Set ^Patterns.Config("Debug") = 1
Set ^Patterns.Config("LogLevel") = "DEBUG"
Set ^Patterns.Config("MockData") = 1
```

## IDE Configuration

### VS Code Setup

1. Install required extensions:
   - InterSystems ObjectScript
   - InterSystems Language Server

2. Configure workspace settings:

```json
// objectscript-design-patterns.code-workspace
{
    "folders": [{
        "path": ".",
        "name": "ObjectScript Design Patterns"
    }],
    "settings": {
        "objectscript.conn": {
            "server": "localhost",
            "port": 1972,
            "ns": "PATTERNS",
            "active": true
        },
        "objectscript.export": {
            "folder": "src",
            "addCategory": true,
            "map": {
                "Patterns.GoF.*": "Patterns/GoF/",
                "Patterns.PoEAA.*": "Patterns/PoEAA/"
            }
        }
    }
}
```

### InterSystems Studio Setup

1. Open Studio
2. Connect to IRIS instance
3. Switch to PATTERNS namespace
4. Import from local files:
   - File → Import Local → Select src directory

## Post-Installation Tasks

### 1. Configure Security

```objectscript
// Create application role
Do ##class(Security.Roles).Create("PatternUser", .props)

// Grant permissions
Do ##class(Security.Roles).AddResource("PatternUser", "%DB_PATTERNS", "RW")
```

### 2. Set Up Scheduled Tasks

```objectscript
// Create task for pattern metrics collection
Set task = ##class(%SYS.Task).%New()
Set task.Name = "Pattern Metrics Collection"
Set task.TaskClass = "Patterns.Utils.MetricsCollector"
Set task.RunAsUser = "_SYSTEM"
Set task.TimePeriod = 0  // Daily
Set task.DailyStartTime = 3600  // 1 AM
Do task.%Save()
```

### 3. Initialize Example Data

```objectscript
// Load example data for demonstrations
Do ##class(Patterns.Examples.DataLoader).LoadExampleData()
```

## Troubleshooting

### Common Installation Issues

#### Issue: "Class does not exist" errors
**Solution**: Ensure all dependencies are imported in the correct order:
```objectscript
// Import in dependency order
Do $System.OBJ.Load("/path/to/src/includes/PatternMacros.inc", "ck")
Do $System.OBJ.LoadDir("/path/to/src/Patterns/Utils", "ck")
Do $System.OBJ.LoadDir("/path/to/src/Patterns", "ck", .errors, 1)
```

#### Issue: "Permission denied" errors
**Solution**: Grant appropriate permissions:
```objectscript
// Grant database access
Do ##class(Security.Users).AddResource(username, "%DB_PATTERNS", "RW")
```

#### Issue: Compilation errors
**Solution**: Check IRIS version compatibility:
```objectscript
Write "IRIS Version: ", $System.Version.GetVersion(), !
// Ensure version is 2023.1 or higher
```

#### Issue: Namespace not found
**Solution**: Create namespace before import:
```objectscript
Do ##class(Config.Namespaces).Exists("PATTERNS", .exists)
If 'exists {
    Do ##class(Config.Namespaces).Create("PATTERNS")
}
```

## Uninstallation

To remove the pattern library:

```objectscript
// Delete all pattern classes
Do $System.OBJ.DeletePackage("Patterns")

// Remove globals
Kill ^Patterns.Registry
Kill ^Patterns.Config

// Remove namespace (optional)
Do ##class(Config.Namespaces).Delete("PATTERNS")
```

## Getting Support

If you encounter issues during installation:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review [GitHub Issues](https://github.com/yourusername/objectscript-design-patterns/issues)
3. Post a question in [Discussions](https://github.com/yourusername/objectscript-design-patterns/discussions)
4. Contact the InterSystems Developer Community

## Next Steps

After successful installation:

1. Read the [Getting Started Guide](getting-started.md)
2. Explore pattern examples in `/examples` directory
3. Run the test suite to verify functionality
4. Start implementing patterns in your projects

## Version Compatibility Matrix

| Library Version | IRIS Version | ObjectScript Version |
|----------------|--------------|---------------------|
| 1.0.x          | 2023.1+      | 2023.1+            |
| 1.1.x          | 2023.2+      | 2023.2+            |
| 2.0.x          | 2024.1+      | 2024.1+            |

---

For the latest installation instructions, visit the [GitHub repository](https://github.com/yourusername/objectscript-design-patterns).
