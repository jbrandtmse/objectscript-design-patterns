/// Gang of Four Chain of Responsibility Pattern - Abstract Handler Base Class
/// 
/// Intent:
/// Avoid coupling the sender of a request to its receiver by giving more than
/// one object a chance to handle the request. Chain the receiving objects and
/// pass the request along the chain until an object handles it.
/// 
/// Participants:
/// - Handler (this class) - defines an interface for handling requests and
///   optionally implements the successor link
/// 
/// @see Patterns.GoF.Behavioral.Request
/// @see Patterns.GoF.Behavioral.Response
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Handler Extends %RegisteredObject [ Abstract ]
{

/// Reference to the next handler in the chain
Property NextHandler As Handler;

/// Set the next handler in the chain
/// 
/// @param pHandler The handler to set as next in chain
/// @return The handler that was set (for fluent interface)
/// 
/// Example:
/// <example>
/// Set handler1 = ##class(ConcreteHandler1).%New()
/// Set handler2 = ##class(ConcreteHandler2).%New()
/// Set handler3 = ##class(ConcreteHandler3).%New()
/// Do handler1.SetNext(handler2).SetNext(handler3)
/// </example>
Method SetNext(pHandler As Handler) As Handler
{
    Set ..NextHandler = pHandler
    Quit pHandler  // Return handler for fluent chaining
}

/// Abstract method to handle the request
/// Concrete handlers must implement this method
/// 
/// @param pRequest The request to handle
/// @return Response object containing the result
Method Handle(pRequest As Request) As Response [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Template method for handling requests with pass-through behavior
/// This method checks if the handler can process the request,
/// processes it if possible, or passes to the next handler
/// 
/// @param pRequest The request to process
/// @return Response from this handler or next in chain
Method HandleRequest(pRequest As Request) As Response
{
    Set tResponse = ""
    
    // Check if this handler can process the request
    If ..CanHandle(pRequest) {
        // Process the request
        Set tResponse = ..Process(pRequest)
        
        // Add handler info to response for tracking
        If $IsObject(tResponse) {
            Do tResponse.AddHandlerToChain(..%ClassName(1))
        }
        Quit tResponse
    }
    
    // Pass to next handler if available
    If $IsObject(..NextHandler) {
        Set tResponse = ..NextHandler.HandleRequest(pRequest)
        Quit tResponse
    }
    
    // No handler could process - return empty response
    Set tResponse = ##class(Response).%New()
    Set tResponse.Handled = 0
    Set tResponse.Message = "Request not handled by any handler in chain"
    Quit tResponse
}

/// Check if this handler can process the given request
/// Concrete handlers should override this method
/// 
/// @param pRequest The request to check
/// @return %Boolean indicating if this handler can process the request
Method CanHandle(pRequest As Request) As %Boolean [ Abstract ]
{
    Quit 0
}

/// Process the request and return a response
/// Concrete handlers must implement this method
/// 
/// @param pRequest The request to process
/// @return Response object with processing results
Method Process(pRequest As Request) As Response [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Get the total number of handlers in the chain starting from this handler
/// 
/// @return %Integer count of handlers in chain
Method GetChainLength() As %Integer
{
    Set tCount = 1
    Set tNext = ..NextHandler
    
    While $IsObject(tNext) {
        Set tCount = tCount + 1
        Set tNext = tNext.NextHandler
    }
    
    Quit tCount
}

/// Remove a specific handler from the chain
/// 
/// @param pHandlerClass The class name of handler to remove
/// @return %Boolean indicating if handler was found and removed
Method RemoveFromChain(pHandlerClass As %String) As %Boolean
{
    // Check if next handler is the one to remove
    If $IsObject(..NextHandler) {
        If ..NextHandler.%ClassName(1) = pHandlerClass {
            Set ..NextHandler = ..NextHandler.NextHandler
            Quit 1
        }
        // Recursively check rest of chain
        Quit ..NextHandler.RemoveFromChain(pHandlerClass)
    }
    
    Quit 0
}

/// Insert a handler after this one in the chain
/// 
/// @param pHandler The handler to insert
Method InsertAfter(pHandler As Handler)
{
    Set pHandler.NextHandler = ..NextHandler
    Set ..NextHandler = pHandler
}

/// Validate that the chain has no circular references
/// 
/// @return %Status indicating if chain is valid
Method ValidateChain() As %Status
{
    Set tSC = $$$OK
    Set tVisited = ""
    Set tCurrent = $this
    
    Try {
        While $IsObject(tCurrent) {
            Set tClassName = tCurrent.%ClassName(1) _ ":" _ tCurrent.%Oid()
            
            If $Data(tVisited(tClassName)) {
                Set tSC = $$$ERROR($$$GeneralError, "Circular reference detected in chain at: " _ tClassName)
                Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
            }
            
            Set tVisited(tClassName) = 1
            Set tCurrent = tCurrent.NextHandler
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get a list of all handler class names in the chain
/// 
/// @return %String comma-delimited list of handler class names
Method GetChainInfo() As %String
{
    Set tInfo = ..%ClassName(1)
    Set tNext = ..NextHandler
    
    While $IsObject(tNext) {
        Set tInfo = tInfo _ "," _ tNext.%ClassName(1)
        Set tNext = tNext.NextHandler
    }
    
    Quit tInfo
}

}
