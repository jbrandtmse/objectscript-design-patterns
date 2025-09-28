/// Message object for decoupled communication
Class Patterns.GoF.Behavioral.Message Extends %RegisteredObject
{

/// Message type identifier
Property Type As %String;

/// Sender identifier (can be colleague ID, service name, etc.)
Property Sender As %String;

/// Target identifier (optional, for directed messages)
Property Target As %String;

/// Message payload as dynamic object
Property Data As %DynamicObject;

/// Priority level (0-100, higher is more important)
Property Priority As %Integer [ InitialExpression = 50 ];

/// Timestamp of message creation
Property Timestamp As %TimeStamp [ InitialExpression = {$ZDATETIME($ZTIMESTAMP,3)} ];

/// Message ID for tracking
Property MessageId As %String [ InitialExpression = {$SYSTEM.Util.CreateGUID()} ];

/// Correlation ID for request-response tracking
Property CorrelationId As %String;

/// Headers for metadata
Property Headers As %DynamicObject;

/// <p>
/// <b>Purpose:</b> Factory method for creating messages easily.<br/>
/// <b>Pattern:</b> Factory Method for consistent object creation
/// </p>
/// Create a new message
/// @param pType Message type
/// @param pSender Sender identifier
/// @param pData Message data
/// @return New message instance
ClassMethod Create(pType As %String, pSender As %String, pData As %DynamicObject = "") As Patterns.GoF.Behavioral.Message
{
    Set msg = ..%New()
    Set msg.Type = pType
    Set msg.Sender = pSender
    If pData '= "" {
        Set msg.Data = pData
    } Else {
        Set msg.Data = {}
    }
    Quit msg
}

/// <p>
/// <b>Purpose:</b> Create a response message maintaining correlation.<br/>
/// <b>Benefit:</b> Ensures request-response tracking in async systems
/// </p>
/// Create response message
/// @param pOriginal Original message to respond to
/// @param pType Response type
/// @param pData Response data
/// @return Response message
ClassMethod CreateResponse(pOriginal As Patterns.GoF.Behavioral.Message, pType As %String, pData As %DynamicObject = "") As Patterns.GoF.Behavioral.Message
{
    Set response = ..Create(pType, pOriginal.Target, pData)
    Set response.Target = pOriginal.Sender
    Set response.CorrelationId = pOriginal.MessageId
    Quit response
}

/// <p>
/// <b>Purpose:</b> Add header metadata without modifying message structure.<br/>
/// <b>Pattern:</b> Decorator-like behavior for message enhancement
/// </p>
/// Add header value
/// @param pKey Header key
/// @param pValue Header value
Method AddHeader(pKey As %String, pValue As %String) As %Status
{
    If ..Headers = "" {
        Set ..Headers = {}
    }
    Do ..Headers.%Set(pKey, pValue)
    Quit $$$OK
}

/// <p>
/// <b>Purpose:</b> Retrieve header value for processing decisions.<br/>
/// </p>
/// Get header value
/// @param pKey Header key
/// @return Header value or empty string
Method GetHeader(pKey As %String) As %String
{
    If ..Headers = "" {
        Quit ""
    }
    If ..Headers.%IsDefined(pKey) {
        Quit ..Headers.%Get(pKey)
    }
    Quit ""
}

/// <p>
/// <b>Purpose:</b> Check if message matches criteria for filtering.<br/>
/// <b>Usage:</b> Used by mediator for message routing decisions
/// </p>
/// Check if message matches filter criteria
/// @param pFilter Dynamic object with filter criteria
/// @return Boolean indicating match
Method MatchesFilter(pFilter As %DynamicObject) As %Boolean
{
    Set result = 1  // Assume match until proven otherwise
    
    Try {
        // Check type filter
        If pFilter.%IsDefined("type") {
            If ..Type '= pFilter.type {
                Set result = 0
                Quit
            }
        }
        
        // Check sender filter
        If pFilter.%IsDefined("sender") {
            If ..Sender '= pFilter.sender {
                Set result = 0
                Quit
            }
        }
        
        // Check priority filter
        If pFilter.%IsDefined("minPriority") {
            If ..Priority < pFilter.minPriority {
                Set result = 0
                Quit
            }
        }
        
        // Check header filters
        If pFilter.%IsDefined("headers") {
            Set iter = pFilter.headers.%GetIterator()
            While iter.%GetNext(.key, .value) {
                If ..GetHeader(key) '= value {
                    Set result = 0
                    Quit
                }
            }
        }
    }
    Catch ex {
        Set result = 0
    }
    
    Quit result
}

/// <p>
/// <b>Purpose:</b> Clone message for broadcast or retry scenarios.<br/>
/// <b>Pattern:</b> Prototype pattern integration
/// </p>
/// Clone this message
/// @return Cloned message
Method Clone() As Patterns.GoF.Behavioral.Message
{
    Set clone = ##class(Patterns.GoF.Behavioral.Message).%New()
    Set clone.Type = ..Type
    Set clone.Sender = ..Sender
    Set clone.Target = ..Target
    Set clone.Priority = ..Priority
    Set clone.CorrelationId = ..CorrelationId
    
    // Clone data if present
    If $ISOBJECT(..Data) {
        Set clone.Data = {}.%FromJSON(..Data.%ToJSON())
    }
    
    // Clone headers if present
    If $ISOBJECT(..Headers) {
        Set clone.Headers = {}.%FromJSON(..Headers.%ToJSON())
    }
    
    // New message gets new ID and timestamp
    Set clone.MessageId = $SYSTEM.Util.CreateGUID()
    Set clone.Timestamp = $ZDATETIME($ZTIMESTAMP,3)
    
    Quit clone
}

}
