/// Gang of Four Interpreter Pattern - Constant Expression Evaluator
/// <p>Terminal expression for predefined constants.</p>
Class Patterns.GoF.Behavioral.ConstantExpression Extends Patterns.GoF.Behavioral.TerminalExpression
{

/// Constant name
Property Name As %String;

/// Predefined constants
Parameter PI = 3.14159265359;

Parameter E = 2.71828182846;

Parameter TRUE = 1;

Parameter FALSE = 0;

/// Constructor
Method %OnNew(pName As %String) As %Status
{
    Set ..Name = $ZCONVERT(pName, "U")
    Quit $$$OK
}

/// Interpret the constant expression
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    Set tResult = ""
    
    // Evaluate based on constant name
    If ..Name = "PI" {
        Set tResult = ..#PI
    } ElseIf ..Name = "E" {
        Set tResult = ..#E
    } ElseIf ..Name = "TRUE" {
        Set tResult = ..#TRUE
    } ElseIf ..Name = "FALSE" {
        Set tResult = ..#FALSE
    } ElseIf ..Name = "NULL" {
        Set tResult = ""
    } Else {
        // Check if it's a user-defined constant in context
        If $IsObject(pContext) && pContext.HasConstant(..Name) {
            Set tResult = pContext.GetConstant(..Name)
        } Else {
            Set tResult = ""
        }
    }
    
    // Add debug info if context has debug mode
    If $IsObject(pContext) && pContext.DebugMode {
        Do pContext.AddDebugInfo("Constant "_..Name_": "_tResult)
    }
    
    Quit tResult
}

/// Get string representation
Method ToString() As %String
{
    Quit ..Name
}

/// Factory method for creating constant expressions
ClassMethod Create(pName As %String) As ConstantExpression
{
    Quit ##class(ConstantExpression).%New(pName)
}

}
