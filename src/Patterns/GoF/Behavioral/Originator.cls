/// Gang of Four Memento Pattern - Abstract Originator
/// 
/// Purpose:
/// Base class for objects that need to save and restore their state
/// 
/// Features:
/// - Create mementos of current state
/// - Restore state from mementos
/// - State encapsulation
/// - Support for complex state serialization
Class Patterns.GoF.Behavioral.Originator Extends %RegisteredObject [ Abstract ]
{

/// Create memento of current state
Method CreateMemento(pCheckpointName As %String = "") As Patterns.GoF.Behavioral.Memento [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Restore state from memento
Method RestoreFromMemento(pMemento As Patterns.GoF.Behavioral.Memento) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Get current state as string (for simple state)
Method GetStateString() As %String
{
    Quit ""
}

/// Get current state as dynamic object (for complex state)
Method GetStateData() As %DynamicObject
{
    Quit {}
}

/// Set state from string (for simple state)
Method SetStateString(pState As %String) As %Status
{
    Quit $$$OK
}

/// Set state from dynamic object (for complex state)
Method SetStateData(pStateData As %DynamicObject) As %Status
{
    Quit $$$OK
}

/// Validate that state can be restored
Method ValidateMemento(pMemento As Patterns.GoF.Behavioral.Memento) As %Status
{
    If '$IsObject(pMemento) {
        Quit $$$ERROR($$$GeneralError, "Invalid memento object")
    }
    
    // Check if it's a memento or subclass of memento
    If 'pMemento.%IsA("Patterns.GoF.Behavioral.Memento") {
        Quit $$$ERROR($$$GeneralError, "Invalid memento class type")
    }
    
    Quit $$$OK
}

/// Helper method to create memento with current state
Method CreateMementoInternal(pState As %String = "", pStateData As %DynamicObject = "", pCheckpointName As %String = "") As Patterns.GoF.Behavioral.Memento
{
    Set tMemento = ##class(Patterns.GoF.Behavioral.Memento).%New(pState, pStateData)
    Set tMemento.CheckpointName = pCheckpointName
    Quit tMemento
}

}
