/// Patient Repository
/// 
/// Implements Repository pattern for Patient domain objects
/// Provides collection-like interface for accessing patient data
/// 
/// Key Features:
/// - Domain-focused query methods (FindByMRN, FindActivePatients, etc.)
/// - Specification pattern support for flexible queries
/// - Identity Map integration for caching
/// - Data Mapper integration for persistence
/// - Hides database implementation details from domain
/// 
/// @see Patterns.PoEAA.ObjectRelational.Repository
/// @see Patterns.Examples.Clinical.Patient
/// @see Patterns.Examples.Clinical.PatientMapper
/// @since 1.0.0
Class Patterns.Examples.Clinical.PatientRepository Extends Patterns.PoEAA.ObjectRelational.Repository
{

/// Entity class managed by this repository
Parameter ENTITYCLASS = "Patterns.Examples.Clinical.Patient";

// ===== CONSTRUCTOR =====

/// Initialize the repository with Patient mapper
Method %OnNew() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) {
        Quit tSC
    }
    
    Try {
        // Initialize Patient mapper
        Set ..Mapper = ##class(Patterns.Examples.Clinical.PatientMapper).%New()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== DOMAIN-SPECIFIC FINDERS =====

/// Find a patient by Medical Record Number
/// 
/// @param pMRN Medical Record Number
/// @return Patient object or null if not found
/// 
/// Example:
/// <example>
/// Set patient = repository.FindByMRN("MRN123")
/// </example>
Method FindByMRN(pMRN As %String) As Patterns.Examples.Clinical.Patient
{
    Set tPatient = ""
    
    Try {
        If $IsObject(..Mapper) {
            Set tPatient = ..Mapper.FindByMRN(pMRN)
            
            // Add to identity map if found
            If $IsObject(tPatient) {
                Set tId = ..GetEntityId(tPatient)
                If (tId '= "") {
                    Do ..IdentityMap.Add(tId, tPatient)
                }
            }
        }
        
    } Catch ex {
        Set tPatient = ""
    }
    
    Quit tPatient
}

/// Find all active patients
/// 
/// @return List of active patient objects
/// 
/// Example:
/// <example>
/// Set activePatients = repository.FindActivePatients()
/// </example>
Method FindActivePatients() As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Use specification for active patients
        Set tSpec = ##class(Patterns.Examples.Clinical.ActivePatientSpec).%New()
        Set tList = ..FindBySpecification(tSpec)
        
    } Catch ex {
        Set tList = ##class(%ListOfObjects).%New()
    }
    
    Quit tList
}

/// Find patients by department
/// 
/// @param pDepartment Department name
/// @return List of patient objects in the department
/// 
/// Example:
/// <example>
/// Set cardiologyPatients = repository.FindPatientsByDepartment("Cardiology")
/// </example>
Method FindPatientsByDepartment(pDepartment As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Use specification for department
        Set tSpec = ##class(Patterns.Examples.Clinical.PatientByDepartmentSpec).%New()
        Set tSpec.Department = pDepartment
        Set tList = ..FindBySpecification(tSpec)
        
    } Catch ex {
        Set tList = ##class(%ListOfObjects).%New()
    }
    
    Quit tList
}

/// Find patients by status
/// 
/// @param pStatus Patient status (Active, Discharged, etc.)
/// @return List of patient objects with the status
/// 
/// Example:
/// <example>
/// Set dischargedPatients = repository.FindPatientsByStatus("Discharged")
/// </example>
Method FindPatientsByStatus(pStatus As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Use specification for status
        Set tSpec = ##class(Patterns.Examples.Clinical.PatientByStatusSpec).%New()
        Set tSpec.Status = pStatus
        Set tList = ..FindBySpecification(tSpec)
        
    } Catch ex {
        Set tList = ##class(%ListOfObjects).%New()
    }
    
    Quit tList
}

// ===== IMPLEMENTED ABSTRACT METHODS =====

/// Get the unique identifier from a Patient entity
/// 
/// @param pEntity Patient entity to extract ID from
/// @return Unique identifier as string
Method GetEntityId(pEntity As Patterns.Examples.Clinical.Patient) As %String
{
    Set tId = ""
    
    Try {
        If $IsObject(pEntity) {
            Set tId = pEntity.%Id()
        }
        
    } Catch ex {
        Set tId = ""
    }
    
    Quit tId
}

/// Find patients by SQL WHERE clause
/// 
/// @param pWhereClause SQL WHERE clause (without WHERE keyword)
/// @return List of patients matching the query
Method FindBySQL(pWhereClause As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        If $IsObject(..Mapper) {
            Set tList = ..Mapper.FindBySQL(pWhereClause)
            
            // Add all patients to identity map
            For i=1:1:tList.Count() {
                Set tPatient = tList.GetAt(i)
                If $IsObject(tPatient) {
                    Set tId = ..GetEntityId(tPatient)
                    If (tId '= "") {
                        Do ..IdentityMap.Add(tId, tPatient)
                    }
                }
            }
        }
        
    } Catch ex {
        Set tList = ##class(%ListOfObjects).%New()
    }
    
    Quit tList
}

}
