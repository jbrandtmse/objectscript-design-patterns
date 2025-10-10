/// Clinical Encounter Data Mapper
/// 
/// Implements Data Mapper pattern for ClinicalEncounter domain objects
/// Provides complete separation between domain logic and database persistence
/// 
/// Key Responsibilities:
/// - All SQL and database operations for ClinicalEncounter objects
/// - Object-relational mapping between domain objects and database tables
/// - Identity Map pattern to prevent duplicate object loads
/// - Finder methods for various query scenarios
/// 
/// @see Patterns.Examples.Clinical.ClinicalEncounter
/// @see Patterns.PoEAA.DataSource.DataMapper
/// @since 1.0.0
Class Patterns.Examples.Clinical.ClinicalEncounterMapper Extends Patterns.PoEAA.DataSource.DataMapper
{

/// Identity Map for preventing duplicate object loads
/// Stores loaded ClinicalEncounter objects keyed by EncounterId
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

/// Insert a new clinical encounter into the database
/// 
/// @param pDomainObject ClinicalEncounter domain object to insert
/// @return %Status indicating success or failure
Method Insert(pDomainObject As Patterns.Examples.Clinical.ClinicalEncounter) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate domain object
        Set tSC = pDomainObject.ValidateEncounter()
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Extract data from domain object
        Set tData = ..MapToDatabase(pDomainObject)
        
        // Execute INSERT with parameterized query
        &sql(INSERT INTO Patterns_Examples_Clinical.ClinicalEncounterTable 
             (PatientMRN, ProviderName, EncounterDate, EncounterType, 
              ChiefComplaint, Diagnosis, TreatmentPlan)
             VALUES (:tData.PatientMRN, :tData.ProviderName, :tData.EncounterDate, 
                     :tData.EncounterType, :tData.ChiefComplaint, :tData.Diagnosis, :tData.TreatmentPlan))
        
        If (SQLCODE = 0) {
            // Set ID on domain object from last inserted row
            Set pDomainObject.EncounterId = %ROWID
            
            // Add to Identity Map
            Do ..AddToIdentityMap(%ROWID, pDomainObject)
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "Insert failed with SQLCODE: " _ SQLCODE)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Update an existing clinical encounter in the database
/// 
/// @param pDomainObject ClinicalEncounter domain object to update
/// @return %Status indicating success or failure
Method Update(pDomainObject As Patterns.Examples.Clinical.ClinicalEncounter) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate domain object
        Set tSC = pDomainObject.ValidateEncounter()
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Ensure object has ID
        If (pDomainObject.EncounterId = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot update encounter without EncounterId")
            Quit
        }
        
        // Extract data from domain object
        Set tData = ..MapToDatabase(pDomainObject)
        Set tId = pDomainObject.EncounterId
        
        // Execute UPDATE with parameterized query
        &sql(UPDATE Patterns_Examples_Clinical.ClinicalEncounterTable 
             SET PatientMRN = :tData.PatientMRN,
                 ProviderName = :tData.ProviderName,
                 EncounterDate = :tData.EncounterDate,
                 EncounterType = :tData.EncounterType,
                 ChiefComplaint = :tData.ChiefComplaint,
                 Diagnosis = :tData.Diagnosis,
                 TreatmentPlan = :tData.TreatmentPlan
             WHERE ID = :tId)
        
        If (SQLCODE '= 0) {
            Set tSC = $$$ERROR($$$GeneralError, "Update failed with SQLCODE: " _ SQLCODE)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Delete a clinical encounter from the database
/// 
/// @param pDomainObject ClinicalEncounter domain object to delete
/// @return %Status indicating success or failure
Method Delete(pDomainObject As Patterns.Examples.Clinical.ClinicalEncounter) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Ensure object has ID
        If (pDomainObject.EncounterId = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot delete encounter without EncounterId")
            Quit
        }
        
        Set tId = pDomainObject.EncounterId
        
        // Execute DELETE with parameterized query
        &sql(DELETE FROM Patterns_Examples_Clinical.ClinicalEncounterTable WHERE ID = :tId)
        
        If (SQLCODE = 0) {
            // Remove from Identity Map
            Kill ..IdentityMap(tId)
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "Delete failed with SQLCODE: " _ SQLCODE)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Find a clinical encounter by ID
/// 
/// @param pId Unique identifier of the encounter
/// @return ClinicalEncounter domain object or null if not found
Method Find(pId As %String) As Patterns.Examples.Clinical.ClinicalEncounter
{
    Set tDomainObject = ""
    
    Try {
        // Check Identity Map first
        Set tDomainObject = ..GetFromIdentityMap(pId)
        If $IsObject(tDomainObject) {
            Quit
        }
        
        // Load from database
        &sql(SELECT PatientMRN, ProviderName, EncounterDate, EncounterType, 
                    ChiefComplaint, Diagnosis, TreatmentPlan
             INTO :tMRN, :tProvider, :tDate, :tType, :tComplaint, :tDiagnosis, :tPlan
             FROM Patterns_Examples_Clinical.ClinicalEncounterTable
             WHERE ID = :pId)
        
        If (SQLCODE = 0) {
            // Create domain object from data
            Set tData = {}
            Set tData.PatientMRN = tMRN
            Set tData.ProviderName = tProvider
            Set tData.EncounterDate = tDate
            Set tData.EncounterType = tType
            Set tData.ChiefComplaint = tComplaint
            Set tData.Diagnosis = tDiagnosis
            Set tData.TreatmentPlan = tPlan
            
            Set tDomainObject = ..MapToDomain(pId, tData)
            
            // Add to Identity Map
            Do ..AddToIdentityMap(pId, tDomainObject)
        }
        
    } Catch ex {
        // Log error but return null
        Set tDomainObject = ""
    }
    
    Quit tDomainObject
}

/// Find all clinical encounters
/// 
/// @return List of ClinicalEncounter domain objects
Method FindAll() As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Query all encounters
        &sql(DECLARE encounterCursor CURSOR FOR
             SELECT ID, PatientMRN, ProviderName, EncounterDate, EncounterType,
                    ChiefComplaint, Diagnosis, TreatmentPlan
             FROM Patterns_Examples_Clinical.ClinicalEncounterTable)
        
        &sql(OPEN encounterCursor)
        
        &sql(FETCH encounterCursor INTO :tId, :tMRN, :tProvider, :tDate, :tType, 
                                         :tComplaint, :tDiagnosis, :tPlan)
        
        While (SQLCODE = 0) {
            // Check Identity Map first
            Set tDomain = ..GetFromIdentityMap(tId)
            
            If '$IsObject(tDomain) {
                // Create domain object
                Set tData = {}
                Set tData.PatientMRN = tMRN
                Set tData.ProviderName = tProvider
                Set tData.EncounterDate = tDate
                Set tData.EncounterType = tType
                Set tData.ChiefComplaint = tComplaint
                Set tData.Diagnosis = tDiagnosis
                Set tData.TreatmentPlan = tPlan
                
                Set tDomain = ..MapToDomain(tId, tData)
                Do ..AddToIdentityMap(tId, tDomain)
            }
            
            Do tList.Insert(tDomain)
            
            &sql(FETCH encounterCursor INTO :tId, :tMRN, :tProvider, :tDate, :tType, 
                                             :tComplaint, :tDiagnosis, :tPlan)
        }
        
        &sql(CLOSE encounterCursor)
        
    } Catch ex {
        // Return empty list on error
    }
    
    Quit tList
}

/// Find clinical encounters by Patient MRN
/// 
/// @param pMRN Patient Medical Record Number
/// @return List of ClinicalEncounter domain objects
Method FindByPatientMRN(pMRN As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Query encounters by MRN with parameterized query
        &sql(DECLARE mrnCursor CURSOR FOR
             SELECT ID, PatientMRN, ProviderName, EncounterDate, EncounterType,
                    ChiefComplaint, Diagnosis, TreatmentPlan
             FROM Patterns_Examples_Clinical.ClinicalEncounterTable
             WHERE PatientMRN = :pMRN)
        
        &sql(OPEN mrnCursor)
        
        &sql(FETCH mrnCursor INTO :tId, :tMRN, :tProvider, :tDate, :tType, 
                                  :tComplaint, :tDiagnosis, :tPlan)
        
        While (SQLCODE = 0) {
            // Check Identity Map first
            Set tDomain = ..GetFromIdentityMap(tId)
            
            If '$IsObject(tDomain) {
                // Create domain object
                Set tData = {}
                Set tData.PatientMRN = tMRN
                Set tData.ProviderName = tProvider
                Set tData.EncounterDate = tDate
                Set tData.EncounterType = tType
                Set tData.ChiefComplaint = tComplaint
                Set tData.Diagnosis = tDiagnosis
                Set tData.TreatmentPlan = tPlan
                
                Set tDomain = ..MapToDomain(tId, tData)
                Do ..AddToIdentityMap(tId, tDomain)
            }
            
            Do tList.Insert(tDomain)
            
            &sql(FETCH mrnCursor INTO :tId, :tMRN, :tProvider, :tDate, :tType, 
                                      :tComplaint, :tDiagnosis, :tPlan)
        }
        
        &sql(CLOSE mrnCursor)
        
    } Catch ex {
        // Return empty list on error
    }
    
    Quit tList
}

/// Find clinical encounters by date range
/// 
/// @param pStartDate Start of date range
/// @param pEndDate End of date range
/// @return List of ClinicalEncounter domain objects
Method FindByDateRange(pStartDate As %TimeStamp, pEndDate As %TimeStamp) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Query encounters by date range with parameterized query
        &sql(DECLARE dateCursor CURSOR FOR
             SELECT ID, PatientMRN, ProviderName, EncounterDate, EncounterType,
                    ChiefComplaint, Diagnosis, TreatmentPlan
             FROM Patterns_Examples_Clinical.ClinicalEncounterTable
             WHERE EncounterDate >= :pStartDate AND EncounterDate <= :pEndDate)
        
        &sql(OPEN dateCursor)
        
        &sql(FETCH dateCursor INTO :tId, :tMRN, :tProvider, :tDate, :tType, 
                                   :tComplaint, :tDiagnosis, :tPlan)
        
        While (SQLCODE = 0) {
            // Check Identity Map first
            Set tDomain = ..GetFromIdentityMap(tId)
            
            If '$IsObject(tDomain) {
                // Create domain object
                Set tData = {}
                Set tData.PatientMRN = tMRN
                Set tData.ProviderName = tProvider
                Set tData.EncounterDate = tDate
                Set tData.EncounterType = tType
                Set tData.ChiefComplaint = tComplaint
                Set tData.Diagnosis = tDiagnosis
                Set tData.TreatmentPlan = tPlan
                
                Set tDomain = ..MapToDomain(tId, tData)
                Do ..AddToIdentityMap(tId, tDomain)
            }
            
            Do tList.Insert(tDomain)
            
            &sql(FETCH dateCursor INTO :tId, :tMRN, :tProvider, :tDate, :tType, 
                                       :tComplaint, :tDiagnosis, :tPlan)
        }
        
        &sql(CLOSE dateCursor)
        
    } Catch ex {
        // Return empty list on error
    }
    
    Quit tList
}

/// Map database data to ClinicalEncounter domain object
/// 
/// @param pId Unique identifier
/// @param pData Dynamic object containing database row data
/// @return Populated ClinicalEncounter domain object
Method MapToDomain(pId As %String, pData As %DynamicObject) As Patterns.Examples.Clinical.ClinicalEncounter
{
    Set tDomain = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    
    Set tDomain.EncounterId = pId
    Set tDomain.PatientMRN = pData.PatientMRN
    Set tDomain.ProviderName = pData.ProviderName
    Set tDomain.EncounterDate = pData.EncounterDate
    Set tDomain.EncounterType = pData.EncounterType
    Set tDomain.ChiefComplaint = pData.ChiefComplaint
    Set tDomain.Diagnosis = pData.Diagnosis
    Set tDomain.TreatmentPlan = pData.TreatmentPlan
    
    Quit tDomain
}

/// Map ClinicalEncounter domain object to database-ready data
/// 
/// @param pDomainObject ClinicalEncounter domain object
/// @return Dynamic object containing data for SQL operations
Method MapToDatabase(pDomainObject As Patterns.Examples.Clinical.ClinicalEncounter) As %DynamicObject
{
    Set tData = {}
    
    Set tData.PatientMRN = pDomainObject.PatientMRN
    Set tData.ProviderName = pDomainObject.ProviderName
    Set tData.EncounterDate = pDomainObject.EncounterDate
    Set tData.EncounterType = pDomainObject.EncounterType
    Set tData.ChiefComplaint = pDomainObject.ChiefComplaint
    Set tData.Diagnosis = pDomainObject.Diagnosis
    Set tData.TreatmentPlan = pDomainObject.TreatmentPlan
    
    Quit tData
}

/// Add domain object to Identity Map
/// 
/// @param pId Unique identifier
/// @param pDomainObject Domain object instance to cache
Method AddToIdentityMap(pId As %String, pDomainObject As Patterns.Examples.Clinical.ClinicalEncounter)
{
    If (pId '= "") && $IsObject(pDomainObject) {
        Set ..IdentityMap(pId) = pDomainObject
    }
}

/// Retrieve domain object from Identity Map
/// 
/// @param pId Unique identifier
/// @return ClinicalEncounter if found in map, null otherwise
Method GetFromIdentityMap(pId As %String) As Patterns.Examples.Clinical.ClinicalEncounter
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
