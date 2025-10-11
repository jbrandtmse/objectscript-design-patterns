/// Patient Data Mapper
/// 
/// Implements Data Mapper pattern for Patient domain objects
/// Provides complete separation between domain logic and database persistence
/// 
/// Key Responsibilities:
/// - All SQL and database operations for Patient objects
/// - Object-relational mapping between domain objects and database tables
/// - Identity Map pattern to prevent duplicate object loads
/// - Finder methods for various query scenarios
/// 
/// @see Patterns.Examples.Clinical.Patient
/// @see Patterns.PoEAA.DataSource.DataMapper
/// @since 1.0.0
Class Patterns.Examples.Clinical.PatientMapper Extends Patterns.PoEAA.DataSource.DataMapper
{

/// Identity Map for preventing duplicate object loads
/// Stores loaded Patient objects keyed by ID
Property IdentityMap [ MultiDimensional ];

/// Constructor - Initialize Identity Map
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize empty Identity Map
        Kill ..IdentityMap
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Insert a new patient into the database
/// 
/// @param pDomainObject Patient domain object to insert
/// @return %Status indicating success or failure
Method Insert(pDomainObject As Patterns.Examples.Clinical.Patient) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate domain object
        If '$IsObject(pDomainObject) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient object is required")
            Quit
        }
        
        // Extract data from domain object
        Set tData = ..MapToDatabase(pDomainObject)
        
        // Save the persistent object
        Set tSC = pDomainObject.%Save()
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Add to Identity Map
        Set tId = pDomainObject.%Id()
        Do ..AddToIdentityMap(tId, pDomainObject)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Update an existing patient in the database
/// 
/// @param pDomainObject Patient domain object to update
/// @return %Status indicating success or failure
Method Update(pDomainObject As Patterns.Examples.Clinical.Patient) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate domain object
        If '$IsObject(pDomainObject) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient object is required")
            Quit
        }
        
        // Ensure object has ID
        If (pDomainObject.%Id() = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot update patient without ID")
            Quit
        }
        
        // Save the persistent object
        Set tSC = pDomainObject.%Save()
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Update in Identity Map
        Set tId = pDomainObject.%Id()
        Do ..AddToIdentityMap(tId, pDomainObject)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Delete a patient from the database
/// 
/// @param pDomainObject Patient domain object to delete
/// @return %Status indicating success or failure
Method Delete(pDomainObject As Patterns.Examples.Clinical.Patient) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Ensure object has ID
        If (pDomainObject.%Id() = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot delete patient without ID")
            Quit
        }
        
        Set tId = pDomainObject.%Id()
        
        // Delete the persistent object
        Set tSC = ##class(Patterns.Examples.Clinical.Patient).%DeleteId(tId)
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Remove from Identity Map
        Kill ..IdentityMap(tId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Find a patient by ID
/// 
/// @param pId Unique identifier of the patient
/// @return Patient domain object or null if not found
Method Find(pId As %String) As Patterns.Examples.Clinical.Patient
{
    Set tDomainObject = ""
    
    Try {
        // Check Identity Map first
        Set tDomainObject = ..GetFromIdentityMap(pId)
        If $IsObject(tDomainObject) {
            Quit
        }
        
        // Load from database
        Set tDomainObject = ##class(Patterns.Examples.Clinical.Patient).%OpenId(pId)
        
        If $IsObject(tDomainObject) {
            // Add to Identity Map
            Do ..AddToIdentityMap(pId, tDomainObject)
        }
        
    } Catch ex {
        // Log error but return null
        Set tDomainObject = ""
    }
    
    Quit tDomainObject
}

/// Find all patients
/// 
/// @return List of Patient domain objects
Method FindAll() As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Query all patients using %SQL.Statement
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT ID FROM Patterns_Examples_Clinical.Patient"
        Set tSC = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tSC) {
            Set tResult = tStatement.%Execute()
            
            While tResult.%Next() {
                Set tId = tResult.%Get("ID")
                
                // Check Identity Map first
                Set tDomain = ..GetFromIdentityMap(tId)
                
                If '$IsObject(tDomain) {
                    // Load from database
                    Set tDomain = ##class(Patterns.Examples.Clinical.Patient).%OpenId(tId)
                    If $IsObject(tDomain) {
                        Do ..AddToIdentityMap(tId, tDomain)
                    }
                }
                
                If $IsObject(tDomain) {
                    Do tList.Insert(tDomain)
                }
            }
        }
        
    } Catch ex {
        // Return empty list on error
    }
    
    Quit tList
}

/// Find patients by MRN
/// 
/// @param pMRN Patient Medical Record Number
/// @return Patient domain object or null if not found
Method FindByMRN(pMRN As %String) As Patterns.Examples.Clinical.Patient
{
    Set tDomainObject = ""
    
    Try {
        // Query by MRN using %SQL.Statement
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT ID FROM Patterns_Examples_Clinical.Patient WHERE MRN = ?"
        Set tSC = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tSC) {
            Set tResult = tStatement.%Execute(pMRN)
            
            If tResult.%Next() {
                Set tId = tResult.%Get("ID")
                
                // Check Identity Map first
                Set tDomainObject = ..GetFromIdentityMap(tId)
                
                If '$IsObject(tDomainObject) {
                    // Load from database
                    Set tDomainObject = ##class(Patterns.Examples.Clinical.Patient).%OpenId(tId)
                    If $IsObject(tDomainObject) {
                        Do ..AddToIdentityMap(tId, tDomainObject)
                    }
                }
            }
        }
        
    } Catch ex {
        Set tDomainObject = ""
    }
    
    Quit tDomainObject
}

/// Find patients by SQL WHERE clause
/// 
/// @param pWhereClause SQL WHERE clause (without WHERE keyword)
/// @return List of Patient domain objects
Method FindBySQL(pWhereClause As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        If (pWhereClause = "") {
            Quit
        }
        
        // Build SQL query
        Set tSQL = "SELECT ID FROM Patterns_Examples_Clinical.Patient WHERE " _ pWhereClause
        
        // Execute query
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tSC) {
            Set tResult = tStatement.%Execute()
            
            While tResult.%Next() {
                Set tId = tResult.%Get("ID")
                
                // Check Identity Map first
                Set tDomain = ..GetFromIdentityMap(tId)
                
                If '$IsObject(tDomain) {
                    // Load from database
                    Set tDomain = ##class(Patterns.Examples.Clinical.Patient).%OpenId(tId)
                    If $IsObject(tDomain) {
                        Do ..AddToIdentityMap(tId, tDomain)
                    }
                }
                
                If $IsObject(tDomain) {
                    Do tList.Insert(tDomain)
                }
            }
        }
        
    } Catch ex {
        // Return empty list on error
    }
    
    Quit tList
}

/// Map database data to Patient domain object
/// 
/// @param pId Unique identifier
/// @param pData Dynamic object containing database row data
/// @return Populated Patient domain object
Method MapToDomain(pId As %String, pData As %DynamicObject) As Patterns.Examples.Clinical.Patient
{
    Set tDomain = ##class(Patterns.Examples.Clinical.Patient).%New()
    
    Set tDomain.FirstName = pData.FirstName
    Set tDomain.LastName = pData.LastName
    Set tDomain.DateOfBirth = pData.DateOfBirth
    Set tDomain.Gender = pData.Gender
    Set tDomain.Department = pData.Department
    Set tDomain.Status = pData.Status
    Set tDomain.MRN = pData.MRN
    
    Quit tDomain
}

/// Map Patient domain object to database-ready data
/// 
/// @param pDomainObject Patient domain object
/// @return Dynamic object containing data for SQL operations
Method MapToDatabase(pDomainObject As Patterns.Examples.Clinical.Patient) As %DynamicObject
{
    Set tData = {}
    
    Set tData.FirstName = pDomainObject.FirstName
    Set tData.LastName = pDomainObject.LastName
    Set tData.DateOfBirth = pDomainObject.DateOfBirth
    Set tData.Gender = pDomainObject.Gender
    Set tData.Department = pDomainObject.Department
    Set tData.Status = pDomainObject.Status
    Set tData.MRN = pDomainObject.MRN
    
    Quit tData
}

/// Add domain object to Identity Map
/// 
/// @param pId Unique identifier
/// @param pDomainObject Domain object instance to cache
Method AddToIdentityMap(pId As %String, pDomainObject As Patterns.Examples.Clinical.Patient)
{
    If (pId '= "") && $IsObject(pDomainObject) {
        Set ..IdentityMap(pId) = pDomainObject
    }
}

/// Retrieve domain object from Identity Map
/// 
/// @param pId Unique identifier
/// @return Patient if found in map, null otherwise
Method GetFromIdentityMap(pId As %String) As Patterns.Examples.Clinical.Patient
{
    Set tObject = ""
    
    If (pId '= "") && $Data(..IdentityMap(pId)) {
        Set tObject = ..IdentityMap(pId)
    }
    
    Quit tObject
}

/// Clear the Identity Map
/// 
/// Should be called at transaction boundaries or session end
Method ClearIdentityMap()
{
    Kill ..IdentityMap
}

}
