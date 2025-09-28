/// Enhanced colleague with message-based communication
Class Patterns.GoF.Behavioral.DecoupledColleague Extends Patterns.GoF.Behavioral.Colleague
{

/// Message handler for processing incoming messages
Property MessageHandler As Patterns.GoF.Behavioral.MessageHandler;

/// Supported message types
Property SupportedTypes As %ListOfDataTypes;

/// Message queue for async processing
Property MessageQueue As %ListOfObjects;

/// Processing strategy (SYNC, ASYNC, PRIORITY)
Property ProcessingStrategy As %String [ InitialExpression = "SYNC" ];

/// <p>
/// <b>Purpose:</b> Initialize decoupled colleague with message handling.<br/>
/// <b>Pattern:</b> Template method for initialization
/// </p>
Method %OnNew() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    Set ..SupportedTypes = ##class(%ListOfDataTypes).%New()
    Set ..MessageQueue = ##class(%ListOfObjects).%New()
    
    Quit $$$OK
}

/// <p>
/// <b>Purpose:</b> Send message through mediator without knowing receiver.<br/>
/// <b>Decoupling:</b> Sender doesn't know who will receive the message<br/>
/// <b>Override:</b> Replaces direct Send method with message-based approach
/// </p>
/// Send message to mediator
/// @param pEvent Event type
/// @param pData Event data
/// @return Status
Method Send(pEvent As %String, pData As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Create message object
        Set message = ##class(Patterns.GoF.Behavioral.Message).Create(pEvent, ..GetId(), pData)
        
        // Send through mediator if available
        If $ISOBJECT(..Mediator) {
            // Use message-based notification
            Set tSC = ..Mediator.Notify($this, "MESSAGE", message)
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "No mediator configured")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <p>
/// <b>Purpose:</b> Send targeted message to specific colleague.<br/>
/// <b>Usage:</b> For request-response patterns
/// </p>
/// Send message to specific target
/// @param pTarget Target colleague ID
/// @param pEvent Event type
/// @param pData Event data
/// @return Status
Method SendTo(pTarget As %String, pEvent As %String, pData As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    Try {
        Set message = ##class(Patterns.GoF.Behavioral.Message).Create(pEvent, ..GetId(), pData)
        Set message.Target = pTarget
        
        If $ISOBJECT(..Mediator) {
            Set tSC = ..Mediator.Notify($this, "DIRECTED_MESSAGE", message)
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "No mediator configured")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <p>
/// <b>Purpose:</b> Broadcast message to all colleagues.<br/>
/// <b>Usage:</b> System-wide notifications
/// </p>
/// Broadcast message to all
/// @param pEvent Event type
/// @param pData Event data
/// @param pPriority Message priority
/// @return Status
Method Broadcast(pEvent As %String, pData As %DynamicObject = "", pPriority As %Integer = 50) As %Status
{
    Set tSC = $$$OK
    Try {
        Set message = ##class(Patterns.GoF.Behavioral.Message).Create(pEvent, ..GetId(), pData)
        Set message.Priority = pPriority
        
        If $ISOBJECT(..Mediator) {
            Set tSC = ..Mediator.Notify($this, "BROADCAST", message)
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "No mediator configured")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <p>
/// <b>Purpose:</b> Receive and process message based on strategy.<br/>
/// <b>Override:</b> Enhanced receive with message objects
/// </p>
/// Receive message from mediator
/// @param pMessage Message or event type
/// @param pData Event data
/// @return Status
Method Receive(pMessage As %String, pData As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Convert to message object if not already
        If '$ISOBJECT(pData) || ('pData.%IsA("Patterns.GoF.Behavioral.Message")) {
            Set messageObj = ##class(Patterns.GoF.Behavioral.Message).Create(pMessage, "Unknown", pData)
        } Else {
            Set messageObj = pData
        }
        
        // Process based on strategy
        If ..ProcessingStrategy = "ASYNC" {
            Set tSC = ..QueueMessage(messageObj)
        } ElseIf ..ProcessingStrategy = "PRIORITY" {
            Set tSC = ..QueueWithPriority(messageObj)
        } Else {
            Set tSC = ..ProcessMessage(messageObj)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <p>
/// <b>Purpose:</b> Process a message immediately.<br/>
/// <b>Pattern:</b> Template method for message processing
/// </p>
/// Process message
/// @param pMessage Message to process
/// @return Status
Method ProcessMessage(pMessage As Patterns.GoF.Behavioral.Message) As %Status
{
    Set tSC = $$$OK
    Try {
        // Check if we support this message type
        If ..SupportsMessageType(pMessage.Type) {
            // If we have a message handler, use it
            If $ISOBJECT(..MessageHandler) {
                Set tSC = ..MessageHandler.HandleMessage(pMessage)
            } Else {
                // Default processing - override in subclasses
                Set tSC = ..HandleMessage(pMessage)
            }
        } Else {
            // Ignore unsupported messages
            Set tSC = $$$OK
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <p>
/// <b>Purpose:</b> Default message handling - override in subclasses.<br/>
/// <b>Pattern:</b> Template method hook
/// </p>
/// Handle message (override in subclasses)
/// @param pMessage Message to handle
/// @return Status
Method HandleMessage(pMessage As Patterns.GoF.Behavioral.Message) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// <p>
/// <b>Purpose:</b> Check if this colleague handles a message type.<br/>
/// <b>Benefit:</b> Allows selective message processing
/// </p>
/// Check if message type is supported
/// @param pType Message type
/// @return Boolean
Method SupportsMessageType(pType As %String) As %Boolean
{
    Set result = 0
    For i=1:1:..SupportedTypes.Count() {
        If ..SupportedTypes.GetAt(i) = pType {
            Set result = 1
            Quit
        }
    }
    Quit result
}

/// <p>
/// <b>Purpose:</b> Register supported message type.<br/>
/// <b>Usage:</b> Called during initialization to declare capabilities
/// </p>
/// Add supported message type
/// @param pType Message type to support
/// @return Status
Method AddSupportedType(pType As %String) As %Status
{
    Do ..SupportedTypes.Insert(pType)
    Quit $$$OK
}

/// <p>
/// <b>Purpose:</b> Queue message for async processing.<br/>
/// <b>Pattern:</b> Producer-consumer for async handling
/// </p>
/// Queue message for later processing
/// @param pMessage Message to queue
/// @return Status
Method QueueMessage(pMessage As Patterns.GoF.Behavioral.Message) As %Status [ Private ]
{
    Do ..MessageQueue.Insert(pMessage)
    Quit $$$OK
}

/// <p>
/// <b>Purpose:</b> Queue with priority ordering.<br/>
/// <b>Algorithm:</b> Insert sort by priority
/// </p>
/// Queue message with priority
/// @param pMessage Message to queue
/// @return Status
Method QueueWithPriority(pMessage As Patterns.GoF.Behavioral.Message) As %Status [ Private ]
{
    Set inserted = 0
    For i=1:1:..MessageQueue.Count() {
        Set existing = ..MessageQueue.GetAt(i)
        If pMessage.Priority > existing.Priority {
            Do ..MessageQueue.InsertAt(pMessage, i)
            Set inserted = 1
            Quit
        }
    }
    
    If 'inserted {
        Do ..MessageQueue.Insert(pMessage)
    }
    
    Quit $$$OK
}

/// <p>
/// <b>Purpose:</b> Process queued messages.<br/>
/// <b>Usage:</b> Called periodically or on-demand
/// </p>
/// Process all queued messages
/// @return Status
Method ProcessQueue() As %Status
{
    Set tSC = $$$OK
    Try {
        While ..MessageQueue.Count() > 0 {
            Set message = ..MessageQueue.GetAt(1)
            Do ..MessageQueue.RemoveAt(1)
            Set tSC = ..ProcessMessage(message)
            If $$$ISERR(tSC) Quit
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <p>
/// <b>Purpose:</b> Get unique identifier for this colleague.<br/>
/// <b>Default:</b> Returns the ColleagueId from parent class
/// </p>
/// Get colleague identifier
/// @return Unique identifier
Method GetId() As %String
{
    Quit ..ColleagueId
}

/// <p>
/// <b>Purpose:</b> Request-response pattern support.<br/>
/// <b>Pattern:</b> Async request with correlation
/// </p>
/// Send request and expect response
/// @param pTarget Target colleague
/// @param pRequest Request type
/// @param pData Request data
/// @param pTimeout Timeout in seconds
/// @param pResponse Output response message
/// @return Status
Method SendRequest(pTarget As %String, pRequest As %String, pData As %DynamicObject = "", pTimeout As %Integer = 30, Output pResponse As Patterns.GoF.Behavioral.Message) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ""
    
    Try {
        // Create request message
        Set request = ##class(Patterns.GoF.Behavioral.Message).Create(pRequest, ..GetId(), pData)
        Set request.Target = pTarget
        
        // Store correlation ID for response matching
        Set correlationId = request.MessageId
        
        // Send request
        If $ISOBJECT(..Mediator) {
            Set tSC = ..Mediator.Notify($this, "REQUEST", request)
            If $$$ISERR(tSC) Quit
            
            // Wait for response (simplified - real implementation would use events)
            Set startTime = $PIECE($ZTIMESTAMP,",",2)
            Set found = 0
            
            While ('found) && (($PIECE($ZTIMESTAMP,",",2) - startTime) < pTimeout) {
                // Check message queue for response
                For i=1:1:..MessageQueue.Count() {
                    Set msg = ..MessageQueue.GetAt(i)
                    If msg.CorrelationId = correlationId {
                        Set pResponse = msg
                        Do ..MessageQueue.RemoveAt(i)
                        Set found = 1
                        Quit
                    }
                }
                
                If 'found {
                    Hang 0.1  // Brief wait before checking again
                }
            }
            
            If 'found {
                Set tSC = $$$ERROR($$$GeneralError, "Request timeout")
            }
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "No mediator configured")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
