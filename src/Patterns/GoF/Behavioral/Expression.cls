/// Gang of Four Interpreter Pattern - Abstract Expression Base Class
/// 
/// Intent:
/// Defines an abstract representation of a grammar expression that can be interpreted.
/// Forms the basis of an expression tree structure for language interpretation.
/// 
/// Participants:
/// - Expression (this class) - declares abstract Interpret operation
/// - TerminalExpression - implements Interpret for terminal symbols
/// - NonTerminalExpression - implements Interpret for grammar rules
/// - Context - contains interpreter state and global information
/// 
/// Structure:
/// <example>
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Do context.SetVariable("x", 10)
/// Set expr = ##class(Patterns.GoF.Behavioral.VariableExpression).%New("x")
/// Set result = expr.Interpret(context)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Context
/// @see Patterns.GoF.Behavioral.TerminalExpression
/// @see Patterns.GoF.Behavioral.NonTerminalExpression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Expression Extends %RegisteredObject [ Abstract ]
{

/// ===== PARAMETERS =====
Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Behavioral";

Parameter PATTERNNAME = "Interpreter";

/// ===== PROPERTIES =====
/// Unique identifier for this expression node
Property NodeId As %String;

/// Parent expression in the tree (if any)
Property ParentExpression As Expression;

/// Expression type identifier for debugging
Property ExpressionType As %String;

/// ===== ABSTRACT METHODS =====
/// Interprets the expression in the given context
/// 
/// @param pContext The context containing variables and state
/// @return The result of interpreting this expression
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String [ Abstract ]
{
    Quit ""
}

/// Returns a string representation of this expression
/// 
/// @return String representation of the expression
Method ToString() As %String [ Abstract ]
{
    Quit ""
}

/// Validates the expression structure
/// 
/// @return %Status indicating if the expression is valid
Method Validate() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// ===== PUBLIC METHODS =====
/// Evaluates this expression and returns the result
/// 
/// @param pContext The evaluation context
/// @return The evaluated result as a string
Method Evaluate(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Validate before interpreting
    Set tSC = ..Validate()
    If $$$ISERR(tSC) {
        Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
    }
    
    // Delegate to concrete implementation
    Quit ..Interpret(pContext)
}

/// Gets the depth of this expression in the tree
/// 
/// @return The depth level (0 for root)
Method GetDepth() As %Integer
{
    Set tDepth = 0
    Set tParent = ..ParentExpression
    
    While $ISOBJECT(tParent) {
        Set tDepth = tDepth + 1
        Set tParent = tParent.ParentExpression
    }
    
    Quit tDepth
}

/// Checks if this is a terminal expression (leaf node)
/// 
/// @return %Boolean indicating if this is a terminal expression
Method IsTerminal() As %Boolean
{
    // Default implementation - override in subclasses
    Quit 0
}

/// Checks if this is a non-terminal expression (composite node)
/// 
/// @return %Boolean indicating if this is a non-terminal expression
Method IsNonTerminal() As %Boolean
{
    // Default implementation - override in subclasses
    Quit 0
}

/// ===== PROTECTED METHODS =====
/// Sets the parent expression for tree traversal
/// 
/// @param pParent The parent expression node
/// @return %Status
Method SetParent(pParent As Expression) As %Status [ Internal ]
{
    Set ..ParentExpression = pParent
    Quit $$$OK
}

/// ===== CONSTRUCTORS =====
/// Initialize the expression
Method %OnNew() As %Status
{
    Set ..NodeId = $SYSTEM.Util.CreateGUID()
    Set ..ExpressionType = ..%ClassName(0)
    Quit $$$OK
}

}
