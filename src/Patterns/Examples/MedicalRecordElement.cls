/// Healthcare Medical Record Element - Abstract Base for Visitor Pattern Example
/// 
/// This abstract class represents the base for all medical record elements
/// in a healthcare system. It demonstrates how the Visitor pattern can be
/// used to add new analysis operations to medical records without modifying
/// the record classes themselves.
/// 
/// Healthcare Use Cases:
/// - Audit compliance checking (HIPAA, regulatory requirements)
/// - Billing analysis and charge capture
/// - Statistical analysis for population health
/// - Export to various formats (HL7, FHIR, CDA)
/// 
/// <example>
/// Set patientRecord = ##class(Patterns.Examples.PatientRecord).%New()
/// Set auditVisitor = ##class(Patterns.Examples.AuditVisitor).%New()
/// Do patientRecord.Accept(auditVisitor)
/// Write auditVisitor.GetAuditReport()
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Element
/// @see Patterns.Examples.AuditVisitor
/// @since 1.0.0
Class Patterns.Examples.MedicalRecordElement Extends Patterns.GoF.Behavioral.Element
{

/// Medical Record ID - unique identifier
Property RecordId As %String;

/// Patient ID associated with this record
Property PatientId As %String;

/// Creation timestamp
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

/// Last modification timestamp
Property ModifiedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

/// Record type for categorization
Property RecordType As %String;

/// Security classification level
Property SecurityLevel As %String [ InitialExpression = "Confidential" ];

/// Creator user ID for audit trail
Property CreatedBy As %String;

/// Priority level for processing
Property Priority As %String;

/// Department or unit where record was created
Property Department As %String;

/// Attending provider or physician responsible for the record
Property AttendingProvider As %String;

/// Constructor - initialize medical record element
Method %OnNew(initvalue As %String = "") As %Status
{
    // Generate unique record ID if not provided
    If ..RecordId = "" {
        Set ..RecordId = "MR"_$TRANSLATE($ZDATETIME($HOROLOG,3)," :-","")_$RANDOM(1000)
    }
    
    Quit $$$OK
}

/// Initialize medical record element - for Factory Method compatibility
/// @return %Status indicating success or failure
Method Initialize() As %Status
{
    // Default initialization - can be overridden by subclasses
    If ..RecordType = "" Set ..RecordType = "MedicalRecord"
    If ..SecurityLevel = "" Set ..SecurityLevel = "Confidential"
    If ..Priority = "" Set ..Priority = "Normal"
    
    // Initialize RecordId if not set
    If ..RecordId = "" {
        Set ..RecordId = "MR"_$TRANSLATE($ZDATETIME($HOROLOG,3)," :-","")_$RANDOM(1000)
    }
    
    Quit $$$OK
}

/// Abstract Accept method - must be implemented by concrete medical records
/// Each concrete medical record type will call the appropriate visitor method
/// 
/// @param pVisitor The medical record visitor to accept
/// @return %Status indicating success or failure
Method Accept(pVisitor As Patterns.GoF.Behavioral.Visitor) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Get medical record summary information
/// Returns basic information about the medical record
/// 
/// @return %String Summary information
Method GetRecordSummary() As %String
{
    Quit "Record ID: "_..RecordId_", Type: "_..RecordType_", Patient: "_..PatientId_", Created: "_..CreatedAt
}

/// Check if record requires special security handling
/// 
/// @return %Boolean True if record has sensitive information
Method IsSecuritySensitive() As %Boolean
{
    Quit (..SecurityLevel = "Restricted") || (..SecurityLevel = "HighlyConfidential")
}

/// Update modification timestamp
/// Called when record is modified
/// 
/// @return %Status indicating success or failure
Method Touch() As %Status
{
    Set ..ModifiedAt = $ZDATETIME($HOROLOG,3)
    Quit $$$OK
}

/// Validate medical record data
/// Basic validation for all medical records
/// 
/// @return %Status indicating validation result
Method ValidateRecord() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check required fields
        If ..RecordId = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Record ID is required")
            Quit
        }
        
        If ..PatientId = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Patient ID is required")
            Quit
        }
        
        If ..RecordType = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Record type is required")
            Quit
        }
        
        // Check security level
        If '..IsValidSecurityLevel(..SecurityLevel) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid security level: "_..SecurityLevel)
            Quit
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check if security level is valid
/// 
/// @param pLevel The security level to validate
/// @return %Boolean True if valid security level
Method IsValidSecurityLevel(pLevel As %String) As %Boolean
{
    Set tValidLevels = "Public,Internal,Confidential,Restricted,HighlyConfidential"
    Quit $LISTFIND($LISTFROMSTRING(tValidLevels), pLevel) > 0
}

/// Get audit information
/// Returns information needed for audit trails
/// 
/// @return %DynamicObject Audit information
Method GetAuditInfo() As %DynamicObject
{
    Set tAudit = ##class(%DynamicObject).%New()
    Do tAudit.%Set("recordId", ..RecordId)
    Do tAudit.%Set("patientId", ..PatientId)
    Do tAudit.%Set("recordType", ..RecordType)
    Do tAudit.%Set("securityLevel", ..SecurityLevel)
    Do tAudit.%Set("createdAt", ..CreatedAt)
    Do tAudit.%Set("modifiedAt", ..ModifiedAt)
    Do tAudit.%Set("createdBy", ..CreatedBy)
    
    Quit tAudit
}

/// Check if record can be accessed by user
/// Basic access control - can be overridden by specific record types
/// 
/// @param pUserId User ID requesting access
/// @param pAccessType Type of access (read, write, delete)
/// @return %Boolean True if access is allowed
Method CanAccess(pUserId As %String, pAccessType As %String = "read") As %Boolean
{
    // Basic implementation - can be enhanced with role-based access
    If pUserId = "" Quit 0
    If pAccessType = "" Set pAccessType = "read"
    
    // Creator always has access
    If ..CreatedBy = pUserId Quit 1
    
    // Check security level restrictions
    If ..SecurityLevel = "HighlyConfidential" Quit 0
    If ..SecurityLevel = "Restricted" && (pAccessType '= "read") Quit 0
    
    Quit 1
}

/// Get record metadata
/// Returns metadata about the record for analysis
/// 
/// @return %DynamicObject Record metadata
Method GetMetadata() As %DynamicObject
{
    Set tMetadata = ##class(%DynamicObject).%New()
    Do tMetadata.%Set("className", $this.%ClassName(1))
    Do tMetadata.%Set("recordId", ..RecordId)
    Do tMetadata.%Set("recordType", ..RecordType)
    Do tMetadata.%Set("hasChildren", ..HasChildren())
    Do tMetadata.%Set("isSecuritySensitive", ..IsSecuritySensitive())
    Do tMetadata.%Set("dataSize", $LENGTH(..GetData()))
    
    Quit tMetadata
}

/// Clone medical record element
/// Creates a copy of the medical record with new ID
/// 
/// @return Element A clone of this medical record
Method Clone() As Patterns.GoF.Behavioral.Element
{
    // This is abstract - concrete classes will implement specific cloning
    Quit $$$NULLOREF
}

}
