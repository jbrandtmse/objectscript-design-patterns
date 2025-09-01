# Getting Started with ObjectScript Design Patterns Library

Welcome to the ObjectScript Design Patterns Library! This guide will help you get up and running quickly with the library.

## Prerequisites

Before you begin, ensure you have the following installed:

- **InterSystems IRIS 2023.1 or higher** - The platform for running ObjectScript
- **Git** - For cloning the repository
- **VS Code with ObjectScript Extension** (recommended) - For development

## Quick Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/objectscript-design-patterns.git
cd objectscript-design-patterns
```

### 2. Import Classes into IRIS

Connect to your IRIS instance and import the classes:

```objectscript
// Import all pattern classes
Do $System.OBJ.LoadDir("/path/to/objectscript-design-patterns/src", "ck", .errors, 1)

// Check for any errors
If $Data(errors) {
    Write "Import errors occurred:", !
    Set key = ""
    For {
        Set key = $Order(errors(key))
        Quit:key=""
        Write errors(key), !
    }
} Else {
    Write "Import successful!", !
}
```

### 3. Verify Installation

Run a simple test to verify the installation:

```objectscript
// Test that the pattern registry is accessible
If ##class(Patterns.Registry.Manager).%ExistsId(1) {
    Write "Pattern Registry is available", !
} Else {
    Write "Creating Pattern Registry...", !
    Set registry = ##class(Patterns.Registry.Manager).%New()
    Do registry.Initialize()
}
```

## Your First Pattern

Let's try using the Singleton pattern as your first example:

```objectscript
// Example: Using the Singleton Pattern
Class MyApp.Configuration Extends Patterns.GoF.Creational.Singleton
{
    Property DatabaseURL As %String;
    Property MaxConnections As %Integer;
    
    Method LoadConfiguration() As %Status
    {
        // Load your configuration here
        Set ..DatabaseURL = "iris://localhost:1972/USER"
        Set ..MaxConnections = 10
        Return $$$OK
    }
}

// Using the singleton
Set config = ##class(MyApp.Configuration).GetInstance()
Do config.LoadConfiguration()
Write "Database URL: ", config.DatabaseURL, !
```

## Exploring Available Patterns

### List All Patterns

```objectscript
// Get list of all available patterns
Set registry = ##class(Patterns.Registry.Manager).GetInstance()
Do registry.ListPatterns()
```

### Get Pattern Information

```objectscript
// Get information about a specific pattern
Set patternInfo = registry.GetPatternInfo("Singleton")
Write "Pattern: ", patternInfo.Name, !
Write "Category: ", patternInfo.Category, !
Write "Intent: ", patternInfo.Intent, !
```

## Common Use Cases

### 1. Factory Pattern for Object Creation

```objectscript
// Define your product interface
Class MyApp.IProduct [ Abstract ]
{
    Method Process() [ Abstract ]
}

// Concrete products
Class MyApp.ProductA Extends MyApp.IProduct
{
    Method Process()
    {
        Write "Processing Product A", !
    }
}

// Use factory to create products
Set factory = ##class(Patterns.GoF.Creational.Factory).%New()
Set product = factory.CreateProduct("TypeA")
Do product.Process()
```

### 2. Observer Pattern for Event Handling

```objectscript
// Create a subject
Set subject = ##class(Patterns.GoF.Behavioral.Observer.Subject).%New()

// Create observers
Set emailNotifier = ##class(MyApp.EmailObserver).%New()
Set logObserver = ##class(MyApp.LogObserver).%New()

// Attach observers
Do subject.Attach(emailNotifier)
Do subject.Attach(logObserver)

// Trigger notification
Do subject.SetState("Order Completed")
Do subject.Notify()  // All observers are notified
```

### 3. Repository Pattern for Data Access

```objectscript
// Use repository for data access
Set userRepo = ##class(Patterns.PoEAA.DataSource.Repository).%New("User")

// Find users
Set users = userRepo.FindByAge(25, 35)
While users.%Next() {
    Set user = users.%Get()
    Write "User: ", user.Name, " Age: ", user.Age, !
}
```

## Best Practices

1. **Choose the Right Pattern**: Not every problem needs a design pattern. Use them when they provide clear benefits.

2. **Keep It Simple**: Start with simpler patterns (Singleton, Factory) before moving to complex ones (Abstract Factory, Visitor).

3. **Document Your Usage**: When implementing a pattern, document why you chose it and how it solves your specific problem.

4. **Test Thoroughly**: Each pattern implementation should have comprehensive tests.

5. **Follow Naming Conventions**: Use clear, descriptive names that indicate pattern usage (e.g., `UserFactory`, `OrderObserver`).

## Learning Path

We recommend learning the patterns in this order:

### Beginner
1. Singleton - Single instance management
2. Factory Method - Object creation
3. Observer - Event handling
4. Strategy - Algorithm selection

### Intermediate
5. Decorator - Adding functionality
6. Adapter - Interface compatibility
7. Command - Request encapsulation
8. Iterator - Collection traversal

### Advanced
9. Abstract Factory - Family creation
10. Visitor - Operations on object structures
11. Chain of Responsibility - Request handling
12. Unit of Work - Transaction management

## Getting Help

### Documentation
- [Pattern Catalog](../patterns/) - Detailed documentation for each pattern
- [API Reference](../api/) - Complete API documentation
- [Examples](../../examples/) - Working examples for each pattern

### Community
- GitHub Issues: Report bugs or request features
- Discussions: Ask questions and share experiences
- Wiki: Community-contributed guides and tips

## Next Steps

Now that you're set up, you can:

1. **Explore the Examples**: Check out the `/examples` directory for real-world usage
2. **Read Pattern Documentation**: Deep dive into specific patterns in `/docs/patterns`
3. **Run the Test Suite**: Execute tests to see patterns in action
4. **Start Implementing**: Use patterns in your own ObjectScript projects

## Troubleshooting

### Common Issues

**Import Errors**: Ensure your IRIS instance has sufficient privileges and the correct namespace is selected.

**Class Not Found**: Verify all dependencies are imported and the namespace mappings are correct.

**Version Compatibility**: This library requires IRIS 2023.1+. Check your version with:
```objectscript
Write $System.Version.GetVersion()
```

For more help, see our [Installation Guide](installation.md) or open an issue on GitHub.
