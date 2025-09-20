/// Gang of Four Flyweight Pattern - Base Class for Memory Optimization
/// 
/// Intent:
/// Use sharing to support large numbers of fine-grained objects efficiently.
/// 
/// Applicability:
/// - An application uses a large number of objects
/// - Storage costs are high because of the sheer quantity of objects
/// - Most object state can be made extrinsic
/// - Groups of objects may be replaced by relatively few shared objects
/// 
/// Structure:
/// <example>
/// Set flyweight = ##class(Patterns.GoF.Structural.FlyweightFactory).GetFlyweight("key")
/// Set result = flyweight.Operation(extrinsicState)
/// </example>
/// 
/// @see Patterns.GoF.Structural.FlyweightFactory
/// @since 1.0.0
Class Patterns.GoF.Structural.Flyweight Extends %RegisteredObject [ Abstract ]
{

/// Intrinsic state - shared among flyweight instances
/// This state is stored in the flyweight and is independent of context
Property IntrinsicState As %String;

/// Operation using extrinsic state
/// The extrinsic state is passed to the flyweight method but not stored
/// 
/// @param pExtrinsicState Context-specific state passed from client
/// @return Operation result combining intrinsic and extrinsic state
Method Operation(pExtrinsicState As %String) As %String [ Abstract ]
{
    Quit ""
}

/// Display internal state for debugging
Method Display() As %String
{
    Quit "Flyweight with intrinsic state: "_..IntrinsicState
}

}
