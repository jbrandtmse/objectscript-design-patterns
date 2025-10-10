/// Healthcare Active Record Example - Patient domain object with built-in persistence
/// 
/// A self-persisting patient domain object that combines patient data with business logic
/// and data access. Demonstrates the Active Record pattern in a healthcare context.
/// 
/// Key features:
/// - Patient demographic and clinical data
/// - Domain validation (MRN, age, status)
/// - Business logic (Admit, Discharge, Transfer)
/// - Calculated properties (Age, FullName, LengthOfStay)
/// - Custom finders (FindByMRN, FindByDepartment)
/// - Automatic persistence via %Persistent
/// 
/// Usage:
/// <example>
/// // Create new patient
/// Set patient = ##class(PatientActiveRecord).%New()
/// Set patient.FirstName = "John"
/// Set patient.LastName = "Doe"
/// Set patient.MRN = "MRN12345"
/// Set patient.DateOfBirth = $ZDATEH("1980-05-15", 3)
/// Set patient.Gender = "M"
/// Set patient.Status = "Pending"
/// Set tSC = patient.Save()
/// 
/// // Admit patient
/// Set tSC = patient.Admit("Cardiology")
/// 
/// // Find patient by MRN
/// Set patient = ##class(PatientActiveRecord).FindByMRN("MRN12345")
/// Write patient.GetFullName(), " is ", patient.GetAge(), " years old"
/// </example>
Class Patterns.Examples.Clinical.PatientActiveRecord Extends Patterns.PoEAA.DataSource.ActiveRecord
{

/// Patient's first name
Property FirstName As %String(MAXLEN = 50);

/// Patient's last name
Property LastName As %String(MAXLEN = 50);

/// Patient's date of birth
Property DateOfBirth As %Date;

/// Patient's gender (M/F/O)
Property Gender As %String(MAXLEN = 1);

/// Current department assignment
Property Department As %String(MAXLEN = 100);

/// Current patient status (Pending/Admitted/Discharged)
Property Status As %String(MAXLEN = 20);

/// Medical Record Number - unique patient identifier
Property MRN As %String(MAXLEN = 20);

/// Admission date when patient was admitted
Property AdmissionDate As %Date;

/// Index for fast MRN lookups (unique)
Index MRNIdx On MRN [ Unique ];

/// Index for last name searches
Index LastNameIdx On LastName;

/// Index for department queries
Index DepartmentIdx On Department;

/// Validate patient data before save
/// Checks MRN format and uniqueness, age validity, and required fields
/// 
/// Returns:
///   %Status - $$$OK if validation passes, error status otherwise
Method ValidateData() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate required fields
        If (..FirstName = "") {
            Set tSC = $$$ERROR($$$GeneralError, "First name is required")
            Quit
        }
        
        If (..LastName = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Last name is required")
            Quit
        }
        
        If (..MRN = "") {
            Set tSC = $$$ERROR($$$GeneralError, "MRN is required")
            Quit
        }
        
        If (..DateOfBirth = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Date of birth is required")
            Quit
        }
        
        If (..Gender = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Gender is required")
            Quit
        }
        
        If (..Status = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Status is required")
            Quit
        }
        
        // Validate MRN
        Set tSC = ..ValidateMRN()
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Validate age
        Set tSC = ..ValidateAge()
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Validate status
        Set tSC = ..ValidateStatus()
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Validate gender
        If ((..Gender '= "M") && (..Gender '= "F") && (..Gender '= "O")) {
            Set tSC = $$$ERROR($$$GeneralError, "Gender must be M, F, or O")
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate Medical Record Number
/// Ensures MRN is properly formatted and unique
/// 
/// Returns:
///   %Status - $$$OK if MRN is valid, error status otherwise
Method ValidateMRN() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check MRN format (must start with MRN and have digits)
        If ($LENGTH(..MRN) < 6) {
            Set tSC = $$$ERROR($$$GeneralError, "MRN must be at least 6 characters")
            Quit
        }
        
        If ($EXTRACT(..MRN, 1, 3) '= "MRN") {
            Set tSC = $$$ERROR($$$GeneralError, "MRN must start with 'MRN'")
            Quit
        }
        
        // Check uniqueness - find any existing record with this MRN
        Set tSQL = "SELECT ID FROM Patterns_Examples_Clinical.PatientActiveRecord WHERE MRN = ?"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tSC) {
            Set tResult = tStatement.%Execute(..MRN)
            If tResult.%Next() {
                // Found existing MRN
                Set tExistingId = tResult.%Get("ID")
                // Allow if it's the same record (for updates)
                If (tExistingId '= ..%Id()) {
                    Set tSC = $$$ERROR($$$GeneralError, "MRN already exists for another patient")
                    Quit
                }
            }
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate patient age
/// Ensures patient age is within acceptable range (0-150 years)
/// 
/// Returns:
///   %Status - $$$OK if age is valid, error status otherwise
Method ValidateAge() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tAge = ..GetAge()
        
        If (tAge < 0) {
            Set tSC = $$$ERROR($$$GeneralError, "Date of birth cannot be in the future")
            Quit
        }
        
        If (tAge > 150) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid date of birth - age exceeds 150 years")
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate patient status
/// Ensures status is one of the allowed values
/// 
/// Returns:
///   %Status - $$$OK if status is valid, error status otherwise
Method ValidateStatus() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tValidStatuses = ",Pending,Admitted,Discharged,"
        
        If (tValidStatuses '[ (","_..Status_",")) {
            Set tSC = $$$ERROR($$$GeneralError, "Status must be Pending, Admitted, or Discharged")
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Business logic: Admit patient to a department
/// Changes patient status to Admitted and assigns department
/// 
/// Parameters:
///   pDepartment - The department to admit the patient to
/// 
/// Returns:
///   %Status - $$$OK if admission succeeds, error status otherwise
Method Admit(pDepartment As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate business rule - can only admit pending patients
        If (..Status '= "Pending") {
            Set tSC = $$$ERROR($$$GeneralError, "Patient must be in Pending status to admit")
            Quit
        }
        
        // Validate department provided
        If (pDepartment = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Department is required for admission")
            Quit
        }
        
        // Update domain state
        Set ..Department = pDepartment
        Set ..Status = "Admitted"
        Set ..AdmissionDate = +$HOROLOG
        
        // Persist changes
        Set tSC = ..Save()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Business logic: Discharge patient from hospital
/// Changes patient status to Discharged and clears department
/// 
/// Returns:
///   %Status - $$$OK if discharge succeeds, error status otherwise
Method Discharge() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate business rule - can only discharge admitted patients
        If (..Status '= "Admitted") {
            Set tSC = $$$ERROR($$$GeneralError, "Patient must be in Admitted status to discharge")
            Quit
        }
        
        // Update domain state
        Set ..Status = "Discharged"
        Set ..Department = ""
        
        // Persist changes
        Set tSC = ..Save()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Business logic: Transfer patient to different department
/// Changes patient's department assignment while maintaining admitted status
/// 
/// Parameters:
///   pDepartment - The department to transfer the patient to
/// 
/// Returns:
///   %Status - $$$OK if transfer succeeds, error status otherwise
Method Transfer(pDepartment As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate business rule - can only transfer admitted patients
        If (..Status '= "Admitted") {
            Set tSC = $$$ERROR($$$GeneralError, "Patient must be in Admitted status to transfer")
            Quit
        }
        
        // Validate department provided
        If (pDepartment = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Department is required for transfer")
            Quit
        }
        
        // Validate not transferring to same department
        If (pDepartment = ..Department) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient is already in " _ pDepartment)
            Quit
        }
        
        // Update domain state
        Set ..Department = pDepartment
        
        // Persist changes
        Set tSC = ..Save()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Business logic: Update patient status with validation
/// Changes patient status with business rule validation
/// 
/// Parameters:
///   pStatus - The new status (Pending, Admitted, Discharged)
/// 
/// Returns:
///   %Status - $$$OK if update succeeds, error status otherwise
Method UpdateStatus(pStatus As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate status value
        Set tValidStatuses = ",Pending,Admitted,Discharged,"
        
        If (tValidStatuses '[ (","_pStatus_",")) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid status: " _ pStatus)
            Quit
        }
        
        // Validate status transitions
        If (..Status = "Discharged") && (pStatus '= "Pending") {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot change status from Discharged to " _ pStatus)
            Quit
        }
        
        // Update domain state
        Set ..Status = pStatus
        
        // Clear department if not admitted
        If (pStatus '= "Admitted") {
            Set ..Department = ""
        }
        
        // Persist changes
        Set tSC = ..Save()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Calculated property: Get patient's current age
/// Calculates age from date of birth
/// 
/// Returns:
///   %Integer - Patient's age in years
Method GetAge() As %Integer
{
    Set tAge = 0
    
    Try {
        If (..DateOfBirth '= "") {
            Set tToday = +$HOROLOG
            Set tBirthday = ..DateOfBirth
            
            // Calculate age in days and convert to years
            Set tDays = tToday - tBirthday
            Set tAge = tDays \ 365
        }
        
    } Catch ex {
        Set tAge = 0
    }
    
    Quit tAge
}

/// Calculated property: Get patient's full name
/// Concatenates first and last name
/// 
/// Returns:
///   %String - Patient's full name
Method GetFullName() As %String
{
    Set tFullName = ""
    
    Try {
        Set tFullName = ..FirstName _ " " _ ..LastName
        
    } Catch ex {
        Set tFullName = ""
    }
    
    Quit tFullName
}

/// Calculated property: Get length of stay
/// Calculates days since admission for admitted patients
/// 
/// Returns:
///   %Integer - Days since admission, or 0 if not admitted
Method GetLengthOfStay() As %Integer
{
    Set tDays = 0
    
    Try {
        If (..Status = "Admitted") && (..AdmissionDate '= "") {
            Set tToday = +$HOROLOG
            Set tDays = tToday - ..AdmissionDate
        }
        
    } Catch ex {
        Set tDays = 0
    }
    
    Quit tDays
}

/// Find patient by Medical Record Number
/// Loads patient active record by MRN
/// 
/// Parameters:
///   pMRN - The medical record number to search for
/// 
/// Returns:
///   PatientActiveRecord - The patient instance, or empty string if not found
ClassMethod FindByMRN(pMRN As %String) As Patterns.Examples.Clinical.PatientActiveRecord
{
    Set tRecord = ""
    
    Try {
        // Use parameterized query to prevent SQL injection
        Set tSQL = "SELECT ID FROM Patterns_Examples_Clinical.PatientActiveRecord WHERE MRN = ?"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tSC) {
            Set tResult = tStatement.%Execute(pMRN)
            
            If tResult.%Next() {
                Set tId = tResult.%Get("ID")
                Set tRecord = ..%OpenId(tId)
            }
        }
        
    } Catch ex {
        // Log error and return empty
        Set tRecord = ""
    }
    
    Quit tRecord
}

/// Find all patients in a specific department
/// Loads all patient active records for a department
/// 
/// Parameters:
///   pDepartment - The department to search for
/// 
/// Returns:
///   %ListOfObjects - List of patient instances in the department
ClassMethod FindByDepartment(pDepartment As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Use parameterized query to prevent SQL injection
        Set tSQL = "SELECT ID FROM Patterns_Examples_Clinical.PatientActiveRecord WHERE Department = ? ORDER BY LastName, FirstName"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSQL)
        
        If $$$ISOK(tSC) {
            Set tResult = tStatement.%Execute(pDepartment)
            
            While tResult.%Next() {
                Set tId = tResult.%Get("ID")
                Set tRecord = ..%OpenId(tId)
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
<Data name="PatientActiveRecordDefaultData">
<Subscript>"PatientActiveRecord"</Subscript>
<Value name="1">
<Value>FirstName</Value>
</Value>
<Value name="2">
<Value>LastName</Value>
</Value>
<Value name="3">
<Value>DateOfBirth</Value>
</Value>
<Value name="4">
<Value>Gender</Value>
</Value>
<Value name="5">
<Value>Department</Value>
</Value>
<Value name="6">
<Value>Status</Value>
</Value>
<Value name="7">
<Value>MRN</Value>
</Value>
<Value name="8">
<Value>AdmissionDate</Value>
</Value>
</Data>
<DefaultData>PatientActiveRecordDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
