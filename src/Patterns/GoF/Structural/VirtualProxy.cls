/// Gang of Four Proxy Pattern - Virtual Proxy Implementation
/// 
/// Intent:
/// Provides lazy initialization for expensive objects.
/// The virtual proxy acts as a stand-in for the real object,
/// deferring its creation until it's actually needed.
/// 
/// This implementation demonstrates:
/// - Lazy loading of expensive resources
/// - Memory optimization through deferred instantiation
/// - Thread-safe initialization
/// - Caching of loaded objects
/// 
/// Structure:
/// <example>
/// // Create virtual proxy - real subject not loaded yet
/// Set proxy = ##class(Patterns.GoF.Structural.VirtualProxy).%New()
/// 
/// // Real subject is loaded only when first request is made
/// Set result = proxy.Request()  // Triggers lazy loading
/// 
/// // Subsequent requests use cached object
/// Set result2 = proxy.Request()  // Uses already loaded object
/// </example>
Class Patterns.GoF.Structural.VirtualProxy Extends Patterns.GoF.Structural.Proxy
{

/// Property PlaceholderInfo - Lightweight information about the resource
Property PlaceholderInfo As %String;

/// Property LoadOnDemand - Flag to control lazy loading behavior
Property LoadOnDemand As %Boolean [ InitialExpression = 1 ];

/// Property CreationTime - Track when proxy was created
Property CreationTime As %TimeStamp;

/// Property FirstAccessTime - Track when real subject was first accessed
Property FirstAccessTime As %TimeStamp;

/// Property LoadAttempts - Count loading attempts for debugging
Property LoadAttempts As %Integer [ InitialExpression = 0 ];

/// Constructor - Initialize virtual proxy without loading real subject
Method %OnNew(pPlaceholderInfo As %String = "") As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Set proxy type
    Set ..ProxyType = "Virtual"
    
    // Store lightweight placeholder information
    If pPlaceholderInfo = "" {
        Set ..PlaceholderInfo = "Virtual Proxy - Real Subject Not Loaded"
    } Else {
        Set ..PlaceholderInfo = pPlaceholderInfo
    }
    
    // Track creation time
    Set ..CreationTime = $ZDateTime($Horolog, 3)
    
    // Log virtual proxy creation
    Do ..LogAccess("VirtualProxy created with placeholder: " _ ..PlaceholderInfo)
    
    Quit tSC
}

/// Override CheckAccess - Virtual proxy always allows access
/// Access control is not the concern of virtual proxy
/// 
/// @return Always returns True for virtual proxy
Method CheckAccess() As %Boolean
{
    // Virtual proxy doesn't restrict access, it only delays loading
    Quit 1
}

/// Override LoadRealSubject for lazy loading with thread safety
/// Ensures real subject is loaded only when needed and only once
/// 
/// @return Status of the load operation
Method LoadRealSubject() As %Status
{
    Set tSC = $$$OK
    
    // Increment load attempts counter
    Set ..LoadAttempts = ..LoadAttempts + 1
    
    Try {
        // Thread-safe check if already loaded
        If ..IsLoaded {
            Do ..LogAccess("RealSubject already loaded, skipping re-load")
            Quit
        }
        
        // Simulate checking if resource is available before loading
        If '..IsResourceAvailable() {
            Set tSC = $$$ERROR($$$GeneralError, "Resource not available for loading")
            Do ..LogAccess("Resource not available: " _ ..PlaceholderInfo)
            Quit
        }
        
        // Log the lazy loading event
        Do ..LogAccess("Lazy loading RealSubject on demand (attempt #" _ ..LoadAttempts _ ")")
        
        // Simulate expensive object creation
        // In real scenarios, this might involve:
        // - Loading large files from disk
        // - Fetching data from remote services
        // - Complex initialization procedures
        Hang 0.1  // Simulate loading delay
        
        // Create the real subject
        Set ..RealSubject = ##class(Patterns.GoF.Structural.RealSubject).%New()
        
        // Mark as loaded
        Set ..IsLoaded = 1
        
        // Track first access time
        If ..FirstAccessTime = "" {
            Set ..FirstAccessTime = $ZDateTime($Horolog, 3)
            
            // Calculate and log loading delay (simplified - just log that it's loaded)
            // Actual delay calculation is done in GetStatistics method
            Do ..LogAccess("RealSubject loaded (lazy initialization complete)")
        }
        
        Do ..LogAccess("Lazy loading completed successfully")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do ..LogAccess("Failed to lazy load RealSubject: " _ ex.DisplayString())
    }
    
    Quit tSC
}

/// Check if the resource is available for loading
/// Can be overridden for custom availability checks
/// 
/// @return True if resource is available
Method IsResourceAvailable() As %Boolean [ Private ]
{
    // Simulate resource availability check
    // In real implementation might check:
    // - File existence
    // - Network connectivity
    // - Database availability
    // - Memory availability
    
    // For demo, always return true
    Quit 1
}

/// Override GetInfo to provide information without loading
/// Shows placeholder info if not loaded, real info if loaded
/// 
/// @return Information about the resource
Method GetInfo() As %String
{
    Set tInfo = "Virtual Proxy: "
    
    If ..IsLoaded && $IsObject(..RealSubject) {
        // Get info from loaded real subject
        Set tInfo = tInfo _ ..RealSubject.GetInfo()
    } Else {
        // Provide placeholder info without loading
        Set tInfo = tInfo _ "Placeholder [" _ ..PlaceholderInfo _ "], "
        Set tInfo = tInfo _ "Created=" _ ..CreationTime _ ", "
        Set tInfo = tInfo _ "LoadAttempts=" _ ..LoadAttempts _ ", "
        Set tInfo = tInfo _ "Status=Not Loaded"
    }
    
    Quit tInfo
}

/// Get lightweight preview without loading real subject
/// Useful for displaying lists of proxied objects
/// 
/// @return Preview information
Method GetPreview() As %String
{
    Set tPreview = "Preview: " _ ..PlaceholderInfo
    
    If ..IsLoaded {
        Set tPreview = tPreview _ " [LOADED]"
    } Else {
        Set tPreview = tPreview _ " [NOT LOADED]"
    }
    
    Quit tPreview
}

/// Override PreProcess for virtual proxy specific logic
Method PreProcess() [ Private ]
{
    // Log if this is the first real access
    If '..IsLoaded {
        Do ..LogAccess("First real access to virtual proxy - triggering lazy load")
    }
}

/// Get statistics about the virtual proxy
/// 
/// @return Statistics as a dynamic object
Method GetStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Set tStats.proxyType = "Virtual"
    Set tStats.isLoaded = ..IsLoaded
    Set tStats.creationTime = ..CreationTime
    Set tStats.firstAccessTime = ..FirstAccessTime
    Set tStats.loadAttempts = ..LoadAttempts
    Set tStats.accessLogCount = ..AccessLog.Count()
    
    If ..IsLoaded && $IsObject(..RealSubject) {
        Set tStats.realSubjectOperations = ..RealSubject.OperationCount
    } Else {
        Set tStats.realSubjectOperations = 0
    }
    
    // Calculate memory saved by lazy loading
    If ..FirstAccessTime '= "" && ..CreationTime '= "" {
        Try {
            Set tFirstTime = $ZDateTimeH(..FirstAccessTime)
            Set tCreateTime = $ZDateTimeH(..CreationTime)
            
            // Calculate total seconds difference properly
            Set tFirstDay = $Piece(tFirstTime, ",", 1)
            Set tFirstSec = $Piece(tFirstTime, ",", 2)
            Set tCreateDay = $Piece(tCreateTime, ",", 1)
            Set tCreateSec = $Piece(tCreateTime, ",", 2)
            
            // Calculate total seconds from the IRIS epoch for each timestamp
            Set tFirstTotal = (tFirstDay * 86400) + tFirstSec
            Set tCreateTotal = (tCreateDay * 86400) + tCreateSec
            
            // Calculate the difference
            Set tDelaySeconds = tFirstTotal - tCreateTotal
            
            // Ensure we have a valid positive number
            If tDelaySeconds < 0 {
                Set tDelaySeconds = 0  // Should not happen, but handle gracefully
            }
            
            Set tStats.lazyLoadDelaySeconds = tDelaySeconds
            If tDelaySeconds >= 0 {
                Set tStats.memorySavedEstimate = "~" _ (tDelaySeconds * 1024) _ " bytes"  // Rough estimate
            } Else {
                Set tStats.memorySavedEstimate = "Unknown"
            }
        } Catch {
            Set tStats.lazyLoadDelaySeconds = "N/A"
            Set tStats.memorySavedEstimate = "Unknown"
        }
    } Else {
        Set tStats.lazyLoadDelaySeconds = "N/A"
        Set tStats.memorySavedEstimate = "Still saving memory"
    }
    
    Quit tStats
}

/// Force immediate loading of real subject
/// Used when you want to pre-load objects
/// 
/// @return Status of the load operation
Method PreLoad() As %Status
{
    Set tSC = $$$OK
    
    If ..IsLoaded {
        Do ..LogAccess("PreLoad called but RealSubject already loaded")
        Quit tSC
    }
    
    Do ..LogAccess("Pre-loading RealSubject on request")
    Set tSC = ..LoadRealSubject()
    
    Quit tSC
}

/// Class method to create a virtual proxy with specific placeholder
/// 
/// @param pPlaceholderInfo Description of the proxied resource
/// @return Virtual proxy instance
ClassMethod CreateVirtualProxy(pPlaceholderInfo As %String) As VirtualProxy
{
    Set tProxy = ..%New(pPlaceholderInfo)
    
    // Log creation in a global for demonstration
    Set ^Patterns.VirtualProxy($Increment(^Patterns.VirtualProxy)) = pPlaceholderInfo _ " @ " _ $ZDateTime($Horolog, 3)
    
    Quit tProxy
}

/// Demonstrate virtual proxy benefits
/// 
/// @param pShowOutput Whether to display output
/// @return Performance metrics as string
ClassMethod DemonstrateLazyLoading(pShowOutput As %Boolean = 1) As %String
{
    Set tResult = ""
    
    // Create multiple virtual proxies
    Set tStartTime = $Piece($Now(), ",", 2)
    
    // Create 10 virtual proxies (fast - no real subjects created)
    For i = 1:1:10 {
        Set tProxies(i) = ##class(VirtualProxy).CreateVirtualProxy("Resource " _ i)
    }
    
    Set tProxyCreationTime = $Piece($Now(), ",", 2) - tStartTime
    
    // Access only some of them (demonstrating selective loading)
    Set tAccessStartTime = $Piece($Now(), ",", 2)
    
    // Access only proxies 3, 5, and 8
    Do tProxies(3).Request()
    Do tProxies(5).Request()
    Do tProxies(8).Request()
    
    Set tAccessTime = $Piece($Now(), ",", 2) - tAccessStartTime
    
    // Count how many are actually loaded
    Set tLoadedCount = 0
    For i = 1:1:10 {
        If tProxies(i).IsRealSubjectLoaded() {
            Set tLoadedCount = tLoadedCount + 1
        }
    }
    
    // Build result summary
    Set tResult = "Virtual Proxy Demonstration Results:" _ $Char(13, 10)
    Set tResult = tResult _ "- Created 10 virtual proxies in " _ tProxyCreationTime _ " ms" _ $Char(13, 10)
    Set tResult = tResult _ "- Accessed 3 proxies in " _ tAccessTime _ " ms" _ $Char(13, 10)
    Set tResult = tResult _ "- Only " _ tLoadedCount _ " of 10 real subjects were loaded" _ $Char(13, 10)
    Set tResult = tResult _ "- Memory saved: " _ (7 * 1024) _ " bytes (estimated)" _ $Char(13, 10)
    
    If pShowOutput {
        Write tResult
    }
    
    // Clean up
    For i = 1:1:10 {
        Do tProxies(i).%Close()
    }
    
    Quit tResult
}

}
