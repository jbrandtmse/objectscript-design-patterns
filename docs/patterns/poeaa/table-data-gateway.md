# Table Data Gateway Pattern

## Pattern Classification
- **Type**: Data Source Pattern
- **Category**: Patterns of Enterprise Application Architecture (PoEAA)
- **Complexity**: Low to Medium
- **Related Patterns**: Row Data Gateway, Active Record, Data Mapper

## Intent

An object that acts as a Gateway to a database table. One instance handles all the rows in the table.

## Also Known As

- Table Gateway
- Table Data Access Object
- Table DAO

## Motivation

Database access is one of the most common operations in enterprise applications. Without proper encapsulation, SQL queries can become scattered throughout the codebase, leading to:

- **Code Duplication**: The same SQL query written in multiple places
- **SQL Injection Vulnerabilities**: Direct string concatenation of user input into SQL
- **Maintenance Nightmares**: Changes to table structure require updates in many locations
- **Testing Difficulties**: Hard to mock or stub database operations
- **Business Logic Mixing**: Database access code intertwined with business rules

The Table Data Gateway pattern addresses these problems by:

1. **Centralizing SQL Access**: All SQL for a table lives in one class
2. **Enforcing Parameterization**: All queries use parameterized statements
3. **Simplifying Changes**: Table structure changes affect only the gateway
4. **Enabling Testing**: Gateways can be mocked or replaced with test implementations
5. **Separating Concerns**: Database access separated from business logic

### Real-World Healthcare Example

Consider a hospital system managing patient records. Without a Table Data Gateway, patient queries might be scattered across:

- Admission module: `SELECT * FROM Patient WHERE Status = 'Active'`
- Billing module: `SELECT * FROM Patient WHERE ID = ?`
- Reporting module: `SELECT COUNT(*) FROM Patient WHERE Department = ?`
- Scheduling module: `SELECT * FROM Patient WHERE LastName LIKE ?`

Each module duplicates SQL logic. If the Patient table structure changes, all these locations need updates.

With a Table Data Gateway, all patient data access goes through `PatientDataGateway`:

```objectscript
// Admission uses gateway
Set activePatients = ##class(PatientDataGateway).FindPatientsByStatus("Active")

// Billing uses gateway
Set patient = ##class(PatientDataGateway).FindPatientById(patientId)

// Reporting uses gateway
Set count = ##class(PatientDataGateway).GetPatientCountByDepartment("Cardiology")

// Scheduling uses gateway
Set smiths = ##class(PatientDataGateway).FindPatientsByLastName("Smith")
```

All SQL is centralized, parameterized, and maintainable.

## Applicability

Use the Table Data Gateway pattern when:

- You need to encapsulate access to a single database table
- SQL queries should be centralized for maintainability
- You want to prevent SQL injection through parameterized queries
- Business logic should be separated from data access logic
- The application uses a table-centric approach (not rich domain models)
- You need simple CRUD operations without complex object mapping

Don't use the Table Data Gateway pattern when:

- You have rich domain models (use Data Mapper instead)
- You need row-specific behavior (use Row Data Gateway instead)
- Domain objects should manage their own persistence (use Active Record instead)
- You're working with document databases or NoSQL (pattern is SQL-centric)
- You have complex object hierarchies requiring sophisticated mapping

## Structure

### Class Diagram

```
┌─────────────────────────────────┐
│    TableDataGateway             │
│    (Abstract Base Class)        │
├─────────────────────────────────┤
│ + TABLENAME : String            │
├─────────────────────────────────┤
│ + FindAll() : %List             │
│ + FindById(id) : %DynamicObject │
│ + FindWhere(clause, params)     │
│ + Insert(data) : String         │
│ + Update(id, data) : %Status    │
│ + Delete(id) : %Status          │
│ + ExecuteQuery(sql, params)     │
│ - MapResultToObject(result)     │
└─────────────────────────────────┘
           ▲
           │ extends
           │
┌─────────────────────────────────┐
│    PatientDataGateway           │
│    (Concrete Gateway)           │
├─────────────────────────────────┤
│ + TABLENAME = "Patient"         │
├─────────────────────────────────┤
│ + FindAllPatients()             │
│ + FindPatientById(id)           │
│ + FindPatientsByLastName(name)  │
│ + FindPatientsByDepartment(dep) │
│ + InsertPatient(data)           │
│ + UpdatePatient(id, data)       │
│ + DeletePatient(id)             │
│ + GetPatientCount()             │
│ + GetPatientCountByDepartment() │
└─────────────────────────────────┘
```

### Sequence Diagram - Find Operation

```
Client          Gateway              SQL.Statement        Database
  │                │                      │                   │
  │─FindPatients─>│                      │                   │
  │                │                      │                   │
  │                │──%New()───────────> │                   │
  │                │                      │                   │
  │                │──%Prepare(SQL)────> │                   │
  │                │                      │                   │
  │                │──%Execute(params)─> │                   │
  │                │                      │                   │
  │                │                      │──SELECT * FROM──>│
  │                │                      │                   │
  │                │                      │<─Result Set──────│
  │                │                      │                   │
  │                │──while %Next()────> │                   │
  │                │                      │                   │
  │                │──MapResultToObject─>│                   │
  │                │<─DynamicObject──────│                   │
  │                │                      │                   │
  │<─List─────────│                      │                   │
  │                │                      │                   │
```

## Participants

### TableDataGateway (Abstract Base Class)
- **Responsibility**: Provides common CRUD operations for all table gateways
- **Collaborators**: %SQL.Statement, %DynamicObject, %ListOfDataTypes
- **Key Methods**:
  - `FindAll()`: Returns all records from table
  - `FindById(id)`: Returns single record by ID
  - `FindWhere(clause, params)`: Custom queries with parameterization
  - `Insert(data)`: Creates new record
  - `Update(id, data)`: Modifies existing record
  - `Delete(id)`: Removes record
  - `MapResultToObject(result)`: Converts SQL result to object

### PatientDataGateway (Concrete Gateway)
- **Responsibility**: Encapsulates all Patient table access
- **Collaborators**: TableDataGateway (parent), Patient table
- **Key Methods**:
  - `FindPatientsByLastName(name)`: Healthcare-specific search
  - `FindPatientsByDepartment(dept)`: Department filtering
  - `GetPatientCount()`: Statistics method
  - All standard CRUD operations inherited from parent

### Client
- **Responsibility**: Business logic that needs patient data
- **Collaborators**: PatientDataGateway
- **Usage**: Calls gateway methods instead of writing SQL

## Collaborations

1. **Client requests data**: Client calls gateway method (e.g., `FindPatientsByLastName("Smith")`)
2. **Gateway prepares SQL**: Gateway builds parameterized SQL query
3. **Gateway executes query**: Uses %SQL.Statement with parameters
4. **Database returns results**: Result set from table
5. **Gateway maps results**: Converts rows to %DynamicObject instances
6. **Gateway returns data**: Client receives list of data objects

### Key Collaboration Rules

- **Stateless Gateway**: Gateway instances hold no data; all state is in the database
- **Transaction Neutral**: Gateway doesn't manage transactions; caller controls scope
- **Parameter Passing**: All user input passed as parameters, never concatenated
- **Result Mapping**: Gateway always returns %DynamicObject or collections, not persistent objects
- **Error Handling**: Gateway catches SQL errors and returns appropriate %Status or empty results

## Consequences

### Benefits

1. **Centralized SQL Management**
   - All SQL for a table in one class
   - Easy to locate and modify queries
   - Consistent query patterns across application

2. **SQL Injection Prevention**
   - All queries use parameterized statements
   - No string concatenation of user input
   - Enforced secure coding practice

3. **Improved Maintainability**
   - Table structure changes affect only the gateway
   - Easier to refactor and optimize queries
   - Single responsibility for data access

4. **Testability**
   - Can mock gateway for unit tests
   - Can create test implementation for integration tests
   - Can measure and profile database access

5. **Separation of Concerns**
   - Business logic doesn't contain SQL
   - Database access logic isolated
   - Clear architectural boundaries

6. **Simple API**
   - Intuitive method names (FindPatientsByLastName)
   - Returns simple data structures
   - Easy to understand and use

### Liabilities

1. **Not Object-Oriented**
   - Returns data structures, not rich domain objects
   - No object behavior, just data
   - Not suitable for complex domain models

2. **Potential Anemic Domain Model**
   - Can lead to transaction scripts instead of rich objects
   - Business logic may scatter if not careful
   - Doesn't enforce domain rules

3. **Table-Centric Design**
   - Tied to database schema
   - Changes to schema affect gateway
   - Not suitable for complex object graphs

4. **Limited Abstraction**
   - Client knows it's working with database tables
   - SQL concepts leak through (e.g., WHERE clauses)
   - Not fully database-agnostic

5. **Coarse-Grained Operations**
   - Fetches entire rows, not specific attributes
   - Can lead to over-fetching data
   - May need optimization for large tables

## Implementation in InterSystems IRIS

### Base Table Data Gateway Class

```objectscript
Class Patterns.PoEAA.DataSource.TableDataGateway Extends %RegisteredObject
{
    /// Table name - override in subclasses
    Parameter TABLENAME;
    
    /// Find all records
    ClassMethod FindAll() As %ListOfDataTypes
    {
        Set tList = ##class(%ListOfDataTypes).%New()
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT * FROM " _ ..#TABLENAME
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            Set tResult = tStatement.%Execute()
            While tResult.%Next() {
                Set tData = ..MapResultToObject(tResult)
                Do tList.Insert(tData)
            }
        }
        
        Quit tList
    }
    
    /// Find by ID - parameterized
    ClassMethod FindById(pId As %String) As %DynamicObject
    {
        Set tResult = ""
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT * FROM " _ ..#TABLENAME _ " WHERE ID = ?"
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            Set tRS = tStatement.%Execute(pId)
            If tRS.%Next() {
                Set tResult = ..MapResultToObject(tRS)
            }
        }
        
        Quit tResult
    }
    
    /// Insert new record
    ClassMethod Insert(pData As %DynamicObject) As %String
    {
        // Build dynamic INSERT with parameters
        // Returns new record ID
    }
    
    /// Map SQL result to dynamic object
    ClassMethod MapResultToObject(pResult) As %DynamicObject [ Private ]
    {
        Set tData = {}
        Set tMetadata = pResult.%GetMetadata()
        
        For tIdx = 1:1:tMetadata.columnCount {
            Set tColName = tMetadata.columns.GetAt(tIdx).colName
            Set tValue = pResult.%GetData(tIdx)
            Do tData.%Set(tColName, tValue)
        }
        
        Quit tData
    }
}
```

### Healthcare Patient Gateway Example

```objectscript
Class Patterns.Examples.Clinical.PatientDataGateway 
    Extends Patterns.PoEAA.DataSource.TableDataGateway
{
    Parameter TABLENAME = "Patterns_Examples_Clinical.Patient";
    
    /// Find patients by last name - healthcare-specific finder
    ClassMethod FindPatientsByLastName(pLastName As %String) As %ListOfDataTypes
    {
        Set tParams = 1
        Set tParams(1) = pLastName
        Quit ..FindWhere("LastName = ?", .tParams)
    }
    
    /// Find patients by department - healthcare-specific finder
    ClassMethod FindPatientsByDepartment(pDept As %String) As %ListOfDataTypes
    {
        Set tParams = 1
        Set tParams(1) = pDept
        Quit ..FindWhere("Department = ?", .tParams)
    }
    
    /// Get patient count - statistics method
    ClassMethod GetPatientCount() As %Integer
    {
        Set tCount = 0
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT COUNT(*) AS PatientCount FROM " _ ..#TABLENAME
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            Set tResult = tStatement.%Execute()
            If tResult.%Next() {
                Set tCount = tResult.%Get("PatientCount")
            }
        }
        
        Quit tCount
    }
}
```

### Usage Example

```objectscript
// Find all active patients in Cardiology
Set allPatients = ##class(PatientDataGateway).FindPatientsByDepartment("Cardiology")

// Find specific patient
Set patient = ##class(PatientDataGateway).FindPatientById("123")
Write "Patient: ", patient.FirstName, " ", patient.LastName

// Insert new patient
Set newPatient = {
    "FirstName": "John",
    "LastName": "Doe",
    "MRN": "MRN12345",
    "Department": "Emergency",
    "Status": "Active"
}
Set newId = ##class(PatientDataGateway).InsertPatient(newPatient)

// Update patient status
Set updateData = {"Status": "Discharged"}
Set status = ##class(PatientDataGateway).UpdatePatient(newId, updateData)

// Get statistics
Set totalPatients = ##class(PatientDataGateway).GetPatientCount()
Set cardioCount = ##class(PatientDataGateway).GetPatientCountByDepartment("Cardiology")
```

## Implementation Considerations

### 1. IRIS Embedded SQL Integration

IRIS provides excellent SQL capabilities through:

- **Embedded SQL**: `&sql()` tag for simple queries
- **Dynamic SQL**: `%SQL.Statement` for parameterized queries
- **Result Sets**: `%SQL.StatementResult` for multi-row results
- **SQL Projections**: Persistent classes automatically project to SQL tables

Table Data Gateway leverages `%SQL.Statement` for:
- Parameterized query support (SQL injection prevention)
- Dynamic query construction
- Result set processing
- Metadata access for column mapping

### 2. Parameterized Query Enforcement

**CRITICAL**: All queries MUST use parameterized syntax:

```objectscript
// GOOD - Parameterized (SQL injection safe)
Set tSQL = "SELECT * FROM Patient WHERE LastName = ?"
Set tResult = tStatement.%Execute(pLastName)

// BAD - String concatenation (SQL injection vulnerable)
Set tSQL = "SELECT * FROM Patient WHERE LastName = '" _ pLastName _ "'"
```

The `?` placeholder ensures user input is properly escaped.

### 3. Result Set to Object Mapping

The `MapResultToObject()` method converts SQL result rows to %DynamicObject:

```objectscript
ClassMethod MapResultToObject(pResult) As %DynamicObject
{
    Set tData = {}
    Set tMetadata = pResult.%GetMetadata()
    
    For tIdx = 1:1:tMetadata.columnCount {
        Set tColName = tMetadata.columns.GetAt(tIdx).colName
        Set tValue = pResult.%GetData(tIdx)
        Do tData.%Set(tColName, tValue)
    }
    
    Quit tData
}
```

This creates a flexible JSON-like object with all column values.

### 4. Transaction Scope

Table Data Gateways are **transaction neutral**:

- Gateway methods don't start transactions
- Caller controls transaction scope
- Multiple gateway calls can be in single transaction

```objectscript
// Caller manages transaction
TSTART
Try {
    Set id1 = ##class(PatientDataGateway).InsertPatient(patient1)
    Set id2 = ##class(PatientDataGateway).InsertPatient(patient2)
    TCOMMIT
} Catch ex {
    TROLLBACK
}
```

### 5. Error Handling Patterns

Gateways handle SQL errors gracefully:

- **Find operations**: Return empty results on error
- **CUD operations**: Return %Status with error details
- **Count operations**: Return 0 on error
- **Logging**: Errors logged to ^ClineDebug or proper logging system

### 6. Performance Optimization

- **Use indices**: Leverage IRIS indices for WHERE clause columns
- **Prepared statements**: Reuse %SQL.Statement for repeated queries
- **Batch operations**: Use transactions for multiple inserts/updates
- **COUNT queries**: Use SQL COUNT instead of fetching all rows
- **Column selection**: Select specific columns instead of SELECT *

## Sample Code

See implementation files:
- `src/Patterns/PoEAA/DataSource/TableDataGateway.cls` - Base gateway class
- `src/Patterns/Examples/Clinical/PatientDataGateway.cls` - Healthcare example
- `src/Patterns/Test/Unit/PoEAA/DataSource/TableDataGatewayTest.cls` - Comprehensive tests

## Known Uses

### Healthcare Systems
- **Patient Data Access**: Centralized patient record queries
- **Appointment Management**: Scheduling table access
- **Billing Records**: Invoice and payment table access
- **Lab Results**: Laboratory data table access

### Enterprise Applications
- **User Management**: User account table access
- **Order Processing**: Order and order line table access
- **Inventory Systems**: Product and stock table access
- **Reporting Systems**: Statistics and summary table access

### InterSystems IRIS Applications
- Integration with IRIS SQL capabilities
- Persistent class table projections
- Healthcare data access in HealthShare environments
- Clinical data repositories

## Related Patterns

### Row Data Gateway
- **Difference**: Row Data Gateway has one instance per row; Table Data Gateway has one instance per table
- **When to use Row Gateway**: When you need row-specific behavior and state
- **When to use Table Gateway**: When you need stateless, table-wide operations

### Active Record
- **Difference**: Active Record combines data access and domain logic; Table Gateway separates them
- **When to use Active Record**: When domain objects should manage their own persistence
- **When to use Table Gateway**: When separating data access from business logic

### Data Mapper
- **Difference**: Data Mapper returns rich domain objects; Table Gateway returns simple data structures
- **When to use Data Mapper**: When you have complex domain models
- **When to use Table Gateway**: When you have simple, table-centric operations

### Repository Pattern
- **Similarity**: Both encapsulate data access
- **Difference**: Repository is collection-oriented; Table Gateway is table-oriented
- **Relationship**: Repository can be implemented using Table Data Gateway

## When to Use vs Other Patterns

### Use Table Data Gateway when:
- ✅ Simple CRUD operations on tables
- ✅ Transaction Script domain logic pattern
- ✅ SQL-centric application design
- ✅ Need to centralize SQL queries
- ✅ Stateless data access required

### Use Row Data Gateway when:
- ✅ Need one gateway instance per database row
- ✅ Row-specific behavior and state
- ✅ Working with individual records frequently

### Use Active Record when:
- ✅ Domain objects should save themselves
- ✅ Simple domain logic closely tied to data
- ✅ Rapid application development

### Use Data Mapper when:
- ✅ Rich domain model separate from database
- ✅ Complex object-relational mapping
- ✅ Domain objects shouldn't know about persistence

## Summary

The Table Data Gateway pattern provides a clean, maintainable way to encapsulate database table access. By centralizing SQL queries, enforcing parameterization, and separating data access from business logic, it creates a solid foundation for data-driven applications.

**Key Takeaways:**

1. **One gateway per table** - Clear responsibility boundaries
2. **All SQL centralized** - Easy to find and maintain queries
3. **Parameterized queries** - SQL injection prevention built-in
4. **Returns data structures** - Simple %DynamicObject results
5. **Stateless and transaction neutral** - Flexible usage patterns
6. **IRIS SQL integration** - Leverages platform capabilities

The pattern works exceptionally well in IRIS with its embedded SQL capabilities and is particularly valuable for healthcare applications requiring robust, auditable data access.
