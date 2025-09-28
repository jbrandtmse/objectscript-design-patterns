/// Gang of Four State Pattern - Abstract State Base Class
/// 
/// Intent:
/// Allow an object to alter its behavior when its internal state changes.
/// The object will appear to change its class.
/// 
/// Participants:
/// - State (this class): Defines an interface for encapsulating the behavior associated with a particular state of the Context
/// - ConcreteState subclasses: Each subclass implements a behavior associated with a state of the Context
/// - StateContext: Maintains an instance of a ConcreteState subclass that defines the current state
/// 
/// Structure:
/// <example>
/// Class ConcreteStateA Extends Patterns.GoF.Behavioral.State
/// {
///     Method Handle(pContext As StateContext, pRequest As %String)
///     {
///         // State-specific behavior
///         Do pContext.TransitionTo(##class(ConcreteStateB).%New())
///         Quit "Handled in State A"
///     }
/// }
/// </example>
Class Patterns.GoF.Behavioral.State Extends %RegisteredObject [ Abstract ]
{

/// Handle request in this state
/// 
/// @param pContext The context maintaining the state
/// @param pRequest The request to handle
/// @return Response from handling the request
Method Handle(pContext As Patterns.GoF.Behavioral.StateContext, pRequest As %String) [ Abstract ]
{
    Quit ""
}

/// Called when entering this state
/// 
/// @param pContext The context transitioning to this state
/// @return %Status indicating success or failure
Method OnEntry(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Quit $$$OK
}

/// Called when exiting this state
/// 
/// @param pContext The context transitioning from this state
/// @return %Status indicating success or failure
Method OnExit(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    Quit $$$OK
}

/// Check if transition to target state is allowed
/// 
/// @param pTargetState The state to transition to
/// @return %Boolean True if transition is allowed
Method CanTransitionTo(pTargetState As Patterns.GoF.Behavioral.State) As %Boolean
{
    // By default, allow all transitions
    // Subclasses can override to implement guard conditions
    Quit 1
}

/// Get the state name for logging/debugging
/// 
/// @return %String The name of this state
Method GetStateName() As %String
{
    Quit ..%ClassName(1)
}

/// Handle timeout in this state
/// 
/// @param pContext The context that timed out
/// @return %Status indicating success or failure
Method OnTimeout(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    // Default implementation does nothing
    // Subclasses can override to implement timeout behavior
    Quit $$$OK
}

/// Validate state consistency
/// 
/// @param pContext The context to validate
/// @return %Status indicating if state is valid
Method ValidateState(pContext As Patterns.GoF.Behavioral.StateContext) As %Status
{
    // Default implementation assumes state is valid
    // Subclasses can override to implement validation
    Quit $$$OK
}

}
