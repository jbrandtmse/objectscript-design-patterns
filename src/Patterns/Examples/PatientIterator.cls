/// Healthcare Example - Patient Iterator
/// Provides filtered iteration over patient records
Class Patterns.Examples.PatientIterator Extends Patterns.GoF.Behavioral.Iterator
{

/// SQL cursor iterator for patients
Property SQLIterator As Patterns.GoF.Behavioral.SQLCursorIterator [ Private ];

/// Filter criteria
Property FilterCriteria As %DynamicObject;

/// Constructor with filter criteria
Method %OnNew(pFilterCriteria As %DynamicObject = "") As %Status
{
        Set tSC = $$$OK
        Try {
            Set ..FilterCriteria = pFilterCriteria
            
            // Build SQL query based on filter criteria
            Set tSQL = "SELECT ID, MRN, FirstName, LastName, DateOfBirth, Gender, "_
                      "Department, DiagnosisCode, AdmissionDate, DischargeDate, Status, "_
                      "LastVisitDate, AttendingPhysician, InsuranceProvider "_
                      "FROM Patterns_Examples.PatientRecord"
            
            Set tWhere = ""
            Set tParams = ##class(%ListOfDataTypes).%New()
            
            If $IsObject(pFilterCriteria) {
                // Department filter
                If pFilterCriteria.%IsDefined("department") {
                    Set tWhere = tWhere_$SELECT(tWhere="":"WHERE ",1:" AND ")_"Department = ?"
                    Do tParams.Insert(pFilterCriteria.department)
                }
                
                // Diagnosis filter
                If pFilterCriteria.%IsDefined("diagnosis") {
                    Set tWhere = tWhere_$SELECT(tWhere="":"WHERE ",1:" AND ")_"DiagnosisCode = ?"
                    Do tParams.Insert(pFilterCriteria.diagnosis)
                }
                
                // Status filter
                If pFilterCriteria.%IsDefined("status") {
                    Set tWhere = tWhere_$SELECT(tWhere="":"WHERE ",1:" AND ")_"Status = ?"
                    Do tParams.Insert(pFilterCriteria.status)
                }
                
                // Date range filter
                If pFilterCriteria.%IsDefined("startDate") {
                    Set tWhere = tWhere_$SELECT(tWhere="":"WHERE ",1:" AND ")_"AdmissionDate >= ?"
                    Do tParams.Insert(pFilterCriteria.startDate)
                }
                
                If pFilterCriteria.%IsDefined("endDate") {
                    Set tWhere = tWhere_$SELECT(tWhere="":"WHERE ",1:" AND ")_"AdmissionDate <= ?"
                    Do tParams.Insert(pFilterCriteria.endDate)
                }
            }
            
            Set tSQL = tSQL_" "_tWhere_" ORDER BY AdmissionDate DESC"
            
            // Create SQL cursor iterator
            Set ..SQLIterator = ##class(Patterns.GoF.Behavioral.SQLCursorIterator).%New(tSQL, tParams)
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
}

/// Check if more patients exist
Method HasNext() As %Boolean
{
        If '$IsObject(..SQLIterator) Quit 0
        Quit ..SQLIterator.HasNext()
}

/// Get next patient as dynamic object
Method Next() As %RegisteredObject
{
        If '$IsObject(..SQLIterator) Quit $$$NULLOREF
        Quit ..SQLIterator.Next()
}

/// Get current patient without advancing
Method Current() As %RegisteredObject
{
        If '$IsObject(..SQLIterator) Quit $$$NULLOREF
        Quit ..SQLIterator.Current()
}

/// Reset iteration
Method Reset() As %Status
{
        If '$IsObject(..SQLIterator) Quit $$$ERROR($$$GeneralError, "No SQL iterator")
        Quit ..SQLIterator.Reset()
}

/// Create iterator for active patients
ClassMethod GetActivePatients() As PatientIterator
{
        Set tFilter = ##class(%DynamicObject).%New()
        Set tFilter.status = "Active"
        Quit ##class(PatientIterator).%New(tFilter)
}

/// Create iterator for department
ClassMethod GetPatientsByDepartment(pDepartment As %String) As PatientIterator
{
        Set tFilter = ##class(%DynamicObject).%New()
        Set tFilter.department = pDepartment
        Quit ##class(PatientIterator).%New(tFilter)
}

/// Create iterator for diagnosis code
ClassMethod GetPatientsByDiagnosis(pDiagnosisCode As %String) As PatientIterator
{
        Set tFilter = ##class(%DynamicObject).%New()
        Set tFilter.diagnosis = pDiagnosisCode
        Quit ##class(PatientIterator).%New(tFilter)
}

/// Create iterator for date range
ClassMethod GetPatientsByDateRange(pStartDate As %String, pEndDate As %String) As PatientIterator
{
        Set tFilter = ##class(%DynamicObject).%New()
        Set tFilter.startDate = pStartDate
        Set tFilter.endDate = pEndDate
        Quit ##class(PatientIterator).%New(tFilter)
}

/// Demonstrate HIPAA audit logging
Method LogAccess(pUserID As %String, pReason As %String) As %Status
{
        Set tSC = $$$OK
        Try {
            Set ^Patterns.HIPAA.AuditLog($INCREMENT(^Patterns.HIPAA.AuditLog)) = $LISTBUILD(
                $ZDATETIME($HOROLOG, 3),
                pUserID,
                "PatientIterator",
                pReason,
                ..FilterCriteria.%ToJSON()
            )
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
}

}
