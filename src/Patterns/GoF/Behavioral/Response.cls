/// Gang of Four Chain of Responsibility Pattern - Response Base Class
/// 
/// Intent:
/// Encapsulates the response from a handler in the chain.
/// Contains processing results, status, and chain traversal information.
/// 
/// @see Patterns.GoF.Behavioral.Handler
/// @see Patterns.GoF.Behavioral.Request
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Response Extends %RegisteredObject
{

/// Indicates if the request was handled successfully
Property Handled As %Boolean [ InitialExpression = 0 ];

/// The result data from processing
Property Result As %String(MAXLEN = "");

/// Status code for the response
Property StatusCode As %Integer [ InitialExpression = 0 ];

/// Human-readable message about the processing result
Property Message As %String(MAXLEN = "");

/// The handler that processed the request
Property HandledBy As %String;

/// List of all handlers the request passed through
Property ChainTraversal As list Of %String;

/// Time taken to process the request (in milliseconds)
Property ProcessingTime As %Integer;

/// Timestamp when response was created
Property CompletedAt As %TimeStamp [ InitialExpression = {$ZDateTime($ZTimeStamp, 3)} ];

/// Any errors that occurred during processing
Property Errors As list Of %String;

/// Additional response metadata
Property Metadata As %DynamicObject;

/// Response type (Success, Failure, Partial, Deferred)
Property ResponseType As %String [ InitialExpression = "Success" ];

/// Constructor to initialize response
/// 
/// @param pHandled Whether the request was handled
/// @param pMessage Response message
/// @return %Status
Method %OnNew(pHandled As %Boolean = 0, pMessage As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..Handled = pHandled
        If pMessage '= "" Set ..Message = pMessage
        
        // Initialize metadata
        Set ..Metadata = {}
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Create a successful response
/// 
/// @param pResult The result data
/// @param pMessage Success message
/// @return Response object
ClassMethod Success(pResult As %String = "", pMessage As %String = "Request processed successfully") As Response
{
    Set tResponse = ##class(Response).%New(1, pMessage)
    Set tResponse.Result = pResult
    Set tResponse.StatusCode = 200
    Set tResponse.ResponseType = "Success"
    Quit tResponse
}

/// Create a failure response
/// 
/// @param pMessage Error message
/// @param pStatusCode Error status code
/// @return Response object
ClassMethod Failure(pMessage As %String = "Request processing failed", pStatusCode As %Integer = 500) As Response
{
    Set tResponse = ##class(Response).%New(0, pMessage)
    Set tResponse.StatusCode = pStatusCode
    Set tResponse.ResponseType = "Failure"
    Quit tResponse
}

/// Create a partial success response
/// 
/// @param pResult Partial result data
/// @param pMessage Partial success message
/// @return Response object
ClassMethod Partial(pResult As %String = "", pMessage As %String = "Request partially processed") As Response
{
    Set tResponse = ##class(Response).%New(1, pMessage)
    Set tResponse.Result = pResult
    Set tResponse.StatusCode = 206
    Set tResponse.ResponseType = "Partial"
    Quit tResponse
}

/// Create a deferred response (request accepted but processing later)
/// 
/// @param pMessage Deferred message
/// @return Response object
ClassMethod Deferred(pMessage As %String = "Request accepted for later processing") As Response
{
    Set tResponse = ##class(Response).%New(0, pMessage)
    Set tResponse.StatusCode = 202
    Set tResponse.ResponseType = "Deferred"
    Quit tResponse
}

/// Add a handler to the chain traversal list
/// 
/// @param pHandlerName Name of the handler
Method AddHandlerToChain(pHandlerName As %String)
{
    Do ..ChainTraversal.Insert(pHandlerName)
    
    // Update HandledBy if this is the handler that processed the request
    If ..Handled && (..HandledBy = "") {
        Set ..HandledBy = pHandlerName
    }
}

/// Add an error to the response
/// 
/// @param pError Error message
Method AddError(pError As %String)
{
    Do ..Errors.Insert(pError)
    
    // Update status if this is the first error
    If ..Errors.Count() = 1 {
        Set ..Handled = 0
        Set ..ResponseType = "Failure"
        If ..StatusCode = 0 Set ..StatusCode = 500
    }
}

/// Check if response has errors
/// 
/// @return %Boolean
Method HasErrors() As %Boolean
{
    Quit (..Errors.Count() > 0)
}

/// Get all errors as a formatted string
/// 
/// @param pDelimiter Delimiter between errors
/// @return %String formatted errors
Method GetErrorsString(pDelimiter As %String = "; ") As %String
{
    Set tErrors = ""
    Set tCount = ..Errors.Count()
    
    For i=1:1:tCount {
        If tErrors '= "" Set tErrors = tErrors _ pDelimiter
        Set tErrors = tErrors _ ..Errors.GetAt(i)
    }
    
    Quit tErrors
}

/// Get chain traversal as a formatted string
/// 
/// @return %String formatted chain traversal
Method GetChainTraversalString() As %String
{
    Set tChain = ""
    Set tCount = ..ChainTraversal.Count()
    
    For i=1:1:tCount {
        If tChain '= "" Set tChain = tChain _ " -> "
        Set tChain = tChain _ ..ChainTraversal.GetAt(i)
    }
    
    Quit tChain
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

/// Merge another response into this one (for aggregating responses)
/// 
/// @param pResponse The response to merge
Method Merge(pResponse As Response)
{
    // Combine results
    If pResponse.Result '= "" {
        If ..Result '= "" Set ..Result = ..Result _ "; "
        Set ..Result = ..Result _ pResponse.Result
    }
    
    // Combine messages
    If pResponse.Message '= "" {
        If ..Message '= "" Set ..Message = ..Message _ "; "
        Set ..Message = ..Message _ pResponse.Message
    }
    
    // Add errors
    Set tCount = pResponse.Errors.Count()
    For i=1:1:tCount {
        Do ..AddError(pResponse.Errors.GetAt(i))
    }
    
    // Merge chain traversal
    Set tCount = pResponse.ChainTraversal.Count()
    For i=1:1:tCount {
        Do ..ChainTraversal.Insert(pResponse.ChainTraversal.GetAt(i))
    }
    
    // Update processing time
    Set ..ProcessingTime = ..ProcessingTime + pResponse.ProcessingTime
    
    // Update handled status (both must be handled for merged to be handled)
    Set ..Handled = ..Handled && pResponse.Handled
}

/// Get a summary of the response for logging/display
/// 
/// @return %String summary
Method GetSummary() As %String
{
    Set tSummary = "Response[Type=" _ ..ResponseType
    Set tSummary = tSummary _ ", Handled=" _ $Select(..Handled:"Yes", 1:"No")
    Set tSummary = tSummary _ ", Status=" _ ..StatusCode
    If ..HandledBy '= "" Set tSummary = tSummary _ ", Handler=" _ ..HandledBy
    If ..ProcessingTime > 0 Set tSummary = tSummary _ ", Time=" _ ..ProcessingTime _ "ms"
    If ..HasErrors() Set tSummary = tSummary _ ", Errors=" _ ..Errors.Count()
    Set tSummary = tSummary _ "]"
    
    Quit tSummary
}

/// Convert response to JSON for serialization
/// 
/// @return %DynamicObject
Method ToJSON() As %DynamicObject
{
    Set tJSON = {}
    Set tJSON.handled = ..Handled
    Set tJSON.result = ..Result
    Set tJSON.statusCode = ..StatusCode
    Set tJSON.message = ..Message
    Set tJSON.handledBy = ..HandledBy
    Set tJSON.responseType = ..ResponseType
    Set tJSON.completedAt = ..CompletedAt
    Set tJSON.processingTime = ..ProcessingTime
    
    If $IsObject(..Metadata) Set tJSON.metadata = ..Metadata
    
    // Add chain traversal
    Set tChain = []
    Set tCount = ..ChainTraversal.Count()
    For i=1:1:tCount {
        Do tChain.%Push(..ChainTraversal.GetAt(i))
    }
    Set tJSON.chainTraversal = tChain
    
    // Add errors
    Set tErrorList = []
    Set tCount = ..Errors.Count()
    For i=1:1:tCount {
        Do tErrorList.%Push(..Errors.GetAt(i))
    }
    Set tJSON.errors = tErrorList
    
    Quit tJSON
}

/// Create a Response from JSON
/// 
/// @param pJSON The JSON object or string
/// @return Response object
ClassMethod FromJSON(pJSON) As Response
{
    Set tResponse = ##class(Response).%New()
    
    // Handle string or object input
    If '$IsObject(pJSON) {
        Set pJSON = {}.%FromJSON(pJSON)
    }
    
    Set tResponse.Handled = pJSON.handled
    Set tResponse.Result = pJSON.result
    Set tResponse.StatusCode = pJSON.statusCode
    Set tResponse.Message = pJSON.message
    Set tResponse.HandledBy = pJSON.handledBy
    Set tResponse.ResponseType = pJSON.responseType
    
    If pJSON.%IsDefined("completedAt") Set tResponse.CompletedAt = pJSON.completedAt
    If pJSON.%IsDefined("processingTime") Set tResponse.ProcessingTime = pJSON.processingTime
    If pJSON.%IsDefined("metadata") Set tResponse.Metadata = pJSON.metadata
    
    // Restore chain traversal
    If pJSON.%IsDefined("chainTraversal") {
        Set tIter = pJSON.chainTraversal.%GetIterator()
        While tIter.%GetNext(.tKey, .tValue) {
            Do tResponse.ChainTraversal.Insert(tValue)
        }
    }
    
    // Restore errors
    If pJSON.%IsDefined("errors") {
        Set tIter = pJSON.errors.%GetIterator()
        While tIter.%GetNext(.tKey, .tValue) {
            Do tResponse.Errors.Insert(tValue)
        }
    }
    
    Quit tResponse
}

/// Check if the response indicates success
/// 
/// @return %Boolean
Method IsSuccess() As %Boolean
{
    Quit (..Handled && (..ResponseType = "Success") && '..HasErrors())
}

/// Check if the response indicates failure
/// 
/// @return %Boolean
Method IsFailure() As %Boolean
{
    Quit ('..Handled || (..ResponseType = "Failure") || ..HasErrors())
}

/// Check if the response is partial
/// 
/// @return %Boolean
Method IsPartial() As %Boolean
{
    Quit (..ResponseType = "Partial")
}

/// Check if the response is deferred
/// 
/// @return %Boolean
Method IsDeferred() As %Boolean
{
    Quit (..ResponseType = "Deferred")
}

}
