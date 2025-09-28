# Chapter 20: State Pattern

## Intent
Allow an object to alter its behavior when its internal state changes. The object will appear to change its class.

## Also Known As
Objects for States

## Motivation
Consider a TCPConnection class that represents a network connection. A TCPConnection object can be in one of several different states: Established, Listening, Closed. When a TCPConnection object receives requests from other objects, it responds differently depending on its current state. For example, the effect of an Open request depends on whether the connection is in its Closed state or its Established state. The State pattern describes how TCPConnection can exhibit different behavior in each state.

The key idea in this pattern is to introduce an abstract class called TCPState to represent the states of the network connection. The TCPState class declares an interface common to all classes that represent different operational states. Subclasses of TCPState implement state-specific behavior. For example, the classes TCPEstablished and TCPClosed implement behavior particular to the Established and Closed states of TCPConnection.

## Applicability
Use the State pattern in either of the following cases:
- An object's behavior depends on its state, and it must change its behavior at run-time depending on that state.
- Operations have large, multipart conditional statements that depend on the object's state. This state is usually represented by one or more enumerated constants. Often, several operations will contain this same conditional structure. The State pattern puts each branch of the conditional in a separate class. This lets you treat the object's state as an object in its own right that can vary independently from other objects.

## Structure
```
    Context                     State
    --------                   -------
    |      |------------------>|     |
    |      |                   |     |
    |      |                   |     |
    --------                   -------
                                  ^
                                  |
                        +---------+---------+
                        |                   |
                 ConcreteStateA      ConcreteStateB
                 --------------      --------------
                 |            |      |            |
                 |            |      |            |
                 --------------      --------------
```

## Participants

### State (State.cls)
- Defines an interface for encapsulating the behavior associated with a particular state of the Context

### ConcreteState subclasses (PreAdmissionState, RegistrationState, etc.)
- Each subclass implements a behavior associated with a state of the Context

### Context (StateContext.cls, PatientAdmissionContext.cls)
- Defines the interface of interest to clients
- Maintains an instance of a ConcreteState subclass that defines the current state

## Collaborations
- Context delegates state-specific requests to the current State object
- Context may pass itself as an argument to the State object handling the request. This lets the State object access the context if necessary
- Context is the primary interface for clients. Clients can configure a context with State objects. Once a context is configured, its clients don't have to deal with the State objects directly
- Either Context or the ConcreteState subclasses can decide which state succeeds another and under what circumstances

## Implementation
The State pattern implementation in ObjectScript demonstrates several key aspects:

### 1. State Interface Definition
```objectscript
Class Patterns.GoF.Behavioral.State Extends %RegisteredObject [ Abstract ]
{
    /// Handle request in this state
    Method Handle(pContext As StateContext, pRequest As %String) [ Abstract ]
    {
        Quit ""
    }
    
    /// Called when entering this state
    Method OnEntry(pContext As StateContext) As %Status
    {
        Quit $$$OK
    }
    
    /// Called when exiting this state
    Method OnExit(pContext As StateContext) As %Status
    {
        Quit $$$OK
    }
}
```

### 2. Context Implementation
```objectscript
Class Patterns.GoF.Behavioral.StateContext Extends %RegisteredObject
{
    Property CurrentState As State;
    Property StateHistory As list Of %String;
    Property TransitionCount As %Integer;
    
    Method TransitionTo(pNewState As State) As %Status
    {
        Set tSC = $$$OK
        
        // Exit current state
        If $IsObject(..CurrentState) {
            Set tSC = ..CurrentState.OnExit($this)
            If $$$ISERR(tSC) Quit tSC
        }
        
        // Record in history
        Do ..StateHistory.Insert(pNewState.GetStateName())
        
        // Enter new state
        Set ..CurrentState = pNewState
        Set tSC = pNewState.OnEntry($this)
        
        Set ..TransitionCount = ..TransitionCount + 1
        
        Quit tSC
    }
    
    Method Request(pRequest As %String)
    {
        If $IsObject(..CurrentState) {
            Quit ..CurrentState.Handle($this, pRequest)
        }
        Quit "No state set"
    }
}
```

### 3. Healthcare Workflow Example
The implementation includes a comprehensive healthcare patient admission workflow that demonstrates:
- **PreAdmission**: Insurance verification and consent collection
- **Registration**: Patient demographics and room assignment
- **Triage**: Initial medical assessment and priority assignment
- **Consultation**: Doctor examination and diagnosis
- **Treatment**: Medical procedures and medication administration
- **Discharge**: Final documentation and follow-up scheduling

## Sample Code

### Creating and Using State Pattern
```objectscript
// Create patient admission context
Set context = ##class(Patterns.Examples.PatientAdmissionContext).%New("PAT001", "John Doe")

// Process pre-admission
Set response = context.ProcessAdmission("VERIFY_INSURANCE")
Write "Insurance: ", response, !

Set response = context.ProcessAdmission("COLLECT_CONSENT")
Write "Consent: ", response, !

// Move to next state (Registration)
Set sc = context.MoveToNextState()
If $$$ISOK(sc) {
    Write "Moved to: ", context.GetCurrentStateName(), !
}

// Process registration
Set response = context.ProcessAdmission("SET_DEMOGRAPHICS")
Set response = context.ProcessAdmission("ASSIGN_BED")

// Continue through workflow...
```

### Emergency Override Example
```objectscript
// Handle emergency case
Set context = ##class(Patterns.Examples.PatientAdmissionContext).%New("PAT002", "Jane Smith")

// Skip directly to treatment for emergency
Set sc = context.EmergencyOverride()
If $$$ISOK(sc) {
    Write "Emergency! Jumped to: ", context.GetCurrentStateName(), !
}
```

### State Persistence Example
```objectscript
// Save state for long-running workflow
Set sc = context.SaveState("PatientKey123")

// Later, restore state
Set newContext = ##class(StateContext).%New()
Set sc = newContext.LoadState("PatientKey123")
```

## Known Uses
The State pattern is commonly used in:
- **UI Frameworks**: Managing different states of UI components (enabled, disabled, focused)
- **TCP Connection Management**: Different states of network connections
- **Document Workflow**: Draft, Review, Approved, Published states
- **Game Development**: Character states (idle, walking, running, jumping)
- **Business Process Management**: Order processing, approval workflows

## Related Patterns
- **Flyweight**: The State pattern often uses the Flyweight pattern when State objects have no instance variables—that is, the state they represent is encoded entirely in their type. When states are shared in this way, they are essentially flyweights with no intrinsic state, only behavior.
- **Singleton**: State objects are often Singletons when they don't contain instance-specific state.
- **Strategy**: State pattern is similar to Strategy pattern, but State allows the object to change its behavior based on internal state, while Strategy typically involves selecting an algorithm.

## Consequences

### Benefits
1. **Localizes state-specific behavior**: All behavior associated with a particular state is localized into one class
2. **Makes state transitions explicit**: State changes become explicit events rather than being buried in conditional statements
3. **State objects can be shared**: When state objects have no instance variables, they can be shared among contexts
4. **Simplifies complex conditionals**: Eliminates large conditional statements based on state
5. **Supports Open/Closed Principle**: New states can be added without modifying existing code

### Liabilities
1. **Increased number of classes**: The pattern distributes behavior across several state classes, increasing the number of classes
2. **Less compact code**: The pattern can result in more lines of code than a single class with conditionals
3. **State explosion**: Systems with many states can become complex to manage

## Implementation in ObjectScript

### Key Features
Our ObjectScript implementation includes several enhancements:

1. **State History Tracking**: Maintains a complete history of state transitions
2. **Entry/Exit Actions**: Automatic execution of actions when entering or leaving states
3. **Guard Conditions**: Validation before allowing state transitions
4. **State Persistence**: Save and restore state for long-running workflows
5. **Timeout Handling**: Automatic timeout detection and handling
6. **Emergency Overrides**: Skip normal workflow for urgent cases
7. **Audit Trail**: Complete logging of all state changes

### ObjectScript-Specific Considerations
- **Abstract Methods**: Must have implementation bodies that return appropriate values
- **MultiDimensional Properties**: Used for flexible state data storage without type restrictions
- **Global Storage**: Leverages IRIS globals for persistent state storage
- **Transaction Support**: Ensures atomic state transitions

### Testing
The implementation includes comprehensive unit tests covering:
- Basic state transitions
- Invalid transition handling
- State-specific behavior
- Guard conditions
- Entry/exit actions
- State history tracking
- State persistence/restoration
- Complete healthcare workflow
- Emergency override scenarios
- Timeout handling
- Concurrent access
- Error recovery

## Summary
The State pattern is a powerful behavioral pattern that allows objects to change their behavior based on internal state. It promotes clean, maintainable code by localizing state-specific behavior and making state transitions explicit. The healthcare workflow example demonstrates how the pattern can model complex, real-world processes with multiple states and transitions. The ObjectScript implementation leverages platform-specific features like globals for persistence and provides a robust foundation for state machine implementations.
