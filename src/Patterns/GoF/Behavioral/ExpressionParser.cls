/// Gang of Four Interpreter Pattern - Expression Parser
/// 
/// Intent:
/// Simple recursive descent parser that converts string expressions into
/// expression trees that can be interpreted by the Interpreter pattern.
/// 
/// Structure:
/// <example>
/// Set parser = ##class(Patterns.GoF.Behavioral.ExpressionParser).%New()
/// Set expr = parser.Parse("10 + 20 * 3")
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Set result = expr.Interpret(context)  // Returns "70"
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Expression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ExpressionParser Extends %RegisteredObject
{

/// ===== PROPERTIES =====
/// The input expression string
Property Input As %String;

/// Current position in the input
Property Position As %Integer;

/// Current character
Property CurrentChar As %String;

/// ===== PUBLIC METHODS =====
/// Parse an expression string and return the expression tree
/// 
/// @param pExpression The expression string to parse
/// @return Expression tree or empty string on error
Method Parse(pExpression As %String) As Patterns.GoF.Behavioral.Expression
{
    Set ..Input = pExpression
    Set ..Position = 1
    Set ..CurrentChar = $EXTRACT(..Input, ..Position)
    
    Set tExpression = ""
    Try {
        Set tExpression = ..ParseExpression()
    } Catch ex {
        // Log error and return empty
        Set ^ClineDebug = ^ClineDebug _ "Parse error: " _ ex.DisplayString() _ "; "
        Set tExpression = ""
    }
    Quit tExpression
}

/// ===== PRIVATE PARSING METHODS =====
/// Parse expression (handles + and -)
Method ParseExpression() As Patterns.GoF.Behavioral.Expression [ Private ]
{
    Set tLeft = ..ParseTerm()
    
    While (..CurrentChar = "+") || (..CurrentChar = "-") {
        Set tOp = ..CurrentChar
        Do ..Advance()
        Set tRight = ..ParseTerm()
        
        If tOp = "+" {
            Set tLeft = ##class(Patterns.GoF.Behavioral.AddExpression).%New(tLeft, tRight)
        } Else {
            Set tLeft = ##class(Patterns.GoF.Behavioral.SubtractExpression).%New(tLeft, tRight)
        }
    }
    
    Quit tLeft
}

/// Parse term (handles * and /)
Method ParseTerm() As Patterns.GoF.Behavioral.Expression [ Private ]
{
    Set tLeft = ..ParseFactor()
    
    While (..CurrentChar = "*") || (..CurrentChar = "/") {
        Set tOp = ..CurrentChar
        Do ..Advance()
        Set tRight = ..ParseFactor()
        
        If tOp = "*" {
            Set tLeft = ##class(Patterns.GoF.Behavioral.MultiplyExpression).%New(tLeft, tRight)
        } Else {
            Set tLeft = ##class(Patterns.GoF.Behavioral.DivideExpression).%New(tLeft, tRight)
        }
    }
    
    Quit tLeft
}

/// Parse factor (numbers, variables, parentheses)
Method ParseFactor() As Patterns.GoF.Behavioral.Expression [ Private ]
{
    Do ..SkipWhitespace()
    
    // Handle parentheses
    If ..CurrentChar = "(" {
        Do ..Advance()
        Set tExpr = ..ParseExpression()
        Do ..Expect(")")
        Quit tExpr
    }
    
    // Handle numbers
    If ..IsDigit(..CurrentChar) {
        Quit ..ParseNumber()
    }
    
    // Handle variables
    If ..IsLetter(..CurrentChar) {
        Quit ..ParseVariable()
    }
    
    // Handle boolean values
    If ..StartsWith("true") || ..StartsWith("false") {
        Quit ..ParseBoolean()
    }
    
    Throw ##class(%Exception.General).%New("Unexpected character: " _ ..CurrentChar)
}

/// Parse a number
Method ParseNumber() As Patterns.GoF.Behavioral.NumberExpression [ Private ]
{
    Set tStart = ..Position
    Set tHasDecimal = 0
    
    While ..IsDigit(..CurrentChar) || ((..CurrentChar = ".") && 'tHasDecimal) {
        If ..CurrentChar = "." Set tHasDecimal = 1
        Do ..Advance()
    }
    
    Set tNumber = $EXTRACT(..Input, tStart, ..Position - 1)
    Quit ##class(Patterns.GoF.Behavioral.NumberExpression).%New(tNumber)
}

/// Parse a variable name
Method ParseVariable() As Patterns.GoF.Behavioral.VariableExpression [ Private ]
{
    Set tStart = ..Position
    
    While ..IsLetter(..CurrentChar) || ..IsDigit(..CurrentChar) || (..CurrentChar = "_") {
        Do ..Advance()
    }
    
    Set tVarName = $EXTRACT(..Input, tStart, ..Position - 1)
    
    // Check if it's actually a boolean keyword
    If (tVarName = "true") || (tVarName = "false") {
        Quit ##class(Patterns.GoF.Behavioral.BooleanExpression).%New(tVarName)
    }
    
    Quit ##class(Patterns.GoF.Behavioral.VariableExpression).%New(tVarName)
}

/// Parse a boolean value
Method ParseBoolean() As Patterns.GoF.Behavioral.BooleanExpression [ Private ]
{
    If ..StartsWith("true") {
        Set ..Position = ..Position + 4
        Set ..CurrentChar = $EXTRACT(..Input, ..Position)
        Quit ##class(Patterns.GoF.Behavioral.BooleanExpression).%New("true")
    }
    
    If ..StartsWith("false") {
        Set ..Position = ..Position + 5
        Set ..CurrentChar = $EXTRACT(..Input, ..Position)
        Quit ##class(Patterns.GoF.Behavioral.BooleanExpression).%New("false")
    }
    
    Throw ##class(%Exception.General).%New("Invalid boolean value")
}

/// ===== HELPER METHODS =====
/// Advance to next character
Method Advance() [ Private ]
{
    Set ..Position = ..Position + 1
    If ..Position <= $LENGTH(..Input) {
        Set ..CurrentChar = $EXTRACT(..Input, ..Position)
    } Else {
        Set ..CurrentChar = ""
    }
    Do ..SkipWhitespace()
}

/// Skip whitespace characters
Method SkipWhitespace() [ Private ]
{
    While (..CurrentChar = " ") || (..CurrentChar = $CHAR(9)) {
        Set ..Position = ..Position + 1
        If ..Position <= $LENGTH(..Input) {
            Set ..CurrentChar = $EXTRACT(..Input, ..Position)
        } Else {
            Set ..CurrentChar = ""
            Quit
        }
    }
}

/// Expect a specific character
Method Expect(pChar As %String) [ Private ]
{
    Do ..SkipWhitespace()
    If ..CurrentChar '= pChar {
        Throw ##class(%Exception.General).%New("Expected '" _ pChar _ "' but got '" _ ..CurrentChar _ "'")
    }
    Do ..Advance()
}

/// Check if character is a digit
Method IsDigit(pChar As %String) As %Boolean [ Private ]
{
    Quit pChar?1N
}

/// Check if character is a letter
Method IsLetter(pChar As %String) As %Boolean [ Private ]
{
    Quit pChar?1A
}

/// Check if input starts with a string at current position
Method StartsWith(pString As %String) As %Boolean [ Private ]
{
    Set tLen = $LENGTH(pString)
    If (..Position + tLen - 1) > $LENGTH(..Input) {
        Quit 0
    }
    
    Set tSubstring = $EXTRACT(..Input, ..Position, ..Position + tLen - 1)
    Quit tSubstring = pString
}

/// ===== CLASS METHODS =====
/// Quick parse static method
/// 
/// @param pExpression The expression to parse
/// @return Expression tree
ClassMethod QuickParse(pExpression As %String) As Patterns.GoF.Behavioral.Expression
{
    Set tParser = ..%New()
    Quit tParser.Parse(pExpression)
}

}
