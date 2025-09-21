/// Gang of Four Chain of Responsibility Pattern - Error Handler
/// 
/// Intent:
/// Specialized handler for processing errors in the chain.
/// Provides error recovery strategies and circuit breaker functionality.
/// 
/// @see Patterns.GoF.Behavioral.ConcreteHandler
/// @see Patterns.GoF.Behavioral.Request
/// @see Patterns.GoF.Behavioral.Response
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ErrorHandler Extends Patterns.GoF.Behavioral.ConcreteHandler
{

/// Error types this handler can process
Property ErrorTypes As %String(MAXLEN = "");

/// Maximum consecutive errors before circuit opens
Property MaxConsecutiveErrors As %Integer [ InitialExpression = 5 ];

/// Current consecutive error count
Property ConsecutiveErrors As %Integer [ InitialExpression = 0 ];

/// Circuit breaker state (CLOSED, OPEN, HALF_OPEN)
Property CircuitState As %String [ InitialExpression = "CLOSED" ];

/// Time when circuit was opened
Property CircuitOpenedAt As %TimeStamp;

/// Circuit reset timeout in seconds
Property CircuitResetTimeout As %Integer [ InitialExpression = 60 ];

/// Recovery strategy (RETRY, FALLBACK, ESCALATE, LOG)
Property RecoveryStrategy As %String [ InitialExpression = "LOG" ];

/// Number of retry attempts
Property RetryAttempts As %Integer [ InitialExpression = 3 ];

/// Retry delay in seconds
Property RetryDelay As %Integer [ InitialExpression = 1 ];

/// Fallback response for FALLBACK strategy
Property FallbackResponse As %String;

/// Constructor with error types and recovery strategy
/// 
/// @param pErrorTypes Comma-delimited list of error types to handle
/// @param pRecoveryStrategy Recovery strategy to use
/// @return %Status
Method %OnNew(pErrorTypes As %String = "", pRecoveryStrategy As %String = "LOG") As %Status
{
    Set tSC = ##super("ErrorHandler")
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        Set ..ErrorTypes = pErrorTypes
        Set ..RecoveryStrategy = pRecoveryStrategy
        Set ..Priority = 1000  // Low priority - process after other handlers
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check if this handler can process the request
/// 
/// @param pRequest The request to check
/// @return %Boolean
Method CanHandleSpecific(pRequest As Request) As %Boolean
{
    // Check circuit breaker state
    If ..CircuitState = "OPEN" {
        // Check if timeout has elapsed
        If ..ShouldAttemptReset() {
            Set ..CircuitState = "HALF_OPEN"
            Set ..ConsecutiveErrors = 0
        } Else {
            Quit 0  // Circuit is open, don't handle
        }
    }
    
    // Handle if request has error context
    If pRequest.HasContext("error") {
        Set tErrorType = pRequest.GetContext("errorType")
        
        // If no specific error types configured, handle all errors
        If ..ErrorTypes = "" Quit 1
        
        // Check if error type matches
        If tErrorType '= "" {
            Set tTypes = "," _ ..ErrorTypes _ ","
            If tTypes [ ("," _ tErrorType _ ",") Quit 1
        }
        
        Quit 1  // Handle any error if type not specified
    }
    
    // Also handle if request type is "Error"
    Quit (pRequest.Type = "Error")
}

/// Process the error request
/// 
/// @param pRequest The request to process
/// @return Response object
Method ProcessSpecific(pRequest As Request) As Response
{
    Set tResponse = ""
    
    Try {
        // Log the error
        Do ..LogError(pRequest)
        
        // Apply recovery strategy
        If ..RecoveryStrategy = "RETRY" {
            Set tResponse = ..HandleWithRetry(pRequest)
        }
        ElseIf ..RecoveryStrategy = "FALLBACK" {
            Set tResponse = ..HandleWithFallback(pRequest)
        }
        ElseIf ..RecoveryStrategy = "ESCALATE" {
            Set tResponse = ..HandleWithEscalation(pRequest)
        }
        Else {
            Set tResponse = ..HandleWithLogging(pRequest)
        }
        
        // Update circuit breaker state
        If tResponse.IsSuccess() {
            // Success - reset consecutive errors
            Set ..ConsecutiveErrors = 0
            If ..CircuitState = "HALF_OPEN" {
                Set ..CircuitState = "CLOSED"
            }
        } Else {
            // Failure - increment consecutive errors
            Set ..ConsecutiveErrors = ..ConsecutiveErrors + 1
            
            If ..ConsecutiveErrors >= ..MaxConsecutiveErrors {
                // Open the circuit
                Set ..CircuitState = "OPEN"
                Set ..CircuitOpenedAt = $ZDateTime($ZTimeStamp, 3)
                Do tResponse.AddError("Circuit breaker opened due to " _ ..ConsecutiveErrors _ " consecutive errors")
            }
            
            If ..CircuitState = "HALF_OPEN" {
                // Failed in half-open state - reopen circuit
                Set ..CircuitState = "OPEN"
                Set ..CircuitOpenedAt = $ZDateTime($ZTimeStamp, 3)
            }
        }
    }
    Catch ex {
        Set tResponse = ##class(Response).Failure("Error handler failed: " _ ex.Name, 500)
        Do tResponse.AddError(ex.Name _ " at " _ ex.Location)
    }
    
    Quit tResponse
}

/// Handle error with retry strategy
/// 
/// @param pRequest The request to process
/// @return Response object
Method HandleWithRetry(pRequest As Request) As Response [ Private ]
{
    Set tResponse = ""
    Set tOriginalHandler = pRequest.GetContext("originalHandler")
    
    For tAttempt=1:1:..RetryAttempts {
        // Wait before retry (except first attempt)
        If tAttempt > 1 {
            Hang ..RetryDelay
        }
        
        // Clone the request for retry
        Set tRetryRequest = pRequest.Clone()
        Set tRetryRequest.Status = "Retry"
        Do tRetryRequest.SetContext("retryAttempt", tAttempt)
        
        // Try to process with original handler if available
        If tOriginalHandler '= "" {
            Try {
                Set tHandler = $CLASSMETHOD(tOriginalHandler, "%New")
                Set tResponse = tHandler.Process(tRetryRequest)
                
                If tResponse.IsSuccess() {
                    Set tResponse.Message = tResponse.Message _ " (succeeded on retry " _ tAttempt _ ")"
                    Quit  // Success - exit loop
                }
            }
            Catch ex {
                // Continue to next retry
            }
        }
    }
    
    // If all retries failed
    If 'tResponse.IsSuccess() {
        Set tResponse = ##class(Response).Failure("All " _ ..RetryAttempts _ " retry attempts failed", 500)
        Do tResponse.AddError("Retry strategy exhausted")
    }
    
    Quit tResponse
}

/// Handle error with fallback strategy
/// 
/// @param pRequest The request to process
/// @return Response object
Method HandleWithFallback(pRequest As Request) As Response [ Private ]
{
    Set tResponse = ##class(Response).Partial(..FallbackResponse, "Handled with fallback response")
    Do tResponse.SetMetadata("fallback", "true")
    Do tResponse.SetMetadata("originalError", pRequest.GetContext("error"))
    
    Quit tResponse
}

/// Handle error with escalation strategy
/// 
/// @param pRequest The request to process
/// @return Response object
Method HandleWithEscalation(pRequest As Request) As Response [ Private ]
{
    // Create escalation request
    Set tEscalationRequest = ##class(Request).%New("Escalation", pRequest.Data)
    Set tEscalationRequest.Priority = 4  // Critical priority
    Set tEscalationRequest.Initiator = "ErrorHandler"
    Do tEscalationRequest.SetContext("originalRequest", pRequest.RequestId)
    Do tEscalationRequest.SetContext("error", pRequest.GetContext("error"))
    Do tEscalationRequest.SetContext("escalationReason", "Error threshold exceeded")
    
    // Pass to next handler in chain for escalation
    Set tResponse = ""
    If $IsObject(..NextHandler) {
        Set tResponse = ..NextHandler.HandleRequest(tEscalationRequest)
    } Else {
        Set tResponse = ##class(Response).Deferred("Escalated to administrator for manual intervention")
    }
    
    Do tResponse.SetMetadata("escalated", "true")
    
    Quit tResponse
}

/// Handle error with logging strategy
/// 
/// @param pRequest The request to process
/// @return Response object
Method HandleWithLogging(pRequest As Request) As Response [ Private ]
{
    // Log has already been done in LogError method
    Set tResponse = ##class(Response).Success("", "Error logged successfully")
    Do tResponse.SetMetadata("logged", "true")
    Do tResponse.SetMetadata("errorId", $System.Util.CreateGUID())
    
    Quit tResponse
}

/// Log error details
/// 
/// @param pRequest The error request
Method LogError(pRequest As Request) [ Private ]
{
    Set tTimestamp = $ZDateTime($ZTimeStamp, 3)
    Set tError = pRequest.GetContext("error")
    Set tErrorType = pRequest.GetContext("errorType")
    Set tOriginalHandler = pRequest.GetContext("originalHandler")
    
    // Log to global for persistence
    Set tLogId = $INCREMENT(^Patterns.Chain.ErrorLog)
    Set ^Patterns.Chain.ErrorLog(tLogId, "timestamp") = tTimestamp
    Set ^Patterns.Chain.ErrorLog(tLogId, "requestId") = pRequest.RequestId
    Set ^Patterns.Chain.ErrorLog(tLogId, "error") = tError
    Set ^Patterns.Chain.ErrorLog(tLogId, "errorType") = tErrorType
    Set ^Patterns.Chain.ErrorLog(tLogId, "originalHandler") = tOriginalHandler
    Set ^Patterns.Chain.ErrorLog(tLogId, "requestType") = pRequest.Type
    Set ^Patterns.Chain.ErrorLog(tLogId, "requestData") = pRequest.Data
    Set ^Patterns.Chain.ErrorLog(tLogId, "initiator") = pRequest.Initiator
    
    // Also log to system console
    Do ##class(%SYS.System).WriteToConsoleLog("ChainError[" _ tLogId _ "]: " _ tError _ " from " _ tOriginalHandler)
}

/// Check if circuit breaker should attempt reset
/// 
/// @return %Boolean
Method ShouldAttemptReset() As %Boolean [ Private ]
{
    If ..CircuitState '= "OPEN" Quit 0
    
    Set tNow = $ZTimeStamp
    Set tOpenedAt = $ZDateH(..CircuitOpenedAt, 3)
    Set tElapsedSeconds = tNow - tOpenedAt
    
    Quit (tElapsedSeconds >= ..CircuitResetTimeout)
}

/// Get circuit breaker status
/// 
/// @return %String circuit status description
Method GetCircuitStatus() As %String
{
    Set tStatus = "Circuit: " _ ..CircuitState
    
    If ..CircuitState = "OPEN" {
        Set tStatus = tStatus _ " (opened at " _ ..CircuitOpenedAt _ ")"
        
        If ..ShouldAttemptReset() {
            Set tStatus = tStatus _ " [Ready to reset]"
        } Else {
            Set tTimeRemaining = ..CircuitResetTimeout - ($ZTimeStamp - $ZDateH(..CircuitOpenedAt, 3))
            Set tStatus = tStatus _ " [Reset in " _ tTimeRemaining _ " seconds]"
        }
    }
    
    Set tStatus = tStatus _ ", Consecutive Errors: " _ ..ConsecutiveErrors _ "/" _ ..MaxConsecutiveErrors
    
    Quit tStatus
}

/// Reset circuit breaker
Method ResetCircuit()
{
    Set ..CircuitState = "CLOSED"
    Set ..ConsecutiveErrors = 0
    Set ..CircuitOpenedAt = ""
}

/// Configure error handler from JSON
/// 
/// @param pConfig JSON configuration object
Method Configure(pConfig As %DynamicObject)
{
    If pConfig.%IsDefined("errorTypes") Set ..ErrorTypes = pConfig.errorTypes
    If pConfig.%IsDefined("recoveryStrategy") Set ..RecoveryStrategy = pConfig.recoveryStrategy
    If pConfig.%IsDefined("maxConsecutiveErrors") Set ..MaxConsecutiveErrors = pConfig.maxConsecutiveErrors
    If pConfig.%IsDefined("circuitResetTimeout") Set ..CircuitResetTimeout = pConfig.circuitResetTimeout
    If pConfig.%IsDefined("retryAttempts") Set ..RetryAttempts = pConfig.retryAttempts
    If pConfig.%IsDefined("retryDelay") Set ..RetryDelay = pConfig.retryDelay
    If pConfig.%IsDefined("fallbackResponse") Set ..FallbackResponse = pConfig.fallbackResponse
    
    // Apply to base configuration
    Set ..Configuration = pConfig
}

/// Get error statistics
/// 
/// @return %DynamicObject with error stats
ClassMethod GetErrorStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Set tTotalErrors = $GET(^Patterns.Chain.ErrorLog, 0)
    Set tStats.totalErrors = tTotalErrors
    
    // Count by error type
    Set tErrorTypes = {}
    Set tLogId = ""
    For {
        Set tLogId = $ORDER(^Patterns.Chain.ErrorLog(tLogId))
        Quit:tLogId=""
        
        Set tType = $GET(^Patterns.Chain.ErrorLog(tLogId, "errorType"), "Unknown")
        Set tCount = $GET(tErrorTypes.%Get(tType), 0) + 1
        Do tErrorTypes.%Set(tType, tCount)
    }
    Set tStats.byType = tErrorTypes
    
    // Get recent errors
    Set tRecent = []
    Set tLogId = $GET(^Patterns.Chain.ErrorLog, 0)
    Set tStartId = $SELECT(tLogId > 10: tLogId - 10, 1: 1)
    
    For i=tLogId:-1:tStartId {
        If $DATA(^Patterns.Chain.ErrorLog(i)) {
            Set tError = {}
            Set tError.id = i
            Set tError.timestamp = $GET(^Patterns.Chain.ErrorLog(i, "timestamp"))
            Set tError.error = $GET(^Patterns.Chain.ErrorLog(i, "error"))
            Set tError.type = $GET(^Patterns.Chain.ErrorLog(i, "errorType"))
            Do tRecent.%Push(tError)
        }
    }
    Set tStats.recentErrors = tRecent
    
    Quit tStats
}

/// Clear error logs
ClassMethod ClearErrorLogs()
{
    Kill ^Patterns.Chain.ErrorLog
}

}
