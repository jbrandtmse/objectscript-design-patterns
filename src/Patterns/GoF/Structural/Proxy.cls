/// Gang of Four Proxy Pattern - Abstract Proxy Base Class
/// 
/// Intent:
/// Maintains a reference to the RealSubject and controls access to it.
/// This abstract class provides the common structure for all proxy types.
/// 
/// The Proxy pattern provides a placeholder or surrogate for another
/// object to control access to it. Different proxy types include:
/// - Virtual Proxy: Lazy initialization of expensive objects
/// - Protection Proxy: Access control based on permissions
/// - Remote Proxy: Local representative for remote objects
/// 
/// Structure:
/// <example>
/// // Create a specific proxy type
/// Set proxy = ##class(Patterns.GoF.Structural.VirtualProxy).%New()
/// Set result = proxy.Request()  // Proxy controls access to RealSubject
/// </example>
Class Patterns.GoF.Structural.Proxy Extends Patterns.GoF.Structural.Subject [ Abstract ]
{

/// Property RealSubject - Reference to the real subject
/// Protected property that subclasses can access
Property RealSubject As RealSubject;

/// Property IsLoaded - Flag indicating if real subject is loaded
Property IsLoaded As %Boolean [ InitialExpression = 0 ];

/// Property AccessLog - Track access attempts for auditing
Property AccessLog As list Of %String;

/// Property ProxyType - Type of proxy (Virtual, Protection, Remote)
/// Subclasses must set this property in their %OnNew() method
Property ProxyType As %String;

/// Constructor - Initialize proxy
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    // Initialize properties
    Set ..IsLoaded = 0
    Set ..RealSubject = ""
    Set ..ProxyType = "Base"  // Subclasses should override
    
    // Clear access log
    Do ..AccessLog.Clear()
    
    // Log proxy creation
    Do ..LogAccess("Proxy created: " _ ..%ClassName(1))
    
    Quit tSC
}

/// Implementation of Request method
/// Delegates to real subject after performing proxy-specific checks
/// 
/// @return Result of the request operation
Method Request() As %String
{
    Set tResult = ""
    
    // Check access (implemented by subclasses)
    If '..CheckAccess() {
        Set tResult = "Access Denied by " _ ..ProxyType _ " Proxy"
        Do ..LogAccess("Request denied: " _ tResult)
        Quit tResult
    }
    
    // Ensure real subject is loaded (for virtual proxy)
    If '..IsLoaded {
        Set tSC = ..LoadRealSubject()
        If $$$ISERR(tSC) {
            Set tResult = "Failed to load RealSubject: " _ $System.Status.GetErrorText(tSC)
            Do ..LogAccess("Load failed: " _ tResult)
            Quit tResult
        }
    }
    
    // Pre-processing hook for subclasses
    Do ..PreProcess()
    
    // Delegate to real subject
    If $IsObject(..RealSubject) {
        Set tResult = ..RealSubject.Request()
        Do ..LogAccess("Request forwarded to RealSubject")
    } Else {
        Set tResult = "RealSubject not available"
        Do ..LogAccess("Request failed: RealSubject not available")
    }
    
    // Post-processing hook for subclasses
    Do ..PostProcess()
    
    Quit tResult
}

/// Implementation of DoOperation method
/// Delegates to real subject with proxy controls
/// 
/// @param pOperation The operation to perform
/// @param pData The data to process
/// @return Status of the operation
Method DoOperation(pOperation As %String, pData As %String = "") As %Status
{
    Set tSC = $$$OK
    
    // Check if operation is allowed
    If '..CheckOperationAccess(pOperation) {
        Set tSC = $$$ERROR($$$GeneralError, "Operation '" _ pOperation _ "' denied by " _ ..ProxyType _ " Proxy")
        Do ..LogAccess("Operation denied: " _ pOperation)
        Quit tSC
    }
    
    // Ensure real subject is loaded
    If '..IsLoaded {
        Set tSC = ..LoadRealSubject()
        If $$$ISERR(tSC) {
            Do ..LogAccess("Load failed for operation: " _ pOperation)
            Quit tSC
        }
    }
    
    // Delegate to real subject
    If $IsObject(..RealSubject) {
        Set tSC = ..RealSubject.DoOperation(pOperation, pData)
        Do ..LogAccess("Operation '" _ pOperation _ "' forwarded to RealSubject")
    } Else {
        Set tSC = $$$ERROR($$$GeneralError, "RealSubject not available for operation")
    }
    
    Quit tSC
}

/// Get information about the resource
/// Can be provided without loading the real subject
/// 
/// @return Information about the resource
Method GetInfo() As %String
{
    Set tInfo = ..ProxyType _ " Proxy: "
    
    If ..IsLoaded && $IsObject(..RealSubject) {
        // Get info from real subject if loaded
        Set tInfo = tInfo _ ..RealSubject.GetInfo()
    } Else {
        // Provide proxy-level info
        Set tInfo = tInfo _ "RealSubject not loaded, AccessLog entries: " _ ..AccessLog.Count()
    }
    
    Quit tInfo
}

/// Abstract method to check access permissions
/// Must be implemented by concrete proxy classes
/// 
/// @return True if access is granted, False otherwise
Method CheckAccess() As %Boolean [ Abstract ]
{
    Quit 1
}

/// Check if specific operation is allowed
/// Can be overridden by subclasses for fine-grained control
/// 
/// @param pOperation The operation to check
/// @return True if operation is allowed, False otherwise
Method CheckOperationAccess(pOperation As %String) As %Boolean
{
    // Default implementation delegates to CheckAccess
    // Subclasses can override for operation-specific checks
    Quit ..CheckAccess()
}

/// Load the real subject
/// Virtual proxies override this for lazy loading
/// 
/// @return Status of the load operation
Method LoadRealSubject() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '..IsLoaded {
            Set ..RealSubject = ##class(Patterns.GoF.Structural.RealSubject).%New()
            Set ..IsLoaded = 1
            Do ..LogAccess("RealSubject loaded")
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do ..LogAccess("Failed to load RealSubject: " _ ex.DisplayString())
    }
    
    Quit tSC
}

/// Pre-processing hook
/// Called before delegating to real subject
Method PreProcess() [ Private ]
{
    // Subclasses can override for custom pre-processing
    Do ..LogAccess("Pre-processing request")
}

/// Post-processing hook
/// Called after delegating to real subject
Method PostProcess() [ Private ]
{
    // Subclasses can override for custom post-processing
    Do ..LogAccess("Post-processing request")
}

/// Log access attempt for auditing
/// 
/// @param pMessage The message to log
Method LogAccess(pMessage As %String) [ Private ]
{
    Set tLogEntry = $ZDateTime($Horolog, 3) _ " - " _ pMessage
    Do ..AccessLog.Insert(tLogEntry)
    
    // Also log to system logger if available
    If ##class(%Dictionary.CompiledClass).%ExistsId("Patterns.Utils.Logger") {
        Do ##class(Patterns.Utils.Logger).LogInfo(..ProxyType _ "Proxy", pMessage)
    }
}

/// Get the access log as a formatted string
/// 
/// @return Formatted access log
Method GetAccessLog() As %String
{
    Set tLog = "Access Log for " _ ..ProxyType _ " Proxy:" _ $Char(13, 10)
    
    For i = 1:1:..AccessLog.Count() {
        Set tLog = tLog _ "  " _ ..AccessLog.GetAt(i) _ $Char(13, 10)
    }
    
    Quit tLog
}

/// Clear the access log
Method ClearAccessLog()
{
    Do ..AccessLog.Clear()
    Do ..LogAccess("Access log cleared")
}

/// Check if real subject is loaded
/// 
/// @return True if loaded, False otherwise
Method IsRealSubjectLoaded() As %Boolean
{
    Quit ..IsLoaded
}

/// Force unload of real subject (for testing/cleanup)
Method UnloadRealSubject()
{
    If $IsObject(..RealSubject) {
        Do ..RealSubject.%Close()
    }
    Set ..RealSubject = ""
    Set ..IsLoaded = 0
    Do ..LogAccess("RealSubject unloaded")
}

/// Clean up resources when proxy is destroyed
Method %OnClose() As %Status
{
    Set tSC = $$$OK
    
    // Clean up real subject if loaded
    If $IsObject(..RealSubject) {
        Do ..RealSubject.%Close()
    }
    
    // Log destruction
    Do ..LogAccess("Proxy destroyed")
    
    Quit tSC
}

}
