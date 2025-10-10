/// Patterns of Enterprise Application Architecture - Value Holder Variant
/// 
/// Intent:
/// A generic wrapper that holds a value and loads it on demand when accessed.
/// 
/// Motivation:
/// Value Holder provides a reusable, generic mechanism for lazy loading any value.
/// It wraps the actual value and defers loading until getValue() is called.
/// This is the most flexible variant as it doesn't require proxy or ghost implementations.
/// 
/// Applicability:
/// - Need generic lazy loading without specialized proxy classes
/// - Value computation or loading is expensive
/// - Value may not be needed in all code paths
/// - Want reusable lazy loading mechanism
/// 
/// Structure:
/// <example>
/// Set holder = ##class(ValueHolder).%New(loaderClass, loaderId)
/// // No load yet
/// Set value = holder.GetValue()  // Triggers load
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.LazyLoad
/// @see Patterns.PoEAA.ObjectRelational.VirtualProxy
/// @since 1.0.0
Class Patterns.PoEAA.ObjectRelational.ValueHolder Extends Patterns.PoEAA.ObjectRelational.LazyLoad
{

/// The held value (loaded on demand)
Property Value As %RegisteredObject [ Private ];

/// Class name of the loader to use
Property LoaderClass As %String [ Private ];

/// Identifier to pass to the loader
Property LoaderId As %String [ Private ];

/// Optional loader method name (defaults to "Load")
Property LoaderMethod As %String [ InitialExpression = "Load", Private ];

/// Initialize the value holder
/// 
/// @param pLoaderClass Class name that has loader method
/// @param pLoaderId Identifier to pass to loader
/// @param pLoaderMethod Optional method name (default: "Load")
Method %OnNew(pLoaderClass As %String = "", pLoaderId As %String = "", pLoaderMethod As %String = "Load") As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..LoaderClass = pLoaderClass
        Set ..LoaderId = pLoaderId
        Set ..LoaderMethod = pLoaderMethod
        Set ..IsLoaded = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Load the value using the configured loader
/// 
/// @return %Status indicating success or failure
Method Load() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Don't load if already loaded
        If ..IsLoaded {
            Quit
        }
        
        // Validate loader configuration
        If (..LoaderClass = "") {
            Set tSC = $$$ERROR($$$GeneralError, "LoaderClass not configured")
            Quit
        }
        
        // Load the value using the loader
        Set ..Value = $CLASSMETHOD(..LoaderClass, ..LoaderMethod, ..LoaderId)
        
        // Note: Value can be null/empty, that's valid
        // Mark as loaded even if value is null
        Do ..SetLoaded(1)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the value, loading if necessary
/// 
/// @return The held value
Method GetValue() As %RegisteredObject
{
    // Trigger lazy load
    If '..IsLoaded {
        Do ..Load()
    }
    
    Quit ..Value
}

/// Set the value directly (useful for testing or pre-loading)
/// 
/// @param pValue The value to set
Method SetValue(pValue As %RegisteredObject) As %Status
{
    Set ..Value = pValue
    Do ..SetLoaded(1)
    Quit $$$OK
}

/// Check if value has been set (may still be null)
/// 
/// @return %Boolean - 1 if loaded, 0 if not
Method HasValue() As %Boolean
{
    Quit ..IsLoaded
}

}
