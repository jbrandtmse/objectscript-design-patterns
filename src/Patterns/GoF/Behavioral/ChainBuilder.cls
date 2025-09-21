/// Gang of Four Chain of Responsibility Pattern - Chain Builder Utility
/// 
/// Intent:
/// Provides a fluent interface for building handler chains dynamically
/// with support for priority-based ordering and runtime modifications.
/// 
/// @see Patterns.GoF.Behavioral.Handler
/// @see Patterns.GoF.Behavioral.ConcreteHandler
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ChainBuilder Extends %RegisteredObject
{

/// List of handlers to be chained
Property Handlers As list Of Handler;

/// Whether to sort handlers by priority
Property SortByPriority As %Boolean [ InitialExpression = 1 ];

/// Registry of handler classes for dynamic instantiation
Property HandlerRegistry As %DynamicObject;

/// Constructor
/// 
/// @return %Status
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize handler registry
        Set ..HandlerRegistry = {}
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Add a handler to the builder
/// 
/// @param pHandler The handler to add
/// @return ChainBuilder for fluent interface
Method AddHandler(pHandler As Handler) As ChainBuilder
{
    Do ..Handlers.Insert(pHandler)
    Quit $this
}

/// Add multiple handlers at once
/// 
/// @param pHandlers Array of handlers to add
/// @return ChainBuilder for fluent interface
Method AddHandlers(pHandlers... As Handler) As ChainBuilder
{
    Set tCount = $GET(pHandlers)
    For i=1:1:tCount {
        If $IsObject(pHandlers(i)) {
            Do ..Handlers.Insert(pHandlers(i))
        }
    }
    Quit $this
}

/// Register a handler class for dynamic instantiation
/// 
/// @param pName Registration name
/// @param pClassName Full class name of the handler
Method RegisterHandlerClass(pName As %String, pClassName As %String)
{
    Do ..HandlerRegistry.%Set(pName, pClassName)
}

/// Create and add a handler by registered name
/// 
/// @param pName Registered handler name
/// @param pConfig Optional configuration object
/// @return ChainBuilder for fluent interface
Method AddHandlerByName(pName As %String, pConfig As %DynamicObject = "") As ChainBuilder
{
    Set tClassName = ..HandlerRegistry.%Get(pName)
    
    If tClassName '= "" {
        Try {
            // Create instance of the handler
            Set tHandler = $CLASSMETHOD(tClassName, "%New")
            
            // Apply configuration if provided
            If $IsObject(pConfig) {
                If $IsObject(tHandler) && tHandler.%IsA("Patterns.GoF.Behavioral.ConcreteHandler") {
                    Set tHandler.Configuration = pConfig
                    
                    // Set specific properties from config
                    If pConfig.%IsDefined("priority") {
                        Set tHandler.Priority = pConfig.priority
                    }
                    If pConfig.%IsDefined("enabled") {
                        Set tHandler.Enabled = pConfig.enabled
                    }
                    If pConfig.%IsDefined("maxRequests") {
                        Set tHandler.MaxRequests = pConfig.maxRequests
                    }
                }
            }
            
            Do ..Handlers.Insert(tHandler)
        }
        Catch ex {
            // Log error but continue building
            Do ##class(%SYS.System).WriteToConsoleLog("ChainBuilder: Failed to create handler " _ pName _ ": " _ ex.Name)
        }
    }
    
    Quit $this
}

/// Build the chain of handlers
/// 
/// @return The first handler in the chain (or empty if no handlers)
Method Build() As Handler
{
    Set tFirst = ""
    
    // Sort handlers if requested
    If ..SortByPriority {
        Do ..SortHandlers()
    }
    
    // Chain the handlers together
    Set tCount = ..Handlers.Count()
    
    If tCount > 0 {
        Set tFirst = ..Handlers.GetAt(1)
        Set tPrevious = tFirst
        
        For i=2:1:tCount {
            Set tCurrent = ..Handlers.GetAt(i)
            Do tPrevious.SetNext(tCurrent)
            Set tPrevious = tCurrent
        }
    }
    
    Quit tFirst
}

/// Sort handlers by priority (lower number = higher priority)
Method SortHandlers() [ Private ]
{
    Set tCount = ..Handlers.Count()
    If tCount <= 1 Quit
    
    // Simple bubble sort for small collections
    For i=1:1:tCount-1 {
        For j=1:1:tCount-i {
            Set tHandler1 = ..Handlers.GetAt(j)
            Set tHandler2 = ..Handlers.GetAt(j+1)
            
            Set tPriority1 = 100  // Default priority
            Set tPriority2 = 100
            
            // Get priorities if ConcreteHandler
            If $IsObject(tHandler1) && tHandler1.%IsA("Patterns.GoF.Behavioral.ConcreteHandler") {
                Set tPriority1 = tHandler1.Priority
            }
            If $IsObject(tHandler2) && tHandler2.%IsA("Patterns.GoF.Behavioral.ConcreteHandler") {
                Set tPriority2 = tHandler2.Priority
            }
            
            // Swap if needed (lower priority number comes first)
            If tPriority1 > tPriority2 {
                Do ..Handlers.SetAt(tHandler2, j)
                Do ..Handlers.SetAt(tHandler1, j+1)
            }
        }
    }
}

/// Clear all handlers from the builder
Method Clear()
{
    Do ..Handlers.Clear()
}

/// Get the current number of handlers
/// 
/// @return %Integer count of handlers
Method GetHandlerCount() As %Integer
{
    Quit ..Handlers.Count()
}

/// Create a chain from a JSON configuration
/// 
/// @param pConfig JSON configuration object or string
/// @return The first handler in the built chain
ClassMethod BuildFromJSON(pConfig) As Handler
{
    Set tBuilder = ##class(ChainBuilder).%New()
    
    // Handle string or object input
    If '$IsObject(pConfig) {
        Set pConfig = {}.%FromJSON(pConfig)
    }
    
    // Set builder options
    If pConfig.%IsDefined("sortByPriority") {
        Set tBuilder.SortByPriority = pConfig.sortByPriority
    }
    
    // Register handler classes if provided
    If pConfig.%IsDefined("registry") {
        Set tIter = pConfig.registry.%GetIterator()
        While tIter.%GetNext(.tName, .tClassName) {
            Do tBuilder.RegisterHandlerClass(tName, tClassName)
        }
    }
    
    // Add handlers
    If pConfig.%IsDefined("handlers") {
        Set tIter = pConfig.handlers.%GetIterator()
        While tIter.%GetNext(.tKey, .tHandlerConfig) {
            If tHandlerConfig.%IsDefined("type") {
                // Create by registered type
                Set tHandlerOptions = {}
                If tHandlerConfig.%IsDefined("priority") Set tHandlerOptions.priority = tHandlerConfig.priority
                If tHandlerConfig.%IsDefined("enabled") Set tHandlerOptions.enabled = tHandlerConfig.enabled
                If tHandlerConfig.%IsDefined("maxRequests") Set tHandlerOptions.maxRequests = tHandlerConfig.maxRequests
                If tHandlerConfig.%IsDefined("config") Set tHandlerOptions.config = tHandlerConfig.config
                
                Do tBuilder.AddHandlerByName(tHandlerConfig.type, tHandlerOptions)
            }
            ElseIf tHandlerConfig.%IsDefined("className") {
                // Create directly by class name
                Try {
                    Set tHandler = $CLASSMETHOD(tHandlerConfig.className, "%New")
                    
                    If $IsObject(tHandler) && tHandler.%IsA("Patterns.GoF.Behavioral.ConcreteHandler") {
                        If tHandlerConfig.%IsDefined("priority") Set tHandler.Priority = tHandlerConfig.priority
                        If tHandlerConfig.%IsDefined("enabled") Set tHandler.Enabled = tHandlerConfig.enabled
                        If tHandlerConfig.%IsDefined("maxRequests") Set tHandler.MaxRequests = tHandlerConfig.maxRequests
                    }
                    
                    Do tBuilder.AddHandler(tHandler)
                }
                Catch ex {
                    // Continue with other handlers
                }
            }
        }
    }
    
    Quit tBuilder.Build()
}

/// Create a simple linear chain from an array of handler class names
/// 
/// @param pClassNames Comma-delimited list of handler class names
/// @return The first handler in the chain
ClassMethod QuickChain(pClassNames As %String) As Handler
{
    Set tBuilder = ##class(ChainBuilder).%New()
    Set tBuilder.SortByPriority = 0  // Maintain order as provided
    
    Set tCount = $LENGTH(pClassNames, ",")
    For i=1:1:tCount {
        Set tClassName = $ZSTRIP($PIECE(pClassNames, ",", i), "<>W")
        If tClassName '= "" {
            Try {
                Set tHandler = $CLASSMETHOD(tClassName, "%New")
                Do tBuilder.AddHandler(tHandler)
            }
            Catch ex {
                // Skip invalid class names
            }
        }
    }
    
    Quit tBuilder.Build()
}

}
