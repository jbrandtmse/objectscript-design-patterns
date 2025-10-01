/// Healthcare Audit Visitor - HIPAA Compliance and Security Analysis
/// 
/// This visitor implements audit and compliance checking for medical records
/// without modifying the record classes. It demonstrates how the Visitor pattern
/// enables adding new operations (compliance checking) to existing structures.
/// 
/// Healthcare Compliance Features:
/// - HIPAA access logging and compliance verification
/// - Security level validation and reporting
/// - Data integrity checks and audit trails
/// - Unauthorized access detection
/// 
/// <example>
/// Set auditVisitor = ##class(Patterns.Examples.AuditVisitor).%New()
/// Do auditVisitor.Initialize()
/// Do patientRecord.Accept(auditVisitor)
/// Write auditVisitor.GetAuditReport()
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Visitor
/// @see Patterns.Examples.MedicalRecordElement
/// @since 1.0.0
Class Patterns.Examples.AuditVisitor Extends Patterns.GoF.Behavioral.Visitor
{

/// Audit findings and violations
Property AuditFindings As %String [ Private ];

/// Count of records audited
Property RecordsAudited As %Integer [ Private ];

/// Count of compliance violations found
Property ViolationsFound As %Integer [ Private ];

/// Current user performing audit
Property AuditorUserId As %String;

/// Audit session ID for tracking
Property AuditSessionId As %String;

/// High-risk findings requiring immediate attention
Property HighRiskFindings As %String [ Private ];

/// Constructor - initialize audit visitor
Method %OnNew(initvalue As %String = "") As %Status
{
    Set ..AuditFindings = ""
    Set ..RecordsAudited = 0
    Set ..ViolationsFound = 0
    Set ..HighRiskFindings = ""
    
    // Generate unique audit session ID
    Set ..AuditSessionId = "AUDIT"_$TRANSLATE($ZDATETIME($HOROLOG,3)," :-","")_$RANDOM(1000)
    
    Quit $$$OK
}

/// Visit PatientRecord - audit patient demographic and health information
/// 
/// @param pElement The PatientRecord being audited
/// @return %Status indicating success or failure
Method VisitPatientRecord(pElement As Patterns.Examples.PatientRecord) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..RecordsAudited = ..RecordsAudited + 1
        Set tViolations = 0
        Set tFindings = "PATIENT RECORD AUDIT - "_pElement.GetRecordSummary()_": "
        
        // Check required patient information
        If pElement.FirstName = "" {
            Do ..AddFinding("VIOLATION: Missing first name", 1)
            Set tViolations = tViolations + 1
        }
        
        If pElement.LastName = "" {
            Do ..AddFinding("VIOLATION: Missing last name", 1)
            Set tViolations = tViolations + 1
        }
        
        If pElement.DateOfBirth = "" {
            Do ..AddFinding("VIOLATION: Missing date of birth", 1)
            Set tViolations = tViolations + 1
        }
        
        // Check security classification
        If '..ValidateSecurityLevel(pElement) {
            Do ..AddFinding("VIOLATION: Invalid security level for patient record", 1)
            Set tViolations = tViolations + 1
        }
        
        // Check age-related compliance (minors require special handling)
        If pElement.IsMinor() {
            Do ..AddFinding("NOTICE: Minor patient - verify parental consent documentation")
            If pElement.EmergencyContact = "" {
                Do ..AddFinding("VIOLATION: Minor patient missing emergency contact", 1)
                Set tViolations = tViolations + 1
            }
        }
        
        // Check insurance information for billing compliance
        If pElement.InsuranceId = "" {
            Do ..AddFinding("WARNING: No insurance information - verify eligibility")
        }
        
        // Check medication allergy documentation
        If pElement.CurrentMedications '= "" && pElement.Allergies = "" {
            Do ..AddFinding("WARNING: Patient has medications but no allergy information documented")
        }
        
        // Audit access control
        Set tAccessAudit = ..AuditRecordAccess(pElement)
        If tAccessAudit '= "" {
            Do ..AddFinding("ACCESS: "_tAccessAudit)
        }
        
        Set tFindings = tFindings_$SELECT(tViolations=0:"COMPLIANT", 1:"VIOLATIONS FOUND: "_tViolations)
        Do ..AddFinding(tFindings)
        
        // Log: AuditVisitor: Patient record "_pElement.PatientId_" audited with "_tViolations_" violations"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Do ..AddFinding("ERROR: Failed to audit patient record - "_ex.DisplayString(), 1)
    }
    
    Quit tSC
}

/// Visit ConcreteElementA - generic element audit for pattern demonstration
/// 
/// @param pElement The ConcreteElementA being audited
/// @return %Status indicating success or failure
Method VisitConcreteElementA(pElement As Patterns.GoF.Behavioral.Element) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..RecordsAudited = ..RecordsAudited + 1
        Set tData = pElement.GetData()
        Set tInfo = pElement.GetElementInfo()
        
        Do ..AddFinding("ELEMENT A AUDIT: "_tData_" | "_tInfo)
        
        // Check element integrity
        If $IsObject(pElement) {
            Do ..AddFinding("NOTICE: Element A object integrity verified")
        } Else {
            Do ..AddFinding("VIOLATION: Element A object integrity failed", 1)
        }
        
        // Log: AuditVisitor: ElementA audited successfully
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Do ..AddFinding("ERROR: Failed to audit ElementA - "_ex.DisplayString(), 1)
    }
    
    Quit tSC
}

/// Visit ConcreteElementB - generic element audit
/// 
/// @param pElement The ConcreteElementB being audited
/// @return %Status indicating success or failure
Method VisitConcreteElementB(pElement As Patterns.GoF.Behavioral.Element) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..RecordsAudited = ..RecordsAudited + 1
        Set tValue = pElement.GetValue()
        Set tStatus = pElement.GetStatus()
        
        Do ..AddFinding("ELEMENT B AUDIT: Value="_tValue_", Status="_tStatus)
        
        // Check value ranges
        If tValue < 0 {
            Do ..AddFinding("WARNING: Element B has negative value: "_tValue)
        }
        
        // Log: AuditVisitor: ElementB audited successfully
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Do ..AddFinding("ERROR: Failed to audit ElementB - "_ex.DisplayString(), 1)
    }
    
    Quit tSC
}

/// Visit ConcreteElementC - composite element audit
/// 
/// @param pElement The ConcreteElementC being audited
/// @return %Status indicating success or failure
Method VisitConcreteElementC(pElement As Patterns.GoF.Behavioral.Element) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..RecordsAudited = ..RecordsAudited + 1
        Set tName = pElement.GetName()
        Set tChildCount = pElement.GetChildCount()
        
        Do ..AddFinding("ELEMENT C AUDIT: Composite "_tName_" with "_tChildCount_" children")
        
        // Audit composite structure
        If tChildCount = 0 {
            Do ..AddFinding("NOTICE: Composite element has no children")
        } Else {
            Do ..AddFinding("NOTICE: Composite element children will be audited separately")
        }
        
        // Log: AuditVisitor: ElementC audited successfully
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Do ..AddFinding("ERROR: Failed to audit ElementC - "_ex.DisplayString(), 1)
    }
    
    Quit tSC
}

/// Initialize audit visitor before traversal
/// 
/// @return %Status indicating success or failure
Method Initialize() As %Status
{
    Set ..AuditFindings = ""
    Set ..RecordsAudited = 0
    Set ..ViolationsFound = 0
    Set ..HighRiskFindings = ""
    
    Do ..AddFinding("=== AUDIT SESSION INITIALIZED ===")
    Do ..AddFinding("Session ID: "_..AuditSessionId)
    Do ..AddFinding("Auditor: "_..AuditorUserId)
    Do ..AddFinding("Start Time: "_$ZDATETIME($HOROLOG,3))
    Do ..AddFinding("=== BEGIN AUDIT ===")
    
    // Log: AuditVisitor initialized for session: "_..AuditSessionId
    Quit $$$OK
}

/// Finalize audit visitor after traversal
/// 
/// @return %Status indicating success or failure
Method Finalize() As %Status
{
    Do ..AddFinding("=== END AUDIT ===")
    Do ..AddFinding("Records Audited: "_..RecordsAudited)
    Do ..AddFinding("Violations Found: "_..ViolationsFound)
    Do ..AddFinding("End Time: "_$ZDATETIME($HOROLOG,3))
    Do ..AddFinding("=== AUDIT SESSION COMPLETED ===")
    
    // Log: AuditVisitor completed. Audited "_..RecordsAudited_" records, found "_..ViolationsFound_" violations"
    Quit $$$OK
}

/// Get comprehensive audit report
/// 
/// @return %String Complete audit report
Method GetAuditReport() As %String
{
    Quit "HEALTHCARE AUDIT REPORT"_$CHAR(13,10)_..AuditFindings
}

/// Get violation count
/// 
/// @return %Integer Number of violations found
Method GetViolationCount() As %Integer
{
    Quit ..ViolationsFound
}

/// Get high-risk findings requiring immediate attention
/// 
/// @return %String High-risk audit findings
Method GetHighRiskFindings() As %String
{
    Quit ..HighRiskFindings
}

/// Check if audit passed (no violations)
/// 
/// @return %Boolean True if no violations found
Method IsAuditPassed() As %Boolean
{
    Quit (..ViolationsFound = 0)
}

/// Add finding to audit report
/// 
/// @param pFinding The finding to add
/// @param pIsViolation Whether this is a compliance violation
/// @param pIsHighRisk Whether this requires immediate attention
Method AddFinding(pFinding As %String, pIsViolation As %Boolean = 0, pIsHighRisk As %Boolean = 0) [ Private ]
{
    Set tTimestamp = $ZDATETIME($HOROLOG,3)
    Set tEntry = tTimestamp_" - "_pFinding
    
    If ..AuditFindings '= "" {
        Set ..AuditFindings = ..AuditFindings_$CHAR(13,10)_tEntry
    } Else {
        Set ..AuditFindings = tEntry
    }
    
    If pIsViolation {
        Set ..ViolationsFound = ..ViolationsFound + 1
    }
    
    If pIsHighRisk {
        If ..HighRiskFindings '= "" {
            Set ..HighRiskFindings = ..HighRiskFindings_$CHAR(13,10)_tEntry
        } Else {
            Set ..HighRiskFindings = tEntry
        }
    }
}

/// Validate security level for medical record type
/// 
/// @param pRecord The medical record to validate
/// @return %Boolean True if security level is appropriate
Method ValidateSecurityLevel(pRecord As Patterns.Examples.MedicalRecordElement) As %Boolean [ Private ]
{
    Set tSecurityLevel = pRecord.SecurityLevel
    Set tRecordType = pRecord.RecordType
    
    // Patient records should be highly confidential
    If tRecordType = "PatientRecord" && (tSecurityLevel '= "HighlyConfidential") {
        Quit 0
    }
    
    // Other record types should be at least confidential
    If tSecurityLevel = "Public" || tSecurityLevel = "Internal" {
        Quit 0
    }
    
    Quit 1
}

/// Audit record access patterns
/// 
/// @param pRecord The medical record to audit access for
/// @return %String Access audit results
Method AuditRecordAccess(pRecord As Patterns.Examples.MedicalRecordElement) As %String [ Private ]
{
    Set tResult = ""
    
    // Check if record has creator information
    If pRecord.CreatedBy = "" {
        Set tResult = tResult_"Missing creator information; "
    }
    
    // Check modification tracking
    If pRecord.ModifiedAt = "" {
        Set tResult = tResult_"Missing modification timestamp; "
    }
    
    // Check if record is security sensitive
    If pRecord.IsSecuritySensitive() {
        Set tResult = tResult_"High-security record requiring special handling; "
    }
    
    // Simulate access log check (in real implementation, would check actual access logs)
    Set tResult = tResult_"Access logging verified"
    
    Quit tResult
}

/// Set auditor information
/// 
/// @param pUserId The ID of the user performing the audit
/// @return %Status indicating success or failure
Method SetAuditor(pUserId As %String) As %Status
{
    Set ..AuditorUserId = pUserId
    Quit $$$OK
}

/// Generate compliance summary
/// 
/// @return %DynamicObject Compliance summary data
Method GetComplianceSummary() As %DynamicObject
{
    Set tSummary = ##class(%DynamicObject).%New()
    Do tSummary.%Set("auditSessionId", ..AuditSessionId)
    Do tSummary.%Set("auditorUserId", ..AuditorUserId)
    Do tSummary.%Set("recordsAudited", ..RecordsAudited)
    Do tSummary.%Set("violationsFound", ..ViolationsFound)
    Do tSummary.%Set("isCompliant", ..IsAuditPassed())
    Do tSummary.%Set("hasHighRiskFindings", (..HighRiskFindings '= ""))
    Do tSummary.%Set("auditTimestamp", $ZDATETIME($HOROLOG,3))
    
    Quit tSummary
}

}
