# Table Module Pattern

## Pattern Classification
- **Category**: Domain Logic Pattern
- **Source**: Patterns of Enterprise Application Architecture (PoEAA)
- **Complexity**: Moderate

## Intent

Organize domain logic around database tables with one class per table, using static methods for table-wide operations and set-based processing.

## Motivation

In many business applications, domain logic naturally aligns with database tables rather than individual objects or use cases. When operations work with entire result sets or require SQL queries, creating rich domain objects for each record can be inefficient. The Table Module pattern provides a middle ground between procedural Transaction Scripts and object-oriented Domain Models.

### Problems Addressed

1. **Inefficient Object Creation**: Creating domain objects for every database row is wasteful for reporting and batch operations
2. **Set-Based Operations**: SQL naturally works with sets of data, not individual objects
3. **Simple Domain Logic**: When business rules are moderate, Domain Model's complexity is unnecessary
4. **Record-Set Processing**: Applications that work extensively with database result sets
5. **Table-Oriented Thinking**: Teams and databases organized around table structures

### Solution

Create one class per database table that provides:
- Static/class methods for all table operations (no instance creation required)
- CRUD operations (Create, Read, Update, Delete)
- Custom query methods returning result sets
- Validation and business rule enforcement
- Simple data structures (DTOs or Dynamic Objects) for results

## Structure

```
┌─────────────────────────────┐
│   <<abstract>>              │
│   TableModule               │
├─────────────────────────────┤
│ + TABLENAME: String         │
│ + PRIMARYKEY: String        │
├─────────────────────────────┤
│ + FindById(id): Object      │
│ + FindAll(): Array          │
│ + Insert(data): Status      │
│ + Update(id, data): Status  │
│ + Delete(id): Status        │
│ + ExecuteQuery(): Array     │
│ + ValidateData(): Status    │
└─────────────────────────────┘
         △
         │ extends
         │
┌─────────────────────────────┐
│   PatientTableModule        │
├─────────────────────────────┤
│ + FindByMRN(): Object       │
│ + FindByName(): Array       │
│ + InsertPatient(): Status   │
│ + UpdatePatient(): Status   │
│ + DeletePatient(): Status   │
│ + GetAllActive(): Array     │
│ + SearchByDiagnosis(): Array│
└─────────────────────────────┘
```

### Key Participants

- **TableModule (Abstract)**: Base class providing common table operations
- **Concrete Table Module**: One per database table with specific operations
- **SQL Statement**: IRIS %SQL.Statement for query execution
- **Result Set**: %SQL.StatementResult for query results
- **Dynamic Object**: %DynamicObject for flexible result structures

## Implementation

### Base Table Module Class

```objectscript
Class Patterns.PoEAA.DomainLogic.TableModule Extends %RegisteredObject [ Abstract ]
{
    /// Table name (override in subclasses)
    Parameter TABLENAME;
    
    /// Find record by ID
    ClassMethod FindById(pId As %Integer) As %DynamicObject
    {
        Set tResult = ""
        Try {
            Set tSQL = "SELECT * FROM " _ ..#TABLENAME _ " WHERE ID = ?"
            Set tStatement = ##class(%SQL.Statement).%New()
            Set tSC = tStatement.%Prepare(tSQL)
            Set tResultSet = tStatement.%Execute(pId)
            
            If tResultSet.%Next() {
                Set tResult = ..ResultSetRowToObject(tResultSet)
            }
        } Catch ex {
            Set tResult = ""
        }
        Quit tResult
    }
    
    /// Insert new record
    ClassMethod Insert(pData As %DynamicObject) As %Status
    {
        // Build and execute INSERT statement
        // Returns status
    }
    
    /// Convert result set row to dynamic object
    ClassMethod ResultSetRowToObject(pResultSet) As %DynamicObject
    {
        // Convert SQL result to object structure
    }
}
```

### Concrete Patient Table Module

```objectscript
Class PatientTableModule Extends TableModule
{
    Parameter TABLENAME = "Patterns_Examples_Clinical.Patient";
    
    /// Find patient by medical record number
    ClassMethod FindByMedicalRecordNumber(pMRN As %String) As %DynamicObject
    {
        Set tSQL = "SELECT * FROM Patterns_Examples_Clinical.Patient WHERE MedicalRecordNumber = ?"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        Set tResultSet = tStatement.%Execute(pMRN)
        
        If tResultSet.%Next() {
            Quit ..ResultSetRowToObject(tResultSet)
        }
        Quit ""
    }
    
    /// Find patients by name (partial match)
    ClassMethod FindPatientsByName(pName As %String) As %DynamicArray
    {
        Set tResult = []
        Set tSQL = "SELECT * FROM Patterns_Examples_Clinical.Patient WHERE FullName LIKE ? ORDER BY FullName"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        Set tResultSet = tStatement.%Execute("%" _ pName _ "%")
        
        While tResultSet.%Next() {
            Do tResult.%Push(..ResultSetRowToObject(tResultSet))
        }
        Quit tResult
    }
}
```

## Applicability

### When to Use Table Module

✅ **Good Fit When:**
- Domain logic is moderate complexity (not trivial, not highly complex)
- Application is primarily data-centric with table-oriented operations
- Reporting and set-based operations are common
- Team is comfortable with SQL and relational thinking
- Performance of set-based operations is important
- Multiple records are processed together frequently

### When NOT to Use Table Module

❌ **Poor Fit When:**
- Business logic is extremely simple (use Transaction Script instead)
- Business logic is very complex with rich object relationships (use Domain Model instead)
- Object behavior and polymorphism are central to the domain
- Domain relationships don't map cleanly to database structure
- Object identity and lifecycle management are critical

## IRIS SQL Integration

### Embedded SQL Features

The Table Module pattern leverages IRIS's powerful SQL capabilities:

```objectscript
/// Using IRIS %SQL.Statement for dynamic queries
ClassMethod ExecuteCustomQuery(pSQL As %String, pParams As %DynamicArray) As %DynamicArray
{
    Set tResult = []
    Set tStatement = ##class(%SQL.Statement).%New()
    Set tSC = tStatement.%Prepare(pSQL)
    
    // Execute with parameters
    If $IsObject(pParams) && (pParams.%Size() > 0) {
        Set tResultSet = tStatement.%Execute(pParams...)
    } Else {
        Set tResultSet = tStatement.%Execute()
    }
    
    // Process result set
    While tResultSet.%Next() {
        Do tResult.%Push(..ResultSetRowToObject(tResultSet))
    }
    Quit tResult
}
```

### SQL Best Practices

1. **Parameterized Queries**: Always use parameters to prevent SQL injection
2. **Result Set Processing**: Convert result sets to dynamic objects for flexibility
3. **Error Handling**: Check SQLCODE and handle SQL exceptions
4. **Query Optimization**: Use IRIS indices for frequently queried columns
5. **Transaction Management**: Wrap multi-statement operations in transactions
6. **Batch Operations**: Leverage SQL's set-based operations for efficiency

## Healthcare Example

### Patient Table Module Operations

```objectscript
// Find patient by ID
Set patient = ##class(PatientTableModule).FindById(123)
Write patient.FullName, " - MRN: ", patient.MedicalRecordNumber

// Search patients by name
Set patients = ##class(PatientTableModule).FindPatientsByName("Smith")
Set iterator = patients.%GetIterator()
While iterator.%GetNext(.key, .patient) {
    Write patient.FullName, !
}

// Insert new patient
Set patientData = {
    "MedicalRecordNumber": "12345678",
    "FullName": "John Doe",
    "DateOfBirth": (+$HOROLOG - 10000),
    "WeightKg": 75,
    "HeightCm": 175
}
Set status = ##class(PatientTableModule).InsertPatient(patientData)

// Update patient weight
Set updateData = {"WeightKg": 77}
Set status = ##class(PatientTableModule).UpdatePatient(123, updateData)

// Delete patient (with referential integrity check)
Set status = ##class(PatientTableModule).DeletePatient(123)

// Get patients by age range
Set count = ##class(PatientTableModule).GetCountByAgeRange(20, 40)

// Calculate average patient age
Set avgAge = ##class(PatientTableModule).CalculateAverageAge()
```

## Comparison with Other Patterns

### Table Module vs Transaction Script

| Aspect | Table Module | Transaction Script |
|--------|--------------|-------------------|
| Organization | By database table | By use case/transaction |
| Reusability | High - methods shared across use cases | Low - procedure per use case |
| Structure | Object-oriented static methods | Procedural functions |
| Best For | Table-oriented operations | Simple procedural workflows |

### Table Module vs Domain Model

| Aspect | Table Module | Domain Model |
|--------|--------------|--------------|
| Instance Creation | No instances - static methods | Rich object instances |
| Business Logic | In table module class | In domain objects |
| Object Relationships | Handled via SQL joins | Object references |
| Complexity | Moderate | High |
| Best For | Set-based operations | Complex business rules |

### Pattern Selection Guide

```
Business Logic Complexity
│
│  Very Complex ──► Domain Model (rich objects, behavior)
│       │
│   Moderate ──────► Table Module (table-oriented, SQL)
│       │
│    Simple ───────► Transaction Script (procedural)
│
└─────────────────────────────────────────
```

## Consequences

### Benefits

✅ **Advantages:**
1. **SQL Efficiency**: Leverages database's set-based processing
2. **Simple Structure**: One class per table is easy to understand
3. **Reusable Operations**: Methods used across multiple use cases
4. **Performance**: Avoids overhead of creating many objects
5. **Natural Fit**: Aligns with relational database structure
6. **Team Familiarity**: Comfortable for SQL-oriented developers

### Liabilities

❌ **Drawbacks:**
1. **Limited Polymorphism**: Static methods don't support object-oriented patterns
2. **Anemic Domain**: Business logic separated from data
3. **Rigid Structure**: Tied to database table organization
4. **Testing Challenges**: Static methods harder to mock/test
5. **Scalability**: Complex domains become unwieldy
6. **No Object Identity**: Every call returns new data structure

## Known Uses

### Healthcare Information Systems
- Patient demographics management
- Laboratory result processing
- Prescription order management
- Claims processing systems

### Financial Applications
- Account transaction processing
- Customer portfolio management
- Transaction reconciliation
- Report generation systems

### Retail Systems
- Inventory management
- Product catalog operations
- Order processing
- Sales reporting

## Related Patterns

### Complementary Patterns

- **Data Mapper**: Table Module can use Data Mapper for persistence
- **Repository**: Can wrap Table Module for domain layer abstraction
- **Service Layer**: Coordinates multiple Table Modules for business operations
- **DTO (Data Transfer Object)**: Table Modules return DTOs/Dynamic Objects

### Alternative Patterns

- **Transaction Script**: Simpler procedural alternative
- **Domain Model**: Object-oriented alternative for complex domains
- **Active Record**: Combines table operations with instance behavior

## Implementation Checklist

- [ ] Create abstract TableModule base class
- [ ] Define TABLENAME and PRIMARYKEY parameters
- [ ] Implement core CRUD operations (FindById, Insert, Update, Delete)
- [ ] Create ResultSetRowToObject conversion utility
- [ ] Add custom query methods for specific table needs
- [ ] Implement validation in ValidateData method
- [ ] Add table-specific business operations
- [ ] Create comprehensive unit tests
- [ ] Document SQL query patterns and optimizations
- [ ] Test with realistic data volumes

## Performance Considerations

### Optimization Strategies

1. **Use Indices**: Create IRIS indices on frequently queried columns
2. **Batch Processing**: Process multiple records in single SQL statements
3. **Cursor Management**: Use cursors efficiently for large result sets
4. **Query Caching**: Cache frequently used query results
5. **Lazy Loading**: Load related data only when needed
6. **Connection Pooling**: Reuse database connections efficiently

### Monitoring

- Profile SQL query execution times
- Monitor result set sizes and memory usage
- Track method call frequencies
- Measure transaction duration
- Analyze query plan performance

## Testing Strategy

### Unit Test Coverage

```objectscript
/// Test FindById operation
Method TestFindById() As %Status
{
    // Create test patient
    Set tPatient = ##class(Patient).%New()
    Set tPatient.MedicalRecordNumber = "12345678"
    Set tSC = tPatient.%Save()
    Set tId = tPatient.%Id()
    
    // Test FindById
    Set tResult = ##class(PatientTableModule).FindById(tId)
    Do $$$AssertTrue($IsObject(tResult), "Patient found")
    Do $$$AssertEquals(tResult.MedicalRecordNumber, "12345678", "Correct data")
    
    // Cleanup
    Do ##class(Patient).%DeleteId(tId)
    Quit $$$OK
}
```

## Security Considerations

1. **SQL Injection Prevention**: Always use parameterized queries
2. **Data Validation**: Validate all inputs before SQL execution
3. **Access Control**: Implement table-level security checks
4. **Audit Logging**: Log all data modification operations
5. **Error Sanitization**: Don't expose internal SQL errors to users
6. **HIPAA Compliance**: Encrypt sensitive patient data

## References

- Fowler, Martin. *Patterns of Enterprise Application Architecture*. Addison-Wesley, 2002.
- Chapter on "Table Module" pattern
- Related patterns: Transaction Script, Domain Model
- IRIS SQL Documentation: InterSystems SQL Reference
- IRIS Performance Tuning Guide

## See Also

- [Transaction Script Pattern](transaction-script.md)
- [Domain Model Pattern](domain-model.md)
- [IRIS SQL Documentation](../../architecture/tech-stack.md)
- [Coding Standards](../../architecture/coding-standards.md)
