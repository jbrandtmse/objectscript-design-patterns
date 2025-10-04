/// Service Context - Request metadata and context information
/// 
/// Intent:
/// Encapsulate request-level metadata and contextual information that flows
/// through service operations. Provides tracking, auditing, and correlation
/// capabilities for service layer operations.
/// 
/// Structure:
/// Contains user identity, session information, request timing, and distributed
/// tracing identifiers. Supports additional metadata via dynamic object.
/// 
/// Example:
/// <example>
/// Set context = ##class(ServiceContext).%New()
/// Set context.UserId = "user123"
/// Set context.SessionId = "session-abc"
/// </example>
Class Patterns.PoEAA.DomainLogic.ServiceContext Extends %RegisteredObject
{

/// User ID executing the operation
Property UserId As %String;

/// Session ID for tracking
Property SessionId As %String;

/// Request timestamp
Property RequestTimestamp As %String;

/// Trace ID for distributed tracing
Property TraceId As %String;

/// Additional metadata
Property Metadata As %DynamicObject;

/// Constructor - Initialize context
Method %OnNew() As %Status
{
    Set ..RequestTimestamp = $ZDATETIME($HOROLOG, 3)
    Set ..TraceId = $SYSTEM.Util.CreateGUID()
    Set ..Metadata = {}
    Set ..UserId = ""
    Set ..SessionId = ""
    
    Quit $$$OK
}

/// Set metadata value
/// 
/// @param pKey Metadata key
/// @param pValue Metadata value
Method SetMetadata(pKey As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Do ..Metadata.%Set(pKey, pValue)
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get metadata value
/// 
/// @param pKey Metadata key
/// @return Metadata value or empty string
Method GetMetadata(pKey As %String) As %String
{
    Set result = ""
    
    Try {
        Set result = ..Metadata.%Get(pKey)
        If result = "" Set result = ""
    } Catch ex {
        Set result = ""
    }
    
    Quit result
}

}
