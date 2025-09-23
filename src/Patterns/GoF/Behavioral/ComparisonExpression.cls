/// Gang of Four Interpreter Pattern - Comparison Expression (Non-Terminal)
/// 
/// Intent:
/// Non-terminal expression for comparison operations (>, <, =, >=, <=, !=).
/// Evaluates two expressions and returns boolean result.
/// 
/// Structure:
/// <example>
/// Set left = ##class(NumberExpression).%New("10")
/// Set right = ##class(NumberExpression).%New("20")
/// Set expr = ##class(ComparisonExpression).%New(left, "<", right)
/// Set result = expr.Interpret(context)  // Returns "true"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.NonTerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ComparisonExpression Extends Patterns.GoF.Behavioral.NonTerminalExpression
{

/// ===== PROPERTIES =====
/// Comparison operator
Property Operator As %String;

/// ===== METHODS =====
/// Interpret this comparison expression
/// 
/// @param pContext The evaluation context
/// @return Boolean result as string ("true" or "false")
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Evaluate operands
    Set tLeft = ..LeftOperand.Interpret(pContext)
    Set tRight = ..RightOperand.Interpret(pContext)
    
    // Convert to numbers if possible
    Set tLeftNum = +tLeft
    Set tRightNum = +tRight
    
    // Perform comparison based on operator
    Set tResult = 0
    If ..Operator = "=" {
        Set tResult = (tLeft = tRight)
    } ElseIf ..Operator = "!=" {
        Set tResult = (tLeft '= tRight)
    } ElseIf ..Operator = ">" {
        Set tResult = (tLeftNum > tRightNum)
    } ElseIf ..Operator = "<" {
        Set tResult = (tLeftNum < tRightNum)
    } ElseIf ..Operator = ">=" {
        Set tResult = (tLeftNum >= tRightNum)
    } ElseIf ..Operator = "<=" {
        Set tResult = (tLeftNum <= tRightNum)
    }
    
    // Return boolean as string
    If tResult {
        Quit "true"
    } Else {
        Quit "false"
    }
}

/// Get string representation
/// 
/// @return String representation
Method ToString() As %String
{
    Set tLeft = ""
    Set tRight = ""
    
    If $ISOBJECT(..LeftOperand) {
        Set tLeft = ..LeftOperand.ToString()
    }
    If $ISOBJECT(..RightOperand) {
        Set tRight = ..RightOperand.ToString()
    }
    
    Quit "(" _ tLeft _ " " _ ..Operator _ " " _ tRight _ ")"
}

/// Validate the comparison expression
/// 
/// @return %Status
Method Validate() As %Status
{
    // Validate operator
    Set tValidOps = $LISTBUILD("=", "!=", ">", "<", ">=", "<=")
    If '$LISTFIND(tValidOps, ..Operator) {
        Quit $$$ERROR($$$GeneralError, "Invalid comparison operator: " _ ..Operator)
    }
    
    // Call parent validation
    Quit ##super()
}

/// ===== CONSTRUCTORS =====
/// Create comparison expression with operator
/// 
/// @param pLeft Left operand
/// @param pRight Right operand  
Method %OnNew(pLeft As Patterns.GoF.Behavioral.Expression = "", pRight As Patterns.GoF.Behavioral.Expression = "") As %Status
{
    // Call parent constructor
    Set tSC = ##super(pLeft, pRight)
    If $$$ISERR(tSC) Quit tSC
    
    // Default operator
    Set ..Operator = "="
    Quit $$$OK
}

/// Set the comparison operator
/// 
/// @param pOperator Comparison operator
/// @return %Status
Method SetOperator(pOperator As %String) As %Status
{
    Set ..Operator = pOperator
    Quit $$$OK
}

/// ===== CLASS METHODS =====
/// Create comparison with operator
/// 
/// @param pLeft Left operand
/// @param pOperator Comparison operator
/// @param pRight Right operand
/// @return ComparisonExpression
ClassMethod CreateWithOperator(pLeft As Patterns.GoF.Behavioral.Expression, pOperator As %String, pRight As Patterns.GoF.Behavioral.Expression) As ComparisonExpression
{
    Set tExpr = ##class(ComparisonExpression).%New(pLeft, pRight)
    Do tExpr.SetOperator(pOperator)
    Quit tExpr
}

}
