/// Concrete implementation of PatientRecord for emergency department visits
/// <p>Represents a patient record for emergency room visits and urgent care.</p>
Class Patterns.Examples.EmergencyRecord Extends Patterns.Examples.PatientRecord
{

/// Triage level (1-5, with 1 being most critical)
Property TriageLevel As %Integer;

/// Chief complaint
Property ChiefComplaint As %String;

/// Time of arrival
Property ArrivalTime As %TimeStamp;

/// Mode of arrival (e.g., "Ambulance", "Walk-in", "Private Vehicle")
Property ArrivalMode As %String;

/// Vital signs at triage
Property VitalSigns As %String;

/// Emergency severity index
Property SeverityIndex As %String;

/// Severity level (simplified name for SeverityIndex)
Property Severity As %String;

/// Disposition (e.g., "Admitted", "Discharged", "Transferred", "Left AMA")
Property Disposition As %String;

/// Trauma alert flag
Property TraumaAlert As %Boolean;

/// Wait time in minutes
Property WaitTimeMinutes As %Integer;

/// Initialize emergency record with default values
/// <returns>%Status indicating initialization success</returns>
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Set record type
        Set ..RecordType = "Emergency"
        
        // Set default priority to High for emergency
        Set ..Priority = "High"
        
        // Set default triage level
        Set ..TriageLevel = 3
        
        // Set arrival time to now
        Set ..ArrivalTime = $ZDateTime($Horolog, 3)
        
        // Set default trauma alert
        Set ..TraumaAlert = 0
        
        // Set default wait time
        Set ..WaitTimeMinutes = 0
        
        // Call parent initialization
        Set tSC = ..Initialize()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process the emergency record
/// <p>Implements emergency-specific processing including triage prioritization
/// and critical care pathways.</p>
/// <returns>Result string describing the processing performed</returns>
Method ProcessRecord() As %String
{
    Set result = "EmergencyRecord.ProcessRecord(): "
    Set result = result _ "Processing emergency visit for " _ ..PatientName
    Set result = result _ " (MRN: " _ ..PatientMRN _ ")"
    
    // Add triage level
    Set result = result _ " - Triage Level: " _ ..TriageLevel
    
    // Add chief complaint
    Set result = result _ " - Chief Complaint: " _ ..ChiefComplaint
    
    // Add arrival information
    Set result = result _ " - Arrived via " _ ..ArrivalMode
    Set result = result _ " at " _ ..ArrivalTime
    
    // Process based on triage level
    If ..TriageLevel = 1 {
        Set result = result _ " [CRITICAL - IMMEDIATE ATTENTION REQUIRED]"
        Set ..Priority = "Critical"
    } ElseIf ..TriageLevel = 2 {
        Set result = result _ " [EMERGENT - HIGH PRIORITY]"
        Set ..Priority = "High"
    } ElseIf ..TriageLevel = 3 {
        Set result = result _ " [URGENT - MODERATE PRIORITY]"
        Set ..Priority = "Medium"
    } ElseIf ..TriageLevel = 4 {
        Set result = result _ " [LESS URGENT - LOW PRIORITY]"
        Set ..Priority = "Low"
    } Else {
        Set result = result _ " [NON-URGENT - ROUTINE CARE]"
        Set ..Priority = "Normal"
    }
    
    // Check for trauma alert
    If ..TraumaAlert {
        Set result = result _ " [TRAUMA ALERT ACTIVATED]"
    }
    
    // Add wait time if applicable
    If ..WaitTimeMinutes > 0 {
        Set result = result _ " [WAIT TIME: " _ ..WaitTimeMinutes _ " minutes]"
    }
    
    // Add disposition if set
    If ..Disposition '= "" {
        Set result = result _ " [DISPOSITION: " _ ..Disposition _ "]"
    }
    
    // Check severity index
    If ..SeverityIndex = "Critical" {
        Set result = result _ " [ACTIVATING EMERGENCY PROTOCOL]"
    }
    
    Quit result
}

/// Validate the emergency record
/// <p>Ensures all required emergency fields are properly populated.</p>
/// <returns>%Status indicating validation result</returns>
Method ValidateRecord() As %Status
{
    Set tSC = $$$OK
    Try {
        // Check required fields
        If ..PatientMRN = "" {
            Throw ##class(%Exception.General).%New("Patient MRN is required")
        }
        
        If ..PatientName = "" {
            Throw ##class(%Exception.General).%New("Patient name is required")
        }
        
        If ..ChiefComplaint = "" {
            Throw ##class(%Exception.General).%New("Chief complaint is required")
        }
        
        If ..Department = "" {
            Set ..Department = "Emergency Department"
        }
        
        // Validate triage level
        If (..TriageLevel < 1) || (..TriageLevel > 5) {
            Throw ##class(%Exception.General).%New("Triage level must be between 1 and 5")
        }
        
        If ..ArrivalMode = "" {
            Throw ##class(%Exception.General).%New("Arrival mode is required")
        }
        
        If ..ArrivalTime = "" {
            Throw ##class(%Exception.General).%New("Arrival time is required")
        }
        
        // Validate wait time
        If ..WaitTimeMinutes < 0 {
            Throw ##class(%Exception.General).%New("Wait time cannot be negative")
        }
        
        // Validate vital signs for critical patients
        If (..TriageLevel <= 2) && (..VitalSigns = "") {
            Throw ##class(%Exception.General).%New("Vital signs required for triage level 1-2 patients")
        }
        
        // Set severity index based on triage if not set
        If ..SeverityIndex = "" {
            If ..TriageLevel = 1 {
                Set ..SeverityIndex = "Critical"
            } ElseIf ..TriageLevel = 2 {
                Set ..SeverityIndex = "Emergent"
            } ElseIf ..TriageLevel = 3 {
                Set ..SeverityIndex = "Urgent"
            } Else {
                Set ..SeverityIndex = "Non-Urgent"
            }
        }
        
        // Also set the Severity property to match (for backward compatibility)
        If ..TriageLevel <= 2 {
            Set ..Severity = "Critical"
        } ElseIf ..TriageLevel = 3 {
            Set ..Severity = "Urgent"
        } ElseIf ..TriageLevel = 4 {
            Set ..Severity = "Less Urgent"
        } Else {
            Set ..Severity = "Non-Urgent"
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Calculate billing code for emergency visit
/// <p>Generates billing code based on triage level and services provided.</p>
/// <returns>Billing code string</returns>
Method CalculateBillingCode() As %String
{
    Set billingCode = "ED-"  // Emergency Department prefix
    
    // Add triage level code
    Set billingCode = billingCode _ "L" _ ..TriageLevel _ "-"
    
    // Add severity code
    If ..SeverityIndex = "Critical" {
        Set billingCode = billingCode _ "CRIT-"
    } ElseIf ..SeverityIndex = "Emergent" {
        Set billingCode = billingCode _ "EMRG-"
    } ElseIf ..SeverityIndex = "Urgent" {
        Set billingCode = billingCode _ "URG-"
    } Else {
        Set billingCode = billingCode _ "NURG-"
    }
    
    // Add arrival mode modifier
    If ..ArrivalMode = "Ambulance" {
        Set billingCode = billingCode _ "AMB"
    } ElseIf ..TraumaAlert {
        Set billingCode = billingCode _ "TRAUMA"
    } Else {
        Set billingCode = billingCode _ "WALK"
    }
    
    // Add disposition modifier if available
    If ..Disposition = "Admitted" {
        Set billingCode = billingCode _ "-ADM"
    } ElseIf ..Disposition = "Transferred" {
        Set billingCode = billingCode _ "-TRANS"
    }
    
    Quit billingCode
}

/// Get detailed record summary including emergency-specific information
/// <returns>Formatted string with complete emergency record details</returns>
Method GetRecordSummary() As %String
{
    // Get base summary from parent
    Set summary = ##super()
    
    // Add emergency-specific details
    Set summary = summary _ $Char(13,10) _ "--- Emergency Details ---" _ $Char(13,10)
    Set summary = summary _ "Triage Level: " _ ..TriageLevel _ " (" _ ..SeverityIndex _ ")" _ $Char(13,10)
    Set summary = summary _ "Chief Complaint: " _ ..ChiefComplaint _ $Char(13,10)
    Set summary = summary _ "Arrival: " _ ..ArrivalMode _ " at " _ ..ArrivalTime _ $Char(13,10)
    
    If ..VitalSigns '= "" {
        Set summary = summary _ "Vital Signs: " _ ..VitalSigns _ $Char(13,10)
    }
    
    If ..TraumaAlert {
        Set summary = summary _ "Trauma Alert: ACTIVE" _ $Char(13,10)
    }
    
    If ..WaitTimeMinutes > 0 {
        Set summary = summary _ "Wait Time: " _ ..WaitTimeMinutes _ " minutes" _ $Char(13,10)
    }
    
    If ..Disposition '= "" {
        Set summary = summary _ "Disposition: " _ ..Disposition _ $Char(13,10)
    }
    
    Set summary = summary _ "Billing Code: " _ ..CalculateBillingCode() _ $Char(13,10)
    Set summary = summary _ "================================"
    
    Quit summary
}

Storage Default
{
<Data name="EmergencyRecordDefaultData">
<Subscript>"EmergencyRecord"</Subscript>
<Value name="1">
<Value>TriageLevel</Value>
</Value>
<Value name="2">
<Value>ChiefComplaint</Value>
</Value>
<Value name="3">
<Value>ArrivalTime</Value>
</Value>
<Value name="4">
<Value>ArrivalMode</Value>
</Value>
<Value name="5">
<Value>VitalSigns</Value>
</Value>
<Value name="6">
<Value>SeverityIndex</Value>
</Value>
<Value name="7">
<Value>Severity</Value>
</Value>
<Value name="8">
<Value>Disposition</Value>
</Value>
<Value name="9">
<Value>TraumaAlert</Value>
</Value>
<Value name="10">
<Value>WaitTimeMinutes</Value>
</Value>
</Data>
<DefaultData>EmergencyRecordDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
