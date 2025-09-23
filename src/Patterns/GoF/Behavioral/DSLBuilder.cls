/// Gang of Four Interpreter Pattern - DSL Builder
/// 
/// Intent:
/// Fluent interface for building expression trees programmatically.
/// Simplifies creation of complex expressions without manual tree construction.
/// 
/// Structure:
/// <example>
/// Set builder = ##class(Patterns.GoF.Behavioral.DSLBuilder).%New()
/// Set expr = builder.Number(10).Add().Number(20).Multiply().Number(2).Build()
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Set result = expr.Interpret(context)  // Returns "50"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Expression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.DSLBuilder Extends %RegisteredObject
{

/// ===== PROPERTIES =====
/// Stack of expressions being built
Property ExpressionStack As %ListOfObjects;

/// Stack of pending operators
Property OperatorStack As %ListOfDataTypes;

/// Current expression being built
Property CurrentExpression As Patterns.GoF.Behavioral.Expression;

/// ===== PUBLIC BUILDER METHODS =====
/// Add a number to the expression
/// 
/// @param pValue The numeric value
/// @return This builder for chaining
Method Number(pValue As %Numeric) As Patterns.GoF.Behavioral.DSLBuilder
{
    Set tExpr = ##class(Patterns.GoF.Behavioral.NumberExpression).%New(pValue)
    Do ..AddExpression(tExpr)
    Quit $THIS
}

/// Add a variable reference to the expression
/// 
/// @param pName The variable name
/// @return This builder for chaining
Method Variable(pName As %String) As Patterns.GoF.Behavioral.DSLBuilder
{
    Set tExpr = ##class(Patterns.GoF.Behavioral.VariableExpression).%New(pName)
    Do ..AddExpression(tExpr)
    Quit $THIS
}

/// Add a boolean value to the expression
/// 
/// @param pValue The boolean value
/// @return This builder for chaining
Method Boolean(pValue As %String) As Patterns.GoF.Behavioral.DSLBuilder
{
    Set tExpr = ##class(Patterns.GoF.Behavioral.BooleanExpression).%New(pValue)
    Do ..AddExpression(tExpr)
    Quit $THIS
}

/// Add addition operator
/// 
/// @return This builder for chaining
Method Add() As Patterns.GoF.Behavioral.DSLBuilder
{
    Do ..AddOperator("+")
    Quit $THIS
}

/// Add subtraction operator
/// 
/// @return This builder for chaining
Method Subtract() As Patterns.GoF.Behavioral.DSLBuilder
{
    Do ..AddOperator("-")
    Quit $THIS
}

/// Add multiplication operator
/// 
/// @return This builder for chaining
Method Multiply() As Patterns.GoF.Behavioral.DSLBuilder
{
    Do ..AddOperator("*")
    Quit $THIS
}

/// Add division operator
/// 
/// @return This builder for chaining
Method Divide() As Patterns.GoF.Behavioral.DSLBuilder
{
    Do ..AddOperator("/")
    Quit $THIS
}

/// Start a grouped expression
/// 
/// @return This builder for chaining
Method OpenParen() As Patterns.GoF.Behavioral.DSLBuilder
{
    Do ..AddOperator("(")
    Quit $THIS
}

/// End a grouped expression
/// 
/// @return This builder for chaining
Method CloseParen() As Patterns.GoF.Behavioral.DSLBuilder
{
    Do ..ProcessUntilOpenParen()
    Quit $THIS
}

/// Build the final expression
/// 
/// @return The constructed expression tree
Method Build() As Patterns.GoF.Behavioral.Expression
{
    // Process remaining operators
    While ..OperatorStack.Count() > 0 {
        Do ..ProcessOperator()
    }
    
    // Return the final expression
    If ..ExpressionStack.Count() > 0 {
        Quit ..ExpressionStack.GetAt(1)
    }
    
    Quit ..CurrentExpression
}

/// ===== PRIVATE HELPER METHODS =====
/// Add an expression to the stack
Method AddExpression(pExpression As Patterns.GoF.Behavioral.Expression) [ Private ]
{
    Do ..ExpressionStack.Insert(pExpression)
}

/// Add an operator to process
Method AddOperator(pOperator As %String) [ Private ]
{
    If pOperator = "(" {
        Do ..OperatorStack.Insert(pOperator)
        Quit
    }
    
    // Process operators with higher or equal precedence
    While (..OperatorStack.Count() > 0) && ..ShouldProcess(pOperator) {
        Do ..ProcessOperator()
    }
    
    Do ..OperatorStack.Insert(pOperator)
}

/// Check if we should process the operator on stack
Method ShouldProcess(pNewOp As %String) As %Boolean [ Private ]
{
    If ..OperatorStack.Count() = 0 Quit 0
    
    Set tTopOp = ..OperatorStack.GetAt(..OperatorStack.Count())
    If tTopOp = "(" Quit 0
    
    Set tTopPrec = ..GetPrecedence(tTopOp)
    Set tNewPrec = ..GetPrecedence(pNewOp)
    
    Quit tTopPrec >= tNewPrec
}

/// Get operator precedence
Method GetPrecedence(pOperator As %String) As %Integer [ Private ]
{
    If (pOperator = "*") || (pOperator = "/") Quit 2
    If (pOperator = "+") || (pOperator = "-") Quit 1
    Quit 0
}

/// Process one operator from the stack
Method ProcessOperator() [ Private ]
{
    If ..OperatorStack.Count() = 0 Quit
    If ..ExpressionStack.Count() < 2 Quit
    
    Set tOp = ..OperatorStack.GetAt(..OperatorStack.Count())
    Do ..OperatorStack.RemoveAt(..OperatorStack.Count())
    
    Set tRight = ..ExpressionStack.GetAt(..ExpressionStack.Count())
    Do ..ExpressionStack.RemoveAt(..ExpressionStack.Count())
    
    Set tLeft = ..ExpressionStack.GetAt(..ExpressionStack.Count())
    Do ..ExpressionStack.RemoveAt(..ExpressionStack.Count())
    
    Set tExpr = ""
    If tOp = "+" {
        Set tExpr = ##class(Patterns.GoF.Behavioral.AddExpression).%New(tLeft, tRight)
    } ElseIf tOp = "-" {
        Set tExpr = ##class(Patterns.GoF.Behavioral.SubtractExpression).%New(tLeft, tRight)
    } ElseIf tOp = "*" {
        Set tExpr = ##class(Patterns.GoF.Behavioral.MultiplyExpression).%New(tLeft, tRight)
    } ElseIf tOp = "/" {
        Set tExpr = ##class(Patterns.GoF.Behavioral.DivideExpression).%New(tLeft, tRight)
    }
    
    If $ISOBJECT(tExpr) {
        Do ..ExpressionStack.Insert(tExpr)
    }
}

/// Process operators until open parenthesis
Method ProcessUntilOpenParen() [ Private ]
{
    While ..OperatorStack.Count() > 0 {
        Set tOp = ..OperatorStack.GetAt(..OperatorStack.Count())
        If tOp = "(" {
            Do ..OperatorStack.RemoveAt(..OperatorStack.Count())
            Quit
        }
        Do ..ProcessOperator()
    }
}

/// ===== CLASS METHODS =====
/// Create a new builder instance
/// 
/// @return New DSLBuilder instance
ClassMethod Create() As Patterns.GoF.Behavioral.DSLBuilder
{
    Quit ..%New()
}

/// Quick expression builder
/// 
/// @param pExpression String expression to parse
/// @return Expression tree
ClassMethod Expression(pExpression As %String) As Patterns.GoF.Behavioral.Expression
{
    Set tParser = ##class(Patterns.GoF.Behavioral.ExpressionParser).%New()
    Quit tParser.Parse(pExpression)
}

/// ===== CONSTRUCTORS =====
/// Initialize the builder
Method %OnNew() As %Status
{
    Set ..ExpressionStack = ##class(%ListOfObjects).%New()
    Set ..OperatorStack = ##class(%ListOfDataTypes).%New()
    Quit $$$OK
}

}
