/// Gang of Four Memento Pattern - State Storage
/// 
/// Intent:
/// Without violating encapsulation, capture and externalize an object's 
/// internal state so that the object can be restored to this state later.
/// 
/// Applicability:
/// - A snapshot of an object's state must be saved for later restoration
/// - Direct interface to obtain state would expose implementation details
/// - Encapsulation boundaries must be preserved
/// 
/// Structure:
/// <example>
/// Set originator = ##class(ConcreteOriginator).%New()
/// Set originator.State = "State1"
/// Set memento = originator.CreateMemento()
/// Set caretaker = ##class(Caretaker).%New()
/// Do caretaker.AddMemento(memento)
/// // Change state
/// Set originator.State = "State2"
/// // Restore
/// Do originator.RestoreFromMemento(caretaker.GetMemento(1))
/// </example>
Class Patterns.GoF.Behavioral.Memento Extends %RegisteredObject
{

/// Private state storage (should not be accessible externally)
Property State As %String [ Private ];

/// Additional state data as dynamic object for complex states
Property StateData As %DynamicObject [ Private ];

/// Timestamp when memento was created
Property Timestamp As %TimeStamp [ ReadOnly ];

/// Optional checkpoint name
Property CheckpointName As %String;

/// Constructor - should only be called by Originator
Method %OnNew(pState As %String = "", pStateData As %DynamicObject = "") As %Status
{
        Set tSC = $$$OK
        
        Try {
            Set ..State = pState
            
            If $IsObject(pStateData) {
                Set ..StateData = pStateData
            } Else {
                Set ..StateData = {}
            }
            
            Set ..Timestamp = $ZDATETIME($HOROLOG, 3)
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Get state - package private for Originator access only
Method GetState() As %String
{
        Quit ..State
}

/// Get state data - package private for Originator access only  
Method GetStateData() As %DynamicObject
{
        Quit ..StateData
}

/// Get size of memento in bytes (approximate)
Method GetSize() As %Integer
{
        Set tSize = $Length(..State)
        
        If $IsObject(..StateData) {
            Set tJSON = ..StateData.%ToJSON()
            Set tSize = tSize + $Length(tJSON)
        }
        
        Quit tSize
}

/// Create a display string for the memento
Method ToString() As %String
{
        Quit "Memento[" _ ..CheckpointName _ " @ " _ ..Timestamp _ "]"
}

}
