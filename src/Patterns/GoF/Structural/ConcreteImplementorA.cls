/// Gang of Four Bridge Pattern - Concrete Implementor A
/// <p>
/// ConcreteImplementorA provides a specific implementation of the Implementor interface.
/// This class represents one possible implementation that can be used by the abstraction.
/// Different concrete implementors provide different ways of performing the same operation.
/// </p>
/// <p>
/// <b>Characteristics:</b><br/>
/// - Implements the Implementor interface<br/>
/// - Provides specific implementation logic<br/>
/// - Can be switched at runtime with other implementors<br/>
/// - Independent of the abstraction hierarchy
/// </p>
/// <example>
/// Set implA = ##class(Patterns.GoF.Structural.ConcreteImplementorA).%New()
/// Set abstraction = ##class(Patterns.GoF.Structural.RefinedAbstraction).%New()
/// Do abstraction.SetImplementation(implA)
/// Write abstraction.Operation(),!
/// </example>
Class Patterns.GoF.Structural.ConcreteImplementorA Extends Patterns.GoF.Structural.Implementor
{

/// Internal state specific to ConcreteImplementorA
Property StateA As %String [ InitialExpression = "StateA" ];

/// Counter for tracking operations (for demonstration)
Property OperationCount As %Integer [ InitialExpression = 0 ];

/// Implementation of the abstract OperationImpl method
/// <p>
/// This implementation provides a specific way of performing the operation.
/// ConcreteImplementorA might represent a fast but less accurate implementation,
/// or a specific platform/technology implementation.
/// </p>
Method OperationImpl() As %String
{
    Set ..OperationCount = ..OperationCount + 1
    Set tResult = "ConcreteImplementorA.OperationImpl() "
    Set tResult = tResult _ "[" _ ..StateA _ ", Count=" _ ..OperationCount _ "]"
    Quit tResult
}

/// Additional method specific to ConcreteImplementorA
/// <p>
/// Concrete implementors can have additional methods beyond the interface,
/// though these won't be accessible through the abstraction's interface.
/// </p>
Method SpecificOperationA() As %String
{
    Quit "Specific operation for ImplementorA with state: " _ ..StateA
}

/// Reset internal state
/// <p>
/// Demonstrates that concrete implementors can manage their own state
/// independently of the abstraction.
/// </p>
Method ResetState() As %Status
{
    Set ..OperationCount = 0
    Set ..StateA = "StateA-Reset"
    Quit $$$OK
}

/// Configure implementor with specific settings
/// <p>
/// Allows configuration of this specific implementor's behavior.
/// </p>
Method Configure(pSettings As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..StateA = "StateA-" _ pSettings
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get performance metrics
/// <p>
/// ConcreteImplementorA might track performance differently than other implementors.
/// </p>
Method GetMetrics() As %String
{
    Quit "ImplementorA Metrics: Operations=" _ ..OperationCount _ ", State=" _ ..StateA
}

/// Validate state before operations
Method ValidateState() As %Status
{
    If ..OperationCount > 1000 {
        Quit $$$ERROR($$$GeneralError, "ImplementorA: Operation limit exceeded")
    }
    Quit $$$OK
}

}
