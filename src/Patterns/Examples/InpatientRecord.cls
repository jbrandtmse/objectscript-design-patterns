/// Inpatient Record - Concrete implementation for admitted patients
/// <p>This class represents a patient record for patients who are admitted
/// to the hospital for extended care.</p>
Class Patterns.Examples.InpatientRecord Extends Patterns.Examples.PatientRecord
{

/// Room number assigned to the patient
Property RoomNumber As %String;

/// Bed number within the room
Property BedNumber As %String;

/// Admission diagnosis
Property AdmissionDiagnosis As %String;

/// Expected length of stay in days
Property ExpectedLengthOfStay As %Integer;

/// Insurance authorization code
Property AuthorizationCode As %String;

/// Initialize the inpatient record
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Set record type
        Set ..RecordType = "Inpatient"
        Set ..Priority = "High"
        Set ..Department = "Inpatient Services"
        
        // Initialize parent
        Set tSC = ..Initialize()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process the inpatient record
/// <returns>Result string describing the processing performed</returns>
Method ProcessRecord() As %String
{
    Set result = "Processing Inpatient Record for " _ ..PatientName
    Set result = result _ " in Room " _ ..RoomNumber _ ", Bed " _ ..BedNumber
    Set result = result _ ". Admission diagnosis: " _ ..AdmissionDiagnosis
    Set result = result _ ". Expected stay: " _ ..ExpectedLengthOfStay _ " days"
    
    // Perform inpatient-specific processing
    Set result = result _ ". [INPATIENT ADMISSION PROCESSED]"
    
    Quit result
}

/// Validate the inpatient record
/// <returns>%Status indicating validation result</returns>
Method ValidateRecord() As %Status
{
    Set tSC = $$$OK
    
    // Validate required fields
    If ..PatientMRN = "" {
        Quit $$$ERROR($$$GeneralError, "Patient MRN is required")
    }
    
    If ..RoomNumber = "" {
        Quit $$$ERROR($$$GeneralError, "Room number is required for inpatient")
    }
    
    If ..AdmissionDiagnosis = "" {
        Quit $$$ERROR($$$GeneralError, "Admission diagnosis is required")
    }
    
    If ..AuthorizationCode = "" {
        Quit $$$ERROR($$$GeneralError, "Insurance authorization required for admission")
    }
    
    Quit tSC
}

/// Calculate billing code for inpatient services
/// <returns>Billing code string</returns>
Method CalculateBillingCode() As %String
{
    Set billingCode = "IP-"  // Inpatient prefix
    
    // Add room type code
    If $Extract(..RoomNumber, 1, 1) = "I" {
        Set billingCode = billingCode _ "ICU-"  // ICU room
    } ElseIf $Extract(..RoomNumber, 1, 1) = "P" {
        Set billingCode = billingCode _ "PVT-"  // Private room
    } Else {
        Set billingCode = billingCode _ "STD-"  // Standard room
    }
    
    // Add length of stay category
    If ..ExpectedLengthOfStay > 7 {
        Set billingCode = billingCode _ "EXTENDED"
    } ElseIf ..ExpectedLengthOfStay > 3 {
        Set billingCode = billingCode _ "STANDARD"
    } Else {
        Set billingCode = billingCode _ "SHORT"
    }
    
    Quit billingCode
}

/// Assign room and bed to the patient
/// <param name="pRoomNumber">Room number to assign</param>
/// <param name="pBedNumber">Bed number to assign</param>
/// <returns>%Status indicating success</returns>
Method AssignRoom(pRoomNumber As %String, pBedNumber As %String) As %Status
{
    Set tSC = $$$OK
    
    If pRoomNumber = "" {
        Quit $$$ERROR($$$GeneralError, "Room number cannot be empty")
    }
    
    Set ..RoomNumber = pRoomNumber
    Set ..BedNumber = pBedNumber
    
    Do ##class(%SYS.System).WriteToConsoleLog(
        "Patient " _ ..PatientName _ " assigned to Room " _ pRoomNumber _ ", Bed " _ pBedNumber)
    
    Quit tSC
}

}
