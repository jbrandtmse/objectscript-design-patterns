# Data Mapper Pattern

## Intent

Provides a layer of mappers that moves data between objects and a database while keeping them independent of each other and the mapper itself.

## Also Known As

- Object-Relational Mapper
- ORM Layer

## Motivation

When building applications with complex domain models, coupling business logic to database persistence creates maintenance nightmares. Domain objects become polluted with SQL code, violating the Single Responsibility Principle. The Data Mapper pattern solves this by completely separating domain objects from database concerns.

Consider a clinical encounter management system. The `ClinicalEncounter` domain object should focus on business rules like billing code calculation and follow-up determination. It shouldn't care about SQL queries, database schemas, or persistence mechanisms. The Data Mapper handles all database operations, allowing the domain model to remain pure and testable.

## Structure

```
┌─────────────────────┐
│  ClinicalEncounter  │ (Domain Object)
│  ─────────────────  │
│  + PatientMRN       │
│  + ProviderName     │
│  + Diagnosis        │
│  + ValidateEncounter()│
│  + CalculateBillingCode()│
└─────────────────────┘
           ▲
           │ uses
           │
┌─────────────────────────────┐
│ ClinicalEncounterMapper     │
│ ──────────────────────────  │
│ - IdentityMap              │
│ + Insert(encounter)         │
│ + Update(encounter)         │
│ + Delete(encounter)         │
│ + Find(id)                  │
│ + FindAll()                 │
│ + FindByPatientMRN(mrn)     │
│ + MapToDomain(data)         │
│ + MapToDatabase(encounter)  │
└─────────────────────────────┘
           │
           ▼
┌─────────────────────┐
│  Database Table     │
│  ClinicalEncounters │
└─────────────────────┘
```

## Participants

### DataMapper (Base Class)
- **Responsibility**: Defines abstract interface for all mappers
- **Key Methods**: `Insert()`, `Update()`, `Delete()`, `Find()`, `FindAll()`, `MapToDomain()`, `MapToDatabase()`
- **Identity Map**: Prevents loading same object twice from database

### ClinicalEncounterMapper (Concrete Mapper)
- **Responsibility**: Implements mapping for ClinicalEncounter domain objects
- **SQL Operations**: All database queries for clinical encounters
- **Finder Methods**: `FindByPatientMRN()`, `FindByDateRange()` for specific queries

### ClinicalEncounter (Domain Object)
- **Responsibility**: Business logic only, zero database knowledge
- **Business Methods**: `ValidateEncounter()`, `CalculateBillingCode()`, `RequiresFollowUp()`
- **Base Class**: Extends `%RegisteredObject` (NOT `%Persistent`)

## Collaborations

1. **Client** creates domain object with business data
2. **Client** calls mapper's `Insert()` method with domain object
3. **Mapper** calls `MapToDatabase()` to extract data
4. **Mapper** executes SQL INSERT with parameterized query
5. **Mapper** sets ID on domain object from database
6. **Mapper** adds object to Identity Map

For retrieval:
1. **Client** calls mapper's `Find(id)` method
2. **Mapper** checks Identity Map first
3. If not in map, **Mapper** executes SQL SELECT
4. **Mapper** calls `MapToDomain()` to create object
5. **Mapper** adds object to Identity Map
6. **Mapper** returns domain object to client

## Implementation

### Domain Object (Pure Business Logic)

```objectscript
/// Clinical Encounter Domain Object - NO database dependencies
Class Patterns.Examples.Clinical.ClinicalEncounter Extends %RegisteredObject
{
    Property EncounterId As %String;
    Property PatientMRN As %String;
    Property ProviderName As %String;
    Property EncounterDate As %TimeStamp;
    Property EncounterType As %String;
    Property ChiefComplaint As %String;
    Property Diagnosis As %String;
    Property TreatmentPlan As %String;
    
    /// Business logic - no database code
    Method ValidateEncounter() As %Status
    {
        Set tSC = $$$OK
        If (..PatientMRN = "") {
            Set tSC = $$$ERROR($$$GeneralError, "PatientMRN is required")
        }
        Quit tSC
    }
    
    Method CalculateBillingCode() As %String
    {
        If (..EncounterType = "Emergency") {
            Quit "EM-99285"
        } ElseIf (..EncounterType = "Outpatient") {
            Quit "OP-99214"
        }
        Quit "UNKNOWN"
    }
    
    Method RequiresFollowUp() As %Boolean
    {
        If (..Diagnosis [ "chronic") || (..TreatmentPlan [ "follow-up") {
            Quit 1
        }
        Quit 0
    }
}
```

### Data Mapper (All Persistence Logic)

```objectscript
/// Clinical Encounter Mapper - ALL database operations
Class Patterns.Examples.Clinical.ClinicalEncounterMapper 
    Extends Patterns.PoEAA.DataSource.DataMapper
{
    Property IdentityMap [ MultiDimensional ];
    
    /// Insert domain object into database
    Method Insert(pDomainObject As ClinicalEncounter) As %Status
    {
        Set tSC = $$$OK
        Try {
            // Validate using domain logic
            Set tSC = pDomainObject.ValidateEncounter()
            If $$$ISERR(tSC) { Quit }
            
            // Extract data from domain
            Set tData = ..MapToDatabase(pDomainObject)
            
            // Execute SQL with parameterized query
            &sql(INSERT INTO ClinicalEncounters 
                 (PatientMRN, ProviderName, EncounterDate, EncounterType, 
                  ChiefComplaint, Diagnosis, TreatmentPlan)
                 VALUES (:tData.PatientMRN, :tData.ProviderName, 
                         :tData.EncounterDate, :tData.EncounterType,
                         :tData.ChiefComplaint, :tData.Diagnosis, 
                         :tData.TreatmentPlan))
            
            If (SQLCODE = 0) {
                Set pDomainObject.EncounterId = %ROWID
                Do ..AddToIdentityMap(%ROWID, pDomainObject)
            } Else {
                Set tSC = $$$ERROR($$$GeneralError, "Insert failed: " _ SQLCODE)
            }
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    /// Find by ID with Identity Map pattern
    Method Find(pId As %String) As ClinicalEncounter
    {
        Set tDomain = ""
        Try {
            // Check Identity Map first
            Set tDomain = ..GetFromIdentityMap(pId)
            If $IsObject(tDomain) { Quit }
            
            // Load from database
            &sql(SELECT PatientMRN, ProviderName, EncounterDate, EncounterType,
                        ChiefComplaint, Diagnosis, TreatmentPlan
                 INTO :tMRN, :tProvider, :tDate, :tType, 
                      :tComplaint, :tDiagnosis, :tPlan
                 FROM ClinicalEncounters WHERE ID = :pId)
            
            If (SQLCODE = 0) {
                Set tData = {}
                Set tData.PatientMRN = tMRN
                Set tData.ProviderName = tProvider
                Set tData.EncounterDate = tDate
                Set tData.EncounterType = tType
                Set tData.ChiefComplaint = tComplaint
                Set tData.Diagnosis = tDiagnosis
                Set tData.TreatmentPlan = tPlan
                
                Set tDomain = ..MapToDomain(pId, tData)
                Do ..AddToIdentityMap(pId, tDomain)
            }
        } Catch ex {
            Set tDomain = ""
        }
        Quit tDomain
    }
    
    /// Custom finder - by Patient MRN
    Method FindByPatientMRN(pMRN As %String) As %ListOfObjects
    {
        Set tList = ##class(%ListOfObjects).%New()
        // Implementation with cursor and Identity Map
        Quit tList
    }
    
    /// Map domain object to database data
    Method MapToDatabase(pDomain As ClinicalEncounter) As %DynamicObject
    {
        Set tData = {}
        Set tData.PatientMRN = pDomain.PatientMRN
        Set tData.ProviderName = pDomain.ProviderName
        Set tData.EncounterDate = pDomain.EncounterDate
        Set tData.EncounterType = pDomain.EncounterType
        Set tData.ChiefComplaint = pDomain.ChiefComplaint
        Set tData.Diagnosis = pDomain.Diagnosis
        Set tData.TreatmentPlan = pDomain.TreatmentPlan
        Quit tData
    }
    
    /// Map database data to domain object
    Method MapToDomain(pId As %String, pData As %DynamicObject) As ClinicalEncounter
    {
        Set tDomain = ##class(ClinicalEncounter).%New()
        Set tDomain.EncounterId = pId
        Set tDomain.PatientMRN = pData.PatientMRN
        Set tDomain.ProviderName = pData.ProviderName
        Set tDomain.EncounterDate = pData.EncounterDate
        Set tDomain.EncounterType = pData.EncounterType
        Set tDomain.ChiefComplaint = pData.ChiefComplaint
        Set tDomain.Diagnosis = pData.Diagnosis
        Set tDomain.TreatmentPlan = pData.TreatmentPlan
        Quit tDomain
    }
}
```

## When to Use Data Mapper

### Use When:
- **Complex domain models** with rich business logic
- **Clean architecture** requirements demand separation of concerns
- **Testability** is critical (test domain logic without database)
- **Multiple persistence mechanisms** possible (database, file, service)
- **Domain-driven design** where domain model is central
- **Long-term maintainability** is more important than initial simplicity

### Don't Use When:
- **Simple CRUD** operations with minimal business logic (use Active Record)
- **Table-oriented** operations (use Table Data Gateway)
- **Row-centric** needs (use Row Data Gateway)
- **Rapid prototyping** where separation adds overhead
- **Small applications** where pattern complexity isn't justified

## Applicability

The Data Mapper pattern applies when:

1. **Domain objects must be testable** without database infrastructure
2. **Business logic is complex** and deserves pure focus
3. **Persistence strategy might change** (different databases, cloud storage)
4. **Object model differs significantly** from database schema
5. **Multiple developers** work on domain vs. persistence concerns
6. **Legacy database schemas** that don't match object design

## Complete Domain/Persistence Separation

### Domain Object Characteristics:
- ✅ Extends `%RegisteredObject` (NOT `%Persistent`)
- ✅ Zero SQL code or database references
- ✅ Pure business logic methods
- ✅ Completely testable without database
- ✅ No knowledge of mapper existence

### Mapper Characteristics:
- ✅ All SQL queries and database operations
- ✅ Handles object-relational impedance mismatch
- ✅ Implements Identity Map pattern
- ✅ Provides finder methods for various queries
- ✅ Manages database transactions

## Identity Map Pattern Integration

The Data Mapper integrates the Identity Map pattern to ensure:

1. **Same object instance** returned for same database row
2. **Prevents duplicate loads** from database
3. **Consistency** within a single session/transaction
4. **Performance** by caching loaded objects

```objectscript
/// Identity Map ensures same object instance
Method Find(pId As %String) As ClinicalEncounter
{
    // Check map first
    Set tObject = ..GetFromIdentityMap(pId)
    If $IsObject(tObject) { Quit tObject }
    
    // Load from database only if not in map
    // ... SQL query ...
    
    // Add to map before returning
    Do ..AddToIdentityMap(pId, tObject)
    Quit tObject
}
```

## Complex Mapping Scenarios

### Handling Relationships

For domain objects with relationships (e.g., Encounter has Patient):

```objectscript
Method MapToDomain(pId, pData) As ClinicalEncounter
{
    Set tEncounter = ##class(ClinicalEncounter).%New()
    
    // Map simple fields
    Set tEncounter.EncounterId = pId
    Set tEncounter.ProviderName = pData.ProviderName
    
    // Handle relationship - use Patient mapper
    Set tPatientMapper = ##class(PatientMapper).%New()
    Set tEncounter.Patient = tPatientMapper.Find(pData.PatientId)
    
    Quit tEncounter
}
```

### Handling Collections

For collections (e.g., Encounter has multiple Observations):

```objectscript
Method MapToDomain(pId, pData) As ClinicalEncounter
{
    Set tEncounter = ##class(ClinicalEncounter).%New()
    
    // Load observations collection
    Set tObsList = ##class(%ListOfObjects).%New()
    Set tObsMapper = ##class(ObservationMapper).%New()
    Set tObservations = tObsMapper.FindByEncounterId(pId)
    
    For i=1:1:tObservations.Count() {
        Do tObsList.Insert(tObservations.GetAt(i))
    }
    
    Set tEncounter.Observations = tObsList
    Quit tEncounter
}
```

### Lazy Loading Support

For expensive relationships, implement lazy loading:

```objectscript
Property PatientProxy As %String;  // Store ID only

Method GetPatient() As Patient
{
    If '$IsObject(..Patient) {
        Set tMapper = ##class(PatientMapper).%New()
        Set ..Patient = tMapper.Find(..PatientProxy)
    }
    Quit ..Patient
}
```

## Healthcare Clinical Encounter Example

The clinical encounter example demonstrates:

### Domain Model
- `ClinicalEncounter` class with healthcare-specific properties
- Business methods: `ValidateEncounter()`, `CalculateBillingCode()`, `RequiresFollowUp()`
- Zero database dependencies - pure domain logic

### Mapper Implementation
- `ClinicalEncounterMapper` handles all persistence
- Standard operations: `Insert()`, `Update()`, `Delete()`, `Find()`
- Healthcare-specific finders: `FindByPatientMRN()`, `FindByDateRange()`
- Identity Map prevents duplicate object loads

### Real-World Usage
```objectscript
// Create and save encounter
Set mapper = ##class(ClinicalEncounterMapper).%New()
Set encounter = ##class(ClinicalEncounter).%New()
Set encounter.PatientMRN = "MRN12345"
Set encounter.ProviderName = "Dr. Smith"
Set encounter.EncounterType = "Emergency"
Set encounter.Diagnosis = "Acute appendicitis"
Set sc = mapper.Insert(encounter)

// Load and use encounter
Set loaded = mapper.Find(encounter.EncounterId)
Set billingCode = loaded.CalculateBillingCode()  // "EM-99285"
Set needsFollowUp = loaded.RequiresFollowUp()    // 0

// Query encounters for patient
Set encounters = mapper.FindByPatientMRN("MRN12345")
```

## Comparison with Other Patterns

### Data Mapper vs Active Record
| Aspect | Data Mapper | Active Record |
|--------|-------------|---------------|
| **Separation** | Complete - domain has zero DB code | Combined - domain includes persistence |
| **Testability** | Domain fully testable without DB | Requires database for testing |
| **Complexity** | Higher - separate mapper classes | Lower - persistence in domain |
| **Use Case** | Complex domain models | Simple CRUD operations |

### Data Mapper vs Row Data Gateway
| Aspect | Data Mapper | Row Data Gateway |
|--------|-------------|------------------|
| **Abstraction** | Creates rich domain objects | Wraps database rows |
| **Business Logic** | In domain objects | Minimal or none |
| **Return Type** | Domain objects | Gateway instances or arrays |
| **Use Case** | Object-oriented domain | Table-oriented operations |

### Data Mapper vs Table Data Gateway
| Aspect | Data Mapper | Table Data Gateway |
|--------|-------------|-------------------|
| **Granularity** | Object-level operations | Table-level operations |
| **Result** | Domain objects | Result sets, arrays |
| **Domain Model** | Rich domain model | Anemic or no domain |
| **Use Case** | DDD, complex logic | Reporting, batch operations |

## Mapper Responsibilities vs Domain Responsibilities

### Mapper Responsibilities:
- ✅ All SQL queries (SELECT, INSERT, UPDATE, DELETE)
- ✅ Object-relational mapping logic
- ✅ Identity Map management
- ✅ Finder method implementation
- ✅ Transaction coordination
- ✅ Database connection management
- ✅ Handling database-specific concerns

### Domain Object Responsibilities:
- ✅ Business rule validation
- ✅ Business logic calculations
- ✅ State management
- ✅ Workflow enforcement
- ✅ Domain-specific operations
- ❌ NO database knowledge
- ❌ NO SQL code
- ❌ NO persistence concerns

## Known Uses

- **Hibernate** (Java) - Popular ORM framework using Data Mapper
- **Entity Framework** (.NET) - Microsoft's ORM with mapper pattern
- **Doctrine** (PHP) - Full-featured ORM for PHP applications
- **HealthShare** (InterSystems) - Uses mapper pattern for clinical data
- **Epic** (Healthcare) - Separates clinical domain from persistence

## Related Patterns

- **Identity Map** - Ensures same object instance for same row (integrated)
- **Unit of Work** - Coordinates multiple mapper operations in transaction
- **Repository** - Higher-level abstraction over mappers for domain collections
- **Lazy Load** - Defers loading expensive relationships until needed
- **Active Record** - Alternative pattern combining domain with persistence
- **Table Data Gateway** - Lower-level table-oriented data access
- **Row Data Gateway** - Lower-level row-oriented data access

## Consequences

### Benefits:
1. **Complete separation** of domain logic from persistence
2. **Highly testable** domain objects without database
3. **Flexible persistence** - can change database strategy
4. **Rich domain models** with pure business focus
5. **Identity Map** prevents duplicate object loads
6. **Multiple databases** supported via different mappers
7. **Complex queries** encapsulated in finder methods

### Drawbacks:
1. **More classes** to maintain (domain + mapper)
2. **Initial complexity** higher than Active Record
3. **Mapping code** can be repetitive
4. **Performance overhead** from mapping layer
5. **Learning curve** for developers
6. **Overkill** for simple CRUD applications

## Sample Code

See implementation examples:
- `Patterns.PoEAA.DataSource.DataMapper` - Base mapper class
- `Patterns.Examples.Clinical.ClinicalEncounter` - Pure domain object
- `Patterns.Examples.Clinical.ClinicalEncounterMapper` - Concrete mapper
- `Patterns.Test.Unit.PoEAA.DataSource.DataMapperTest` - Comprehensive tests

## References

- Fowler, Martin. *Patterns of Enterprise Application Architecture*. Addison-Wesley, 2002.
- Evans, Eric. *Domain-Driven Design*. Addison-Wesley, 2003.
- Nilsson, Jimmy. *Applying Domain-Driven Design and Patterns*. Addison-Wesley, 2006.
