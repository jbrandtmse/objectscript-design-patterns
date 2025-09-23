/// Gang of Four Interpreter Pattern - Non-Terminal Expression Base Class
/// 
/// Intent:
/// Base class for non-terminal expressions (composite nodes) in the expression tree.
/// Non-terminal expressions contain and operate on other expressions.
/// 
/// Structure:
/// <example>
/// Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
/// Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("20")
/// Set addExpr = ##class(Patterns.GoF.Behavioral.AddExpression).%New(left, right)
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Set result = addExpr.Interpret(context)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Expression
/// @see Patterns.GoF.Behavioral.TerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.NonTerminalExpression Extends Patterns.GoF.Behavioral.Expression [ Abstract ]
{

/// ===== PARAMETERS =====
Parameter ISTERMINAL = 0;

/// ===== PROPERTIES =====
/// Left operand expression
Property LeftOperand As Expression;

/// Right operand expression
Property RightOperand As Expression;

/// Additional operands for n-ary operations
Property Operands As list Of Expression;

/// Operation type (Add, Subtract, And, Or, etc.)
Property OperationType As %String;

/// ===== PUBLIC METHODS =====
/// Checks if this is a terminal expression
/// 
/// @return %Boolean always returns 0 for non-terminal expressions
Method IsTerminal() As %Boolean
{
    Quit 0
}

/// Checks if this is a non-terminal expression
/// 
/// @return %Boolean always returns 1 for non-terminal expressions
Method IsNonTerminal() As %Boolean
{
    Quit 1
}

/// Gets the left operand
/// 
/// @return Expression or null
Method GetLeftOperand() As Expression
{
    Quit ..LeftOperand
}

/// Sets the left operand
/// 
/// @param pExpression The expression to set as left operand
/// @return %Status
Method SetLeftOperand(pExpression As Expression) As %Status
{
    Set ..LeftOperand = pExpression
    If $ISOBJECT(pExpression) {
        Do pExpression.SetParent($THIS)
    }
    Quit $$$OK
}

/// Gets the right operand
/// 
/// @return Expression or null
Method GetRightOperand() As Expression
{
    Quit ..RightOperand
}

/// Sets the right operand
/// 
/// @param pExpression The expression to set as right operand
/// @return %Status
Method SetRightOperand(pExpression As Expression) As %Status
{
    Set ..RightOperand = pExpression
    If $ISOBJECT(pExpression) {
        Do pExpression.SetParent($THIS)
    }
    Quit $$$OK
}

/// Adds an operand to the operands list
/// 
/// @param pExpression The expression to add
/// @return %Status
Method AddOperand(pExpression As Expression) As %Status
{
    Do ..Operands.Insert(pExpression)
    If $ISOBJECT(pExpression) {
        Do pExpression.SetParent($THIS)
    }
    Quit $$$OK
}

/// Gets all operands as a list
/// 
/// @return list Of Expression
Method GetOperands() As %ListOfObjects
{
    Quit ..Operands
}

/// Gets operand count
/// 
/// @return %Integer
Method GetOperandCount() As %Integer
{
    Set tCount = 0
    If $ISOBJECT(..LeftOperand) Set tCount = tCount + 1
    If $ISOBJECT(..RightOperand) Set tCount = tCount + 1
    Set tCount = tCount + ..Operands.Count()
    Quit tCount
}

/// Validate that operands are properly set
/// 
/// @return %Status
Method ValidateOperands() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Base validation for non-terminal expressions
/// 
/// @return %Status
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    // Validate operands are set correctly
    Set tSC = ..ValidateOperands()
    If $$$ISERR(tSC) {
        Quit tSC
    }
    
    // Validate left operand if present
    If $ISOBJECT(..LeftOperand) {
        Set tSC = ..LeftOperand.Validate()
        If $$$ISERR(tSC) {
            Quit $$$ERROR($$$GeneralError, "Left operand validation failed: " _ $SYSTEM.Status.GetErrorText(tSC))
        }
    }
    
    // Validate right operand if present
    If $ISOBJECT(..RightOperand) {
        Set tSC = ..RightOperand.Validate()
        If $$$ISERR(tSC) {
            Quit $$$ERROR($$$GeneralError, "Right operand validation failed: " _ $SYSTEM.Status.GetErrorText(tSC))
        }
    }
    
    // Validate additional operands
    Set tError = ""
    For i=1:1:..Operands.Count() {
        If tError = "" {
            Set tOperand = ..Operands.GetAt(i)
            If $ISOBJECT(tOperand) {
                Set tSC = tOperand.Validate()
                If $$$ISERR(tSC) {
                    Set tError = "Operand " _ i _ " validation failed: " _ $SYSTEM.Status.GetErrorText(tSC)
                }
            }
        }
    }
    
    If tError '= "" {
        Quit $$$ERROR($$$GeneralError, tError)
    }
    
    Quit $$$OK
}

/// Get all child expressions for tree traversal
/// 
/// @return %ListOfObjects containing all child expressions
Method GetChildren() As %ListOfObjects
{
    Set tChildren = ##class(%ListOfObjects).%New()
    
    If $ISOBJECT(..LeftOperand) {
        Do tChildren.Insert(..LeftOperand)
    }
    
    If $ISOBJECT(..RightOperand) {
        Do tChildren.Insert(..RightOperand)
    }
    
    For i=1:1:..Operands.Count() {
        Set tOperand = ..Operands.GetAt(i)
        If $ISOBJECT(tOperand) {
            Do tChildren.Insert(tOperand)
        }
    }
    
    Quit tChildren
}

/// Traverse expression tree with visitor callback
/// 
/// @param pVisitor Object with Visit method
/// @param pDepth Current depth in tree
/// @return %Status
Method Traverse(pVisitor As %RegisteredObject, pDepth As %Integer = 0) As %Status
{
    // Visit this node
    If $ISOBJECT(pVisitor) && ##class(%Dictionary.CompiledMethod).%ExistsId(pVisitor.%ClassName(1) _ "||Visit") {
        Do $METHOD(pVisitor, "Visit", $THIS, pDepth)
    }
    
    // Visit children
    Set tChildren = ..GetChildren()
    For i=1:1:tChildren.Count() {
        Set tChild = tChildren.GetAt(i)
        If $ISOBJECT(tChild) && tChild.%IsA("Patterns.GoF.Behavioral.NonTerminalExpression") {
            Do $METHOD(tChild, "Traverse", pVisitor, pDepth + 1)
        } ElseIf $ISOBJECT(tChild) {
            Do $METHOD(pVisitor, "Visit", tChild, pDepth + 1)
        }
    }
    
    Quit $$$OK
}

/// Get the operation symbol for string representation
/// 
/// @return %String
Method GetOperationSymbol() As %String [ Abstract ]
{
    Quit ""
}

/// ===== CONSTRUCTORS =====
/// Initialize non-terminal expression with optional operands
/// 
/// @param pLeft Optional left operand
/// @param pRight Optional right operand
Method %OnNew(pLeft As Expression = "", pRight As Expression = "") As %Status
{
    // Call parent constructor
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Initialize operands list
    Set ..Operands = ##class(%ListOfObjects).%New()
    
    // Set operands if provided
    If $ISOBJECT(pLeft) {
        Set tSC = ..SetLeftOperand(pLeft)
        If $$$ISERR(tSC) Quit tSC
    }
    
    If $ISOBJECT(pRight) {
        Set tSC = ..SetRightOperand(pRight)
        If $$$ISERR(tSC) Quit tSC
    }
    
    Quit $$$OK
}

}
