/// PoEAA Table Module Pattern - One Class Per Database Table
/// 
/// Intent:
/// Organize domain logic around database tables with one class per table,
/// using static methods for table-wide operations.
/// 
/// Applicability:
/// - Domain logic is table-oriented with set-based operations
/// - Application needs efficient SQL-based data access
/// - Business logic is moderate complexity
/// - Record-set processing and reporting requirements
/// 
/// Structure:
/// Each table module:
/// - Corresponds to a single database table
/// - Provides static methods for CRUD operations
/// - Handles result set processing
/// - Returns simple data structures or collections
/// 
/// Example:
/// <example>
/// Set patient = ##class(PatientTableModule).FindById(123)
/// Set status = ##class(PatientTableModule).Insert(patientData)
/// Set patients = ##class(PatientTableModule).FindByName("Smith")
/// </example>
/// 
/// @see Patterns.PoEAA.DomainLogic.TransactionScript
/// @see Patterns.PoEAA.DomainLogic.DomainModel
/// @since 1.0.0
Class Patterns.PoEAA.DomainLogic.TableModule Extends %RegisteredObject [ Abstract ]
{

/// Version of the pattern implementation
Parameter VERSION = "1.0.0";

/// Pattern type classification
Parameter PATTERNTYPE = "Domain Logic";

/// Table name this module operates on (override in subclasses)
Parameter TABLENAME;

/// Primary key column name (override in subclasses)
Parameter PRIMARYKEY = "ID";

/// Find record by primary key ID
/// @param pId Primary key value
/// @return Dynamic object containing record data or empty string if not found
ClassMethod FindById(pId As %Integer) As %DynamicObject
{
    Set tResult = ""
    
    Try {
        // Get table name from parameter
        Set tTableName = ..#TABLENAME
        If tTableName = "" {
            Quit
        }
        
        // Execute SELECT query
        Set tSQL = "SELECT * FROM " _ tTableName _ " WHERE " _ ..#PRIMARYKEY _ " = ?"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        Set tResultSet = tStatement.%Execute(pId)
        
        // Convert first row to object
        If tResultSet.%Next() {
            Set tResult = ..ResultSetRowToObject(tResultSet)
        }
        
    } Catch ex {
        Set tResult = ""
    }
    
    Quit tResult
}

/// Find all records in table
/// @return Dynamic array of record objects
ClassMethod FindAll() As %DynamicArray
{
    Set tResult = []
    
    Try {
        // Get table name from parameter
        Set tTableName = ..#TABLENAME
        If tTableName = "" {
            Quit
        }
        
        // Execute SELECT query
        Set tSQL = "SELECT * FROM " _ tTableName
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        Set tResultSet = tStatement.%Execute()
        
        // Convert all rows to objects
        While tResultSet.%Next() {
            Set tRecord = ..ResultSetRowToObject(tResultSet)
            If tRecord '= "" {
                Do tResult.%Push(tRecord)
            }
        }
        
    } Catch ex {
        Set tResult = []
    }
    
    Quit tResult
}

/// Insert new record into table
/// @param pData Dynamic object containing field values
/// @return Status indicating success or failure
ClassMethod Insert(pData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate input data
        Set tSC = ..ValidateData(pData)
        If $$$ISERR(tSC) Quit
        
        // Get table name from parameter
        Set tTableName = ..#TABLENAME
        If tTableName = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Table name not defined")
            Quit
        }
        
        // Build INSERT statement dynamically
        Set tFields = ""
        Set tValues = ""
        Set tParams = []
        
        Set tIterator = pData.%GetIterator()
        While tIterator.%GetNext(.tKey, .tValue) {
            If tFields '= "" {
                Set tFields = tFields _ ", "
                Set tValues = tValues _ ", "
            }
            Set tFields = tFields _ tKey
            Set tValues = tValues _ "?"
            Do tParams.%Push(tValue)
        }
        
        Set tSQL = "INSERT INTO " _ tTableName _ " (" _ tFields _ ") VALUES (" _ tValues _ ")"
        
        // Execute INSERT
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        Set tResultSet = tStatement.%Execute(tParams...)
        
        // Check SQL result
        If tResultSet.%SQLCODE '= 0 {
            Set tSC = $$$ERROR($$$GeneralError, "Insert failed: SQLCODE=" _ tResultSet.%SQLCODE)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Update existing record in table
/// @param pId Primary key value
/// @param pData Dynamic object containing field values to update
/// @return Status indicating success or failure
ClassMethod Update(pId As %Integer, pData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate input data
        Set tSC = ..ValidateData(pData)
        If $$$ISERR(tSC) Quit
        
        // Get table name from parameter
        Set tTableName = ..#TABLENAME
        If tTableName = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Table name not defined")
            Quit
        }
        
        // Build UPDATE statement dynamically
        Set tSetClause = ""
        Set tParams = []
        
        Set tIterator = pData.%GetIterator()
        While tIterator.%GetNext(.tKey, .tValue) {
            If tSetClause '= "" {
                Set tSetClause = tSetClause _ ", "
            }
            Set tSetClause = tSetClause _ tKey _ " = ?"
            Do tParams.%Push(tValue)
        }
        
        // Add ID parameter
        Do tParams.%Push(pId)
        
        Set tSQL = "UPDATE " _ tTableName _ " SET " _ tSetClause _ " WHERE " _ ..#PRIMARYKEY _ " = ?"
        
        // Execute UPDATE
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        Set tResultSet = tStatement.%Execute(tParams...)
        
        // Check SQL result
        If tResultSet.%SQLCODE '= 0 {
            Set tSC = $$$ERROR($$$GeneralError, "Update failed: SQLCODE=" _ tResultSet.%SQLCODE)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Delete record from table
/// @param pId Primary key value
/// @return Status indicating success or failure
ClassMethod Delete(pId As %Integer) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Get table name from parameter
        Set tTableName = ..#TABLENAME
        If tTableName = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Table name not defined")
            Quit
        }
        
        Set tSQL = "DELETE FROM " _ tTableName _ " WHERE " _ ..#PRIMARYKEY _ " = ?"
        
        // Execute DELETE
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        Set tResultSet = tStatement.%Execute(pId)
        
        // Check SQL result
        If tResultSet.%SQLCODE '= 0 {
            Set tSC = $$$ERROR($$$GeneralError, "Delete failed: SQLCODE=" _ tResultSet.%SQLCODE)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Execute custom SQL query and return result set
/// @param pSQL SQL query string
/// @param pParams Array of query parameters
/// @return Dynamic array of result objects
ClassMethod ExecuteQuery(pSQL As %String, pParams As %DynamicArray = "") As %DynamicArray
{
    Set tResult = []
    
    Try {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(pSQL)
        If $$$ISERR(tSC) Quit
        
        // Execute with or without parameters
        If $IsObject(pParams) && (pParams.%Size() > 0) {
            Set tResultSet = tStatement.%Execute(pParams...)
        } Else {
            Set tResultSet = tStatement.%Execute()
        }
        
        // Convert all rows to objects
        While tResultSet.%Next() {
            Set tRecord = ..ResultSetRowToObject(tResultSet)
            If tRecord '= "" {
                Do tResult.%Push(tRecord)
            }
        }
        
    } Catch ex {
        Set tResult = []
    }
    
    Quit tResult
}

/// Convert result set row to dynamic object
/// @param pResultSet SQL result set positioned at current row
/// @return Dynamic object containing row data
ClassMethod ResultSetRowToObject(pResultSet As %SQL.StatementResult) As %DynamicObject
{
    Set tObject = {}
    
    Try {
        // Get column metadata
        Set tMetadata = pResultSet.%GetMetadata()
        If '$IsObject(tMetadata) Quit
        
        Set tColumnCount = tMetadata.columnCount
        
        // Iterate through columns
        For tIndex = 1:1:tColumnCount {
            Set tColumnName = tMetadata.columns.GetAt(tIndex).colName
            Set tValue = pResultSet.%GetData(tIndex)
            
            // Handle null values
            If tValue = "" {
                Set tValue = ""
            }
            
            // Set property on object
            Set $PROPERTY(tObject, tColumnName) = tValue
        }
        
    } Catch ex {
        Set tObject = {}
    }
    
    Quit tObject
}

/// Validate data before database operation (override in subclasses)
/// @param pData Dynamic object to validate
/// @return Status indicating validation success or failure
ClassMethod ValidateData(pData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if data object exists
        If '$IsObject(pData) {
            Set tSC = $$$ERROR($$$GeneralError, "Data object is null or invalid")
            Quit
        }
        
        // Default validation passes - override in subclasses for specific validation
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get count of records in table
/// @return Number of records in table
ClassMethod GetCount() As %Integer
{
    Set tCount = 0
    
    Try {
        // Get table name from parameter
        Set tTableName = ..#TABLENAME
        If tTableName = "" {
            Quit
        }
        
        Set tSQL = "SELECT COUNT(*) AS RecordCount FROM " _ tTableName
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        Set tResultSet = tStatement.%Execute()
        
        If tResultSet.%Next() {
            Set tCount = tResultSet.%Get("RecordCount")
        }
        
    } Catch ex {
        Set tCount = 0
    }
    
    Quit tCount
}

/// Check if record exists by ID
/// @param pId Primary key value
/// @return 1 if exists, 0 otherwise
ClassMethod Exists(pId As %Integer) As %Boolean
{
    Set tExists = 0
    
    Try {
        Set tRecord = ..FindById(pId)
        Set tExists = ($IsObject(tRecord) && (tRecord '= ""))
        
    } Catch ex {
        Set tExists = 0
    }
    
    Quit tExists
}

}
