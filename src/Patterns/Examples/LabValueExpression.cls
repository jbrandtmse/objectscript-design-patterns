/// Gang of Four Interpreter Pattern - Healthcare Lab Value Expression
/// <p>Expression for evaluating lab test results against reference ranges.</p>
Class Patterns.Examples.LabValueExpression Extends Patterns.Examples.ClinicalRuleExpression
{

/// Lab test name
Property TestName As %String;

/// Comparison operator
Property Operator As %String;

/// Reference value
Property ReferenceValue As %Numeric;

/// Unit of measurement
Property Unit As %String;

/// Constructor
Method %OnNew(pTestName As %String = "", pOperator As %String = "", pReferenceValue As %Numeric = "", pUnit As %String = "") As %Status
{
    Set ..TestName = pTestName
    Set ..Operator = pOperator
    Set ..ReferenceValue = pReferenceValue
    Set ..Unit = pUnit
    Set ..Description = "Lab value rule for "_pTestName
    Quit $$$OK
}

/// Interpret the lab value expression
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    Set tResult = 0
    
    Try {
        // Cast to ClinicalContext for accessing lab values
        If '$IsObject(pContext) || (pContext.%ClassName(1) '= "ClinicalContext") {
            Set tResult = 0
            Quit
        }
        
        Set tClinicalContext = pContext
        
        // Get current lab value
        Set tCurrentValue = tClinicalContext.GetLabValue(..TestName)
        
        // If lab value not found, return false
        If tCurrentValue = "" {
            Set tResult = 0
            Quit
        }
        
        // Perform comparison
        Set tResult = ..Compare(tCurrentValue, ..Operator, ..ReferenceValue)
        
        // Generate alert if rule evaluates to true
        If tResult {
            Set tAlert = ..GenerateAlert(tClinicalContext)
            If $IsObject(tAlert) {
                Do tClinicalContext.AddAlert(tAlert.message)
            }
        }
        
        // Add debug info
        If pContext.DebugMode {
            Do pContext.AddDebugInfo("Lab "_..TestName_": "_tCurrentValue_" "_..Operator_" "_..ReferenceValue_" = "_tResult)
        }
        
    } Catch ex {
        Set tResult = 0
        If $IsObject(pContext) && pContext.DebugMode {
            Do pContext.AddDebugInfo("Lab expression error: "_ex.DisplayString())
        }
    }
    
    Quit tResult
}

/// Compare values based on operator
Method Compare(pCurrent As %Numeric, pOperator As %String, pReference As %Numeric) As %Boolean [ Private ]
{
    Set tResult = 0
    
    If pOperator = ">" {
        Set tResult = (pCurrent > pReference)
    } ElseIf pOperator = "<" {
        Set tResult = (pCurrent < pReference)
    } ElseIf pOperator = ">=" {
        Set tResult = (pCurrent >= pReference)
    } ElseIf pOperator = "<=" {
        Set tResult = (pCurrent <= pReference)
    } ElseIf pOperator = "=" {
        Set tResult = (pCurrent = pReference)
    } ElseIf pOperator = "!=" || (pOperator = "<>") {
        Set tResult = (pCurrent '= pReference)
    }
    
    Quit tResult
}

/// Generate clinical alert (overrides base class)
Method GenerateAlert(pContext As Patterns.Examples.ClinicalContext) As %DynamicObject
{
    Set tAlert = ##class(%DynamicObject).%New()
    Set tAlert.rule = ..TestName_" Test"
    Set tAlert.severity = ..Severity
    Set tAlert.message = ..Severity_": "_..TestName_" is "_..Operator_" "_..ReferenceValue_" "_..Unit
    Set tAlert.timestamp = $ZDATETIME($HOROLOG,3)
    If $IsObject(pContext) {
        Set tAlert.patientId = pContext.PatientId
    }
    Quit tAlert
}

/// Get string representation
Method ToString() As %String
{
    Quit ..TestName_" "_..Operator_" "_..ReferenceValue_" "_..Unit
}

/// Factory method for creating lab value expressions
ClassMethod Create(pTestName As %String, pOperator As %String, pReferenceValue As %Numeric, pUnit As %String = "", pSeverity As %String = "WARNING") As LabValueExpression
{
    Set tExpression = ##class(LabValueExpression).%New(pTestName, pOperator, pReferenceValue, pUnit)
    Set tExpression.Severity = pSeverity
    Quit tExpression
}

/// Create common lab test rules
ClassMethod CreateGlucoseHighRule() As LabValueExpression
{
    Quit ..Create("Glucose", ">", 200, "mg/dL", "CRITICAL")
}

ClassMethod CreateCreatinineHighRule() As LabValueExpression
{
    Quit ..Create("Creatinine", ">", 1.5, "mg/dL", "WARNING")
}

ClassMethod CreateHemoglobinLowRule() As LabValueExpression
{
    Quit ..Create("Hemoglobin", "<", 8, "g/dL", "CRITICAL")
}

}
