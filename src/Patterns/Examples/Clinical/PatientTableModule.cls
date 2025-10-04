/// Healthcare Patient Table Module
/// 
/// Table Module implementation for Patient table operations.
/// Provides static methods for CRUD operations on patient data.
/// 
/// @see Patterns.PoEAA.DomainLogic.TableModule
/// @since 1.0.0
Class Patterns.Examples.Clinical.PatientTableModule Extends Patterns.PoEAA.DomainLogic.TableModule
{

/// Table name for patient data  
Parameter TABLENAME = "Patterns_Examples_Clinical.PersistentPatient";

/// Primary key column
Parameter PRIMARYKEY = "ID";

/// Find patient by medical record number
/// @param pMRN Medical record number (8 digits)
/// @return Dynamic object containing patient data or empty string if not found
ClassMethod FindByMedicalRecordNumber(pMRN As %String) As %DynamicObject
{
    Set tResult = ""
    
    Try {
        Set tSQL = "SELECT * FROM Patterns_Examples_Clinical.PersistentPatient WHERE MedicalRecordNumber = ?"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        Set tResultSet = tStatement.%Execute(pMRN)
        
        If tResultSet.%Next() {
            Set tResult = ..ResultSetRowToObject(tResultSet)
        }
        
    } Catch ex {
        Set tResult = ""
    }
    
    Quit tResult
}

/// Find patients by name (partial match)
/// @param pName Patient name (supports partial matching)
/// @return Dynamic array of patient objects
ClassMethod FindPatientsByName(pName As %String) As %DynamicArray
{
    Set tResult = []
    
    Try {
        Set tSQL = "SELECT * FROM Patterns_Examples_Clinical.PersistentPatient WHERE FullName LIKE ? ORDER BY FullName"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        // Add wildcards for partial matching
        Set tSearchPattern = "%" _ pName _ "%"
        Set tResultSet = tStatement.%Execute(tSearchPattern)
        
        While tResultSet.%Next() {
            Set tPatient = ..ResultSetRowToObject(tResultSet)
            If tPatient '= "" {
                Do tResult.%Push(tPatient)
            }
        }
        
    } Catch ex {
        Set tResult = []
    }
    
    Quit tResult
}

/// Insert new patient record
/// @param pData Dynamic object with patient data
/// @return Status indicating success or failure
ClassMethod InsertPatient(pData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate patient data
        Set tSC = ..ValidatePatientData(pData)
        If $$$ISERR(tSC) Quit
        
        // Create new patient object (PersistentPatient extends %Persistent)
        Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        
        // Map dynamic object properties to patient object
        If pData.%IsDefined("MedicalRecordNumber") {
            Set tPatient.MedicalRecordNumber = pData.MedicalRecordNumber
        }
        If pData.%IsDefined("FullName") {
            Set tPatient.FullName = pData.FullName
        }
        If pData.%IsDefined("DateOfBirth") {
            Set tPatient.DateOfBirth = pData.DateOfBirth
        }
        If pData.%IsDefined("WeightKg") {
            Set tPatient.WeightKg = pData.WeightKg
        }
        If pData.%IsDefined("HeightCm") {
            Set tPatient.HeightCm = pData.HeightCm
        }
        
        // Save patient object
        Set tSC = tPatient.%Save()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Update patient record
/// @param pId Patient ID
/// @param pData Dynamic object with updated patient data
/// @return Status indicating success or failure
ClassMethod UpdatePatient(pId As %Integer, pData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate patient data
        Set tSC = ..ValidatePatientData(pData)
        If $$$ISERR(tSC) Quit
        
        // Load existing patient object
        Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%OpenId(pId)
        If '$IsObject(tPatient) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient not found")
            Quit
        }
        
        // Update properties from dynamic object
        If pData.%IsDefined("MedicalRecordNumber") {
            Set tPatient.MedicalRecordNumber = pData.MedicalRecordNumber
        }
        If pData.%IsDefined("FullName") {
            Set tPatient.FullName = pData.FullName
        }
        If pData.%IsDefined("DateOfBirth") {
            Set tPatient.DateOfBirth = pData.DateOfBirth
        }
        If pData.%IsDefined("WeightKg") {
            Set tPatient.WeightKg = pData.WeightKg
        }
        If pData.%IsDefined("HeightCm") {
            Set tPatient.HeightCm = pData.HeightCm
        }
        
        // Save updated patient
        Set tSC = tPatient.%Save()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Delete patient record
/// @param pId Patient ID
/// @return Status indicating success or failure
ClassMethod DeletePatient(pId As %Integer) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check for referential integrity (medical records, etc.)
        Set tSC = ..CheckReferentialIntegrity(pId)
        If $$$ISERR(tSC) Quit
        
        // Use base class Delete method
        Set tSC = ..Delete(pId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get all active patients
/// @return Dynamic array of active patient objects
ClassMethod GetAllActivePatients() As %DynamicArray
{
    Set tResult = []
    
    Try {
        // Assuming active patients are those with recent activity
        // For demo purposes, returning all patients
        Set tResult = ..FindAll()
        
    } Catch ex {
        Set tResult = []
    }
    
    Quit tResult
}

/// Search patients by diagnosis
/// @param pDiagnosisCode Diagnosis code to search for
/// @return Dynamic array of patient objects with matching diagnosis
ClassMethod SearchPatientsByDiagnosis(pDiagnosisCode As %String) As %DynamicArray
{
    Set tResult = []
    
    Try {
        // This would typically join with diagnosis or medical record tables
        // For demo purposes, using a simple query
        Set tSQL = "SELECT DISTINCT p.* FROM Patterns_Examples_Clinical.PersistentPatient p WHERE p.ID IN (SELECT PatientID FROM SomeDiagnosisTable WHERE DiagnosisCode = ?)"
        
        // Simplified version - return empty array as placeholder
        // In real implementation, would query related diagnosis tables
        Set tResult = []
        
    } Catch ex {
        Set tResult = []
    }
    
    Quit tResult
}

/// Validate patient data
/// @param pData Dynamic object to validate
/// @return Status indicating validation success or failure
ClassMethod ValidatePatientData(pData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Call base class validation
        Set tSC = ..ValidateData(pData)
        If $$$ISERR(tSC) Quit
        
        // Validate medical record number (8 digits)
        If pData.%IsDefined("MedicalRecordNumber") {
            Set tMRN = pData.MedicalRecordNumber
            If ($LENGTH(tMRN) '= 8) || ('$MATCH(tMRN, "^[0-9]{8}$")) {
                Set tSC = $$$ERROR($$$GeneralError, "Medical record number must be 8 digits")
                Quit
            }
        }
        
        // Validate patient name
        If pData.%IsDefined("FullName") {
            Set tName = pData.FullName
            If ($LENGTH(tName) < 2) {
                Set tSC = $$$ERROR($$$GeneralError, "Patient name must be at least 2 characters")
                Quit
            }
        }
        
        // Validate date of birth is not in future
        If pData.%IsDefined("DateOfBirth") {
            Set tDOB = pData.DateOfBirth
            If (tDOB > +$HOROLOG) {
                Set tSC = $$$ERROR($$$GeneralError, "Date of birth cannot be in the future")
                Quit
            }
        }
        
        // Validate weight and height if provided
        If pData.%IsDefined("WeightKg") {
            Set tWeight = pData.WeightKg
            If (tWeight < 0) || (tWeight > 500) {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid weight value")
                Quit
            }
        }
        
        If pData.%IsDefined("HeightCm") {
            Set tHeight = pData.HeightCm
            If (tHeight < 0) || (tHeight > 300) {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid height value")
                Quit
            }
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check referential integrity before deleting patient
/// @param pId Patient ID
/// @return Status indicating if delete is safe
ClassMethod CheckReferentialIntegrity(pId As %Integer) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check for related medical records
        // In real implementation, would check for:
        // - Active medical records
        // - Scheduled appointments
        // - Pending lab results
        // - Active prescriptions
        
        // For demo purposes, allowing delete
        Set tSC = $$$OK
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get patient count by age range
/// @param pMinAge Minimum age
/// @param pMaxAge Maximum age
/// @return Number of patients in age range
ClassMethod GetCountByAgeRange(pMinAge As %Integer, pMaxAge As %Integer) As %Integer
{
    Set tCount = 0
    
    Try {
        Set tSQL = "SELECT COUNT(*) AS PatientCount FROM Patterns_Examples_Clinical.PersistentPatient WHERE DATEDIFF('year', DateOfBirth, CURRENT_DATE) BETWEEN ? AND ?"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        Set tResultSet = tStatement.%Execute(pMinAge, pMaxAge)
        
        If tResultSet.%Next() {
            Set tCount = tResultSet.%Get("PatientCount")
        }
        
    } Catch ex {
        Set tCount = 0
    }
    
    Quit tCount
}

/// Get patients needing wellness checkup (last visit > 1 year)
/// @return Dynamic array of patient objects
ClassMethod GetPatientsNeedingCheckup() As %DynamicArray
{
    Set tResult = []
    
    Try {
        // This would join with visit/appointment tables
        // For demo purposes, returning empty array as placeholder
        Set tResult = []
        
    } Catch ex {
        Set tResult = []
    }
    
    Quit tResult
}

/// Calculate average patient age
/// @return Average age in years
ClassMethod CalculateAverageAge() As %Numeric
{
    Set tAverage = 0
    
    Try {
        Set tSQL = "SELECT AVG(DATEDIFF('year', DateOfBirth, CURRENT_DATE)) AS AvgAge FROM Patterns_Examples_Clinical.PersistentPatient"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) Quit
        
        Set tResultSet = tStatement.%Execute()
        
        If tResultSet.%Next() {
            Set tAverage = tResultSet.%Get("AvgAge")
        }
        
    } Catch ex {
        Set tAverage = 0
    }
    
    Quit tAverage
}

}
