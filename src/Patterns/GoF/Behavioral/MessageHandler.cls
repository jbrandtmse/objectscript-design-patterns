/// Interface for handling messages in a decoupled way
Class Patterns.GoF.Behavioral.MessageHandler Extends %RegisteredObject [ Abstract ]
{

/// <p>
/// <b>Purpose:</b> Define contract for message handling without coupling to specific implementations.<br/>
/// <b>GoF Pattern:</b> Mediator Pattern - Decoupling Interface<br/>
/// <b>Design Principle:</b> Program to interfaces, not implementations
/// </p>
/// Handle an incoming message
/// @param pMessage The message object containing type, sender, and data
/// @return Status of message handling
Method HandleMessage(pMessage As Patterns.GoF.Behavioral.Message) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// <p>
/// <b>Purpose:</b> Check if this handler can process a specific message type.<br/>
/// <b>Pattern Usage:</b> Chain of Responsibility integration with Mediator
/// </p>
/// Check if this handler can process the message type
/// @param pMessageType The type of message to check
/// @return Boolean indicating if handler can process this type
Method CanHandle(pMessageType As %String) As %Boolean [ Abstract ]
{
    Quit 0
}

/// <p>
/// <b>Purpose:</b> Get supported message types for dynamic routing.<br/>
/// <b>Benefit:</b> Allows mediator to build routing table dynamically
/// </p>
/// Get list of message types this handler supports
/// @return List of supported message types
Method GetSupportedTypes() As %ListOfDataTypes [ Abstract ]
{
    Quit $$$NULLOREF
}

/// <p>
/// <b>Purpose:</b> Priority for handling messages when multiple handlers exist.<br/>
/// <b>Pattern:</b> Strategy pattern for handler selection
/// </p>
/// Get handler priority (higher number = higher priority)
/// @return Priority value (0-100)
Method GetPriority() As %Integer [ Abstract ]
{
    Quit 0
}

}
