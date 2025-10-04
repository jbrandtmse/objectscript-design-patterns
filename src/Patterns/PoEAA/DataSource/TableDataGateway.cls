/// Patterns of Enterprise Application Architecture - Table Data Gateway Pattern
/// 
/// Intent:
/// An object that acts as a Gateway to a database table. One instance handles all the rows in the table.
/// 
/// Applicability:
/// - Need to encapsulate access to a single database table
/// - Want to centralize SQL queries in one location
/// - Require simple CRUD operations without complex domain logic
/// - Need to prevent SQL injection through parameterized queries
/// 
/// Structure:
/// <example>
/// Set gateway = ##class(MyTableGateway).%New()
/// Set allRecords = gateway.FindAll()
/// Set record = gateway.FindById("123")
/// Set newId = gateway.Insert(dataObject)
/// Set status = gateway.Update("123", dataObject)
/// Set status = gateway.Delete("123")
/// </example>
/// 
/// @see Patterns.PoEAA.DataSource.RowDataGateway
/// @see Patterns.PoEAA.DataSource.ActiveRecord
/// @since 1.0.0
Class Patterns.PoEAA.DataSource.TableDataGateway Extends %RegisteredObject
{

/// Table name this gateway accesses - must be overridden in subclasses
Parameter TABLENAME;

/// Find all records in table
/// @return %ListOfDataTypes containing all records as %DynamicObject
ClassMethod FindAll() As %ListOfDataTypes
{
    Set tList = ##class(%ListOfDataTypes).%New()
    
    Try {
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
    } Catch ex {
        // Log error but return empty list
        Do ..LogError("FindAll", ex)
    }
    
    Quit tList
}

/// Find record by ID
/// @param pId The ID of the record to find
/// @return %DynamicObject containing the record, or empty string if not found
ClassMethod FindById(pId As %String) As %DynamicObject
{
    Set tResult = ""
    
    Try {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT * FROM " _ ..#TABLENAME _ " WHERE ID = ?"
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            Set tRS = tStatement.%Execute(pId)
            If tRS.%Next() {
                Set tResult = ..MapResultToObject(tRS)
            }
        }
    } Catch ex {
        Do ..LogError("FindById", ex)
        Set tResult = ""
    }
    
    Quit tResult
}

/// Find records matching custom WHERE clause
/// @param pWhereClause The WHERE clause (without 'WHERE' keyword)
/// @param pParams Array of parameter values for the WHERE clause
/// @return %ListOfDataTypes containing matching records
ClassMethod FindWhere(pWhereClause As %String, ByRef pParams) As %ListOfDataTypes
{
    Set tList = ##class(%ListOfDataTypes).%New()
    
    Try {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT * FROM " _ ..#TABLENAME _ " WHERE " _ pWhereClause
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            // Build parameter list for Execute
            Set tParamCount = $Get(pParams, 0)
            If tParamCount = 0 {
                Set tResult = tStatement.%Execute()
            } ElseIf tParamCount = 1 {
                Set tResult = tStatement.%Execute($Get(pParams(1)))
            } ElseIf tParamCount = 2 {
                Set tResult = tStatement.%Execute($Get(pParams(1)), $Get(pParams(2)))
            } ElseIf tParamCount = 3 {
                Set tResult = tStatement.%Execute($Get(pParams(1)), $Get(pParams(2)), $Get(pParams(3)))
            } Else {
                // Support up to 5 parameters
                Set tResult = tStatement.%Execute($Get(pParams(1)), $Get(pParams(2)), $Get(pParams(3)), $Get(pParams(4)), $Get(pParams(5)))
            }
            
            While tResult.%Next() {
                Set tData = ..MapResultToObject(tResult)
                Do tList.Insert(tData)
            }
        }
    } Catch ex {
        Do ..LogError("FindWhere", ex)
    }
    
    Quit tList
}

/// Insert new record
/// @param pData %DynamicObject containing field names and values to insert
/// @return ID of newly inserted record, or empty string on failure
ClassMethod Insert(pData As %DynamicObject) As %String
{
    Set tId = ""
    
    Try {
        // Build column and value lists
        Set tColumns = ""
        Set tPlaceholders = ""
        Set tValues = ##class(%ListOfDataTypes).%New()
        
        Set tIterator = pData.%GetIterator()
        While tIterator.%GetNext(.tKey, .tValue) {
            If tColumns '= "" {
                Set tColumns = tColumns _ ", "
                Set tPlaceholders = tPlaceholders _ ", "
            }
            Set tColumns = tColumns _ tKey
            Set tPlaceholders = tPlaceholders _ "?"
            Do tValues.Insert(tValue)
        }
        
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "INSERT INTO " _ ..#TABLENAME _ " (" _ tColumns _ ") VALUES (" _ tPlaceholders _ ")"
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            // Execute with parameters
            Set tParamCount = tValues.Count()
            If tParamCount = 1 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1))
            } ElseIf tParamCount = 2 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2))
            } ElseIf tParamCount = 3 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2), tValues.GetAt(3))
            } ElseIf tParamCount = 4 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2), tValues.GetAt(3), tValues.GetAt(4))
            } ElseIf tParamCount = 5 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2), tValues.GetAt(3), tValues.GetAt(4), tValues.GetAt(5))
            } Else {
                // Support up to 10 parameters
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2), tValues.GetAt(3), tValues.GetAt(4), tValues.GetAt(5), tValues.GetAt(6), tValues.GetAt(7), tValues.GetAt(8), tValues.GetAt(9), tValues.GetAt(10))
            }
            
            If tResult.%SQLCODE = 0 {
                Set tId = tResult.%ROWID
            }
        }
    } Catch ex {
        Do ..LogError("Insert", ex)
        Set tId = ""
    }
    
    Quit tId
}

/// Update existing record
/// @param pId ID of the record to update
/// @param pData %DynamicObject containing field names and new values
/// @return %Status indicating success or failure
ClassMethod Update(pId As %String, pData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Build SET clause
        Set tSetClause = ""
        Set tValues = ##class(%ListOfDataTypes).%New()
        
        Set tIterator = pData.%GetIterator()
        While tIterator.%GetNext(.tKey, .tValue) {
            If tSetClause '= "" {
                Set tSetClause = tSetClause _ ", "
            }
            Set tSetClause = tSetClause _ tKey _ " = ?"
            Do tValues.Insert(tValue)
        }
        
        // Add ID as last parameter
        Do tValues.Insert(pId)
        
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "UPDATE " _ ..#TABLENAME _ " SET " _ tSetClause _ " WHERE ID = ?"
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            // Execute with parameters
            Set tParamCount = tValues.Count()
            If tParamCount = 1 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1))
            } ElseIf tParamCount = 2 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2))
            } ElseIf tParamCount = 3 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2), tValues.GetAt(3))
            } ElseIf tParamCount = 4 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2), tValues.GetAt(3), tValues.GetAt(4))
            } ElseIf tParamCount = 5 {
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2), tValues.GetAt(3), tValues.GetAt(4), tValues.GetAt(5))
            } Else {
                // Support up to 10 parameters
                Set tResult = tStatement.%Execute(tValues.GetAt(1), tValues.GetAt(2), tValues.GetAt(3), tValues.GetAt(4), tValues.GetAt(5), tValues.GetAt(6), tValues.GetAt(7), tValues.GetAt(8), tValues.GetAt(9), tValues.GetAt(10))
            }
            
            If tResult.%SQLCODE '= 0 {
                Set tSC = $$$ERROR($$$GeneralError, "Update failed with SQLCODE: " _ tResult.%SQLCODE)
            }
        } Else {
            Set tSC = tStatus
        }
    } Catch ex {
        Do ..LogError("Update", ex)
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Delete record by ID
/// @param pId ID of the record to delete
/// @return %Status indicating success or failure
ClassMethod Delete(pId As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "DELETE FROM " _ ..#TABLENAME _ " WHERE ID = ?"
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            Set tResult = tStatement.%Execute(pId)
            If tResult.%SQLCODE '= 0 {
                Set tSC = $$$ERROR($$$GeneralError, "Delete failed with SQLCODE: " _ tResult.%SQLCODE)
            }
        } Else {
            Set tSC = tStatus
        }
    } Catch ex {
        Do ..LogError("Delete", ex)
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Execute custom SQL query
/// @param pSQL The SQL query to execute
/// @param pParams Array of parameter values
/// @return %ListOfDataTypes containing query results
ClassMethod ExecuteQuery(pSQL As %String, ByRef pParams) As %ListOfDataTypes
{
    Set tList = ##class(%ListOfDataTypes).%New()
    
    Try {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tStatus = tStatement.%Prepare(pSQL)
        
        If $$$ISOK(tStatus) {
            // Build parameter list for Execute
            Set tParamCount = $Get(pParams, 0)
            If tParamCount = 0 {
                Set tResult = tStatement.%Execute()
            } ElseIf tParamCount = 1 {
                Set tResult = tStatement.%Execute($Get(pParams(1)))
            } ElseIf tParamCount = 2 {
                Set tResult = tStatement.%Execute($Get(pParams(1)), $Get(pParams(2)))
            } ElseIf tParamCount = 3 {
                Set tResult = tStatement.%Execute($Get(pParams(1)), $Get(pParams(2)), $Get(pParams(3)))
            } Else {
                Set tResult = tStatement.%Execute($Get(pParams(1)), $Get(pParams(2)), $Get(pParams(3)), $Get(pParams(4)), $Get(pParams(5)))
            }
            
            While tResult.%Next() {
                Set tData = ..MapResultToObject(tResult)
                Do tList.Insert(tData)
            }
        }
    } Catch ex {
        Do ..LogError("ExecuteQuery", ex)
    }
    
    Quit tList
}

/// Map result set row to data object
/// @param pResult %SQL.StatementResult row to map
/// @return %DynamicObject containing row data
ClassMethod MapResultToObject(pResult As %SQL.StatementResult) As %DynamicObject [ Private ]
{
    Set tData = {}
    
    Try {
        // Get column metadata
        Set tMetadata = pResult.%GetMetadata()
        Set tColumnCount = tMetadata.columnCount
        
        // Map each column to property
        For tIdx = 1:1:tColumnCount {
            Set tColumnName = tMetadata.columns.GetAt(tIdx).colName
            Set tValue = pResult.%GetData(tIdx)
            Do tData.%Set(tColumnName, tValue)
        }
    } Catch ex {
        Do ..LogError("MapResultToObject", ex)
        Set tData = {}
    }
    
    Quit tData
}

/// Log error for debugging
/// @param pMethod Method name where error occurred
/// @param pException Exception object
ClassMethod LogError(pMethod As %String, pException As %Exception.AbstractException) [ Private ]
{
    // In production, this would log to proper logging system
    // For now, write to ^ClineDebug for development
    Set ^ClineDebug = $Get(^ClineDebug) _ pMethod _ " Error: " _ pException.Name _ " - " _ pException.DisplayString() _ "; "
}

}
