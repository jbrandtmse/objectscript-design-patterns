/// Gang of Four Decorator Pattern - Audit Decorator for Patient Records
/// 
/// <p>Intent:
/// Adds comprehensive audit logging capabilities to patient records,
/// tracking all data access and modifications for compliance and security.</p>
/// 
/// <p>Motivation:
/// Healthcare regulations require detailed audit trails of who accessed
/// patient data, when, and what changes were made. This decorator adds
/// transparent audit logging to any patient record component.</p>
/// 
/// <p>Structure:
/// Extends PatientRecordComponent and wraps another record component,
/// adding audit logging to all operations while maintaining the same interface.</p>
/// 
/// <p>Participants:
/// - Logs all data access operations
/// - Records data modifications with timestamps
/// - Tracks user information (simulated)
/// - Maintains detailed audit trail</p>
/// 
/// @since 1.0.0
/// @see Patterns.Examples.PatientRecordComponent
/// @see Patterns.Examples.BasicPatientRecord
Class Patterns.Examples.AuditDecorator Extends Patterns.Examples.PatientRecordComponent
{

/// The wrapped patient record component
Property Component As Patterns.Examples.PatientRecordComponent;

/// Audit log entries (list of audit records)
Property AuditLog As list Of %String;

/// Current user (simulated)
Property CurrentUser As %String [ InitialExpression = "System" ];

/// Audit level (Basic, Standard, Detailed)
Property AuditLevel As %String [ InitialExpression = "Standard" ];

/// Additional cost for audit operations
Property AdditionalCost As %Numeric [ InitialExpression = 15 ];

/// Track number of audit entries
Property AuditEntryCount As %Integer [ InitialExpression = 0 ];

/// Track number of access violations
Property ViolationCount As %Integer [ InitialExpression = 0 ];

/// Constructor accepting component to wrap
/// 
/// @param pComponent The patient record component to decorate
/// @param pUser Optional user identifier
/// @param pLevel Optional audit level
/// @return %Status indicating success or failure
Method %OnNew(pComponent As Patterns.Examples.PatientRecordComponent, pUser As %String = "", pLevel As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate component
        If '$ISOBJECT(pComponent) {
            Set tSC = $$$ERROR($$$GeneralError, "AuditDecorator requires a component to wrap")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Set ..Component = pComponent
        
        If pUser '= "" {
            Set ..CurrentUser = pUser
        }
        
        If pLevel '= "" {
            Set ..AuditLevel = pLevel
        }
        
        // Adjust cost based on audit level
        If ..AuditLevel = "Detailed" {
            Set ..AdditionalCost = 20
        } ElseIf ..AuditLevel = "Basic" {
            Set ..AdditionalCost = 10
        }
        
        // Log decorator creation
        Do ..AddAuditEntry("CREATE", "AuditDecorator initialized", "")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get patient data with audit logging
/// 
/// @param pDataType Type of data to retrieve
/// @return Patient data with audit notification
Method GetData(pDataType As %String = "All") As %String
{
    // Log data access
    Do ..AddAuditEntry("READ", "Data accessed", "DataType=" _ pDataType)
    
    // Check for potential violations
    If pDataType = "All" && (..CurrentUser '= "System") {
        Do ..CheckAccessViolation("Full record access by " _ ..CurrentUser)
    }
    
    // Get data from wrapped component
    Set tData = ..Component.GetData(pDataType)
    
    // Add audit indicator based on level
    If ..AuditLevel = "Detailed" {
        Set tResult = "[AUDITED-READ:" _ $ZDATETIME($HOROLOG, 3) _ "] " _ tData
    } Else {
        Set tResult = "[AUDITED] " _ tData
    }
    
    Quit tResult
}

/// Save patient data with audit logging
/// 
/// @param pData Data to save
/// @param pDataType Type of data being saved
/// @return %Status indicating success or failure
Method SaveData(pData As %String, pDataType As %String = "General") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Log data modification attempt
        Do ..AddAuditEntry("WRITE", "Data modification attempt", "DataType=" _ pDataType _ ", Size=" _ $LENGTH(pData))
        
        // Store old value for detailed audit
        If ..AuditLevel = "Detailed" {
            Set tOldData = ..Component.GetData(pDataType)
            Do ..AddAuditEntry("WRITE", "Previous value stored", "OldSize=" _ $LENGTH(tOldData))
        }
        
        // Save data through wrapped component
        Set tSC = ..Component.SaveData(pData, pDataType)
        
        If $$$ISOK(tSC) {
            Do ..AddAuditEntry("WRITE", "Data saved successfully", "DataType=" _ pDataType)
        } Else {
            Do ..AddAuditEntry("ERROR", "Data save failed", "DataType=" _ pDataType)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Do ..AddAuditEntry("ERROR", "Exception during save", ex.Name)
    }
    
    Quit tSC
}

/// Get enhanced description
/// 
/// @return Description including audit status
Method GetDescription() As %String
{
    Set tDescription = ..Component.GetDescription()
    Set tDescription = tDescription _ " + Audit(" _ ..AuditLevel _ ")"
    
    If ..AuditEntryCount > 0 {
        Set tDescription = tDescription _ "[" _ ..AuditEntryCount _ " entries]"
    }
    
    Quit tDescription
}

/// Get total cost including audit overhead
/// 
/// @return Total cost value
Method GetCost() As %Numeric
{
    Set tBaseCost = ..Component.GetCost()
    Quit tBaseCost + ..AdditionalCost
}

/// Check HIPAA compliance
/// 
/// <p>Audit logging improves HIPAA compliance.</p>
/// 
/// @return %Boolean indicating compliance
Method IsHIPAACompliant() As %Boolean
{
    // Check base compliance
    Set tBaseCompliant = ..Component.IsHIPAACompliant()
    
    // Audit logging is required for HIPAA, but needs encryption too
    If tBaseCompliant {
        Quit 1
    } Else {
        // Audit alone doesn't make it compliant if base isn't
        Quit tBaseCompliant
    }
}

/// Get security level
/// 
/// @return Security level including audit indicator
Method GetSecurityLevel() As %String
{
    Set tBaseLevel = ..Component.GetSecurityLevel()
    
    // Add audit indicator to the security level
    If tBaseLevel [ "Audited" {
        // Already audited, just return it
        Quit tBaseLevel
    } Else {
        // Add audited prefix to show audit logging is active
        Quit "Audited(" _ tBaseLevel _ ")"
    }
}

/// Check for critical values
/// 
/// @param pThresholds Optional custom thresholds
/// @return %Boolean from wrapped component
Method HasCriticalValues(pThresholds As %String = "") As %Boolean
{
    Set tHasCritical = ..Component.HasCriticalValues(pThresholds)
    
    // Log critical value check
    If tHasCritical {
        Do ..AddAuditEntry("ALERT", "Critical values detected", "Thresholds=" _ pThresholds)
    }
    
    Quit tHasCritical
}

/// Get comprehensive audit trail
/// 
/// @param pStartDate Optional start date
/// @param pEndDate Optional end date
/// @return Enhanced audit trail with all entries
Method GetAuditTrail(pStartDate As %Date = "", pEndDate As %Date = "") As %String
{
    Set tAudit = ..Component.GetAuditTrail(pStartDate, pEndDate)
    
    // Add detailed audit log
    Set tAudit = tAudit _ $CHAR(13,10)
    Set tAudit = tAudit _ "=== Detailed Audit Log ===" _ $CHAR(13,10)
    Set tAudit = tAudit _ "Audit Level: " _ ..AuditLevel _ $CHAR(13,10)
    Set tAudit = tAudit _ "Total Entries: " _ ..AuditEntryCount _ $CHAR(13,10)
    Set tAudit = tAudit _ "Violations: " _ ..ViolationCount _ $CHAR(13,10)
    
    // Add recent audit entries
    Set tAudit = tAudit _ $CHAR(13,10) _ "Recent Entries:" _ $CHAR(13,10)
    Set tMaxEntries = $SELECT(..AuditLevel="Detailed":20, ..AuditLevel="Standard":10, 1:5)
    Set tStart = $SELECT(..AuditLog.Count() > tMaxEntries : ..AuditLog.Count() - tMaxEntries + 1, 1:1)
    
    For i = tStart:1:..AuditLog.Count() {
        Set tEntry = ..AuditLog.GetAt(i)
        Set tAudit = tAudit _ "  " _ tEntry _ $CHAR(13,10)
    }
    
    Quit tAudit
}

/// Add an entry to the audit log
/// 
/// @param pAction Action type (READ, WRITE, DELETE, etc.)
/// @param pDescription Description of the action
/// @param pDetails Additional details
Method AddAuditEntry(pAction As %String, pDescription As %String, pDetails As %String) [ Private ]
{
    Set ..AuditEntryCount = ..AuditEntryCount + 1
    
    // Format audit entry
    Set tTimestamp = $ZDATETIME($HOROLOG, 3, 1, 3)
    Set tEntry = tTimestamp _ " | " _ ..CurrentUser _ " | " _ pAction _ " | " _ pDescription
    
    If pDetails '= "" {
        Set tEntry = tEntry _ " | " _ pDetails
    }
    
    // Add to audit log
    Do ..AuditLog.Insert(tEntry)
    
    // In production, would also write to persistent audit database
}

/// Check for access violations
/// 
/// @param pReason Reason for potential violation
Method CheckAccessViolation(pReason As %String) [ Private ]
{
    If ..AuditLevel = "Detailed" {
        Set ..ViolationCount = ..ViolationCount + 1
        Do ..AddAuditEntry("VIOLATION", "Potential access violation", pReason)
    }
}

/// Display decorator information
Method Display()
{
    Write "=== Audit Decorator ===" , !
    Write "Current User: ", ..CurrentUser, !
    Write "Audit Level: ", ..AuditLevel, !
    Write "Audit Entries: ", ..AuditEntryCount, !
    Write "Violations: ", ..ViolationCount, !
    Write "Additional Cost: $", ..AdditionalCost, !
    Write "Total Cost: $", ..GetCost(), !
    Write "=====================", !
    
    // Display wrapped component
    If $ISOBJECT(..Component) {
        Do ..Component.Display()
    }
}

/// Get audit statistics
/// 
/// @return Statistics string
Method GetStatistics() As %String
{
    Set tStats = "Audit Statistics: "
    Set tStats = tStats _ "Level=" _ ..AuditLevel
    Set tStats = tStats _ ", Entries=" _ ..AuditEntryCount
    Set tStats = tStats _ ", Violations=" _ ..ViolationCount
    
    If ..AuditEntryCount > 0 {
        Set tViolationRate = $FNUMBER(..ViolationCount / ..AuditEntryCount * 100, "", 1)
        Set tStats = tStats _ ", ViolationRate=" _ tViolationRate _ "%"
    }
    
    Quit tStats
}

/// Clear audit log (requires admin privileges)
/// 
/// @param pAuthorization Authorization code
/// @return %Status
Method ClearAuditLog(pAuthorization As %String) As %Status
{
    // In production, would verify authorization
    If pAuthorization '= "ADMIN-CLEAR-AUDIT" {
        Quit $$$ERROR($$$GeneralError, "Unauthorized audit clear attempt")
    }
    
    Do ..AddAuditEntry("ADMIN", "Audit log cleared", "Authorization provided")
    Do ..AuditLog.Clear()
    Set ..AuditEntryCount = 0
    Set ..ViolationCount = 0
    
    Quit $$$OK
}

}
