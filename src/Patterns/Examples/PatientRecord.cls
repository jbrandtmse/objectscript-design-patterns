/// Abstract Patient Record base class for Factory Method pattern example
/// <p>This abstract class defines the interface for different types of patient records
/// that can be created by the healthcare record factories.</p>
Class Patterns.Examples.PatientRecord Extends %RegisteredObject [ Abstract ]
{

/// Patient identifier (MRN - Medical Record Number)
Property PatientMRN As %String;

/// Patient name
Property PatientName As %String;

/// Record type identifier
Property RecordType As %String;

/// Unique record identifier
Property RecordID As %String;

/// Admission or visit date
Property AdmissionDate As %Date;

/// Department or service
Property Department As %String;

/// Provider name
Property AttendingProvider As %String;

/// Record creation timestamp
Property CreatedAt As %TimeStamp;

/// Priority level for record processing
Property Priority As %String;

/// Initialize the patient record
/// <p>Called after record creation to set up initial state</p>
/// <returns>%Status indicating initialization success</returns>
Method Initialize() As %Status
{
    Set tSC = $$$OK
    Try {
        // Set creation timestamp
        Set ..CreatedAt = $ZDateTime($Horolog, 3)
        
        // Generate MRN if not provided
        If ..PatientMRN = "" {
            Set ..PatientMRN = "MRN-" _ $Random(1000000)
        }
        
        // Set admission date to today if not provided
        If ..AdmissionDate = "" {
            Set ..AdmissionDate = +$Horolog
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Abstract method to process the patient record
/// <p>Each concrete record type must implement its own processing logic</p>
/// <returns>Result string describing the processing performed</returns>
Method ProcessRecord() As %String [ Abstract ]
{
}

/// Abstract method to validate the patient record
/// <p>Each record type has specific validation requirements</p>
/// <returns>%Status indicating validation result</returns>
Method ValidateRecord() As %Status [ Abstract ]
{
}

/// Abstract method to calculate billing code
/// <p>Different record types have different billing implications</p>
/// <returns>Billing code string</returns>
Method CalculateBillingCode() As %String [ Abstract ]
{
}

/// Get formatted record summary
/// <returns>Formatted string with record details</returns>
Method GetRecordSummary() As %String
{
    Set summary = "=== Patient Record Summary ===" _ $Char(13,10)
    Set summary = summary _ "MRN: " _ ..PatientMRN _ $Char(13,10)
    Set summary = summary _ "Patient: " _ ..PatientName _ $Char(13,10)
    Set summary = summary _ "Type: " _ ..RecordType _ $Char(13,10)
    Set summary = summary _ "Date: " _ $ZDate(..AdmissionDate, 3) _ $Char(13,10)
    Set summary = summary _ "Department: " _ ..Department _ $Char(13,10)
    Set summary = summary _ "Provider: " _ ..AttendingProvider _ $Char(13,10)
    Set summary = summary _ "Priority: " _ ..Priority _ $Char(13,10)
    Set summary = summary _ "Created: " _ ..CreatedAt _ $Char(13,10)
    Set summary = summary _ "================================"
    
    Quit summary
}

}
