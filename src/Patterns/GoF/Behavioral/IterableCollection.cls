/// Gang of Four Iterator Pattern - Iterable Collection Interface
/// 
/// Intent:
/// Define the interface for collections that can be iterated over,
/// providing a standard way to create iterators for different collection types.
/// 
/// Applicability:
/// - When collections need to provide iteration capability
/// - To decouple iteration logic from collection implementation
/// - To support multiple simultaneous iterations
/// 
/// Structure:
/// <example>
/// Set collection = ##class(MyCollection).%New()
/// Set iterator = collection.CreateIterator()
/// While iterator.HasNext() {
///     Set item = iterator.Next()
///     // Process item
/// }
/// </example>
Class Patterns.GoF.Behavioral.IterableCollection Extends %RegisteredObject [ Abstract ]
{

/// Create and return an iterator for this collection
Method CreateIterator() As Patterns.GoF.Behavioral.Iterator [ Abstract ]
{
        Quit $$$NULLOREF
}

/// Get the size of the collection
Method Size() As %Integer
{
        Quit 0
}

/// Check if the collection is empty
Method IsEmpty() As %Boolean
{
        Quit (..Size() = 0)
}

/// Clear all elements from the collection (optional operation)
Method Clear() As %Status
{
        Quit $$$ERROR($$$GeneralError, "Clear operation not supported by this collection")
}

/// Check if the collection contains a specific element (optional operation)
Method Contains(pElement As %RegisteredObject) As %Boolean
{
        Quit 0
}

}
