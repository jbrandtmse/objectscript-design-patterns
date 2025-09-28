/// Gang of Four Iterator Pattern - SQL Cursor Iterator Implementation
/// Provides iteration over SQL query results using IRIS cursors
Class Patterns.GoF.Behavioral.SQLCursorIterator Extends Patterns.GoF.Behavioral.Iterator
{

/// SQL query to execute
Property Query As %String(MAXLEN = "");

/// Query parameters
Property Parameters As %ListOfDataTypes;

/// Cursor name for this iterator
Property CursorName As %String [ Private ];

/// Current row data
Property CurrentRow As %DynamicObject [ Private ];

/// Flag indicating if cursor is open
Property IsOpen As %Boolean [ InitialExpression = 0, Private ];

/// Flag indicating if we've fetched the first row
Property HasFetched As %Boolean [ InitialExpression = 0, Private ];

/// Batch size for fetching
Property BatchSize As %Integer [ InitialExpression = 1 ];

/// Constructor
Method %OnNew(pQuery As %String = "", pParameters As %ListOfDataTypes = "") As %Status
{
        Set tSC = $$$OK
        Try {
            Set ..Query = pQuery
            If pParameters '= "" {
                Set ..Parameters = pParameters
            } Else {
                Set ..Parameters = ##class(%ListOfDataTypes).%New()
            }
            
            // Generate unique cursor name
            Set ..CursorName = "Cursor"_$TRANSLATE($HOROLOG,",","")_$INCREMENT(^Patterns.Iterator.CursorCounter)
            
            // Open the cursor
            Set tSC = ..OpenCursor()
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
}

/// Open the SQL cursor
Method OpenCursor() As %Status [ Private ]
{
        Set tSC = $$$OK
        Try {
            // Build dynamic SQL
            Set tStatement = ##class(%SQL.Statement).%New()
            Set tSC = tStatement.%Prepare(..Query)
            If $$$ISERR(tSC) Quit
            
            // Execute with parameters
            If ..Parameters.Count() > 0 {
                Set tArgs = ..Parameters.Count()
                Set tExecute = "Set tResultSet = tStatement.%Execute("
                For i=1:1:tArgs {
                    Set tExecute = tExecute_"..Parameters.GetAt("_i_")"
                    If i < tArgs Set tExecute = tExecute_","
                }
                Set tExecute = tExecute_")"
                XECUTE tExecute
            } Else {
                Set tResultSet = tStatement.%Execute()
            }
            
            Set ..%ResultSet = tResultSet
            Set ..IsOpen = 1
            Set ..HasFetched = 0
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
}

/// Internal result set
Property %ResultSet As %SQL.StatementResult [ Private ];

/// Check if more rows exist
Method HasNext() As %Boolean
{
        Set tHasNext = 0
        Try {
            If '..IsOpen Quit
            
            If '..HasFetched {
                // Fetch first row
                If ..%ResultSet.%Next() {
                    Set ..CurrentRow = ##class(%DynamicObject).%New()
                    Set tMetadata = ..%ResultSet.%GetMetadata()
                    For i=1:1:tMetadata.columns.Count() {
                        Set tColumn = tMetadata.columns.GetAt(i)
                        Set tName = tColumn.colName
                        Set tValue = ..%ResultSet.%Get(tName)
                        Do ..CurrentRow.%Set(tName, tValue)
                    }
                    Set ..HasFetched = 1
                    Set tHasNext = 1
                }
            } Else {
                // Check if we have a current row
                Set tHasNext = $IsObject(..CurrentRow)
            }
        }
        Catch ex {
            Set tHasNext = 0
        }
        Quit tHasNext
}

/// Get next row
Method Next() As %RegisteredObject
{
        Set tResult = $$$NULLOREF
        Try {
            If '..IsOpen Quit
            
            If '..HasFetched {
                // Call HasNext to fetch first row
                If '..HasNext() Quit
            }
            
            // Return current row
            Set tResult = ..CurrentRow
            
            // Fetch next row for next call
            If ..%ResultSet.%Next() {
                Set ..CurrentRow = ##class(%DynamicObject).%New()
                Set tMetadata = ..%ResultSet.%GetMetadata()
                For i=1:1:tMetadata.columns.Count() {
                    Set tColumn = tMetadata.columns.GetAt(i)
                    Set tName = tColumn.colName
                    Set tValue = ..%ResultSet.%Get(tName)
                    Do ..CurrentRow.%Set(tName, tValue)
                }
            } Else {
                Set ..CurrentRow = $$$NULLOREF
            }
        }
        Catch ex {
            Set tResult = $$$NULLOREF
        }
        Quit tResult
}

/// Get current row without advancing
Method Current() As %RegisteredObject
{
        Quit ..CurrentRow
}

/// Reset cursor (reopen query)
Method Reset() As %Status
{
        Set tSC = $$$OK
        Try {
            Set tSC = ..CloseCursor()
            If $$$ISERR(tSC) Quit
            
            Set tSC = ..OpenCursor()
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
}

/// Close cursor and cleanup
Method CloseCursor() As %Status [ Private ]
{
        Set tSC = $$$OK
        Try {
            If $IsObject(..%ResultSet) {
                // Result set auto-closes when done
                Set ..%ResultSet = ""
            }
            Set ..IsOpen = 0
            Set ..HasFetched = 0
            Set ..CurrentRow = $$$NULLOREF
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
}

/// Cleanup on object destruction
Method %OnClose() As %Status
{
        Quit ..CloseCursor()
}

/// Set batch size for fetching
Method SetBatchSize(pSize As %Integer) As %Status
{
        If pSize < 1 {
            Quit $$$ERROR($$$GeneralError, "Batch size must be >= 1")
        }
        Set ..BatchSize = pSize
        Quit $$$OK
}

/// Execute a parameterized query
ClassMethod ExecuteQuery(pQuery As %String, pParams... As %String) As SQLCursorIterator
{
        Set tParams = ##class(%ListOfDataTypes).%New()
        For i=1:1:$GET(pParams) {
            Do tParams.Insert(pParams(i))
        }
        Quit ##class(SQLCursorIterator).%New(pQuery, tParams)
}

}
