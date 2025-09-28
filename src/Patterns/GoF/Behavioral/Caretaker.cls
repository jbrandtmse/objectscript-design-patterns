/// Gang of Four Memento Pattern - Caretaker
/// 
/// Purpose:
/// Manages mementos without knowing their internal structure
/// 
/// Features:
/// - Store and retrieve mementos
/// - Multiple checkpoint support
/// - Checkpoint naming and management
/// - History limitation and pruning
Class Patterns.GoF.Behavioral.Caretaker Extends %RegisteredObject
{

/// Collection of saved mementos
Property Mementos As %ListOfObjects [ Private ];

/// Maximum number of mementos to keep (0 = unlimited)
Property MaxMementos As %Integer [ InitialExpression = 10 ];

/// Current position in history for undo/redo
Property CurrentIndex As %Integer [ InitialExpression = 0, Private ];

/// Constructor
Method %OnNew(pMaxMementos As %Integer = 10) As %Status
{
        Set ..Mementos = ##class(%ListOfObjects).%New()
        Set ..MaxMementos = pMaxMementos
        Quit $$$OK
}

/// Add memento to history
Method AddMemento(pMemento As Patterns.GoF.Behavioral.Memento, pCheckpointName As %String = "") As %Status
{
        Set tSC = $$$OK
        
        Try {
            If '$IsObject(pMemento) {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid memento object")
                Quit
            }
            
            // Set checkpoint name if provided
            If pCheckpointName '= "" {
                Set pMemento.CheckpointName = pCheckpointName
            }
            
            // Add memento
            Do ..Mementos.Insert(pMemento)
            Set ..CurrentIndex = ..Mementos.Count()
            
            // Prune old mementos if limit exceeded
            If (..MaxMementos > 0) && (..Mementos.Count() > ..MaxMementos) {
                Do ..PruneOldestMementos()
            }
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Get memento by index (1-based)
Method GetMemento(pIndex As %Integer) As Patterns.GoF.Behavioral.Memento
{
        If (pIndex < 1) || (pIndex > ..Mementos.Count()) {
            Quit $$$NULLOREF
        }
        
        Quit ..Mementos.GetAt(pIndex)
}

/// Get memento by checkpoint name
Method GetMementoByName(pCheckpointName As %String) As Patterns.GoF.Behavioral.Memento
{
        Set tResult = $$$NULLOREF
        
        For i=1:1:..Mementos.Count() {
            Set tMemento = ..Mementos.GetAt(i)
            If tMemento.CheckpointName = pCheckpointName {
                Set tResult = tMemento
                Quit
            }
        }
        
        Quit tResult
}

/// Get the most recent memento
Method GetLatestMemento() As Patterns.GoF.Behavioral.Memento
{
        If ..Mementos.Count() = 0 {
            Quit $$$NULLOREF
        }
        
        Quit ..Mementos.GetAt(..Mementos.Count())
}

/// Get previous memento for undo operation
Method GetPreviousMemento() As Patterns.GoF.Behavioral.Memento
{
        If ..CurrentIndex > 1 {
            Set ..CurrentIndex = ..CurrentIndex - 1
            Quit ..Mementos.GetAt(..CurrentIndex)
        }
        
        Quit $$$NULLOREF
}

/// Get next memento for redo operation
Method GetNextMemento() As Patterns.GoF.Behavioral.Memento
{
        If ..CurrentIndex < ..Mementos.Count() {
            Set ..CurrentIndex = ..CurrentIndex + 1
            Quit ..Mementos.GetAt(..CurrentIndex)
        }
        
        Quit $$$NULLOREF
}

/// Clear all mementos
Method ClearHistory() As %Status
{
        Do ..Mementos.Clear()
        Set ..CurrentIndex = 0
        Quit $$$OK
}

/// Get number of stored mementos
Method GetMementoCount() As %Integer
{
        Quit ..Mementos.Count()
}

/// Remove oldest mementos to maintain limit
Method PruneOldestMementos() As %Status [ Private ]
{
        While ..Mementos.Count() > ..MaxMementos {
            Do ..Mementos.RemoveAt(1)
            If ..CurrentIndex > 1 {
                Set ..CurrentIndex = ..CurrentIndex - 1
            }
        }
        
        Quit $$$OK
}

/// Get list of all checkpoint names
Method GetCheckpointNames() As %ListOfDataTypes
{
        Set tList = ##class(%ListOfDataTypes).%New()
        
        For i=1:1:..Mementos.Count() {
            Set tMemento = ..Mementos.GetAt(i)
            If tMemento.CheckpointName '= "" {
                Do tList.Insert(tMemento.CheckpointName)
            }
        }
        
        Quit tList
}

/// Get total size of all mementos
Method GetTotalSize() As %Integer
{
        Set tTotalSize = 0
        
        For i=1:1:..Mementos.Count() {
            Set tMemento = ..Mementos.GetAt(i)
            Set tTotalSize = tTotalSize + tMemento.GetSize()
        }
        
        Quit tTotalSize
}

}
