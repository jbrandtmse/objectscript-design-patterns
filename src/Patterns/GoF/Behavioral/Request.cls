/// Gang of Four Chain of Responsibility Pattern - Request Base Class
/// 
/// Intent:
/// Encapsulates a request that will be passed along a chain of handlers.
/// Contains all necessary information for handlers to process the request.
/// 
/// @see Patterns.GoF.Behavioral.Handler
/// @see Patterns.GoF.Behavioral.Response
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Request Extends %RegisteredObject
{

/// Type of the request (e.g., "Approval", "Processing", "Validation")
Property Type As %String;

/// Data payload for the request (can be JSON, XML, or any string data)
Property Data As %String(MAXLEN = "");

/// Priority level of the request (1=Low, 2=Normal, 3=High, 4=Critical)
Property Priority As %Integer [ InitialExpression = 2 ];

/// Context information for the request (key-value pairs)
Property Context As %DynamicObject;

/// Unique identifier for request tracking
Property RequestId As %String [ InitialExpression = {$System.Util.CreateGUID()} ];

/// Timestamp when request was created
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDateTime($ZTimeStamp, 3)} ];

/// User or system that initiated the request
Property Initiator As %String;

/// List of handlers that have processed this request (for audit trail)
Property ProcessingHistory As list Of %String;

/// Additional metadata for the request
Property Metadata As %DynamicObject;

/// Status of the request (New, Processing, Completed, Failed)
Property Status As %String [ InitialExpression = "New" ];

/// Constructor to initialize request with type and data
/// 
/// @param pType The type of request
/// @param pData The data payload
/// @return %Status
Method %OnNew(pType As %String = "", pData As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pType '= "" Set ..Type = pType
        If pData '= "" Set ..Data = pData
        
        // Initialize dynamic objects
        Set ..Context = {}
        Set ..Metadata = {}
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate the request has required fields
/// 
/// @return %Status indicating if request is valid
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check required fields
        If ..Type = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Request type is required")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Validate priority range
        If (..Priority < 1) || (..Priority > 4) {
            Set tSC = $$$ERROR($$$GeneralError, "Priority must be between 1 and 4")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Additional validation can be added by subclasses
        Set tSC = ..ValidateData()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate the data payload - can be overridden by subclasses
/// 
/// @return %Status
Method ValidateData() As %Status
{
    Quit $$$OK
}

/// Add a handler to the processing history
/// 
/// @param pHandlerName The name of the handler that processed this request
Method AddToHistory(pHandlerName As %String)
{
    Do ..ProcessingHistory.Insert(pHandlerName _ " at " _ $ZDateTime($ZTimeStamp, 3))
}

/// Get the processing history as a formatted string
/// 
/// @return %String formatted history
Method GetHistoryString() As %String
{
    Set tHistory = ""
    Set tCount = ..ProcessingHistory.Count()
    
    For i=1:1:tCount {
        If tHistory '= "" Set tHistory = tHistory _ " -> "
        Set tHistory = tHistory _ ..ProcessingHistory.GetAt(i)
    }
    
    Quit tHistory
}

/// Set a context value
/// 
/// @param pKey The context key
/// @param pValue The context value
Method SetContext(pKey As %String, pValue As %String)
{
    If '$IsObject(..Context) Set ..Context = {}
    Do ..Context.%Set(pKey, pValue)
}

/// Get a context value
/// 
/// @param pKey The context key
/// @return The context value or empty string
Method GetContext(pKey As %String) As %String
{
    If '$IsObject(..Context) Quit ""
    Quit ..Context.%Get(pKey)
}

/// Check if a context key exists
/// 
/// @param pKey The context key
/// @return %Boolean
Method HasContext(pKey As %String) As %Boolean
{
    If '$IsObject(..Context) Quit 0
    Quit ..Context.%IsDefined(pKey)
}

/// Set metadata value
/// 
/// @param pKey The metadata key
/// @param pValue The metadata value
Method SetMetadata(pKey As %String, pValue As %String)
{
    If '$IsObject(..Metadata) Set ..Metadata = {}
    Do ..Metadata.%Set(pKey, pValue)
}

/// Get metadata value
/// 
/// @param pKey The metadata key
/// @return The metadata value or empty string
Method GetMetadata(pKey As %String) As %String
{
    If '$IsObject(..Metadata) Quit ""
    Quit ..Metadata.%Get(pKey)
}

/// Clone the request for modification without affecting original
/// 
/// @return A new Request object with same data
Method Clone() As Request
{
    Set tClone = ##class(Request).%New(..Type, ..Data)
    Set tClone.Priority = ..Priority
    Set tClone.Initiator = ..Initiator
    Set tClone.Status = ..Status
    
    // Deep copy context
    If $IsObject(..Context) {
        Set tClone.Context = {}.%FromJSON(..Context.%ToJSON())
    }
    
    // Deep copy metadata
    If $IsObject(..Metadata) {
        Set tClone.Metadata = {}.%FromJSON(..Metadata.%ToJSON())
    }
    
    // Copy history
    Set tCount = ..ProcessingHistory.Count()
    For i=1:1:tCount {
        Do tClone.ProcessingHistory.Insert(..ProcessingHistory.GetAt(i))
    }
    
    Quit tClone
}

/// Get a summary of the request for logging/display
/// 
/// @return %String summary
Method GetSummary() As %String
{
    Set tSummary = "Request[ID=" _ ..RequestId
    Set tSummary = tSummary _ ", Type=" _ ..Type
    Set tSummary = tSummary _ ", Priority=" _ ..Priority
    Set tSummary = tSummary _ ", Status=" _ ..Status
    Set tSummary = tSummary _ ", Created=" _ ..CreatedAt
    If ..Initiator '= "" Set tSummary = tSummary _ ", Initiator=" _ ..Initiator
    Set tSummary = tSummary _ "]"
    
    Quit tSummary
}

/// Convert request to JSON for serialization
/// 
/// @return %DynamicObject
Method ToJSON() As %DynamicObject
{
    Set tJSON = {}
    Set tJSON.requestId = ..RequestId
    Set tJSON.type = ..Type
    Set tJSON.data = ..Data
    Set tJSON.priority = ..Priority
    Set tJSON.status = ..Status
    Set tJSON.createdAt = ..CreatedAt
    Set tJSON.initiator = ..Initiator
    
    If $IsObject(..Context) Set tJSON.context = ..Context
    If $IsObject(..Metadata) Set tJSON.metadata = ..Metadata
    
    // Add history
    Set tHistory = []
    Set tCount = ..ProcessingHistory.Count()
    For i=1:1:tCount {
        Do tHistory.%Push(..ProcessingHistory.GetAt(i))
    }
    Set tJSON.processingHistory = tHistory
    
    Quit tJSON
}

/// Create a Request from JSON
/// 
/// @param pJSON The JSON object or string
/// @return Request object
ClassMethod FromJSON(pJSON) As Request
{
    Set tRequest = ##class(Request).%New()
    
    // Handle string or object input
    If '$IsObject(pJSON) {
        Set pJSON = {}.%FromJSON(pJSON)
    }
    
    Set tRequest.Type = pJSON.type
    Set tRequest.Data = pJSON.data
    Set tRequest.Priority = pJSON.priority
    Set tRequest.Status = pJSON.status
    Set tRequest.Initiator = pJSON.initiator
    
    If pJSON.%IsDefined("requestId") Set tRequest.RequestId = pJSON.requestId
    If pJSON.%IsDefined("createdAt") Set tRequest.CreatedAt = pJSON.createdAt
    If pJSON.%IsDefined("context") Set tRequest.Context = pJSON.context
    If pJSON.%IsDefined("metadata") Set tRequest.Metadata = pJSON.metadata
    
    // Restore history
    If pJSON.%IsDefined("processingHistory") {
        Set tIter = pJSON.processingHistory.%GetIterator()
        While tIter.%GetNext(.tKey, .tValue) {
            Do tRequest.ProcessingHistory.Insert(tValue)
        }
    }
    
    Quit tRequest
}

}
