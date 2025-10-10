/// Clinical Encounter Domain Object
/// 
/// Pure domain class with NO database dependencies
/// Represents a clinical patient encounter with business logic only
/// 
/// This class demonstrates the Data Mapper pattern's complete separation
/// of domain logic from persistence concerns.
/// 
/// @see Patterns.Examples.Clinical.ClinicalEncounterMapper
/// @since 1.0.0
Class Patterns.Examples.Clinical.ClinicalEncounter Extends %RegisteredObject
{

/// Unique identifier for the encounter
/// Set by mapper after database insert
Property EncounterId As %String;

/// Patient Medical Record Number
Property PatientMRN As %String;

/// Provider name responsible for encounter
Property ProviderName As %String;

/// Date and time of the encounter
Property EncounterDate As %TimeStamp;

/// Type of encounter (e.g., "Emergency", "Outpatient", "Inpatient")
Property EncounterType As %String;

/// Chief complaint reported by patient
Property ChiefComplaint As %String;

/// Diagnosis determined during encounter
Property Diagnosis As %String;

/// Treatment plan for the patient
Property TreatmentPlan As %String;

/// Validate encounter data meets business rules
/// 
/// @return %Status indicating if encounter is valid
Method ValidateEncounter() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate required fields
        If (..PatientMRN = "") {
            Set tSC = $$$ERROR($$$GeneralError, "PatientMRN is required")
            Quit
        }
        
        If (..ProviderName = "") {
            Set tSC = $$$ERROR($$$GeneralError, "ProviderName is required")
            Quit
        }
        
        If (..EncounterDate = "") {
            Set tSC = $$$ERROR($$$GeneralError, "EncounterDate is required")
            Quit
        }
        
        If (..EncounterType = "") {
            Set tSC = $$$ERROR($$$GeneralError, "EncounterType is required")
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Calculate billing code based on encounter type and diagnosis
/// 
/// @return %String billing code
Method CalculateBillingCode() As %String
{
    Set tBillingCode = ""
    
    // Business logic for billing code calculation
    If (..EncounterType = "Emergency") {
        Set tBillingCode = "EM-99285"
    } ElseIf (..EncounterType = "Outpatient") {
        Set tBillingCode = "OP-99214"
    } ElseIf (..EncounterType = "Inpatient") {
        Set tBillingCode = "IP-99223"
    } Else {
        Set tBillingCode = "UNKNOWN"
    }
    
    Quit tBillingCode
}

/// Check if encounter requires follow-up based on diagnosis
/// 
/// @return %Boolean true if follow-up needed
Method RequiresFollowUp() As %Boolean
{
    Set tRequiresFollowUp = 0
    
    // Business logic for follow-up determination
    If (..Diagnosis [ "chronic") || (..Diagnosis [ "ongoing") {
        Set tRequiresFollowUp = 1
    }
    
    If (..TreatmentPlan [ "follow-up") || (..TreatmentPlan [ "return") {
        Set tRequiresFollowUp = 1
    }
    
    Quit tRequiresFollowUp
}

/// Get encounter summary for reporting
/// 
/// @return %String formatted summary
Method GetSummary() As %String
{
    Set tSummary = ""
    
    Set tSummary = tSummary _ "Encounter ID: " _ ..EncounterId _ $Char(13,10)
    Set tSummary = tSummary _ "Patient MRN: " _ ..PatientMRN _ $Char(13,10)
    Set tSummary = tSummary _ "Provider: " _ ..ProviderName _ $Char(13,10)
    Set tSummary = tSummary _ "Date: " _ ..EncounterDate _ $Char(13,10)
    Set tSummary = tSummary _ "Type: " _ ..EncounterType _ $Char(13,10)
    Set tSummary = tSummary _ "Chief Complaint: " _ ..ChiefComplaint _ $Char(13,10)
    Set tSummary = tSummary _ "Diagnosis: " _ ..Diagnosis _ $Char(13,10)
    Set tSummary = tSummary _ "Treatment Plan: " _ ..TreatmentPlan
    
    Quit tSummary
}

}
