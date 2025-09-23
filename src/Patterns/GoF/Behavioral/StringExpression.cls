/// Gang of Four Interpreter Pattern - String Literal Expression
/// <p>Terminal expression for string literal values.</p>
Class Patterns.GoF.Behavioral.StringExpression Extends Patterns.GoF.Behavioral.TerminalExpression
{

/// String value
Property Value As %String;

/// Constructor
Method %OnNew(pValue As %String) As %Status
{
    Set ..Value = pValue
    Quit $$$OK
}

/// Interpret the string expression
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    // Add debug info if context has debug mode
    If $IsObject(pContext) && pContext.DebugMode {
        Do pContext.AddDebugInfo("String: """_..Value_"""")
    }
    Quit ..Value
}

/// Get string representation
Method ToString() As %String
{
    Quit """"_..Value_""""
}

/// Factory method for creating string expressions
ClassMethod Create(pValue As %String) As StringExpression
{
    Quit ##class(StringExpression).%New(pValue)
}

}
