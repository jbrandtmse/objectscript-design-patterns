/// Mock object builder for creating test doubles
/// Provides functionality for setting expectations, argument matching, and verification
/// 
/// @since 1.0.0
Class Patterns.Test.MockBuilder Extends %RegisteredObject
{

// ===== PROPERTIES =====

/// Name of the class being mocked
Property ClassName As %String;

/// Collection of expected method calls
Property Expectations As list Of Patterns.Test.MockExpectation;

/// Collection of actual method calls made
Property CallHistory As list Of Patterns.Test.MockCall;

/// Mock object instance
Property MockInstance As %RegisteredObject;

/// Flag indicating if strict mode is enabled (all calls must be expected)
Property StrictMode As %Boolean [ InitialExpression = 0 ];

// ===== CONSTRUCTOR =====

/// Create a new mock builder for a specific class
/// 
/// @param pClassName Name of the class to mock
/// @param pStrictMode Enable strict mode (optional)
/// @return MockBuilder instance
ClassMethod CreateMock(pClassName As %String, pStrictMode As %Boolean = 0) As Patterns.Test.MockBuilder
{
    Set mock = ..%New()
    Set mock.ClassName = pClassName
    Set mock.StrictMode = pStrictMode
    
    // Create a dynamic mock object
    Set mock.MockInstance = {}
    Set mock.MockInstance.%ClassName = pClassName
    Set mock.MockInstance.%IsMock = 1
    Set mock.MockInstance.%MockBuilder = mock
    
    Return mock
}

// ===== EXPECTATION METHODS =====

/// Set expectation for a method call
/// 
/// @param pMethodName Name of the method expected to be called
/// @return MockExpectation for further configuration
Method ExpectCall(pMethodName As %String) As Patterns.Test.MockExpectation
{
    Set expectation = ##class(Patterns.Test.MockExpectation).%New()
    Set expectation.MethodName = pMethodName
    Set expectation.MockBuilder = $THIS
    
    Do ..Expectations.Insert(expectation)
    
    // Add method to mock instance (fixed syntax)
    Set code = "Set mockBuilder = args.%MockBuilder "
    Set code = code_"Do mockBuilder.RecordCall("""_pMethodName_""", args) "
    Set code = code_"Return mockBuilder.GetReturnValue("""_pMethodName_""", args)"
    
    // Use Do for dynamic object method
    Do ..MockInstance.%Set(pMethodName, code)
    
    Return expectation
}

/// Set expectation that a method should not be called
/// 
/// @param pMethodName Name of the method that should not be called
Method ExpectNoCalls(pMethodName As %String)
{
    Set expectation = ##class(Patterns.Test.MockExpectation).%New()
    Set expectation.MethodName = pMethodName
    Set expectation.ExpectedCalls = 0
    Set expectation.MockBuilder = $THIS
    
    Do ..Expectations.Insert(expectation)
}

/// Record a method call in the history
/// 
/// @param pMethodName Name of the method called
/// @param pArgs Arguments passed to the method
Method RecordCall(pMethodName As %String, pArgs As %DynamicObject)
{
    Set call = ##class(Patterns.Test.MockCall).%New()
    Set call.MethodName = pMethodName
    Set call.Arguments = pArgs
    Set call.Timestamp = $ZHOROLOG
    
    Do ..CallHistory.Insert(call)
    
    // In strict mode, verify this call was expected
    If ..StrictMode {
        Set expected = ..FindExpectation(pMethodName)
        If '$ISOBJECT(expected) {
            Throw ##class(%Exception.General).%New("MockError", 
                "Unexpected method call: "_pMethodName_" (strict mode enabled)")
        }
    }
}

/// Get the return value for a mocked method
/// 
/// @param pMethodName Name of the method
/// @param pArgs Arguments passed
/// @return Configured return value or default
Method GetReturnValue(pMethodName As %String, pArgs As %DynamicObject) As %String
{
    Set expectation = ..FindExpectation(pMethodName)
    
    If $ISOBJECT(expectation) {
        // Check if arguments match
        If expectation.ValidateArguments(pArgs) {
            Return expectation.ReturnValue
        }
    }
    
    Return ""
}

/// Find expectation for a method
/// 
/// @param pMethodName Name of the method
/// @return MockExpectation or empty string
Method FindExpectation(pMethodName As %String) As Patterns.Test.MockExpectation [ Private ]
{
    For i = 1:1:..Expectations.Count() {
        Set exp = ..Expectations.GetAt(i)
        If exp.MethodName = pMethodName {
            Return exp
        }
    }
    Return ""
}

// ===== VERIFICATION METHODS =====

/// Verify all expectations were met
/// 
/// @return %Status indicating success or failure
Method Verify() As %Status
{
    Set status = $$$OK
    Set errors = ""
    
    For i = 1:1:..Expectations.Count() {
        Set expectation = ..Expectations.GetAt(i)
        Set actualCalls = ..CountCalls(expectation.MethodName, expectation.ArgumentMatcher)
        
        // Check minimum calls
        If expectation.MinCalls '= "" {
            If actualCalls < expectation.MinCalls {
                Set errors = errors_$SELECT(errors'="": "; ", 1: "")_
                    "Method '"_expectation.MethodName_"' called "_actualCalls_
                    " times (expected min: "_expectation.MinCalls_")"
            }
        }
        
        // Check maximum calls
        If expectation.MaxCalls '= "" {
            If actualCalls > expectation.MaxCalls {
                Set errors = errors_$SELECT(errors'="": "; ", 1: "")_
                    "Method '"_expectation.MethodName_"' called "_actualCalls_
                    " times (expected max: "_expectation.MaxCalls_")"
            }
        }
        
        // Check exact calls if specified
        If expectation.ExpectedCalls '= "" {
            If actualCalls '= expectation.ExpectedCalls {
                Set errors = errors_$SELECT(errors'="": "; ", 1: "")_
                    "Method '"_expectation.MethodName_"' called "_actualCalls_
                    " times (expected: "_expectation.ExpectedCalls_")"
            }
        }
    }
    
    If errors '= "" {
        Set status = $$$ERROR($$$GeneralError, "Mock verification failed: "_errors)
    }
    
    Return status
}

/// Count the number of calls to a method with optional argument matching
/// 
/// @param pMethodName Name of the method
/// @param pArgumentMatcher Optional argument matcher
/// @return Number of matching calls
Method CountCalls(pMethodName As %String, pArgumentMatcher As %DynamicObject = "") As %Integer
{
    Set count = 0
    
    For i = 1:1:..CallHistory.Count() {
        Set call = ..CallHistory.GetAt(i)
        If call.MethodName = pMethodName {
            If '$ISOBJECT(pArgumentMatcher) {
                Set count = count + 1
            } ElseIf ..MatchArguments(call.Arguments, pArgumentMatcher) {
                Set count = count + 1
            }
        }
    }
    
    Return count
}

/// Check if arguments match the expected pattern
/// 
/// @param pActual Actual arguments
/// @param pExpected Expected argument pattern
/// @return Boolean indicating match
Method MatchArguments(pActual As %DynamicObject, pExpected As %DynamicObject) As %Boolean [ Private ]
{
    // If no expected arguments specified, any arguments match
    If '$ISOBJECT(pExpected) Return 1
    
    // Convert to JSON for comparison
    Set actualJSON = pActual.%ToJSON()
    Set expectedJSON = pExpected.%ToJSON()
    
    Return (actualJSON = expectedJSON)
}

/// Reset all expectations and call history
Method Reset()
{
    Do ..Expectations.Clear()
    Do ..CallHistory.Clear()
}

/// Get a summary of all calls made
/// 
/// @return String summary of call history
Method GetCallSummary() As %String
{
    Set summary = ""
    
    For i = 1:1:..CallHistory.Count() {
        Set call = ..CallHistory.GetAt(i)
        Set summary = summary_$SELECT(summary'="": $CHAR(10), 1: "")_
            call.MethodName_"("_$SELECT($ISOBJECT(call.Arguments): call.Arguments.%ToJSON(), 1: "")_")"
    }
    
    Return summary
}

}
