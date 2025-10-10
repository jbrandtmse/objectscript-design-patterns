# Active Record Pattern

## Pattern Type
**Patterns of Enterprise Application Architecture (PoEAA) - Data Source Architectural Pattern**

## Intent

An object that wraps a row in a database table or view, encapsulates the database access, and adds domain logic on that data.

## Also Known As

- Domain Object with Persistence
- Self-Persisting Domain Object

## Motivation

Many applications need to work with data stored in a database while also applying business logic to that data. You could separate the data access from the domain logic, but for simple domain models this creates unnecessary complexity. The Active Record pattern combines data access and domain logic in a single class, making it straightforward to work with database-backed objects.

Each Active Record instance represents a single row in a database table and knows how to persist itself. The object wraps database operations (insert, update, delete, find) as methods on the domain object itself, making it natural to work with from the application code.

This pattern works best when:
- The domain logic is relatively simple
- There's a close correspondence between the database schema and the domain model
- You want objects that feel natural to work with in your application code

## Applicability

Use the Active Record pattern when:

- You have a simple domain model with straightforward business logic
- There's a one-to-one mapping between domain objects and database tables
- Domain logic is closely tied to individual records
- You want objects that manage their own persistence
- The team is comfortable with objects that have multiple responsibilities
- Performance requirements allow for the overhead of loading full objects

Don't use Active Record when:

- You have complex domain logic that should be separated from persistence
- You need fine-grained control over database access for performance
- Domain model and database schema have significant differences
- You're building a rich domain model with complex object graphs
- You need to switch between different persistence mechanisms
- You want to follow strict separation of concerns

## Structure

```
┌─────────────────────────────┐
│   Active Record             │
│   (Abstract)                │
├─────────────────────────────┤
│ + Save() : %Status          │
│ + Delete() : %Status        │
│ + Reload() : %Status        │
│ + IsNew() : %Boolean        │
│ + FindById(id) : Object     │
│ + FindAll() : List          │
│ # ValidateData() : %Status  │
│ # CheckBusinessRules()      │
│ # CalculateProperties()     │
└─────────────────────────────┘
           △
           │ extends
           │
┌─────────────────────────────┐
│   PatientActiveRecord       │
├─────────────────────────────┤
│ - FirstName : String        │
│ - LastName : String         │
│ - DateOfBirth : Date        │
│ - Status : String           │
│ - Department : String       │
│ - MRN : String              │
├─────────────────────────────┤
│ + Admit(dept) : %Status     │
│ + Discharge() : %Status     │
│ + Transfer(dept) : %Status  │
│ + GetAge() : Integer        │
│ + GetFullName() : String    │
│ + FindByMRN(mrn) : Patient  │
│ + FindByDepartment(dept)    │
└─────────────────────────────┘
```

## Participants

- **Active Record (Abstract Base)**
  - Defines the interface for persistence operations
  - Provides base implementations of Save(), Delete(), Reload()
  - Extends %Persistent for automatic database mapping
  - Defines hooks for validation and business rules
  - Implements common finder methods

- **Concrete Active Record (e.g., PatientActiveRecord)**
  - Extends the Active Record base class
  - Defines domain-specific properties
  - Implements domain validation logic
  - Contains business logic methods
  - Provides domain-specific finder methods
  - Includes calculated properties

## Collaborations

1. Client creates new Active Record instance
2. Client sets properties on the instance
3. Client calls Save() to persist the object
4. Active Record validates data and business rules
5. Active Record uses %Persistent to perform INSERT/UPDATE
6. Client calls domain methods (e.g., Admit, Transfer)
7. Domain methods update state and call Save()
8. Client uses class methods to find records (FindById, FindByMRN)
9. Finders return fully-populated Active Record instances

## Implementation in ObjectScript/IRIS

### Base Active Record Class

```objectscript
/// Base Active Record class providing persistence and lifecycle management
Class Patterns.PoEAA.DataSource.ActiveRecord Extends %Persistent [ Abstract ]
{
    /// Validate domain data before save
    Method ValidateData() As %Status
    {
        // Override in subclasses
        Quit $$$OK
    }
    
    /// Check business rules before save
    Method CheckBusinessRules() As %Status
    {
        // Override in subclasses
        Quit $$$OK
    }
    
    /// Save record with validation
    Method Save() As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Validate data
            Set tSC = ..ValidateData()
            If $$$ISERR(tSC) Quit
            
            // Check business rules
            Set tSC = ..CheckBusinessRules()
            If $$$ISERR(tSC) Quit
            
            // Persist using %Persistent
            Set tSC = ..%Save()
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Delete record from database
    Method Delete() As %Status
    {
        Set tSC = $$$OK
        
        Try {
            If '..IsNew() {
                Set tSC = ..%DeleteId(..%Id())
            } Else {
                Set tSC = $$$ERROR($$$GeneralError, "Cannot delete unsaved record")
            }
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Find record by ID
    ClassMethod FindById(pId As %String) As ActiveRecord
    {
        Quit ..%OpenId(pId)
    }
}
```

### Healthcare Patient Active Record Example

```objectscript
/// Patient domain object with built-in persistence
Class Patterns.Examples.Clinical.PatientActiveRecord Extends Patterns.PoEAA.DataSource.ActiveRecord
{
    /// Patient properties
    Property FirstName As %String;
    Property LastName As %String;
    Property DateOfBirth As %Date;
    Property Status As %String;
    Property Department As %String;
    Property MRN As %String;
    
    Index MRNIdx On MRN [ Unique ];
    
    /// Validate patient data
    Method ValidateData() As %Status
    {
        Set tSC = $$$OK
        
        // Validate required fields
        If (..FirstName = "") {
            Set tSC = $$$ERROR($$$GeneralError, "First name required")
            Quit tSC
        }
        
        // Validate MRN format
        If ($LENGTH(..MRN) < 6) || ($EXTRACT(..MRN, 1, 3) '= "MRN") {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid MRN format")
            Quit tSC
        }
        
        Quit tSC
    }
    
    /// Business logic: Admit patient
    Method Admit(pDepartment As %String) As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Validate business rule
            If (..Status '= "Pending") {
                Set tSC = $$$ERROR($$$GeneralError, "Patient must be pending")
                Quit
            }
            
            // Update state
            Set ..Department = pDepartment
            Set ..Status = "Admitted"
            Set ..AdmissionDate = +$HOROLOG
            
            // Persist changes
            Set tSC = ..Save()
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Calculated property: Get age
    Method GetAge() As %Integer
    {
        If (..DateOfBirth = "") Quit 0
        
        Set tToday = +$HOROLOG
        Set tDays = tToday - ..DateOfBirth
        Quit tDays \ 365
    }
    
    /// Find patient by MRN
    ClassMethod FindByMRN(pMRN As %String) As PatientActiveRecord
    {
        Set tSQL = "SELECT ID FROM Patterns_Examples_Clinical.PatientActiveRecord WHERE MRN = ?"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tSC) {
            Set tResult = tStatement.%Execute(pMRN)
            If tResult.%Next() {
                Quit ..%OpenId(tResult.%Get("ID"))
            }
        }
        
        Quit ""
    }
}
```

### Usage Examples

```objectscript
// Create new patient
Set patient = ##class(PatientActiveRecord).%New()
Set patient.FirstName = "John"
Set patient.LastName = "Doe"
Set patient.MRN = "MRN12345"
Set patient.DateOfBirth = $ZDATEH("1980-05-15", 3)
Set patient.Gender = "M"
Set patient.Status = "Pending"
Set tSC = patient.Save()

// Admit patient (business logic + persistence)
Set tSC = patient.Admit("Cardiology")

// Find and update patient
Set patient = ##class(PatientActiveRecord).FindByMRN("MRN12345")
Set tSC = patient.Transfer("Neurology")

// Use calculated properties
Write "Patient: ", patient.GetFullName()
Write "Age: ", patient.GetAge(), " years"
Write "LOS: ", patient.GetLengthOfStay(), " days"

// Discharge patient
Set tSC = patient.Discharge()
```

## IRIS %Persistent Integration

The Active Record pattern leverages IRIS's %Persistent class for powerful capabilities:

### Automatic Features

- **SQL Projection**: Properties automatically map to SQL columns
- **Persistence Operations**: %Save(), %Delete(), %OpenId() handle database operations
- **State Tracking**: %IsNew() identifies new vs existing records
- **ID Management**: %Id() provides unique identifier
- **Indices**: Define indices for query performance
- **Relationships**: Support one-to-many and many-to-one relationships

### Persistence Methods

| Method | Purpose |
|--------|---------|
| %Save() | Persist object (INSERT or UPDATE) |
| %Delete() | Remove object from database |
| %OpenId(id) | Load object by ID |
| %Reload() | Refresh object from database |
| %IsNew() | Check if object is unsaved |
| %DeleteId(id) | Delete object by ID (class method) |
| %ExistsId(id) | Check if ID exists (class method) |

### Callbacks

%Persistent provides lifecycle callbacks for business logic:

- **%OnBeforeSave()**: Called before save (validation, defaults)
- **%OnAfterSave()**: Called after save (logging, notifications)
- **%OnDelete()**: Called during delete (cleanup, cascade)
- **%OnValidateObject()**: Object-level validation

## Consequences

### Benefits

1. **Simplicity**: Single class combines data and behavior
2. **Natural API**: Objects manage their own persistence
3. **Familiar Pattern**: Easy for developers to understand
4. **IRIS Integration**: Leverages %Persistent capabilities
5. **Quick Development**: Rapid prototyping and development
6. **Self-Contained**: Objects have everything they need
7. **Transaction Participation**: Fits IRIS transaction model

### Liabilities

1. **Tight Coupling**: Domain logic coupled to persistence
2. **Testing Challenges**: Harder to test without database
3. **Performance**: Always loads full objects
4. **Scalability**: Can be inefficient for complex queries
5. **Flexibility**: Hard to change persistence mechanism
6. **Rich Domain Models**: Not ideal for complex domain logic
7. **Database Schema**: Must match domain model closely

## When to Use %Persistent Features

### Use %Persistent Directly For

- Simple CRUD applications
- Rapid prototyping
- Small to medium applications
- When database schema matches domain model
- Internal tools and utilities

### Use Active Record Pattern For

- Adding domain logic to %Persistent objects
- Business rule enforcement
- Calculated properties
- Domain-specific finders
- Workflow and state management
- Healthcare/business applications

### Don't Use Active Record For

- Complex domain models (use Domain Model + Data Mapper)
- Heavy business logic (use Service Layer)
- Performance-critical operations (use Table Data Gateway)
- Multiple persistence mechanisms
- Domain-driven design with rich models

## Comparison with Other Patterns

### Active Record vs Row Data Gateway

| Aspect | Active Record | Row Data Gateway |
|--------|---------------|------------------|
| Domain Logic | Contains business logic | Pure data access |
| Purpose | Domain object | Database wrapper |
| Methods | Business + persistence | Only CRUD |
| Coupling | Coupled | Decoupled |
| Complexity | Simple to moderate | Very simple |

### Active Record vs Table Data Gateway

| Aspect | Active Record | Table Data Gateway |
|--------|---------------|-------------------|
| Instance | Per row | Per table |
| State | Stateful object | Stateless |
| API | Object-oriented | Procedure-oriented |
| Queries | Instance + class methods | All class methods |
| Use Case | Object manipulation | Batch operations |

### Active Record vs Data Mapper

| Aspect | Active Record | Data Mapper |
|--------|---------------|-------------|
| Separation | Coupled | Separated |
| Domain Logic | In Active Record | In Domain Model |
| Persistence | Self-managing | Mapper manages |
| Complexity | Simple | Complex |
| Rich Models | Limited support | Full support |

## Implementation Notes

### Validation Strategy

Implement validation in layers:

1. **Property Validation**: Format, range, type checking
2. **Business Rules**: Domain-specific constraints
3. **Database Constraints**: Unique indices, foreign keys
4. **Save Workflow**: ValidateData() → CheckBusinessRules() → %Save()

### Finder Methods

Implement finders as class methods:

```objectscript
/// Find by domain-specific criteria
ClassMethod FindByMRN(pMRN As %String) As PatientActiveRecord
{
    // Use parameterized SQL for security
    Set tSQL = "SELECT ID FROM Table WHERE MRN = ?"
    // Execute query and return Active Record instance
}
```

### Calculated Properties

Use instance methods for derived values:

```objectscript
Method GetAge() As %Integer
{
    // Calculate from stored properties
    Quit tAge
}
```

### Business Logic Methods

Implement workflows as instance methods:

```objectscript
Method Admit(pDepartment As %String) As %Status
{
    // Validate business rules
    // Update state
    // Persist changes
    Quit ..Save()
}
```

## Testing Strategy

### Unit Testing Active Records

```objectscript
Class ActiveRecordTest Extends %UnitTest.TestCase
{
    Method TestSaveNewRecord()
    {
        Set obj = ##class(PatientActiveRecord).%New()
        // Set properties
        Set tSC = obj.Save()
        Do $$$AssertStatusOK(tSC)
        Do $$$AssertTrue('obj.IsNew())
    }
    
    Method TestBusinessLogic()
    {
        Set obj = ##class(PatientActiveRecord).%New()
        // Setup
        Set tSC = obj.Admit("Cardiology")
        Do $$$AssertStatusOK(tSC)
        Do $$$AssertEquals(obj.Status, "Admitted")
    }
}
```

### Test Data Cleanup

```objectscript
Method OnBeforeOneTest() As %Status
{
    // Clean up test data
    &sql(DELETE FROM PatientActiveRecord)
    Quit $$$OK
}
```

## Known Uses

### Healthcare Systems

- Patient management
- Appointment scheduling
- Medical record tracking
- Insurance claim processing

### Business Applications

- Customer relationship management
- Order processing
- Inventory management
- Employee records

### InterSystems IRIS Applications

- Simple CRUD applications
- Internal tools and utilities
- Prototype development
- Small to medium applications

## Related Patterns

- **Domain Model**: For complex business logic, separate from Active Record
- **Data Mapper**: For decoupling domain model from database
- **Table Data Gateway**: For table-wide operations
- **Row Data Gateway**: For data access without business logic
- **Service Layer**: For coordinating Active Record operations
- **Unit of Work**: For managing Active Record transactions
- **Identity Map**: For caching Active Record instances

## References

- Fowler, Martin. "Patterns of Enterprise Application Architecture" (2002)
- InterSystems IRIS Documentation: "%Persistent Class"
- InterSystems IRIS Documentation: "Object-Relational Mapping"

## See Also

- [Domain Model Pattern](domain-model.md)
- [Table Data Gateway Pattern](table-data-gateway.md)
- [Row Data Gateway Pattern](row-data-gateway.md)
- [Service Layer Pattern](service-layer.md)
