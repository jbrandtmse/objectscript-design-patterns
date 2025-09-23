/// Gang of Four Interpreter Pattern - Number Expression (Terminal)
/// 
/// Intent:
/// Terminal expression that represents numeric literals in the expression language.
/// Handles integer and decimal number values.
/// 
/// Structure:
/// <example>
/// Set numExpr = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("42")
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Set result = numExpr.Interpret(context)  // Returns "42"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.TerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.NumberExpression Extends Patterns.GoF.Behavioral.TerminalExpression
{

/// ===== METHODS =====
/// Interprets this number expression
/// 
/// @param pContext The evaluation context
/// @return The numeric value as a string
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Push to evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PushEvaluation("NumberExpression: " _ ..Value)
    }
    
    // Return the numeric value
    Set tResult = ..Value
    
    // Pop from evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PopEvaluation()
        Do pContext.AddDebugInfo("NumberExpression result: " _ tResult)
    }
    
    Quit tResult
}

/// Returns string representation of this number
/// 
/// @return String representation
Method ToString() As %String
{
    Quit ..Value
}

/// Validates that the value is a valid number
/// 
/// @return %Status
Method ValidateValue() As %Status
{
    // Check if value is numeric
    If ..Value = "" {
        Quit $$$ERROR($$$GeneralError, "Number expression has empty value")
    }
    
    If '$ISVALIDNUM(..Value) {
        Quit $$$ERROR($$$GeneralError, "Invalid number format: " _ ..Value)
    }
    
    Quit $$$OK
}

/// Get the numeric value
/// 
/// @return The numeric value
Method GetNumericValue() As %Numeric
{
    If $ISVALIDNUM(..Value) {
        Quit +..Value
    }
    Quit 0
}

/// Check if this is an integer
/// 
/// @return %Boolean
Method IsInteger() As %Boolean
{
    If '$ISVALIDNUM(..Value) {
        Quit 0
    }
    
    Set tNum = +..Value
    Quit (tNum = $NUMBER(tNum, 0))
}

/// Check if this is a decimal
/// 
/// @return %Boolean
Method IsDecimal() As %Boolean
{
    If '$ISVALIDNUM(..Value) {
        Quit 0
    }
    
    Quit '..IsInteger()
}

/// Check if the number is positive
/// 
/// @return %Boolean
Method IsPositive() As %Boolean
{
    If $ISVALIDNUM(..Value) {
        Quit (+..Value > 0)
    }
    Quit 0
}

/// Check if the number is negative
/// 
/// @return %Boolean
Method IsNegative() As %Boolean
{
    If $ISVALIDNUM(..Value) {
        Quit (+..Value < 0)
    }
    Quit 0
}

/// Check if the number is zero
/// 
/// @return %Boolean
Method IsZero() As %Boolean
{
    If $ISVALIDNUM(..Value) {
        Quit (+..Value = 0)
    }
    Quit 0
}

/// ===== CONSTRUCTORS =====
/// Initialize with a numeric value
/// 
/// @param pValue The numeric value as string
Method %OnNew(pValue As %String = "") As %Status
{
    // Call parent constructor
    Set tSC = ##super(pValue)
    If $$$ISERR(tSC) Quit tSC
    
    // Set data type
    Set ..DataType = "Number"
    
    // Validate the number
    Set tSC = ..ValidateValue()
    
    Quit tSC
}

}
