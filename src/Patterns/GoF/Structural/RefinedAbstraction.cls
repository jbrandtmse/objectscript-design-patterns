/// Gang of Four Bridge Pattern - Refined Abstraction
/// <p>
/// RefinedAbstraction extends the interface defined by Abstraction.
/// It provides more specific or enhanced operations while still
/// delegating the actual work to the implementation object.
/// </p>
/// <p>
/// <b>Purpose:</b><br/>
/// - Extends the abstraction with additional operations<br/>
/// - Provides variant behavior while maintaining the bridge to implementation<br/>
/// - Can add state or additional logic on top of the basic abstraction
/// </p>
/// <example>
/// Set refined = ##class(Patterns.GoF.Structural.RefinedAbstraction).%New()
/// Set impl = ##class(Patterns.GoF.Structural.ConcreteImplementorA).%New()
/// Do refined.SetImplementation(impl)
/// Write refined.Operation(),!
/// Write refined.RefinedOperation(),!
/// </example>
Class Patterns.GoF.Structural.RefinedAbstraction Extends Patterns.GoF.Structural.Abstraction
{

/// Additional state specific to refined abstraction
Property AdditionalState As %String;

/// Initialize the refined abstraction
Method %OnNew() As %Status
{
    Set ..AdditionalState = "Refined"
    Quit $$$OK
}

/// Implementation of the abstract Operation method
/// <p>
/// This method demonstrates how the refined abstraction uses
/// the implementation to perform its operation.
/// </p>
Method Operation() As %String
{
    Set tResult = ""
    
    If ..HasImplementation() {
        Set tImplResult = ..Implementation.OperationImpl()
        Set tResult = "RefinedAbstraction: Based on (" _ tImplResult _ ")"
    } Else {
        Set tResult = "RefinedAbstraction: No implementation set"
    }
    
    Quit tResult
}

/// Additional refined operation
/// <p>
/// This method shows how refined abstractions can add new operations
/// that build upon the basic abstraction and implementation.
/// </p>
Method RefinedOperation() As %String
{
    Set tResult = ""
    
    If ..HasImplementation() {
        // Perform multiple operations using the implementation
        Set tImplResult1 = ..Implementation.OperationImpl()
        Set tImplResult2 = ..Implementation.OperationImpl()
        Set tResult = "RefinedOperation: Combining [" _ tImplResult1 _ "] and [" _ tImplResult2 _ "]"
        Set tResult = tResult _ " with state: " _ ..AdditionalState
    } Else {
        Set tResult = "RefinedOperation: No implementation available"
    }
    
    Quit tResult
}

/// Extended operation with parameters
/// <p>
/// Demonstrates how refined abstractions can add parameterized operations
/// that leverage the implementation in different ways.
/// </p>
Method ExtendedOperation(pParameter As %String) As %String
{
    Set tResult = ""
    
    If ..HasImplementation() {
        Set tImplResult = ..Implementation.OperationImpl()
        Set tResult = "Extended[" _ pParameter _ "]: " _ tImplResult
    } Else {
        Set tResult = "ExtendedOperation: No implementation"
    }
    
    Quit tResult
}

/// Get status information
/// <p>
/// Provides detailed status including both abstraction and implementation info.
/// </p>
Method GetStatus() As %String
{
    Set tStatus = "RefinedAbstraction Status: "
    Set tStatus = tStatus _ "State=" _ ..AdditionalState _ ", "
    
    If ..HasImplementation() {
        Set tStatus = tStatus _ "Implementation=" _ ..GetImplementationType()
    } Else {
        Set tStatus = tStatus _ "Implementation=None"
    }
    
    Quit tStatus
}

}
