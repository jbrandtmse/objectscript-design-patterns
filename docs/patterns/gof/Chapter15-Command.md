# Chapter 15: Command Pattern

## Intent
Encapsulate a request as an object, thereby letting you parameterize clients with different requests, queue or log requests, and support undoable operations.

## Also Known As
- Action
- Transaction

## Motivation
Sometimes it's necessary to issue requests to objects without knowing anything about the operation being requested or the receiver of the request. For example, user interface toolkits include objects like buttons and menus that carry out a request in response to user input. But the toolkit can't implement the request explicitly in the button or menu, because only applications that use the toolkit know what should be done on which object.

The Command pattern lets toolkit objects make requests of unspecified application objects by turning the request itself into an object. This object can be stored and passed around like other objects. The key to this pattern is an abstract Command class, which declares an interface for executing operations.

## Applicability
Use the Command pattern when you want to:

- **Parameterize objects with an action to perform**: Commands are a convenient way to parameterize objects with operations. You can store a command in a variable and pass it as a parameter.

- **Queue operations, schedule their execution, or execute them remotely**: A Command object can have a lifetime independent of the original request. This enables you to queue it for later execution.

- **Support undo/redo operations**: The Command's Execute operation can store state for reversing its effects in the command itself. The Command interface must have an Undo operation that reverses the effects of Execute.

- **Support logging changes**: By keeping a history of commands, you can reapply them after a crash to recover to a known state.

- **Structure a system around high-level operations built on primitive operations**: Such a structure is common in information systems that support transactions. Commands maintain the transactional nature of operations.

## Structure

### UML Class Diagram
```
    Client                  Invoker
       |                       |
       |                       | commands
       v                       v
    Receiver              Command
       ^                 +Execute()
       |                 +Undo()
       |                     ^
       |                     |
       |            ConcreteCommand
       +------------|  +Execute()
                    |  +Undo()
                    |  -state
```

## Participants

### Command (Patterns.GoF.Behavioral.Command)
- Declares an interface for executing an operation
- Declares an interface for undoing an operation
- May include methods for state management

### ConcreteCommand (LabOrderCommand, MedicationOrderCommand, ImagingOrderCommand, CancelOrderCommand)
- Defines a binding between a Receiver object and an action
- Implements Execute by invoking operations on Receiver
- Implements Undo by restoring previous state
- Maintains state for undo operations

### Client
- Creates ConcreteCommand objects and sets their receivers

### Invoker (CommandInvoker)
- Asks the command to carry out the request
- Maintains command history for undo/redo
- Can batch commands and queue them

### Receiver (ClinicalOrder)
- Knows how to perform the operations associated with a request
- Any class may serve as a Receiver

## Collaborations

- The client creates a ConcreteCommand object and specifies its receiver
- An Invoker object stores the ConcreteCommand object
- The Invoker issues a request by calling Execute on the command
- The ConcreteCommand object invokes operations on its receiver to carry out the request
- For undo support, the ConcreteCommand stores state before Execute and implements Undo to restore it

## Implementation in ObjectScript

### Key Implementation Details

1. **Abstract Command Class**
```objectscript
Class Patterns.GoF.Behavioral.Command Extends %RegisteredObject [ Abstract ]
{
    Property Receiver As Patterns.GoF.Behavioral.Receiver;
    Property PreviousState As %String;
    Property ExecutionTime As %String;
    
    Method Execute() As %Status [ Abstract ]
    Method Undo() As %Status [ Abstract ]
}
```

2. **Command Invoker with History Management**
```objectscript
Class Patterns.GoF.Behavioral.CommandInvoker
{
    Property CommandHistory As list Of Command;
    Property CurrentPosition As %Integer;
    Property BatchMode As %Boolean;
    Property CommandQueue As list Of Command;
    
    Method ExecuteCommand(pCommand As Command) As %Status
    {
        // Execute command
        Set tSC = pCommand.Execute()
        
        // Add to history for undo/redo
        Do ..AddToHistory(pCommand)
        
        Quit tSC
    }
    
    Method Undo() As %Status
    {
        If ..CurrentPosition > 0 {
            Set tCommand = ..CommandHistory.GetAt(..CurrentPosition)
            Set tSC = tCommand.Undo()
            Set ..CurrentPosition = ..CurrentPosition - 1
        }
        Quit tSC
    }
}
```

3. **Healthcare Example - Clinical Order Management**
```objectscript
Class Patterns.Examples.ClinicalOrder Extends Patterns.GoF.Behavioral.Receiver
{
    Property OrderID As %String;
    Property PatientID As %String;
    Property OrderType As %String;
    Property Status As %String;
    Property Priority As %String;
    Property AuditLog As list Of %String;
    
    Method GetState() As %String
    {
        // Serialize current state for undo support
        Set tState = {}
        Set tState.orderID = ..OrderID
        Set tState.status = ..Status
        Set tState.orderType = ..OrderType
        Quit tState.%ToJSON()
    }
}
```

### ObjectScript-Specific Considerations

1. **State Serialization**: Use %DynamicObject for JSON-based state storage
2. **Status Returns**: All methods return %Status for error handling
3. **Try/Catch Blocks**: Comprehensive error handling in command execution
4. **Batch Processing**: Support for atomic batch operations with rollback

## Sample Code

### Basic Command Execution
```objectscript
// Create receiver (clinical order)
Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New()
Set tOrder.PatientID = "P12345"
Set tOrder.Status = "Draft"

// Create command
Set tLabCommand = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder)
Set tLabCommand.TestCode = "CBC"
Set tLabCommand.Priority = "STAT"

// Create invoker
Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()

// Execute command
Set tSC = tInvoker.ExecuteCommand(tLabCommand)

// Undo if needed
Set tSC = tInvoker.Undo()
```

### Batch Command Processing
```objectscript
// Start batch
Do tInvoker.BeginBatch()

// Add multiple commands
Set tCBC = ##class(LabOrderCommand).CreateCBCPanel(tOrder)
Do tInvoker.ExecuteCommand(tCBC)

Set tBMP = ##class(LabOrderCommand).CreateBMPPanel(tOrder)
Do tInvoker.ExecuteCommand(tBMP)

// Execute batch atomically
Set tSC = tInvoker.EndBatch()
```

### Command Queue with Deferred Execution
```objectscript
// Queue commands for later execution
Set tCommand1 = ##class(MedicationOrderCommand).CreateCommonMedication(tOrder, "Aspirin")
Do tInvoker.QueueCommand(tCommand1)

Set tCommand2 = ##class(ImagingOrderCommand).CreateChestXRay(tOrder)
Do tInvoker.QueueCommand(tCommand2)

// Process queue
Set tSC = tInvoker.ProcessQueue()
```

## Known Uses

1. **Clinical Decision Support Systems**: Commands represent clinical actions that can be reviewed, approved, and potentially reversed
2. **Order Entry Systems**: Medical orders as commands with full audit trail
3. **Workflow Engines**: Each workflow step as a command with rollback capability
4. **Integration Engines**: Message processing commands with replay capability

## Related Patterns

### Composite Pattern
- CompositeCommand uses Composite to implement macro commands
- Groups multiple commands into a single command object

### Memento Pattern
- Commands use Memento-like state capture for undo operations
- PreviousState property acts as a memento

### Prototype Pattern
- Commands can be cloned for reuse
- Useful for creating command templates

### Chain of Responsibility
- Commands can be chained for complex workflows
- Each command can decide whether to pass control to the next

## Consequences

### Benefits
1. **Decoupling**: Separates the object that invokes the operation from the one that performs it
2. **Flexibility**: Easy to add new commands without changing existing code
3. **Undo/Redo Support**: Natural implementation of reversible operations
4. **Logging and Auditing**: Commands can be logged for audit trails
5. **Queuing and Scheduling**: Commands can be queued, scheduled, or executed remotely
6. **Macro Commands**: Composite commands enable complex operations

### Liabilities
1. **Proliferation of Classes**: May result in many small command classes
2. **Memory Overhead**: Storing command history can consume memory
3. **Complexity**: Implementing proper undo can be complex for some operations
4. **State Management**: Must carefully manage state for undo operations

## Healthcare-Specific Implementation Notes

The healthcare implementation demonstrates several key aspects:

1. **Order Lifecycle**: Commands manage transitions through order states (Draft→Pending→Active→Completed)
2. **Priority Handling**: STAT orders receive special processing
3. **Audit Requirements**: All actions are logged for regulatory compliance
4. **Safety Checks**: Commands include validation (allergies, drug interactions, etc.)
5. **Cancellation Logic**: Special handling for cancelling active orders
6. **Clinical Protocols**: Common order sets implemented as factory methods

## Testing Considerations

The CommandTest class includes comprehensive tests for:
- Basic command execution and undo
- Undo/redo stack management
- Batch command processing with rollback
- Command queue processing
- Healthcare-specific workflows
- Error handling and validation
- Composite command execution
- State restoration accuracy

## Summary

The Command pattern is particularly valuable in healthcare systems where:
- Actions must be auditable and potentially reversible
- Complex workflows require atomic operations
- Integration with multiple systems requires queuing
- Clinical safety requires validation before execution
- Regulatory compliance requires complete audit trails

The ObjectScript implementation leverages IRIS features like:
- %Status for comprehensive error handling
- %DynamicObject for flexible state storage
- List collections for history management
- Try/Catch for robust error handling
- Factory methods for common command creation
