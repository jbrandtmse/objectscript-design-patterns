/// Healthcare Diagnosis Domain Object
///
/// Represents a medical diagnosis with ICD-10 codes and clinical rules.
/// Encapsulates diagnosis-specific business logic and validation.
///
/// @see Patterns.Examples.Clinical.MedicalRecord
/// @since 1.0.0
Class Patterns.Examples.Clinical.Diagnosis Extends Patterns.PoEAA.DomainLogic.DomainModel
{

/// ICD-10 diagnosis code
Property DiagnosisCode As %String;

/// Diagnosis description
Property Description As %String;

/// Date of diagnosis
Property DiagnosisDate As %Date;

/// Severity level (Mild, Moderate, Severe, Critical)
Property Severity As %String;

/// Clinical notes
Property ClinicalNotes As %String;

/// Diagnosis status (Active, Resolved, Chronic)
Property Status As %String;

/// Treatment contraindications (multi-dimensional array)
Property Contraindications [ MultiDimensional ];

/// Domain-specific initialization
Method Initialize() As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize collections
        Kill ..Contraindications
        
        // Set default values
        Set ..Severity = "Moderate"
        Set ..Status = "Active"
        Set ..DiagnosisDate = +$HOROLOG
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check diagnosis domain invariants
Method CheckInvariants() As %Boolean
{
    // Must have diagnosis code
    If (..DiagnosisCode = "") Quit 0
    
    // Must have description
    If (..Description = "") Quit 0
    
    // Must have valid diagnosis date
    If (..DiagnosisDate = "") Quit 0
    
    // Must have valid severity
    If '..IsValidSeverity(..Severity) Quit 0
    
    // Must have valid status
    If '..IsValidStatus(..Status) Quit 0
    
    Quit 1
}

/// Perform diagnosis-specific validation
Method PerformValidation() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate ICD-10 code format (basic pattern: Letter followed by 2-3 digits)
        If '$MATCH(..DiagnosisCode, "^[A-Z][0-9]{2,3}") {
            Do ..AddValidationError("DiagnosisCode", "Invalid ICD-10 code format")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid diagnosis code")
            Quit
        }
        
        // Validate description length
        If ($LENGTH(..Description) < 5) {
            Do ..AddValidationError("Description", "Description must be at least 5 characters")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid description")
            Quit
        }
        
        // Validate diagnosis date is not in future
        If (..DiagnosisDate > +$HOROLOG) {
            Do ..AddValidationError("DiagnosisDate", "Diagnosis date cannot be in the future")
            Set tSC = $$$ERROR($$$GeneralError, "Invalid diagnosis date")
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Execute diagnosis business logic
Method ExecuteBusinessLogic() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate before execution
        Set tSC = ..ValidateRules()
        If $$$ISERR(tSC) Quit
        
        // Raise domain event
        Set tEventData = {"diagnosisId": (..Identity), "code": (..DiagnosisCode), "severity": (..Severity)}
        Do ..RaiseDomainEvent("DiagnosisValidated", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check if severity value is valid
/// @param pSeverity Severity to validate
/// @return 1 if valid, 0 otherwise
Method IsValidSeverity(pSeverity As %String) As %Boolean
{
    Set tValid = $LISTFIND($LISTBUILD("Mild", "Moderate", "Severe", "Critical"), pSeverity)
    Quit (tValid > 0)
}

/// Check if status value is valid
/// @param pStatus Status to validate
/// @return 1 if valid, 0 otherwise
Method IsValidStatus(pStatus As %String) As %Boolean
{
    Set tValid = $LISTFIND($LISTBUILD("Active", "Resolved", "Chronic"), pStatus)
    Quit (tValid > 0)
}

/// Add contraindication for treatment
/// @param pTreatment Treatment or medication name
/// @param pReason Reason for contraindication
Method AddContraindication(pTreatment As %String, pReason As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        If (pTreatment = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Treatment name required")
            Quit
        }
        
        If (pReason = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Reason required")
            Quit
        }
        
        // Add contraindication
        Set tCount = $GET(..Contraindications)
        Set tCount = tCount + 1
        Set ..Contraindications = tCount
        Set ..Contraindications(tCount, "treatment") = pTreatment
        Set ..Contraindications(tCount, "reason") = pReason
        
        // Raise domain event
        Set tEventData = {"treatment": (pTreatment), "reason": (pReason)}
        Do ..RaiseDomainEvent("ContraindicationAdded", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check if treatment is contraindicated
/// @param pTreatment Treatment to check
/// @return 1 if contraindicated, 0 otherwise
Method IsContraindicated(pTreatment As %String) As %Boolean
{
    Set tResult = 0
    Set tCount = $GET(..Contraindications)
    For tIndex = 1:1:tCount {
        Set tTreatment = $GET(..Contraindications(tIndex, "treatment"))
        If (tTreatment = pTreatment) {
            Set tResult = 1
            Quit
        }
    }
    Quit tResult
}

/// Resolve the diagnosis
Method Resolve() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Status = "Resolved"
        
        // Raise domain event
        Set tEventData = {"diagnosisId": (..Identity), "code": (..DiagnosisCode)}
        Do ..RaiseDomainEvent("DiagnosisResolved", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Mark as chronic condition
Method MarkAsChronic() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Status = "Chronic"
        
        // Raise domain event
        Set tEventData = {"diagnosisId": (..Identity), "code": (..DiagnosisCode)}
        Do ..RaiseDomainEvent("DiagnosisMarkedChronic", tEventData)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
