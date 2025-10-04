/// Healthcare Patient Domain Object
/// 
/// Represents a patient in the clinical domain model with medical history,
/// allergies, and medications. Encapsulates patient-specific business rules.
/// 
/// @see Patterns.Examples.Clinical.MedicalRecord
/// @since 1.0.0
Class Patterns.Examples.Clinical.Patient Extends Patterns.PoEAA.DomainLogic.DomainModel
{

/// Patient medical record number
Property MedicalRecordNumber As %String;

/// Patient full name
Property FullName As %String;

/// Date of birth
Property DateOfBirth As %Date;

/// Patient allergies (multi-dimensional array)
Property Allergies [ MultiDimensional ];

/// Active medications (multi-dimensional array)
Property ActiveMedications [ MultiDimensional ];

/// Medical history entries (multi-dimensional array)
Property MedicalHistory [ MultiDimensional ];

/// Patient weight in kilograms
Property WeightKg As %Numeric;

/// Patient height in centimeters
Property HeightCm As %Numeric;

/// Domain-specific initialization
Method Initialize() As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize collections
        Kill ..Allergies
        Kill ..ActiveMedications
        Kill ..MedicalHistory
        
        // Set default values
        Set ..WeightKg = 0
        Set ..HeightCm = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check patient domain invariants
Method CheckInvariants() As %Boolean
{
    // Patient must have medical record number
    If (..MedicalRecordNumber = "") Quit 0
    
    // Patient must have a name
    If (..FullName = "") Quit 0
    
    // Patient must have valid date of birth
    If (..DateOfBirth = "") Quit 0
    
    // If weight/height specified, must be positive
    If (..WeightKg < 0) Quit 0
    If (..HeightCm < 0) Quit 0
    
    Quit 1
}

/// Perform patient-specific validation
Method PerformValidation() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate medical record number format (8 digits)
        If ($LENGTH(..MedicalRecordNumber) '= 8) || ('$MATCH(..MedicalRecordNumber, "^[0-9]{8}$")) {
            Do ..AddValidationError("MedicalRecordNumber", "Medical record number must be 8 digits")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid medical record number")
            Quit
        }
        
        // Validate name
        If ($LENGTH(..FullName) < 2) {
            Do ..AddValidationError("FullName", "Patient name must be at least 2 characters")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid patient name")
            Quit
        }
        
        // Validate date of birth is not in future
        If (..DateOfBirth > +$HOROLOG) {
            Do ..AddValidationError("DateOfBirth", "Date of birth cannot be in the future")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid date of birth")
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Execute patient business logic
Method ExecuteBusinessLogic() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate before execution
        Set tSC = ..ValidateRules()
        If $$$ISERR(tSC) Quit
        
        // Raise domain event
        Set tEventData = {"patientId": (..Identity), "mrn": (..MedicalRecordNumber)}
        Do ..RaiseDomainEvent("PatientValidated", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Add allergy to patient record
/// @param pAllergen Allergen name
/// @param pSeverity Severity level (Mild, Moderate, Severe)
Method AddAllergy(pAllergen As %String, pSeverity As %String = "Moderate") As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate inputs
        If (pAllergen = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Allergen name required")
            Quit
        }
        
        // Check for duplicate
        Set tExists = ..HasAllergy(pAllergen)
        If tExists {
            Set tSC = $$$ERROR($$$GeneralError, "Allergy already recorded")
            Quit
        }
        
        // Add allergy
        Set tCount = $GET(..Allergies)
        Set tCount = tCount + 1
        Set ..Allergies = tCount
        Set ..Allergies(tCount, "allergen") = pAllergen
        Set ..Allergies(tCount, "severity") = pSeverity
        Set ..Allergies(tCount, "recordedDate") = +$HOROLOG
        
        // Raise domain event
        Set tEventData = {"allergen": (pAllergen), "severity": (pSeverity)}
        Do ..RaiseDomainEvent("AllergyAdded", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check if patient has specific allergy
/// @param pAllergen Allergen name
/// @return 1 if patient has allergy, 0 otherwise
Method HasAllergy(pAllergen As %String) As %Boolean
{
    Set tResult = 0
    Set tCount = $GET(..Allergies)
    For tIndex = 1:1:tCount {
        Set tAllergen = $GET(..Allergies(tIndex, "allergen"))
        If (tAllergen = pAllergen) {
            Set tResult = 1
            Quit
        }
    }
    Quit tResult
}

/// Add medication to active medications
/// @param pMedication Medication name
/// @param pDosage Dosage instructions
Method AddMedication(pMedication As %String, pDosage As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate inputs
        If (pMedication = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Medication name required")
            Quit
        }
        
        If (pDosage = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Dosage required")
            Quit
        }
        
        // Add medication
        Set tCount = $GET(..ActiveMedications)
        Set tCount = tCount + 1
        Set ..ActiveMedications = tCount
        Set ..ActiveMedications(tCount, "medication") = pMedication
        Set ..ActiveMedications(tCount, "dosage") = pDosage
        Set ..ActiveMedications(tCount, "startDate") = +$HOROLOG
        
        // Raise domain event
        Set tEventData = {"medication": (pMedication), "dosage": (pDosage)}
        Do ..RaiseDomainEvent("MedicationAdded", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Calculate patient age in years
/// @return Age in years
Method CalculateAge() As %Integer
{
    Set tToday = +$HOROLOG
    Set tAge = $SYSTEM.SQL.DATEDIFF("year", ..DateOfBirth, tToday)
    Quit tAge
}

/// Calculate Body Mass Index (BMI)
/// @return BMI value or 0 if weight/height not set
Method CalculateBMI() As %Numeric
{
    If (..WeightKg <= 0) || (..HeightCm <= 0) Quit 0
    
    Set tHeightM = ..HeightCm / 100
    Set tBMI = ..WeightKg / (tHeightM * tHeightM)
    Quit $FNUMBER(tBMI, "", 2)
}

/// Add medical history entry
/// @param pCondition Medical condition
/// @param pDiagnosisDate Date of diagnosis
Method AddMedicalHistory(pCondition As %String, pDiagnosisDate As %Date = "") As %Status
{
    Set tSC = $$$OK
    Try {
        If (pCondition = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Condition required")
            Quit
        }
        
        If (pDiagnosisDate = "") {
            Set pDiagnosisDate = +$HOROLOG
        }
        
        Set tCount = $GET(..MedicalHistory)
        Set tCount = tCount + 1
        Set ..MedicalHistory = tCount
        Set ..MedicalHistory(tCount, "condition") = pCondition
        Set ..MedicalHistory(tCount, "diagnosisDate") = pDiagnosisDate
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
