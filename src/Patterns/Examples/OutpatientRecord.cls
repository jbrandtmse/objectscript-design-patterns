/// Concrete implementation of PatientRecord for outpatient visits
/// <p>Represents a patient record for outpatient clinic visits or ambulatory care.</p>
Class Patterns.Examples.OutpatientRecord Extends Patterns.Examples.PatientRecord
{

/// Visit type (e.g., "Follow-up", "New Patient", "Consultation")
Property VisitType As %String;

/// Appointment time
Property AppointmentTime As %Time;

/// Visit reason or chief complaint
Property VisitReason As %String;

/// Referral source if applicable
Property ReferralSource As %String;

/// Follow-up required flag
Property FollowUpRequired As %Boolean;

/// Next appointment date if scheduled
Property NextAppointmentDate As %Date;

/// Insurance copay amount
Property CopayAmount As %Decimal(SCALE = 2);

/// Copay alias for compatibility (references CopayAmount)
Property Copay As %Decimal(SCALE = 2) [ Calculated, SqlComputeCode = { Set {*} = {CopayAmount} }, SqlComputed ];

/// Initialize outpatient record with default values
/// <returns>%Status indicating initialization success</returns>
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Set record type
        Set ..RecordType = "Outpatient"
        
        // Set default priority
        Set ..Priority = "Normal"
        
        // Set default copay
        Set ..CopayAmount = 0
        
        // Set default follow-up
        Set ..FollowUpRequired = 0
        
        // Call parent initialization
        Set tSC = ..Initialize()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process the outpatient record
/// <p>Implements outpatient-specific processing including appointment scheduling
/// and follow-up management.</p>
/// <returns>Result string describing the processing performed</returns>
Method ProcessRecord() As %String
{
    Set result = "OutpatientRecord.ProcessRecord(): "
    Set result = result _ "Processing outpatient visit for " _ ..PatientName
    Set result = result _ " (MRN: " _ ..PatientMRN _ ")"
    
    // Add visit type information
    Set result = result _ " - Visit Type: " _ ..VisitType
    
    // Add appointment time
    If ..AppointmentTime '= "" {
        Set result = result _ " at " _ $ZTime(..AppointmentTime, 1)
    }
    
    // Add department and provider
    Set result = result _ " with Dr. " _ ..AttendingProvider
    Set result = result _ " in " _ ..Department
    
    // Process based on visit type
    If ..VisitType = "New Patient" {
        Set result = result _ " [NEW PATIENT INTAKE REQUIRED]"
    } ElseIf ..VisitType = "Follow-up" {
        Set result = result _ " [REVIEWING PREVIOUS VISIT]"
    } ElseIf ..VisitType = "Consultation" {
        Set result = result _ " [SPECIALIST CONSULTATION]"
    }
    
    // Check for follow-up requirements
    If ..FollowUpRequired {
        Set result = result _ " [FOLLOW-UP SCHEDULED: " _ $ZDate(..NextAppointmentDate, 3) _ "]"
    }
    
    // Process referral if exists
    If ..ReferralSource '= "" {
        Set result = result _ " [REFERRED BY: " _ ..ReferralSource _ "]"
    }
    
    // Process copay
    If ..CopayAmount > 0 {
        Set result = result _ " [COPAY COLLECTED: $" _ $Justify(..CopayAmount, 0, 2) _ "]"
    }
    
    Quit result
}

/// Validate the outpatient record
/// <p>Ensures all required outpatient fields are properly populated.</p>
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
        
        If ..VisitType = "" {
            Throw ##class(%Exception.General).%New("Visit type is required")
        }
        
        If ..Department = "" {
            Throw ##class(%Exception.General).%New("Department is required")
        }
        
        If ..AttendingProvider = "" {
            Throw ##class(%Exception.General).%New("Attending provider is required")
        }
        
        // Validate appointment time for non-walk-in visits
        If (..VisitType '= "Walk-in") && (..AppointmentTime = "") {
            Throw ##class(%Exception.General).%New("Appointment time required for scheduled visits")
        }
        
        // Validate visit reason
        If ..VisitReason = "" {
            Throw ##class(%Exception.General).%New("Visit reason is required")
        }
        
        // Validate copay amount
        If ..CopayAmount < 0 {
            Throw ##class(%Exception.General).%New("Copay amount cannot be negative")
        }
        
        // Validate follow-up date if follow-up required
        If ..FollowUpRequired && (..NextAppointmentDate = "") {
            Throw ##class(%Exception.General).%New("Next appointment date required when follow-up is needed")
        }
        
        // Ensure next appointment is in the future
        If (..NextAppointmentDate '= "") && (..NextAppointmentDate <= +$Horolog) {
            Throw ##class(%Exception.General).%New("Next appointment date must be in the future")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Calculate billing code for outpatient visit
/// <p>Generates billing code based on visit type and services.</p>
/// <returns>Billing code string</returns>
Method CalculateBillingCode() As %String
{
    Set billingCode = "OP-"  // Outpatient prefix
    
    // Add visit type code
    If ..VisitType = "New Patient" {
        Set billingCode = billingCode _ "NEW-"
    } ElseIf ..VisitType = "Follow-up" {
        Set billingCode = billingCode _ "FU-"
    } ElseIf ..VisitType = "Consultation" {
        Set billingCode = billingCode _ "CONS-"
    } ElseIf ..VisitType = "Walk-in" {
        Set billingCode = billingCode _ "WALK-"
    } Else {
        Set billingCode = billingCode _ "VISIT-"
    }
    
    // Add department code
    If $Find(..Department, "Cardiology") {
        Set billingCode = billingCode _ "CARD"
    } ElseIf $Find(..Department, "Orthopedics") {
        Set billingCode = billingCode _ "ORTH"
    } ElseIf $Find(..Department, "Dermatology") {
        Set billingCode = billingCode _ "DERM"
    } ElseIf $Find(..Department, "Primary") {
        Set billingCode = billingCode _ "PCP"
    } Else {
        Set billingCode = billingCode _ "GEN"
    }
    
    // Add referral modifier if applicable
    If ..ReferralSource '= "" {
        Set billingCode = billingCode _ "-REF"
    }
    
    Quit billingCode
}

/// Get detailed record summary including outpatient-specific information
/// <returns>Formatted string with complete outpatient record details</returns>
Method GetRecordSummary() As %String
{
    // Get base summary from parent
    Set summary = ##super()
    
    // Add outpatient-specific details
    Set summary = summary _ $Char(13,10) _ "--- Outpatient Details ---" _ $Char(13,10)
    Set summary = summary _ "Visit Type: " _ ..VisitType _ $Char(13,10)
    
    If ..AppointmentTime '= "" {
        Set summary = summary _ "Appointment: " _ $ZTime(..AppointmentTime, 1) _ $Char(13,10)
    }
    
    Set summary = summary _ "Reason: " _ ..VisitReason _ $Char(13,10)
    
    If ..ReferralSource '= "" {
        Set summary = summary _ "Referred By: " _ ..ReferralSource _ $Char(13,10)
    }
    
    If ..CopayAmount > 0 {
        Set summary = summary _ "Copay: $" _ $Justify(..CopayAmount, 0, 2) _ $Char(13,10)
    }
    
    If ..FollowUpRequired {
        Set summary = summary _ "Follow-up Required: Yes" _ $Char(13,10)
        If ..NextAppointmentDate '= "" {
            Set summary = summary _ "Next Appointment: " _ $ZDate(..NextAppointmentDate, 3) _ $Char(13,10)
        }
    } Else {
        Set summary = summary _ "Follow-up Required: No" _ $Char(13,10)
    }
    
    Set summary = summary _ "Billing Code: " _ ..CalculateBillingCode() _ $Char(13,10)
    Set summary = summary _ "================================"
    
    Quit summary
}

/// Get method for calculated Copay property
Method CopayGet() As %Decimal
{
    Quit ..CopayAmount
}

/// Set method for calculated Copay property
Method CopaySet(pValue As %Decimal) As %Status
{
    Set ..CopayAmount = pValue
    Quit $$$OK
}

Storage Default
{
<Data name="OutpatientRecordDefaultData">
<Subscript>"OutpatientRecord"</Subscript>
<Value name="1">
<Value>VisitType</Value>
</Value>
<Value name="2">
<Value>AppointmentTime</Value>
</Value>
<Value name="3">
<Value>VisitReason</Value>
</Value>
<Value name="4">
<Value>ReferralSource</Value>
</Value>
<Value name="5">
<Value>FollowUpRequired</Value>
</Value>
<Value name="6">
<Value>NextAppointmentDate</Value>
</Value>
<Value name="7">
<Value>CopayAmount</Value>
</Value>
</Data>
<DefaultData>OutpatientRecordDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
