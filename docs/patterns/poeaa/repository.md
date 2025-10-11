# Repository Pattern

**Category:** Patterns of Enterprise Application Architecture (PoEAA)  
**Type:** Object-Relational Behavioral  
**Source:** Martin Fowler's "Patterns of Enterprise Application Architecture"

## Intent

Mediates between the domain and data mapping layers using a collection-like interface for accessing domain objects. The Repository pattern encapsulates the logic of accessing data sources and provides a more object-oriented view of the persistence layer.

## Also Known As

- Collection Interface for Data Access
- Domain Object Collections

## Motivation

In a domain-driven design, the domain layer contains rich business logic and should remain independent of infrastructure concerns like database access. However, domain objects need to be persisted and retrieved. Writing database access code directly in the domain layer couples it to the persistence mechanism and makes testing difficult.

The Repository pattern solves this by providing a collection-like interface to the domain layer. From the domain's perspective, the repository looks like an in-memory collection of objects. The repository handles all the details of accessing the database, executing queries, and managing object identity.

### Problem

Without the Repository pattern:
- Domain code is coupled to database access details
- Query logic is scattered throughout the application
- Testing domain logic requires a real database
- Duplicate object loads can occur
- Complex queries are difficult to reuse

### Solution

The Repository pattern:
- Provides a collection-like interface for domain objects
- Encapsulates all database access logic
- Uses Data Mapper for persistence operations
- Integrates Identity Map to prevent duplicate loads
- Supports flexible query specifications
- Enables easy testing with mock repositories

## Applicability

Use the Repository pattern when:

- You're using domain-driven design
- Domain objects should be independent of persistence
- You need a collection-oriented interface to data
- Complex queries should be encapsulated and reusable
- You want to centralize data access logic
- Testing should be possible without a database

Don't use the Repository pattern when:

- You have a simple CRUD application
- Table-oriented data access is sufficient
- The overhead of the abstraction is not justified
- You're using Active Record pattern (conflicting approaches)

## Structure

### Class Diagram

```
┌─────────────────────────┐
│      Repository         │
│      (Abstract)         │
├─────────────────────────┤
│ + IdentityMap           │
│ + Mapper                │
├─────────────────────────┤
│ + Add(entity)           │
│ + Remove(entity)        │
│ + FindById(id)          │
│ + FindAll()             │
│ + FindBySpec(spec)      │
│ + Update(entity)        │
│ + Count()               │
│ + Contains(id)          │
├─────────────────────────┤
│ # GetEntityId(entity)   │◄────────┐
│ # FindBySQL(where)      │         │
└─────────────────────────┘         │
           △                         │
           │                         │
           │ extends                 │
           │                         │
┌─────────────────────────┐         │
│   PatientRepository     │         │
├─────────────────────────┤         │
│ + FindByMRN(mrn)        │         │
│ + FindActivePatients()  │         │
│ + FindByDepartment()    │         │
└─────────────────────────┘         │
           │                         │
           │ uses                    │
           ▼                         │
┌─────────────────────────┐         │
│     DataMapper          │         │
├─────────────────────────┤         │
│ + Insert(object)        │         │
│ + Update(object)        │         │
│ + Delete(object)        │         │
│ + Find(id)              │         │
│ + FindAll()             │         │
└─────────────────────────┘         │
                                    │
┌─────────────────────────┐         │
│    IdentityMap          │◄────────┘
├─────────────────────────┤
│ + Add(id, object)       │
│ + Get(id)               │
│ + Contains(id)          │
│ + Remove(id)            │
└─────────────────────────┘

┌─────────────────────────┐
│    Specification        │
│      (Abstract)         │
├─────────────────────────┤
│ + ToSQL()               │
│ + IsSatisfiedBy(obj)    │
│ + And(spec)             │
│ + Or(spec)              │
│ + Not()                 │
└─────────────────────────┘
           △
           │
           ├──────────────────┬─────────────────┐
           │                  │                 │
┌─────────────────┐  ┌──────────────┐  ┌─────────────┐
│ ActivePatient   │  │ ByDepartment │  │  ByStatus   │
│ Specification   │  │Specification │  │Specification│
└─────────────────┘  └──────────────┘  └─────────────┘
```

### Participants

**Repository (Abstract)**
- Defines collection interface for domain objects
- Manages Identity Map for caching
- Delegates persistence to Data Mapper
- Provides query specification support

**Concrete Repository (e.g., PatientRepository)**
- Implements abstract methods
- Provides domain-specific finders
- Configures appropriate Data Mapper

**Specification**
- Encapsulates query criteria
- Converts to SQL or other query format
- Supports composition (AND, OR, NOT)

**Identity Map**
- Caches loaded objects
- Ensures single instance per ID
- Prevents duplicate database loads

**Data Mapper**
- Handles actual database operations
- Maps between domain objects and tables
- Executes SQL queries

## Implementation

### Repository Base Class

```objectscript
Class Patterns.PoEAA.ObjectRelational.Repository Extends %RegisteredObject [ Abstract ]
{
    Property IdentityMap As Patterns.PoEAA.ObjectRelational.IdentityMap;
    Property Mapper As Patterns.PoEAA.DataSource.DataMapper;
    
    Method Add(pEntity As %RegisteredObject) As %Status
    {
        Set tSC = ..Mapper.Insert(pEntity)
        If $$$ISOK(tSC) {
            Set tId = ..GetEntityId(pEntity)
            Do ..IdentityMap.Add(tId, pEntity)
        }
        Quit tSC
    }
    
    Method FindById(pId As %String) As %RegisteredObject
    {
        // Check cache first
        Set tEntity = ..IdentityMap.Get(pId)
        
        If '$IsObject(tEntity) {
            // Load from database
            Set tEntity = ..Mapper.Find(pId)
            If $IsObject(tEntity) {
                Do ..IdentityMap.Add(pId, tEntity)
            }
        }
        
        Quit tEntity
    }
    
    Method FindBySpecification(pSpec As Specification) As %ListOfObjects
    {
        Set tSQL = pSpec.ToSQL()
        Quit ..FindBySQL(tSQL)
    }
    
    Method GetEntityId(pEntity) As %String [ Abstract ]
    Method FindBySQL(pWhere) As %ListOfObjects [ Abstract ]
}
```

### Patient Repository Example

```objectscript
Class PatientRepository Extends Repository
{
    Method %OnNew() As %Status
    {
        Do ##super()
        Set ..Mapper = ##class(PatientMapper).%New()
        Quit $$$OK
    }
    
    Method FindByMRN(pMRN As %String) As Patient
    {
        Quit ..Mapper.FindByMRN(pMRN)
    }
    
    Method FindActivePatients() As %ListOfObjects
    {
        Set tSpec = ##class(ActivePatientSpec).%New()
        Quit ..FindBySpecification(tSpec)
    }
    
    Method GetEntityId(pEntity As Patient) As %String
    {
        Quit pEntity.%Id()
    }
    
    Method FindBySQL(pWhere As %String) As %ListOfObjects
    {
        Quit ..Mapper.FindBySQL(pWhere)
    }
}
```

### Specification Pattern

```objectscript
Class ActivePatientSpec Extends Specification
{
    Method ToSQL() As %String
    {
        Quit "Status = 'Active'"
    }
    
    Method IsSatisfiedBy(pPatient) As %Boolean
    {
        Quit (pPatient.Status = "Active")
    }
}

Class PatientByDepartmentSpec Extends Specification
{
    Property Department As %String;
    
    Method ToSQL() As %String
    {
        Quit "Department = '" _ ..Department _ "'"
    }
    
    Method IsSatisfiedBy(pPatient) As %Boolean
    {
        Quit (pPatient.Department = ..Department)
    }
}
```

## Sample Code

### Basic Repository Usage

```objectscript
// Create repository
Set repository = ##class(PatientRepository).%New()

// Add patient
Set patient = ##class(Patient).%New()
Set patient.FirstName = "John"
Set patient.LastName = "Doe"
Set patient.MRN = "MRN12345"
Set patient.Status = "Active"
Set patient.Department = "Cardiology"
Set sc = repository.Add(patient)

// Find by ID
Set foundPatient = repository.FindById(patient.%Id())

// Find by MRN
Set foundPatient = repository.FindByMRN("MRN12345")

// Update patient
Set patient.Status = "Discharged"
Set sc = repository.Update(patient)

// Remove patient
Set sc = repository.Remove(patient)
```

### Using Specifications

```objectscript
// Simple specification
Set spec = ##class(ActivePatientSpec).%New()
Set activePatients = repository.FindBySpecification(spec)

// Department specification
Set deptSpec = ##class(PatientByDepartmentSpec).%New()
Set deptSpec.Department = "Cardiology"
Set cardioPatients = repository.FindBySpecification(deptSpec)

// Combined specifications (AND)
Set activeSpec = ##class(ActivePatientSpec).%New()
Set deptSpec = ##class(PatientByDepartmentSpec).%New()
Set deptSpec.Department = "Cardiology"
Set combined = activeSpec.And(deptSpec)
Set activeCardioPatients = repository.FindBySpecification(combined)

// Complex queries (OR)
Set cardioSpec = ##class(PatientByDepartmentSpec).%New()
Set cardioSpec.Department = "Cardiology"
Set orthoSpec = ##class(PatientByDepartmentSpec).%New()
Set orthoSpec.Department = "Orthopedics"
Set eitherDept = cardioSpec.Or(orthoSpec)
Set patients = repository.FindBySpecification(eitherDept)
```

### Domain-Specific Finders

```objectscript
// Healthcare-specific finders
Set activePatients = repository.FindActivePatients()
Set cardioPatients = repository.FindPatientsByDepartment("Cardiology")
Set discharged = repository.FindPatientsByStatus("Discharged")

// Collection operations
Set count = repository.Count()
Set exists = repository.Contains(patientId)
Set allPatients = repository.FindAll()
```

## Consequences

### Benefits

1. **Separation of Concerns**: Domain logic separated from data access
2. **Testability**: Easy to mock repositories for testing
3. **Centralized Queries**: All data access logic in one place
4. **Reusable Specifications**: Query logic encapsulated and composable
5. **Identity Management**: Automatic prevention of duplicate loads
6. **Collection Semantics**: Natural object-oriented interface
7. **Flexibility**: Easy to change persistence implementation

### Liabilities

1. **Abstraction Overhead**: Additional layer of indirection
2. **Learning Curve**: More complex than direct database access
3. **Performance Concerns**: May need optimization for complex queries
4. **Repository Explosion**: Can lead to many repository classes
5. **Specification Complexity**: Complex queries can be difficult to express

## Known Uses

### Healthcare Domain

**Patient Management**
- PatientRepository for patient records
- Specifications for clinical criteria
- MRN-based lookups
- Department and status filtering

**Clinical Documentation**
- EncounterRepository for clinical encounters
- Diagnosis and treatment queries
- Date range specifications
- Provider-based filtering

### E-Commerce Domain

**Order Management**
- OrderRepository for order processing
- Customer order history
- Status-based queries
- Date range filtering

**Product Catalog**
- ProductRepository for product data
- Category specifications
- Price range queries
- Availability filtering

## Related Patterns

**Data Mapper**
- Repository uses Data Mapper for persistence
- Data Mapper handles actual SQL operations
- Repository provides higher-level interface

**Identity Map**
- Repository integrates Identity Map for caching
- Prevents duplicate object loads
- Ensures reference equality

**Specification**
- Repository uses Specification for queries
- Encapsulates query criteria
- Enables query composition

**Unit of Work**
- Can coordinate with Repository for transactions
- Tracks changes across multiple repositories
- Manages commit/rollback

**DAO (Data Access Object)**
- Similar purpose but different approach
- DAO is more data-oriented
- Repository is more collection-oriented
- Repository is aligned with DDD

## Domain-Driven Design Integration

The Repository pattern is a key tactical pattern in Domain-Driven Design:

**Aggregate Roots**
- Repositories typically manage aggregate roots
- Each aggregate root has one repository
- Child entities accessed through aggregate root

**Ubiquitous Language**
- Repository methods use domain terminology
- FindActivePatients() vs FindByStatus("Active")
- Specifications express domain concepts

**Bounded Context**
- Repositories define boundaries of aggregates
- Enforce aggregate consistency rules
- Prevent bypass of domain logic

## Implementation Guidelines

### Repository Design

1. **One Repository Per Aggregate Root**: Don't create repositories for every entity
2. **Domain-Focused Methods**: Name methods using domain language
3. **Return Domain Objects**: Never return database result sets
4. **Specification Support**: Enable flexible, composable queries
5. **Identity Map Integration**: Always prevent duplicate loads

### Specification Design

1. **Single Responsibility**: Each specification represents one criterion
2. **Composable**: Support AND, OR, NOT combinations
3. **Testable**: Include IsSatisfiedBy() for in-memory filtering
4. **Reusable**: Design for use across multiple repositories

### Performance Considerations

1. **Eager vs Lazy Loading**: Choose appropriate loading strategy
2. **Batch Queries**: Optimize for N+1 query problems
3. **Caching**: Use Identity Map effectively
4. **Query Optimization**: Profile and optimize SQL generation

## References

- Fowler, Martin. *Patterns of Enterprise Application Architecture*. Addison-Wesley, 2002.
- Evans, Eric. *Domain-Driven Design*. Addison-Wesley, 2003.
- Fowler, Martin. *"Repository Pattern"*. martinfowler.com

## See Also

- [Data Mapper Pattern](data-mapper.md)
- [Identity Map Pattern](../objectrelational/identity-map.md)
- [Specification Pattern](specification.md)
- [Unit of Work Pattern](unit-of-work.md)
