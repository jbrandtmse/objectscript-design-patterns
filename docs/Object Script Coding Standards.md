# InterSystems ObjectScript Coding Standards

Version 1.0 | Last Updated: August 2025

## Table of Contents

1. [Introduction & Purpose](#introduction--purpose)
2. [Naming Conventions](#naming-conventions)
3. [Code Formatting & Style](#code-formatting--style)
4. [Documentation Standards](#documentation-standards)
5. [Programming Practices](#programming-practices)
6. [Class Design Standards](#class-design-standards)
7. [Interoperability & Integration](#interoperability--integration)
8. [Performance Guidelines](#performance-guidelines)
9. [Security Standards](#security-standards)
10. [Testing Standards](#testing-standards)
11. [Version Control & Deployment](#version-control--deployment)
12. [Code Organization](#code-organization)
13. [Common Patterns & Anti-patterns](#common-patterns--anti-patterns)
14. [Tools & Development Environment](#tools--development-environment)
15. [Appendices](#appendices)

---

## 1. Introduction & Purpose

### Purpose
This document establishes coding standards for InterSystems ObjectScript development to ensure:
- Code consistency across teams and projects
- Improved code readability and maintainability
- Reduced bugs and technical debt
- Simplified onboarding for new developers
- Better integration with InterSystems IRIS platform features

### Scope
These standards apply to all ObjectScript development including:
- IRIS database applications
- Interoperability productions
- REST APIs and web services
- Business logic and data transformations
- Unit tests and utilities

### Benefits
- **Consistency**: Uniform code style across the organization
- **Quality**: Reduced defects through proven practices
- **Efficiency**: Faster development and code reviews
- **Maintainability**: Easier long-term code maintenance
- **Knowledge Transfer**: Simplified team collaboration

---

## 2. Naming Conventions

### Classes
```objectscript
// Good: PascalCase with clear package structure
Class MyCompany.Patient.Demographics Extends %Persistent
```

**Rules:**
- Use PascalCase for class names
- Use dot notation for package hierarchy
- Avoid special characters except dots
- Keep names descriptive but concise
- Maximum 60 characters for full class name

### Methods

```objectscript
// ClassMethod: PascalCase
ClassMethod CalculateTotalAmount(pOrderId As %Integer) As %Decimal
{
    // Implementation
}

// Instance Method: camelCase
Method validateUserInput() As %Status
{
    // Implementation
}
```

### Properties

```objectscript
// Properties: PascalCase
Property FirstName As %String(MAXLEN = 50);
Property DateOfBirth As %Date;
Property IsActive As %Boolean [ InitialExpression = 1 ];
```

### Variables

```objectscript
// Parameters: 'p' prefix
ClassMethod ProcessOrder(pOrderId As %Integer, pStatus As %String)

// Local variables: 't' prefix
Set tCounter = 0
Set tResultSet = ##class(%SQL.Statement).%ExecDirect(,tSQL)

// Loop variables: 'i', 'j', 'k' or descriptive
For i=1:1:tCount {
    // Process
}
```

### Globals

```objectscript
// Global variables: Descriptive with caps
Set ^MYAPP.CONFIG("timeout") = 30
Set ^TEMP.PROCESS($Job, "status") = "running"

// System globals: Follow InterSystems conventions
// ^%SYS, ^%qCacheTemp, etc.
```

### Constants/Parameters

```objectscript
// Class parameters: UPPERCASE
Parameter MAXRECORDS = 1000;
Parameter DEFAULTNAMESPACE = "USER";

// Access using #
Set tLimit = ..#MAXRECORDS
```

### Package Structure

```
MyCompany.
├── Data.           // Persistent classes
│   ├── Patient
│   └── Provider
├── Business.       // Business logic
│   ├── Service
│   └── Process
├── REST.          // REST APIs
├── Utility.       // Helper classes
└── Test.          // Unit tests
```

---

## 3. Code Formatting & Style

### Indentation

```objectscript
Class Example.CodeStyle
{

Method DemoIndentation() As %Status
{
    Set tSC = $$$OK
    Try {
        If (condition) {
            // Use 4 spaces or 1 tab consistently
            Write "Indented code block",!
            
            For i=1:1:10 {
                Write i,!
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
```

### Line Length
- Maximum 120 characters per line when possible
- Break long lines at logical points
- Indent continuation lines

```objectscript
// Break long method calls
Set tResult = ##class(Very.Long.Package.Name).VeryLongMethodName(
    pFirstParameter,
    pSecondParameter,
    pThirdParameter)

// Break long SQL statements
Set tSQL = "SELECT PatientID, FirstName, LastName, DateOfBirth "_
          "FROM Patient.Demographics "_
          "WHERE IsActive = 1 "_
          "ORDER BY LastName, FirstName"
```

### Whitespace

```objectscript
// Spaces around operators
Set tTotal = tPrice + tTax
Set tIsValid = (tValue > 0) && (tValue < 100)

// Spaces after commas
Write tFirst, tSecond, tThird

// No space before comma or semicolon
Set tName = "John"; Set tAge = 30

// Blank lines between logical sections
Method ProcessData() As %Status
{
    // Initialize
    Set tSC = $$$OK
    Set tCount = 0
    
    // Process records
    While (tRS.%Next()) {
        // Processing logic
    }
    
    // Return result
    Quit tSC
}
```

### Command Casing

```objectscript
// ObjectScript commands: UPPERCASE
SET tValue = 100
WRITE "Output",!
IF (condition) {
    DO ..ProcessRecord()
}
QUIT tSC

// Alternative: Initial caps (choose one style)
Set tValue = 100
Write "Output",!
If (condition) {
    Do ..ProcessRecord()
}
Quit tSC
```

---

## 4. Documentation Standards

### Class Documentation

```objectscript
/// <class>Patient.Demographics</class>
/// <description>
/// This class represents patient demographic information
/// including personal details, contact information, and 
/// insurance data.
/// </description>
/// <example>
/// Set patient = ##class(Patient.Demographics).%New()
/// Set patient.FirstName = "John"
/// Set patient.LastName = "Doe"
/// Set sc = patient.%Save()
/// </example>
/// <version>1.0</version>
/// <author>John Developer</author>
Class Patient.Demographics Extends %Persistent
{
    // Class implementation
}
```

### Method Documentation

```objectscript
/// <method>CalculateAge</method>
/// <description>
/// Calculates patient age based on date of birth
/// </description>
/// <parameters>
/// pDOB - Date of birth in IRIS date format
/// pAsOfDate - Optional reference date (defaults to today)
/// </parameters>
/// <returns>Age in years as integer</returns>
/// <example>
/// Set age = ##class(Patient.Demographics).CalculateAge(45678)
/// </example>
ClassMethod CalculateAge(pDOB As %Date, pAsOfDate As %Date = "") As %Integer
{
    // Implementation
}
```

### Inline Comments

```objectscript
Method ProcessOrder() As %Status
{
    Set tSC = $$$OK
    
    // Validate order before processing
    Set tSC = ..ValidateOrder()
    If $$$ISERR(tSC) Quit tSC
    
    // Calculate totals including tax
    // Note: Tax rate retrieved from configuration
    Set tTaxRate = ..GetTaxRate()
    Set tSubtotal = ..CalculateSubtotal()
    Set tTax = tSubtotal * tTaxRate
    Set tTotal = tSubtotal + tTax  ; Final amount
    
    // TODO: Add discount calculation
    // FIXME: Handle currency conversion
    
    Quit tSC
}
```

### Comment Standards
- Use `///` for method/class documentation
- Use `//` for block comments
- Use `;` for single line comments
- Use `;` for end-of-line comments
- Keep comments concise and meaningful
- Update comments when code changes
- Remove commented-out code before commit

---

## 5. Programming Practices

### Status Codes

```objectscript
Method SaveRecord() As %Status
{
    // Always initialize status
    Set tSC = $$$OK
    
    Try {
        // Perform operations
        Set tSC = ..ValidateData()
        If $$$ISERR(tSC) Quit
        
        Set tSC = ..%Save()
        If $$$ISERR(tSC) Quit
        
        // Chain status codes
        Set tSC = $$$ADDSC(tSC, ..SendNotification())
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    // Always return status
    Quit tSC
}
```

### Error Handling

```objectscript
Method SafeOperation() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Risky operations in Try block
        Set tFile = ##class(%File).%New(pFilename)
        Set tSC = tFile.Open("R")
        If $$$ISERR(tSC) {
            // Create custom error
            Set tSC = $$$ERROR($$$GeneralError, "Cannot open file: "_pFilename)
            Quit
        }
        
        // Process file
        While 'tFile.AtEnd {
            Set tLine = tFile.ReadLine()
            Do ..ProcessLine(tLine)
        }
    }
    Catch ex {
        // Log error details
        Do ##class(%SYS.System).WriteToConsoleLog(ex.DisplayString())
        Set tSC = ex.AsStatus()
    }
    Finally {
        // Cleanup resources
        If $IsObject($Get(tFile)) {
            Do tFile.Close()
        }
    }
    
    Quit tSC
}
```

### Macros

```objectscript
// Define custom macros
#define APPNAME "MyApplication"
#define MAXRETRIES 3
#define LogInfo(%msg) Do ##class(Util.Logger).LogInfo(%msg)

// Use macros
Method ProcessWithRetry() As %Status
{
    Set tSC = $$$OK
    
    For tRetry=1:1:$$$MAXRETRIES {
        $$$LogInfo("Attempt "_tRetry_" of "_$$$MAXRETRIES)
        
        Set tSC = ..AttemptProcess()
        If $$$ISOK(tSC) Quit
        
        // Wait before retry
        Hang 2
    }
    
    Quit tSC
}
```

### SQL Usage

**Important:** Embedded/Compiled SQL (&sql syntax) is preferred over dynamic SQL for simple queries and updates with few or no parameters due to better performance and compile-time optimization.

```objectscript
// PREFERRED: Embedded SQL for simple queries
// - Better performance (compiled and optimized at compile time)
// - Cleaner syntax for simple operations
// - Automatic type checking
Method GetPatientCount() As %Integer [ SqlProc ]
{
    &sql(SELECT COUNT(*) INTO :tCount 
         FROM Patient.Demographics
         WHERE IsActive = 1)
    
    If SQLCODE'=0 {
        Set tCount = 0
    }
    
    Quit tCount
}

// PREFERRED: Embedded SQL for simple updates
Method UpdatePatientStatus(pPatientId As %Integer, pStatus As %String) As %Status
{
    &sql(UPDATE Patient.Demographics 
         SET Status = :pStatus,
             ModifiedDate = CURRENT_TIMESTAMP
         WHERE ID = :pPatientId)
    
    If SQLCODE = 0 {
        Quit $$$OK
    } Else {
        Quit $$$ERROR($$$GeneralError, "Failed to update patient status: SQLCODE="_SQLCODE)
    }
}

// PREFERRED: Embedded SQL for single record lookups
Method GetPatientName(pPatientId As %Integer, Output pFirstName As %String, Output pLastName As %String) As %Status
{
    &sql(SELECT FirstName, LastName 
         INTO :pFirstName, :pLastName
         FROM Patient.Demographics
         WHERE ID = :pPatientId)
    
    If SQLCODE = 0 {
        Quit $$$OK
    } ElseIf SQLCODE = 100 {
        Quit $$$ERROR($$$GeneralError, "Patient not found")
    } Else {
        Quit $$$ERROR($$$GeneralError, "Database error: SQLCODE="_SQLCODE)
    }
}

// USE DYNAMIC SQL WHEN: Complex queries with variable conditions
// - Dynamic WHERE clauses
// - Variable column lists
// - Runtime-determined table names
// - Complex parameterized queries with many parameters
ClassMethod SearchPatients(pFilters As %DynamicObject) As %SQL.StatementResult
{
    Set tSQL = "SELECT ID, FirstName, LastName, DateOfBirth "_
              "FROM Patient.Demographics WHERE 1=1"
    Set tParams = []
    
    // Build dynamic WHERE clause based on filters
    If pFilters.%IsDefined("lastName") {
        Set tSQL = tSQL_" AND LastName LIKE ?"
        Do tParams.%Push(pFilters.lastName_"%")
    }
    If pFilters.%IsDefined("city") {
        Set tSQL = tSQL_" AND City = ?"
        Do tParams.%Push(pFilters.city)
    }
    If pFilters.%IsDefined("ageMin") {
        Set tSQL = tSQL_" AND DATEDIFF('year', DateOfBirth, CURRENT_DATE) >= ?"
        Do tParams.%Push(pFilters.ageMin)
    }
    
    Set tSQL = tSQL_" ORDER BY LastName, FirstName"
    
    Set tStatement = ##class(%SQL.Statement).%New()
    Set tSC = tStatement.%Prepare(tSQL)
    If $$$ISERR(tSC) Quit $$$NULLOREF
    
    Set tResult = tStatement.%Execute(tParams...)
    Quit tResult
}

// USE DYNAMIC SQL WHEN: Preventing SQL injection with user input
ClassMethod GetPatientsByDynamicCriteria(pColumn As %String, pValue As %String) As %SQL.StatementResult
{
    // When column name comes from user input, use dynamic SQL with parameters
    Set tAllowedColumns = $ListBuild("FirstName", "LastName", "City", "State")
    If '$ListFind(tAllowedColumns, pColumn) {
        Throw ##class(%Exception.General).%New("Invalid column name")
    }
    
    Set tSQL = "SELECT * FROM Patient.Demographics WHERE "_pColumn_" = ?"
    
    Set tStatement = ##class(%SQL.Statement).%New()
    Set tSC = tStatement.%Prepare(tSQL)
    If $$$ISERR(tSC) Quit $$$NULLOREF
    
    Set tResult = tStatement.%Execute(pValue)
    Quit tResult
}
```

#### SQL Best Practices Summary

| Use Case | Recommended Approach | Reason |
|----------|---------------------|---------|
| Simple SELECT/INSERT/UPDATE/DELETE | Embedded SQL (&sql) | Compiled, optimized, cleaner syntax |
| Single record lookups | Embedded SQL (&sql) | Better performance, simpler code |
| Fixed queries with 0-3 parameters | Embedded SQL (&sql) | Compile-time optimization |
| Dynamic WHERE clauses | Dynamic SQL | Flexibility required |
| Variable column lists | Dynamic SQL | Runtime determination |
| Complex multi-parameter queries | Dynamic SQL | Better parameter management |
| User-provided column/table names | Dynamic SQL with validation | Security (prevent SQL injection) |

### Transactions

```objectscript
Method TransferFunds(pFromAccount, pToAccount, pAmount) As %Status
{
    Set tSC = $$$OK
    
    // Start transaction
    TSTART
    
    Try {
        // Debit from account
        Set tSC = ..DebitAccount(pFromAccount, pAmount)
        If $$$ISERR(tSC) {
            TROLLBACK
            Quit
        }
        
        // Credit to account
        Set tSC = ..CreditAccount(pToAccount, pAmount)
        If $$$ISERR(tSC) {
            TROLLBACK
            Quit
        }
        
        // Commit if successful
        TCOMMIT
    }
    Catch ex {
        TROLLBACK
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}
```

---

## 6. Class Design Standards

### Inheritance

```objectscript
// Base class with common functionality
Class Company.Base.AuditableRecord Extends %Persistent [ Abstract ]
{
    Property CreatedDate As %TimeStamp [ InitialExpression = {$ZDateTime($H,3)} ];
    Property CreatedBy As %String;
    Property ModifiedDate As %TimeStamp;
    Property ModifiedBy As %String;
    
    Method %OnAddToSaveSet(depth As %Integer = 3) As %Status
    {
        Set ..ModifiedDate = $ZDateTime($H,3)
        Set ..ModifiedBy = $Username
        Quit $$$OK
    }
}

// Concrete implementation
Class Company.Patient Extends Company.Base.AuditableRecord
{
    Property Name As %String(MAXLEN = 100);
    Property DateOfBirth As %Date;
}
```

### Properties

```objectscript
Class Example.PropertyStandards
{
    // Simple properties
    Property Code As %String(MAXLEN = 10, MINLEN = 3) [ Required ];
    Property Description As %String(MAXLEN = 200);
    Property IsActive As %Boolean [ InitialExpression = 1 ];
    
    // Calculated property
    Property Age As %Integer [ Calculated, SqlComputeCode = {Set {Age} = ..CalculateAge({DateOfBirth})}, SqlComputed ];
    
    // Private property
    Property InternalStatus As %String [ Private ];
    
    // Collection properties
    Property Tags As list Of %String;
    Property Attributes As array Of %String;
    
    // Relationship properties
    Relationship Orders As Order.Header [ Cardinality = children, Inverse = Patient ];
}
```

### Indexes

```objectscript
Class Example.IndexStandards
{
    Property Code As %String;
    Property Name As %String;
    Property Category As %String;
    Property IsActive As %Boolean;
    
    // Primary key
    Index PK On Code [ PrimaryKey ];
    
    // Unique index
    Index NameIndex On Name [ Unique ];
    
    // Standard index
    Index CategoryIndex On Category;
    
    // Bitmap index for boolean
    Index ActiveIndex On IsActive [ Type = bitmap ];
    
    // Compound index
    Index CatActiveIndex On (Category, IsActive);
    
    // Functional index
    Index UpperNameIndex On $ZCVT(Name,"U");
}
```

### Queries

```objectscript
Class Example.QueryStandards
{
    /// Custom query using SQL
    Query ActivePatients() As %SQLQuery
    {
        SELECT ID, Name, DateOfBirth
        FROM Patient
        WHERE IsActive = 1
        ORDER BY Name
    }
    
    /// Custom query with parameters
    Query PatientsByCategory(pCategory As %String) As %SQLQuery
    {
        SELECT ID, Name, Category
        FROM Patient
        WHERE Category = :pCategory
        AND IsActive = 1
    }
    
    /// Class query implementation
    Query CustomQuery() As %Query
    {
    }
    
    ClassMethod CustomQueryExecute(ByRef qHandle As %Binary) As %Status
    {
        // Initialize query
        Quit $$$OK
    }
    
    ClassMethod CustomQueryFetch(ByRef qHandle As %Binary, 
                                  ByRef Row As %List, 
                                  ByRef AtEnd As %Integer = 0) As %Status
    {
        // Fetch next row
        Quit $$$OK
    }
    
    ClassMethod CustomQueryClose(ByRef qHandle As %Binary) As %Status
    {
        // Cleanup
        Quit $$$OK
    }
}
```

---

## 7. Interoperability & Integration

### Business Services

```objectscript
Class Production.Service.FileService Extends Ens.BusinessService
{
    Parameter ADAPTER = "EnsLib.File.InboundAdapter";
    
    Property TargetOperation As %String;
    
    Parameter SETTINGS = "TargetOperation:Basic";
    
    Method OnProcessInput(pInput As %RegisteredObject, 
                          Output pOutput As %RegisteredObject) As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Create request message
            Set tRequest = ##class(Production.Message.FileRequest).%New()
            Set tRequest.Filename = pInput.Name
            Set tRequest.Content = pInput.Stream
            
            // Send to operation
            Set tSC = ..SendRequestSync(..TargetOperation, tRequest, .tResponse)
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}
```

### Message Classes

```objectscript
// Request message
Class Production.Message.ProcessRequest Extends Ens.Request
{
    Property PatientID As %String;
    Property Action As %String(VALUELIST = ",CREATE,UPDATE,DELETE");
    Property Data As %String(MAXLEN = "");
}

// Response message
Class Production.Message.ProcessResponse Extends Ens.Response
{
    Property Success As %Boolean;
    Property Message As %String;
    Property ResultCode As %String;
}
```

### Business Operations

```objectscript
Class Production.Operation.DatabaseOperation Extends Ens.BusinessOperation
{
    Method ProcessRequest(pRequest As Production.Message.ProcessRequest, 
                         Output pResponse As Production.Message.ProcessResponse) As %Status
    {
        Set tSC = $$$OK
        Set pResponse = ##class(Production.Message.ProcessResponse).%New()
        
        Try {
            If pRequest.Action = "CREATE" {
                Set tSC = ..CreateRecord(pRequest.Data)
            }
            ElseIf pRequest.Action = "UPDATE" {
                Set tSC = ..UpdateRecord(pRequest.PatientID, pRequest.Data)
            }
            ElseIf pRequest.Action = "DELETE" {
                Set tSC = ..DeleteRecord(pRequest.PatientID)
            }
            
            Set pResponse.Success = $$$ISOK(tSC)
            Set pResponse.Message = $Select($$$ISOK(tSC):"Success", 1:$System.Status.GetErrorText(tSC))
        }
        Catch ex {
            Set tSC = ex.AsStatus()
            Set pResponse.Success = 0
            Set pResponse.Message = ex.DisplayString()
        }
        
        Quit tSC
    }
}
```

### External Language Integration

```objectscript
// Python integration
Class Example.PythonIntegration
{
    ClassMethod CallPython() As %String [ Language = python ]
    {
        import json
        import requests
        
        # Python code here
        response = requests.get('https://api.example.com/data')
        data = response.json()
        
        return json.dumps(data)
    }
    
    // Calling Python from ObjectScript
    ClassMethod UsePython() As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Import Python module
            Set tModule = ##class(%SYS.Python).Import("datetime")
            
            // Use Python functionality
            Set tNow = tModule.datetime.now()
            Write "Current time from Python: ", tNow.isoformat(),!
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}
```

---

## 8. Performance Guidelines

### Global Access Optimization

```objectscript
// Inefficient: Multiple global references
Method InefficientMethod()
{
    For i=1:1:1000 {
        Set ^DATA("record", i, "field1") = "value1"
        Set ^DATA("record", i, "field2") = "value2"
        Set ^DATA("record", i, "field3") = "value3"
    }
}

// Efficient: Minimize global references
Method EfficientMethod()
{
    For i=1:1:1000 {
        Set tData = $ListBuild("value1", "value2", "value3")
        Set ^DATA("record", i) = tData
    }
}

// Use local arrays for batch operations
Method BatchProcess()
{
    // Collect in local array
    For i=1:1:1000 {
        Set tLocal(i) = ..ProcessRecord(i)
    }
    
    // Write to global in one operation
    Merge ^DATA = tLocal
}
```

### SQL Performance

```objectscript
// PERFORMANCE TIP: Use embedded SQL for simple queries (see Section 5 - SQL Usage)
// Embedded SQL is compiled and optimized at compile time
Method GetActiveCount() As %Integer
{
    // GOOD: Embedded SQL - compiled and optimized
    &sql(SELECT COUNT(*) INTO :tCount FROM Performance.OptimizedTable WHERE Status = 'ACTIVE')
    Quit tCount
}

// Use appropriate indexes
Class Performance.OptimizedTable Extends %Persistent
{
    Property Status As %String;
    Property ProcessDate As %Date;
    
    // Index for frequent queries
    Index StatusDateIndex On (Status, ProcessDate);
    
    // For complex dynamic queries, use Dynamic SQL
    ClassMethod GetRecordsByStatusAndDate(pStatus, pDate) As %ResultSet
    {
        // Dynamic SQL appropriate here if query structure varies
        Set tSQL = "SELECT * FROM Performance.OptimizedTable "_
                  "WHERE Status = ? AND ProcessDate >= ? "_
                  "ORDER BY ProcessDate"
        
        // This will use StatusDateIndex
        Set tRS = ##class(%SQL.Statement).%ExecDirect(, tSQL, pStatus, pDate)
        Quit tRS
    }
}

// Avoid SELECT * 
// Be specific about columns needed
ClassMethod GetPatientNames() As %ResultSet
{
    // Good: Select only needed columns
    Set tSQL = "SELECT ID, FirstName, LastName FROM Patient"
    
    // Bad: Select all columns
    // Set tSQL = "SELECT * FROM Patient"
    
    Quit ##class(%SQL.Statement).%ExecDirect(, tSQL)
}

// Batch operations: Use embedded SQL for better performance
Method UpdateBatchStatus(pIDList As %List, pNewStatus As %String) As %Status
{
    Set tSC = $$$OK
    
    For i=1:1:$ListLength(pIDList) {
        Set tID = $List(pIDList, i)
        
        // Embedded SQL for each update - compiled once, executed many times
        &sql(UPDATE Performance.OptimizedTable 
             SET Status = :pNewStatus 
             WHERE ID = :tID)
        
        If SQLCODE '= 0 {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to update ID "_tID)
            Quit
        }
    }
    
    Quit tSC
}
```

### Caching Strategies

```objectscript
Class Cache.Manager
{
    // Simple time-based cache
    ClassMethod GetCachedData(pKey As %String) As %String
    {
        // Check if cache exists and is valid
        If $Data(^CACHE(pKey), tData) {
            Set tTimestamp = $Piece(tData, "||", 1)
            Set tValue = $Piece(tData, "||", 2)
            
            // Cache valid for 5 minutes (300 seconds)
            If ($ZH - tTimestamp) < 300 {
                Quit tValue
            }
        }
        
        // Generate fresh data
        Set tValue = ..GenerateData(pKey)
        
        // Store in cache with timestamp
        Set ^CACHE(pKey) = $ZH_"||"_tValue
        
        Quit tValue
    }
    
    // Clear cache
    ClassMethod ClearCache(pPattern As %String = "")
    {
        If pPattern = "" {
            Kill ^CACHE
        } Else {
            // Clear specific pattern
            Set tKey = $Order(^CACHE(pPattern), -1)
            While tKey '= "" {
                If tKey [ pPattern {
                    Kill ^CACHE(tKey)
                }
                Set tKey = $Order(^CACHE(tKey))
            }
        }
    }
}
```

---

## 9. Security Standards

### Input Validation

```objectscript
Class Security.InputValidator
{
    /// Validate and sanitize user input
    ClassMethod ValidateInput(pInput As %String, pType As %String) As %String
    {
        Set tClean = $ZStrip(pInput, "<>W")  // Remove leading/trailing whitespace
        
        // Type-specific validation
        If pType = "EMAIL" {
            If '..IsValidEmail(tClean) {
                Throw ##class(%Exception.General).%New("Invalid email format")
            }
        }
        ElseIf pType = "PHONE" {
            Set tClean = $ZStrip(tClean, "*", "- ()")  // Remove formatting
            If '..IsValidPhone(tClean) {
                Throw ##class(%Exception.General).%New("Invalid phone number")
            }
        }
        ElseIf pType = "ALPHANUMERIC" {
            Set tClean = $ZStrip(tClean, "*E'N'A")  // Keep only alphanumeric
        }
        
        // Check for SQL injection patterns
        If ..ContainsSQLInjection(tClean) {
            Throw ##class(%Exception.General).%New("Invalid input detected")
        }
        
        Quit tClean
    }
    
    ClassMethod ContainsSQLInjection(pInput As %String) As %Boolean
    {
        Set tPatterns = $ListBuild("DROP ", "DELETE ", "INSERT ", "UPDATE ", "--", "/*", "*/", "xp_", "sp_")
        
        Set tUpper = $ZConvert(pInput, "U")
        Set ptr = 0
        While $ListNext(tPatterns, ptr, tPattern) {
            If tUpper [ tPattern Quit 1
        }
        
        Quit 0
    }
}
```

### Authentication/Authorization

```objectscript
Class Security.AccessControl
{
    /// Check user permissions
    ClassMethod HasPermission(pResource As %String, pAction As %String) As %Boolean
    {
        // Get current user
        Set tUser = $Username
        
        // Check if user has role
        Set tHasAccess = 0
        
        &sql(SELECT COUNT(*) INTO :tCount
             FROM Security.UserRole ur
             JOIN Security.RolePermission rp ON ur.RoleID = rp.RoleID
             JOIN Security.Permission p ON rp.PermissionID = p.ID
             WHERE ur.Username = :tUser
             AND p.Resource = :pResource
             AND p.Action = :pAction)
        
        If SQLCODE = 0, tCount > 0 {
            Set tHasAccess = 1
        }
        
        // Audit access attempt
        Do ..AuditAccess(tUser, pResource, pAction, tHasAccess)
        
        Quit tHasAccess
    }
    
    /// Audit access attempts
    ClassMethod AuditAccess(pUser, pResource, pAction, pGranted)
    {
        Set tAudit = ##class(Security.AuditLog).%New()
        Set tAudit.Username = pUser
        Set tAudit.Resource = pResource
        Set tAudit.Action = pAction
        Set tAudit.Granted = pGranted
        Set tAudit.Timestamp = $ZDateTime($H, 3)
        Set tAudit.IPAddress = ..GetClientIP()
        Do tAudit.%Save()
    }
}
```

### Sensitive Data Handling

```objectscript
Class Security.DataProtection
{
    /// Encrypt sensitive data
    ClassMethod EncryptData(pData As %String) As %String
    {
        // Use IRIS encryption
        Set tKey = ..GetEncryptionKey()
        Set tEncrypted = $System.Encryption.AESCBCEncrypt(pData, tKey, ..GetIV())
        Set tBase64 = $System.Encryption.Base64Encode(tEncrypted)
        Quit tBase64
    }
    
    /// Decrypt sensitive data
    ClassMethod DecryptData(pEncrypted As %String) As %String
    {
        Set tKey = ..GetEncryptionKey()
        Set tBinary = $System.Encryption.Base64Decode(pEncrypted)
        Set tDecrypted = $System.Encryption.AESCBCDecrypt(tBinary, tKey, ..GetIV())
        Quit tDecrypted
    }
    
    /// Mask sensitive data for display
    ClassMethod MaskData(pData As %String, pType As %String) As %String
    {
        If pType = "SSN" {
            // Show only last 4 digits
            Quit "***-**-"_$Extract(pData, $Length(pData)-3, $Length(pData))
        }
        ElseIf pType = "CREDITCARD" {
            // Show only last 4 digits
            Quit "****-****-****-"_$Extract(pData, $Length(pData)-3, $Length(pData))
        }
        ElseIf pType = "EMAIL" {
            // Mask email partially
            Set tAt = $Find(pData, "@")
            If tAt {
                Set tUser = $Extract(pData, 1, tAt-2)
                Set tDomain = $Extract(pData, tAt, $Length(pData))
                Quit $Extract(tUser, 1, 2)_"***"_tDomain
            }
        }
        
        // Default masking
        Quit "********"
    }
}
```

---

## 10. Testing Standards

### Unit Testing Framework

```objectscript
/// Unit test class example
Class Tests.Patient.DemographicsTest Extends %UnitTest.TestCase
{
    /// Test setup - runs before each test
    Method OnBeforeOneTest() As %Status
    {
        // Create test data
        Set ..TestPatientID = ..CreateTestPatient()
        Quit $$$OK
    }
    
    /// Test patient creation
    Method TestCreatePatient()
    {
        Set tPatient = ##class(Patient.Demographics).%New()
        Set tPatient.FirstName = "Test"
        Set tPatient.LastName = "Patient"
        Set tPatient.DateOfBirth = $H - (365 * 25)  // 25 years old
        
        Set tSC = tPatient.%Save()
        Do $$$AssertStatusOK(tSC, "Patient should save successfully")
        
        Set tID = tPatient.%Id()
        Do $$$AssertNotEquals(tID, "", "Patient should have an ID after save")
        
        // Verify saved data
        Set tSaved = ##class(Patient.Demographics).%OpenId(tID)
        Do $$$AssertEquals(tSaved.FirstName, "Test", "First name should match")
        Do $$$AssertEquals(tSaved.LastName, "Patient", "Last name should match")
    }
    
    /// Test age calculation
    Method TestAgeCalculation()
    {
        Set tDOB = $H - (365 * 30)  // 30 years ago
        Set tAge = ##class(Patient.Demographics).CalculateAge(tDOB)
        
        Do $$$AssertEquals(tAge, 30, "Age should be 30 years")
        
        // Test with future date
        Set tFutureDOB = $H + 100
        Set tAge = ##class(Patient.Demographics).CalculateAge(tFutureDOB)
        Do $$$AssertEquals(tAge, 0, "Future birth date should return 0")
    }
    
    /// Test validation
    Method TestValidation()
    {
        Set tPatient = ##class(Patient.Demographics).%New()
        // Missing required fields
        
        Set tSC = tPatient.%ValidateObject()
        Do $$$AssertStatusNotOK(tSC, "Validation should fail with missing required fields")
        
        // Add required fields
        Set tPatient.FirstName = "John"
        Set tPatient.LastName = "Doe"
        Set tPatient.DateOfBirth = $H - 10000
        
        Set tSC = tPatient.%ValidateObject()
        Do $$$AssertStatusOK(tSC, "Validation should pass with all required fields")
    }
    
    /// Test cleanup - runs after each test
    Method OnAfterOneTest() As %Status
    {
        // Clean up test data
        If $Get(..TestPatientID) '= "" {
            Do ##class(Patient.Demographics).%DeleteId(..TestPatientID)
        }
        Quit $$$OK
    }
}
```

### Test Coverage Requirements

```objectscript
/// Coverage analyzer
Class Tests.CoverageAnalyzer
{
    /// Calculate test coverage for a package
    ClassMethod AnalyzeCoverage(pPackage As %String) As %Decimal
    {
        Set tTotalMethods = 0
        Set tTestedMethods = 0
        
        // Get all classes in package
        Set tRS = ##class(%Dictionary.ClassDefinitionQuery).SubclassOfFunc("%RegisteredObject")
        While tRS.%Next() {
            Set tClass = tRS.Name
            If $Extract(tClass, 1, $Length(pPackage)) '= pPackage Continue
            
            // Count methods
            Set tMethodRS = ##class(%Dictionary.MethodDefinitionQuery).MethodsFunc(tClass)
            While tMethodRS.%Next() {
                Set tTotalMethods = tTotalMethods + 1
                
                // Check if method has test
                If ..HasTest(tClass, tMethodRS.Name) {
                    Set tTestedMethods = tTestedMethods + 1
                }
            }
        }
        
        If tTotalMethods = 0 Quit 0
        
        Quit (tTestedMethods / tTotalMethods) * 100
    }
    
    /// Minimum coverage: 80%
    Parameter MINCOVERAGE = 80;
}
```

### Mock Data Management

```objectscript
/// Test data factory
Class Tests.TestDataFactory
{
    /// Generate test patient
    ClassMethod CreateTestPatient(pPrefix As %String = "TEST") As Patient.Demographics
    {
        Set tPatient = ##class(Patient.Demographics).%New()
        Set tPatient.FirstName = pPrefix_"_FirstName_"_$Random(9999)
        Set tPatient.LastName = pPrefix_"_LastName_"_$Random(9999)
        Set tPatient.DateOfBirth = $H - $Random(365*80)
        Set tPatient.SSN = ..GenerateSSN()
        Set tPatient.Email = $ZConvert(tPatient.FirstName_"."_tPatient.LastName, "L")_"@test.com"
        
        Do tPatient.%Save()
        Quit tPatient
    }
    
    /// Generate test SSN
    ClassMethod GenerateSSN() As %String
    {
        Set tSSN = $Random(899) + 100_"-"_($Random(89) + 10)_"-"_($Random(8999) + 1000)
        Quit tSSN
    }
    
    /// Clean up test data
    ClassMethod CleanupTestData(pPrefix As %String = "TEST")
    {
        &sql(DELETE FROM Patient.Demographics WHERE FirstName %STARTSWITH :pPrefix)
        &sql(DELETE FROM Order.Header WHERE Reference %STARTSWITH :pPrefix)
        // Add more cleanup as needed
    }
}
```

---

## 11. Version Control & Deployment

### Source Control Best Practices

```text
Git Commit Message Format:
[TYPE] Brief description (max 50 chars)

Detailed explanation of changes (if needed)

Types:
- FEAT: New feature
- FIX: Bug fix
- DOCS: Documentation only
- STYLE: Code style changes
- REFACTOR: Code refactoring
- PERF: Performance improvements
- TEST: Test additions/changes
- CHORE: Build process or auxiliary tool changes

Example:
[FEAT] Add patient search by insurance ID

- Implemented new search method in Patient.Demographics
- Added index on InsuranceID field
- Updated API to include new search endpoint
```

### Branching Strategy

```text
main/master
├── develop
│   ├── feature/patient-search
│   ├── feature/billing-module
│   └── feature/reporting
├── release/v2.0
│   └── hotfix/critical-bug-fix
└── hotfix/production-issue
```

### Code Review Checklist

```text
□ Code follows naming conventions
□ Methods have proper documentation
□ Error handling is implemented
□ Unit tests are included
□ No hardcoded values
□ SQL queries are parameterized
□ Performance impact considered
□ Security implications reviewed
□ Code is properly formatted
□ No commented-out code
□ Dependencies documented
□ Breaking changes noted
```

### Deployment Process

```objectscript
/// Deployment utility
Class Deploy.Manager
{
    /// Deploy to environment
    ClassMethod Deploy(pEnvironment As %String, pVersion As %String) As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Pre-deployment validation
            Set tSC = ..ValidateEnvironment(pEnvironment)
            If $$$ISERR(tSC) Quit
            
            // Backup current version
            Set tSC = ..BackupCurrentVersion(pEnvironment)
            If $$$ISERR(tSC) Quit
            
            // Deploy new version
            Set tSC = ..DeployVersion(pEnvironment, pVersion)
            If $$$ISERR(tSC) {
                // Rollback on failure
                Do ..Rollback(pEnvironment)
                Quit
            }
            
            // Run post-deployment tests
            Set tSC = ..RunSmokeTests(pEnvironment)
            If $$$ISERR(tSC) {
                Do ..Rollback(pEnvironment)
                Quit
            }
            
            // Update deployment log
            Do ..LogDeployment(pEnvironment, pVersion, "SUCCESS")
        }
        Catch ex {
            Set tSC = ex.AsStatus()
            Do ..LogDeployment(pEnvironment, pVersion, "FAILED: "_ex.DisplayString())
        }
        
        Quit tSC
    }
}
```

---

## 12. Code Organization

### Project Structure

```text
/project-root
├── /src
│   ├── /Business          # Business logic
│   │   ├── /Service       # Business services
│   │   ├── /Process       # Business processes
│   │   └── /Operation     # Business operations
│   ├── /Data              # Data layer
│   │   ├── /Model         # Persistent classes
│   │   └── /Repository    # Data access classes
│   ├── /API               # REST/SOAP APIs
│   │   ├── /REST
│   │   └── /SOAP
│   ├── /Message           # Message classes
│   │   ├── /Request
│   │   └── /Response
│   ├── /Utility           # Helper classes
│   │   ├── /Logger
│   │   ├── /Validator
│   │   └── /Converter
│   └── /Production        # Production configurations
├── /tests
│   ├── /Unit              # Unit tests
│   ├── /Integration       # Integration tests
│   └── /Performance       # Performance tests
├── /docs                  # Documentation
├── /config                # Configuration files
└── /scripts               # Deployment scripts
```

### Package Dependencies

```objectscript
/// Dependency manager
Class Build.DependencyManager
{
    /// Define dependencies
    XData Dependencies [ XMLNamespace = "http://company.com/dependencies" ]
    {
        <Dependencies>
            <Package name="Company.Core" version="2.0.0" required="true"/>
            <Package name="Company.Utilities" version="1.5.0" required="true"/>
            <Package name="HealthShare.Core" version="2020.1" required="false"/>
        </Dependencies>
    }
    
    /// Check dependencies
    ClassMethod CheckDependencies() As %Status
    {
        Set tSC = $$$OK
        
        // Parse dependencies
        Set tDeps = ..GetDependencies()
        
        Set tKey = $Order(tDeps(""))
        While tKey '= "" {
            Set tPackage = tDeps(tKey, "name")
            Set tVersion = tDeps(tKey, "version")
            Set tRequired = tDeps(tKey, "required")
            
            If '..IsPackageInstalled(tPackage, tVersion) {
                If tRequired {
                    Set tSC = $$$ERROR($$$GeneralError, "Missing required package: "_tPackage_" v"_tVersion)
                    Quit
                } Else {
                    Write "Warning: Optional package not found: "_tPackage,!
                }
            }
            
            Set tKey = $Order(tDeps(tKey))
        }
        
        Quit tSC
    }
}
```

---

## 13. Common Patterns & Anti-patterns

### Design Patterns

#### Singleton Pattern
```objectscript
Class Patterns.Singleton
{
    /// Private instance holder
    Property Instance As Patterns.Singleton [ Private, ClassMethod ];
    
    /// Get singleton instance
    ClassMethod GetInstance() As Patterns.Singleton
    {
        If '$IsObject($Get(^||SingletonInstance)) {
            Set ^||SingletonInstance = ..%New()
        }
        Quit ^||SingletonInstance
    }
    
    /// Private constructor
    Method %OnNew() As %Status [ Private ]
    {
        // Initialization code
        Quit $$$OK
    }
}
```

#### Factory Pattern
```objectscript
Class Patterns.ProcessorFactory
{
    /// Create processor based on type
    ClassMethod CreateProcessor(pType As %String) As Patterns.Processor
    {
        If pType = "JSON" {
            Quit ##class(Patterns.JSONProcessor).%New()
        }
        ElseIf pType = "XML" {
            Quit ##class(Patterns.XMLProcessor).%New()
        }
        ElseIf pType = "CSV" {
            Quit ##class(Patterns.CSVProcessor).%New()
        }
        
        Throw ##class(%Exception.General).%New("Unknown processor type: "_pType)
    }
}
```

#### Observer Pattern
```objectscript
Class Patterns.Subject
{
    Property Observers As list Of Patterns.Observer;
    
    Method Attach(pObserver As Patterns.Observer)
    {
        Do ..Observers.Insert(pObserver)
    }
    
    Method Notify(pEvent As %String)
    {
        For i=1:1:..Observers.Count() {
            Set tObserver = ..Observers.GetAt(i)
            Do tObserver.Update($this, pEvent)
        }
    }
}
```

### Anti-patterns to Avoid

```objectscript
/// ANTI-PATTERN: God Object
/// Don't create classes that do everything
Class BadExample.GodObject
{
    // Too many responsibilities in one class
    Method ProcessOrder() { }
    Method SendEmail() { }
    Method GenerateReport() { }
    Method ValidateUser() { }
    Method CalculateTax() { }
    // ... hundreds more methods
}

/// GOOD: Single Responsibility
Class GoodExample.OrderProcessor
{
    Method ProcessOrder() { }
}

Class GoodExample.EmailService
{
    Method SendEmail() { }
}

/// ANTI-PATTERN: Copy-Paste Programming
/// Don't duplicate code
Class BadExample.Duplication
{
    Method ProcessTypeA()
    {
        Set tData = ..GetData()
        Set tData = $ZConvert(tData, "U")
        Set tData = $Translate(tData, " ", "")
        // Process Type A
    }
    
    Method ProcessTypeB()
    {
        Set tData = ..GetData()
        Set tData = $ZConvert(tData, "U")
        Set tData = $Translate(tData, " ", "")
        // Process Type B
    }
}

/// GOOD: Extract common functionality
Class GoodExample.NoDuplication
{
    Method PrepareData() [ Private ]
    {
        Set tData = ..GetData()
        Set tData = $ZConvert(tData, "U")
        Set tData = $Translate(tData, " ", "")
        Quit tData
    }
    
    Method ProcessTypeA()
    {
        Set tData = ..PrepareData()
        // Process Type A
    }
}
```

---

## 14. Tools & Development Environment

### VS Code Configuration

```json
{
    "objectscript.conn": {
        "active": true,
        "host": "localhost",
        "port": 52773,
        "username": "developer",
        "password": "",
        "ns": "USER",
        "https": false
    },
    "objectscript.format": {
        "commandCase": "word",
        "functionCase": "word",
        "indent": 4,
        "lineWidth": 120
    },
    "objectscript.compile": {
        "onSave": true,
        "flags": "cuk"
    },
    "files.associations": {
        "*.cls": "objectscript-class",
        "*.mac": "objectscript",
        "*.inc": "objectscript"
    }
}
```

### Development Workflow

```objectscript
/// Development helper utilities
Class Dev.Utils
{
    /// Export classes for source control
    ClassMethod Export(pPackage As %String, pPath As %String) As %Status
    {
        Set tSC = $$$OK
        
        Set tItems = pPackage_".*.cls"
        Set tSC = $System.OBJ.Export(tItems, pPath_"/"_pPackage_".xml", "d")
        
        Quit tSC
    }
    
    /// Import classes from source control
    ClassMethod Import(pPath As %String) As %Status
    {
        Set tSC = $System.OBJ.Load(pPath, "ck")
        Quit tSC
    }
    
    /// Compile all project classes
    ClassMethod CompileProject(pPackage As %String) As %Status
    {
        Set tSC = $System.OBJ.CompilePackage(pPackage, "cukbr")
        Quit tSC
    }
    
    /// Run code quality checks
    ClassMethod QualityCheck(pClass As %String) As %Status
    {
        Set tSC = $$$OK
        
        // Check for common issues
        If '..HasDocumentation(pClass) {
            Write "WARNING: Missing class documentation",!
        }
        
        If ..HasHardcodedValues(pClass) {
            Write "WARNING: Hardcoded values detected",!
        }
        
        If '..FollowsNamingConvention(pClass) {
            Write "WARNING: Naming convention violations",!
        }
        
        Quit tSC
    }
}
```

---

## 15. Appendices

### A. Quick Reference Card

| Element | Convention | Example |
|---------|------------|---------|
| Class Name | PascalCase | `PatientRecord` |
| Method Name | PascalCase/camelCase | `GetPatientData()` |
| Property | PascalCase | `DateOfBirth` |
| Parameter | p prefix | `pPatientId` |
| Local Variable | t prefix | `tCounter` |
| Constant | UPPERCASE | `MAXRETRIES` |
| Global | Descriptive | `^APPDATA` |

### B. Common Code Snippets

```objectscript
/// Standard method template
Method StandardMethod(pParam As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Method logic here
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// SQL iteration template
Set tRS = ##class(%SQL.Statement).%ExecDirect(, tSQL)
While tRS.%Next() {
    // Process row
    Set tValue = tRS.%Get("ColumnName")
}

/// Transaction template
TSTART
Try {
    // Transactional operations
    TCOMMIT
}
Catch ex {
    TROLLBACK
    Throw ex
}
```

### C. Glossary

- **IRIS**: InterSystems IRIS Data Platform
- **ObjectScript**: InterSystems programming language
- **Production**: Interoperability configuration
- **Business Service**: Component that receives data
- **Business Process**: Component that orchestrates data flow
- **Business Operation**: Component that sends data
- **%Status**: Standard error handling mechanism
- **Global**: Persistent multidimensional array
- **Class Parameter**: Class-level constant
- **Method**: Function within a class
- **Property**: Data field in a class

### D. Resources

- [InterSystems Documentation](https://docs.intersystems.com)
- [ObjectScript Reference](https://docs.intersystems.com/iris/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS)
- [IRIS Community](https://community.intersystems.com)
- [Learning Services](https://learning.intersystems.com)

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Aug 2025 | Standards Committee | Initial release |

---

*This document is a living standard and will be updated periodically to reflect best practices and technological advances in InterSystems ObjectScript development.*
