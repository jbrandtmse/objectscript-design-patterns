/// Gang of Four Proxy Pattern - Protection Proxy Implementation
/// 
/// Intent:
/// Controls access to an object based on access rights.
/// The protection proxy checks permissions before allowing
/// operations on the real subject.
/// 
/// This implementation demonstrates:
/// - Role-based access control
/// - Integration with IRIS security ($USERNAME, $ROLES)
/// - Audit logging for compliance
/// - Operation-level permissions
/// 
/// Structure:
/// <example>
/// // Create protection proxy with access control
/// Set proxy = ##class(Patterns.GoF.Structural.ProtectionProxy).%New()
/// 
/// // Access is checked based on current user's roles
/// Set result = proxy.Request()  // Allowed or denied based on permissions
/// 
/// // Different operations have different permission requirements
/// Set status = proxy.DoOperation("WRITE", data)  // Requires write permission
/// </example>
Class Patterns.GoF.Structural.ProtectionProxy Extends Patterns.GoF.Structural.Proxy
{

/// Property RequiredRole - Role required for basic access
Property RequiredRole As %String [ InitialExpression = "PatternUser" ];

/// Property RequiredResource - IRIS resource to check
Property RequiredResource As %String [ InitialExpression = "%Development" ];

/// Property AllowedRoles - List of roles with access
Property AllowedRoles As list Of %String;

/// Property DeniedUsers - Blacklist of users
Property DeniedUsers As list Of %String;

/// Property OperationPermissions - Map of operations to required roles
Property OperationPermissions As %ArrayOfDataTypes;

/// Property AuditEnabled - Whether to audit access attempts
Property AuditEnabled As %Boolean [ InitialExpression = 1 ];

/// Property LastAccessUser - Track last user who accessed
Property LastAccessUser As %String;

/// Property LastAccessTime - Track last access time
Property LastAccessTime As %TimeStamp;

/// Property AccessCount - Count successful accesses
Property AccessCount As %Integer [ InitialExpression = 0 ];

/// Property DenialCount - Count access denials
Property DenialCount As %Integer [ InitialExpression = 0 ];

/// Constructor - Initialize protection proxy with security settings
Method %OnNew(pRequiredRole As %String = "", pRequiredResource As %String = "") As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Set proxy type
    Set ..ProxyType = "Protection"
    
    // Set required role and resource
    If pRequiredRole '= "" Set ..RequiredRole = pRequiredRole
    If pRequiredResource '= "" Set ..RequiredResource = pRequiredResource
    
    // Initialize allowed roles list
    Do ..AllowedRoles.Insert(..RequiredRole)
    Do ..AllowedRoles.Insert("%All")  // Superuser role
    Do ..AllowedRoles.Insert("%Manager")
    
    // Initialize operation permissions
    Set ..OperationPermissions = ##class(%ArrayOfDataTypes).%New()
    Do ..OperationPermissions.SetAt("PatternUser", "READ")
    Do ..OperationPermissions.SetAt("PatternAdmin", "WRITE")
    Do ..OperationPermissions.SetAt("PatternAdmin", "DELETE")
    Do ..OperationPermissions.SetAt("PatternUser", "COMPUTE")
    
    // Log protection proxy creation
    Do ..LogAccess("ProtectionProxy created with role requirement: " _ ..RequiredRole)
    
    Quit tSC
}

/// Override CheckAccess - Check user permissions
/// Integrates with IRIS security to verify access rights
/// 
/// @return True if access is granted, False otherwise
Method CheckAccess() As %Boolean
{
    Set tAllowed = 0
    
    // Get current user and roles
    Set tUsername = $USERNAME
    Set tRoles = $ROLES
    
    // Check if user is blacklisted
    For i = 1:1:..DeniedUsers.Count() {
        If ..DeniedUsers.GetAt(i) = tUsername {
            Do ..LogSecurityEvent("ACCESS_DENIED", "User blacklisted: " _ tUsername)
            Set ..DenialCount = ..DenialCount + 1
            Quit
        }
    }
    
    // Check if user has required role
    If '..HasRequiredRole(tUsername, tRoles) {
        Do ..LogSecurityEvent("ACCESS_DENIED", "Missing role: " _ ..RequiredRole _ " for user: " _ tUsername)
        Set ..DenialCount = ..DenialCount + 1
        Quit tAllowed
    }
    
    // Check IRIS resource permission if specified
    If ..RequiredResource '= "" {
        If '..CheckResourcePermission(..RequiredResource) {
            Do ..LogSecurityEvent("ACCESS_DENIED", "Resource permission denied: " _ ..RequiredResource)
            Set ..DenialCount = ..DenialCount + 1
            Quit tAllowed
        }
    }
    
    // Access granted
    Set tAllowed = 1
    Set ..LastAccessUser = tUsername
    Set ..LastAccessTime = $ZDateTime($Horolog, 3)
    Set ..AccessCount = ..AccessCount + 1
    
    Do ..LogSecurityEvent("ACCESS_GRANTED", "User: " _ tUsername _ " with roles: " _ tRoles)
    
    Quit tAllowed
}

/// Check if user has required role
/// 
/// @param pUsername The username to check
/// @param pRoles Comma-separated list of user's roles
/// @return True if user has required role
Method HasRequiredRole(pUsername As %String, pRoles As %String) As %Boolean [ Private ]
{
    Set tHasRole = 0
    
    // Check if any of user's roles match allowed roles
    For i = 1:1:..AllowedRoles.Count() {
        Set tAllowedRole = ..AllowedRoles.GetAt(i)
        If $Find("," _ pRoles _ ",", "," _ tAllowedRole _ ",") {
            Set tHasRole = 1
            Quit
        }
    }
    
    // Check specific required role if not already found
    If 'tHasRole {
        If $Find("," _ pRoles _ ",", "," _ ..RequiredRole _ ",") {
            Set tHasRole = 1
        }
    }
    
    Quit tHasRole
}

/// Check IRIS resource permission
/// 
/// @param pResource The resource to check
/// @return True if user has permission
Method CheckResourcePermission(pResource As %String) As %Boolean [ Private ]
{
    // Check if user has permission for the resource
    // Note: $SYSTEM.Security.Check() would be used in real implementation
    // but we simulate it here for demonstration
    
    Set tHasPermission = 1  // Default to true for demo
    
    // In real implementation:
    // Set tHasPermission = $SYSTEM.Security.Check(pResource, "USE")
    
    // For demo, check based on username
    If $USERNAME = "UnknownUser" || ($USERNAME = "_SYSTEM") {
        Set tHasPermission = 0
    }
    
    Quit tHasPermission
}

/// Override CheckOperationAccess for fine-grained control
/// Different operations require different permissions
/// 
/// @param pOperation The operation to check
/// @return True if operation is allowed
Method CheckOperationAccess(pOperation As %String) As %Boolean
{
    // First check general access
    If '..CheckAccess() {
        Quit 0
    }
    
    // Then check operation-specific permission
    Set tRequiredRole = ..OperationPermissions.GetAt(pOperation)
    If tRequiredRole = "" {
        // No specific requirement, use default
        Quit 1
    }
    
    // Check if user has the required role for this operation
    If '$Find("," _ $ROLES _ ",", "," _ tRequiredRole _ ",") {
        Do ..LogSecurityEvent("OPERATION_DENIED", 
            "Operation '" _ pOperation _ "' requires role: " _ tRequiredRole)
        Quit 0
    }
    
    Do ..LogSecurityEvent("OPERATION_GRANTED", 
        "Operation '" _ pOperation _ "' allowed for user: " _ $USERNAME)
    
    Quit 1
}

/// Log security event for audit trail
/// 
/// @param pEventType Type of security event
/// @param pDetails Event details
Method LogSecurityEvent(pEventType As %String, pDetails As %String) [ Private ]
{
    If '..AuditEnabled Quit
    
    Set tAuditEntry = $ZDateTime($Horolog, 3) _ " | " _ 
                     pEventType _ " | " _ 
                     $USERNAME _ " | " _ 
                     pDetails
    
    // Add to proxy's access log
    Do ..LogAccess(tAuditEntry)
    
    // In real implementation, would also log to system audit
    // Do $SYSTEM.Security.Audit("ProtectionProxy", pEventType, pDetails)
    
    // Store in global for demonstration
    Set ^Patterns.ProxyAudit($Increment(^Patterns.ProxyAudit)) = tAuditEntry
}

/// Add user to blacklist
/// 
/// @param pUsername Username to blacklist
Method AddToBlacklist(pUsername As %String)
{
    If pUsername = "" Quit
    
    // Check if already blacklisted
    For i = 1:1:..DeniedUsers.Count() {
        If ..DeniedUsers.GetAt(i) = pUsername Quit
    }
    
    Do ..DeniedUsers.Insert(pUsername)
    Do ..LogSecurityEvent("BLACKLIST_ADD", "User added to blacklist: " _ pUsername)
}

/// Remove user from blacklist
/// 
/// @param pUsername Username to remove from blacklist
Method RemoveFromBlacklist(pUsername As %String)
{
    For i = 1:1:..DeniedUsers.Count() {
        If ..DeniedUsers.GetAt(i) = pUsername {
            Do ..DeniedUsers.RemoveAt(i)
            Do ..LogSecurityEvent("BLACKLIST_REMOVE", "User removed from blacklist: " _ pUsername)
            Quit
        }
    }
}

/// Add allowed role
/// 
/// @param pRole Role to allow access
Method AddAllowedRole(pRole As %String)
{
    Do ..AllowedRoles.Insert(pRole)
    Do ..LogSecurityEvent("ROLE_ADDED", "Role added to allowed list: " _ pRole)
}

/// Set operation permission
/// 
/// @param pOperation Operation name
/// @param pRequiredRole Role required for the operation
Method SetOperationPermission(pOperation As %String, pRequiredRole As %String)
{
    Do ..OperationPermissions.SetAt(pRequiredRole, pOperation)
    Do ..LogSecurityEvent("PERMISSION_SET", 
        "Operation '" _ pOperation _ "' now requires role: " _ pRequiredRole)
}

/// Get security statistics
/// 
/// @return Statistics as dynamic object
Method GetSecurityStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Set tStats.proxyType = "Protection"
    Set tStats.currentUser = $USERNAME
    Set tStats.currentRoles = $ROLES
    Set tStats.requiredRole = ..RequiredRole
    Set tStats.requiredResource = ..RequiredResource
    Set tStats.accessCount = ..AccessCount
    Set tStats.denialCount = ..DenialCount
    Set tStats.lastAccessUser = ..LastAccessUser
    Set tStats.lastAccessTime = ..LastAccessTime
    Set tStats.blacklistedUsers = ..DeniedUsers.Count()
    Set tStats.allowedRoles = ..AllowedRoles.Count()
    Set tStats.auditEnabled = ..AuditEnabled
    Set tStats.auditLogEntries = ..AccessLog.Count()
    
    // Calculate access rate
    If (..AccessCount + ..DenialCount) > 0 {
        Set tStats.accessRate = $Normalize(..AccessCount / (..AccessCount + ..DenialCount) * 100, 2) _ "%"
    } Else {
        Set tStats.accessRate = "N/A"
    }
    
    Quit tStats
}

/// Class method to create protection proxy with custom settings
/// 
/// @param pRequiredRole Role required for access
/// @param pRequiredResource IRIS resource to check
/// @return Protection proxy instance
ClassMethod CreateProtectionProxy(pRequiredRole As %String, pRequiredResource As %String = "") As ProtectionProxy
{
    Set tProxy = ..%New(pRequiredRole, pRequiredResource)
    
    // Log creation
    Do tProxy.LogSecurityEvent("PROXY_CREATED", 
        "Protection proxy created with role: " _ pRequiredRole)
    
    Quit tProxy
}

/// Demonstrate protection proxy with different user contexts
/// 
/// @param pShowOutput Whether to display output
/// @return Demonstration results
ClassMethod DemonstrateAccessControl(pShowOutput As %Boolean = 1) As %String
{
    Set tResult = ""
    
    // Create protection proxy
    Set tProxy = ##class(ProtectionProxy).CreateProtectionProxy("PatternAdmin", "%Development")
    
    // Simulate different user access attempts
    Set tResult = tResult _ "Protection Proxy Access Control Demonstration:" _ $Char(13, 10)
    Set tResult = tResult _ $Char(13, 10)
    
    // Note: In real usage, $USERNAME and $ROLES would be set by IRIS security
    // For demonstration, we'll show what would happen with different users
    Set tResult = tResult _ "Current User: " _ $USERNAME _ $Char(13, 10)
    Set tResult = tResult _ "Current Roles: " _ $ROLES _ $Char(13, 10)
    Set tResult = tResult _ $Char(13, 10)
    
    // Test 1: Check current user's access
    Set tResult = tResult _ "Test 1 - Current User Access:" _ $Char(13, 10)
    If tProxy.CheckAccess() {
        Set tResult = tResult _ "  ✓ Access GRANTED for " _ $USERNAME _ $Char(13, 10)
    } Else {
        Set tResult = tResult _ "  ✗ Access DENIED for " _ $USERNAME _ $Char(13, 10)
    }
    
    // Test 2: Add current user to blacklist and test
    Set tResult = tResult _ $Char(13, 10) _ "Test 2 - Blacklist Test:" _ $Char(13, 10)
    Do tProxy.AddToBlacklist($USERNAME)
    If tProxy.CheckAccess() {
        Set tResult = tResult _ "  ✓ Access GRANTED for blacklisted user" _ $Char(13, 10)
    } Else {
        Set tResult = tResult _ "  ✗ Access DENIED for blacklisted user" _ $Char(13, 10)
    }
    
    // Remove from blacklist
    Do tProxy.RemoveFromBlacklist($USERNAME)
    
    // Test 3: Operation-specific permissions
    Set tResult = tResult _ $Char(13, 10) _ "Test 3 - Operation Permissions:" _ $Char(13, 10)
    Set tOperations = $ListBuild("READ", "WRITE", "DELETE", "COMPUTE")
    For i = 1:1:$ListLength(tOperations) {
        Set tOp = $ListGet(tOperations, i)
        If tProxy.CheckOperationAccess(tOp) {
            Set tResult = tResult _ "  ✓ Operation " _ tOp _ " allowed" _ $Char(13, 10)
        } Else {
            Set tResult = tResult _ "  ✗ Operation " _ tOp _ " denied" _ $Char(13, 10)
        }
    }
    
    // Get statistics
    Set tStats = tProxy.GetSecurityStatistics()
    Set tResult = tResult _ $Char(13, 10) _ "Statistics:" _ $Char(13, 10)
    Set tResult = tResult _ "  - Access attempts: " _ (tStats.accessCount + tStats.denialCount) _ $Char(13, 10)
    Set tResult = tResult _ "  - Successful: " _ tStats.accessCount _ $Char(13, 10)
    Set tResult = tResult _ "  - Denied: " _ tStats.denialCount _ $Char(13, 10)
    Set tResult = tResult _ "  - Access rate: " _ tStats.accessRate _ $Char(13, 10)
    Set tResult = tResult _ "  - Audit log entries: " _ tStats.auditLogEntries _ $Char(13, 10)
    
    If pShowOutput {
        Write tResult
    }
    
    // Clean up
    Do tProxy.%Close()
    
    Quit tResult
}

}
