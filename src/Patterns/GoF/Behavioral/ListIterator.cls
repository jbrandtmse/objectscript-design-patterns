/// Gang of Four Iterator Pattern - List Iterator Implementation
/// 
/// Purpose:
/// Provides iteration capability for %Collection.ListOfObj and %Collection.ListOfDataTypes
/// 
/// Features:
/// - Forward and backward iteration
/// - Current position tracking
/// - Concurrent modification detection
/// - Optional filtering with predicates
Class Patterns.GoF.Behavioral.ListIterator Extends Patterns.GoF.Behavioral.Iterator
{

/// The list collection to iterate over
Property Collection As %Collection.AbstractList [ Private ];

/// Current position in the list (1-based indexing)
Property CurrentIndex As %Integer [ InitialExpression = 0, Private ];

/// Total count of elements
Property Count As %Integer [ Private ];

/// Modification count for concurrent modification detection
Property ModCount As %Integer [ Private ];

/// Optional filter predicate (class:method format)
Property FilterPredicate As %String;

/// Direction of iteration (1 = forward, -1 = backward)
Property Direction As %Integer [ InitialExpression = 1, Private ];

/// Constructor
Method %OnNew(pCollection As %Collection.AbstractList, pFilterPredicate As %String = "") As %Status
{
        Set tSC = $$$OK
        
        Try {
            If '$IsObject(pCollection) {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid collection object")
                Quit
            }
            
            Set ..Collection = pCollection
            Set ..Count = pCollection.Count()
            Set ..ModCount = ..GetModificationCount()
            Set ..FilterPredicate = pFilterPredicate
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Check if more elements exist
Method HasNext() As %Boolean
{
        // Check for concurrent modification
        If (..GetModificationCount() '= ..ModCount) {
            Throw ##class(%Exception.General).%New("ConcurrentModificationException", 5001, , "Collection was modified during iteration")
        }
        
        Set tHasNext = 0
        
        If ..Direction = 1 {
            // Forward iteration
            Set tNextIndex = ..CurrentIndex + 1
            While (tNextIndex <= ..Count) {
                If ..FilterPredicate = "" {
                    Set tHasNext = 1
                    Quit
                }
                // Check if element matches filter
                Set tElement = ..Collection.GetAt(tNextIndex)
                If ..MatchesFilter(tElement) {
                    Set tHasNext = 1
                    Quit
                }
                Set tNextIndex = tNextIndex + 1
            }
        } Else {
            // Backward iteration
            Set tNextIndex = ..CurrentIndex - 1
            While (tNextIndex >= 1) {
                If ..FilterPredicate = "" {
                    Set tHasNext = 1
                    Quit
                }
                // Check if element matches filter
                Set tElement = ..Collection.GetAt(tNextIndex)
                If ..MatchesFilter(tElement) {
                    Set tHasNext = 1
                    Quit
                }
                Set tNextIndex = tNextIndex - 1
            }
        }
        
        Quit tHasNext
}

/// Get the next element
Method Next() As %RegisteredObject
{
        Set tElement = $$$NULLOREF
        
        // Check for concurrent modification
        If (..GetModificationCount() '= ..ModCount) {
            Throw ##class(%Exception.General).%New("ConcurrentModificationException", 5001, , "Collection was modified during iteration")
        }
        
        If '..HasNext() {
            // Return null object instead of throwing exception for empty collections
            Quit $$$NULLOREF
        }
        
        If ..Direction = 1 {
            // Forward iteration
            Set ..CurrentIndex = ..CurrentIndex + 1
            While (..CurrentIndex <= ..Count) {
                Set tElement = ..Collection.GetAt(..CurrentIndex)
                If (..FilterPredicate = "") || ..MatchesFilter(tElement) {
                    Quit
                }
                Set ..CurrentIndex = ..CurrentIndex + 1
            }
        } Else {
            // Backward iteration
            Set ..CurrentIndex = ..CurrentIndex - 1
            While (..CurrentIndex >= 1) {
                Set tElement = ..Collection.GetAt(..CurrentIndex)
                If (..FilterPredicate = "") || ..MatchesFilter(tElement) {
                    Quit
                }
                Set ..CurrentIndex = ..CurrentIndex - 1
            }
        }
        
        Quit tElement
}

/// Get current element without advancing
Method Current() As %RegisteredObject
{
        If (..CurrentIndex < 1) || (..CurrentIndex > ..Count) {
            Quit $$$NULLOREF
        }
        Quit ..Collection.GetAt(..CurrentIndex)
}

/// Reset iterator to beginning
Method Reset() As %Status
{
        Set ..CurrentIndex = 0
        Set ..ModCount = ..GetModificationCount()
        Quit $$$OK
}

/// Remove current element from collection
Method Remove() As %Status
{
        Set tSC = $$$OK
        
        Try {
            If (..CurrentIndex < 1) || (..CurrentIndex > ..Count) {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid iterator position")
                Quit
            }
            
            // RemoveAt returns the removed element (or empty string on error), not a status
            Set tRemovedItem = ..Collection.RemoveAt(..CurrentIndex)
            // Check if removal was successful by checking new count
            Set newCount = ..Collection.Count()
            If newCount = (..Count - 1) {
                Set ..Count = newCount
                Set ..ModCount = ..GetModificationCount()
                If ..Direction = 1 {
                    // Adjust index after removal for forward iteration
                    Set ..CurrentIndex = ..CurrentIndex - 1
                }
                Set tSC = $$$OK
            } Else {
                Set tSC = $$$ERROR($$$GeneralError, "Failed to remove element")
            }
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Set iteration direction
Method SetDirection(pDirection As %Integer) As %Status
{
        If (pDirection '= 1) && (pDirection '= -1) {
            Quit $$$ERROR($$$GeneralError, "Invalid direction. Use 1 for forward, -1 for backward")
        }
        Set ..Direction = pDirection
        Quit $$$OK
}

/// Check if element matches filter predicate
Method MatchesFilter(pElement As %RegisteredObject) As %Boolean [ Private ]
{
        If ..FilterPredicate = "" {
            Quit 1
        }
        
        // FilterPredicate format: "ClassName:MethodName"
        Set tClass = $Piece(..FilterPredicate, ":", 1)
        Set tMethod = $Piece(..FilterPredicate, ":", 2)
        
        If (tClass = "") || (tMethod = "") {
            Quit 1
        }
        
        Try {
            Set tResult = $ClassMethod(tClass, tMethod, pElement)
        } Catch {
            Set tResult = 1
        }
        
        Quit tResult
}

/// Get modification count for concurrent modification detection
Method GetModificationCount() As %Integer [ Private ]
{
        // Simple implementation using collection count
        // Could be enhanced with version tracking
        Quit ..Collection.Count()
}

}
