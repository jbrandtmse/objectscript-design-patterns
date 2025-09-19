/// Gang of Four Decorator Pattern - Basic Patient Record Implementation
/// 
/// <p>Intent:
/// Provides the base implementation of a patient record that can be
/// enhanced with various features through decorators.</p>
/// 
/// <p>Motivation:
/// This class represents the core patient record functionality without
/// any additional features. It stores basic patient data and provides
/// fundamental operations that decorators can enhance.</p>
/// 
/// <p>Structure:
/// Implements the PatientRecordComponent interface, providing the base
/// behavior that decorators will extend with additional capabilities.</p>
/// 
/// <p>Participants:
/// - Stores patient demographic and clinical data
/// - Implements basic data retrieval and storage
/// - Provides base security and compliance levels
/// - Acts as the foundation for decorator enhancements</p>
/// 
/// @since 1.0.0
/// @see Patterns.Examples.PatientRecordComponent
/// @see Patterns.Examples.EncryptionDecorator
Class Patterns.Examples.BasicPatientRecord Extends Patterns.Examples.PatientRecordComponent
{

/// Patient ID (MRN - Medical Record Number)
Property PatientID As %String;

/// Patient name
Property PatientName As %String;

/// Date of birth
Property DateOfBirth As %Date;

/// Patient demographics data
Property Demographics As %String;

/// Patient vital signs data
Property Vitals As %String;

/// Laboratory results data
Property Labs As %String;

/// Medications data
Property Medications As %String;

/// Allergies data
Property Allergies As %String;

/// Record creation timestamp
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG, 3)} ];

/// Last modified timestamp
Property ModifiedAt As %TimeStamp;

/// Base computational cost
Property BaseCost As %Numeric [ InitialExpression = 10 ];

/// Constructor to initialize the patient record
/// 
/// @param pPatientID Patient's medical record number
/// @param pPatientName Patient's full name
/// @param pDOB Patient's date of birth
/// @return %Status indicating success or failure
Method %OnNew(pPatientID As %String = "", pPatientName As %String = "", pDOB As %Date = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pPatientID = "" {
            // Generate a random patient ID if not provided
            Set ..PatientID = "MRN-" _ $RANDOM(999999)
        } Else {
            Set ..PatientID = pPatientID
        }
        
        If pPatientName '= "" {
            Set ..PatientName = pPatientName
        } Else {
            Set ..PatientName = "John Doe"
        }
        
        If pDOB '= "" {
            Set ..DateOfBirth = pDOB
        } Else {
            // Default to a date 30 years ago
            Set ..DateOfBirth = $HOROLOG - (365 * 30)
        }
        
        // Initialize with sample data
        Set ..Demographics = "Gender: Unknown | Address: Not Specified | Phone: Not Specified"
        Set ..Vitals = "BP: 120/80 | HR: 72 | Temp: 98.6F | RR: 16"
        Set ..Labs = "CBC: Normal | Glucose: 95 mg/dL | Creatinine: 1.0 mg/dL"
        Set ..Medications = "None documented"
        Set ..Allergies = "NKDA (No Known Drug Allergies)"
        
        Set ..CreatedAt = $ZDATETIME($HOROLOG, 3)
        Set ..ModifiedAt = ..CreatedAt
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get patient data from the record
/// 
/// @param pDataType Type of data to retrieve (Demographics, Vitals, Labs, etc.)
/// @return Patient data as a string
Method GetData(pDataType As %String = "All") As %String
{
    Set tResult = ""
    
    // Select data based on type
    If pDataType = "All" {
        Set tResult = "=== Patient Record ===" _ $CHAR(13,10)
        Set tResult = tResult _ "ID: " _ ..PatientID _ $CHAR(13,10)
        Set tResult = tResult _ "Name: " _ ..PatientName _ $CHAR(13,10)
        Set tResult = tResult _ "DOB: " _ $ZDATE(..DateOfBirth, 3) _ $CHAR(13,10)
        Set tResult = tResult _ "Demographics: " _ ..Demographics _ $CHAR(13,10)
        Set tResult = tResult _ "Vitals: " _ ..Vitals _ $CHAR(13,10)
        Set tResult = tResult _ "Labs: " _ ..Labs _ $CHAR(13,10)
        Set tResult = tResult _ "Medications: " _ ..Medications _ $CHAR(13,10)
        Set tResult = tResult _ "Allergies: " _ ..Allergies
    } ElseIf pDataType = "Demographics" {
        Set tResult = "Patient: " _ ..PatientName _ " (" _ ..PatientID _ ") | " _ ..Demographics
    } ElseIf pDataType = "Vitals" {
        Set tResult = ..Vitals
    } ElseIf pDataType = "Labs" {
        Set tResult = ..Labs
    } ElseIf pDataType = "Medications" {
        Set tResult = ..Medications
    } ElseIf pDataType = "Allergies" {
        Set tResult = ..Allergies
    } Else {
        Set tResult = "Unknown data type: " _ pDataType
    }
    
    Quit tResult
}

/// Save patient data to the record
/// 
/// @param pData Data to save
/// @param pDataType Type of data being saved
/// @return %Status indicating success or failure
Method SaveData(pData As %String, pDataType As %String = "General") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate data is not empty
        If pData = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot save empty data")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Save based on data type
        If pDataType = "Demographics" {
            Set ..Demographics = pData
        } ElseIf pDataType = "Vitals" {
            Set ..Vitals = pData
        } ElseIf pDataType = "Labs" {
            Set ..Labs = pData
        } ElseIf pDataType = "Medications" {
            Set ..Medications = pData
        } ElseIf pDataType = "Allergies" {
            Set ..Allergies = pData
        } ElseIf pDataType = "General" {
            // For general data, append to demographics
            Set ..Demographics = ..Demographics _ " | " _ pData
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "Unknown data type: " _ pDataType)
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Update modification timestamp
        Set ..ModifiedAt = $ZDATETIME($HOROLOG, 3)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get record description
/// 
/// @return Description string
Method GetDescription() As %String
{
    Set tDescription = "BasicPatientRecord"
    
    If ..PatientID '= "" {
        Set tDescription = tDescription _ "[" _ ..PatientID _ "]"
    }
    
    Quit tDescription
}

/// Get the cost/overhead of this record configuration
/// 
/// @return Numeric cost value
Method GetCost() As %Numeric
{
    Quit ..BaseCost
}

/// Check if the record is HIPAA compliant
/// 
/// <p>Basic records have minimal HIPAA compliance.</p>
/// 
/// @return %Boolean indicating compliance
Method IsHIPAACompliant() As %Boolean
{
    // Basic record without encryption is not fully compliant
    Quit 0
}

/// Get security level
/// 
/// @return Security level
Method GetSecurityLevel() As %String
{
    Quit "Basic"
}

/// Check if critical values are present
/// 
/// <p>Checks for critical lab values or vital signs.</p>
/// 
/// @param pThresholds Optional custom thresholds
/// @return %Boolean indicating presence of critical values
Method HasCriticalValues(pThresholds As %String = "") As %Boolean
{
    Set tHasCritical = 0
    
    // Simple check for critical values in vitals
    If ..Vitals [ "BP: 180" || (..Vitals [ "BP: 90") {
        Set tHasCritical = 1
    }
    
    // Check for critical glucose levels
    If ..Labs [ "Glucose: 40" || (..Labs [ "Glucose: 400") {
        Set tHasCritical = 1
    }
    
    Quit tHasCritical
}

/// Get audit trail
/// 
/// @param pStartDate Optional start date for audit entries
/// @param pEndDate Optional end date for audit entries
/// @return Audit trail as a string
Method GetAuditTrail(pStartDate As %Date = "", pEndDate As %Date = "") As %String
{
    Set tAudit = "=== Audit Trail ===" _ $CHAR(13,10)
    Set tAudit = tAudit _ "Record Created: " _ ..CreatedAt _ $CHAR(13,10)
    Set tAudit = tAudit _ "Last Modified: " _ ..ModifiedAt _ $CHAR(13,10)
    Set tAudit = tAudit _ "Note: Basic records have limited audit capabilities"
    
    Quit tAudit
}

/// Display detailed record information
Method Display()
{
    Write "=== Basic Patient Record ===", !
    Write "Patient ID: ", ..PatientID, !
    Write "Patient Name: ", ..PatientName, !
    Write "Date of Birth: ", $ZDATE(..DateOfBirth, 3), !
    Write "Description: ", ..GetDescription(), !
    Write "Security Level: ", ..GetSecurityLevel(), !
    Write "HIPAA Compliant: ", $SELECT(..IsHIPAACompliant():"Yes", 1:"No"), !
    Write "Has Critical Values: ", $SELECT(..HasCriticalValues():"Yes", 1:"No"), !
    Write "Cost: ", ..GetCost(), !
    Write "Created: ", ..CreatedAt, !
    Write "Modified: ", ..ModifiedAt, !
    Write "===========================", !
}

/// Create a sample record with test data
/// 
/// @return Instance of BasicPatientRecord with sample data
ClassMethod CreateSampleRecord() As Patterns.Examples.BasicPatientRecord
{
    Set tRecord = ..%New("MRN-123456", "Jane Smith", $HOROLOG - (365 * 45))
    
    // Set sample critical values for testing
    Set tRecord.Vitals = "BP: 185/95 | HR: 110 | Temp: 101.5F | RR: 24"
    Set tRecord.Labs = "CBC: Abnormal | Glucose: 425 mg/dL | Creatinine: 2.5 mg/dL"
    Set tRecord.Medications = "Metformin 1000mg BID | Lisinopril 10mg QD"
    Set tRecord.Allergies = "Penicillin (rash) | Sulfa (anaphylaxis)"
    
    Quit tRecord
}

}
