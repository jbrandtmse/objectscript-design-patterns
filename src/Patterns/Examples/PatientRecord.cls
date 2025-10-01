/// Healthcare Patient Record - Concrete Medical Record for Visitor Pattern Example
/// 
/// This class represents a patient's demographic and basic health information.
/// It demonstrates how the Visitor pattern enables different operations
/// (audit, billing, statistics, export) without modifying the record structure.
/// 
/// <example>
/// Set patient = ##class(Patterns.Examples.PatientRecord).%New()
/// Do patient.SetPatientInfo("12345", "John", "Doe", "1980-01-15")
/// Set auditVisitor = ##class(Patterns.Examples.AuditVisitor).%New()
/// Do patient.Accept(auditVisitor)
/// </example>
/// 
/// @see Patterns.Examples.MedicalRecordElement
/// @see Patterns.Examples.AuditVisitor
/// @since 1.0.0
Class Patterns.Examples.PatientRecord Extends Patterns.Examples.MedicalRecordElement [ Abstract ]
{

/// Patient's first name
Property FirstName As %String;

/// Patient's last name
Property LastName As %String;

/// Date of birth
Property DateOfBirth As %Date;

/// Gender (M/F/O/U)
Property Gender As %String;

/// Social Security Number (encrypted/masked)
Property SSN As %String;

/// Insurance ID
Property InsuranceId As %String;

/// Emergency contact name
Property EmergencyContact As %String;

/// Emergency contact phone
Property EmergencyPhone As %String;

/// Primary diagnosis codes (ICD-10)
Property DiagnosisCodes As %String;

/// Current medications list
Property CurrentMedications As %String;

/// Allergies information
Property Allergies As %String;

/// Patient Name (legacy property for Factory Method compatibility)
Property PatientName As %String;

/// Patient MRN (Medical Record Number)
Property PatientMRN As %String;

/// Constructor - initialize patient record
Method %OnNew(initvalue As %String = "") As %Status
{
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    Set ..RecordType = "PatientRecord"
    Set ..SecurityLevel = "HighlyConfidential"  // Patient records are highly sensitive
    
    // Initialize compatibility properties
    Do ..SyncPatientProperties()
    
    Quit $$$OK
}

/// Initialize patient record - override for Factory Method compatibility
/// @return %Status indicating success or failure
Method Initialize() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Patient-specific initialization
    Set ..RecordType = "PatientRecord"
    Set ..SecurityLevel = "HighlyConfidential"
    
    // Sync patient properties for compatibility
    Do ..SyncPatientProperties()
    
    Quit $$$OK
}

/// Sync patient properties for Factory Method compatibility
Method SyncPatientProperties() [ Private ]
{
    // Sync PatientName with FirstName/LastName
    If ..PatientName = "" && (..FirstName '= "" || ..LastName '= "") {
        Set ..PatientName = ..GetFullName()
    }
    
    // Sync PatientMRN with PatientId
    If ..PatientMRN = "" && ..PatientId '= "" {
        Set ..PatientMRN = ..PatientId
    }
    If ..PatientId = "" && ..PatientMRN '= "" {
        Set ..PatientId = ..PatientMRN
    }
}

/// Accept a visitor - implements double dispatch for patient records
/// Calls the appropriate visitor method for patient record analysis
/// 
/// @param pVisitor The visitor to accept
/// @return %Status indicating success or failure
Method Accept(pVisitor As Patterns.GoF.Behavioral.Visitor) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Double dispatch - tell visitor this is a PatientRecord
        Set tSC = pVisitor.VisitPatientRecord($this)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Set patient demographic information
/// 
/// @param pPatientId Unique patient identifier
/// @param pFirstName Patient's first name
/// @param pLastName Patient's last name
/// @param pDateOfBirth Date of birth (YYYY-MM-DD format)
/// @return %Status indicating success or failure
Method SetPatientInfo(pPatientId As %String, pFirstName As %String, pLastName As %String, pDateOfBirth As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..PatientId = pPatientId
        Set ..FirstName = pFirstName
        Set ..LastName = pLastName
        
        // Update compatibility properties
        Set ..PatientMRN = pPatientId
        Set ..PatientName = ..GetFullName()
        
        // Convert date string to %Date - handle YYYY-MM-DD format
        If pDateOfBirth '= "" {
            // Parse YYYY-MM-DD manually and convert to $HOROLOG format
            Set tYear = $PIECE(pDateOfBirth, "-", 1)
            Set tMonth = $PIECE(pDateOfBirth, "-", 2)
            Set tDay = $PIECE(pDateOfBirth, "-", 3)
            
            // Use simple calculation: days since 1841-01-01 (ObjectScript epoch)
            Set tBaseYear = 1841
            Set tDays = 0
            
            // Add days for complete years
            For tY = tBaseYear:1:(tYear-1) {
                Set tDays = tDays + $SELECT(((tY#4=0)&&(tY#100'=0))||(tY#400=0):366, 1:365)
            }
            
            // Add days for complete months in the target year
            Set tIsLeap = $SELECT(((tYear#4=0)&&(tYear#100'=0))||(tYear#400=0):1, 1:0)
            Set tMonthDays = "31,28,31,30,31,30,31,31,30,31,30,31"
            If tIsLeap Set $PIECE(tMonthDays, ",", 2) = "29"
            
            For tM = 1:1:(tMonth-1) {
                Set tDays = tDays + $PIECE(tMonthDays, ",", tM)
            }
            
            // Add remaining days
            Set tDays = tDays + tDay - 1
            
            Set ..DateOfBirth = tDays
        }
        
        Do ..Touch()  // Update modification timestamp
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get patient's full name
/// 
/// @return %String Full name
Method GetFullName() As %String
{
    Quit ..FirstName_" "_..LastName
}

/// Calculate patient's age
/// 
/// @return %Integer Age in years
Method GetAge() As %Integer
{
    If ..DateOfBirth = "" Quit 0
    
    Set tToday = +$HOROLOG
    Set tBirthDate = +..DateOfBirth
    
    // Simple age calculation in days, then convert to years
    Set tAgeDays = tToday - tBirthDate
    Set tAge = tAgeDays \ 365.25  // Account for leap years
    
    Quit tAge
}

/// Get patient's data for visitor processing
/// Returns patient demographic information
/// 
/// @return %String Patient data
Method GetData() As %String
{
    Quit "Patient: "_..GetFullName()_", Age: "_..GetAge()_", Gender: "_..Gender_", DOB: "_$ZDATE(..DateOfBirth, 5)
}

/// Add diagnosis code
/// 
/// @param pCode ICD-10 diagnosis code
/// @return %Status indicating success or failure
Method AddDiagnosisCode(pCode As %String) As %Status
{
    If ..DiagnosisCodes = "" {
        Set ..DiagnosisCodes = pCode
    } Else {
        Set ..DiagnosisCodes = ..DiagnosisCodes_","_pCode
    }
    
    Do ..Touch()
    Quit $$$OK
}

/// Add current medication
/// 
/// @param pMedication Medication name and dosage
/// @return %Status indicating success or failure
Method AddMedication(pMedication As %String) As %Status
{
    If ..CurrentMedications = "" {
        Set ..CurrentMedications = pMedication
    } Else {
        Set ..CurrentMedications = ..CurrentMedications_";"_pMedication
    }
    
    Do ..Touch()
    Quit $$$OK
}

/// Add allergy information
/// 
/// @param pAllergy Allergy description
/// @return %Status indicating success or failure
Method AddAllergy(pAllergy As %String) As %Status
{
    If ..Allergies = "" {
        Set ..Allergies = pAllergy
    } Else {
        Set ..Allergies = ..Allergies_";"_pAllergy
    }
    
    Do ..Touch()
    Quit $$$OK
}

/// Check if patient is a minor
/// 
/// @return %Boolean True if patient is under 18
Method IsMinor() As %Boolean
{
    Quit (..GetAge() < 18)
}

/// Get insurance information for billing
/// 
/// @return %String Insurance details
Method GetInsuranceInfo() As %String
{
    Quit "Insurance ID: "_..InsuranceId
}

/// Validate patient record data
/// Enhanced validation for patient records
/// 
/// @return %Status indicating validation result
Method ValidateRecord() As %Status
{
    Set tSC = ##super()  // Call parent validation
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        // Patient-specific validations
        If ..FirstName = "" {
            Set tSC = $$$ERROR($$$GeneralError, "First name is required")
            Quit
        }
        
        If ..LastName = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Last name is required")
            Quit
        }
        
        If ..DateOfBirth = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Date of birth is required")
            Quit
        }
        
        // Validate gender
        If ..Gender '= "" && ("MFOU"'[..Gender) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid gender: "_..Gender_" (must be M, F, O, or U)")
            Quit
        }
        
        // Check age reasonableness
        Set tAge = ..GetAge()
        If tAge < 0 || tAge > 150 {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid age: "_tAge)
            Quit
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clone patient record
/// Creates a copy of the patient record with new ID
/// 
/// @return Element A clone of this patient record
Method Clone() As Patterns.GoF.Behavioral.Element [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Get demographics summary for reporting
/// 
/// @return %DynamicObject Demographics data
Method GetDemographics() As %DynamicObject
{
    Set tDemo = ##class(%DynamicObject).%New()
    Do tDemo.%Set("patientId", ..PatientId)
    Do tDemo.%Set("fullName", ..GetFullName())
    Do tDemo.%Set("age", ..GetAge())
    Do tDemo.%Set("gender", ..Gender)
    Do tDemo.%Set("isMinor", ..IsMinor())
    Do tDemo.%Set("hasInsurance", (..InsuranceId '= ""))
    Do tDemo.%Set("diagnosisCount", $LENGTH(..DiagnosisCodes, ","))
    Do tDemo.%Set("medicationCount", $LENGTH(..CurrentMedications, ";"))
    Do tDemo.%Set("allergyCount", $LENGTH(..Allergies, ";"))
    
    Quit tDemo
}

}
