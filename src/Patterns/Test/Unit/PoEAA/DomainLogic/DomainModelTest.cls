/// Unit Tests for Domain Model Pattern
/// 
/// Tests the Domain Model pattern implementation including:
/// - Domain object creation and initialization
/// - Business rule validation and enforcement
/// - Object relationship management
/// - Domain event handling
/// - Healthcare clinical domain model scenarios
Class Patterns.Test.Unit.PoEAA.DomainLogic.DomainModelTest Extends %UnitTest.TestCase
{

/// Test domain model object creation
Method TestDomainObjectCreation() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Do $$$AssertTrue($ISOBJECT(tPatient), "Patient object created")
        Do $$$AssertTrue(tPatient.Identity '= "", "Patient has identity")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test patient validation rules
Method TestPatientValidation() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create valid patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tPatient.WeightKg = 75
        Set tPatient.HeightCm = 175
        
        // Validate
        Set tSC = tPatient.ValidateRules()
        Do $$$AssertStatusOK(tSC, "Valid patient passes validation")
        Do $$$AssertTrue(tPatient.IsValid, "Patient marked as valid")
        
        // Test invalid medical record number
        Set tPatient2 = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient2.MedicalRecordNumber = "123"
        Set tPatient2.FullName = "Jane Doe"
        Set tPatient2.DateOfBirth = +$HOROLOG - 10000
        
        Set tSC = tPatient2.ValidateRules()
        Do $$$AssertStatusNotOK(tSC, "Invalid MRN fails validation")
        Do $$$AssertTrue(tPatient2.HasValidationErrors(), "Validation errors recorded")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test patient business logic
Method TestPatientBusinessLogic() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10950  // ~30 years ago
        Set tPatient.WeightKg = 75
        Set tPatient.HeightCm = 175
        
        // Test age calculation
        Set tAge = tPatient.CalculateAge()
        Do $$$AssertTrue(tAge >= 29, "Age calculated correctly")
        
        // Test BMI calculation
        Set tBMI = tPatient.CalculateBMI()
        Do $$$AssertTrue(tBMI > 0, "BMI calculated")
        Do $$$AssertTrue((tBMI > 24) && (tBMI < 25), "BMI is approximately 24.5")
        
        // Test allergy management
        Set tSC = tPatient.AddAllergy("Penicillin", "Severe")
        Do $$$AssertStatusOK(tSC, "Allergy added")
        Do $$$AssertTrue(tPatient.HasAllergy("Penicillin"), "Allergy recorded")
        Do $$$AssertTrue('tPatient.HasAllergy("Aspirin"), "Non-existent allergy returns false")
        
        // Test medication management
        Set tSC = tPatient.AddMedication("Lisinopril", "10mg daily")
        Do $$$AssertStatusOK(tSC, "Medication added")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test diagnosis validation and business rules
Method TestDiagnosisValidation() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create valid diagnosis
        Set tDiagnosis = ##class(Patterns.Examples.Clinical.Diagnosis).%New()
        Set tDiagnosis.DiagnosisCode = "I10"
        Set tDiagnosis.Description = "Essential hypertension"
        Set tDiagnosis.DiagnosisDate = +$HOROLOG
        Set tDiagnosis.Severity = "Moderate"
        
        Set tSC = tDiagnosis.ValidateRules()
        Do $$$AssertStatusOK(tSC, "Valid diagnosis passes validation")
        
        // Test contraindication management
        Set tSC = tDiagnosis.AddContraindication("NSAIDs", "May worsen hypertension")
        Do $$$AssertStatusOK(tSC, "Contraindication added")
        Do $$$AssertTrue(tDiagnosis.IsContraindicated("NSAIDs"), "Contraindication recorded")
        
        // Test status changes
        Set tSC = tDiagnosis.Resolve()
        Do $$$AssertStatusOK(tSC, "Diagnosis resolved")
        Do $$$AssertEquals(tDiagnosis.Status, "Resolved", "Status updated to Resolved")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test treatment validation and dosage calculations
Method TestTreatmentValidation() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create valid treatment
        Set tTreatment = ##class(Patterns.Examples.Clinical.Treatment).%New()
        Set tTreatment.ProtocolName = "Hypertension Management"
        Set tTreatment.MedicationName = "Lisinopril"
        Set tTreatment.DosageAmount = 10
        Set tTreatment.DosageUnit = "mg"
        Set tTreatment.Frequency = "Once daily"
        
        Set tSC = tTreatment.ValidateRules()
        Do $$$AssertStatusOK(tSC, "Valid treatment passes validation")
        
        // Test daily dosage calculation
        Set tDailyDosage = tTreatment.CalculateDailyDosage()
        Do $$$AssertEquals(tDailyDosage, 10, "Daily dosage calculated for once daily")
        
        // Test twice daily dosage
        Set tTreatment2 = ##class(Patterns.Examples.Clinical.Treatment).%New()
        Set tTreatment2.ProtocolName = "Protocol"
        Set tTreatment2.MedicationName = "Aspirin"
        Set tTreatment2.DosageAmount = 325
        Set tTreatment2.DosageUnit = "mg"
        Set tTreatment2.Frequency = "Twice daily"
        
        Set tDailyDosage2 = tTreatment2.CalculateDailyDosage()
        Do $$$AssertEquals(tDailyDosage2, 650, "Daily dosage calculated for twice daily")
        
        // Test weight-based safety
        Set tIsSafe = tTreatment2.IsSafeForWeight(70, 10)
        Do $$$AssertTrue(tIsSafe, "Dosage safe for patient weight")
        
        Set tIsSafe2 = tTreatment2.IsSafeForWeight(70, 5)
        Do $$$AssertTrue('tIsSafe2, "Excessive dosage detected")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test medical record aggregate root
Method TestMedicalRecordAggregateRoot() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create medical record
        Set tRecord = ##class(Patterns.Examples.Clinical.MedicalRecord).%New()
        Do $$$AssertTrue($ISOBJECT(tRecord), "Medical record created")
        
        // Create and admit patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tPatient.WeightKg = 75
        Set tPatient.HeightCm = 175
        
        Set tSC = tRecord.AdmitPatient(tPatient)
        Do $$$AssertStatusOK(tSC, "Patient admitted")
        Do $$$AssertTrue($ISOBJECT(tRecord.Patient), "Patient assigned to record")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test adding diagnosis to medical record
Method TestMedicalRecordDiagnosis() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create medical record with patient
        Set tRecord = ##class(Patterns.Examples.Clinical.MedicalRecord).%New()
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tSC = tRecord.AdmitPatient(tPatient)
        
        // Add diagnosis
        Set tDiagnosis = ##class(Patterns.Examples.Clinical.Diagnosis).%New()
        Set tDiagnosis.DiagnosisCode = "I10"
        Set tDiagnosis.Description = "Essential hypertension"
        
        Set tSC = tRecord.AddDiagnosis(tDiagnosis)
        Do $$$AssertStatusOK(tSC, "Diagnosis added to record")
        
        // Verify diagnosis in collection
        Set tDiagCount = $GET(tRecord.Diagnoses)
        Do $$$AssertEquals(tDiagCount, 1, "One diagnosis in collection")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test adding treatment with safety checks
Method TestMedicalRecordTreatmentSafety() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create medical record with patient
        Set tRecord = ##class(Patterns.Examples.Clinical.MedicalRecord).%New()
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tPatient.WeightKg = 75
        Set tPatient.HeightCm = 175
        
        Set tSC = tRecord.AdmitPatient(tPatient)
        
        // Add allergy to patient
        Set tSC = tPatient.AddAllergy("Penicillin", "Severe")
        
        // Try to add treatment with allergic medication
        Set tTreatment = ##class(Patterns.Examples.Clinical.Treatment).%New()
        Set tTreatment.ProtocolName = "Antibiotic Protocol"
        Set tTreatment.MedicationName = "Penicillin"
        Set tTreatment.DosageAmount = 500
        Set tTreatment.DosageUnit = "mg"
        Set tTreatment.Frequency = "Twice daily"
        
        Set tSC = tRecord.AddTreatment(tTreatment)
        Do $$$AssertStatusNotOK(tSC, "Treatment with allergy rejected")
        Do $$$AssertTrue(tRecord.HasValidationErrors(), "Allergy conflict recorded")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test drug interaction checking
Method TestDrugInteractionChecking() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create medical record with patient
        Set tRecord = ##class(Patterns.Examples.Clinical.MedicalRecord).%New()
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tPatient.WeightKg = 75
        
        Set tSC = tRecord.AdmitPatient(tPatient)
        
        // Add medication to patient
        Set tSC = tPatient.AddMedication("Lisinopril", "10mg daily")
        
        // Try to add duplicate medication
        Set tTreatment = ##class(Patterns.Examples.Clinical.Treatment).%New()
        Set tTreatment.ProtocolName = "Hypertension Protocol"
        Set tTreatment.MedicationName = "Lisinopril"
        Set tTreatment.DosageAmount = 10
        Set tTreatment.DosageUnit = "mg"
        Set tTreatment.Frequency = "Once daily"
        
        Set tSC = tRecord.AddTreatment(tTreatment)
        Do $$$AssertStatusNotOK(tSC, "Duplicate medication rejected")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test contraindication checking
Method TestContraindicationChecking() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create medical record with patient
        Set tRecord = ##class(Patterns.Examples.Clinical.MedicalRecord).%New()
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tPatient.WeightKg = 75
        
        Set tSC = tRecord.AdmitPatient(tPatient)
        
        // Add diagnosis with contraindication
        Set tDiagnosis = ##class(Patterns.Examples.Clinical.Diagnosis).%New()
        Set tDiagnosis.DiagnosisCode = "I10"
        Set tDiagnosis.Description = "Essential hypertension"
        Set tSC = tDiagnosis.AddContraindication("NSAIDs", "May worsen condition")
        Set tSC = tRecord.AddDiagnosis(tDiagnosis)
        
        // Try to add contraindicated treatment
        Set tTreatment = ##class(Patterns.Examples.Clinical.Treatment).%New()
        Set tTreatment.ProtocolName = "Pain Management"
        Set tTreatment.MedicationName = "NSAIDs"
        Set tTreatment.DosageAmount = 400
        Set tTreatment.DosageUnit = "mg"
        Set tTreatment.Frequency = "Twice daily"
        
        Set tSC = tRecord.AddTreatment(tTreatment)
        Do $$$AssertStatusNotOK(tSC, "Contraindicated treatment rejected")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test domain event handling
Method TestDomainEventHandling() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        
        // Add allergy (raises domain event)
        Set tSC = tPatient.AddAllergy("Penicillin", "Severe")
        
        // Verify event was raised
        Set tEvents = tPatient.GetDomainEvents()
        Do $$$AssertTrue($ISOBJECT(tEvents), "Domain events retrieved")
        Do $$$AssertTrue(tEvents.%Size() > 0, "Events were raised")
        
        Set tFirstEvent = tEvents.%Get(0)
        Do $$$AssertEquals(tFirstEvent.type, "AllergyAdded", "Correct event type")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test complete clinical workflow
Method TestCompleteClinicWorkflow() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create medical record
        Set tRecord = ##class(Patterns.Examples.Clinical.MedicalRecord).%New()
        
        // Create and admit patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tPatient.WeightKg = 75
        Set tPatient.HeightCm = 175
        Set tSC = tRecord.AdmitPatient(tPatient)
        Do $$$AssertStatusOK(tSC, "Patient admitted")
        
        // Add diagnosis
        Set tDiagnosis = ##class(Patterns.Examples.Clinical.Diagnosis).%New()
        Set tDiagnosis.DiagnosisCode = "I10"
        Set tDiagnosis.Description = "Essential hypertension"
        Set tSC = tRecord.AddDiagnosis(tDiagnosis)
        Do $$$AssertStatusOK(tSC, "Diagnosis added")
        
        // Add safe treatment
        Set tTreatment = ##class(Patterns.Examples.Clinical.Treatment).%New()
        Set tTreatment.ProtocolName = "Hypertension Management"
        Set tTreatment.MedicationName = "Lisinopril"
        Set tTreatment.DosageAmount = 10
        Set tTreatment.DosageUnit = "mg"
        Set tTreatment.Frequency = "Once daily"
        Set tSC = tRecord.AddTreatment(tTreatment)
        Do $$$AssertStatusOK(tSC, "Treatment added")
        
        // Verify active diagnoses and treatments
        Set tActiveDiagnoses = tRecord.GetActiveDiagnoses()
        Do $$$AssertEquals(tActiveDiagnoses.%Size(), 1, "One active diagnosis")
        
        Set tActiveTreatments = tRecord.GetActiveTreatments()
        Do $$$AssertEquals(tActiveTreatments.%Size(), 1, "One active treatment")
        
        // Discharge patient
        Set tSC = tRecord.DischargePatient("Recovery complete")
        Do $$$AssertStatusOK(tSC, "Patient discharged")
        Do $$$AssertEquals(tRecord.RecordStatus, "Discharged", "Record status updated")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test validation error collection
Method TestValidationErrorCollection() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient with multiple validation errors
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.MedicalRecordNumber = "123"  // Too short
        Set tPatient.FullName = "J"  // Too short
        Set tPatient.DateOfBirth = +$HOROLOG + 100  // Future date
        
        Set tSC = tPatient.ValidateRules()
        Do $$$AssertStatusNotOK(tSC, "Invalid patient fails validation")
        Do $$$AssertTrue(tPatient.HasValidationErrors(), "Validation errors exist")
        
        Set tErrors = tPatient.GetValidationErrors()
        Do $$$AssertTrue($ISOBJECT(tErrors), "Validation errors retrieved")
        Do $$$AssertTrue(tErrors.%Size() > 0, "Multiple validation errors captured")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

}
