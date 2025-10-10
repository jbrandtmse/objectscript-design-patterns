/// Patterns of Enterprise Application Architecture - Lazy Load Pattern Base
/// 
/// Intent:
/// An object that doesn't contain all of the data you need but knows how to get it.
/// 
/// Motivation:
/// Loading all objects eagerly can be expensive, especially with large object graphs.
/// Lazy Load defers object initialization or data loading until first use.
/// 
/// Applicability:
/// - Loading object data is expensive (network, database, computation)
/// - Object data may not be needed in all use cases
/// - Want to optimize performance by deferring loads
/// - Need transparent loading without client code changes
/// 
/// Key Variants:
/// - Virtual Proxy: Proxy object that loads real object on first access
/// - Ghost Object: Real object with uninitialized state, loads on property access
/// - Value Holder: Generic wrapper that loads value on demand
/// - Lazy Initialization: Object initializes data on first use
/// 
/// Structure:
/// <example>
/// Set lazyObject = ##class(VirtualProxy).%New(loaderId)
/// // No load yet
/// Set value = lazyObject.GetData()  // Triggers load
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.IdentityMap
/// @see Patterns.PoEAA.DataSource.DataMapper
/// @since 1.0.0
Class Patterns.PoEAA.ObjectRelational.LazyLoad Extends %RegisteredObject [ Abstract ]
{

/// Pattern type classification
Parameter PATTERNTYPE = "ObjectRelational";

/// Pattern category from PoEAA
Parameter PATTERNCATEGORY = "Object-Relational Behavioral";

/// Indicates whether the lazy data has been loaded
Property IsLoaded As %Boolean [ InitialExpression = 0 ];

/// Load the deferred data or object
/// 
/// @return %Status indicating success or failure
/// 
/// Subclasses must implement this to define specific loading behavior
Method Load() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Check if the lazy object/data has been loaded
/// 
/// @return %Boolean - 1 if loaded, 0 if not loaded
Method IsLoadedGet() As %Boolean
{
    Quit i%IsLoaded
}

/// Mark the object as loaded (internal use)
/// 
/// @param pLoaded Boolean indicating loaded state
Method SetLoaded(pLoaded As %Boolean = 1) As %Status
{
    Set i%IsLoaded = pLoaded
    Quit $$$OK
}

}
