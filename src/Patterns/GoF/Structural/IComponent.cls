/// Gang of Four Decorator Pattern - Component Interface
/// 
/// <p>Intent:
/// Define the interface for objects that can have responsibilities added to them dynamically.</p>
/// 
/// <p>Motivation:
/// Sometimes we want to add responsibilities to individual objects, not to an entire class.
/// A graphical user interface toolkit, for example, should let you add properties like
/// borders or behaviors like scrolling to any user interface component.</p>
/// 
/// <p>Structure:
/// This abstract class defines the interface for both concrete components and decorators.
/// Decorators will extend this same interface to maintain type compatibility.</p>
/// 
/// <p>Applicability:
/// Use the Component interface when:
/// - You want to add responsibilities to individual objects dynamically and transparently
/// - You want responsibilities that can be withdrawn
/// - Extension by subclassing is impractical</p>
/// 
/// @since 1.0.0
/// @see Patterns.GoF.Structural.Decorator
/// @see Patterns.GoF.Structural.ConcreteComponent
Class Patterns.GoF.Structural.IComponent Extends %RegisteredObject [ Abstract ]
{

/// Perform the component's operation
/// 
/// <p>This method defines the core operation that both concrete components
/// and decorators must implement. Decorators will typically enhance or modify
/// this operation while maintaining the same interface.</p>
/// 
/// @return Operation result as a string describing the performed operation
/// 
/// <example>
/// Set component = ##class(ConcreteComponent).%New()
/// Set result = component.Operation()
/// Write "Operation result: ", result, !
/// </example>
Method Operation() As %String [ Abstract ]
{
    Quit ""
}

/// Get the component's description
/// 
/// <p>Returns a description of the component, which may be enhanced by decorators
/// to reflect the added responsibilities.</p>
/// 
/// @return Component description as a string
/// 
/// <example>
/// Set component = ##class(ConcreteComponent).%New()
/// Set description = component.GetDescription()
/// Write "Component: ", description, !
/// </example>
Method GetDescription() As %String [ Abstract ]
{
    Quit ""
}

/// Get the cost or value associated with this component
/// 
/// <p>Optional method that can be used to demonstrate cumulative behavior
/// through decorator chains. Useful for showing how decorators can add
/// to base values.</p>
/// 
/// @return Numeric cost or value
Method GetCost() As %Numeric
{
    Quit 0
}

/// Check if the component is valid
/// 
/// <p>Validation method that can be enhanced by decorators to add
/// additional validation rules.</p>
/// 
/// @return %Boolean indicating whether the component is valid
Method IsValid() As %Boolean
{
    Quit 1
}

}
