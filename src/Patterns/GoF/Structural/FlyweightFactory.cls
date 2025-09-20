/// Gang of Four Flyweight Pattern - Flyweight Factory
/// 
/// Manages a pool of shared flyweight objects. The factory ensures that flyweights
/// are shared properly by returning existing instances when available, or creating
/// new ones when needed. Uses ObjectScript globals for efficient storage.
/// 
/// Structure:
/// <example>
/// Set flyweight1 = ##class(Patterns.GoF.Structural.FlyweightFactory).GetFlyweight("key1")
/// Set flyweight2 = ##class(Patterns.GoF.Structural.FlyweightFactory).GetFlyweight("key1")
/// // flyweight1 and flyweight2 reference the same object
/// Write ##class(Patterns.GoF.Structural.FlyweightFactory).GetPoolStatistics()
/// </example>
/// 
/// @see Patterns.GoF.Structural.Flyweight
/// @see Patterns.GoF.Structural.ConcreteFlyweight
/// @since 1.0.0
Class Patterns.GoF.Structural.FlyweightFactory Extends %RegisteredObject
{

/// Pool of flyweight instances stored as a property
Property FlyweightPool [ MultiDimensional ];

/// Statistics tracking
Property PoolHits As %Integer [ InitialExpression = 0 ];

Property PoolMisses As %Integer [ InitialExpression = 0 ];

/// Constructor initializes the factory
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize statistics
        Set ..PoolHits = 0
        Set ..PoolMisses = 0
        // Clear any existing pool data
        Kill ..FlyweightPool
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get or create a flyweight for the given key
/// This is the main factory method that implements sharing
/// 
/// @param pKey Unique key identifying the flyweight's intrinsic state
/// @return Flyweight instance (shared if already exists, new if not)
Method GetFlyweight(pKey As %String) As ConcreteFlyweight
{
    Set tFlyweight = ""
    
    Try {
        // Check if flyweight exists in pool
        If $DATA(..FlyweightPool(pKey)) {
            Set tFlyweight = ..FlyweightPool(pKey)
            Set ..PoolHits = ..PoolHits + 1
            Do tFlyweight.IncrementReference()
        }
        Else {
            // Create new flyweight
            Set tFlyweight = ##class(ConcreteFlyweight).%New(pKey)
            Set ..FlyweightPool(pKey) = tFlyweight
            Set ..PoolMisses = ..PoolMisses + 1
        }
    }
    Catch ex {
        // Log error and return null
        Do ##class(Patterns.Utils.Logger).LogError($CLASSNAME(), "GetFlyweight", ex.Name)
    }
    
    Quit tFlyweight
}

/// Get an unshared flyweight (always creates new instance)
/// 
/// @param pState State for the unshared flyweight
/// @return New UnsharedConcreteFlyweight instance
Method GetUnsharedFlyweight(pState As %String) As UnsharedConcreteFlyweight
{
    Set tFlyweight = ##class(UnsharedConcreteFlyweight).%New(pState)
    Quit tFlyweight
}

/// Remove a flyweight from the pool
/// 
/// @param pKey Key of the flyweight to remove
/// @return %Status indicating success or failure
Method RemoveFlyweight(pKey As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $DATA(..FlyweightPool(pKey)) {
            Set tFlyweight = ..FlyweightPool(pKey)
            Set tRefCount = tFlyweight.DecrementReference()
            
            If tRefCount <= 0 {
                Kill ..FlyweightPool(pKey)
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get current pool size
Method GetPoolSize() As %Integer
{
    Set tCount = 0
    Set tKey = ""
    For {
        Set tKey = $ORDER(..FlyweightPool(tKey))
        Quit:tKey=""
        Set tCount = tCount + 1
    }
    Quit tCount
}

/// Get pool statistics as a string
Method GetPoolStatistics() As %String
{
    Set tStats = "FlyweightFactory Statistics: "
    Set tStats = tStats_"Pool Size="_..GetPoolSize()
    Set tStats = tStats_", Hits="_..PoolHits
    Set tStats = tStats_", Misses="_..PoolMisses
    
    If (..PoolHits + ..PoolMisses) > 0 {
        Set tHitRate = $FNUMBER((..PoolHits / (..PoolHits + ..PoolMisses)) * 100, "", 2)
        Set tStats = tStats_", Hit Rate="_tHitRate_"%"
    }
    
    Quit tStats
}

/// Clear all flyweights from the pool
Method ClearPool() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Kill ..FlyweightPool
        Set ..PoolHits = 0
        Set ..PoolMisses = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// List all keys currently in the pool
Method ListPoolKeys() As %String
{
    Set tKeys = ""
    Set tKey = ""
    For {
        Set tKey = $ORDER(..FlyweightPool(tKey))
        Quit:tKey=""
        If tKeys '= "" Set tKeys = tKeys_","
        Set tKeys = tKeys_tKey
    }
    Quit tKeys
}

/// Class method to manage a global-based shared factory instance
/// Note: Since globals cannot store object references directly,
/// we use a class-level cache property to hold instances
/// 
/// @param pKey Key for the flyweight
/// @return Shared flyweight instance
ClassMethod GetSharedFlyweight(pKey As %String) As ConcreteFlyweight
{
    Set tFlyweight = ""
    
    Try {
        // Use a static instance pool stored in process memory
        // Check if we have a cached instance
        If '$DATA(%FlyweightCache) {
            Set %FlyweightCache = ##class(%ArrayOfObjects).%New()
        }
        
        If %FlyweightCache.IsDefined(pKey) {
            Set tFlyweight = %FlyweightCache.GetAt(pKey)
            Do tFlyweight.IncrementReference()
            Set ^Patterns.Flyweight.Stats("Hits") = $GET(^Patterns.Flyweight.Stats("Hits"), 0) + 1
        }
        Else {
            // Create new flyweight and cache it
            Set tFlyweight = ##class(ConcreteFlyweight).%New(pKey)
            Do %FlyweightCache.SetAt(tFlyweight, pKey)
            Set ^Patterns.Flyweight.Stats("Misses") = $GET(^Patterns.Flyweight.Stats("Misses"), 0) + 1
            // Track keys in global for statistics
            Set ^Patterns.Flyweight.Pool(pKey) = 1
        }
    }
    Catch ex {
        // Log error but don't fail
    }
    
    Quit tFlyweight
}

/// Clear the global-based pool
ClassMethod ClearGlobalPool() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Kill ^Patterns.Flyweight.Pool
        Kill ^Patterns.Flyweight.Stats
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get statistics from the global pool
ClassMethod GetGlobalPoolStatistics() As %String
{
    Set tHits = $GET(^Patterns.Flyweight.Stats("Hits"), 0)
    Set tMisses = $GET(^Patterns.Flyweight.Stats("Misses"), 0)
    
    Set tCount = 0
    Set tKey = ""
    For {
        Set tKey = $ORDER(^Patterns.Flyweight.Pool(tKey))
        Quit:tKey=""
        Set tCount = tCount + 1
    }
    
    Set tStats = "Global Pool: Size="_tCount_", Hits="_tHits_", Misses="_tMisses
    
    If (tHits + tMisses) > 0 {
        Set tHitRate = $FNUMBER((tHits / (tHits + tMisses)) * 100, "", 2)
        Set tStats = tStats_", Hit Rate="_tHitRate_"%"
    }
    
    Quit tStats
}

/// Cleanup method to clear the global pool and cache
ClassMethod CleanupGlobalPool() As %Status
{
    Set tSC = $$$OK
    Set tCleaned = 0
    
    Try {
        // Clear the in-memory cache
        If $DATA(%FlyweightCache) {
            Kill %FlyweightCache
        }
        
        // Count and clear global tracking
        Set tKey = ""
        For {
            Set tKey = $ORDER(^Patterns.Flyweight.Pool(tKey))
            Quit:tKey=""
            Set tCleaned = tCleaned + 1
        }
        
        // Clear the tracking globals
        Kill ^Patterns.Flyweight.Pool
        
        If tCleaned > 0 {
            Set ^Patterns.Flyweight.Stats("LastCleanup") = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
            Set ^Patterns.Flyweight.Stats("Cleaned") = tCleaned
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
