/// Gang of Four Interpreter Pattern - Healthcare Clinical Rule Expression
/// 
/// Intent:
/// Base class for clinical decision support rule expressions.
/// Provides framework for evaluating medical conditions and generating alerts.
/// 
/// Structure:
/// <example>
/// Set rule = ##class(LabValueExpression).%New("glucose", ">", "200")
/// Set context = ##class(ClinicalContext).%New()
/// Do context.SetLabValue("glucose", "250")
/// Set alert = rule.Evaluate(context)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Expression
/// @since 1.0.0
Class Patterns.Examples.ClinicalRuleExpression Extends Patterns.GoF.Behavioral.Expression
{

/// ===== PARAMETERS =====
Parameter SEVERITY As STRING = "INFO,WARNING,CRITICAL";

/// ===== PROPERTIES =====
/// Rule name/identifier
Property RuleName As %String;

/// Rule severity level
Property Severity As %String [ InitialExpression = "INFO" ];

/// Rule description
Property Description As %String;

/// Alert message template
Property AlertMessage As %String;

/// ===== ABSTRACT METHODS =====
/// Evaluate the clinical rule
/// 
/// @param pContext Clinical context with patient data
/// @return Alert message or empty if rule doesn't apply
Method Evaluate(pContext As Patterns.Examples.ClinicalContext) As %String [ Abstract ]
{
    Quit ""
}

/// Validate the clinical rule
/// 
/// @return %Status
Method ValidateRule() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// ===== PUBLIC METHODS =====
/// Implementation of Expression.Interpret() for compatibility
/// 
/// @param pContext General context
/// @return Rule evaluation result
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Convert to clinical context if possible
    If $CLASSNAME(pContext) = "Patterns.Examples.ClinicalContext" {
        Quit ..Evaluate(pContext)
    }
    Quit ""
}

/// Generate clinical alert
/// 
/// @param pContext Clinical context
/// @return Alert object or null
Method GenerateAlert(pContext As Patterns.Examples.ClinicalContext) As %DynamicObject
{
    Set tResult = ..Evaluate(pContext)
    If tResult = "" Quit ""
    
    Set tAlert = ##class(%DynamicObject).%New()
    Set tAlert.rule = ..RuleName
    Set tAlert.severity = ..Severity
    Set tAlert.message = tResult
    Set tAlert.timestamp = $ZDATETIME($HOROLOG,3)
    Set tAlert.patientId = pContext.PatientId
    
    Quit tAlert
}

/// Get rule priority based on severity
/// 
/// @return Priority value (1=Critical, 2=Warning, 3=Info)
Method GetPriority() As %Integer
{
    If ..Severity = "CRITICAL" Quit 1
    If ..Severity = "WARNING" Quit 2
    Quit 3
}

/// Validate method from Expression interface
/// 
/// @return %Status
Method Validate() As %Status
{
    // Check severity is valid
    If ..Severity = "" {
        Quit $$$ERROR($$$GeneralError, "Rule severity not set")
    }
    
    If '((..Severity = "INFO") || (..Severity = "WARNING") || (..Severity = "CRITICAL")) {
        Quit $$$ERROR($$$GeneralError, "Invalid severity: " _ ..Severity)
    }
    
    // Validate specific rule
    Quit ..ValidateRule()
}

/// Get string representation
/// 
/// @return String representation
Method ToString() As %String
{
    Quit "ClinicalRule[" _ ..RuleName _ ":" _ ..Severity _ "]"
}

}
