/// Gang of Four Interpreter Pattern - Variable Expression (Terminal)
/// 
/// Intent:
/// Terminal expression that represents variable references in the expression language.
/// Retrieves values from the context based on variable names.
/// 
/// Structure:
/// <example>
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Do context.SetVariable("x", "100")
/// Set varExpr = ##class(Patterns.GoF.Behavioral.VariableExpression).%New("x")
/// Set result = varExpr.Interpret(context)  // Returns "100"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.TerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.VariableExpression Extends Patterns.GoF.Behavioral.TerminalExpression
{

/// ===== PROPERTIES =====
/// The variable name to lookup in context
Property VariableName As %String;

/// ===== METHODS =====
/// Interprets this variable expression by looking up value in context
/// 
/// @param pContext The evaluation context containing variables
/// @return The variable value from context
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Push to evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PushEvaluation("VariableExpression: " _ ..VariableName)
    }
    
    // Look up variable in context
    If 'pContext.HasVariable(..VariableName) {
        // Variable not found - could return empty or throw error
        If pContext.DebugMode {
            Do pContext.PopEvaluation()
            Do pContext.AddDebugInfo("Variable not found: " _ ..VariableName)
        }
        Quit ""
    }
    
    Set tResult = pContext.GetVariable(..VariableName)
    
    // Pop from evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PopEvaluation()
        Do pContext.AddDebugInfo("Variable " _ ..VariableName _ " = " _ tResult)
    }
    
    Quit tResult
}

/// Returns string representation of this variable reference
/// 
/// @return String representation
Method ToString() As %String
{
    Quit "$" _ ..VariableName
}

/// Validates that the variable name is valid
/// 
/// @return %Status
Method ValidateValue() As %Status
{
    // Check if variable name is valid
    If ..VariableName = "" {
        Quit $$$ERROR($$$GeneralError, "Variable expression has empty variable name")
    }
    
    // Check for valid variable name format (alphanumeric and underscore)
    Set tValid = 1
    For i=1:1:$LENGTH(..VariableName) {
        Set tChar = $EXTRACT(..VariableName, i)
        If '((tChar?1A) || (tChar?1N) || (tChar = "_")) {
            Set tValid = 0
            Quit
        }
    }
    
    If 'tValid {
        Quit $$$ERROR($$$GeneralError, "Invalid variable name format: " _ ..VariableName)
    }
    
    // Check that first character is not a digit
    If $EXTRACT(..VariableName, 1)?1N {
        Quit $$$ERROR($$$GeneralError, "Variable name cannot start with digit: " _ ..VariableName)
    }
    
    Quit $$$OK
}

/// Get the variable name
/// 
/// @return The variable name
Method GetVariableName() As %String
{
    Quit ..VariableName
}

/// Set the variable name
/// 
/// @param pName The variable name
/// @return %Status
Method SetVariableName(pName As %String) As %Status
{
    Set ..VariableName = pName
    Set ..Value = pName  // Store in base Value property too
    Quit ..ValidateValue()
}

/// Check if this variable exists in the given context
/// 
/// @param pContext The context to check
/// @return %Boolean
Method ExistsInContext(pContext As Patterns.GoF.Behavioral.Context) As %Boolean
{
    Quit pContext.HasVariable(..VariableName)
}

/// Get the variable value from context
/// 
/// @param pContext The context containing variables
/// @return The variable value or empty string
Method GetValueFromContext(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    If pContext.HasVariable(..VariableName) {
        Quit pContext.GetVariable(..VariableName)
    }
    Quit ""
}

/// ===== CONSTRUCTORS =====
/// Initialize with a variable name
/// 
/// @param pVariableName The name of the variable
Method %OnNew(pVariableName As %String = "") As %Status
{
    // Call parent constructor
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Set data type
    Set ..DataType = "Variable"
    
    // Set variable name
    If pVariableName '= "" {
        Set ..VariableName = pVariableName
        Set ..Value = pVariableName
        Set tSC = ..ValidateValue()
    }
    
    Quit tSC
}

}
