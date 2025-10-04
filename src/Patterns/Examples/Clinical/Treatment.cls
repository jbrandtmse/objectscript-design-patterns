/// Healthcare Treatment Domain Object
/// 
/// Represents a medical treatment protocol with medication orders and dosage calculations.
/// Encapsulates treatment-specific business logic and safety rules.
/// 
/// @see Patterns.Examples.Clinical.MedicalRecord
/// @since 1.0.0
Class Patterns.Examples.Clinical.Treatment Extends Patterns.PoEAA.DomainLogic.DomainModel
{

/// Treatment protocol name
Property ProtocolName As %String;

/// Medication name
Property MedicationName As %String;

/// Dosage amount
Property DosageAmount As %Numeric;

/// Dosage unit (mg, ml, units, etc.)
Property DosageUnit As %String;

/// Frequency (e.g., "Every 8 hours", "Twice daily")
Property Frequency As %String;

/// Treatment start date
Property StartDate As %Date;

/// Treatment end date
Property EndDate As %Date;

/// Treatment status (Ordered, Active, Completed, Discontinued)
Property Status As %String;

/// Route of administration (Oral, IV, IM, etc.)
Property Route As %String;

/// Special instructions
Property SpecialInstructions As %String;

/// Domain-specific initialization
Method Initialize() As %Status
{
    Set tSC = $$$OK
    Try {
        // Set default values
        Set ..Status = "Ordered"
        Set ..StartDate = +$HOROLOG
        Set ..DosageAmount = 0
        Set ..Route = "Oral"
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check treatment domain invariants
Method CheckInvariants() As %Boolean
{
    // Must have protocol name
    If (..ProtocolName = "") Quit 0
    
    // Must have medication name
    If (..MedicationName = "") Quit 0
    
    // Must have valid dosage
    If (..DosageAmount <= 0) Quit 0
    
    // Must have dosage unit
    If (..DosageUnit = "") Quit 0
    
    // Must have frequency
    If (..Frequency = "") Quit 0
    
    // Must have valid status
    If '..IsValidStatus(..Status) Quit 0
    
    // End date must be after start date if specified
    If (..EndDate '= "") && (..EndDate < ..StartDate) Quit 0
    
    Quit 1
}

/// Perform treatment-specific validation
Method PerformValidation() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate protocol name
        If ($LENGTH(..ProtocolName) < 3) {
            Do ..AddValidationError("ProtocolName", "Protocol name must be at least 3 characters")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid protocol name")
            Quit
        }
        
        // Validate medication name
        If ($LENGTH(..MedicationName) < 3) {
            Do ..AddValidationError("MedicationName", "Medication name must be at least 3 characters")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid medication name")
            Quit
        }
        
        // Validate dosage is positive
        If (..DosageAmount <= 0) {
            Do ..AddValidationError("DosageAmount", "Dosage must be greater than zero")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid dosage amount")
            Quit
        }
        
        // Validate start date is not in future
        If (..StartDate > +$HOROLOG) {
            Do ..AddValidationError("StartDate", "Start date cannot be in the future")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid start date")
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Execute treatment business logic
Method ExecuteBusinessLogic() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate before execution
        Set tSC = ..ValidateRules()
        If $$$ISERR(tSC) Quit
        
        // Raise domain event
        Set tEventData = {"treatmentId": (..Identity), "medication": (..MedicationName), "protocol": (..ProtocolName)}
        Do ..RaiseDomainEvent("TreatmentValidated", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check if status value is valid
/// @param pStatus Status to validate
/// @return 1 if valid, 0 otherwise
Method IsValidStatus(pStatus As %String) As %Boolean
{
    Set tValid = $LISTFIND($LISTBUILD("Ordered", "Active", "Completed", "Discontinued"), pStatus)
    Quit (tValid > 0)
}

/// Calculate daily dosage
/// @return Total daily dosage amount
Method CalculateDailyDosage() As %Numeric
{
    Set tDailyDosage = 0
    
    // Simple frequency parsing - check more specific patterns first
    If (..Frequency [ "four") || (..Frequency [ "Four") {
        // Four times daily
        Set tDailyDosage = ..DosageAmount * 4
    } ElseIf (..Frequency [ "three") || (..Frequency [ "Three") {
        // Three times daily
        Set tDailyDosage = ..DosageAmount * 3
    } ElseIf (..Frequency [ "twice") || (..Frequency [ "Twice") {
        // Twice daily
        Set tDailyDosage = ..DosageAmount * 2
    } ElseIf (..Frequency [ "6 hours") || (..Frequency [ "6 Hours") {
        // Every 6 hours = 4 times daily
        Set tDailyDosage = ..DosageAmount * 4
    } ElseIf (..Frequency [ "8 hours") || (..Frequency [ "8 Hours") {
        // Every 8 hours = 3 times daily
        Set tDailyDosage = ..DosageAmount * 3
    } ElseIf (..Frequency [ "12 hours") || (..Frequency [ "12 Hours") {
        // Every 12 hours = 2 times daily
        Set tDailyDosage = ..DosageAmount * 2
    } ElseIf (..Frequency [ "daily") || (..Frequency [ "Daily") {
        // Once daily
        Set tDailyDosage = ..DosageAmount
    } Else {
        // Default to once daily
        Set tDailyDosage = ..DosageAmount
    }
    
    Quit tDailyDosage
}

/// Check if treatment is safe for patient weight
/// @param pPatientWeightKg Patient weight in kilograms
/// @param pMaxDosePerKg Maximum safe dose per kg
/// @return 1 if safe, 0 if exceeds safe limits
Method IsSafeForWeight(pPatientWeightKg As %Numeric, pMaxDosePerKg As %Numeric) As %Boolean
{
    If (pPatientWeightKg <= 0) Quit 0
    If (pMaxDosePerKg <= 0) Quit 0
    
    Set tDailyDosage = ..CalculateDailyDosage()
    Set tMaxDailyDose = pPatientWeightKg * pMaxDosePerKg
    
    Quit (tDailyDosage <= tMaxDailyDose)
}

/// Start the treatment
Method Start() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Status = "Active"
        Set ..StartDate = +$HOROLOG
        
        // Raise domain event
        Set tEventData = {"treatmentId": (..Identity), "medication": (..MedicationName)}
        Do ..RaiseDomainEvent("TreatmentStarted", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Complete the treatment
Method Complete() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Status = "Completed"
        Set ..EndDate = +$HOROLOG
        
        // Raise domain event
        Set tEventData = {"treatmentId": (..Identity), "medication": (..MedicationName)}
        Do ..RaiseDomainEvent("TreatmentCompleted", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Discontinue the treatment
/// @param pReason Reason for discontinuation
Method Discontinue(pReason As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Status = "Discontinued"
        Set ..EndDate = +$HOROLOG
        Set ..SpecialInstructions = "Discontinued: " _ pReason
        
        // Raise domain event
        Set tEventData = {"treatmentId": (..Identity), "medication": (..MedicationName), "reason": (pReason)}
        Do ..RaiseDomainEvent("TreatmentDiscontinued", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
