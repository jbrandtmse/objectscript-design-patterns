/// Standard patient record template for regular admissions.
/// <p>Provides default configuration for standard patient admissions
/// with basic tests and medication protocols.</p>
Class Patterns.Examples.StandardPatientRecord Extends Patterns.Examples.PatientRecordTemplate
{

/// Insurance provider information
Property InsuranceProvider As %String;

/// Attending physician
Property AttendingPhysician As %String;

/// Expected length of stay in days
Property ExpectedLengthOfStay As %Integer;

/// Constructor - initialize standard patient defaults
Method %OnNew(initvalue As %String = "") As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Set standard defaults
    Set ..TemplateName = "Standard Patient Record"
    Set ..AdmissionType = "Scheduled"
    Set ..PriorityLevel = 3
    Set ..Department = "General Medicine"
    Set ..ExpectedLengthOfStay = 2
    
    // Add standard required tests
    Do ..AddRequiredTest("Complete Blood Count")
    Do ..AddRequiredTest("Basic Metabolic Panel")
    Do ..AddRequiredTest("Urinalysis")
    
    // Add standard medications
    Do ..AddDefaultMedication("IV Fluids")
    Do ..AddDefaultMedication("Pain Management Protocol")
    
    Quit $$$OK
}

/// Clone method override for standard patient
Method Clone() As Patterns.GoF.Creational.Prototype
{
    Set clone = ##super()
    // Ensure standard patient specific properties are handled
    If $IsObject(clone) {
        Set clone.InsuranceProvider = ..InsuranceProvider
        Set clone.AttendingPhysician = ..AttendingPhysician
        Set clone.ExpectedLengthOfStay = ..ExpectedLengthOfStay
    }
    Quit clone
}

/// Create a customized instance for a specific patient
Method CustomizeForPatient(pPatientID As %String, pPhysician As %String = "", pInsurance As %String = "") As Patterns.Examples.StandardPatientRecord
{
    Set newRecord = ..Clone()
    Set newRecord.PatientID = pPatientID
    If pPhysician '= "" {
        Set newRecord.AttendingPhysician = pPhysician
    }
    If pInsurance '= "" {
        Set newRecord.InsuranceProvider = pInsurance
    }
    Quit newRecord
}

}
