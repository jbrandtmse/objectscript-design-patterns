/// Gang of Four Bridge Pattern - Implementor
/// <p>
/// The Implementor interface defines the interface for implementation classes.
/// This interface doesn't have to correspond exactly to Abstraction's interface;
/// in fact, the two interfaces can be quite different. Typically, the Implementor
/// interface provides only primitive operations, and Abstraction defines higher-level
/// operations based on these primitives.
/// </p>
/// <p>
/// <b>Key Characteristics:</b><br/>
/// - Defines the interface for concrete implementation classes<br/>
/// - Typically provides primitive operations<br/>
/// - Decoupled from the abstraction hierarchy<br/>
/// - Can be switched at runtime
/// </p>
/// <p>
/// <b>Benefits:</b><br/>
/// - Implementation can be selected or switched at runtime<br/>
/// - Abstraction and implementation can be extended independently<br/>
/// - Implementation details are hidden from clients
/// </p>
Class Patterns.GoF.Structural.Implementor Extends %RegisteredObject [ Abstract ]
{

/// Abstract method for implementation-specific operation
/// <p>
/// This method defines the primitive operation that concrete implementors
/// must provide. The abstraction will use this operation to build
/// higher-level functionality.
/// </p>
/// <p>
/// Concrete implementors will provide different implementations of this
/// method, allowing the abstraction to work with various implementations
/// without modification.
/// </p>
Method OperationImpl() As %String [ Abstract ]
{
    // Abstract method must have implementation body in ObjectScript
    Quit ""
}

/// Get implementation details for debugging
/// <p>
/// Returns information about the specific implementation.
/// Useful for logging and debugging purposes.
/// </p>
Method GetImplementationInfo() As %String
{
    Quit "Implementor: " _ ..%ClassName(1)
}

/// Validate implementation state
/// <p>
/// Can be overridden by concrete implementors to validate
/// their internal state before performing operations.
/// </p>
Method ValidateState() As %Status
{
    Quit $$$OK
}

}
