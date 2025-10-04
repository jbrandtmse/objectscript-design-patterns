/// Healthcare Medical Record - Aggregate Root
/// 
/// Represents a complete medical record coordinating Patient, Diagnoses, and Treatments.
/// Acts as the aggregate root maintaining consistency boundaries and business rules.
/// 
/// @see Patterns.PoEAA.DomainLogic.DomainModel
/// @since 1.0.0
Class Patterns.Examples.Clinical.MedicalRecord Extends Patterns.PoEAA.DomainLogic.DomainModel
{

/// Patient associated with this medical record
Property Patient As Patterns.Examples.Clinical.Patient;

/// Collection of diagnoses (multi-dimensional array)
Property Diagnoses [ MultiDimensional ];

/// Collection of treatments (multi-dimensional array)
Property Treatments [ MultiDimensional ];

/// Medical record status (Active, Discharged, Archived)
Property RecordStatus As %String;

/// Admission date
Property AdmissionDate As %Date;

/// Discharge date
Property DischargeDate As %Date;

/// Domain-specific initialization
Method Initialize() As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize collections
        Kill ..Diagnoses
        Kill ..Treatments
        
        // Set default values
        Set ..RecordStatus = "Active"
        Set ..AdmissionDate = +$HOROLOG
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check medical record domain invariants
Method CheckInvariants() As %Boolean
{
    // Must have a patient
    If '$ISOBJECT(..Patient) Quit 0
    
    // Patient must be valid
    If '..Patient.IsValid Quit 0
    
    // Must have valid record status
    If '..IsValidRecordStatus(..RecordStatus) Quit 0
    
    // Discharge date must be after admission if specified
    If (..DischargeDate '= "") && (..DischargeDate < ..AdmissionDate) Quit 0
    
    Quit 1
}

/// Perform medical record validation
Method PerformValidation() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate patient exists and is valid
        If '$ISOBJECT(..Patient) {
            Do ..AddValidationError("Patient", "Patient is required")
            Set tSC = $$$ERROR($$$GeneralError, "Patient required")
            Quit
        }
        
        // Validate patient
        Set tSC = ..Patient.ValidateRules()
        If $$$ISERR(tSC) {
            Do ..AddValidationError("Patient", "Patient validation failed")
            Quit
        }
        
        // Validate admission date
        If (..AdmissionDate > +$HOROLOG) {
            Do ..AddValidationError("AdmissionDate", "Admission date cannot be in the future")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid admission date")
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Execute medical record business logic
Method ExecuteBusinessLogic() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate before execution
        Set tSC = ..ValidateRules()
        If $$$ISERR(tSC) Quit
        
        // Raise domain event
        Set tEventData = {"recordId": (..Identity), "patientMRN": (..Patient.MedicalRecordNumber)}
        Do ..RaiseDomainEvent("MedicalRecordValidated", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check if record status is valid
/// @param pStatus Status to validate
/// @return 1 if valid, 0 otherwise
Method IsValidRecordStatus(pStatus As %String) As %Boolean
{
    Set tValid = $LISTFIND($LISTBUILD("Active", "Discharged", "Archived"), pStatus)
    Quit (tValid > 0)
}

/// Admit patient
/// @param pPatient Patient to admit
Method AdmitPatient(pPatient As Patterns.Examples.Clinical.Patient) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$ISOBJECT(pPatient) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient object required")
            Quit
        }
        
        // Validate patient
        Set tSC = pPatient.ValidateRules()
        If $$$ISERR(tSC) Quit
        
        // Assign patient
        Set ..Patient = pPatient
        Set ..AdmissionDate = +$HOROLOG
        Set ..RecordStatus = "Active"
        
        // Raise domain event
        Set tEventData = {"recordId": (..Identity), "patientMRN": (pPatient.MedicalRecordNumber)}
        Do ..RaiseDomainEvent("PatientAdmitted", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Add diagnosis to medical record
/// @param pDiagnosis Diagnosis to add
Method AddDiagnosis(pDiagnosis As Patterns.Examples.Clinical.Diagnosis) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$ISOBJECT(pDiagnosis) {
            Set tSC = $$$ERROR($$$GeneralError, "Diagnosis object required")
            Quit
        }
        
        // Validate diagnosis
        Set tSC = pDiagnosis.ValidateRules()
        If $$$ISERR(tSC) Quit
        
        // Add diagnosis to collection
        Set tCount = $GET(..Diagnoses)
        Set tCount = tCount + 1
        Set ..Diagnoses = tCount
        Set ..Diagnoses(tCount) = pDiagnosis
        
        // Raise domain event
        Set tEventData = {"recordId": (..Identity), "diagnosisCode": (pDiagnosis.DiagnosisCode)}
        Do ..RaiseDomainEvent("DiagnosisAdded", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Add treatment to medical record with safety checks
/// @param pTreatment Treatment to add
Method AddTreatment(pTreatment As Patterns.Examples.Clinical.Treatment) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$ISOBJECT(pTreatment) {
            Set tSC = $$$ERROR($$$GeneralError, "Treatment object required")
            Quit
        }
        
        // Validate treatment
        Set tSC = pTreatment.ValidateRules()
        If $$$ISERR(tSC) Quit
        
        // Check for drug interactions with active medications
        Set tSC = ..CheckDrugInteractions(pTreatment)
        If $$$ISERR(tSC) {
            Do ..AddValidationError("Treatment", "Drug interaction detected")
            Quit
        }
        
        // Check for contraindications based on diagnoses
        Set tSC = ..CheckContraindications(pTreatment)
        If $$$ISERR(tSC) {
            Do ..AddValidationError("Treatment", "Contraindication detected")
            Quit
        }
        
        // Check for patient allergies
        Set tSC = ..CheckAllergies(pTreatment)
        If $$$ISERR(tSC) {
            Do ..AddValidationError("Treatment", "Allergy conflict detected")
            Quit
        }
        
        // Check dosage safety for patient weight
        If $ISOBJECT(..Patient) && (..Patient.WeightKg > 0) {
            // Example: max 50mg/kg for demonstration
            Set tMaxDosePerKg = 50
            If 'pTreatment.IsSafeForWeight(..Patient.WeightKg, tMaxDosePerKg) {
                Do ..AddValidationError("Treatment", "Dosage exceeds safe limits for patient weight")
                Set tSC = $$$ERROR($$$GeneralError, "Unsafe dosage")
                Quit
            }
        }
        
        // All checks passed - activate and add treatment
        Set tSC = pTreatment.Start()
        If $$$ISERR(tSC) Quit
        
        Set tCount = $GET(..Treatments)
        Set tCount = tCount + 1
        Set ..Treatments = tCount
        Set ..Treatments(tCount) = pTreatment
        
        // Raise domain event
        Set tEventData = {"recordId": (..Identity), "medication": (pTreatment.MedicationName)}
        Do ..RaiseDomainEvent("TreatmentAdded", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check for drug interactions
/// @param pTreatment Treatment to check
Method CheckDrugInteractions(pTreatment As Patterns.Examples.Clinical.Treatment) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$ISOBJECT(..Patient) Quit
        
        // Check if medication is in patient's active medications (potential duplicate)
        Set tMedCount = $GET(..Patient.ActiveMedications)
        For tIndex = 1:1:tMedCount {
            Set tMedication = $GET(..Patient.ActiveMedications(tIndex, "medication"))
            If (tMedication = pTreatment.MedicationName) {
                Set tSC = $$$ERROR($$$GeneralError, "Duplicate medication: " _ tMedication)
                Quit
            }
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check for contraindications based on diagnoses
/// @param pTreatment Treatment to check
Method CheckContraindications(pTreatment As Patterns.Examples.Clinical.Treatment) As %Status
{
    Set tSC = $$$OK
    Try {
        Set tDiagCount = $GET(..Diagnoses)
        For tIndex = 1:1:tDiagCount {
            Set tDiagnosis = ..Diagnoses(tIndex)
            If $ISOBJECT(tDiagnosis) {
                If tDiagnosis.IsContraindicated(pTreatment.MedicationName) {
                    Set tSC = $$$ERROR($$$GeneralError, "Treatment contraindicated for diagnosis: " _ tDiagnosis.DiagnosisCode)
                    Quit
                }
            }
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check for patient allergies
/// @param pTreatment Treatment to check
Method CheckAllergies(pTreatment As Patterns.Examples.Clinical.Treatment) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$ISOBJECT(..Patient) Quit
        
        // Check if patient is allergic to the medication
        If ..Patient.HasAllergy(pTreatment.MedicationName) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient allergic to: " _ pTreatment.MedicationName)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get active diagnoses
/// @return Dynamic array of active diagnoses
Method GetActiveDiagnoses() As %DynamicArray
{
    Set tResult = []
    Set tCount = $GET(..Diagnoses)
    For tIndex = 1:1:tCount {
        Set tDiagnosis = ..Diagnoses(tIndex)
        If $ISOBJECT(tDiagnosis) && (tDiagnosis.Status = "Active") {
            Set tDiagInfo = {"code": (tDiagnosis.DiagnosisCode), "description": (tDiagnosis.Description), "severity": (tDiagnosis.Severity)}
            Do tResult.%Push(tDiagInfo)
        }
    }
    Quit tResult
}

/// Get active treatments
/// @return Dynamic array of active treatments
Method GetActiveTreatments() As %DynamicArray
{
    Set tResult = []
    Set tCount = $GET(..Treatments)
    For tIndex = 1:1:tCount {
        Set tTreatment = ..Treatments(tIndex)
        If $ISOBJECT(tTreatment) && (tTreatment.Status = "Active") {
            Set tTreatInfo = {"medication": (tTreatment.MedicationName), "dosage": (tTreatment.DosageAmount), "unit": (tTreatment.DosageUnit), "frequency": (tTreatment.Frequency)}
            Do tResult.%Push(tTreatInfo)
        }
    }
    Quit tResult
}

/// Discharge patient
/// @param pDischargeNotes Discharge notes
Method DischargePatient(pDischargeNotes As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..RecordStatus = "Discharged"
        Set ..DischargeDate = +$HOROLOG
        
        // Raise domain event
        Set tEventData = {"recordId": (..Identity), "dischargeDate": (..DischargeDate)}
        Do ..RaiseDomainEvent("PatientDischarged", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
