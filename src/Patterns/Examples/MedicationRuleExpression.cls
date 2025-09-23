/// Gang of Four Interpreter Pattern - Healthcare Medication Rule Expression
/// <p>Expression for evaluating medication-related rules and drug interactions.</p>
Class Patterns.Examples.MedicationRuleExpression Extends Patterns.Examples.ClinicalRuleExpression
{

/// Medication name
Property MedicationName As %String;

/// Rule type (INTERACTION, ALLERGY, DOSAGE, CONTRAINDICATION)
Property RuleType As %String;

/// Related medication for interactions
Property RelatedMedication As %String;

/// Maximum dosage
Property MaxDosage As %Numeric;

/// Dosage unit
Property DosageUnit As %String;

/// Constructor
Method %OnNew(pMedicationName As %String = "", pRuleType As %String = "") As %Status
{
    Set ..MedicationName = pMedicationName
    Set ..RuleType = pRuleType
    Set ..Description = "Medication rule for "_pMedicationName
    Quit $$$OK
}

/// Interpret the medication rule expression
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    Set tResult = 0
    
    Try {
        // Cast to ClinicalContext
        If '$IsObject(pContext) || (pContext.%ClassName(1) '= "ClinicalContext") {
            Set tResult = 0
            Quit
        }
        
        Set tClinicalContext = pContext
        
        // Check rule based on type
        If ..RuleType = "INTERACTION" {
            Set tResult = ..CheckInteraction(tClinicalContext)
        } ElseIf ..RuleType = "ALLERGY" {
            Set tResult = ..CheckAllergy(tClinicalContext)
        } ElseIf ..RuleType = "DOSAGE" {
            Set tResult = ..CheckDosage(tClinicalContext)
        } ElseIf ..RuleType = "CONTRAINDICATION" {
            Set tResult = ..CheckContraindication(tClinicalContext)
        }
        
        // Generate alert if rule triggers
        If tResult {
            Set tAlert = ..GenerateAlert(tClinicalContext)
            If $IsObject(tAlert) {
                Do tClinicalContext.AddAlert(tAlert.message)
            }
        }
        
        // Add debug info
        If pContext.DebugMode {
            Do pContext.AddDebugInfo("Medication rule "_..RuleType_" for "_..MedicationName_": "_tResult)
        }
        
    } Catch ex {
        Set tResult = 0
        If $IsObject(pContext) && pContext.DebugMode {
            Do pContext.AddDebugInfo("Medication expression error: "_ex.DisplayString())
        }
    }
    
    Quit tResult
}

/// Check for drug interactions
Method CheckInteraction(pContext As Patterns.Examples.ClinicalContext) As %Boolean [ Private ]
{
    If ..RelatedMedication = "" Quit 0
    
    Set tHasMed1 = pContext.HasMedication(..MedicationName)
    Set tHasMed2 = pContext.HasMedication(..RelatedMedication)
    
    // Return true if both medications are present
    Quit (tHasMed1 && tHasMed2)
}

/// Check for allergies
Method CheckAllergy(pContext As Patterns.Examples.ClinicalContext) As %Boolean [ Private ]
{
    // Check if patient has allergy to this medication
    Set tAllergies = pContext.GetDiagnosis("ALLERGY")
    If tAllergies [ ..MedicationName {
        Quit 1
    }
    Quit 0
}

/// Check dosage limits
Method CheckDosage(pContext As Patterns.Examples.ClinicalContext) As %Boolean [ Private ]
{
    If ..MaxDosage = "" Quit 0
    
    Set tCurrentDosage = pContext.GetMedicationDosage(..MedicationName)
    If tCurrentDosage = "" Quit 0
    
    // Return true if dosage exceeds maximum
    Quit (tCurrentDosage > ..MaxDosage)
}

/// Check contraindications
Method CheckContraindication(pContext As Patterns.Examples.ClinicalContext) As %Boolean [ Private ]
{
    // Example: Check if medication is contraindicated based on diagnosis
    Set tDiagnoses = pContext.Diagnoses
    
    // Simplified logic - in real system would have contraindication database
    If (..MedicationName = "Aspirin") && (tDiagnoses [ "BLEEDING_DISORDER") {
        Quit 1
    }
    If (..MedicationName = "Metformin") && (tDiagnoses [ "RENAL_FAILURE") {
        Quit 1
    }
    
    Quit 0
}

/// Generate clinical alert (overrides base class)
Method GenerateAlert(pContext As Patterns.Examples.ClinicalContext) As %DynamicObject
{
    Set tAlert = ##class(%DynamicObject).%New()
    Set tAlert.rule = ..MedicationName_" "_..RuleType
    Set tAlert.severity = ..Severity
    
    Set tMessage = ..Severity_": "
    If ..RuleType = "INTERACTION" {
        Set tMessage = tMessage_"Drug interaction between "_..MedicationName_" and "_..RelatedMedication
    } ElseIf ..RuleType = "ALLERGY" {
        Set tMessage = tMessage_"Patient allergic to "_..MedicationName
    } ElseIf ..RuleType = "DOSAGE" {
        Set tMessage = tMessage_..MedicationName_" dosage exceeds maximum of "_..MaxDosage_" "_..DosageUnit
    } ElseIf ..RuleType = "CONTRAINDICATION" {
        Set tMessage = tMessage_..MedicationName_" is contraindicated"
    }
    
    Set tAlert.message = tMessage
    Set tAlert.timestamp = $ZDATETIME($HOROLOG,3)
    If $IsObject(pContext) {
        Set tAlert.patientId = pContext.PatientId
    }
    Quit tAlert
}

/// Get string representation
Method ToString() As %String
{
    Quit ..RuleType_" rule for "_..MedicationName
}

/// Factory methods for creating common medication rules
ClassMethod CreateInteractionRule(pMed1 As %String, pMed2 As %String) As MedicationRuleExpression
{
    Set tRule = ##class(MedicationRuleExpression).%New(pMed1, "INTERACTION")
    Set tRule.RelatedMedication = pMed2
    Set tRule.Severity = "CRITICAL"
    Quit tRule
}

ClassMethod CreateAllergyRule(pMedication As %String) As MedicationRuleExpression
{
    Set tRule = ##class(MedicationRuleExpression).%New(pMedication, "ALLERGY")
    Set tRule.Severity = "CRITICAL"
    Quit tRule
}

ClassMethod CreateDosageRule(pMedication As %String, pMaxDosage As %Numeric, pUnit As %String) As MedicationRuleExpression
{
    Set tRule = ##class(MedicationRuleExpression).%New(pMedication, "DOSAGE")
    Set tRule.MaxDosage = pMaxDosage
    Set tRule.DosageUnit = pUnit
    Set tRule.Severity = "WARNING"
    Quit tRule
}

ClassMethod CreateContraindicationRule(pMedication As %String) As MedicationRuleExpression
{
    Set tRule = ##class(MedicationRuleExpression).%New(pMedication, "CONTRAINDICATION")
    Set tRule.Severity = "CRITICAL"
    Quit tRule
}

}
