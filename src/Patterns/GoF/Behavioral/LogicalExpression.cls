/// Gang of Four Interpreter Pattern - Logical Expression (Non-Terminal)
/// 
/// Intent:
/// Non-terminal expression for logical operations (AND, OR, NOT).
/// Evaluates boolean expressions using logical operators.
/// 
/// Structure:
/// <example>
/// Set cond1 = ##class(ComparisonExpression).%New(x, ">", zero)
/// Set cond2 = ##class(ComparisonExpression).%New(x, "<", ten)
/// Set expr = ##class(LogicalExpression).%New(cond1, "AND", cond2)
/// Set result = expr.Interpret(context)  // x > 0 AND x < 10
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.NonTerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.LogicalExpression Extends Patterns.GoF.Behavioral.NonTerminalExpression
{

/// ===== PROPERTIES =====
/// Logical operator (AND, OR, NOT)
Property Operator As %String;

/// ===== METHODS =====
/// Interpret this logical expression
/// 
/// @param pContext The evaluation context
/// @return Boolean result as string ("true" or "false")
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Handle NOT operator (unary)
    If ..Operator = "NOT" {
        Set tLeft = ..LeftOperand.Interpret(pContext)
        Set tBool = ..ToBoolean(tLeft)
        If 'tBool {
            Quit "true"
        } Else {
            Quit "false"
        }
    }
    
    // Handle binary operators (AND, OR)
    Set tLeft = ..LeftOperand.Interpret(pContext)
    Set tRight = ..RightOperand.Interpret(pContext)
    
    Set tLeftBool = ..ToBoolean(tLeft)
    Set tRightBool = ..ToBoolean(tRight)
    
    Set tResult = 0
    If ..Operator = "AND" {
        Set tResult = (tLeftBool && tRightBool)
    } ElseIf ..Operator = "OR" {
        Set tResult = (tLeftBool || tRightBool)
    }
    
    If tResult {
        Quit "true"
    } Else {
        Quit "false"
    }
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
    If ..Operator = "NOT" {
        Set tLeft = ""
        If $ISOBJECT(..LeftOperand) {
            Set tLeft = ..LeftOperand.ToString()
        }
        Quit "(NOT " _ tLeft _ ")"
    }
    
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

/// Validate the logical expression
/// 
/// @return %Status
Method Validate() As %Status
{
    // Validate operator
    Set tValidOps = $LISTBUILD("AND", "OR", "NOT")
    If '$LISTFIND(tValidOps, ..Operator) {
        Quit $$$ERROR($$$GeneralError, "Invalid logical operator: " _ ..Operator)
    }
    
    // For NOT operator, only left operand is needed
    If ..Operator = "NOT" {
        If '$ISOBJECT(..LeftOperand) {
            Quit $$$ERROR($$$GeneralError, "NOT operator requires operand")
        }
        Quit $$$OK
    }
    
    // For AND/OR, both operands needed
    Quit ##super()
}

/// ===== CONSTRUCTORS =====
/// Create logical expression
/// 
/// @param pLeft Left operand (or single operand for NOT)
/// @param pRight Right operand (not used for NOT)
Method %OnNew(pLeft As Patterns.GoF.Behavioral.Expression = "", pRight As Patterns.GoF.Behavioral.Expression = "") As %Status
{
    // Call parent constructor
    Set tSC = ##super(pLeft, pRight)
    If $$$ISERR(tSC) Quit tSC
    
    // Default operator
    Set ..Operator = "AND"
    Quit $$$OK
}

/// Set the logical operator
/// 
/// @param pOperator Logical operator (AND, OR, NOT)
/// @return %Status
Method SetOperator(pOperator As %String) As %Status
{
    Set ..Operator = pOperator
    Quit $$$OK
}

/// ===== CLASS METHODS =====
/// Create AND expression
/// 
/// @param pLeft Left operand
/// @param pRight Right operand
/// @return LogicalExpression
ClassMethod And(pLeft As Patterns.GoF.Behavioral.Expression, pRight As Patterns.GoF.Behavioral.Expression) As LogicalExpression
{
    Set tExpr = ##class(LogicalExpression).%New(pLeft, pRight)
    Do tExpr.SetOperator("AND")
    Quit tExpr
}

/// Create OR expression
/// 
/// @param pLeft Left operand
/// @param pRight Right operand
/// @return LogicalExpression
ClassMethod Or(pLeft As Patterns.GoF.Behavioral.Expression, pRight As Patterns.GoF.Behavioral.Expression) As LogicalExpression
{
    Set tExpr = ##class(LogicalExpression).%New(pLeft, pRight)
    Do tExpr.SetOperator("OR")
    Quit tExpr
}

/// Create NOT expression
/// 
/// @param pExpr Expression to negate
/// @return LogicalExpression
ClassMethod Not(pExpr As Patterns.GoF.Behavioral.Expression) As LogicalExpression
{
    Set tExpr = ##class(LogicalExpression).%New(pExpr, "")
    Do tExpr.SetOperator("NOT")
    Quit tExpr
}

}
