# Row Data Gateway Pattern

## Intent

**Row Data Gateway** is an object that acts as a gateway to a single record in a data source. There is one instance per row.

## Also Known As

- Record Gateway
- Row Gateway

## Motivation

When accessing data in a relational database, you often need to work with individual records (rows). While you could use SQL statements directly throughout your application, this leads to scattered data access code and makes it hard to change the database schema.

The Row Data Gateway pattern addresses this by wrapping each database row with an object that contains all the row's fields as properties and provides methods to save, delete, and refresh the data. Each instance corresponds exactly to one row in the database.

### Example Problem

Consider a healthcare application that needs to manage patient records. Without Row Data Gateway, patient data access code might be scattered throughout the application:

```objectscript
// In one part of the application
&sql(SELECT FirstName, LastName INTO :firstName, :lastName 
     FROM Patient WHERE ID = :patientId)

// In another part
&sql(UPDATE Patient SET Status = :newStatus WHERE ID = :patientId)

// In yet another part
&sql(DELETE FROM Patient WHERE ID = :patientId)
```

This approach has several problems:
- SQL code is duplicated across the application
- Changes to the database schema require updates everywhere
- No centralized place to add validation or business rules
- Difficult to test data access code

### Solution with Row Data Gateway

The Row Data Gateway pattern solves these issues by providing a dedicated object for each patient row:

```objectscript
// Load existing patient
Set patient = ##class(PatientRowGateway).%New(patientId)

// Modify properties
Set patient.Status = "Discharged"

// Save changes
Do patient.Save()

// Delete patient
Do patient.Delete()
```

## Applicability

Use Row Data Gateway when:

- You need to access individual database rows with a clean object interface
- You want to encapsulate data access logic in one place
- You need instance-based CRUD operations
- You want to track changes to individual records (dirty tracking)
- Your application works primarily with one row at a time

Don't use Row Data Gateway when:

- You need table-wide operations (use Table Data Gateway instead)
- You have complex domain logic (use Domain Model with Data Mapper instead)
- You need to work with multiple rows as a unit (use Table Data Gateway)
- Performance is critical and you need to minimize object creation overhead

## Structure

```
┌─────────────────────────────┐
│   RowDataGateway            │
│  (Abstract Base Class)      │
├─────────────────────────────┤
│ + Id: String                │
│ - %IsNew: Boolean           │
│ - %IsDirty: Boolean         │
├─────────────────────────────┤
│ + %OnNew(pId)               │
│ + IsNew(): Boolean          │
│ + IsDirty(): Boolean        │
│ + Save(): %Status           │
│ + Delete(): %Status         │
│ + Refresh(): %Status        │
│ + FindById(pId): Gateway    │
│ + FindAll(): List           │
│ # LoadFromDatabase(pId)     │
│ # InsertRow()               │
│ # UpdateRow()               │
│ # DeleteRow()               │
└─────────────────────────────┘
         △
         │
         │ extends
         │
┌─────────────────────────────┐
│  PatientRowGateway          │
│  (Concrete Implementation)  │
├─────────────────────────────┤
│ + FirstName: String         │
│ + LastName: String          │
│ + DateOfBirth: Date         │
│ + Gender: String            │
│ + Department: String        │
│ + Status: String            │
│ + MRN: String               │
├─────────────────────────────┤
│ + FindByMRN(pMRN): Gateway  │
│ + FindByLastName(name): List│
│ # LoadFromDatabase(pId)     │
│ # InsertRow()               │
│ # UpdateRow()               │
│ # DeleteRow()               │
└─────────────────────────────┘
```

## Participants

### RowDataGateway (Base Class)
- **Responsibility**: Provides framework for row-level data access
- **Collaborators**: Subclasses that implement specific table access
- **Key Methods**:
  - `%OnNew(pId)`: Constructor that loads row by ID
  - `Save()`: Inserts new row or updates existing row
  - `Delete()`: Removes row from database
  - `Refresh()`: Reloads data from database
  - `IsNew()`: Indicates if row exists in database
  - `IsDirty()`: Indicates if properties have been modified
  - `FindById(pId)`: Class method to load gateway by ID
  - `FindAll()`: Class method to load all rows as gateways

### PatientRowGateway (Concrete Gateway)
- **Responsibility**: Provides access to individual patient rows
- **Collaborators**: Patient persistent class, application code
- **Key Features**:
  - Properties map to database columns
  - Finder methods for healthcare-specific queries
  - Implements abstract methods from base class

## Collaborations

### Loading an Existing Row

```
Client                  PatientRowGateway              Patient (Database)
  |                            |                              |
  |----%New(id)--------------->|                              |
  |                            |----%OpenId(id)-------------->|
  |                            |<----patient object-----------|
  |                            |---copy properties----------->|
  |<---gateway instance--------|                              |
```

### Creating and Saving New Row

```
Client                  PatientRowGateway              Patient (Database)
  |                            |                              |
  |----%New()----------------->|                              |
  |<---new gateway-------------|                              |
  |---set properties---------->|                              |
  |---Save()------------------>|                              |
  |                            |----%New()-------------------->|
  |                            |---set properties------------>|
  |                            |----%Save()------------------>|
  |                            |<----id-----------------------|
  |<---$$$OK-------------------|                              |
```

### Updating Existing Row

```
Client                  PatientRowGateway              Patient (Database)
  |                            |                              |
  |----%New(id)--------------->|                              |
  |<---gateway-----------------|                              |
  |---modify properties------->|                              |
  |---Save()------------------>|                              |
  |                            |----%OpenId(id)-------------->|
  |                            |---update properties--------->|
  |                            |----%Save()------------------>|
  |<---$$$OK-------------------|                              |
```

## Implementation

### ObjectScript Implementation

The Row Data Gateway pattern in ObjectScript leverages IRIS's %Persistent objects for database operations while maintaining the gateway abstraction.

#### Base Class Pattern

```objectscript
Class Patterns.PoEAA.DataSource.RowDataGateway Extends %RegisteredObject
{
    /// Row ID from database
    Property Id As %String;
    
    /// Flag indicating new (unsaved) instance
    Property %IsNew As %Boolean [ Private ];
    
    /// Flag indicating properties have been modified
    Property %IsDirty As %Boolean [ Private ];
    
    /// Constructor loads row by ID if provided
    Method %OnNew(pId As %String = "") As %Status
    {
        Set tSC = $$$OK
        
        Try {
            Set ..%IsNew = 1
            Set ..%IsDirty = 0
            
            If pId '= "" {
                Set tSC = ..LoadFromDatabase(pId)
                If $$$ISOK(tSC) {
                    Set ..Id = pId
                    Set ..%IsNew = 0
                    Set ..%IsDirty = 0
                }
            }
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Save row to database (insert or update based on IsNew)
    Method Save() As %Status
    {
        Set tSC = $$$OK
        
        Try {
            If ..IsNew() {
                Set tSC = ..InsertRow()
                If $$$ISOK(tSC) {
                    Set ..%IsNew = 0
                    Set ..%IsDirty = 0
                }
            } Else {
                If ..IsDirty() {
                    Set tSC = ..UpdateRow()
                    If $$$ISOK(tSC) {
                        Set ..%IsDirty = 0
                    }
                }
            }
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    // ... other methods
}
```

#### Concrete Implementation Pattern

```objectscript
Class Patterns.Examples.Clinical.PatientRowGateway 
    Extends Patterns.PoEAA.DataSource.RowDataGateway
{
    /// Patient properties map to database columns
    Property FirstName As %String;
    Property LastName As %String;
    Property MRN As %String;
    
    /// Property setter tracks changes
    Method FirstNameSet(pValue As %String) As %Status
    {
        Set i%FirstName = pValue
        Do ..MarkDirty()
        Quit $$$OK
    }
    
    /// Load patient data from database by ID
    Method LoadFromDatabase(pId As %String) As %Status [ Private ]
    {
        Set tSC = $$$OK
        
        Try {
            Set tPatient = ##class(Patient).%OpenId(pId)
            
            If $IsObject(tPatient) {
                Set i%FirstName = tPatient.FirstName
                Set i%LastName = tPatient.LastName
                Set i%MRN = tPatient.MRN
            } Else {
                Set tSC = $$$ERROR($$$GeneralError, "Patient not found")
            }
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Insert new patient row
    Method InsertRow() As %Status [ Private ]
    {
        Set tSC = $$$OK
        
        Try {
            // Validate required fields
            If (..FirstName = "") || (..LastName = "") {
                Set tSC = $$$ERROR($$$GeneralError, "Required fields missing")
                Quit
            }
            
            // Create and save persistent object
            Set tPatient = ##class(Patient).%New()
            Set tPatient.FirstName = ..FirstName
            Set tPatient.LastName = ..LastName
            Set tPatient.MRN = ..MRN
            
            Set tSC = tPatient.%Save()
            If $$$ISOK(tSC) {
                Set ..Id = tPatient.%Id()
            }
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Healthcare-specific finder by MRN
    ClassMethod FindByMRN(pMRN As %String) 
        As Patterns.Examples.Clinical.PatientRowGateway
    {
        Set tGateway = ""
        
        Try {
            Set tId = ##class(Patient).MRNIdxOpen(pMRN)
            If tId '= "" {
                Set tGateway = ..%New(tId)
            }
        } Catch ex {
            Set tGateway = ""
        }
        
        Quit tGateway
    }
}
```

### Key Implementation Decisions

#### 1. ObjectScript %Persistent Integration

Rather than using raw SQL, the implementation leverages IRIS's %Persistent object methods:
- `%OpenId()` for loading rows
- `%New()` and `%Save()` for creating/updating
- `%DeleteId()` for deletion
- Index methods for custom finders

**Advantages**:
- Type safety and validation
- Automatic SQL generation
- Index optimization
- Transaction management
- Less SQL injection risk

#### 2. State Tracking

Two flags track gateway state:
- `%IsNew`: Indicates if row exists in database
- `%IsDirty`: Indicates if properties have been modified

**Benefits**:
- Optimize saves (skip if not dirty)
- Prevent unnecessary database operations
- Support optimistic concurrency

#### 3. Property Setters for Dirty Tracking

Override property setters to automatically mark gateway as dirty:

```objectscript
Method FirstNameSet(pValue As %String) As %Status
{
    Set i%FirstName = pValue
    Do ..MarkDirty()
    Quit $$$OK
}
```

**Benefits**:
- Automatic change tracking
- No manual dirty flag management
- Transparent to clients

#### 4. Constructor Loading Pattern

The `%OnNew()` constructor optionally loads a row by ID:

```objectscript
// Create new gateway (not in database yet)
Set gateway = ##class(PatientRowGateway).%New()

// Load existing gateway
Set gateway = ##class(PatientRowGateway).%New(id)
```

**Benefits**:
- Single object creation pattern
- Explicit new vs existing distinction
- Simple client code

## Sample Code

### Basic CRUD Operations

```objectscript
/// Create new patient
Set patient = ##class(PatientRowGateway).%New()
Set patient.FirstName = "John"
Set patient.LastName = "Doe"
Set patient.MRN = "MRN12345"
Set patient.Gender = "M"
Set patient.Status = "Active"

// Save new patient
Set status = patient.Save()
If $$$ISERR(status) {
    Write "Error: ", $System.Status.GetErrorText(status)
}

/// Load existing patient
Set patient = ##class(PatientRowGateway).%New("123")
If 'patient.IsNew() {
    Write "Patient: ", patient.FirstName, " ", patient.LastName
}

/// Update patient
Set patient = ##class(PatientRowGateway).%New("123")
Set patient.Status = "Discharged"
Do patient.Save()

/// Delete patient
Set patient = ##class(PatientRowGateway).%New("123")
Do patient.Delete()
```

### Using Finder Methods

```objectscript
/// Find by ID
Set patient = ##class(PatientRowGateway).FindById("123")
If $IsObject(patient) {
    Write "Found: ", patient.FirstName
}

/// Find by Medical Record Number
Set patient = ##class(PatientRowGateway).FindByMRN("MRN12345")
If $IsObject(patient) {
    Write "Patient ID: ", patient.Id
}

/// Find by last name (returns list)
Set patients = ##class(PatientRowGateway).FindByLastName("Smith")
For i=1:1:patients.Count() {
    Set patient = patients.GetAt(i)
    Write patient.FirstName, " ", patient.LastName, !
}

/// Find all patients
Set allPatients = ##class(PatientRowGateway).FindAll()
Write "Total patients: ", allPatients.Count()
```

### State Tracking

```objectscript
/// Check if gateway is new
Set patient = ##class(PatientRowGateway).%New()
If patient.IsNew() {
    Write "This is a new patient (not saved yet)"
}

/// Check if gateway is dirty
Set patient = ##class(PatientRowGateway).%New("123")
Write "Dirty before change: ", patient.IsDirty()  // 0

Set patient.FirstName = "Jane"
Write "Dirty after change: ", patient.IsDirty()   // 1

Do patient.Save()
Write "Dirty after save: ", patient.IsDirty()     // 0
```

### Refresh Pattern

```objectscript
/// Load patient in two different gateways
Set gateway1 = ##class(PatientRowGateway).%New("123")
Set gateway2 = ##class(PatientRowGateway).%New("123")

/// Modify first gateway
Set gateway1.Status = "Discharged"
Do gateway1.Save()

/// Second gateway has stale data
Write gateway2.Status  // Still shows "Active"

/// Refresh second gateway
Do gateway2.Refresh()
Write gateway2.Status  // Now shows "Discharged"
```

## Known Uses

### InterSystems IRIS Applications

- **HealthShare**: Patient demographics gateways
- **TrakCare**: Admission/discharge/transfer record gateways
- **Custom Healthcare Systems**: Clinical data row access

### Enterprise Applications

- **E-commerce**: Order row gateways for individual order processing
- **Financial Systems**: Transaction row gateways for audit trails
- **CRM Systems**: Contact and lead row gateways

### Comparison with Similar Patterns

#### Row Data Gateway vs Table Data Gateway

| Aspect | Row Data Gateway | Table Data Gateway |
|--------|------------------|-------------------|
| Instance Scope | One instance per row | One instance per table |
| State | Stateful (holds row data) | Stateless (no data storage) |
| Methods | Instance methods (Save, Delete) | Class methods (InsertRow, UpdateRow) |
| Use Case | Row-centric operations | Table-wide operations |
| Example | `patient.Save()` | `##class(Gateway).UpdatePatient(id, data)` |

#### Row Data Gateway vs Active Record

| Aspect | Row Data Gateway | Active Record |
|--------|------------------|---------------|
| Purpose | Pure data access | Data access + domain logic |
| Complexity | Simple, focused | Can become complex |
| Domain Logic | None (in gateway) | Included in record |
| Testability | Easy to test | Harder due to mixed concerns |
| Example | Gateway only saves | Record validates and saves |

#### Row Data Gateway vs Data Mapper

| Aspect | Row Data Gateway | Data Mapper |
|--------|------------------|-------------|
| Mapping | Gateway IS the row | Mapper translates row to domain object |
| Domain Object | Gateway itself | Separate rich domain object |
| Complexity | Lower | Higher |
| Use Case | Simple data structures | Complex domain models |
| Flexibility | Limited | High |

## Consequences

### Benefits

1. **Encapsulation**: All database access for a row in one place
2. **Single Responsibility**: Gateway only handles data access, no business logic
3. **Easy Testing**: Can mock gateways for testing business logic
4. **Schema Independence**: Database schema changes isolated to gateway
5. **Type Safety**: Properties provide compile-time type checking
6. **Dirty Tracking**: Automatic detection of changes
7. **Familiar OO Model**: Each row is an object

### Liabilities

1. **Object Creation Overhead**: One object per row can be expensive
2. **Memory Usage**: Large result sets create many objects
3. **Identity Map Needed**: Multiple instances can represent same row
4. **Limited Batch Operations**: Not optimized for bulk updates
5. **Potential Stale Data**: Multiple gateways can have different views of same row
6. **No Domain Logic**: Business rules must live elsewhere

### Performance Considerations

- **Good For**: Interactive applications working with individual records
- **Poor For**: Batch processing, reporting, bulk operations
- **Optimization**: Use finder methods that return lists efficiently
- **Caching**: Consider caching frequently accessed gateways
- **Lazy Loading**: Load related data only when needed

## Related Patterns

### Complementary Patterns

- **Table Data Gateway**: Use for table-wide operations alongside Row Data Gateway for row-level
- **Unit of Work**: Manages changes across multiple gateways and coordinates saves
- **Identity Map**: Ensures only one gateway instance per row in memory
- **Lazy Load**: Delays loading of related data until accessed

### Alternative Patterns

- **Active Record**: If you want to combine data access with domain logic
- **Data Mapper**: If you need to map rows to rich domain objects
- **Repository**: For more complex querying and domain-oriented access

### Pattern Sequences

Common progression:
1. Start with **Row Data Gateway** for simple CRUD
2. Add **Unit of Work** when managing multiple gateways
3. Introduce **Identity Map** to prevent multiple instances
4. Consider **Data Mapper** when domain logic grows complex

## See Also

- Martin Fowler, *Patterns of Enterprise Application Architecture*, Chapter 10
- [Table Data Gateway Pattern](table-data-gateway.md)
- [Domain Model Pattern](domain-model.md)
- [Active Record Pattern](https://martinfowler.com/eaaCatalog/activeRecord.html)
- [Data Mapper Pattern](https://martinfowler.com/eaaCatalog/dataMapper.html)
