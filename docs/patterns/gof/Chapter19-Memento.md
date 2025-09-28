# Chapter 19: Memento Pattern

## Intent
Without violating encapsulation, capture and externalize an object's internal state so that the object can be restored to this state later.

## Also Known As
- Token
- Snapshot

## Motivation
Sometimes it's necessary to record the internal state of an object. This is required when implementing checkpoints and undo mechanisms that let users back out of tentative operations or recover from errors. You must save state information somewhere so that you can restore objects to their previous states. But objects normally encapsulate some or all of their state, making it inaccessible to other objects and impossible to save externally. Exposing this state would violate encapsulation, which can compromise the application's reliability and extensibility.

The Memento pattern lets you capture an object's internal state without violating encapsulation. The pattern stores this state in a separate memento object, which only the originating object can access.

## Applicability
Use the Memento pattern when:
- A snapshot of (some portion of) an object's state must be saved so that it can be restored to that state later
- A direct interface to obtaining the state would expose implementation details and break the object's encapsulation

## Structure
```
┌──────────────┐        creates      ┌──────────────┐
│  Originator  │───────────────────►│    Memento   │
├──────────────┤                     ├──────────────┤
│ -state       │                     │ -state       │
├──────────────┤                     ├──────────────┤
│ +CreateMemento()                   │ +GetState()  │
│ +RestoreFromMemento()              │ -SetState()  │
└──────────────┘                     └──────────────┘
        ▲                                    ▲
        │                                    │
        │                stores/retrieves    │
        │                                    │
┌──────────────┐                            │
│  Caretaker   │────────────────────────────┘
├──────────────┤
│              │
└──────────────┘
```

## Participants
- **Memento** (`Patterns.GoF.Behavioral.Memento`)
  - Stores internal state of the Originator object
  - Protects against access by objects other than the originator
  - Provides narrow interface to Caretaker, wider interface to Originator
  
- **Originator** (`Patterns.GoF.Behavioral.Originator`)
  - Creates a memento containing a snapshot of its current internal state
  - Uses the memento to restore its internal state
  
- **Caretaker** (`Patterns.GoF.Behavioral.Caretaker`)
  - Responsible for the memento's safekeeping
  - Never operates on or examines the contents of a memento

## Collaborations
- A caretaker requests a memento from an originator, holds it for a time, and passes it back to the originator
- Mementos are passive. Only the originator that created a memento will assign or retrieve its state

## Consequences
The Memento pattern has several consequences:

### Benefits
1. **Preserves encapsulation boundaries** - Avoids exposing information that only an originator should manage
2. **Simplifies the originator** - Keeps the originator from having to manage versions of its state
3. **Provides easy undo/redo** - Makes it straightforward to implement undo and redo operations
4. **Supports complex state restoration** - Can store and restore arbitrarily complex states

### Liabilities
1. **Storage costs** - Mementos might incur considerable overhead if large amounts of state must be stored
2. **Hidden costs in caretaker** - A caretaker might not know how much state is in the memento
3. **Performance overhead** - Creating and restoring mementos can be expensive

## Implementation
Consider the following implementation issues:

### 1. Language Support
In ObjectScript, we can't fully enforce narrow and wide interfaces as in languages with friend classes. We use naming conventions and documentation to indicate which methods should be used by which classes.

### 2. Storing Incremental Changes
For efficiency, store only the incremental changes to the originator's state rather than full snapshots.

### 3. State Serialization
Complex state can be serialized to JSON or other formats for storage and transmission.

## ObjectScript Implementation

### Basic Implementation
```objectscript
/// Basic Memento
Class Patterns.GoF.Behavioral.Memento Extends %RegisteredObject
{
    Property State As %String [ Private ];
    Property StateData As %DynamicObject [ Private ];
    Property Timestamp As %TimeStamp;
    Property CheckpointName As %String;
    
    Method %OnNew(pState As %String = "", pStateData As %DynamicObject = "") As %Status
    {
        Set ..State = pState
        Set ..StateData = pStateData
        Set ..Timestamp = $ZDATETIME($HOROLOG, 3)
        Quit $$$OK
    }
    
    Method GetState() As %String
    {
        Quit ..State
    }
    
    Method GetStateData() As %DynamicObject
    {
        Quit ..StateData
    }
}

/// Basic Originator
Class Patterns.GoF.Behavioral.Originator Extends %RegisteredObject
{
    Method CreateMemento(pCheckpointName As %String = "") As Memento
    {
        Set tState = ..GetStateString()
        Set tStateData = ..GetStateData()
        Set tMemento = ##class(Memento).%New(tState, tStateData)
        Set tMemento.CheckpointName = pCheckpointName
        Quit tMemento
    }
    
    Method RestoreFromMemento(pMemento As Memento) As %Status
    {
        Set tSC = ..ValidateMemento(pMemento)
        If $$$ISERR(tSC) Quit tSC
        
        Set tState = pMemento.GetState()
        Set tStateData = pMemento.GetStateData()
        
        Set tSC = ..SetStateString(tState)
        If $$$ISOK(tSC) {
            Set tSC = ..SetStateData(tStateData)
        }
        
        Quit tSC
    }
}

/// Basic Caretaker
Class Patterns.GoF.Behavioral.Caretaker Extends %RegisteredObject
{
    Property History As list Of Memento [ Private ];
    Property CurrentIndex As %Integer [ InitialExpression = 0 ];
    
    Method Save(pMemento As Memento) As %Status
    {
        Do ..History.Insert(pMemento)
        Set ..CurrentIndex = ..History.Count()
        Quit $$$OK
    }
    
    Method Undo() As Memento
    {
        If ..CurrentIndex > 1 {
            Set ..CurrentIndex = ..CurrentIndex - 1
            Quit ..History.GetAt(..CurrentIndex)
        }
        Quit $$$NULLOREF
    }
}
```

## Sample Code
See our healthcare implementation for a complete example:
- `Patterns.Examples.PatientRecordOriginator` - Patient record with versioning
- `Patterns.Examples.PatientRecordMemento` - HIPAA-compliant state storage
- `Patterns.Examples.PatientRecordCaretaker` - Version management with audit trail

### Example Usage
```objectscript
// Create patient record
Set patient = ##class(PatientRecordOriginator).%New("MRN001")
Set patient.PatientName = "John Doe"
Set patient.Diagnosis = "Initial diagnosis"

// Create first checkpoint
Set memento1 = patient.CreateMemento("Initial state")
Set caretaker = ##class(PatientRecordCaretaker).%New("MRN001")
Do caretaker.AddVersion(memento1)

// Make changes
Set patient.Diagnosis = "Updated diagnosis"
Do patient.AddMedication("Aspirin")

// Create second checkpoint
Set memento2 = patient.CreateMemento("After medication")
Do caretaker.AddVersion(memento2)

// Rollback to first version
Set restoredMemento = caretaker.GetVersion(1)
Do patient.RestoreFromMemento(restoredMemento)
// Patient state is now back to initial
```

## Known Uses
1. **Text editors** - Undo/redo functionality
2. **Database systems** - Transaction rollback and recovery
3. **Games** - Save game state
4. **Workflow engines** - Checkpoint and restore process state
5. **Version control systems** - Store and restore file versions

## Related Patterns
- **Command**: Commands can use mementos to maintain state for undo operations
- **Iterator**: Mementos can be used to store iteration state
- **State**: A memento can store the internal state when transitioning between states
- **Prototype**: Can use mementos to implement deep copying

## Advanced Features in Our Implementation

### 1. Checkpoint History Management
```objectscript
Class Patterns.GoF.Behavioral.MementoHistory
{
    // Named checkpoints with metadata
    Method SaveCheckpoint(pMemento, pName, pMetadata) { }
    
    // Branching support for alternate timelines
    Method CreateBranch(pBranchName, pFromCheckpoint) { }
    
    // Automatic pruning strategies
    Property MaxCheckpoints As %Integer;
    Property MaxAgeInDays As %Integer;
}
```

### 2. State Serialization
```objectscript
Class Patterns.GoF.Behavioral.StateSerializer
{
    // JSON serialization with compression
    ClassMethod SerializeToJSON(pObject) As %String { }
    ClassMethod DeserializeFromJSON(pJSON) As %DynamicObject { }
    
    // Optional compression and encryption
    ClassMethod CompressState(pState) As %String { }
    ClassMethod EncryptState(pState, pKey) As %String { }
}
```

### 3. Healthcare-Specific Features
```objectscript
Class Patterns.Examples.PatientRecordCaretaker
{
    // HIPAA-compliant audit trail
    Method GetAuditTrail(Output pTrail) As %Status { }
    
    // Regulatory snapshots that cannot be deleted
    Method CreateRegulatorySnapshot(pMemento, pReason) { }
    
    // Automatic archival to globals
    Method ArchiveVersion(pVersion, pMemento) { }
}
```

## Summary
The Memento pattern provides a way to capture and restore an object's state without violating encapsulation. It's particularly useful for implementing undo/redo operations, checkpointing, and version control. Our ObjectScript implementation includes advanced features like checkpoint management, state serialization, and healthcare-specific compliance requirements.

The pattern separates the concerns of state storage from the originator's primary responsibilities, making the system more maintainable and flexible. However, care must be taken to manage the storage costs and performance implications of creating and maintaining mementos, especially for objects with large or complex states.
