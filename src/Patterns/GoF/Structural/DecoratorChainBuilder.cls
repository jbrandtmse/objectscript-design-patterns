/// Gang of Four Decorator Pattern - Decorator Chain Builder
/// 
/// <p>Intent:
/// Provides a fluent interface for building complex decorator chains
/// programmatically, making it easier to compose multiple decorators.</p>
/// 
/// <p>Motivation:
/// While decorators can be manually nested, the builder pattern simplifies
/// the process of creating complex decorator chains and makes the code
/// more readable and maintainable.</p>
/// 
/// <p>Structure:
/// The builder maintains a reference to the current component being built
/// and provides methods to add different types of decorators to the chain.</p>
/// 
/// <p>Participants:
/// - Manages the construction of decorator chains
/// - Provides fluent interface for adding decorators
/// - Handles the proper ordering and nesting of decorators</p>
/// 
/// @since 1.0.0
/// @see Patterns.GoF.Structural.Decorator
/// @see Patterns.GoF.Structural.ConcreteDecoratorA
/// @see Patterns.GoF.Structural.ConcreteDecoratorB
Class Patterns.GoF.Structural.DecoratorChainBuilder Extends %RegisteredObject
{

/// The base component to start with
Property BaseComponent As Patterns.GoF.Structural.IComponent;

/// The current component (with all decorators applied)
Property CurrentComponent As Patterns.GoF.Structural.IComponent;

/// List of decorator types applied (for tracking)
Property DecoratorStack As list Of %String;

/// Total number of decorators applied
Property DecoratorCount As %Integer [ InitialExpression = 0 ];

/// Constructor to initialize the builder
/// 
/// @param pBaseComponent Optional base component to start with
/// @return %Status indicating success or failure
Method %OnNew(pBaseComponent As Patterns.GoF.Structural.IComponent = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $ISOBJECT(pBaseComponent) {
            Set ..BaseComponent = pBaseComponent
            Set ..CurrentComponent = pBaseComponent
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Start building with a base component
/// 
/// @param pBaseComponent The base component to start with
/// @return This builder instance for method chaining
Method WithBase(pBaseComponent As Patterns.GoF.Structural.IComponent) As Patterns.GoF.Structural.DecoratorChainBuilder
{
    Set ..BaseComponent = pBaseComponent
    Set ..CurrentComponent = pBaseComponent
    Do ..DecoratorStack.Clear()
    Set ..DecoratorCount = 0
    
    Quit $THIS
}

/// Add ConcreteDecoratorA to the chain
/// 
/// @param pLevel Optional enhancement level for DecoratorA
/// @return This builder instance for method chaining
/// 
/// <example>
/// Set builder = ##class(DecoratorChainBuilder).%New()
/// Set chain = builder.WithBase(component)
///                   .AddDecoratorA("Premium")
///                   .AddDecoratorB("Fast")
///                   .Build()
/// </example>
Method AddDecoratorA(pLevel As %String = "") As Patterns.GoF.Structural.DecoratorChainBuilder
{
    If '$ISOBJECT(..CurrentComponent) {
        // Create a default base component if none exists
        Set ..CurrentComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
        Set ..BaseComponent = ..CurrentComponent
    }
    
    // Create and wrap with DecoratorA
    Set tDecorator = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(..CurrentComponent, pLevel)
    Set ..CurrentComponent = tDecorator
    
    // Track the decorator
    Do ..DecoratorStack.Insert("DecoratorA(" _ $SELECT(pLevel'="":pLevel, 1:"Standard") _ ")")
    Set ..DecoratorCount = ..DecoratorCount + 1
    
    Quit $THIS
}

/// Add ConcreteDecoratorB to the chain
/// 
/// @param pMode Optional performance mode for DecoratorB
/// @return This builder instance for method chaining
Method AddDecoratorB(pMode As %String = "") As Patterns.GoF.Structural.DecoratorChainBuilder
{
    If '$ISOBJECT(..CurrentComponent) {
        // Create a default base component if none exists
        Set ..CurrentComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
        Set ..BaseComponent = ..CurrentComponent
    }
    
    // Create and wrap with DecoratorB
    Set tDecorator = ##class(Patterns.GoF.Structural.ConcreteDecoratorB).%New(..CurrentComponent, pMode)
    Set ..CurrentComponent = tDecorator
    
    // Track the decorator
    Do ..DecoratorStack.Insert("DecoratorB(" _ $SELECT(pMode'="":pMode, 1:"Balanced") _ ")")
    Set ..DecoratorCount = ..DecoratorCount + 1
    
    Quit $THIS
}

/// Add a custom decorator to the chain
/// 
/// @param pDecorator A decorator instance to add
/// @return This builder instance for method chaining
Method AddCustomDecorator(pDecorator As Patterns.GoF.Structural.Decorator) As Patterns.GoF.Structural.DecoratorChainBuilder
{
    If '$ISOBJECT(..CurrentComponent) {
        // Create a default base component if none exists
        Set ..CurrentComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
        Set ..BaseComponent = ..CurrentComponent
    }
    
    // Set the component for the custom decorator
    Set tSC = pDecorator.SetComponent(..CurrentComponent)
    If $$$ISOK(tSC) {
        Set ..CurrentComponent = pDecorator
        Do ..DecoratorStack.Insert("CustomDecorator")
        Set ..DecoratorCount = ..DecoratorCount + 1
    }
    
    Quit $THIS
}

/// Add multiple DecoratorA instances
/// 
/// @param pCount Number of DecoratorA instances to add
/// @param pLevel Enhancement level for all instances
/// @return This builder instance for method chaining
Method AddMultipleDecoratorA(pCount As %Integer = 2, pLevel As %String = "") As Patterns.GoF.Structural.DecoratorChainBuilder
{
    For i = 1:1:pCount {
        Do ..AddDecoratorA(pLevel)
    }
    
    Quit $THIS
}

/// Add multiple DecoratorB instances
/// 
/// @param pCount Number of DecoratorB instances to add
/// @param pMode Performance mode for all instances
/// @return This builder instance for method chaining
Method AddMultipleDecoratorB(pCount As %Integer = 2, pMode As %String = "") As Patterns.GoF.Structural.DecoratorChainBuilder
{
    For i = 1:1:pCount {
        Do ..AddDecoratorB(pMode)
    }
    
    Quit $THIS
}

/// Add alternating decorators
/// 
/// @param pCount Number of alternating pairs to add
/// @return This builder instance for method chaining
Method AddAlternating(pCount As %Integer = 2) As Patterns.GoF.Structural.DecoratorChainBuilder
{
    For i = 1:1:pCount {
        Do ..AddDecoratorA()
        Do ..AddDecoratorB()
    }
    
    Quit $THIS
}

/// Build and return the final decorated component
/// 
/// @return The fully decorated component
Method Build() As Patterns.GoF.Structural.IComponent
{
    If '$ISOBJECT(..CurrentComponent) {
        // Return a default component if nothing was built
        Quit ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    }
    
    Quit ..CurrentComponent
}

/// Reset the builder to start fresh
Method Reset()
{
    Set ..BaseComponent = ""
    Set ..CurrentComponent = ""
    Do ..DecoratorStack.Clear()
    Set ..DecoratorCount = 0
}

/// Get information about the current chain
/// 
/// @return String describing the chain structure
Method GetChainInfo() As %String
{
    Set tInfo = "Chain has " _ ..DecoratorCount _ " decorator(s): "
    
    For i = ..DecoratorStack.Count():-1:1 {
        Set tInfo = tInfo _ ..DecoratorStack.GetAt(i)
        If i > 1 Set tInfo = tInfo _ " -> "
    }
    
    If $ISOBJECT(..BaseComponent) {
        Set tInfo = tInfo _ " -> " _ ..BaseComponent.GetDescription()
    }
    
    Quit tInfo
}

/// Display the chain structure
Method DisplayChain()
{
    Write "=== Decorator Chain Structure ===" , !
    Write "Total Decorators: ", ..DecoratorCount, !
    Write "Chain Order (outer to inner):", !
    
    For i = ..DecoratorStack.Count():-1:1 {
        Write "  ", i, ". ", ..DecoratorStack.GetAt(i), !
    }
    
    If $ISOBJECT(..BaseComponent) {
        Write "  Base: ", ..BaseComponent.GetDescription(), !
    }
    
    If $ISOBJECT(..CurrentComponent) {
        Write "Total Cost: $", ..CurrentComponent.GetCost(), !
    }
    
    Write "================================", !
}

/// Class method to demonstrate building complex chains
/// 
/// <example>
/// Do ##class(DecoratorChainBuilder).DemonstrateChaining()
/// </example>
ClassMethod DemonstrateChaining()
{
    Write "=== Decorator Chain Builder Demonstration ===", !
    
    // Create base component
    Set tBase = ##class(Patterns.GoF.Structural.ConcreteComponent).%New("Demo Component", "Test Data")
    
    // Example 1: Simple chain
    Write !, "Example 1: Simple Chain", !
    Set tBuilder = ..%New()
    Set tChain1 = tBuilder.WithBase(tBase).AddDecoratorA("Premium").AddDecoratorB("Quality").Build()
    Write "Result: ", tChain1.Operation(), !
    Write "Cost: $", tChain1.GetCost(), !
    
    // Example 2: Multiple decorators of same type
    Write !, "Example 2: Multiple Same Type", !
    Do tBuilder.Reset()
    Set tChain2 = tBuilder.WithBase(tBase).AddMultipleDecoratorA(3, "Advanced").Build()
    Write "Result: ", tChain2.Operation(), !
    Write "Cost: $", tChain2.GetCost(), !
    
    // Example 3: Alternating pattern
    Write !, "Example 3: Alternating Pattern", !
    Do tBuilder.Reset()
    Set tChain3 = tBuilder.WithBase(tBase).AddAlternating(2).Build()
    Write "Result: ", tChain3.Operation(), !
    Write "Cost: $", tChain3.GetCost(), !
    
    // Example 4: Complex chain (10+ levels)
    Write !, "Example 4: Deep Chain (10+ levels)", !
    Do tBuilder.Reset()
    Set tDeepChain = tBuilder.WithBase(tBase).AddDecoratorA("Basic").AddDecoratorB("Fast").AddDecoratorA("Standard").AddDecoratorB("Balanced").AddDecoratorA("Advanced").AddDecoratorB("Quality").AddDecoratorA("Premium").AddDecoratorB("Fast").AddDecoratorA("Basic").AddDecoratorB("Quality").AddDecoratorA("Premium").Build()
    
    Write "Chain Info: ", tBuilder.GetChainInfo(), !
    Write "Total Cost: $", tDeepChain.GetCost(), !
    
    // Display chain structure
    Do tBuilder.DisplayChain()
    
    Write !, "=== Demonstration Complete ===", !
}

/// Create a performance-optimized chain
/// 
/// @param pBase Base component to decorate
/// @return Optimized decorator chain
ClassMethod CreatePerformanceChain(pBase As Patterns.GoF.Structural.IComponent) As Patterns.GoF.Structural.IComponent
{
    Set tBuilder = ..%New()
    Quit tBuilder.WithBase(pBase).AddDecoratorB("Fast").AddDecoratorB("Fast").AddDecoratorA("Basic").Build()
}

/// Create a quality-focused chain
/// 
/// @param pBase Base component to decorate
/// @return Quality-focused decorator chain
ClassMethod CreateQualityChain(pBase As Patterns.GoF.Structural.IComponent) As Patterns.GoF.Structural.IComponent
{
    Set tBuilder = ..%New()
    Quit tBuilder.WithBase(pBase).AddDecoratorA("Premium").AddDecoratorB("Quality").AddDecoratorA("Advanced").AddDecoratorB("Quality").Build()
}

}
