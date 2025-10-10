/// Patterns of Enterprise Application Architecture - Virtual Proxy Variant
/// 
/// Intent:
/// A proxy object that stands in for the real object and loads it on first access.
/// 
/// Motivation:
/// Virtual Proxy provides transparent lazy loading by implementing the same interface
/// as the real object. The proxy loads the real object on first method call,
/// then delegates all subsequent calls to the loaded object.
/// 
/// Applicability:
/// - Real object is expensive to create or load
/// - Object may not be needed in all scenarios
/// - Want transparent lazy loading without client awareness
/// - Can define proxy interface matching real object
/// 
/// Structure:
/// <example>
/// Set proxy = ##class(VirtualProxy).%New(loaderClass, loaderId)
/// // No load yet
/// Set value = proxy.GetData()  // Triggers load, delegates to real object
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.LazyLoad
/// @see Patterns.PoEAA.ObjectRelational.GhostObject
/// @since 1.0.0
Class Patterns.PoEAA.ObjectRelational.VirtualProxy Extends Patterns.PoEAA.ObjectRelational.LazyLoad
{

/// The real subject object (loaded on demand)
Property RealSubject As %RegisteredObject [ Private ];

/// Class name of the loader to use
Property LoaderClass As %String [ Private ];

/// Identifier to pass to the loader
Property LoaderId As %String [ Private ];

/// Initialize the virtual proxy
/// 
/// @param pLoaderClass Class name that has Load(id) method
/// @param pLoaderId Identifier to load the real object
Method %OnNew(pLoaderClass As %String = "", pLoaderId As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..LoaderClass = pLoaderClass
        Set ..LoaderId = pLoaderId
        Set ..IsLoaded = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Load the real subject object
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
        
        // Load the real object using the loader
        Set ..RealSubject = $CLASSMETHOD(..LoaderClass, "Load", ..LoaderId)
        
        If '$IsObject(..RealSubject) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to load real subject")
            Quit
        }
        
        // Mark as loaded
        Do ..SetLoaded(1)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the real subject, loading if necessary
/// 
/// @return The real subject object
Method GetRealSubject() As %RegisteredObject
{
    // Trigger lazy load
    If '..IsLoaded {
        Do ..Load()
    }
    
    Quit ..RealSubject
}

/// Check if real subject is loaded and available
/// 
/// @return %Boolean - 1 if loaded, 0 if not
Method HasRealSubject() As %Boolean
{
    Quit (..IsLoaded && $IsObject(..RealSubject))
}

}
