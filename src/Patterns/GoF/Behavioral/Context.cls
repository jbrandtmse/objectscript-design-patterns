/// Gang of Four Interpreter Pattern - Context for Variable Storage
/// 
/// Intent:
/// Maintains interpreter state and global information that's shared across expressions.
/// Stores variables, constants, and other contextual data needed during interpretation.
/// 
/// Structure:
/// <example>
/// Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
/// Do context.SetVariable("x", 10)
/// Do context.SetVariable("y", 20)
/// Set value = context.GetVariable("x")
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Expression
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Context Extends %RegisteredObject
{

/// ===== PARAMETERS =====
Parameter VERSION = "1.0.0";

/// ===== PROPERTIES =====
/// Variable storage using dynamic object
Property Variables As %DynamicObject;

/// Constant storage using dynamic object
Property Constants As %DynamicObject;

/// Function definitions for custom functions
Property Functions As %DynamicObject;

/// Stack for recursive evaluation tracking
Property EvaluationStack As %ListOfDataTypes;

/// Maximum evaluation depth to prevent stack overflow
Property MaxEvaluationDepth As %Integer [ InitialExpression = 100 ];

/// Current evaluation depth
Property CurrentDepth As %Integer [ InitialExpression = 0 ];

/// Debug mode flag
Property DebugMode As %Boolean [ InitialExpression = 0 ];

/// Debug output collection
Property DebugOutput As %ListOfDataTypes;

/// ===== PUBLIC METHODS =====
/// Gets a variable value from context
/// 
/// @param pName The variable name
/// @return The variable value or empty string if not found
Method GetVariable(pName As %String) As %String
{
    If ..Variables.%IsDefined(pName) {
        Quit ..Variables.%Get(pName)
    }
    Quit ""
}

/// Sets a variable value in context
/// 
/// @param pName The variable name
/// @param pValue The variable value
/// @return %Status
Method SetVariable(pName As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Do ..Variables.%Set(pName, pValue)
        If ..DebugMode {
            Do ..AddDebugInfo("Set variable: " _ pName _ " = " _ pValue)
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Checks if a variable exists in context
/// 
/// @param pName The variable name
/// @return %Boolean indicating if variable exists
Method HasVariable(pName As %String) As %Boolean
{
    Quit ..Variables.%IsDefined(pName)
}

/// Removes a variable from context
/// 
/// @param pName The variable name
/// @return %Status
Method RemoveVariable(pName As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Do ..Variables.%Remove(pName)
        If ..DebugMode {
            Do ..AddDebugInfo("Removed variable: " _ pName)
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Clear all variables from context
/// 
/// @return %Status
Method ClearVariables() As %Status
{
    Set ..Variables = ##class(%DynamicObject).%New()
    If ..DebugMode {
        Do ..AddDebugInfo("Cleared all variables")
    }
    Quit $$$OK
}

/// Register a custom function
/// 
/// @param pName The function name
/// @param pClassName The class containing the function
/// @param pMethodName The method name to invoke
/// @return %Status
Method RegisterFunction(pName As %String, pClassName As %String, pMethodName As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Set tFunction = ##class(%DynamicObject).%New()
        Set tFunction.className = pClassName
        Set tFunction.methodName = pMethodName
        Do ..Functions.%Set(pName, tFunction)
        If ..DebugMode {
            Do ..AddDebugInfo("Registered function: " _ pName)
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check if a function is registered
/// 
/// @param pName The function name
/// @return %Boolean
Method HasFunction(pName As %String) As %Boolean
{
    Quit ..Functions.%IsDefined(pName)
}

/// Get function information
/// 
/// @param pName The function name
/// @return %DynamicObject with function info or null
Method GetFunction(pName As %String) As %DynamicObject
{
    If ..Functions.%IsDefined(pName) {
        Quit ..Functions.%Get(pName)
    }
    Quit ""
}

/// Push evaluation context onto stack
/// 
/// @param pExpression The expression being evaluated
/// @return %Status
Method PushEvaluation(pExpression As %String) As %Status
{
    Set ..CurrentDepth = ..CurrentDepth + 1
    
    If ..CurrentDepth > ..MaxEvaluationDepth {
        Quit $$$ERROR($$$GeneralError, "Maximum evaluation depth exceeded: " _ ..MaxEvaluationDepth)
    }
    
    Do ..EvaluationStack.Insert(pExpression)
    
    If ..DebugMode {
        Do ..AddDebugInfo("Push: " _ pExpression _ " (depth: " _ ..CurrentDepth _ ")")
    }
    
    Quit $$$OK
}

/// Pop evaluation context from stack
/// 
/// @return %Status
Method PopEvaluation() As %Status
{
    If ..EvaluationStack.Count() > 0 {
        Set tExpression = ..EvaluationStack.GetAt(..EvaluationStack.Count())
        Do ..EvaluationStack.RemoveAt(..EvaluationStack.Count())
        Set ..CurrentDepth = ..CurrentDepth - 1
        
        If ..DebugMode {
            Do ..AddDebugInfo("Pop: " _ tExpression _ " (depth: " _ ..CurrentDepth _ ")")
        }
    }
    
    Quit $$$OK
}

/// Get current evaluation stack trace
/// 
/// @return %String with stack trace
Method GetStackTrace() As %String
{
    Set tTrace = ""
    For i=1:1:..EvaluationStack.Count() {
        Set:tTrace'="" tTrace = tTrace _ " -> "
        Set tTrace = tTrace _ ..EvaluationStack.GetAt(i)
    }
    Quit tTrace
}

/// Enable debug mode
/// 
/// @return %Status
Method EnableDebug() As %Status
{
    Set ..DebugMode = 1
    Do ..DebugOutput.Clear()
    Do ..AddDebugInfo("Debug mode enabled")
    Quit $$$OK
}

/// Disable debug mode
/// 
/// @return %Status
Method DisableDebug() As %Status
{
    Set ..DebugMode = 0
    Quit $$$OK
}

/// Add debug information
/// 
/// @param pInfo Debug information string
Method AddDebugInfo(pInfo As %String)
{
    If ..DebugMode {
        Do ..DebugOutput.Insert($ZDATETIME($HOROLOG,3) _ " - " _ pInfo)
    }
}

/// Get debug output
/// 
/// @return %String with all debug information
Method GetDebugOutput() As %String
{
    Set tOutput = ""
    For i=1:1:..DebugOutput.Count() {
        Set:tOutput'="" tOutput = tOutput _ $CHAR(10)
        Set tOutput = tOutput _ ..DebugOutput.GetAt(i)
    }
    Quit tOutput
}

/// Create a copy of this context
/// 
/// @return New Context instance with copied values
Method Clone() As Patterns.GoF.Behavioral.Context
{
    Set tNewContext = ##class(Context).%New()
    
    // Copy variables
    Set tIterator = ..Variables.%GetIterator()
    While tIterator.%GetNext(.tKey, .tValue) {
        Do tNewContext.SetVariable(tKey, tValue)
    }
    
    // Copy functions
    Set tIterator = ..Functions.%GetIterator()
    While tIterator.%GetNext(.tKey, .tValue) {
        Do tNewContext.Functions.%Set(tKey, tValue)
    }
    
    // Copy settings
    Set tNewContext.MaxEvaluationDepth = ..MaxEvaluationDepth
    Set tNewContext.DebugMode = ..DebugMode
    
    Quit tNewContext
}

/// Reset context to initial state
/// 
/// @return %Status
Method Reset() As %Status
{
    Set ..Variables = ##class(%DynamicObject).%New()
    Set ..Functions = ##class(%DynamicObject).%New()
    Do ..EvaluationStack.Clear()
    Set ..CurrentDepth = 0
    Do ..DebugOutput.Clear()
    
    If ..DebugMode {
        Do ..AddDebugInfo("Context reset")
    }
    
    Quit $$$OK
}

/// ===== CONSTRUCTORS =====
/// Initialize the context
Method %OnNew() As %Status
{
    Set ..Variables = ##class(%DynamicObject).%New()
    Set ..Constants = ##class(%DynamicObject).%New()
    Set ..Functions = ##class(%DynamicObject).%New()
    Set ..EvaluationStack = ##class(%ListOfDataTypes).%New()
    Set ..DebugOutput = ##class(%ListOfDataTypes).%New()
    
    // Initialize standard constants
    Do ..InitializeConstants()
    
    Quit $$$OK
}

/// Initialize standard constants
Method InitializeConstants() [ Private ]
{
    Do ..Constants.%Set("PI", 3.14159265359)
    Do ..Constants.%Set("E", 2.71828182846)
    Do ..Constants.%Set("TRUE", 1)
    Do ..Constants.%Set("FALSE", 0)
}

/// Check if constant exists
Method HasConstant(pName As %String) As %Boolean
{
    Quit ..Constants.%IsDefined(pName)
}

/// Get constant value
Method GetConstant(pName As %String) As %String
{
    If ..Constants.%IsDefined(pName) {
        Quit ..Constants.%Get(pName)
    }
    Quit ""
}

/// Set constant value
Method SetConstant(pName As %String, pValue As %String) As %Status
{
    Do ..Constants.%Set(pName, pValue)
    Quit $$$OK
}

}
