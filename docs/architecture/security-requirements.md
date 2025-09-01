# Security Requirements

### Security Overview

The ObjectScript Design Patterns Library implements comprehensive security measures to protect code integrity, prevent malicious usage, and ensure safe pattern implementations. While primarily a reference library, security is critical for preventing vulnerabilities in applications that adopt these patterns.

### Security Principles

1. **Defense in Depth** - Multiple layers of security controls
2. **Least Privilege** - Minimal access rights for operations
3. **Secure by Default** - Safe defaults for all configurations
4. **Input Validation** - Never trust external input
5. **Fail Securely** - Errors don't expose sensitive information
6. **Audit Trail** - Log security-relevant events
7. **Code Integrity** - Prevent unauthorized modifications

### Access Control

**Namespace Security:**
```objectscript
/// Pattern access control implementation
Class Patterns.Security.AccessControl Extends %RegisteredObject
{
    /// Check if user has permission to access pattern
    ClassMethod CheckAccess(pPatternClass As %String, pOperation As %String = "READ") As %Boolean
    {
        // Check namespace permissions
        If '$SYSTEM.Security.Check("%DB_PATTERNS", pOperation) {
            Do ##class(Patterns.Utils.Logger).LogWarning("Security", 
                "Access denied to " _ pPatternClass _ " for operation " _ pOperation)
            Return 0
        }
        
        // Check pattern-specific permissions
        If ..RequiresElevatedPrivileges(pPatternClass) {
            If '$SYSTEM.Security.Check("%Admin_Manage", "USE") {
                Return 0
            }
        }
        
        Return 1
    }
    
    /// Patterns requiring elevated privileges
    ClassMethod RequiresElevatedPrivileges(pPatternClass As %String) As %Boolean
    {
        // Patterns that modify system state
        Set elevatedPatterns = $LISTBUILD(
            "Patterns.PoEAA.Session.DatabaseSessionState",
            "Patterns.PoEAA.Offline.PessimisticOfflineLock",
            "Patterns.Utils.Performance"
        )
        
        Return $LISTFIND(elevatedPatterns, pPatternClass) > 0
    }
}
```

### Input Validation

**Validation Framework:**
```objectscript
Class Patterns.Security.InputValidator Extends %RegisteredObject
{
    /// Validate and sanitize input
    ClassMethod ValidateInput(pInput As %String, pType As %String = "TEXT") As %String
    {
        // Remove null bytes
        Set pInput = $TRANSLATE(pInput, $CHAR(0), "")
        
        // Type-specific validation
        Set validated = $CASE(pType,
            "TEXT": ..ValidateText(pInput),
            "SQL": ..ValidateSQL(pInput),
            "JSON": ..ValidateJSON(pInput),
            "CLASSNAME": ..ValidateClassName(pInput),
            : pInput
        )
        
        Return validated
    }
    
    /// Prevent SQL injection
    ClassMethod ValidateSQL(pInput As %String) As %String
    {
        // Escape dangerous characters
        Set dangerous = $LISTBUILD("'", """", ";", "--", "/*", "*/", "xp_", "sp_")
        Set ptr = 0
        
        While $LISTNEXT(dangerous, ptr, char) {
            Set pInput = $REPLACE(pInput, char, "")
        }
        
        Return pInput
    }
    
    /// Validate class names
    ClassMethod ValidateClassName(pInput As %String) As %String
    {
        // Must match pattern namespace convention
        If pInput '[ "^Patterns\." {
            Throw ##class(Patterns.Errors.SecurityException).%New(
                "INVALID_CLASS", "Class name must be in Patterns namespace")
        }
        
        // Check for directory traversal
        If (pInput [ "..") || (pInput [ "./") {
            Throw ##class(Patterns.Errors.SecurityException).%New(
                "PATH_TRAVERSAL", "Invalid class name")
        }
        
        Return pInput
    }
}
```

### Secure Coding Practices

**1. Parameterized Queries:**
```objectscript
// SECURE: Use parameters
&sql(SELECT * FROM Patterns_Registry.PatternInfo 
     WHERE PatternName = :patternName)

// INSECURE: String concatenation
Set sql = "SELECT * FROM Patterns_Registry.PatternInfo WHERE PatternName = '" _ patternName _ "'"
```

**2. Secure Random Number Generation:**
```objectscript
/// Generate cryptographically secure random values
ClassMethod SecureRandom(pLength As %Integer = 32) As %String
{
    Set random = ""
    For i=1:1:pLength {
        Set random = random _ $CHAR($SYSTEM.Encryption.GenCryptRand(1))
    }
    Return $SYSTEM.Encryption.Base64Encode(random)
}
```

**3. Secure Object Creation:**
```objectscript
Method CreateSecureInstance(pClassName As %String) As %RegisteredObject
{
    // Validate class name
    Set pClassName = ##class(Patterns.Security.InputValidator).ValidateClassName(pClassName)
    
    // Check if class exists and is allowed
    If '##class(%Dictionary.ClassDefinition).%ExistsId(pClassName) {
        Throw ##class(Patterns.Errors.SecurityException).%New(
            "CLASS_NOT_FOUND", "Class does not exist")
    }
    
    // Check access permissions
    If '##class(Patterns.Security.AccessControl).CheckAccess(pClassName, "CREATE") {
        Throw ##class(Patterns.Errors.SecurityException).%New(
            "ACCESS_DENIED", "Insufficient privileges")
    }
    
    // Create instance with error handling
    Try {
        Set instance = $CLASSMETHOD(pClassName, "%New")
    } Catch ex {
        Do ##class(Patterns.Utils.Logger).LogError("Security", 
            "Failed to create instance of " _ pClassName, ex.Name)
        Throw ex
    }
    
    Return instance
}
```

### Authentication & Authorization

**Pattern Usage Authorization:**
```objectscript
Class Patterns.Security.Authorization Extends %RegisteredObject
{
    /// Role-based pattern access
    Parameter ROLES = {
        "PatternUser": ["READ"],
        "PatternDeveloper": ["READ", "CREATE", "UPDATE"],
        "PatternAdmin": ["READ", "CREATE", "UPDATE", "DELETE", "ADMIN"]
    }
    
    /// Check if current user can perform operation
    ClassMethod IsAuthorized(pOperation As %String, pResource As %String = "") As %Boolean
    {
        // Get current user's roles
        Set username = $USERNAME
        Set roles = ##class(Security.Users).GetRoles(username)
        
        // Check each role for permission
        Set authorized = 0
        Set ptr = 0
        While $LISTNEXT(roles, ptr, role) {
            If ..RoleHasPermission(role, pOperation) {
                Set authorized = 1
                Quit
            }
        }
        
        // Log authorization attempt
        Do ##class(Patterns.Security.AuditLog).LogAuthAttempt(
            username, pOperation, pResource, authorized)
        
        Return authorized
    }
}
```

### Encryption & Data Protection

**Sensitive Data Handling:**
```objectscript
Class Patterns.Security.Encryption Extends %RegisteredObject
{
    /// Encrypt sensitive pattern configuration
    ClassMethod EncryptConfig(pConfig As %DynamicObject) As %String
    {
        Set json = pConfig.%ToJSON()
        Set key = ..GetEncryptionKey()
        
        Try {
            Set encrypted = $SYSTEM.Encryption.AESCBCEncrypt(json, key)
            Set encoded = $SYSTEM.Encryption.Base64Encode(encrypted)
        } Catch ex {
            Throw ##class(Patterns.Errors.SecurityException).%New(
                "ENCRYPTION_FAILED", "Failed to encrypt configuration")
        }
        
        Return encoded
    }
    
    /// Decrypt pattern configuration
    ClassMethod DecryptConfig(pEncrypted As %String) As %DynamicObject
    {
        Set key = ..GetEncryptionKey()
        
        Try {
            Set decoded = $SYSTEM.Encryption.Base64Decode(pEncrypted)
            Set json = $SYSTEM.Encryption.AESCBCDecrypt(decoded, key)
            Set config = {}.%FromJSON(json)
        } Catch ex {
            Throw ##class(Patterns.Errors.SecurityException).%New(
                "DECRYPTION_FAILED", "Failed to decrypt configuration")
        }
        
        Return config
    }
    
    /// Get encryption key from secure storage
    ClassMethod GetEncryptionKey() As %String [ Private ]
    {
        // In production, retrieve from secure key management system
        // This is a placeholder implementation
        Return $SYSTEM.Encryption.GenCryptToken()
    }
}
```

### Security Audit Logging

**Audit Log Implementation:**
```objectscript
Class Patterns.Security.AuditLog Extends %Persistent
{
    Property EventType As %String(VALUELIST = ",ACCESS,MODIFY,DELETE,ERROR,AUTH,CONFIG");
    Property Username As %String;
    Property Timestamp As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];
    Property Resource As %String(MAXLEN = 500);
    Property Operation As %String;
    Property Success As %Boolean;
    Property IPAddress As %String;
    Property Details As %String(MAXLEN = 2000);
    
    Index TimestampIndex On Timestamp;
    Index UsernameIndex On Username;
    Index EventTypeIndex On EventType;
    
    /// Log security event
    ClassMethod LogEvent(pEventType As %String, pResource As %String, 
                         pOperation As %String, pSuccess As %Boolean, 
                         pDetails As %String = "") As %Status
    {
        Set log = ..%New()
        Set log.EventType = pEventType
        Set log.Username = $USERNAME
        Set log.Resource = pResource
        Set log.Operation = pOperation
        Set log.Success = pSuccess
        Set log.IPAddress = $SYSTEM.Process.ClientIPAddress()
        Set log.Details = pDetails
        
        Return log.%Save()
    }
    
    /// Generate security report
    ClassMethod GenerateSecurityReport(pStartDate As %Date, pEndDate As %Date) As %Stream.GlobalCharacter
    {
        Set report = ##class(%Stream.GlobalCharacter).%New()
        
        &sql(DECLARE SecurityCursor CURSOR FOR
             SELECT EventType, COUNT(*) as EventCount,
                    SUM(CASE WHEN Success = 1 THEN 1 ELSE 0 END) as SuccessCount
             FROM Patterns_Security.AuditLog
             WHERE Timestamp BETWEEN :pStartDate AND :pEndDate
             GROUP BY EventType)
        
        &sql(OPEN SecurityCursor)
        
        Do report.WriteLine("# Security Audit Report")
        Do report.WriteLine("Period: " _ pStartDate _ " to " _ pEndDate)
        Do report.WriteLine("")
        
        &sql(FETCH SecurityCursor INTO :eventType, :eventCount, :successCount)
        While SQLCODE = 0 {
            Do report.WriteLine("## " _ eventType)
            Do report.WriteLine("- Total Events: " _ eventCount)
            Do report.WriteLine("- Successful: " _ successCount)
            Do report.WriteLine("- Failed: " _ (eventCount - successCount))
            Do report.WriteLine("")
            
            &sql(FETCH SecurityCursor INTO :eventType, :eventCount, :successCount)
        }
        
        &sql(CLOSE SecurityCursor)
        
        Return report
    }
}
```

### Vulnerability Prevention

**1. Cross-Site Scripting (XSS) Prevention:**
```objectscript
ClassMethod SanitizeOutput(pText As %String) As %String
{
    Set pText = $REPLACE(pText, "<", "&lt;")
    Set pText = $REPLACE(pText, ">", "&gt;")
    Set pText = $REPLACE(pText, """", "&quot;")
    Set pText = $REPLACE(pText, "'", "&#x27;")
    Set pText = $REPLACE(pText, "/", "&#x2F;")
    Return pText
}
```

**2. Path Traversal Prevention:**
```objectscript
ClassMethod ValidatePath(pPath As %String) As %Boolean
{
    // Check for directory traversal attempts
    If (pPath [ "..") || (pPath [ "./") || (pPath [ "//") {
        Do ##class(Patterns.Security.AuditLog).LogEvent(
            "ERROR", pPath, "PATH_TRAVERSAL", 0, "Attempted path traversal")
        Return 0
    }
    
    // Ensure path is within allowed directories
    Set allowedPaths = $LISTBUILD("/patterns/", "/examples/", "/tests/")
    Set valid = 0
    
    Set ptr = 0
    While $LISTNEXT(allowedPaths, ptr, allowed) {
        If $EXTRACT(pPath, 1, $LENGTH(allowed)) = allowed {
            Set valid = 1
            Quit
        }
    }
    
    Return valid
}
```

### Security Configuration

**Global Security Settings:**
```
^Patterns.Security("MaxLoginAttempts") = 5
^Patterns.Security("SessionTimeout") = 3600  // seconds
^Patterns.Security("PasswordMinLength") = 12
^Patterns.Security("RequireMFA") = 1
^Patterns.Security("AuditLevel") = "FULL"
^Patterns.Security("EncryptionAlgorithm") = "AES256"
```

### Security Testing

**Security Test Suite:**
```objectscript
Class Patterns.Test.SecurityTests Extends %UnitTest.TestCase
{
    Method TestSQLInjection()
    {
        Set maliciousInput = "'; DROP TABLE Patterns_Registry.PatternInfo; --"
        
        Try {
            Set cleaned = ##class(Patterns.Security.InputValidator).ValidateSQL(maliciousInput)
            Do ..AssertNotEquals(cleaned, maliciousInput, "SQL injection attempt should be sanitized")
        } Catch ex {
            Do ..AssertTrue(1, "SQL injection prevented by exception")
        }
    }
    
    Method TestAccessControl()
    {
        // Test unauthorized access
        Set authorized = ##class(Patterns.Security.AccessControl).CheckAccess(
            "Patterns.Admin.SystemConfig", "DELETE")
        
        Do ..AssertFalse(authorized, "Unauthorized user should not have DELETE access")
    }
    
    Method TestEncryption()
    {
        Set original = {"secret": "sensitive data"}
        Set encrypted = ##class(Patterns.Security.Encryption).EncryptConfig(original)
        Set decrypted = ##class(Patterns.Security.Encryption).DecryptConfig(encrypted)
        
        Do ..AssertEquals(original.%ToJSON(), decrypted.%ToJSON(), 
            "Encryption/decryption should preserve data")
        Do ..AssertNotEquals(encrypted, original.%ToJSON(), 
            "Encrypted data should differ from original")
    }
}
```

### Security Compliance

**Compliance Standards:**
1. **OWASP Top 10** - Address common web application vulnerabilities
2. **CWE/SANS Top 25** - Prevent dangerous software errors
3. **GDPR** - Data protection and privacy (if applicable)
4. **HIPAA** - Healthcare data security (for healthcare implementations)
5. **SOC 2** - Security, availability, and confidentiality

### Security Checklist

- [ ] All inputs validated and sanitized
- [ ] Authentication required for sensitive operations
- [ ] Authorization checks implemented
- [ ] Sensitive data encrypted at rest
- [ ] Secure communication channels used
- [ ] Audit logging enabled
- [ ] Error messages don't expose system details
- [ ] Security headers configured
- [ ] Dependencies regularly updated
- [ ] Security testing in CI/CD pipeline
- [ ] Incident response plan documented
- [ ] Regular security audits performed
