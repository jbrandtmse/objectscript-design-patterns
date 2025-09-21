/// Gang of Four Chain of Responsibility Pattern - Concrete Handler Base Class
/// 
/// Intent:
/// Provides a base implementation for concrete handlers that can be easily
/// extended to create specific handlers with minimal code.
/// 
/// @see Patterns.GoF.Behavioral.Handler
/// @see Patterns.GoF.Behavioral.Request
/// @see Patterns.GoF.Behavioral.Response
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ConcreteHandler Extends Patterns.GoF.Behavioral.Handler
{

/// Priority of this handler (used for dynamic chain ordering)
Property Priority As %Integer [ InitialExpression = 100 ];

/// Handler name for identification
Property HandlerName As %String;

/// Whether this handler is enabled
Property Enabled As %Boolean [ InitialExpression = 1 ];

/// Configuration for this handler
Property Configuration As %DynamicObject;

/// Maximum number of requests this handler can process (-1 for unlimited)
Property MaxRequests As %Integer [ InitialExpression = -1 ];

/// Current number of requests processed
Property RequestsProcessed As %Integer [ InitialExpression = 0 ];

/// Constructor with optional name and priority
/// 
/// @param pName Handler name
/// @param pPriority Handler priority
/// @return %Status
Method %OnNew(pName As %String = "", pPriority As %Integer = 100) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pName = "" {
            Set ..HandlerName = ..%ClassName(1)
        } Else {
            Set ..HandlerName = pName
        }
        
        Set ..Priority = pPriority
        Set ..Configuration = {}
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Implementation of Handle method using template pattern
/// 
/// @param pRequest The request to handle
/// @return Response object
Method Handle(pRequest As Request) As Response
{
    // Use the template method from base class
    Quit ..HandleRequest(pRequest)
}

/// Check if this handler can process the request
/// Default implementation checks enabled status and request limit
/// 
/// @param pRequest The request to check
/// @return %Boolean
Method CanHandle(pRequest As Request) As %Boolean
{
    // Check if handler is enabled
    If '..Enabled Quit 0
    
    // Check request limit
    If (..MaxRequests > 0) && (..RequestsProcessed >= ..MaxRequests) {
        Quit 0
    }
    
    // Delegate to specific implementation
    Quit ..CanHandleSpecific(pRequest)
}

/// Specific check to be implemented by concrete handlers
/// 
/// @param pRequest The request to check
/// @return %Boolean
Method CanHandleSpecific(pRequest As Request) As %Boolean
{
    // Default implementation - override in subclasses
    Quit 0
}

/// Process the request
/// 
/// @param pRequest The request to process
/// @return Response object
Method Process(pRequest As Request) As Response
{
    Set tStartTime = $ZH
    Set tResponse = ""
    
    Try {
        // Increment processed count
        Set ..RequestsProcessed = ..RequestsProcessed + 1
        
        // Add to request history
        Do pRequest.AddToHistory(..HandlerName)
        
        // Update request status
        Set pRequest.Status = "Processing"
        
        // Perform actual processing
        Set tResponse = ..ProcessSpecific(pRequest)
        
        // Calculate processing time
        Set tEndTime = $ZH
        Set tProcessingTime = (tEndTime - tStartTime) * 1000  // Convert to milliseconds
        Set tResponse.ProcessingTime = tProcessingTime
        
        // Update response with handler info
        Set tResponse.HandledBy = ..HandlerName
        
        // Update request status
        Set pRequest.Status = $Select(tResponse.IsSuccess():"Completed", 1:"Failed")
    }
    Catch ex {
        // Create error response
        Set tResponse = ##class(Response).Failure("Handler error: " _ ex.Name, 500)
        Do tResponse.AddError(ex.Name _ ": " _ ex.Location)
        Set tResponse.HandledBy = ..HandlerName
    }
    
    Quit tResponse
}

/// Specific processing to be implemented by concrete handlers
/// 
/// @param pRequest The request to process
/// @return Response object
Method ProcessSpecific(pRequest As Request) As Response
{
    // Default implementation - override in subclasses
    Quit ##class(Response).Failure("ProcessSpecific not implemented in " _ ..%ClassName(1))
}

/// Set configuration value
/// 
/// @param pKey Configuration key
/// @param pValue Configuration value
Method SetConfig(pKey As %String, pValue As %String)
{
    If '$IsObject(..Configuration) Set ..Configuration = {}
    Do ..Configuration.%Set(pKey, pValue)
}

/// Get configuration value
/// 
/// @param pKey Configuration key
/// @param pDefault Default value if key not found
/// @return Configuration value
Method GetConfig(pKey As %String, pDefault As %String = "") As %String
{
    If '$IsObject(..Configuration) Quit pDefault
    If '..Configuration.%IsDefined(pKey) Quit pDefault
    Quit ..Configuration.%Get(pKey)
}

/// Enable this handler
Method Enable()
{
    Set ..Enabled = 1
}

/// Disable this handler
Method Disable()
{
    Set ..Enabled = 0
}

/// Reset the requests processed counter
Method ResetCounter()
{
    Set ..RequestsProcessed = 0
}

/// Get handler information
/// 
/// @return %String handler info
Method GetInfo() As %String
{
    Set tInfo = "Handler[Name=" _ ..HandlerName
    Set tInfo = tInfo _ ", Class=" _ ..%ClassName(1)
    Set tInfo = tInfo _ ", Priority=" _ ..Priority
    Set tInfo = tInfo _ ", Enabled=" _ $Select(..Enabled:"Yes", 1:"No")
    Set tInfo = tInfo _ ", Processed=" _ ..RequestsProcessed
    If ..MaxRequests > 0 Set tInfo = tInfo _ "/" _ ..MaxRequests
    Set tInfo = tInfo _ "]"
    
    Quit tInfo
}

/// Compare priority with another handler for sorting
/// 
/// @param pOther Another handler to compare
/// @return -1 if this has higher priority, 1 if lower, 0 if equal
Method ComparePriority(pOther As ConcreteHandler) As %Integer
{
    If ..Priority < pOther.Priority Quit -1
    If ..Priority > pOther.Priority Quit 1
    Quit 0
}

}
