/// Gang of Four Decorator Pattern - Abstract Decorator Base Class
/// 
/// <p>Intent:
/// Maintains a reference to a Component object and defines an interface
/// that conforms to Component's interface.</p>
/// 
/// <p>Motivation:
/// This abstract decorator class provides the base implementation for all
/// concrete decorators. It wraps a component and delegates all operations
/// to it by default, allowing subclasses to add behavior before or after
/// the delegation.</p>
/// 
/// <p>Structure:
/// The Decorator class extends IComponent and contains a reference to
/// another IComponent object. This creates a recursive composition that
/// allows for unlimited levels of decoration.</p>
/// 
/// <p>Participants:
/// - Maintains a reference to a Component object
/// - Defines an interface that conforms to Component's interface
/// - Delegates all requests to the wrapped component by default</p>
/// 
/// <p>Collaborations:
/// - Decorator forwards requests to its Component object
/// - May perform additional operations before and/or after forwarding</p>
/// 
/// @since 1.0.0
/// @see Patterns.GoF.Structural.IComponent
/// @see Patterns.GoF.Structural.ConcreteComponent
Class Patterns.GoF.Structural.Decorator Extends Patterns.GoF.Structural.IComponent [ Abstract ]
{

/// The wrapped component that this decorator enhances
Property Component As Patterns.GoF.Structural.IComponent;

/// Additional cost added by this decorator
Property AdditionalCost As %Numeric [ InitialExpression = 0 ];

/// Decorator name for identification
Property DecoratorName As %String [ InitialExpression = "Decorator" ];

/// Constructor accepting component to wrap
/// 
/// <p>Initializes the decorator with a component to enhance.
/// The component parameter can be null, allowing decorators
/// to exist without a wrapped component.</p>
/// 
/// @param pComponent The component to be decorated (optional)
/// @return %Status indicating success or failure
/// 
/// <example>
/// Set baseComponent = ##class(ConcreteComponent).%New()
/// Set decorator = ##class(ConcreteDecoratorA).%New(baseComponent)
/// </example>
Method %OnNew(pComponent As Patterns.GoF.Structural.IComponent = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Allow null components - decorators can exist without wrapping
        If $ISOBJECT(pComponent) {
            // Verify the component implements IComponent interface
            If '##class(%Dictionary.CompiledClass).%ExistsId(pComponent.%ClassName(1)) {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid component class")
                Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
            }
            Set ..Component = pComponent
        } Else {
            // Component is null - that's okay
            Set ..Component = ""
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Perform the component's operation with decorator enhancements
/// 
/// <p>Default implementation delegates to the wrapped component.
/// Concrete decorators override this method to add behavior
/// before or after the delegation.</p>
/// 
/// @return Operation result from the wrapped component
/// 
/// <example>
/// // Default behavior - just delegates
/// Set result = decorator.Operation()
/// 
/// // Concrete decorator would override to add behavior:
/// Method Operation() As %String
/// {
///     Set result = "Before: "
///     Set result = result _ ##super()  // Call parent (delegate)
///     Set result = result _ " :After"
///     Quit result
/// }
/// </example>
Method Operation() As %String
{
    // Validate component exists
    If '$ISOBJECT(..Component) {
        Quit "ERROR: No component to decorate"
    }
    
    // Delegate to wrapped component
    Quit ..Component.Operation()
}

/// Get the component's description with decorator enhancements
/// 
/// <p>Default implementation delegates to the wrapped component.
/// Concrete decorators can override to enhance the description.</p>
/// 
/// @return Description from the wrapped component
Method GetDescription() As %String
{
    // Validate component exists
    If '$ISOBJECT(..Component) {
        Quit "ERROR: No component"
    }
    
    // Delegate to wrapped component
    Quit ..Component.GetDescription()
}

/// Get the cost with decorator's additional cost
/// 
/// <p>Calculates total cost by adding this decorator's cost
/// to the wrapped component's cost.</p>
/// 
/// @return Total cost including decorator's addition
Method GetCost() As %Numeric
{
    Set tBaseCost = 0
    
    // Get cost from wrapped component
    If $ISOBJECT(..Component) {
        Set tBaseCost = ..Component.GetCost()
    }
    
    // Add this decorator's additional cost
    Quit tBaseCost + ..AdditionalCost
}

/// Validate the component with decorator's validation
/// 
/// <p>Default implementation delegates validation to wrapped component.
/// Concrete decorators can add additional validation rules.</p>
/// 
/// @return %Boolean indicating whether the component is valid
Method IsValid() As %Boolean
{
    // First check if we have a component
    If '$ISOBJECT(..Component) {
        Quit 0
    }
    
    // Delegate validation to wrapped component
    Quit ..Component.IsValid()
}

/// Get the wrapped component
/// 
/// <p>Utility method to access the wrapped component directly.
/// Useful for decorator chains and debugging.</p>
/// 
/// @return The wrapped component
Method GetWrappedComponent() As Patterns.GoF.Structural.IComponent
{
    Quit ..Component
}

/// Set a new component to wrap
/// 
/// <p>Allows changing the wrapped component after construction.
/// Use with caution as it changes the decorator's behavior.</p>
/// 
/// @param pComponent New component to wrap
/// @return %Status indicating success or failure
Method SetComponent(pComponent As Patterns.GoF.Structural.IComponent) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Allow null/empty components
        If $ISOBJECT(pComponent) {
            Set ..Component = pComponent
        } Else {
            Set ..Component = ""
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Remove the outermost decorator layer
/// 
/// <p>Returns the wrapped component, effectively removing this
/// decorator from the chain. Useful for dynamic decoration removal.</p>
/// 
/// @return The wrapped component without this decorator
Method RemoveDecorator() As Patterns.GoF.Structural.IComponent
{
    Quit ..Component
}

/// Get decorator chain depth
/// 
/// <p>Calculates how many decorator layers exist in the chain.</p>
/// 
/// @return Number of decorator layers
Method GetDecoratorDepth() As %Integer
{
    Set tDepth = 1  // This decorator counts as 1
    
    // If wrapped component is also a decorator, get its depth
    If $ISOBJECT(..Component) && (..Component.%IsA("Patterns.GoF.Structural.Decorator")) {
        Set tDepth = tDepth + ..Component.GetDecoratorDepth()
    }
    
    Quit tDepth
}

/// Display decorator chain information
/// 
/// <p>Utility method to display the decorator chain structure.
/// Useful for debugging and understanding the decoration layers.</p>
Method DisplayChain()
{
    Write "Decorator: ", ..DecoratorName, " (Cost: +$", ..AdditionalCost, ")", !
    
    // If wrapped component has display method, call it
    If $ISOBJECT(..Component) {
        If ##class(%Dictionary.CompiledMethod).%ExistsId(..Component.%ClassName(1)_"||DisplayChain") {
            Do ..Component.DisplayChain()
        } ElseIf ##class(%Dictionary.CompiledMethod).%ExistsId(..Component.%ClassName(1)_"||Display") {
            Do ..Component.Display()
        } Else {
            Write "  -> ", ..Component.GetDescription(), !
        }
    }
}

/// Class method to demonstrate ObjectScript method overriding
/// 
/// <p>This method documents how to properly override methods in
/// ObjectScript using ##super() to call parent implementations.</p>
/// 
/// <example>
/// // In a concrete decorator class:
/// Method Operation() As %String
/// {
///     // Add behavior before delegation
///     Set tResult = "Decorator processing: "
///     
///     // Call parent implementation (which delegates to component)
///     Set tResult = tResult _ ##super()
///     
///     // Add behavior after delegation
///     Set tResult = tResult _ " [Enhanced by " _ ..DecoratorName _ "]"
///     
///     Quit tResult
/// }
/// </example>
ClassMethod DemonstrateOverriding()
{
    Write "=== ObjectScript Method Overriding Pattern ===", !
    Write "1. Use ##super() to call parent method implementation", !
    Write "2. Override methods by redefining them in subclass", !
    Write "3. Methods are virtual by default (can be overridden)", !
    Write "4. Use [ Final ] keyword to prevent overriding", !
    Write "5. Abstract methods must have implementation body", !
    Write "6. Call order: Subclass -> ##super() -> Parent class", !
    Write "===============================================", !
}

}
