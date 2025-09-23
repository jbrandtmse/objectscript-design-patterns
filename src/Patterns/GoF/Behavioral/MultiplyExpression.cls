/// Gang of Four Interpreter Pattern - Multiply Expression (Non-Terminal)
/// 
/// Intent:
/// Non-terminal expression that performs multiplication of two expressions.
/// Evaluates left and right operands and returns their product.
/// 
/// Structure:
/// <example>
/// Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("5")
/// Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("4")
/// Set multiplyExpr = ##class(Patterns.GoF.Behavioral.MultiplyExpression).%New(left, right)
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Set result = multiplyExpr.Interpret(context)  // Returns "20"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.NonTerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.MultiplyExpression Extends Patterns.GoF.Behavioral.NonTerminalExpression
{

/// ===== METHODS =====
/// Interprets this multiplication expression
/// 
/// @param pContext The evaluation context
/// @return The product of left and right operands
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Push to evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PushEvaluation("MultiplyExpression")
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
    
    // Perform multiplication
    Set tResult = ""
    
    // Check if both values are numeric
    If $ISVALIDNUM(tLeftResult) && $ISVALIDNUM(tRightResult) {
        Set tResult = +tLeftResult * +tRightResult
    }
    Else {
        // Can't multiply non-numeric values
        Set tResult = "NaN"
    }
    
    // Pop from evaluation stack if debugging
    If pContext.DebugMode {
        Do pContext.PopEvaluation()
        Do pContext.AddDebugInfo("MultiplyExpression: " _ tLeftResult _ " * " _ tRightResult _ " = " _ tResult)
    }
    
    Quit tResult
}

/// Returns string representation of this multiplication
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
    
    Quit "(" _ tLeft _ " * " _ tRight _ ")"
}

/// Validate that both operands are set
/// 
/// @return %Status
Method ValidateOperands() As %Status
{
    If '$ISOBJECT(..LeftOperand) {
        Quit $$$ERROR($$$GeneralError, "MultiplyExpression missing left operand")
    }
    
    If '$ISOBJECT(..RightOperand) {
        Quit $$$ERROR($$$GeneralError, "MultiplyExpression missing right operand")
    }
    
    Quit $$$OK
}

/// Get the operation symbol
/// 
/// @return "*"
Method GetOperationSymbol() As %String
{
    Quit "*"
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
    Set ..OperationType = "Multiply"
    
    Quit $$$OK
}

}
