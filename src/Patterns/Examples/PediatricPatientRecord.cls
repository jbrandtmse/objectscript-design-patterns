/// Pediatric patient record template for children and adolescents.
/// <p>Provides specialized configuration for pediatric admissions
/// with age-appropriate tests and medication dosing protocols.</p>
Class Patterns.Examples.PediatricPatientRecord Extends Patterns.Examples.PatientRecordTemplate
{

/// Patient age in years
Property AgeInYears As %Decimal;

/// Patient weight in kilograms
Property WeightKg As %Decimal;

/// Guardian/Parent name
Property GuardianName As %String;

/// Guardian contact information
Property GuardianContact As %String;

/// Immunization status
Property ImmunizationStatus As %String;

/// Growth percentile
Property GrowthPercentile As %Integer;

/// Pediatrician name
Property Pediatrician As %String;

/// Constructor - initialize pediatric patient defaults
Method %OnNew(initvalue As %String = "") As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Set pediatric defaults
    Set ..TemplateName = "Pediatric Patient Record"
    Set ..AdmissionType = "Pediatric"
    Set ..PriorityLevel = 2
    Set ..Department = "Pediatrics"
    Set ..ImmunizationStatus = "To be verified"
    
    // Add pediatric required tests
    Do ..AddRequiredTest("Pediatric Blood Panel")
    Do ..AddRequiredTest("Growth Assessment")
    Do ..AddRequiredTest("Developmental Screening")
    Do ..AddRequiredTest("Immunization Review")
    
    // Add pediatric medications (weight-based dosing)
    Do ..AddDefaultMedication("Acetaminophen (weight-based)")
    Do ..AddDefaultMedication("Ibuprofen (weight-based)")
    Do ..AddDefaultMedication("Pediatric IV Fluids")
    Do ..AddDefaultMedication("Age-appropriate vitamins")
    
    Quit $$$OK
}

/// Clone method override for pediatric patient
Method Clone() As Patterns.GoF.Creational.Prototype
{
    Set clone = ##super()
    // Ensure pediatric patient specific properties are handled
    If $IsObject(clone) {
        Set clone.AgeInYears = ..AgeInYears
        Set clone.WeightKg = ..WeightKg
        Set clone.GuardianName = ..GuardianName
        Set clone.GuardianContact = ..GuardianContact
        Set clone.ImmunizationStatus = ..ImmunizationStatus
        Set clone.GrowthPercentile = ..GrowthPercentile
        Set clone.Pediatrician = ..Pediatrician
    }
    Quit clone
}

/// Create a customized instance for a specific pediatric patient
Method CustomizeForChild(pPatientID As %String, pAge As %Decimal, pWeight As %Decimal, pGuardian As %String) As Patterns.Examples.PediatricPatientRecord
{
    Set newRecord = ..Clone()
    Set newRecord.PatientID = pPatientID
    Set newRecord.AgeInYears = pAge
    Set newRecord.WeightKg = pWeight
    Set newRecord.GuardianName = pGuardian
    
    // Adjust tests based on age
    If pAge < 2 {
        Do newRecord.AddRequiredTest("Infant Development Assessment")
        Do newRecord.AddDefaultMedication("Infant formula if needed")
    } ElseIf pAge < 5 {
        Do newRecord.AddRequiredTest("Toddler Behavioral Screening")
    } ElseIf pAge < 13 {
        Do newRecord.AddRequiredTest("School-age Assessment")
    } Else {
        Do newRecord.AddRequiredTest("Adolescent Risk Assessment")
    }
    
    // Calculate medication doses based on weight
    Do newRecord.CalculateDosages()
    
    Quit newRecord
}

/// Calculate medication dosages based on patient weight
Method CalculateDosages() [ Private ]
{
    // Clear current medications
    Do ..DefaultMedications.Clear()
    
    // Add weight-based dosages
    Set acetDose = ..WeightKg * 15  // 15mg/kg
    Set ibuDose = ..WeightKg * 10   // 10mg/kg
    
    Do ..AddDefaultMedication("Acetaminophen "_acetDose_"mg Q6H PRN")
    Do ..AddDefaultMedication("Ibuprofen "_ibuDose_"mg Q8H PRN")
    
    // Fluid calculation
    Set fluidRate = 0
    If ..WeightKg <= 10 {
        Set fluidRate = ..WeightKg * 100
    } ElseIf ..WeightKg <= 20 {
        Set fluidRate = 1000 + ((..WeightKg - 10) * 50)
    } Else {
        Set fluidRate = 1500 + ((..WeightKg - 20) * 20)
    }
    Do ..AddDefaultMedication("Maintenance fluids at "_fluidRate_"ml/day")
}

/// Set guardian information
Method SetGuardianInfo(pName As %String, pContact As %String)
{
    Set ..GuardianName = pName
    Set ..GuardianContact = pContact
}

}
