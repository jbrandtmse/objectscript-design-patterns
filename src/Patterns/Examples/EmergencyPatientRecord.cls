/// Emergency patient record template for urgent care situations.
/// <p>Provides specialized configuration for emergency admissions
/// with critical tests and immediate intervention protocols.</p>
Class Patterns.Examples.EmergencyPatientRecord Extends Patterns.Examples.PatientRecordTemplate
{

/// Triage category (Red, Yellow, Green)
Property TriageCategory As %String;

/// Time of arrival
Property ArrivalTime As %TimeStamp;

/// Chief complaint
Property ChiefComplaint As %String;

/// Vital signs at admission
Property VitalSigns As %String;

/// Emergency contact information
Property EmergencyContact As %String;

/// Constructor - initialize emergency patient defaults
Method %OnNew(initvalue As %String = "") As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Set emergency defaults
    Set ..TemplateName = "Emergency Patient Record"
    Set ..AdmissionType = "Emergency"
    Set ..PriorityLevel = 1
    Set ..Department = "Emergency Department"
    Set ..TriageCategory = "Yellow"
    Set ..ArrivalTime = $ZDATETIME($HOROLOG, 3)
    
    // Add emergency required tests
    Do ..AddRequiredTest("STAT Complete Blood Count")
    Do ..AddRequiredTest("STAT Comprehensive Metabolic Panel")
    Do ..AddRequiredTest("Cardiac Enzymes")
    Do ..AddRequiredTest("ECG")
    Do ..AddRequiredTest("Chest X-Ray")
    Do ..AddRequiredTest("CT Scan if indicated")
    
    // Add emergency medications
    Do ..AddDefaultMedication("IV Access Protocol")
    Do ..AddDefaultMedication("Oxygen Therapy")
    Do ..AddDefaultMedication("Pain Management - Acute")
    Do ..AddDefaultMedication("Antiemetic if needed")
    
    Quit $$$OK
}

/// Clone method override for emergency patient
Method Clone() As Patterns.GoF.Creational.Prototype
{
    Set clone = ##super()
    // Ensure emergency patient specific properties are handled
    If $IsObject(clone) {
        Set clone.TriageCategory = ..TriageCategory
        Set clone.ArrivalTime = ..ArrivalTime
        Set clone.ChiefComplaint = ..ChiefComplaint
        Set clone.VitalSigns = ..VitalSigns
        Set clone.EmergencyContact = ..EmergencyContact
    }
    Quit clone
}

/// Create a customized instance for a specific emergency patient
Method CustomizeForEmergency(pPatientID As %String, pTriageCategory As %String, pChiefComplaint As %String) As Patterns.Examples.EmergencyPatientRecord
{
    Set newRecord = ..Clone()
    Set newRecord.PatientID = pPatientID
    Set newRecord.TriageCategory = pTriageCategory
    Set newRecord.ChiefComplaint = pChiefComplaint
    Set newRecord.ArrivalTime = $ZDATETIME($HOROLOG, 3)
    
    // Adjust priority based on triage category
    If pTriageCategory = "Red" {
        Set newRecord.PriorityLevel = 1
    } ElseIf pTriageCategory = "Yellow" {
        Set newRecord.PriorityLevel = 2
    } Else {
        Set newRecord.PriorityLevel = 3
    }
    
    Quit newRecord
}

/// Set vital signs for the patient
Method SetVitalSigns(pBP As %String, pPulse As %Integer, pTemp As %Decimal, pRespRate As %Integer)
{
    Set ..VitalSigns = "BP: "_pBP_", Pulse: "_pPulse_", Temp: "_pTemp_"°F, Resp: "_pRespRate
}

}
