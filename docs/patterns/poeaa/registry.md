# Registry Pattern

## Intent
Provide a well-known object for accessing common objects and services throughout an application without passing references through multiple layers.

## Also Known As
- Service Locator (when used for services)
- Global Object Repository

## Motivation
In complex applications, certain objects need to be accessed from various parts of the system. Rather than passing these objects through constructor chains or method parameters, a Registry provides centralized access to commonly used objects and services.

In healthcare applications, services like `PatientService`, `EncounterService`, and `BillingService` often need to be accessed from multiple layers. A Registry eliminates the need for dependency injection chains while maintaining loose coupling.

## Applicability
Use the Registry pattern when:
- Multiple parts of your application need access to the same services or objects
- Passing objects through constructor chains becomes cumbersome
- You need different scopes for object lifetime (global, session, request)
- You want to centralize configuration of well-known services
- You need a simple alternative to dependency injection containers

## Structure

### Class Diagram
```
┌─────────────────────────┐
│      Registry           │
├─────────────────────────┤
│ - Scope: String         │
├─────────────────────────┤
│ + GetInstance()         │
│ + Set(key, object)      │
│ + Get(key)              │
│ + Contains(key)         │
│ + Remove(key)           │
│ + Clear()               │
│ + GetCount()            │
│ + GetKeys()             │
└─────────────────────────┘
         △
         │
         │ extends
         │
┌────────────────────────────────┐
│ HealthcareServiceRegistry      │
├────────────────────────────────┤
│ + GetPatientService()          │
│ + GetEncounterService()        │
│ + GetBillingService()          │
│ + ValidateServices()           │
└────────────────────────────────┘
```

### Participants
- **Registry**: Base class providing registration and lookup operations
- **HealthcareServiceRegistry**: Domain-specific registry with convenience methods
- **Services**: Objects registered in the registry (PatientService, EncounterService, etc.)

## Implementation

### ObjectScript Implementation

```objectscript
/// Base Registry - stores objects in Process Private Globals (PPG)
Class Patterns.PoEAA.Base.Registry Extends %RegisteredObject
{
    Property Scope As %String;
    
    /// Get global registry instance
    ClassMethod GetInstance() As Registry {
        Quit ..%New("Global")
    }
    
    /// Register an object
    Method Set(pKey As %String, pValue As %RegisteredObject) As %Status {
        Set ^||Patterns.Registry.Data(..Scope, pKey) = pValue
        Quit $$$OK
    }
    
    /// Retrieve an object
    Method Get(pKey As %String) As %RegisteredObject {
        Quit $Get(^||Patterns.Registry.Data(..Scope, pKey))
    }
}

/// Healthcare-specific registry with convenience methods
Class HealthcareServiceRegistry Extends Registry
{
    ClassMethod GetPatientService() As PatientService {
        Set registry = ..GetInstance()
        Quit registry.Get("PatientService")
    }
}
```

### Key Implementation Points

1. **Lightweight Instances**: Each instance is lightweight; data is stored in shared PPG storage
2. **Scoped Access**: Supports Global, Session, and Request scopes
3. **Unique Instances**: Instances created via `%New()` get unique scopes for independence
4. **Named Scopes**: Class methods like `GetInstance()` use named scopes for sharing

### ObjectScript Limitations

**IMPORTANT**: ObjectScript has documented limitations with storing %RegisteredObject instances in globals:
- Objects stored in globals are serialized, which may affect object identity
- For production use, consider:
  - Storing object IDs and recreating objects on retrieval
  - Using %Persistent classes for objects that need to be stored
  - Accepting that retrieved objects may be copies, not references

## Sample Code

### Basic Usage
```objectscript
// Create registry and register objects
Set registry = ##class(Registry).GetInstance()
Set service = ##class(PatientService).%New()
Do registry.Set("PatientService", service)

// Retrieve from anywhere in application
Set registry = ##class(Registry).GetInstance()
Set service = registry.Get("PatientService")
Do service.ProcessPatient(patientId)
```

### Healthcare Registry Example
```objectscript
// Access well-known services through convenience methods
Set patientService = ##class(HealthcareServiceRegistry).GetPatientService()
Set encounterService = ##class(HealthcareServiceRegistry).GetEncounterService()

// Use services
Do patientService.AdmitPatient(patientId, departmentId)
Do encounterService.CreateEncounter(patientId, encounterType)
```

### Scoped Registries
```objectscript
// Global scope - shared across application
Set global = ##class(Registry).GetInstance()

// Session scope - per user session
Set session = ##class(Registry).CreateSessionRegistry()

// Request scope - per HTTP request
Set request = ##class(Registry).CreateRequestRegistry()

// Each scope maintains independent data
Do global.Set("Config", globalConfig)
Do session.Set("UserPrefs", userPrefs)
Do request.Set("Context", requestContext)
```

## Consequences

### Benefits
1. **Decoupling**: Eliminates need for dependency injection chains
2. **Global Access**: Well-known objects accessible from anywhere
3. **Flexible Scoping**: Supports multiple object lifetimes (global, session, request)
4. **Simple API**: Easy to understand and use
5. **Type Safety**: Can provide typed convenience methods
6. **Performance**: O(1) lookup in Process Private Globals

### Liabilities
1. **Global State**: Can make testing more difficult
2. **Hidden Dependencies**: Dependencies not visible in constructor/method signatures
3. **Object Serialization**: ObjectScript may serialize objects stored in globals
4. **Cleanup Required**: Must clear registry state between tests
5. **Tight Coupling**: Application becomes coupled to registry interface

## Known Uses
- **Service Locator Pattern**: Microsoft's Unity, Spring Framework
- **OSGi Service Registry**: Dynamic service registration and lookup
- **JNDI**: Java Naming and Directory Interface for resource lookup
- **Healthcare Systems**: Centralized access to clinical services

## Related Patterns
- **Singleton**: Registry often implemented as singleton
- **Service Locator**: Specialized registry for services
- **Dependency Injection**: Alternative approach to providing dependencies
- **Factory**: Registry can store and retrieve factories
- **Lazy Load**: Can combine with registry for lazy service initialization

## Testing Considerations

### Test Setup/Teardown
```objectscript
Method OnBeforeOneTest() As %Status {
    // Clear registry state
    Kill ^||Patterns.Registry.Data
    Quit $$$OK
}
```

### Test Independence
```objectscript
// Each test gets independent registry
Set registry1 = ##class(Registry).%New()  // Unique scope
Set registry2 = ##class(Registry).%New()  // Different unique scope
```

### Healthcare Registry Testing
```objectscript
Method TestServiceAccess() {
    Set registry = ##class(HealthcareServiceRegistry).GetInstance()
    Set patientService = ##class(HealthcareServiceRegistry).GetPatientService()
    Do $$$AssertTrue($IsObject(patientService), "Should return service object")
}
```

## References
- Martin Fowler, "Patterns of Enterprise Application Architecture" (2002)
- Microsoft Application Architecture Guide
- InterSystems ObjectScript Documentation on Process Private Globals

## See Also
- [Identity Map Pattern](identity-map.md) - Ensures loaded objects are unique
- [Unit of Work Pattern](../data-source/unit-of-work.md) - Manages object changes
- [Lazy Load Pattern](lazy-load.md) - Defers object loading
