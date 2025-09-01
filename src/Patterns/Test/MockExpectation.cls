/// Mock expectation configuration
/// Used to define expected behavior for mocked methods
/// 
/// @since 1.0.0
Class Patterns.Test.MockExpectation Extends %RegisteredObject
{

/// Name of the expected method
Property MethodName As %String;

/// Expected arguments (optional)
Property ArgumentMatcher As %DynamicObject;

/// Return value for the mocked method
Property ReturnValue As %String;

/// Minimum number of expected calls
Property MinCalls As %Integer;

/// Maximum number of expected calls
Property MaxCalls As %Integer;

/// Exact number of expected calls
Property ExpectedCalls As %Integer;

/// Reference to the parent MockBuilder
Property MockBuilder As Patterns.Test.MockBuilder;

/// Configure expected arguments for this method call
/// 
/// @param pArgs Expected arguments as dynamic object
/// @return This expectation for method chaining
Method WithArgs(pArgs As %DynamicObject) As Patterns.Test.MockExpectation
{
    Set ..ArgumentMatcher = pArgs
    Return $THIS
}

/// Set the return value for this mocked method
/// 
/// @param pValue Value to return when method is called
/// @return This expectation for method chaining
Method Returns(pValue As %String) As Patterns.Test.MockExpectation
{
    Set ..ReturnValue = pValue
    Return $THIS
}

/// Expect this method to be called exactly n times
/// 
/// @param pCount Expected number of calls
/// @return This expectation for method chaining
Method Times(pCount As %Integer) As Patterns.Test.MockExpectation
{
    Set ..ExpectedCalls = pCount
    Return $THIS
}

/// Expect this method to be called at least n times
/// 
/// @param pCount Minimum number of calls
/// @return This expectation for method chaining
Method AtLeast(pCount As %Integer) As Patterns.Test.MockExpectation
{
    Set ..MinCalls = pCount
    Return $THIS
}

/// Expect this method to be called at most n times
/// 
/// @param pCount Maximum number of calls
/// @return This expectation for method chaining
Method AtMost(pCount As %Integer) As Patterns.Test.MockExpectation
{
    Set ..MaxCalls = pCount
    Return $THIS
}

/// Expect this method to be called once
/// 
/// @return This expectation for method chaining
Method Once() As Patterns.Test.MockExpectation
{
    Set ..ExpectedCalls = 1
    Return $THIS
}

/// Expect this method to be called twice
/// 
/// @return This expectation for method chaining
Method Twice() As Patterns.Test.MockExpectation
{
    Set ..ExpectedCalls = 2
    Return $THIS
}

/// Expect this method to never be called
/// 
/// @return This expectation for method chaining
Method Never() As Patterns.Test.MockExpectation
{
    Set ..ExpectedCalls = 0
    Return $THIS
}

/// Validate if arguments match the expectation
/// 
/// @param pActualArgs Actual arguments passed
/// @return Boolean indicating if arguments match
Method ValidateArguments(pActualArgs As %DynamicObject) As %Boolean
{
    // If no argument matcher specified, any arguments are valid
    If '$ISOBJECT(..ArgumentMatcher) Return 1
    
    // Compare arguments
    Return ..MockBuilder.MatchArguments(pActualArgs, ..ArgumentMatcher)
}

}
