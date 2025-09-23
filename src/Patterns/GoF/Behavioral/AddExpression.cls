/// Gang of Four Interpreter Pattern - Add Expression (Non-Terminal)
/// 
/// Intent:
/// Non-terminal expression that performs addition of two expressions.
/// Evaluates left and right operands and returns their sum.
/// 
/// Structure:
/// <example>
/// Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
/// Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("20")
/// Set addExpr = ##class(Patterns.GoF.Behavioral.AddExpression).%New(left, right)
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Set result = addExpr.Interpret(context)  // Returns "30"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.NonTerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.AddExpression Extends Patterns.GoF.Behavioral.NonTerminalExpression
{

/// ===== METHODS =====
/// Interprets this addition expression
/// 
/// @param pContext The evaluation context
/// @return The sum of left and right operands
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Push to evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PushEvaluation("AddExpression")
    }
    
    // Evaluate left operand
    Set tLeftResult = ""
    If $ISOBJECT(..LeftOperand) {
        Set tLeftResult = ..LeftOperand.Interpret(pContext)
    }
    
    // Evaluate right operand
    Set tRightResult = ""
    If $ISOBJECT(..RightOperand) {
        Set tRightResult = ..RightOperand.Interpret(pContext)
    }
    
    // Perform addition
    Set tResult = ""
    
    // Check if both values are numeric
    If $ISVALIDNUM(tLeftResult) && $ISVALIDNUM(tRightResult) {
        Set tResult = +tLeftResult + +tRightResult
    }
    Else {
        // String concatenation if not numeric
        Set tResult = tLeftResult _ tRightResult
    }
    
    // Pop from evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PopEvaluation()
        Do pContext.AddDebugInfo("AddExpression: " _ tLeftResult _ " + " _ tRightResult _ " = " _ tResult)
    }
    
    Quit tResult
}

/// Returns string representation of this addition
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
    
    Quit "(" _ tLeft _ " + " _ tRight _ ")"
}

/// Validate that both operands are set
/// 
/// @return %Status
Method ValidateOperands() As %Status
{
    If '$ISOBJECT(..LeftOperand) {
        Quit $$$ERROR($$$GeneralError, "AddExpression missing left operand")
    }
    
    If '$ISOBJECT(..RightOperand) {
        Quit $$$ERROR($$$GeneralError, "AddExpression missing right operand")
    }
    
    Quit $$$OK
}

/// Get the operation symbol
/// 
/// @return "+"
Method GetOperationSymbol() As %String
{
    Quit "+"
}

/// ===== CONSTRUCTORS =====
/// Initialize with left and right operands
/// 
/// @param pLeft Left operand expression
/// @param pRight Right operand expression
Method %OnNew(pLeft As Expression = "", pRight As Expression = "") As %Status
{
    // Call parent constructor
    Set tSC = ##super(pLeft, pRight)
    If $$$ISERR(tSC) Quit tSC
    
    // Set operation type
    Set ..OperationType = "Add"
    
    Quit $$$OK
}

}
