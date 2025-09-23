/// Gang of Four Interpreter Pattern - Boolean Expression (Terminal)
/// 
/// Intent:
/// Terminal expression that represents boolean literals in the expression language.
/// Handles true/false boolean values.
/// 
/// Structure:
/// <example>
/// Set boolExpr = ##class(Patterns.GoF.Behavioral.BooleanExpression).%New("true")
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Set result = boolExpr.Interpret(context)  // Returns "true"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.TerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.BooleanExpression Extends Patterns.GoF.Behavioral.TerminalExpression
{

/// ===== METHODS =====
/// Interprets this boolean expression
/// 
/// @param pContext The evaluation context
/// @return The boolean value as a string ("true" or "false")
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Push to evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PushEvaluation("BooleanExpression: " _ ..Value)
    }
    
    // Normalize boolean value
    Set tResult = ..GetNormalizedValue()
    
    // Pop from evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PopEvaluation()
        Do pContext.AddDebugInfo("BooleanExpression result: " _ tResult)
    }
    
    Quit tResult
}

/// Returns string representation of this boolean
/// 
/// @return String representation
Method ToString() As %String
{
    Quit ..GetNormalizedValue()
}

/// Validates that the value is a valid boolean
/// 
/// @return %Status
Method ValidateValue() As %Status
{
    // Check if value represents a boolean
    If ..Value = "" {
        Quit $$$ERROR($$$GeneralError, "Boolean expression has empty value")
    }
    
    Set tLower = $ZCONVERT(..Value, "L")
    If '((tLower = "true") || (tLower = "false") || (..Value = "1") || (..Value = "0")) {
        Quit $$$ERROR($$$GeneralError, "Invalid boolean format: " _ ..Value)
    }
    
    Quit $$$OK
}

/// Get the boolean value as 0 or 1
/// 
/// @return %Boolean (0 or 1)
Method GetBooleanValue() As %Boolean
{
    Set tLower = $ZCONVERT(..Value, "L")
    If (tLower = "true") || (..Value = "1") {
        Quit 1
    }
    Quit 0
}

/// Get normalized string representation
/// 
/// @return "true" or "false"
Method GetNormalizedValue() As %String
{
    If ..GetBooleanValue() {
        Quit "true"
    }
    Quit "false"
}

/// Check if this boolean is true
/// 
/// @return %Boolean
Method IsTrue() As %Boolean
{
    Quit ..GetBooleanValue()
}

/// Check if this boolean is false
/// 
/// @return %Boolean
Method IsFalse() As %Boolean
{
    Quit '..GetBooleanValue()
}

/// Negate this boolean value
/// 
/// @return New BooleanExpression with negated value
Method Negate() As BooleanExpression
{
    Set tNewValue = "false"
    If ..IsFalse() {
        Set tNewValue = "true"
    }
    Quit ##class(BooleanExpression).%New(tNewValue)
}

/// Convert to numeric representation
/// 
/// @return 1 for true, 0 for false
Method ToNumber() As %Numeric
{
    Quit ..GetBooleanValue()
}

/// ===== CLASS METHODS =====
/// Create a TRUE boolean expression
/// 
/// @return BooleanExpression
ClassMethod True() As BooleanExpression
{
    Quit ##class(BooleanExpression).%New("true")
}

/// Create a FALSE boolean expression
/// 
/// @return BooleanExpression
ClassMethod False() As BooleanExpression
{
    Quit ##class(BooleanExpression).%New("false")
}

/// Create a boolean expression from a numeric value
/// 
/// @param pNumber The numeric value (0 = false, non-zero = true)
/// @return BooleanExpression
ClassMethod FromNumber(pNumber As %Numeric) As BooleanExpression
{
    If pNumber = 0 {
        Quit ##class(BooleanExpression).%New("false")
    }
    Quit ##class(BooleanExpression).%New("true")
}

/// ===== CONSTRUCTORS =====
/// Initialize with a boolean value
/// 
/// @param pValue The boolean value as string ("true", "false", "1", "0")
Method %OnNew(pValue As %String = "") As %Status
{
    // Default to false if no value provided
    If pValue = "" {
        Set pValue = "false"
    }
    
    // Call parent constructor
    Set tSC = ##super(pValue)
    If $$$ISERR(tSC) Quit tSC
    
    // Set data type
    Set ..DataType = "Boolean"
    
    // Validate the boolean
    Set tSC = ..ValidateValue()
    
    Quit tSC
}

}
