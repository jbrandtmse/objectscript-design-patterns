# Coding Standards

### ObjectScript Coding Conventions

The ObjectScript Design Patterns Library follows the comprehensive coding standards defined in **[Object Script Coding Standards.md](Object%20Script%20Coding%20Standards.md)**. This document provides detailed guidelines for all ObjectScript development within the project.

The standards ensure consistency, readability, and maintainability across all pattern implementations. Key areas covered include:

### Naming Conventions

**IMPORTANT:** All naming conventions must follow the standards defined in **[Object Script Coding Standards.md](Object%20Script%20Coding%20Standards.md)**, Section "Naming Conventions and Syntax". The key conventions are:

**Classes:**
- Use PascalCase: `PatternRegistry`, `SingletonFactory`
- Prefix with namespace: `Patterns.GoF.Creational.Singleton`
- Descriptive names indicating purpose
- Follow the detailed class naming rules in the standards document

**Methods:**
- Use PascalCase for public methods: `CreateInstance()`, `GetPattern()`
- Use camelCase for private methods: `validateInput()`, `initializeState()`
- Begin with verb indicating action
- Additional method naming guidelines in the standards document

**Properties:**
- Use PascalCase: `PatternName`, `InstanceCount`
- Boolean properties prefix with `Is`, `Has`, `Can`: `IsInitialized`, `HasDependencies`
- See standards document for complete property naming rules

**Parameters:**
- Prefix with 'p': `pPatternName`, `pConfiguration`
- Use descriptive names: `pMaxRetries` not `pMR`
- Refer to standards document for parameter conventions

**Variables:**
- Use camelCase: `patternInstance`, `errorCount`
- Meaningful names: `currentState` not `cs`
- Loop counters: `i`, `j`, `k` for simple loops
- Complete variable naming rules in the standards document

**Constants:**
- Use UPPERCASE with underscores: `MAX_INSTANCES`, `DEFAULT_TIMEOUT`
- Define as macros or parameters
- See standards document for macro conventions

**Globals:**
- Prefix with pattern namespace: `^Patterns.Registry`, `^Patterns.Config`
- Use dot notation for structure: `^Patterns.Registry("GoF", "Singleton")`
- Follow global naming patterns in the standards document

### Code Organization

**Note:** The complete code organization standards are defined in **[Object Script Coding Standards.md](Object%20Script%20Coding%20Standards.md)**, Section "Code Organization and Structure". 

**Class Structure Template:**
```objectscript
/// Description of the class purpose
Class Patterns.Category.PatternName Extends %RegisteredObject
{
    // ===== PARAMETERS =====
    Parameter VERSION = "1.0.0";
    Parameter PATTERN_TYPE = "Behavioral";
    
    // ===== PROPERTIES =====
    /// Public properties
    Property PublicProperty As %String;
    
    /// Private properties (prefix with %)
    Property %PrivateProperty As %Integer [ Private ];
    
    // ===== INDICES =====
    Index NameIndex On Name;
    
    // ===== CONSTRUCTORS/DESTRUCTORS =====
    Method %OnNew(pParam As %String) As %Status
    {
        // Initialization logic
        Return $$$OK
    }
    
    // ===== PUBLIC METHODS =====
    /// Main execution method
    Method Execute() As %Status
    {
        // Implementation
        Return $$$OK
    }
    
    // ===== PRIVATE METHODS =====
    Method validateInput(pInput As %String) As %Boolean [ Private ]
    {
        // Validation logic
        Return 1
    }
    
    // ===== CLASS METHODS =====
    ClassMethod GetInstance() As PatternName
    {
        // Static method implementation
        Return ##class(PatternName).%New()
    }
}
```

### Documentation Standards

**Class Documentation:**
```objectscript
/// Gang of Four Singleton Pattern Implementation
/// 
/// Intent:
/// Ensure a class has only one instance and provide a global point of access to it.
/// 
/// Applicability:
/// - There must be exactly one instance of a class
/// - The instance must be accessible from a well-known access point
/// 
/// Structure:
/// <example>
/// Set singleton = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
/// </example>
/// 
/// @see Patterns.GoF.Creational.Factory
/// @since 1.0.0
Class Patterns.GoF.Creational.Singleton
```

**Method Documentation:**
```objectscript
/// Creates a new instance of the pattern
/// 
/// @param pConfiguration Configuration object for pattern initialization
/// @param pOptions Additional options as JSON string
/// @return Instance of the pattern or null on error
/// @throws Patterns.Errors.ConfigurationException if configuration is invalid
/// 
/// Example:
/// <example>
/// Set config = {"maxInstances": 5, "timeout": 30}
/// Set instance = ##class(Pattern).CreateInstance(config)
/// </example>
Method CreateInstance(pConfiguration As %DynamicObject, pOptions As %String = "") As Pattern
```

### Code Quality Rules

**Note:** Comprehensive code quality standards are defined in **[Object Script Coding Standards.md](Object%20Script%20Coding%20Standards.md)**, including SQL standards, error handling patterns, and performance guidelines.

**1. Method Length:**
- Keep methods under 50 lines (as per standards document)
- Extract complex logic into helper methods
- Single responsibility per method
- Follow the "Code Organization and Structure" section in the standards

**2. Class Cohesion:**
- High cohesion within classes
- Related functionality grouped together
- Minimal coupling between classes
- Adhere to the design principles in the standards document

**3. Error Handling:**
```objectscript
Method SafeExecute() As %Status
{
    Set sc = $$$OK
    Set errorOccurred = 0
    
    Try {
        // Validate inputs
        If '..ValidateInputs() {
            Set sc = $$$ERROR($$$GeneralError, "Invalid inputs")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        }
        
        // Main logic
        Set sc = ..ProcessData()
        
    } Catch ex {
        Set errorOccurred = 1
        Set sc = ex.AsStatus()
        Do ##class(Patterns.Utils.Logger).LogError(..%ClassName(1), ex.Name, ex.Code)
    }
    
    // Cleanup regardless of success/failure
    Do ..Cleanup()
    
    Return sc
}
```

**4. Performance Considerations:**
```objectscript
// GOOD: Use $DATA to check existence
If $DATA(^Global(key)) {
    Set value = ^Global(key)
}

// BAD: Accessing twice
If (^Global(key) '= "") {
    Set value = ^Global(key)
}

// GOOD: Use $INCREMENT for atomic operations
Set id = $INCREMENT(^Counter)

// BAD: Non-atomic increment
Set ^Counter = ^Counter + 1
Set id = ^Counter
```

### Testing Standards

**Note:** Testing standards are comprehensively defined in **[Object Script Coding Standards.md](Object%20Script%20Coding%20Standards.md)**, Section "Unit Testing Standards".

**Test Class Naming:**
- Suffix with `Test`: `SingletonTest`, `FactoryPatternTest`
- Mirror source structure in test namespace
- Follow the unit testing naming conventions in the standards document

**Test Method Naming:**
- Prefix with `Test`: `TestCreateInstance()`, `TestErrorHandling()`
- Descriptive of what is being tested
- Adhere to the test method patterns in the standards document

**Test Structure:**
```objectscript
Method TestPatternBehavior() As %Boolean
{
    // Arrange
    Set pattern = ##class(Pattern).%New()
    Set expectedResult = "Success"
    
    // Act
    Set actualResult = pattern.Execute()
    
    // Assert
    Do ..AssertEquals(actualResult, expectedResult, "Pattern should return success")
    
    // Cleanup
    Do pattern.%Close()
    
    Return 1
}
```

### Security Standards

**Note:** Security implementation must follow the guidelines in **[Object Script Coding Standards.md](Object%20Script%20Coding%20Standards.md)**, Section "Security Considerations".

1. **Never hardcode credentials** - Use secure configuration (see standards document)
2. **Validate all inputs** - Prevent injection attacks (validation patterns in standards)
3. **Use parameterized queries** - Avoid SQL injection (SQL standards section)
4. **Implement access controls** - Check permissions (security section in standards)
5. **Sanitize error messages** - Don't expose internals (error handling in standards)
6. **Audit sensitive operations** - Log security events (logging standards section)

### Performance Guidelines

**Note:** Performance optimization should follow the guidelines in **[Object Script Coding Standards.md](Object%20Script%20Coding%20Standards.md)**, Section "Performance Considerations".

1. **Cache frequently accessed data** in properties (caching patterns in standards)
2. **Use indices** for faster lookups (indexing guidelines in standards)
3. **Minimize global references** in loops (global access patterns in standards)
4. **Use transactions** for atomic operations (transaction guidelines in standards)
5. **Implement lazy loading** for expensive operations (performance section)
6. **Profile code** to identify bottlenecks (profiling tools in standards)
7. **Use embedded SQL** for set operations (SQL performance in standards)
8. **Avoid recursive global kills** (global management in standards)

### Code Review Checklist

**Note:** Code reviews must verify compliance with **[Object Script Coding Standards.md](Object%20Script%20Coding%20Standards.md)**.

- [ ] Follows naming conventions (per standards document)
- [ ] Properly documented (documentation standards section)
- [ ] Error handling implemented (error handling patterns in standards)
- [ ] Unit tests written (unit testing standards section)
- [ ] No hardcoded values (best practices in standards)
- [ ] Performance optimized (performance considerations in standards)
- [ ] Security considered (security section in standards)
- [ ] No code duplication (code organization in standards)
- [ ] Meets pattern requirements
- [ ] Compatible with IRIS 2023.1+
- [ ] Complies with all sections of the Object Script Coding Standards document
