/// Identity Map Pattern Implementation
/// 
/// Intent:
/// Ensures that each object gets loaded only once by keeping every loaded object in a map.
/// Looks up objects using the map when referring to them.
/// 
/// Motivation:
/// A common problem in enterprise applications is that multiple parts of the code may need
/// to access the same domain object. If each access loads the object from the database,
/// you can end up with multiple in-memory copies of the same object. This leads to
/// synchronization issues and wasted memory. The Identity Map keeps track of all objects
/// that have been loaded, ensuring only one instance exists per unique identifier.
/// 
/// Structure:
/// The Identity Map maintains a cache of loaded objects indexed by their identifier.
/// When a request is made for an object:
/// 1. Check if the object is in the map
/// 2. If yes, return the cached instance
/// 3. If no, load from data source and add to map
/// 
/// Applicability:
/// - You need to ensure a single in-memory representation of each domain object
/// - Multiple parts of your application access the same objects
/// - You want to reduce database calls through caching
/// - You need reference equality for domain objects
/// 
/// <example>
/// Set map = ##class(Patterns.PoEAA.ObjectRelational.IdentityMap).%New()
/// Do map.Add("123", patient)
/// Set samePatient = map.Get("123")
/// If (patient = samePatient) { Write "Same instance!" }
/// </example>
/// 
/// @see Patterns.PoEAA.DataSource.DataMapper
/// @see Patterns.PoEAA.DataSource.UnitOfWork
/// @since 1.0.0
Class Patterns.PoEAA.ObjectRelational.IdentityMap Extends %RegisteredObject
{

/// Version of the Identity Map pattern implementation
Parameter VERSION = "1.0.0";

/// Pattern type classification
Parameter PATTERNTYPE = "Object-Relational Behavioral";

// ===== PROPERTIES =====

/// Internal cache storage for objects indexed by ID
Property Cache As %ArrayOfObjects;

/// Total number of objects currently in the map
Property Size As %Integer [ InitialExpression = 0 ];

/// Number of cache hits (successful retrievals)
Property HitCount As %Integer [ InitialExpression = 0 ];

/// Number of cache misses (object not found in cache)
Property MissCount As %Integer [ InitialExpression = 0 ];

// ===== CONSTRUCTOR =====

/// Initialize the identity map with an empty cache
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize the cache as an ArrayOfObjects
        Set ..Cache = ##class(%ArrayOfObjects).%New()
        Set ..Size = 0
        Set ..HitCount = 0
        Set ..MissCount = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Add an object to the identity map
/// 
/// @param pId Unique identifier for the object
/// @param pObject The object instance to cache
/// @return %Status indicating success or failure
/// 
/// Example:
/// <example>
/// Set status = map.Add("123", patientObject)
/// </example>
Method Add(pId As %String, pObject As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate inputs
        If (pId = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Object ID cannot be empty")
            Quit
        }
        
        If '$IsObject(pObject) {
            Set tSC = $$$ERROR($$$GeneralError, "Object parameter must be a valid object")
            Quit
        }
        
        // Check if object already exists
        Set tExists = ..Cache.IsDefined(pId)
        
        // Store in cache
        Do ..Cache.SetAt(pObject, pId)
        
        // Update size if this is a new entry
        If 'tExists {
            Set ..Size = ..Size + 1
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Retrieve an object from the identity map by ID
/// 
/// @param pId Unique identifier for the object
/// @return The cached object instance, or null if not found
/// 
/// Example:
/// <example>
/// Set patient = map.Get("123")
/// If $IsObject(patient) { Write "Found!" }
/// </example>
Method Get(pId As %String) As %RegisteredObject
{
    Set tObject = ""
    
    Try {
        // Check if exists in cache
        If ..Cache.IsDefined(pId) {
            Set tObject = ..Cache.GetAt(pId)
            
            // Update hit count
            Set ..HitCount = ..HitCount + 1
        } Else {
            // Update miss count
            Set ..MissCount = ..MissCount + 1
        }
        
    } Catch ex {
        // Log error but return null
        Set tObject = ""
    }
    
    Quit tObject
}

/// Check if an object with the given ID exists in the map
/// 
/// @param pId Unique identifier to check
/// @return 1 if the object exists, 0 otherwise
/// 
/// Example:
/// <example>
/// If map.Contains("123") { Write "Object is cached" }
/// </example>
Method Contains(pId As %String) As %Boolean
{
    Set tExists = 0
    
    Try {
        Set tExists = ..Cache.IsDefined(pId)
        
    } Catch ex {
        Set tExists = 0
    }
    
    Quit tExists
}

/// Remove an object from the identity map
/// 
/// @param pId Unique identifier of the object to remove
/// @return %Status indicating success or failure
/// 
/// Example:
/// <example>
/// Set status = map.Remove("123")
/// </example>
Method Remove(pId As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if exists before removing
        If ..Cache.IsDefined(pId) {
            // Remove from cache
            Do ..Cache.RemoveAt(pId)
            
            // Update size
            Set ..Size = ..Size - 1
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clear all objects from the identity map
/// 
/// @return %Status indicating success or failure
/// 
/// Example:
/// <example>
/// Do map.Clear()
/// </example>
Method Clear() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear the cache
        Do ..Cache.Clear()
        
        // Reset statistics
        Set ..Size = 0
        Set ..HitCount = 0
        Set ..MissCount = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get an object from cache or load it using the provided loader
/// 
/// @param pId Unique identifier for the object
/// @param pLoaderClass Class name that implements a Load(pId) class method
/// @return The object instance (from cache or newly loaded)
/// 
/// Example:
/// <example>
/// Set patient = map.GetOrLoad("123", "Patterns.Examples.Clinical.PatientMapper")
/// </example>
Method GetOrLoad(pId As %String, pLoaderClass As %String) As %RegisteredObject
{
    Set tObject = ""
    
    Try {
        // Check cache first
        Set tObject = ..Get(pId)
        
        // If not in cache, load it
        If '$IsObject(tObject) {
            // Validate loader class
            If (pLoaderClass = "") {
                Quit
            }
            
            // Call loader class method
            Set tObject = $CLASSMETHOD(pLoaderClass, "Load", pId)
            
            // Add to cache if loaded successfully
            If $IsObject(tObject) {
                Do ..Add(pId, tObject)
            }
        }
        
    } Catch ex {
        // Log error but return null
        Set tObject = ""
    }
    
    Quit tObject
}

/// Get cache hit ratio as a percentage
/// 
/// @return Hit ratio (0-100) or -1 if no requests made
/// 
/// Example:
/// <example>
/// Write "Hit ratio: ", map.GetHitRatio(), "%"
/// </example>
Method GetHitRatio() As %Numeric
{
    Set tRatio = -1
    Set tTotal = ..HitCount + ..MissCount
    
    Try {
        If (tTotal > 0) {
            Set tRatio = (..HitCount / tTotal) * 100
        }
        
    } Catch ex {
        Set tRatio = -1
    }
    
    Quit tRatio
}

/// Get statistics about the identity map
/// 
/// @return JSON object with statistics
/// 
/// Example:
/// <example>
/// Set stats = map.GetStatistics()
/// Write stats.%ToJSON()
/// </example>
Method GetStatistics() As %DynamicObject
{
    Set tStats = ""
    
    Try {
        Set tStats = {
            "size": (..Size),
            "hitCount": (..HitCount),
            "missCount": (..MissCount),
            "hitRatio": (..GetHitRatio())
        }
        
    } Catch ex {
        Set tStats = {}
    }
    
    Quit tStats
}

}
