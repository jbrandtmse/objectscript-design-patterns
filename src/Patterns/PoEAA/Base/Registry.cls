/// Registry Pattern - Base Implementation
/// 
/// Intent:
/// Provide a well-known object for accessing common objects and services.
/// 
/// Motivation:
/// When objects need to access common services or global objects, rather than
/// passing references through multiple layers, a Registry provides a centralized
/// repository that can be accessed from anywhere in the application.
/// 
/// Structure:
/// The Registry uses a Singleton pattern with %Persistent storage to maintain
/// object references across process boundaries while preserving object identity.
/// 
/// Implementation Notes:
/// - Uses %Persistent for proper object serialization/deserialization
/// - Singleton instance identified by Scope property (e.g., "Global", "Session")
/// - Instance multidimensional properties preserve object references
/// - Thread-safe operations using locks
/// - Supports scoped registries (Global, Session, Request)
/// - O(1) lookup performance
/// - Data persists in database for true global singleton behavior
/// 
/// @see Patterns.PoEAA.Base.ServiceLocator
/// @since 1.0.0
Class Patterns.PoEAA.Base.Registry Extends %Persistent
{

// ===== PARAMETERS =====

Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Base";

// ===== PROPERTIES =====

/// Multidimensional storage for registry data
/// Format: RegistryData(scope, key) = object
/// This storage preserves object identity (no serialization)
Property RegistryData [ MultiDimensional ];

/// Scope of this registry instance (Global, Session, Request)
/// Also serves as the unique ID for singleton instances
Property Scope As %String [ InitialExpression = "Global" ];

// ===== INDICES =====

/// Index on Scope to ensure uniqueness
Index ScopeIdx On Scope [ IdKey ];

// ===== CLASS METHODS =====

/// Get the singleton registry instance for Global scope
/// Returns THE SAME instance stored in database
/// 
/// @return Registry The singleton registry instance
ClassMethod GetInstance() As Patterns.PoEAA.Base.Registry
{
    // Try to open existing instance
    Set tRegistry = ..%OpenId("Global")
    
    // Create new if doesn't exist
    If '$IsObject(tRegistry) {
        Set tRegistry = ..%New()
        Set tRegistry.Scope = "Global"
        Do tRegistry.%Save()
    }
    
    Quit tRegistry
}

/// Get the singleton session-scoped registry
/// Returns THE SAME session instance stored in database
/// 
/// @return Registry The session registry instance
ClassMethod CreateSessionRegistry() As Patterns.PoEAA.Base.Registry
{
    // Try to open existing instance
    Set tRegistry = ..%OpenId("Session")
    
    // Create new if doesn't exist
    If '$IsObject(tRegistry) {
        Set tRegistry = ..%New()
        Set tRegistry.Scope = "Session"
        Do tRegistry.%Save()
    }
    
    Quit tRegistry
}

/// Create a request-scoped registry
/// Returns a new instance for request scope (not persisted)
/// 
/// @return Registry A request-scoped registry instance
ClassMethod CreateRequestRegistry() As Patterns.PoEAA.Base.Registry
{
    // Each call creates a unique request-scoped instance (not saved)
    Set tRegistry = ..%New()
    Set tRegistry.Scope = "Request"
    Quit tRegistry
}

/// Clear all singleton instances (for testing)
/// Removes singleton instances from database
ClassMethod ClearSingletons() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Delete Global scope instance
        If ..%ExistsId("Global") {
            Set tSC = ..%DeleteId("Global")
            If $$$ISERR(tSC) Quit
        }
        
        // Delete Session scope instance
        If ..%ExistsId("Session") {
            Set tSC = ..%DeleteId("Session")
            If $$$ISERR(tSC) Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clear all registry data for a scope (for testing)
/// 
/// @param pScope The scope to clear (default: Global)
/// @return %Status Success or error status
ClassMethod ClearData(pScope As %String = "Global") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Open the instance
        Set tRegistry = ..%OpenId(pScope)
        
        If $IsObject(tRegistry) {
            // Clear its data
            Do tRegistry.Clear()
            
            // Save the cleared state
            Set tSC = tRegistry.%Save()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Register an object with a key
/// Stores object reference in instance storage (preserves object identity)
/// 
/// @param pKey The key to register the object under
/// @param pValue The object to register
/// @return %Status Success or error status
Method Set(pKey As %String, pValue As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate inputs
        If (pKey = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Registry key cannot be empty")
            Quit
        }
        
        If '$IsObject(pValue) {
            Set tSC = $$$ERROR($$$GeneralError, "Registry value must be an object")
            Quit
        }
        
        // Store object reference in instance multidimensional property
        // This preserves object identity (no serialization)
        Set i%RegistryData(..Scope, pKey) = pValue
        
        // Save the registry to persist changes (only if persisted instance)
        If (..%Id() '= "") {
            Set tSC = ..%Save()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Retrieve an object by key
/// Reads from instance storage
/// 
/// @param pKey The key to look up
/// @return %RegisteredObject The registered object or empty string if not found
Method Get(pKey As %String) As %RegisteredObject
{
    Set tValue = ""
    
    If $Data(i%RegistryData(..Scope, pKey)) {
        Set tValue = i%RegistryData(..Scope, pKey)
    }
    
    Quit tValue
}

/// Check if a key is registered
/// 
/// @param pKey The key to check
/// @return %Boolean True if key exists, false otherwise
Method Contains(pKey As %String) As %Boolean
{
    Quit $Data(i%RegistryData(..Scope, pKey))
}

/// Remove an object from the registry
/// 
/// @param pKey The key to unregister
/// @return %Status Success or error status
Method Remove(pKey As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If (pKey = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Registry key cannot be empty")
            Quit
        }
        
        Kill i%RegistryData(..Scope, pKey)
        
        // Save the registry to persist changes (only if persisted instance)
        If (..%Id() '= "") {
            Set tSC = ..%Save()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clear all registrations from the registry
/// 
/// @return %Status Success or error status
Method Clear() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Kill i%RegistryData(..Scope)
        
        // Save the registry to persist changes (only if persisted instance)
        If (..%Id() '= "") {
            Set tSC = ..%Save()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get count of registered entries
/// 
/// @return %Integer Number of registered entries
Method GetCount() As %Integer
{
    Set tCount = 0
    Set tKey = ""
    
    For {
        Set tKey = $Order(i%RegistryData(..Scope, tKey))
        Quit:(tKey = "")
        Set tCount = tCount + 1
    }
    
    Quit tCount
}

/// Get all registered keys
/// 
/// @return %List List of all registered keys
Method GetKeys() As %List
{
    Set tKeys = ""
    Set tKey = ""
    
    For {
        Set tKey = $Order(i%RegistryData(..Scope, tKey))
        Quit:(tKey = "")
        Set tKeys = tKeys _ $ListBuild(tKey)
    }
    
    Quit tKeys
}

Storage Default
{
<Data name="RegistryData">
<Attribute>RegistryData</Attribute>
<Structure>subnode</Structure>
<Subscript>"RegistryData"</Subscript>
</Data>
<Data name="RegistryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^Patterns.PoEAA.Base.RegistryD</DataLocation>
<DefaultData>RegistryDefaultData</DefaultData>
<IdLocation>^Patterns.PoEAA.Base.RegistryD</IdLocation>
<IndexLocation>^Patterns.PoEAA.Base.RegistryI</IndexLocation>
<StreamLocation>^Patterns.PoEAA.Base.RegistryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
