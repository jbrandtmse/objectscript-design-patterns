/// Clinical Example - Patient Data Gateway for Table Data Gateway pattern demonstration
/// 
/// This class demonstrates the Table Data Gateway pattern by providing
/// encapsulated access to the Patient table with healthcare-specific finder methods.
/// 
/// Example Usage:
/// <example>
/// // Find all patients
/// Set allPatients = ##class(PatientDataGateway).FindAllPatients()
/// 
/// // Find specific patient
/// Set patient = ##class(PatientDataGateway).FindPatientById("123")
/// 
/// // Search by last name
/// Set smiths = ##class(PatientDataGateway).FindPatientsByLastName("Smith")
/// 
/// // Insert new patient
/// Set data = {"FirstName": "John", "LastName": "Doe", "MRN": "12345"}
/// Set newId = ##class(PatientDataGateway).InsertPatient(data)
/// </example>
Class Patterns.Examples.Clinical.PatientDataGateway Extends Patterns.PoEAA.DataSource.TableDataGateway
{

/// Table name for Patient data
Parameter TABLENAME = "Patterns_Examples_Clinical.Patient";

/// Find all patients in the system
/// @return %ListOfDataTypes containing all patient records
ClassMethod FindAllPatients() As %ListOfDataTypes
{
    Quit ..FindAll()
}

/// Find patient by ID
/// @param pPatientId The patient ID to search for
/// @return %DynamicObject containing patient data, or empty string if not found
ClassMethod FindPatientById(pPatientId As %String) As %DynamicObject
{
    Quit ..FindById(pPatientId)
}

/// Find patients by last name
/// @param pLastName The last name to search for
/// @return %ListOfDataTypes containing matching patient records
ClassMethod FindPatientsByLastName(pLastName As %String) As %ListOfDataTypes
{
    Set tParams = 1
    Set tParams(1) = pLastName
    
    Quit ..FindWhere("LastName = ?", .tParams)
}

/// Find patients by department
/// @param pDepartment The department to filter by
/// @return %ListOfDataTypes containing matching patient records
ClassMethod FindPatientsByDepartment(pDepartment As %String) As %ListOfDataTypes
{
    Set tParams = 1
    Set tParams(1) = pDepartment
    
    Quit ..FindWhere("Department = ?", .tParams)
}

/// Find patients by status
/// @param pStatus The status to filter by (Active, Discharged, Deceased, Transferred)
/// @return %ListOfDataTypes containing matching patient records
ClassMethod FindPatientsByStatus(pStatus As %String) As %ListOfDataTypes
{
    Set tParams = 1
    Set tParams(1) = pStatus
    
    Quit ..FindWhere("Status = ?", .tParams)
}

/// Find patients by medical record number (MRN)
/// @param pMRN The medical record number to search for
/// @return %DynamicObject containing patient data, or empty string if not found
ClassMethod FindPatientByMRN(pMRN As %String) As %DynamicObject
{
    Set tList = ""
    Set tParams = 1
    Set tParams(1) = pMRN
    
    Set tList = ..FindWhere("MRN = ?", .tParams)
    
    // MRN is unique, so return first (and only) result
    If tList.Count() > 0 {
        Quit tList.GetAt(1)
    }
    
    Quit ""
}

/// Insert new patient record
/// @param pPatientData %DynamicObject containing patient data
/// @return ID of newly created patient, or empty string on failure
ClassMethod InsertPatient(pPatientData As %DynamicObject) As %String
{
    Quit ..Insert(pPatientData)
}

/// Update existing patient record
/// @param pPatientId ID of patient to update
/// @param pPatientData %DynamicObject containing updated patient data
/// @return %Status indicating success or failure
ClassMethod UpdatePatient(pPatientId As %String, pPatientData As %DynamicObject) As %Status
{
    Quit ..Update(pPatientId, pPatientData)
}

/// Delete patient record
/// @param pPatientId ID of patient to delete
/// @return %Status indicating success or failure
ClassMethod DeletePatient(pPatientId As %String) As %Status
{
    Quit ..Delete(pPatientId)
}

/// Get total count of patients in the system
/// @return Number of patients
ClassMethod GetPatientCount() As %Integer
{
    Set tCount = 0
    
    Try {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT COUNT(*) AS PatientCount FROM " _ ..#TABLENAME
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            Set tResult = tStatement.%Execute()
            If tResult.%Next() {
                Set tCount = tResult.%Get("PatientCount")
            }
        }
    } Catch ex {
        Do ..LogError("GetPatientCount", ex)
        Set tCount = 0
    }
    
    Quit tCount
}

/// Get count of patients by department
/// @param pDepartment The department to count
/// @return Number of patients in the specified department
ClassMethod GetPatientCountByDepartment(pDepartment As %String) As %Integer
{
    Set tCount = 0
    
    Try {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT COUNT(*) AS PatientCount FROM " _ ..#TABLENAME _ " WHERE Department = ?"
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            Set tResult = tStatement.%Execute(pDepartment)
            If tResult.%Next() {
                Set tCount = tResult.%Get("PatientCount")
            }
        }
    } Catch ex {
        Do ..LogError("GetPatientCountByDepartment", ex)
        Set tCount = 0
    }
    
    Quit tCount
}

/// Get count of patients by status
/// @param pStatus The status to count
/// @return Number of patients with the specified status
ClassMethod GetPatientCountByStatus(pStatus As %String) As %Integer
{
    Set tCount = 0
    
    Try {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT COUNT(*) AS PatientCount FROM " _ ..#TABLENAME _ " WHERE Status = ?"
        Set tStatus = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tStatus) {
            Set tResult = tStatement.%Execute(pStatus)
            If tResult.%Next() {
                Set tCount = tResult.%Get("PatientCount")
            }
        }
    } Catch ex {
        Do ..LogError("GetPatientCountByStatus", ex)
        Set tCount = 0
    }
    
    Quit tCount
}

}
