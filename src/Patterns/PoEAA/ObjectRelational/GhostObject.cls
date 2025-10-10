/// Patterns of Enterprise Application Architecture - Ghost Object Variant
/// 
/// Intent:
/// A real object with uninitialized state that loads its data on first property access.
/// 
/// Motivation:
/// Ghost Object is the actual object with a minimal initial state. When any property
/// is accessed, the object triggers loading of its full state. This is different from
/// Virtual Proxy because it IS the real object, not a proxy to it.
/// 
/// Applicability:
/// - Object exists but data loading is expensive
/// - Want the real object reference, not a proxy
/// - Can intercept property access to trigger loading
/// - Object structure doesn't change after loading
/// 
/// Structure:
/// <example>
/// Set ghost = ##class(GhostPatient).%New(patientId)
/// // Ghost exists but data not loaded
/// Set name = ghost.FirstName  // Triggers load via getter
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.LazyLoad
/// @see Patterns.PoEAA.ObjectRelational.VirtualProxy
/// @since 1.0.0
Class Patterns.PoEAA.ObjectRelational.GhostObject Extends Patterns.PoEAA.ObjectRelational.LazyLoad
{

/// Class name of the loader to use
Property LoaderClass As %String [ Private ];

/// Identifier for this object
Property ObjectId As %String [ Private ];

/// Initialize the ghost object with minimal state
/// 
/// @param pLoaderClass Class name that has Load(id) method
/// @param pObjectId Identifier for loading full state
Method %OnNew(pLoaderClass As %String = "", pObjectId As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..LoaderClass = pLoaderClass
        Set ..ObjectId = pObjectId
        Set ..IsLoaded = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Load the full object state
/// 
/// @return %Status indicating success or failure
/// 
/// Subclasses should override this to load their specific properties
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
        
        If (..ObjectId = "") {
            Set tSC = $$$ERROR($$$GeneralError, "ObjectId not configured")
            Quit
        }
        
        // Load the data using the loader
        Set tData = $CLASSMETHOD(..LoaderClass, "Load", ..ObjectId)
        
        If '$IsObject(tData) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to load object data")
            Quit
        }
        
        // Populate this object with loaded data
        Set tSC = ..PopulateFromData(tData)
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Mark as loaded
        Do ..SetLoaded(1)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Populate object properties from loaded data
/// 
/// @param pData Data object containing property values
/// @return %Status indicating success or failure
/// 
/// Subclasses must override this to populate their specific properties
Method PopulateFromData(pData As %RegisteredObject) As %Status
{
    // Default implementation - subclasses should override
    Quit $$$OK
}

/// Ensure object is loaded before accessing properties
/// 
/// Subclasses should call this in property getters
Method EnsureLoaded() As %Status
{
    If '..IsLoaded {
        Quit ..Load()
    }
    
    Quit $$$OK
}

}
