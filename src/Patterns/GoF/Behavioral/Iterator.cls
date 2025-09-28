/// Gang of Four Iterator Pattern - Abstract Base Iterator
/// 
/// Intent:
/// Provide a way to access the elements of an aggregate object sequentially
/// without exposing its underlying representation.
/// 
/// Applicability:
/// - To access aggregate object's contents without exposing internals
/// - To support multiple traversals of aggregate objects
/// - To provide uniform interface for traversing different aggregate structures
/// 
/// Structure:
/// <example>
/// Set iter = collection.CreateIterator()
/// While iter.HasNext() {
///     Set item = iter.Next()
///     // Process item
/// }
/// </example>
Class Patterns.GoF.Behavioral.Iterator Extends %RegisteredObject [ Abstract ]
{

/// Check if more elements exist in the iteration
Method HasNext() As %Boolean [ Abstract ]
{
        Quit 0
}

/// Get the next element in the iteration
Method Next() As %RegisteredObject [ Abstract ]
{
        Quit $$$NULLOREF
}

/// Reset iterator to the beginning of the collection
Method Reset() As %Status
{
        Quit $$$OK
}

/// Remove current element from the collection (optional operation)
Method Remove() As %Status
{
        Quit $$$ERROR($$$GeneralError, "Remove operation not supported by this iterator")
}

/// Get current element without advancing (optional operation)
Method Current() As %RegisteredObject
{
        Quit $$$NULLOREF
}

}
