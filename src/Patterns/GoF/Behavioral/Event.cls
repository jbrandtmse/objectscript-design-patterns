/// Gang of Four Mediator Pattern - Event Object
/// 
/// Purpose:
/// Represents an event in the event-based communication system.
/// Encapsulates event data, metadata, and behavior for the
/// Mediator pattern's event-driven architecture.
/// 
/// Features:
/// - Event types and priorities
/// - Payload management
/// - Event lifecycle (cancelable, bubbling)
/// - Correlation ID for request/response pairs
/// - Timestamp and audit information
Class Patterns.GoF.Behavioral.Event Extends %RegisteredObject
{

/// Event types
Parameter TYPEREQUEST = "REQUEST";

Parameter TYPERESPONSE = "RESPONSE";

Parameter TYPENOTIFICATION = "NOTIFICATION";

Parameter TYPEALERT = "ALERT";

Parameter TYPEEMERGENCY = "EMERGENCY";

Parameter TYPEBROADCAST = "BROADCAST";

/// Priority levels
Parameter PRIORITYLOW = 1;

Parameter PRIORITYNORMAL = 5;

Parameter PRIORITYHIGH = 8;

Parameter PRIORITYCRITICAL = 10;

/// Unique event identifier
Property EventId As %String [ InitialExpression = {$System.Util.CreateGUID()} ];

/// Event type (REQUEST, RESPONSE, NOTIFICATION, etc.)
Property EventType As %String;

/// Event priority (1-10, where 10 is highest)
Property Priority As %Integer [ InitialExpression = 5 ];

/// Sender colleague ID
Property SenderId As %String;

/// Target colleague ID (optional, for targeted messages)
Property TargetId As %String;

/// Event payload data
Property Payload As %DynamicObject;

/// Timestamp when event was created
Property Timestamp As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG, 3)} ];

/// Correlation ID for linking related events
Property CorrelationId As %String;

/// Whether this event can bubble up through hierarchy
Property Bubbles As %Boolean [ InitialExpression = 0 ];

/// Whether this event has been canceled
Property Canceled As %Boolean [ InitialExpression = 0 ];

/// Whether this event has been handled
Property Handled As %Boolean [ InitialExpression = 0 ];

/// Error status if event processing failed
Property ErrorStatus As %Status;

/// Event metadata (headers, context, etc.)
Property Metadata As %ArrayOfDataTypes;

/// Constructor
Method %OnNew(pEventType As %String = "", pPayload As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pEventType '= "" {
            Set ..EventType = pEventType
        }
        
        If $IsObject(pPayload) {
            Set ..Payload = pPayload
        } Else {
            Set ..Payload = ##class(%DynamicObject).%New()
        }
        
        Set ..Metadata = ##class(%ArrayOfDataTypes).%New()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Create a request event
ClassMethod CreateRequest(pSenderId As %String, pTargetId As %String = "", pPayload As %DynamicObject = "") As Event
{
    Set tEvent = ..%New(..#TYPEREQUEST, pPayload)
    Set tEvent.SenderId = pSenderId
    Set tEvent.TargetId = pTargetId
    Set tEvent.Priority = ..#PRIORITYNORMAL
    
    Quit tEvent
}

/// Create a response event
ClassMethod CreateResponse(pSenderId As %String, pTargetId As %String, pCorrelationId As %String, pPayload As %DynamicObject = "") As Event
{
    Set tEvent = ..%New(..#TYPERESPONSE, pPayload)
    Set tEvent.SenderId = pSenderId
    Set tEvent.TargetId = pTargetId
    Set tEvent.CorrelationId = pCorrelationId
    Set tEvent.Priority = ..#PRIORITYNORMAL
    
    Quit tEvent
}

/// Create a notification event
ClassMethod CreateNotification(pSenderId As %String, pPayload As %DynamicObject = "") As Event
{
    Set tEvent = ..%New(..#TYPENOTIFICATION, pPayload)
    Set tEvent.SenderId = pSenderId
    Set tEvent.Priority = ..#PRIORITYLOW
    Set tEvent.Bubbles = 1
    
    Quit tEvent
}

/// Create an alert event
ClassMethod CreateAlert(pSenderId As %String, pMessage As %String, pPriority As %Integer = 8) As Event
{
    Set tPayload = ##class(%DynamicObject).%New()
    Set tPayload.message = pMessage
    Set tPayload.alertTime = $ZDATETIME($HOROLOG, 3)
    
    Set tEvent = ..%New(..#TYPEALERT, tPayload)
    Set tEvent.SenderId = pSenderId
    Set tEvent.Priority = pPriority
    Set tEvent.Bubbles = 1
    
    Quit tEvent
}

/// Create an emergency event
ClassMethod CreateEmergency(pSenderId As %String, pPayload As %DynamicObject = "") As Event
{
    Set tEvent = ..%New(..#TYPEEMERGENCY, pPayload)
    Set tEvent.SenderId = pSenderId
    Set tEvent.Priority = ..#PRIORITYCRITICAL
    Set tEvent.Bubbles = 1
    
    Quit tEvent
}

/// Create a broadcast event
ClassMethod CreateBroadcast(pSenderId As %String, pPayload As %DynamicObject = "") As Event
{
    Set tEvent = ..%New(..#TYPEBROADCAST, pPayload)
    Set tEvent.SenderId = pSenderId
    Set tEvent.Priority = ..#PRIORITYNORMAL
    
    Quit tEvent
}

/// Cancel this event
Method Cancel() As %Status
{
    Set ..Canceled = 1
    Quit $$$OK
}

/// Mark event as handled
Method MarkHandled() As %Status
{
    Set ..Handled = 1
    Quit $$$OK
}

/// Check if event should be processed
Method ShouldProcess() As %Boolean
{
    Quit '..Canceled && '..Handled
}

/// Add metadata to event
Method AddMetadata(pKey As %String, pValue As %String) As %Status
{
    Do ..Metadata.SetAt(pValue, pKey)
    Quit $$$OK
}

/// Get metadata value
Method GetMetadata(pKey As %String) As %String
{
    Set tValue = ""
    If ..Metadata.IsDefined(pKey) {
        Set tValue = ..Metadata.GetAt(pKey)
    }
    Quit tValue
}

/// Clone this event
Method Clone() As Event
{
    Set tClone = ##class(Event).%New()
    
    // Copy all properties
    Set tClone.EventType = ..EventType
    Set tClone.Priority = ..Priority
    Set tClone.SenderId = ..SenderId
    Set tClone.TargetId = ..TargetId
    Set tClone.CorrelationId = ..CorrelationId
    Set tClone.Bubbles = ..Bubbles
    Set tClone.Canceled = ..Canceled
    Set tClone.Handled = ..Handled
    
    // Clone payload if present
    If $IsObject(..Payload) {
        Set tClone.Payload = ##class(%DynamicObject).%FromJSON(..Payload.%ToJSON())
    }
    
    // Clone metadata
    Set tKey = ""
    For {
        Set tKey = ..Metadata.Next(tKey)
        Quit:tKey=""
        Do tClone.Metadata.SetAt(..Metadata.GetAt(tKey), tKey)
    }
    
    Quit tClone
}

/// Convert event to JSON representation
Method ToJSON() As %DynamicObject
{
    Set tJSON = ##class(%DynamicObject).%New()
    
    Set tJSON.eventId = ..EventId
    Set tJSON.eventType = ..EventType
    Set tJSON.priority = ..Priority
    Set tJSON.senderId = ..SenderId
    Set tJSON.targetId = ..TargetId
    Set tJSON.correlationId = ..CorrelationId
    Set tJSON.timestamp = ..Timestamp
    Set tJSON.bubbles = ..Bubbles
    Set tJSON.canceled = ..Canceled
    Set tJSON.handled = ..Handled
    
    If $IsObject(..Payload) {
        Set tJSON.payload = ..Payload
    }
    
    // Add metadata
    Set tMetadataObj = ##class(%DynamicObject).%New()
    Set tKey = ""
    For {
        Set tKey = ..Metadata.Next(tKey)
        Quit:tKey=""
        Do tMetadataObj.%Set(tKey, ..Metadata.GetAt(tKey))
    }
    Set tJSON.metadata = tMetadataObj
    
    Quit tJSON
}

/// Create event from JSON representation
ClassMethod FromJSON(pJSON As %DynamicObject) As Event
{
    Set tEvent = ##class(Event).%New()
    
    Try {
        If pJSON.%IsDefined("eventId") Set tEvent.EventId = pJSON.eventId
        If pJSON.%IsDefined("eventType") Set tEvent.EventType = pJSON.eventType
        If pJSON.%IsDefined("priority") Set tEvent.Priority = pJSON.priority
        If pJSON.%IsDefined("senderId") Set tEvent.SenderId = pJSON.senderId
        If pJSON.%IsDefined("targetId") Set tEvent.TargetId = pJSON.targetId
        If pJSON.%IsDefined("correlationId") Set tEvent.CorrelationId = pJSON.correlationId
        If pJSON.%IsDefined("timestamp") Set tEvent.Timestamp = pJSON.timestamp
        If pJSON.%IsDefined("bubbles") Set tEvent.Bubbles = pJSON.bubbles
        If pJSON.%IsDefined("canceled") Set tEvent.Canceled = pJSON.canceled
        If pJSON.%IsDefined("handled") Set tEvent.Handled = pJSON.handled
        If pJSON.%IsDefined("payload") Set tEvent.Payload = pJSON.payload
        
        // Load metadata
        If pJSON.%IsDefined("metadata") {
            Set tIterator = pJSON.metadata.%GetIterator()
            While tIterator.%GetNext(.tKey, .tValue) {
                Do tEvent.Metadata.SetAt(tValue, tKey)
            }
        }
    } Catch ex {
        // Return partially populated event
    }
    
    Quit tEvent
}

/// Compare priority with another event
Method ComparePriority(pOtherEvent As Event) As %Integer
{
    If '$IsObject(pOtherEvent) Quit 0
    
    If ..Priority > pOtherEvent.Priority Quit 1
    If ..Priority < pOtherEvent.Priority Quit -1
    
    // Same priority, compare timestamps (later events first)
    If $ZDATETIME(..Timestamp,3) > $ZDATETIME(pOtherEvent.Timestamp,3) Quit 1
    If $ZDATETIME(..Timestamp,3) < $ZDATETIME(pOtherEvent.Timestamp,3) Quit -1
    
    Quit 0
}

/// Validate event structure
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate required fields
        If ..EventType = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Event type is required")
            Quit
        }
        
        If ..SenderId = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Sender ID is required")
            Quit
        }
        
        // Validate priority range
        If (..Priority < 1) || (..Priority > 10) {
            Set tSC = $$$ERROR($$$GeneralError, "Priority must be between 1 and 10")
            Quit
        }
        
        // Validate event type
        Set tValidTypes = $LISTBUILD(..#TYPEREQUEST, ..#TYPERESPONSE, ..#TYPENOTIFICATION, 
                                     ..#TYPEALERT, ..#TYPEEMERGENCY, ..#TYPEBROADCAST)
        If '$LISTFIND(tValidTypes, ..EventType) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid event type: "_..EventType)
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
