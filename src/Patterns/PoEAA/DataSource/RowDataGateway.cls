/// PoEAA Row Data Gateway Pattern - One instance per row
/// 
/// <p>The Row Data Gateway pattern provides an object that acts as a gateway 
/// to a single record in a data source. There is one instance per row.</p>
/// 
/// <p>This base class provides the framework for:</p>
/// <ul>
/// <li>Loading row data by ID in constructor</li>
/// <li>Saving changes (insert or update based on IsNew state)</li>
/// <li>Deleting the row from database</li>
/// <li>Refreshing data from database</li>
/// <li>Tracking new vs existing row state</li>
/// <li>Tracking property changes (dirty flag)</li>
/// </ul>
/// 
/// <p>Subclasses must implement:</p>
/// <ul>
/// <li>LoadFromDatabase(pId) - Load row data from database</li>
/// <li>InsertRow() - Insert new row to database</li>
/// <li>UpdateRow() - Update existing row in database</li>
/// <li>DeleteRow() - Delete row from database</li>
/// <li>Property definitions for database columns</li>
/// </ul>
Class Patterns.PoEAA.DataSource.RowDataGateway Extends %RegisteredObject
{

/// Row ID from database
Property Id As %String;

/// Flag indicating new (unsaved) instance
Property %IsNew As %Boolean [ Private ];

/// Flag indicating properties have been modified
Property %IsDirty As %Boolean [ Private ];

/// Constructor loads row by ID if provided
/// 
/// <p>If pId is provided, attempts to load row from database.
/// If pId is empty or load fails, creates new instance.</p>
/// 
/// <parameter name="pId">Optional row ID to load</parameter>
/// <returns>%Status - Always OK (load failures result in new instance)</returns>
Method %OnNew(pId As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..%IsNew = 1
        Set ..%IsDirty = 0
        Set ..Id = ""
        
        If pId '= "" {
            Set tLoadSC = ..LoadFromDatabase(pId)
            If $$$ISOK(tLoadSC) {
                Set ..Id = pId
                Set ..%IsNew = 0
                Set ..%IsDirty = 0
            }
            // If load fails, instance remains as "new"
        }
    } Catch ex {
        // Even on exception, return OK - instance will be "new"
        Set tSC = $$$OK
    }
    
    Quit tSC
}

/// Check if instance represents new (unsaved) row
/// 
/// <returns>%Boolean - 1 if new, 0 if exists in database</returns>
Method IsNew() As %Boolean
{
    Quit ..%IsNew
}

/// Check if instance properties have been modified
/// 
/// <returns>%Boolean - 1 if modified, 0 if unchanged</returns>
Method IsDirty() As %Boolean
{
    Quit ..%IsDirty
}

/// Mark instance as dirty (modified)
/// 
/// <p>Subclasses should call this when properties are modified</p>
Method MarkDirty()
{
    Set ..%IsDirty = 1
}

/// Save row to database (insert or update based on IsNew)
/// 
/// <returns>%Status - OK or error</returns>
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

/// Delete row from database
/// 
/// <returns>%Status - OK or error</returns>
Method Delete() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..IsNew() {
            // Nothing to delete if row doesn't exist in database
            Quit
        }
        
        Set tSC = ..DeleteRow()
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Refresh data from database
/// 
/// <p>Reloads current row data from database, discarding any unsaved changes</p>
/// 
/// <returns>%Status - OK or error</returns>
Method Refresh() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..IsNew() {
            // Nothing to refresh if row doesn't exist in database
            Quit
        }
        
        Set tSC = ..LoadFromDatabase(..Id)
        If $$$ISOK(tSC) {
            Set ..%IsDirty = 0
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Load row data from database (must be implemented by subclass)
/// 
/// <p>Subclass implementation should:</p>
/// <ul>
/// <li>Execute SQL SELECT to load row by ID</li>
/// <li>Populate all property values from result set</li>
/// <li>Return error if row not found</li>
/// </ul>
/// 
/// <parameter name="pId">Row ID to load</parameter>
/// <returns>%Status - OK or error</returns>
Method LoadFromDatabase(pId As %String) As %Status [ Private ]
{
    // Override in subclass
    Quit $$$OK
}

/// Insert new row to database (must be implemented by subclass)
/// 
/// <p>Subclass implementation should:</p>
/// <ul>
/// <li>Execute SQL INSERT with property values</li>
/// <li>Set ..Id from %ROWID or generated ID</li>
/// <li>Return error if insert fails</li>
/// </ul>
/// 
/// <returns>%Status - OK or error</returns>
Method InsertRow() As %Status [ Private ]
{
    // Override in subclass
    Quit $$$OK
}

/// Update existing row in database (must be implemented by subclass)
/// 
/// <p>Subclass implementation should:</p>
/// <ul>
/// <li>Execute SQL UPDATE with property values</li>
/// <li>Use ..Id to identify row</li>
/// <li>Return error if update fails</li>
/// </ul>
/// 
/// <returns>%Status - OK or error</returns>
Method UpdateRow() As %Status [ Private ]
{
    // Override in subclass
    Quit $$$OK
}

/// Delete row from database (must be implemented by subclass)
/// 
/// <p>Subclass implementation should:</p>
/// <ul>
/// <li>Execute SQL DELETE using ..Id</li>
/// <li>Return error if delete fails</li>
/// </ul>
/// 
/// <returns>%Status - OK or error</returns>
Method DeleteRow() As %Status [ Private ]
{
    // Override in subclass
    Quit $$$OK
}

/// Find row by ID (class method returning gateway instance)
/// 
/// <p>Attempts to load row from database and return gateway instance.
/// Returns empty string if row not found.</p>
/// 
/// <parameter name="pId">Row ID to find</parameter>
/// <returns>RowDataGateway instance or empty string</returns>
ClassMethod FindById(pId As %String) As Patterns.PoEAA.DataSource.RowDataGateway
{
    Set tGateway = ""
    
    Try {
        Set tGateway = ..%New(pId)
        If tGateway.IsNew() {
            // Row not found
            Set tGateway = ""
        }
    } Catch ex {
        // Error occurred, return empty
        Set tGateway = ""
    }
    
    Quit tGateway
}

/// Find all rows (class method returning list of gateway instances)
/// 
/// <p>Must be implemented by subclass to return all rows as gateways</p>
/// 
/// <returns>%ListOfObjects containing gateway instances</returns>
ClassMethod FindAll() As %ListOfObjects
{
    // Override in subclass
    Set tList = ##class(%ListOfObjects).%New()
    Quit tList
}

}
