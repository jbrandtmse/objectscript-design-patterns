/// Gang of Four Proxy Pattern - Remote Proxy Implementation
/// 
/// Intent:
/// Provides a local representative for an object in a different
/// address space. The remote proxy handles network communication
/// and marshalling/unmarshalling of data.
/// 
/// This implementation demonstrates:
/// - Simulated remote object access
/// - Request/response marshalling
/// - Connection state management
/// - Network failure handling
/// - Caching of remote data
/// 
/// Structure:
/// <example>
/// // Create remote proxy for object on another server
/// Set proxy = ##class(Patterns.GoF.Structural.RemoteProxy).%New("server.example.com", 1972)
/// 
/// // Proxy handles network communication transparently
/// Set result = proxy.Request()  // Marshalled over network
/// 
/// // Operations are sent to remote object
/// Set status = proxy.DoOperation("QUERY", searchParams)
/// </example>
Class Patterns.GoF.Structural.RemoteProxy Extends Patterns.GoF.Structural.Proxy
{

/// Property RemoteHost - Host where real subject resides
Property RemoteHost As %String [ InitialExpression = "localhost" ];

/// Property RemotePort - Port for remote communication
Property RemotePort As %Integer [ InitialExpression = 1972 ];

/// Property RemoteNamespace - Target namespace on remote system
Property RemoteNamespace As %String [ InitialExpression = "USER" ];

/// Property ConnectionState - Current connection state
Property ConnectionState As %String [ InitialExpression = "Disconnected" ];

/// Property ConnectionTimeout - Timeout for remote operations (seconds)
Property ConnectionTimeout As %Integer [ InitialExpression = 30 ];

/// Property RetryCount - Number of retries for failed operations
Property RetryCount As %Integer [ InitialExpression = 3 ];

/// Property CacheEnabled - Whether to cache remote responses
Property CacheEnabled As %Boolean [ InitialExpression = 1 ];

/// Property ResponseCache - Cache of remote responses
Property ResponseCache As %ArrayOfDataTypes;

/// Property LastPingTime - Last successful ping timestamp
Property LastPingTime As %TimeStamp;

/// Property NetworkLatency - Simulated network latency (ms)
Property NetworkLatency As %Integer [ InitialExpression = 100 ];

/// Property TotalRemoteCalls - Count of remote calls made
Property TotalRemoteCalls As %Integer [ InitialExpression = 0 ];

/// Property FailedCalls - Count of failed remote calls
Property FailedCalls As %Integer [ InitialExpression = 0 ];

/// Constructor - Initialize remote proxy with connection details
Method %OnNew(pRemoteHost As %String = "", pRemotePort As %Integer = 0, pRemoteNamespace As %String = "") As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Set proxy type
    Set ..ProxyType = "Remote"
    
    // Set remote connection details
    If pRemoteHost '= "" Set ..RemoteHost = pRemoteHost
    If pRemotePort > 0 Set ..RemotePort = pRemotePort
    If pRemoteNamespace '= "" Set ..RemoteNamespace = pRemoteNamespace
    
    // Initialize response cache
    Set ..ResponseCache = ##class(%ArrayOfDataTypes).%New()
    
    // Log remote proxy creation
    Do ..LogAccess("RemoteProxy created for " _ ..RemoteHost _ ":" _ ..RemotePort _ "/" _ ..RemoteNamespace)
    
    // Attempt initial connection
    Do ..EstablishConnection()
    
    Quit tSC
}

/// Override CheckAccess - Check if remote connection is available
/// 
/// @return True if remote access is possible
Method CheckAccess() As %Boolean
{
    // Check connection state
    If ..ConnectionState '= "Connected" {
        // Try to establish connection
        Set tSC = ..EstablishConnection()
        If $$$ISERR(tSC) {
            Do ..LogAccess("Remote access denied: Connection failed")
            Quit 0
        }
    }
    
    // Verify connection with ping
    If '..PingRemoteHost() {
        Set ..ConnectionState = "Disconnected"
        Do ..LogAccess("Remote access denied: Host not responding")
        Quit 0
    }
    
    Quit 1
}

/// Establish connection to remote host
/// 
/// @return Status of connection attempt
Method EstablishConnection() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        Do ..LogAccess("Attempting connection to " _ ..RemoteHost _ ":" _ ..RemotePort)
        
        // Simulate connection establishment
        // In real implementation, would use %Net.RemoteConnection or similar
        Hang ..NetworkLatency / 1000  // Simulate network delay
        
        // For demonstration, simulate success based on host
        If ..RemoteHost = "unreachable.host" {
            Set tSC = $$$ERROR($$$GeneralError, "Connection refused")
            Set ..ConnectionState = "Failed"
        } Else {
            Set ..ConnectionState = "Connected"
            Set ..LastPingTime = $ZDateTime($Horolog, 3)
            Do ..LogAccess("Connection established successfully")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..ConnectionState = "Error"
        Do ..LogAccess("Connection error: " _ ex.DisplayString())
    }
    
    Quit tSC
}

/// Ping remote host to verify connection
/// 
/// @return True if host responds
Method PingRemoteHost() As %Boolean [ Private ]
{
    // Simulate ping
    Hang ..NetworkLatency / 2000  // Half latency for ping
    
    // For demo, succeed if not specific failure host
    If ..RemoteHost = "timeout.host" {
        Quit 0
    }
    
    Set ..LastPingTime = $ZDateTime($Horolog, 3)
    Quit 1
}

/// Override LoadRealSubject for remote loading
/// Creates local stub that communicates with remote object
/// 
/// @return Status of the load operation
Method LoadRealSubject() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '..IsLoaded {
            // For remote proxy, we don't load the actual object
            // Instead, we maintain connection info
            Do ..LogAccess("Remote subject reference established")
            Set ..IsLoaded = 1
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do ..LogAccess("Failed to establish remote reference: " _ ex.DisplayString())
    }
    
    Quit tSC
}

/// Override Request method to handle remote communication
/// 
/// @return Result from remote object
Method Request() As %String
{
    Set tResult = ""
    Set ..TotalRemoteCalls = ..TotalRemoteCalls + 1
    
    // Check access and connection
    If '..CheckAccess() {
        Set ..FailedCalls = ..FailedCalls + 1
        Quit "Remote Proxy: Connection failed to " _ ..RemoteHost
    }
    
    // Check cache first
    Set tCacheKey = "Request"
    If ..CacheEnabled && ..ResponseCache.IsDefined(tCacheKey) {
        Set tResult = ..ResponseCache.GetAt(tCacheKey)
        Do ..LogAccess("Returning cached response for Request")
        Quit tResult
    }
    
    // Marshal request
    Set tMarshalledRequest = ..MarshalRequest("Request", "")
    
    // Send to remote host with retry logic
    Set tAttempt = 0
    Set tSuccess = 0
    
    While (tAttempt < ..RetryCount) && ('tSuccess) {
        Set tAttempt = tAttempt + 1
        
        Try {
            // Simulate remote call
            Set tRemoteResponse = ..ExecuteRemoteCall(tMarshalledRequest)
            
            // Unmarshal response
            Set tResult = ..UnmarshalResponse(tRemoteResponse)
            Set tSuccess = 1
            
            // Cache response
            If ..CacheEnabled {
                Do ..ResponseCache.SetAt(tResult, tCacheKey)
            }
            
        } Catch ex {
            Do ..LogAccess("Remote call attempt " _ tAttempt _ " failed: " _ ex.DisplayString())
            If tAttempt < ..RetryCount {
                Hang 0.5  // Wait before retry
            }
        }
    }
    
    If 'tSuccess {
        Set ..FailedCalls = ..FailedCalls + 1
        Set tResult = "Remote Proxy: All " _ ..RetryCount _ " attempts failed"
    }
    
    Quit tResult
}

/// Override DoOperation for remote operations
/// 
/// @param pOperation Operation to perform
/// @param pData Data for the operation
/// @return Status of remote operation
Method DoOperation(pOperation As %String, pData As %String = "") As %Status
{
    Set tSC = $$$OK
    Set ..TotalRemoteCalls = ..TotalRemoteCalls + 1
    
    // Check access and connection
    If '..CheckAccess() {
        Set ..FailedCalls = ..FailedCalls + 1
        Set tSC = $$$ERROR($$$GeneralError, "Remote connection failed")
        Quit tSC
    }
    
    // Marshal operation request
    Set tMarshalledRequest = ..MarshalRequest(pOperation, pData)
    
    Try {
        // Send to remote host
        Set tRemoteResponse = ..ExecuteRemoteCall(tMarshalledRequest)
        
        // Check response status
        If tRemoteResponse [ "ERROR" {
            Set tSC = $$$ERROR($$$GeneralError, "Remote operation failed: " _ tRemoteResponse)
            Set ..FailedCalls = ..FailedCalls + 1
        } Else {
            Do ..LogAccess("Remote operation '" _ pOperation _ "' completed successfully")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..FailedCalls = ..FailedCalls + 1
        Do ..LogAccess("Remote operation error: " _ ex.DisplayString())
    }
    
    Quit tSC
}

/// Marshal request for network transmission
/// 
/// @param pMethod Method being called
/// @param pData Data to send
/// @return Marshalled request as string
Method MarshalRequest(pMethod As %String, pData As %String) As %String [ Private ]
{
    Set tRequest = {}
    Set tRequest.method = pMethod
    Set tRequest.data = pData
    Set tRequest.timestamp = $ZDateTime($Horolog, 3)
    Set tRequest.source = $System
    Set tRequest.namespace = $Namespace
    
    // Convert to JSON for transmission
    Set tMarshalled = tRequest.%ToJSON()
    
    Do ..LogAccess("Request marshalled: " _ $Extract(tMarshalled, 1, 50) _ "...")
    
    Quit tMarshalled
}

/// Unmarshal response from network transmission
/// 
/// @param pResponse Raw response data
/// @return Unmarshalled response
Method UnmarshalResponse(pResponse As %String) As %String [ Private ]
{
    Try {
        // Parse JSON response
        Set tResponseObj = {}.%FromJSON(pResponse)
        Set tResult = tResponseObj.result
        
        // Update latency measurement
        If tResponseObj.%IsDefined("latency") {
            Set ..NetworkLatency = tResponseObj.latency
        }
        
    } Catch ex {
        // If unmarshalling fails, return raw response
        Set tResult = pResponse
    }
    
    Do ..LogAccess("Response unmarshalled: " _ $Extract(tResult, 1, 50) _ "...")
    
    Quit tResult
}

/// Execute remote call (simulated)
/// 
/// @param pRequest Marshalled request
/// @return Remote response
Method ExecuteRemoteCall(pRequest As %String) As %String [ Private ]
{
    // Simulate network communication
    Hang ..NetworkLatency / 1000
    
    // Parse request for simulation
    Set tRequestObj = {}.%FromJSON(pRequest)
    
    // Build simulated response
    Set tResponse = {}
    Set tResponse.status = "OK"
    Set tResponse.result = "Remote execution of " _ tRequestObj.method _ " on " _ ..RemoteHost _ " completed"
    Set tResponse.timestamp = $ZDateTime($Horolog, 3)
    Set tResponse.latency = ..NetworkLatency
    
    // Simulate different responses based on operation
    If tRequestObj.method = "Request" {
        Set tResponse.result = "RemoteSubject@" _ ..RemoteHost _ ": Handling request with data from " _ ..RemoteNamespace
    } ElseIf tRequestObj.method [ "READ" {
        Set tResponse.result = "Remote data retrieved: [Sample Data from " _ ..RemoteHost _ "]"
    } ElseIf tRequestObj.method [ "WRITE" {
        Set tResponse.result = "Remote data written successfully"
    }
    
    Quit tResponse.%ToJSON()
}

/// Get remote proxy statistics
/// 
/// @return Statistics as dynamic object
Method GetStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Set tStats.proxyType = "Remote"
    Set tStats.remoteHost = ..RemoteHost
    Set tStats.remotePort = ..RemotePort
    Set tStats.remoteNamespace = ..RemoteNamespace
    Set tStats.connectionState = ..ConnectionState
    Set tStats.lastPingTime = ..LastPingTime
    Set tStats.networkLatency = ..NetworkLatency _ " ms"
    Set tStats.totalRemoteCalls = ..TotalRemoteCalls
    Set tStats.failedCalls = ..FailedCalls
    Set tStats.successRate = "0%"
    
    If ..TotalRemoteCalls > 0 {
        Set tSuccessful = ..TotalRemoteCalls - ..FailedCalls
        Set tStats.successRate = $Normalize(tSuccessful / ..TotalRemoteCalls * 100, 2) _ "%"
    }
    
    Set tStats.cacheEnabled = ..CacheEnabled
    Set tStats.cacheSize = ..ResponseCache.Count()
    Set tStats.connectionTimeout = ..ConnectionTimeout _ " seconds"
    Set tStats.retryCount = ..RetryCount
    
    Quit tStats
}

/// Clear response cache
Method ClearCache()
{
    Do ..ResponseCache.Clear()
    Do ..LogAccess("Response cache cleared")
}

/// Reconnect to remote host
/// 
/// @return Status of reconnection
Method Reconnect() As %Status
{
    Set ..ConnectionState = "Disconnected"
    Do ..ClearCache()
    Set tSC = ..EstablishConnection()
    Quit tSC
}

/// Class method to create remote proxy
/// 
/// @param pHost Remote host
/// @param pPort Remote port
/// @param pNamespace Remote namespace
/// @return Remote proxy instance
ClassMethod CreateRemoteProxy(pHost As %String, pPort As %Integer = 1972, pNamespace As %String = "USER") As RemoteProxy
{
    Set tProxy = ..%New(pHost, pPort, pNamespace)
    
    // Log creation in global
    Set ^Patterns.RemoteProxy($Increment(^Patterns.RemoteProxy)) = pHost _ ":" _ pPort _ "/" _ pNamespace _ " @ " _ $ZDateTime($Horolog, 3)
    
    Quit tProxy
}

/// Demonstrate remote proxy functionality
/// 
/// @param pShowOutput Whether to display output
/// @return Demonstration results
ClassMethod DemonstrateRemoteProxy(pShowOutput As %Boolean = 1) As %String
{
    Set tResult = ""
    
    // Create remote proxies for different scenarios
    Set tResult = tResult _ "Remote Proxy Demonstration:" _ $Char(13, 10)
    Set tResult = tResult _ $Char(13, 10)
    
    // Test 1: Successful remote connection
    Set tResult = tResult _ "Test 1 - Normal Remote Connection:" _ $Char(13, 10)
    Set tProxy1 = ##class(RemoteProxy).CreateRemoteProxy("app.server.com", 1972, "PRODUCTION")
    Set tResponse = tProxy1.Request()
    Set tResult = tResult _ "  Response: " _ tResponse _ $Char(13, 10)
    
    // Test 2: Failed connection
    Set tResult = tResult _ $Char(13, 10) _ "Test 2 - Unreachable Host:" _ $Char(13, 10)
    Set tProxy2 = ##class(RemoteProxy).CreateRemoteProxy("unreachable.host", 1972, "TEST")
    Set tResponse = tProxy2.Request()
    Set tResult = tResult _ "  Response: " _ tResponse _ $Char(13, 10)
    
    // Test 3: Cached responses
    Set tResult = tResult _ $Char(13, 10) _ "Test 3 - Cached Responses:" _ $Char(13, 10)
    Set tProxy3 = ##class(RemoteProxy).CreateRemoteProxy("cache.server.com", 1972, "USER")
    
    Set tStartTime = $Piece($Now(), ",", 2)
    Set tResponse1 = tProxy3.Request()  // First call - remote
    Set tTime1 = $Piece($Now(), ",", 2) - tStartTime
    
    Set tStartTime = $Piece($Now(), ",", 2)
    Set tResponse2 = tProxy3.Request()  // Second call - cached
    Set tTime2 = $Piece($Now(), ",", 2) - tStartTime
    
    Set tResult = tResult _ "  First call (remote): " _ tTime1 _ " ms" _ $Char(13, 10)
    Set tResult = tResult _ "  Second call (cached): " _ tTime2 _ " ms" _ $Char(13, 10)
    Set tResult = tResult _ "  Cache speedup: " _ $Normalize(tTime1 / tTime2, 2) _ "x faster" _ $Char(13, 10)
    
    // Get statistics
    Set tStats = tProxy1.GetStatistics()
    Set tResult = tResult _ $Char(13, 10) _ "Statistics for " _ tStats.remoteHost _ ":" _ $Char(13, 10)
    Set tResult = tResult _ "  - Total calls: " _ tStats.totalRemoteCalls _ $Char(13, 10)
    Set tResult = tResult _ "  - Failed calls: " _ tStats.failedCalls _ $Char(13, 10)
    Set tResult = tResult _ "  - Success rate: " _ tStats.successRate _ $Char(13, 10)
    Set tResult = tResult _ "  - Network latency: " _ tStats.networkLatency _ $Char(13, 10)
    
    If pShowOutput {
        Write tResult
    }
    
    // Clean up
    Do tProxy1.%Close()
    Do tProxy2.%Close()
    Do tProxy3.%Close()
    
    Quit tResult
}

}
