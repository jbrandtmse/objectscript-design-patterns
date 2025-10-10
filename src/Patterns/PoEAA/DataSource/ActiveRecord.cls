/// PoEAA Active Record Pattern - Domain object with built-in persistence
/// 
/// An object that wraps a row in a database table or view, encapsulates the database access,
/// and adds domain logic on that data. Active Record combines data access and domain logic
/// in a single class, with each instance representing a row in the database.
/// 
/// Key characteristics:
/// - Extends %Persistent for automatic persistence capabilities
/// - Instance methods for CRUD operations (Save, Delete, Reload)
/// - Class methods for finders (FindById, FindAll)
/// - Domain validation integrated with persistence
/// - Business logic methods coexist with data access
/// - Each instance represents a database row
/// 
/// Usage:
/// <example>
/// Set patient = ##class(PatientActiveRecord).%New()
/// Set patient.FirstName = "John"
/// Set patient.LastName = "Doe"
/// Set tSC = patient.Save()
/// 
/// Set patient = ##class(PatientActiveRecord).FindById(1)
/// Set tSC = patient.Admit("Cardiology")
/// </example>
Class Patterns.PoEAA.DataSource.ActiveRecord Extends %Persistent [ Abstract ]
{

/// Validate domain data before save
/// Override in subclasses to implement specific validation rules
/// 
/// Returns:
///   %Status - $$$OK if validation passes, error status otherwise
Method ValidateData() As %Status
{
    // Default implementation - override in subclasses
    Quit $$$OK
}

/// Check business rules before save
/// Override in subclasses to implement specific business rule validation
/// 
/// Returns:
///   %Status - $$$OK if business rules pass, error status otherwise
Method CheckBusinessRules() As %Status
{
    // Default implementation - override in subclasses
    Quit $$$OK
}

/// Calculate any derived properties
/// Override in subclasses to compute calculated values
/// Called before validation during Save operation
Method CalculateProperties()
{
    // Default implementation - override in subclasses
    Quit
}

/// Save record to database with validation
/// Performs domain validation and business rule checking before persisting
/// Handles both INSERT (new records) and UPDATE (existing records)
/// 
/// Returns:
///   %Status - $$$OK if save succeeds, error status otherwise
Method Save() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Calculate any derived properties
        Do ..CalculateProperties()
        
        // Validate data
        Set tSC = ..ValidateData()
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Check business rules
        Set tSC = ..CheckBusinessRules()
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Persist using %Persistent
        Set tSC = ..%Save()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Delete record from database
/// Removes the active record instance from the database
/// 
/// Returns:
///   %Status - $$$OK if delete succeeds, error status otherwise
Method Delete() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Get the object's ID
        Set tId = ..%Id()
        
        // Check if record exists in database (has an ID)
        If tId '= "" {
            // Use %DeleteId() class method with this object's ID
            Set tSC = $classmethod(..%ClassName(1), "%DeleteId", tId)
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot delete record that has not been saved")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Reload data from database
/// Refreshes the active record instance with current database values
/// Discards any unsaved changes
/// 
/// Returns:
///   %Status - $$$OK if reload succeeds, error status otherwise
Method Reload() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Get the object's ID
        Set tId = ..%Id()
        
        // Check if record exists in database (has an ID)
        If tId '= "" {
            Set tSC = ..%Reload()
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot reload record that has not been saved")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check if record is new (not yet saved to database)
/// 
/// Returns:
///   %Boolean - 1 if new, 0 if existing
Method IsNew() As %Boolean
{
    // Check if object has no ID (new/unsaved)
    Quit (..%Id() = "")
}

/// Find record by ID
/// Loads an active record instance from the database by its ID
/// 
/// Parameters:
///   pId - The database ID of the record to find
/// 
/// Returns:
///   ActiveRecord - The loaded active record instance, or empty string if not found
ClassMethod FindById(pId As %String) As Patterns.PoEAA.DataSource.ActiveRecord
{
    Set tRecord = ""
    
    Try {
        // Use %OpenId() to load persistent object
        Set tRecord = ..%OpenId(pId)
        
    } Catch ex {
        // Log error and return empty
        Set tRecord = ""
    }
    
    Quit tRecord
}

/// Find all records
/// Loads all active record instances from the database
/// 
/// Returns:
///   %ListOfObjects - List containing all active record instances
ClassMethod FindAll() As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Build SQL query to select all IDs
        // Convert class name to SQL table format: Package.Subpackage.ClassName -> Package_Subpackage.ClassName
        Set tClassName = ..%ClassName(1)
        // Find last dot to separate package from class name
        Set tLastDot = $LENGTH(tClassName, ".") 
        Set tPackage = $PIECE(tClassName, ".", 1, tLastDot - 1)
        Set tClass = $PIECE(tClassName, ".", tLastDot)
        // Replace dots with underscores in package path, then add dot separator and class name
        Set tPackageSQL = $TRANSLATE(tPackage, ".", "_")
        Set tSQLTable = tPackageSQL _ "." _ tClass
        Set tSQL = "SELECT ID FROM " _ tSQLTable
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tSC) {
            Set tResult = tStatement.%Execute()
            While tResult.%Next() {
                Set tRecord = ..%OpenId(tResult.%Get("ID"))
                If $IsObject(tRecord) {
                    Do tList.Insert(tRecord)
                }
            }
        }
        
    } Catch ex {
        // Log error and return empty list
        // List already initialized, so just continue
    }
    
    Quit tList
}

Storage Default
{
<Data name="ActiveRecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^Patterns.PoEAB528.ActiveRecordD</DataLocation>
<DefaultData>ActiveRecordDefaultData</DefaultData>
<IdLocation>^Patterns.PoEAB528.ActiveRecordD</IdLocation>
<IndexLocation>^Patterns.PoEAB528.ActiveRecordI</IndexLocation>
<StreamLocation>^Patterns.PoEAB528.ActiveRecordS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
