/// Patient Identity Map Implementation
/// 
/// Healthcare-specific implementation of the Identity Map pattern for patient objects.
/// Ensures that each patient object is loaded only once per session, preventing
/// duplicate in-memory representations and ensuring reference equality.
/// 
/// Intent:
/// Provide a session-scoped cache for patient objects to prevent duplicate loading
/// and ensure all references to the same patient point to the same object instance.
/// 
/// Motivation:
/// In healthcare applications, patient objects are frequently accessed across multiple
/// operations (admission, vitals recording, medication administration, discharge).
/// Without an identity map, each access could create a new instance, leading to:
/// - Wasted memory and database calls
/// - Synchronization issues when multiple instances are updated
/// - Loss of transactional consistency
/// 
/// The Patient Identity Map ensures a single authoritative instance per patient ID.
/// 
/// <example>
/// // Create identity map
/// Set patientMap = ##class(Patterns.Examples.Clinical.PatientIdentityMap).%New()
/// 
/// // First access loads from database
/// Set patient1 = patientMap.GetOrLoadPatient("123")
/// 
/// // Second access returns cached instance
/// Set patient2 = patientMap.GetOrLoadPatient("123")
/// 
/// // Verify same instance (reference equality)
/// If (patient1 = patient2) { Write "Same instance!" }
/// 
/// // Clear cache when session ends
/// Do patientMap.Clear()
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.IdentityMap
/// @see Patterns.Examples.Clinical.PatientActiveRecord
/// @since 1.0.0
Class Patterns.Examples.Clinical.PatientIdentityMap Extends Patterns.PoEAA.ObjectRelational.IdentityMap
{

/// Scope of this identity map (Session, Request, Transaction)
Parameter SCOPE = "Session";

/// Maximum cache size to prevent memory issues
Parameter MAXCACHESIZE = 1000;

// ===== PROPERTIES =====

/// Track when cache was last warmed
Property LastWarmTime As %TimeStamp;

/// List of patient IDs that are frequently accessed (for cache warming)
Property FrequentPatientIds As %ListOfDataTypes;

// ===== CONSTRUCTOR =====

/// Initialize patient identity map with enhanced tracking
Method %OnNew() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        // Initialize frequent patient tracking
        Set ..FrequentPatientIds = ##class(%ListOfDataTypes).%New()
        Set ..LastWarmTime = ""
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Get patient from cache or load from database
/// 
/// @param pPatientId Patient identifier (ID or MRN)
/// @return PatientActiveRecord instance or empty string if not found
/// 
/// Example:
/// <example>
/// Set patient = patientMap.GetOrLoadPatient("123")
/// </example>
Method GetOrLoadPatient(pPatientId As %String) As Patterns.Examples.Clinical.PatientActiveRecord
{
    Set tPatient = ""
    
    Try {
        // Check cache first
        Set tPatient = ..Get(pPatientId)
        
        // If not in cache, load from database
        If '$IsObject(tPatient) {
            // Try loading as ID first
            Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).Load(pPatientId)
            
            // If not found by ID, try as MRN
            If '$IsObject(tPatient) {
                Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).FindByMRN(pPatientId)
            }
            
            // Add to cache if loaded successfully
            If $IsObject(tPatient) {
                Do ..Add(pPatientId, tPatient)
                
                // Track frequent access
                Do ..TrackFrequentAccess(pPatientId)
            }
        }
        
        // Check cache size limits
        Do ..EnforceCacheLimit()
        
    } Catch ex {
        Set tPatient = ""
    }
    
    Quit tPatient
}

/// Invalidate cache entry when patient is updated
/// 
/// @param pPatientId Patient identifier to invalidate
/// @return %Status indicating success or failure
/// 
/// Example:
/// <example>
/// Do patient.Update()
/// Do patientMap.InvalidatePatient(patient.ID)
/// </example>
Method InvalidatePatient(pPatientId As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Remove from cache
        Set tSC = ..Remove(pPatientId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Warm cache with frequently accessed patients
/// 
/// @param pPatientIds Optional list of patient IDs to pre-load
/// @return %Status indicating success or failure
/// 
/// Example:
/// <example>
/// Set ids = $ListBuild("123", "456", "789")
/// Do patientMap.WarmCache(ids)
/// </example>
Method WarmCache(pPatientIds As %List = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Use provided IDs or frequent access list
        Set tIdList = pPatientIds
        If (tIdList = "") {
            // Build list from frequent access tracking
            Set tIdList = ""
            For i=1:1:..FrequentPatientIds.Count() {
                Set tId = ..FrequentPatientIds.GetAt(i)
                Set tIdList = tIdList _ $ListBuild(tId)
            }
        }
        
        // Pre-load each patient
        Set tPtr = 0
        While $ListNext(tIdList, tPtr, tId) {
            // Load into cache (will use GetOrLoadPatient logic)
            Set tPatient = ..GetOrLoadPatient(tId)
        }
        
        // Update warm time
        Set ..LastWarmTime = $ZDateTime($Horolog, 3)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get cache statistics specific to patient caching
/// 
/// @return JSON object with patient cache statistics
/// 
/// Example:
/// <example>
/// Set stats = patientMap.GetPatientCacheStatistics()
/// Write stats.%ToJSON()
/// </example>
Method GetPatientCacheStatistics() As %DynamicObject
{
    Set tStats = ""
    
    Try {
        // Get base statistics
        Set tBaseStats = ..GetStatistics()
        
        // Add patient-specific information
        Set tStats = {
            "scope": (..#SCOPE),
            "maxCacheSize": (..#MAXCACHESIZE),
            "currentSize": (..Size),
            "hitCount": (..HitCount),
            "missCount": (..MissCount),
            "hitRatio": (..GetHitRatio()),
            "lastWarmTime": (..LastWarmTime),
            "frequentPatientCount": (..FrequentPatientIds.Count())
        }
        
    } Catch ex {
        Set tStats = {}
    }
    
    Quit tStats
}

/// Clear cache and reset for new session
/// 
/// @return %Status indicating success or failure
/// 
/// Example:
/// <example>
/// // Clear cache on session end
/// Do patientMap.ClearSession()
/// </example>
Method ClearSession() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear the cache
        Set tSC = ..Clear()
        If $$$ISERR(tSC) Quit
        
        // Reset session-specific tracking
        Do ..FrequentPatientIds.Clear()
        Set ..LastWarmTime = ""
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PRIVATE METHODS =====

/// Track frequently accessed patient IDs
/// 
/// @param pPatientId Patient ID to track
Method TrackFrequentAccess(pPatientId As %String) [ Private ]
{
    Try {
        // Only track if not already in frequent list
        Set tFound = 0
        For i=1:1:..FrequentPatientIds.Count() {
            If (..FrequentPatientIds.GetAt(i) = pPatientId) {
                Set tFound = 1
                Quit
            }
        }
        
        // Add to frequent list if new
        If 'tFound {
            Do ..FrequentPatientIds.Insert(pPatientId)
            
            // Keep frequent list manageable (top 20)
            If (..FrequentPatientIds.Count() > 20) {
                Do ..FrequentPatientIds.RemoveAt(1)
            }
        }
        
    } Catch ex {
        // Ignore tracking errors
    }
    
    Quit
}

/// Enforce maximum cache size limit
Method EnforceCacheLimit() [ Private ]
{
    Try {
        // Check if cache exceeded max size
        If (..Size > ..#MAXCACHESIZE) {
            // Simple strategy: clear oldest entries
            // In production, could use LRU or other eviction strategies
            
            // For now, clear 10% of cache
            Set tEvictCount = (..#MAXCACHESIZE * 0.1)
            Set tEvicted = 0
            
            // Iterate and remove entries (simple FIFO)
            Set tKey = ""
            For {
                Set tKey = ..Cache.Next(tKey)
                If (tKey = "") Quit
                
                Do ..Remove(tKey)
                Set tEvicted = tEvicted + 1
                
                If (tEvicted >= tEvictCount) Quit
            }
        }
        
    } Catch ex {
        // Ignore eviction errors
    }
    
    Quit
}

}
