# Error Handling Strategy

### Error Handling Philosophy

The ObjectScript Design Patterns Library follows a comprehensive error handling approach that balances robustness with clarity. Our strategy emphasizes early detection, clear communication, and graceful recovery while maintaining pattern integrity.

### Error Categories

**1. Pattern Implementation Errors**
- **Configuration Errors** - Invalid pattern parameters or settings
- **State Errors** - Pattern used in invalid state
- **Dependency Errors** - Required patterns or components unavailable
- **Contract Violations** - Preconditions or postconditions not met

**2. System-Level Errors**
- **Resource Errors** - Memory, disk, or connection limits
- **Permission Errors** - Insufficient privileges for operations
- **Environment Errors** - Missing namespaces or configurations
- **Version Errors** - Incompatible IRIS versions

**3. Usage Errors**
- **Type Errors** - Invalid data types passed to patterns
- **Validation Errors** - Business rule violations
- **Sequence Errors** - Operations performed out of order
- **Null Reference Errors** - Attempting to use uninitialized objects

### Error Handling Patterns

**Base Error Class:**
```objectscript
Class Patterns.Errors.PatternException Extends %Exception.AbstractException
{
    Property PatternName As %String;
    Property ErrorCategory As %String;
    Property ErrorContext As %String(MAXLEN = 1000);
    Property Severity As %String(VALUELIST = ",Low,Medium,High,Critical");
    Property RecoveryAction As %String(MAXLEN = 500);
    Property Timestamp As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];
    
    Method %OnNew(pPatternName As %String = "", pCode As %String = "", pMessage As %String = "") As %Status
    {
        Set ..PatternName = pPatternName
        Set ..Code = pCode
        Set ..Name = pMessage
        Return $$$OK
    }
    
    Method LogError() As %Status
    {
        Do ##class(Patterns.Utils.Logger).LogError(..PatternName, ..Name, ..ErrorContext)
        Return $$$OK
    }
}
```

**Standard Error Handling Approach:**
```objectscript
Method ExecutePattern() As %Status
{
    Set sc = $$$OK
    Try {
        // Validate preconditions
        Set sc = ..ValidatePreconditions()
        If $$$ISERR(sc) Throw ##class(Patterns.Errors.ValidationException).%New(..%ClassName(1), "VALIDATION", $System.Status.GetErrorText(sc))
        
        // Execute pattern logic
        Set sc = ..DoExecute()
        
        // Validate postconditions
        Set sc = ..ValidatePostconditions()
        If $$$ISERR(sc) Throw ##class(Patterns.Errors.ContractException).%New(..%ClassName(1), "CONTRACT", "Postcondition failed")
    }
    Catch ex {
        // Log the error
        Do ex.LogError()
        
        // Attempt recovery
        Set sc = ..RecoverFromError(ex)
        
        // Re-throw if recovery failed
        If $$$ISERR(sc) Throw ex
    }
    
    Return sc
}
```

### Error Codes and Messages

**Standard Error Code Format:** `PAT-{Category}-{Number}`

| Error Code | Description | Recovery Action |
|------------|-------------|----------------|
| PAT-CONFIG-001 | Invalid pattern configuration | Check configuration parameters |
| PAT-CONFIG-002 | Missing required parameter | Provide all required parameters |
| PAT-STATE-001 | Pattern not initialized | Call Initialize() method first |
| PAT-STATE-002 | Invalid state transition | Reset pattern to valid state |
| PAT-DEP-001 | Required pattern not found | Register required pattern |
| PAT-DEP-002 | Circular dependency detected | Review pattern dependencies |
| PAT-VAL-001 | Invalid input type | Check parameter types |
| PAT-VAL-002 | Value out of range | Verify input values |
| PAT-SYS-001 | Insufficient memory | Increase memory allocation |
| PAT-SYS-002 | Namespace not found | Create required namespace |

### Error Recovery Strategies

**1. Retry Logic:**
```objectscript
Method ExecuteWithRetry(maxRetries As %Integer = 3) As %Status
{
    Set retryCount = 0
    Set sc = $$$OK
    
    While (retryCount < maxRetries) {
        Try {
            Set sc = ..Execute()
            If $$$ISOK(sc) Quit
        }
        Catch ex {
            Set retryCount = retryCount + 1
            If (retryCount >= maxRetries) {
                Do ##class(Patterns.Utils.Logger).LogError(..%ClassName(1), "Max retries exceeded", ex.Name)
                Throw ex
            }
            Hang 1  // Wait before retry
        }
    }
    
    Return sc
}
```

**2. Fallback Patterns:**
```objectscript
Method ExecuteWithFallback() As %Status
{
    Set sc = $$$OK
    
    Try {
        // Try primary pattern
        Set sc = ..ExecutePrimary()
    }
    Catch ex {
        // Log primary failure
        Do ##class(Patterns.Utils.Logger).LogWarning(..%ClassName(1), "Primary failed, using fallback", ex.Name)
        
        Try {
            // Execute fallback pattern
            Set sc = ..ExecuteFallback()
        }
        Catch fallbackEx {
            Do ##class(Patterns.Utils.Logger).LogError(..%ClassName(1), "Fallback also failed", fallbackEx.Name)
            Throw fallbackEx
        }
    }
    
    Return sc
}
```

**3. Circuit Breaker Pattern:**
```objectscript
Class Patterns.Utils.CircuitBreaker Extends %RegisteredObject
{
    Property State As %String(VALUELIST = ",Closed,Open,HalfOpen") [ InitialExpression = "Closed" ];
    Property FailureCount As %Integer [ InitialExpression = 0 ];
    Property FailureThreshold As %Integer [ InitialExpression = 5 ];
    Property ResetTimeout As %Integer [ InitialExpression = 60 ];
    Property LastFailureTime As %TimeStamp;
    
    Method Execute(pMethod As %String, pArgs...) As %Status
    {
        If (..State = "Open") {
            If (..ShouldAttemptReset()) {
                Set ..State = "HalfOpen"
            } Else {
                Throw ##class(Patterns.Errors.CircuitOpenException).%New()
            }
        }
        
        Try {
            Set sc = $METHOD($THIS, pMethod, pArgs...)
            If (..State = "HalfOpen") Set ..State = "Closed"
            Set ..FailureCount = 0
            Return sc
        }
        Catch ex {
            Set ..FailureCount = ..FailureCount + 1
            Set ..LastFailureTime = $ZDATETIME($HOROLOG,3)
            
            If (..FailureCount >= ..FailureThreshold) {
                Set ..State = "Open"
            }
            
            Throw ex
        }
    }
}
```

### Error Logging and Monitoring

**Logging Levels:**
1. **DEBUG** - Detailed diagnostic information
2. **INFO** - General informational messages
3. **WARNING** - Potentially harmful situations
4. **ERROR** - Error events but application continues
5. **CRITICAL** - Critical problems requiring immediate attention

**Error Tracking Global:**
```
^Patterns.Errors = <total error count>
^Patterns.Errors("ByPattern", <pattern name>) = <count>
^Patterns.Errors("ByCategory", <category>) = <count>
^Patterns.Errors("Recent", <timestamp>) = <error details>
```

### Testing Error Handling

**Error Test Framework:**
```objectscript
Class Patterns.Test.ErrorTesting Extends %UnitTest.TestCase
{
    Method TestErrorCondition(pPattern As %RegisteredObject, pErrorCode As %String) As %Boolean
    {
        Set success = 0
        
        Try {
            // Trigger error condition
            Do pPattern.TriggerError(pErrorCode)
        }
        Catch ex {
            // Verify correct error was thrown
            If (ex.Code = pErrorCode) {
                Set success = 1
            }
        }
        
        Do ..AssertTrue(success, "Expected error " _ pErrorCode _ " was thrown")
        Return success
    }
}
```

### Best Practices

1. **Always use Try-Catch blocks** for operations that might fail
2. **Log errors at appropriate levels** based on severity
3. **Provide meaningful error messages** with context
4. **Include recovery suggestions** in error messages
5. **Never swallow exceptions** without logging
6. **Test error paths** as thoroughly as success paths
7. **Document expected errors** in method comments
8. **Use specific exception types** rather than generic ones
9. **Maintain error statistics** for monitoring
10. **Implement graceful degradation** where possible
