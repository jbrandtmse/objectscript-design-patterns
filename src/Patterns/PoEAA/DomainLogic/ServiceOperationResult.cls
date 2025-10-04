/// Service Operation Result - Consistent response object
/// 
/// Intent:
/// Provide a consistent, uniform response structure for all service layer
/// operations. Encapsulates success/failure status, messages, data, and
/// error details in a standardized format.
/// 
/// Structure:
/// Contains success flag, message, data payload, timestamp, and error details.
/// Enables consistent error handling and response processing across all
/// service operations.
/// 
/// Example:
/// <example>
/// Set result = ##class(ServiceOperationResult).%New()
/// Set result.Success = 1
/// Set result.Message = "Patient admitted successfully"
/// Set result.Data = patientId
/// </example>
Class Patterns.PoEAA.DomainLogic.ServiceOperationResult Extends %RegisteredObject
{

/// Success flag
Property Success As %Boolean;

/// Result message
Property Message As %String;

/// Result data (can be object, JSON, or simple value)
Property Data As %String;

/// Operation timestamp
Property Timestamp As %String;

/// Error details if operation failed
Property ErrorDetails As %String;

/// Status code for categorizing results
Property StatusCode As %String;

/// Constructor
Method %OnNew() As %Status
{
    Set ..Success = 0
    Set ..Message = ""
    Set ..Data = ""
    Set ..Timestamp = $ZDATETIME($HOROLOG, 3)
    Set ..ErrorDetails = ""
    Set ..StatusCode = ""
    
    Quit $$$OK
}

/// Set success result
/// 
/// @param pMessage Success message
/// @param pData Optional data payload
Method SetSuccess(pMessage As %String, pData As %String = "") As %Status
{
    Set ..Success = 1
    Set ..Message = pMessage
    Set ..Data = pData
    Set ..StatusCode = "SUCCESS"
    
    Quit $$$OK
}

/// Set failure result
/// 
/// @param pMessage Failure message
/// @param pErrorDetails Optional error details
Method SetFailure(pMessage As %String, pErrorDetails As %String = "") As %Status
{
    Set ..Success = 0
    Set ..Message = pMessage
    Set ..ErrorDetails = pErrorDetails
    Set ..StatusCode = "FAILURE"
    
    Quit $$$OK
}

/// Convert result to JSON
/// 
/// @return JSON representation of result
Method ToJSON() As %DynamicObject
{
    Set json = {
        "success": (..Success),
        "message": (..Message),
        "data": (..Data),
        "timestamp": (..Timestamp),
        "statusCode": (..StatusCode)
    }
    
    If ..ErrorDetails '= "" {
        Do json.%Set("errorDetails", ..ErrorDetails)
    }
    
    Quit json
}

}
