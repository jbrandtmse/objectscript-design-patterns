/// Gang of Four Bridge Pattern - Abstraction
/// <p>
/// The Abstraction defines the abstraction's interface and maintains a reference
/// to an object of type Implementor. This class represents the high-level control
/// layer for some entity. It doesn't do the real work on its own but delegates
/// all the complex tasks to the implementation object.
/// </p>
/// <p>
/// <b>Pattern Intent:</b><br/>
/// Decouple an abstraction from its implementation so that the two can vary independently.
/// </p>
/// <p>
/// <b>Participants:</b><br/>
/// - Abstraction (this class): Defines the abstraction's interface and maintains a reference to Implementor<br/>
/// - RefinedAbstraction: Extends the interface defined by Abstraction<br/>
/// - Implementor: Defines the interface for implementation classes<br/>
/// - ConcreteImplementor: Implements the Implementor interface
/// </p>
Class Patterns.GoF.Structural.Abstraction Extends %RegisteredObject [ Abstract ]
{

/// Reference to the implementation object
/// This allows the abstraction to delegate actual work to the implementation
Property Implementation As Patterns.GoF.Structural.Implementor;

/// Set or change the implementation at runtime
/// <p>
/// This method allows dynamic switching of implementations, which is
/// one of the key benefits of the Bridge pattern.
/// </p>
/// <example>
/// Set abstraction = ##class(RefinedAbstraction).%New()
/// Set implementorA = ##class(ConcreteImplementorA).%New()
/// Do abstraction.SetImplementation(implementorA)
/// </example>
Method SetImplementation(pImplementation As Patterns.GoF.Structural.Implementor) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$IsObject(pImplementation) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "Implementation object is required"))
        }
        
        Set ..Implementation = pImplementation
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Abstract operation that uses the implementation
/// <p>
/// This method delegates the actual work to the implementation object.
/// Subclasses will implement this to define how they use the implementation.
/// </p>
Method Operation() As %String [ Abstract ]
{
    // Abstract method must have implementation body in ObjectScript
    Quit ""
}

/// Check if implementation is set
/// <p>
/// Helper method to verify that an implementation has been configured
/// before attempting to use it.
/// </p>
Method HasImplementation() As %Boolean
{
    Quit $IsObject(..Implementation)
}

/// Get the current implementation class name
/// <p>
/// Useful for debugging and logging to identify which implementation
/// is currently in use.
/// </p>
Method GetImplementationType() As %String
{
    If ..HasImplementation() {
        Quit ..Implementation.%ClassName(1)
    }
    Quit ""
}

}
