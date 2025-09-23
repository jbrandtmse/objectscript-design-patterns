/// Gang of Four Interpreter Pattern - Conditional Expression (Non-Terminal)
/// 
/// Intent:
/// Non-terminal expression for conditional evaluation (IF-THEN-ELSE).
/// Evaluates condition and returns result of then or else branch.
/// 
/// Structure:
/// <example>
/// Set condition = ##class(ComparisonExpression).%New(x, ">", zero)
/// Set thenExpr = ##class(NumberExpression).%New("positive")
/// Set elseExpr = ##class(NumberExpression).%New("negative")
/// Set expr = ##class(ConditionalExpression).%New(condition, thenExpr, elseExpr)
/// Set result = expr.Interpret(context)  // IF x > 0 THEN "positive" ELSE "negative"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Expression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ConditionalExpression Extends Patterns.GoF.Behavioral.Expression
{

/// ===== PROPERTIES =====
/// Condition expression
Property Condition As Patterns.GoF.Behavioral.Expression;

/// Then branch expression
Property ThenExpression As Patterns.GoF.Behavioral.Expression;

/// Else branch expression
Property ElseExpression As Patterns.GoF.Behavioral.Expression;

/// ===== METHODS =====
/// Interpret this conditional expression
/// 
/// @param pContext The evaluation context
/// @return Result from then or else branch
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Evaluate condition
    Set tCondResult = ..Condition.Interpret(pContext)
    
    // Convert to boolean
    Set tIsTrue = ..ToBoolean(tCondResult)
    
    // Execute appropriate branch
    If tIsTrue {
        If $ISOBJECT(..ThenExpression) {
            Quit ..ThenExpression.Interpret(pContext)
        }
    } Else {
        If $ISOBJECT(..ElseExpression) {
            Quit ..ElseExpression.Interpret(pContext)
        }
    }
    
    Quit ""
}

/// Convert value to boolean
/// 
/// @param pValue Value to convert
/// @return Boolean (1 or 0)
Method ToBoolean(pValue As %String) As %Boolean [ Private ]
{
    If pValue = "true" Quit 1
    If pValue = "false" Quit 0
    If pValue = "" Quit 0
    If pValue = "0" Quit 0
    Quit 1
}

/// Get string representation
/// 
/// @return String representation
Method ToString() As %String
{
    Set tCond = ""
    Set tThen = ""
    Set tElse = ""
    
    If $ISOBJECT(..Condition) {
        Set tCond = ..Condition.ToString()
    }
    If $ISOBJECT(..ThenExpression) {
        Set tThen = ..ThenExpression.ToString()
    }
    If $ISOBJECT(..ElseExpression) {
        Set tElse = ..ElseExpression.ToString()
    }
    
    Quit "IF " _ tCond _ " THEN " _ tThen _ " ELSE " _ tElse
}

/// Validate the conditional expression
/// 
/// @return %Status
Method Validate() As %Status
{
    If '$ISOBJECT(..Condition) {
        Quit $$$ERROR($$$GeneralError, "Conditional expression requires condition")
    }
    
    If '$ISOBJECT(..ThenExpression) {
        Quit $$$ERROR($$$GeneralError, "Conditional expression requires then branch")
    }
    
    // Else branch is optional
    
    Quit $$$OK
}

/// ===== CONSTRUCTORS =====
/// Create conditional expression
/// 
/// @param pCondition Condition to evaluate
/// @param pThen Expression for true condition
/// @param pElse Expression for false condition (optional)
Method %OnNew(pCondition As Patterns.GoF.Behavioral.Expression = "", pThen As Patterns.GoF.Behavioral.Expression = "", pElse As Patterns.GoF.Behavioral.Expression = "") As %Status
{
    Set ..Condition = pCondition
    Set ..ThenExpression = pThen
    Set ..ElseExpression = pElse
    Quit $$$OK
}

}
