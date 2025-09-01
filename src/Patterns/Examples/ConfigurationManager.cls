/// Healthcare Configuration Manager - Singleton Pattern Example
/// 
/// <p><b>Purpose:</b><br/>
/// Demonstrates a practical implementation of the Singleton pattern for managing
/// healthcare system configuration settings. This class ensures that all parts of
/// the healthcare system access the same configuration instance, preventing
/// inconsistencies and providing a centralized point for configuration management.</p>
/// 
/// <p><b>Use Case:</b><br/>
/// In healthcare integration systems, configuration must be consistent across all
/// components (HL7 interfaces, FHIR endpoints, security settings). Having multiple
/// configuration instances could lead to data inconsistencies, security breaches,
/// or communication failures. The Singleton pattern ensures all components share
/// the same configuration state.</p>
/// 
/// <p><b>Features:</b><br/>
/// <ul>
/// <li>Thread-safe singleton instance management</li>
/// <li>Healthcare-specific configuration properties (HL7, FHIR, security)</li>
/// <li>Persistent configuration storage in IRIS globals</li>
/// <li>Configuration validation and error handling</li>
/// <li>Audit trail for configuration changes</li>
/// </ul></p>
/// 
/// <p><b>Example Usage:</b></p>
/// <example>
/// // Get the configuration manager instance
/// Set configMgr = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
/// 
/// // Enable HL7 interface
/// Do configMgr.SetSetting("HL7Enabled", 1)
/// 
/// // Configure FHIR endpoint
/// Do configMgr.SetSetting("FHIREndpoint", "https://fhir.hospital.org/api")
/// 
/// // Set maximum connections
/// Do configMgr.SetSetting("MaxConnections", 100)
/// 
/// // Save configuration to persistent storage
/// Set status = configMgr.SaveConfiguration()
/// 
/// // Load configuration from persistent storage
/// Set status = configMgr.LoadConfiguration()
/// 
/// // Get a specific setting
/// Set hl7Enabled = configMgr.GetSetting("HL7Enabled")
/// </example>
/// 
/// @see Patterns.GoF.Creational.Singleton
/// @since 1.0.0
/// @author ObjectScript Design Patterns Library
Class Patterns.Examples.ConfigurationManager Extends Patterns.GoF.Creational.Singleton
{

// ===== PARAMETERS =====

/// Configuration global name for persistence
Parameter CONFIGGLOBAL = "^Patterns.Examples.Config";

/// Maximum number of configuration history entries to maintain
Parameter MAXHISTORY = 100;

// ===== PROPERTIES =====

/// Indicates if HL7 interface is enabled
Property HL7Enabled As %Boolean [ InitialExpression = 0 ];

/// FHIR server endpoint URL
Property FHIREndpoint As %String(MAXLEN = 500);

/// Maximum number of concurrent connections allowed
Property MaxConnections As %Integer [ InitialExpression = 10 ];

/// Patient data encryption enabled flag
Property EncryptionEnabled As %Boolean [ InitialExpression = 1 ];

/// Audit logging level (0=None, 1=Errors, 2=Warnings, 3=Info, 4=Debug)
Property AuditLevel As %Integer [ InitialExpression = 2 ];

/// Default timeout for external service calls (in seconds)
Property ServiceTimeout As %Integer [ InitialExpression = 30 ];

/// Organization identifier for multi-tenant systems
Property OrganizationId As %String(MAXLEN = 100);

/// Configuration last modified timestamp
Property LastModified As %TimeStamp;

/// Configuration last modified by user
Property LastModifiedBy As %String(MAXLEN = 100);

/// Internal settings storage for dynamic configuration
Property Settings As %String [ MultiDimensional ];

// ===== CONSTRUCTORS/DESTRUCTORS =====

/// Private constructor - extends parent Singleton constructor
/// Initializes healthcare-specific configuration settings
/// 
/// @param initvalue Initial value passed from parent
/// @return Status code
Method %OnNew(initvalue As %String = "") As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Call parent constructor
        Set tSC = ##super(initvalue)
        If $$$ISERR(tSC) Quit
        
        // Initialize healthcare-specific defaults
        Set ..HL7Enabled = 0
        Set ..FHIREndpoint = ""
        Set ..MaxConnections = 10
        Set ..EncryptionEnabled = 1
        Set ..AuditLevel = 2
        Set ..ServiceTimeout = 30
        Set ..OrganizationId = ""
        Set ..LastModified = $ZDATETIME($HOROLOG, 3)
        Set ..LastModifiedBy = $USERNAME
        
        // Load existing configuration if available
        Do ..LoadConfiguration()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

// ===== CLASS METHODS =====

/// Get the singleton instance of ConfigurationManager
/// Overrides parent GetInstance to return correct type
/// 
/// @return The singleton ConfigurationManager instance
ClassMethod GetInstance() As Patterns.Examples.ConfigurationManager
{
    Set tInstance = ""
    Set tLockName = "^Patterns.Lock(""ConfigurationManager"")"
    Set tGlobalName = "^Patterns.ConfigurationManager"
    Set tTimeout = 5
    
    Try {
        // First check - without lock for performance
        If $DATA(@tGlobalName) {
            Set tOref = @tGlobalName
            If $ISOBJECT(tOref) {
                // Verify it's the correct class type
                If tOref.%IsA("Patterns.Examples.ConfigurationManager") {
                    Set tOref.AccessCount = tOref.AccessCount + 1
                    Return tOref
                }
            }
        }
        
        // Need to create instance - acquire exclusive lock
        Lock +@tLockName:tTimeout
        If '$TEST {
            Set tError = ##class(%Exception.General).%New("ConfigurationManagerLockTimeout")
            Set tError.Name = "ConfigurationManagerLockTimeout"
            Set tError.Code = "Unable to acquire lock for ConfigurationManager creation within " _ tTimeout _ " seconds"
            Throw tError
        }
        
        // Double-check inside lock
        If $DATA(@tGlobalName) {
            Set tOref = @tGlobalName
            If $ISOBJECT(tOref) {
                If tOref.%IsA("Patterns.Examples.ConfigurationManager") {
                    Set tOref.AccessCount = tOref.AccessCount + 1
                    Lock -@tLockName
                    Return tOref
                }
            }
        }
        
        // Create the singleton instance
        Set tInstance = ..%New()
        If $ISOBJECT(tInstance) {
            // Store in global for persistence
            Set @tGlobalName = tInstance
            Set tInstance.AccessCount = 1
        }
        
        // Release the lock
        Lock -@tLockName
        
    } Catch ex {
        // Ensure lock is released
        Lock -@tLockName
        
        // Log the error
        Do ##class(%SYS.System).WriteToConsoleLog("ConfigurationManager.GetInstance() error: " _ ex.Name _ " - " _ ex.Code)
        
        Set tInstance = ""
    }
    
    Return tInstance
}

/// Reset the configuration manager instance (for testing)
/// 
/// @return Status code
ClassMethod Reset() As %Status
{
    Set tSC = $$$OK
    Set tLockName = "^Patterns.Lock(""ConfigurationManager"")"
    Set tGlobalName = "^Patterns.ConfigurationManager"
    Set tTimeout = 5
    
    Try {
        // Acquire exclusive lock
        Lock +@tLockName:tTimeout
        If '$TEST {
            Set tSC = $$$ERROR($$$GeneralError, "Unable to acquire lock for ConfigurationManager reset")
            Return tSC
        }
        
        // Clear the instance
        If $DATA(@tGlobalName) {
            Set tOref = @tGlobalName
            If $ISOBJECT(tOref) {
                Do tOref.%Close()
            }
            Kill @tGlobalName
        }
        
        // Also clear configuration data
        Kill @..#CONFIGGLOBAL
        
        // Release the lock
        Lock -@tLockName
        
    } Catch ex {
        Lock -@tLockName
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

// ===== PUBLIC METHODS =====

/// Load configuration from persistent storage
/// 
/// @return Status code
Method LoadConfiguration() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if configuration exists
        If '$DATA(@..#CONFIGGLOBAL) {
            // No configuration to load, use defaults
            Return tSC
        }
        
        // Load basic properties
        If $DATA(@..#CONFIGGLOBAL@("HL7Enabled")) {
            Set ..HL7Enabled = @..#CONFIGGLOBAL@("HL7Enabled")
        }
        
        If $DATA(@..#CONFIGGLOBAL@("FHIREndpoint")) {
            Set ..FHIREndpoint = @..#CONFIGGLOBAL@("FHIREndpoint")
        }
        
        If $DATA(@..#CONFIGGLOBAL@("MaxConnections")) {
            Set ..MaxConnections = @..#CONFIGGLOBAL@("MaxConnections")
        }
        
        If $DATA(@..#CONFIGGLOBAL@("EncryptionEnabled")) {
            Set ..EncryptionEnabled = @..#CONFIGGLOBAL@("EncryptionEnabled")
        }
        
        If $DATA(@..#CONFIGGLOBAL@("AuditLevel")) {
            Set ..AuditLevel = @..#CONFIGGLOBAL@("AuditLevel")
        }
        
        If $DATA(@..#CONFIGGLOBAL@("ServiceTimeout")) {
            Set ..ServiceTimeout = @..#CONFIGGLOBAL@("ServiceTimeout")
        }
        
        If $DATA(@..#CONFIGGLOBAL@("OrganizationId")) {
            Set ..OrganizationId = @..#CONFIGGLOBAL@("OrganizationId")
        }
        
        // Load dynamic settings
        If $DATA(@..#CONFIGGLOBAL@("Settings")) {
            Merge ..Settings = @..#CONFIGGLOBAL@("Settings")
        }
        
        // Update audit info
        If $DATA(@..#CONFIGGLOBAL@("LastModified")) {
            Set ..LastModified = @..#CONFIGGLOBAL@("LastModified")
        }
        
        If $DATA(@..#CONFIGGLOBAL@("LastModifiedBy")) {
            Set ..LastModifiedBy = @..#CONFIGGLOBAL@("LastModifiedBy")
        }
        
        // Log the load operation
        Do ..AuditLog("Configuration loaded", "INFO")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do ..AuditLog("Configuration load failed: " _ ex.Name, "ERROR")
    }
    
    Return tSC
}

/// Save configuration to persistent storage
/// 
/// @return Status code
Method SaveConfiguration() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Update modification info
        Set ..LastModified = $ZDATETIME($HOROLOG, 3)
        Set ..LastModifiedBy = $USERNAME
        
        // Save to history before updating
        Do ..SaveToHistory()
        
        // Save basic properties
        Set @..#CONFIGGLOBAL@("HL7Enabled") = ..HL7Enabled
        Set @..#CONFIGGLOBAL@("FHIREndpoint") = ..FHIREndpoint
        Set @..#CONFIGGLOBAL@("MaxConnections") = ..MaxConnections
        Set @..#CONFIGGLOBAL@("EncryptionEnabled") = ..EncryptionEnabled
        Set @..#CONFIGGLOBAL@("AuditLevel") = ..AuditLevel
        Set @..#CONFIGGLOBAL@("ServiceTimeout") = ..ServiceTimeout
        Set @..#CONFIGGLOBAL@("OrganizationId") = ..OrganizationId
        
        // Save dynamic settings
        Kill @..#CONFIGGLOBAL@("Settings")
        Merge @..#CONFIGGLOBAL@("Settings") = ..Settings
        
        // Save audit info
        Set @..#CONFIGGLOBAL@("LastModified") = ..LastModified
        Set @..#CONFIGGLOBAL@("LastModifiedBy") = ..LastModifiedBy
        
        // Log the save operation
        Do ..AuditLog("Configuration saved", "INFO")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do ..AuditLog("Configuration save failed: " _ ex.Name, "ERROR")
    }
    
    Return tSC
}

/// Get a configuration setting value
/// 
/// @param pKey The setting key/name
/// @return The setting value or empty string if not found
Method GetSetting(pKey As %String) As %String
{
    Set tValue = ""
    
    Try {
        // Check standard properties first
        If pKey = "HL7Enabled" {
            Set tValue = ..HL7Enabled
        } ElseIf pKey = "FHIREndpoint" {
            Set tValue = ..FHIREndpoint
        } ElseIf pKey = "MaxConnections" {
            Set tValue = ..MaxConnections
        } ElseIf pKey = "EncryptionEnabled" {
            Set tValue = ..EncryptionEnabled
        } ElseIf pKey = "AuditLevel" {
            Set tValue = ..AuditLevel
        } ElseIf pKey = "ServiceTimeout" {
            Set tValue = ..ServiceTimeout
        } ElseIf pKey = "OrganizationId" {
            Set tValue = ..OrganizationId
        } ElseIf $DATA(..Settings(pKey)) {
            // Check dynamic settings
            Set tValue = ..Settings(pKey)
        }
        
    } Catch ex {
        Do ..AuditLog("Error getting setting '" _ pKey _ "': " _ ex.Name, "ERROR")
    }
    
    Return tValue
}

/// Set a configuration setting value
/// 
/// @param pKey The setting key/name
/// @param pValue The value to set
/// @return Status code
Method SetSetting(pKey As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate key
        If pKey = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Setting key cannot be empty")
            Return tSC
        }
        
        // Store old value for audit
        Set tOldValue = ..GetSetting(pKey)
        
        // Set standard properties
        If pKey = "HL7Enabled" {
            Set ..HL7Enabled = pValue
        } ElseIf pKey = "FHIREndpoint" {
            Set ..FHIREndpoint = pValue
        } ElseIf pKey = "MaxConnections" {
            // Validate numeric value
            If +pValue '= pValue {
                Set tSC = $$$ERROR($$$GeneralError, "MaxConnections must be numeric")
                Return tSC
            }
            If pValue < 1 {
                Set tSC = $$$ERROR($$$GeneralError, "MaxConnections must be at least 1")
                Return tSC
            }
            Set ..MaxConnections = pValue
        } ElseIf pKey = "EncryptionEnabled" {
            Set ..EncryptionEnabled = pValue
        } ElseIf pKey = "AuditLevel" {
            // Validate audit level
            If +pValue '= pValue {
                Set tSC = $$$ERROR($$$GeneralError, "AuditLevel must be numeric")
                Return tSC
            }
            If (pValue < 0) || (pValue > 4) {
                Set tSC = $$$ERROR($$$GeneralError, "AuditLevel must be between 0 and 4")
                Return tSC
            }
            Set ..AuditLevel = pValue
        } ElseIf pKey = "ServiceTimeout" {
            // Validate timeout value
            If +pValue '= pValue {
                Set tSC = $$$ERROR($$$GeneralError, "ServiceTimeout must be numeric")
                Return tSC
            }
            If pValue < 1 {
                Set tSC = $$$ERROR($$$GeneralError, "ServiceTimeout must be at least 1 second")
                Return tSC
            }
            Set ..ServiceTimeout = pValue
        } ElseIf pKey = "OrganizationId" {
            Set ..OrganizationId = pValue
        } Else {
            // Store in dynamic settings
            Set ..Settings(pKey) = pValue
        }
        
        // Update modification info
        Set ..LastModified = $ZDATETIME($HOROLOG, 3)
        Set ..LastModifiedBy = $USERNAME
        
        // Log the change
        Do ..AuditLog("Setting changed: " _ pKey _ " from '" _ tOldValue _ "' to '" _ pValue _ "'", "INFO")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do ..AuditLog("Error setting '" _ pKey _ "': " _ ex.Name, "ERROR")
    }
    
    Return tSC
}

/// Validate all configuration settings
/// 
/// @return Status code with validation results
Method ValidateConfiguration() As %Status
{
    Set tSC = $$$OK
    Set tErrors = ""
    
    Try {
        // Validate FHIR endpoint if specified
        If ..FHIREndpoint '= "" {
            If '($EXTRACT(..FHIREndpoint, 1, 7) = "http://") && '($EXTRACT(..FHIREndpoint, 1, 8) = "https://") {
                Set tErrors = tErrors _ "FHIREndpoint must start with http:// or https://; "
            }
        }
        
        // Validate MaxConnections
        If ..MaxConnections < 1 {
            Set tErrors = tErrors _ "MaxConnections must be at least 1; "
        }
        If ..MaxConnections > 1000 {
            Set tErrors = tErrors _ "MaxConnections should not exceed 1000; "
        }
        
        // Validate AuditLevel
        If (..AuditLevel < 0) || (..AuditLevel > 4) {
            Set tErrors = tErrors _ "AuditLevel must be between 0 and 4; "
        }
        
        // Validate ServiceTimeout
        If ..ServiceTimeout < 1 {
            Set tErrors = tErrors _ "ServiceTimeout must be at least 1 second; "
        }
        If ..ServiceTimeout > 300 {
            Set tErrors = tErrors _ "ServiceTimeout should not exceed 300 seconds; "
        }
        
        // Check for required settings when HL7 is enabled
        If ..HL7Enabled {
            If ..MaxConnections < 5 {
                Set tErrors = tErrors _ "MaxConnections should be at least 5 when HL7 is enabled; "
            }
        }
        
        // Check encryption requirements
        If '..EncryptionEnabled && (..AuditLevel < 2) {
            Set tErrors = tErrors _ "AuditLevel should be at least 2 (Warnings) when encryption is disabled; "
        }
        
        // Return error if validation failed
        If tErrors '= "" {
            Set tSC = $$$ERROR($$$GeneralError, "Configuration validation failed: " _ tErrors)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

/// Display current configuration
/// 
/// @return Status code
Method DisplayConfiguration() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "=== Healthcare Configuration Manager ===========", !
        Write "Instance Information:", !
        Write "  Created: ", ..CreationTimestamp, !
        Write "  Access Count: ", ..AccessCount, !
        Write "  Last Modified: ", ..LastModified, !
        Write "  Modified By: ", ..LastModifiedBy, !
        Write !, "Healthcare Settings:", !
        Write "  HL7 Enabled: ", $SELECT(..HL7Enabled:"Yes", 1:"No"), !
        Write "  FHIR Endpoint: ", $SELECT(..FHIREndpoint'="":..FHIREndpoint, 1:"<not configured>"), !
        Write "  Max Connections: ", ..MaxConnections, !
        Write "  Encryption: ", $SELECT(..EncryptionEnabled:"Enabled", 1:"Disabled"), !
        Write "  Audit Level: ", $CASE(..AuditLevel, 0:"None", 1:"Errors", 2:"Warnings", 3:"Info", 4:"Debug"), !
        Write "  Service Timeout: ", ..ServiceTimeout, " seconds", !
        Write "  Organization ID: ", $SELECT(..OrganizationId'="":..OrganizationId, 1:"<not set>"), !
        
        // Display dynamic settings if any
        Set tKey = $ORDER(..Settings(""))
        If tKey '= "" {
            Write !, "Dynamic Settings:", !
            While tKey '= "" {
                Write "  ", tKey, ": ", ..Settings(tKey), !
                Set tKey = $ORDER(..Settings(tKey))
            }
        }
        Write "================================================", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

// ===== PRIVATE METHODS =====

/// Log audit message
/// 
/// @param pMessage The message to log
/// @param pLevel The log level (ERROR, WARNING, INFO, DEBUG)
Method AuditLog(pMessage As %String, pLevel As %String = "INFO") [ Private ]
{
    Set tLevelNum = $CASE(pLevel, "ERROR":1, "WARNING":2, "INFO":3, "DEBUG":4, :3)
    
    // Only log if audit level permits
    If tLevelNum <= ..AuditLevel {
        Set tTimestamp = $ZDATETIME($HOROLOG, 3)
        Set tUser = $USERNAME
        
        // Store in audit log global
        Set tIndex = $INCREMENT(@..#CONFIGGLOBAL@("AuditLog"))
        Set @..#CONFIGGLOBAL@("AuditLog", tIndex) = tTimestamp _ "|" _ tUser _ "|" _ pLevel _ "|" _ pMessage
        
        // Also write to console log for system monitoring
        Do ##class(%SYS.System).WriteToConsoleLog("ConfigMgr [" _ pLevel _ "]: " _ pMessage)
    }
}

/// Save current configuration to history
Method SaveToHistory() [ Private ]
{
    Try {
        Set tTimestamp = $ZDATETIME($HOROLOG, 3)
        Set tIndex = $INCREMENT(@..#CONFIGGLOBAL@("History"))
        
        // Save snapshot
        Set @..#CONFIGGLOBAL@("History", tIndex, "Timestamp") = tTimestamp
        Set @..#CONFIGGLOBAL@("History", tIndex, "User") = $USERNAME
        Set @..#CONFIGGLOBAL@("History", tIndex, "HL7Enabled") = ..HL7Enabled
        Set @..#CONFIGGLOBAL@("History", tIndex, "FHIREndpoint") = ..FHIREndpoint
        Set @..#CONFIGGLOBAL@("History", tIndex, "MaxConnections") = ..MaxConnections
        Set @..#CONFIGGLOBAL@("History", tIndex, "EncryptionEnabled") = ..EncryptionEnabled
        Set @..#CONFIGGLOBAL@("History", tIndex, "AuditLevel") = ..AuditLevel
        Set @..#CONFIGGLOBAL@("History", tIndex, "ServiceTimeout") = ..ServiceTimeout
        Set @..#CONFIGGLOBAL@("History", tIndex, "OrganizationId") = ..OrganizationId
        
        // Cleanup old history if needed
        If tIndex > ..#MAXHISTORY {
            Set tOldest = tIndex - ..#MAXHISTORY
            For i = 1:1:tOldest {
                Kill @..#CONFIGGLOBAL@("History", i)
            }
        }
        
    } Catch ex {
        // Silently fail history save - don't interrupt main operation
    }
}

}
