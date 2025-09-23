/// Gang of Four Interpreter Pattern - Divide Expression (Non-Terminal)
/// 
/// Intent:
/// Non-terminal expression that performs division of two expressions.
/// Evaluates left and right operands and returns their quotient.
/// 
/// Structure:
/// <example>
/// Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("20")
/// Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("4")
/// Set divideExpr = ##class(Patterns.GoF.Behavioral.DivideExpression).%New(left, right)
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Set result = divideExpr.Interpret(context)  // Returns "5"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.NonTerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.DivideExpression Extends Patterns.GoF.Behavioral.NonTerminalExpression
{

/// ===== METHODS =====
/// Interprets this division expression
/// 
/// @param pContext The evaluation context
/// @return The quotient of left and right operands
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Push to evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PushEvaluation("DivideExpression")
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
    
    // Perform division
    Set tResult = ""
    
    // Check if both values are numeric
    If $ISVALIDNUM(tLeftResult) && $ISVALIDNUM(tRightResult) {
        // Check for division by zero
        If +tRightResult = 0 {
            Set tResult = "NaN"  // or could throw error
        } Else {
            Set tResult = +tLeftResult / +tRightResult
        }
    }
    Else {
        // Can't divide non-numeric values
        Set tResult = "NaN"
    }
    
    // Pop from evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PopEvaluation()
        Do pContext.AddDebugInfo("DivideExpression: " _ tLeftResult _ " / " _ tRightResult _ " = " _ tResult)
    }
    
    Quit tResult
}

/// Returns string representation of this division
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
    
    Quit "(" _ tLeft _ " / " _ tRight _ ")"
}

/// Validate that both operands are set
/// 
/// @return %Status
Method ValidateOperands() As %Status
{
    If '$ISOBJECT(..LeftOperand) {
        Quit $$$ERROR($$$GeneralError, "DivideExpression missing left operand")
    }
    
    If '$ISOBJECT(..RightOperand) {
        Quit $$$ERROR($$$GeneralError, "DivideExpression missing right operand")
    }
    
    Quit $$$OK
}

/// Get the operation symbol
/// 
/// @return "/"
Method GetOperationSymbol() As %String
{
    Quit "/"
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
    Set ..OperationType = "Divide"
    
    Quit $$$OK
}

}
