/// Gang of Four Interpreter Pattern - Terminal Expression Base Class
/// 
/// Intent:
/// Base class for terminal expressions (leaf nodes) in the expression tree.
/// Terminal expressions represent atomic values that cannot be further decomposed.
/// 
/// Structure:
/// <example>
/// Set numExpr = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("42")
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Set result = numExpr.Interpret(context)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Expression
/// @see Patterns.GoF.Behavioral.NonTerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.TerminalExpression Extends Patterns.GoF.Behavioral.Expression [ Abstract ]
{

/// ===== PARAMETERS =====
Parameter ISTERMINAL = 1;

/// ===== PROPERTIES =====
/// The raw value of this terminal expression
Property Value As %String;

/// The data type of this terminal expression
Property DataType As %String;

/// ===== PUBLIC METHODS =====
/// Checks if this is a terminal expression
/// 
/// @return %Boolean always returns 1 for terminal expressions
Method IsTerminal() As %Boolean
{
    Quit 1
}

/// Checks if this is a non-terminal expression
/// 
/// @return %Boolean always returns 0 for terminal expressions
Method IsNonTerminal() As %Boolean
{
    Quit 0
}

/// Gets the value of this terminal expression
/// 
/// @return The value as a string
Method GetValue() As %String
{
    Quit ..Value
}

/// Sets the value of this terminal expression
/// 
/// @param pValue The value to set
/// @return %Status
Method SetValue(pValue As %String) As %Status
{
    Set ..Value = pValue
    Quit $$$OK
}

/// Gets the data type of this terminal expression
/// 
/// @return The data type as a string
Method GetDataType() As %String
{
    Quit ..DataType
}

/// Validates that the value is appropriate for this terminal type
/// 
/// @return %Status
Method ValidateValue() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Base validation for terminal expressions
/// 
/// @return %Status
Method Validate() As %Status
{
    // First validate the value itself
    Set tSC = ..ValidateValue()
    If $$$ISERR(tSC) {
        Quit tSC
    }
    
    // Check that we have a value
    If ..Value = "" {
        Quit $$$ERROR($$$GeneralError, "Terminal expression has no value")
    }
    
    Quit $$$OK
}

/// Convert value to a specific type
/// 
/// @param pType The target type (Number, Boolean, String)
/// @return The converted value
Method ConvertTo(pType As %String) As %String
{
    If pType = "Number" {
        // Try to convert to number
        If ..Value'="" && ($ISVALIDNUM(..Value)) {
            Quit +..Value
        }
        Quit 0
    }
    ElseIf pType = "Boolean" {
        // Convert to boolean
        If ..Value = "true" || ..Value = 1 {
            Quit 1
        }
        ElseIf ..Value = "false" || ..Value = 0 || ..Value = "" {
            Quit 0
        }
        // Non-empty string is true
        Quit 1
    }
    Else {
        // Default to string
        Quit ..Value
    }
}

/// Check if value can be converted to number
/// 
/// @return %Boolean
Method IsNumeric() As %Boolean
{
    Quit $ISVALIDNUM(..Value)
}

/// Check if value represents boolean
/// 
/// @return %Boolean
Method IsBoolean() As %Boolean
{
    Set tLower = $ZCONVERT(..Value, "L")
    Quit (tLower = "true") || (tLower = "false") || (..Value = "0") || (..Value = "1")
}

/// ===== CONSTRUCTORS =====
/// Initialize terminal expression with optional value
/// 
/// @param pValue Optional initial value
Method %OnNew(pValue As %String = "") As %Status
{
    // Call parent constructor
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Set value if provided
    If pValue '= "" {
        Set ..Value = pValue
    }
    
    // Set default data type
    Set ..DataType = "String"
    
    Quit $$$OK
}

}
