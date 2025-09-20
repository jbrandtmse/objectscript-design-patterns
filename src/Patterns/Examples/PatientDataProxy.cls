/// Gang of Four Proxy Pattern - Healthcare Example (Proxy)
/// 
/// Intent:
/// Provides controlled access to patient data based on user roles.
/// This proxy implements both protection (access control) and virtual
/// (lazy loading) proxy patterns for healthcare data management.
/// 
/// This implementation demonstrates:
/// - Role-based access control (Doctor, Nurse, Admin, Billing)
/// - Data masking for sensitive fields
/// - HIPAA-compliant audit logging
/// - Lazy loading of expensive operations
/// - Different access levels for different data types
/// 
/// Structure:
/// <example>
/// // Create proxy with role-based access control
/// Set proxy = ##class(Patterns.Examples.PatientDataProxy).%New("Doctor")
/// 
/// // Access is controlled based on role
/// Set patientData = proxy.GetPatientRecord("PAT001")  // Full access for doctor
/// 
/// // Different roles have different permissions
/// Set billingProxy = ##class(Patterns.Examples.PatientDataProxy).%New("Billing")
/// Set billingData = billingProxy.GetPatientRecord("PAT001")  // Limited data
/// </example>
Class Patterns.Examples.PatientDataProxy Extends %RegisteredObject
{

/// Property RealService - Reference to actual patient data service
Property RealService As PatientDataService [ Private ];

/// Property UserRole - Current user's role
Property UserRole As %String;

/// Property UserName - Current user's name
Property UserName As %String;

/// Property IsServiceLoaded - Flag for lazy loading
Property IsServiceLoaded As %Boolean [ InitialExpression = 0 ];

/// Property AccessLog - Track access attempts
Property AccessLog As list Of %String;

/// Property CachedData - Cache for frequently accessed data
Property CachedData As %ArrayOfDataTypes;

/// Property AccessCount - Count of access attempts
Property AccessCount As %Integer [ InitialExpression = 0 ];

/// Property DeniedCount - Count of denied access attempts
Property DeniedCount As %Integer [ InitialExpression = 0 ];

/// Access control matrix - defines what each role can access
Parameter ACCESSMATRIX = "{""Doctor"":{""fullRecord"":true,""demographics"":true,""medical"":true,""billing"":true,""ssn"":true,""update"":true,""delete"":false,""images"":true,""notes"":true},""Nurse"":{""fullRecord"":false,""demographics"":true,""medical"":true,""billing"":false,""ssn"":false,""update"":true,""delete"":false,""images"":true,""notes"":true},""Admin"":{""fullRecord"":true,""demographics"":true,""medical"":false,""billing"":true,""ssn"":false,""update"":true,""delete"":true,""images"":false,""notes"":false},""Billing"":{""fullRecord"":false,""demographics"":true,""medical"":false,""billing"":true,""ssn"":false,""update"":false,""delete"":false,""images"":false,""notes"":false}}";

/// Constructor - Initialize proxy with user role
Method %OnNew(pUserRole As %String = "", pUserName As %String = "") As %Status
{
    Set tSC = $$$OK
    
    // Set user information
    If pUserRole = "" Set pUserRole = "Guest"
    Set ..UserRole = pUserRole
    
    If pUserName = "" Set pUserName = $USERNAME
    Set ..UserName = pUserName
    
    // Initialize structures
    Set ..AccessLog = ##class(%ListOfDataTypes).%New()
    Set ..CachedData = ##class(%ArrayOfDataTypes).%New()
    
    // Log proxy creation
    Do ..LogAccess("PROXY_CREATED", "Role: " _ ..UserRole _ ", User: " _ ..UserName, "")
    
    Quit tSC
}

/// Load real service (lazy loading)
Method LoadRealService() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    If '..IsServiceLoaded {
        Try {
            // Simulate authentication check
            If ..UserRole = "Guest" {
                Set tSC = $$$ERROR($$$GeneralError, "Guest users cannot access patient data")
                Quit
            }
            
            // Load the real service
            Set ..RealService = ##class(PatientDataService).%New()
            Set ..IsServiceLoaded = 1
            
            Do ..LogAccess("SERVICE_LOADED", "Real service loaded for role: " _ ..UserRole, "")
            
        } Catch ex {
            Set tSC = ex.AsStatus()
            Do ..LogAccess("SERVICE_LOAD_FAILED", ex.DisplayString(), "")
        }
    }
    
    Quit tSC
}

/// Check if role has permission for operation
Method CheckPermission(pOperation As %String) As %Boolean [ Private ]
{
    // Parse access matrix
    Set tMatrix = {}.%FromJSON(..#ACCESSMATRIX)
    
    // Check if role exists
    If 'tMatrix.%IsDefined(..UserRole) {
        Do ..LogAccess("ACCESS_DENIED", "Unknown role: " _ ..UserRole, pOperation)
        Quit 0
    }
    
    // Get role permissions
    Set tRolePerms = tMatrix.%Get(..UserRole)
    
    // Check specific permission
    If 'tRolePerms.%IsDefined(pOperation) {
        Do ..LogAccess("ACCESS_DENIED", "No permission defined for operation: " _ pOperation, "")
        Quit 0
    }
    
    Set tAllowed = tRolePerms.%Get(pOperation)
    
    If 'tAllowed {
        Do ..LogAccess("ACCESS_DENIED", "Role " _ ..UserRole _ " denied for: " _ pOperation, "")
        Set ..DeniedCount = ..DeniedCount + 1
    } Else {
        Do ..LogAccess("ACCESS_GRANTED", "Role " _ ..UserRole _ " allowed for: " _ pOperation, "")
        Set ..AccessCount = ..AccessCount + 1
    }
    
    Quit tAllowed
}

/// Get patient record with role-based filtering
/// 
/// @param pPatientId Patient identifier
/// @return Patient data (filtered based on role)
Method GetPatientRecord(pPatientId As %String) As %DynamicObject
{
    // Check permission
    If '..CheckPermission("fullRecord") {
        // Try to return limited data based on role
        If ..UserRole = "Nurse" {
            Quit ..GetPatientMedicalInfo(pPatientId)
        } ElseIf ..UserRole = "Billing" {
            Quit ..GetPatientBillingInfo(pPatientId)
        } Else {
            Quit ""
        }
    }
    
    // Load service if needed
    Set tSC = ..LoadRealService()
    If $$$ISERR(tSC) Quit ""
    
    // Get full record
    Set tPatient = ..RealService.GetPatientRecord(pPatientId)
    
    // Apply data masking if needed
    If ..UserRole '= "Doctor" {
        Set tPatient = ..MaskSensitiveData(tPatient)
    }
    
    Do ..LogAccess("FULL_RECORD_ACCESS", pPatientId, ..UserName)
    
    Quit tPatient
}

/// Get patient demographics only
/// 
/// @param pPatientId Patient identifier
/// @return Demographics data
Method GetPatientDemographics(pPatientId As %String) As %DynamicObject
{
    If '..CheckPermission("demographics") Quit ""
    
    Set tSC = ..LoadRealService()
    If $$$ISERR(tSC) Quit ""
    
    Set tData = ..RealService.GetPatientDemographics(pPatientId)
    
    Do ..LogAccess("DEMOGRAPHICS_ACCESS", pPatientId, ..UserName)
    
    Quit tData
}

/// Get patient medical information
/// 
/// @param pPatientId Patient identifier
/// @return Medical data
Method GetPatientMedicalInfo(pPatientId As %String) As %DynamicObject
{
    If '..CheckPermission("medical") Quit ""
    
    Set tSC = ..LoadRealService()
    If $$$ISERR(tSC) Quit ""
    
    Set tData = ..RealService.GetPatientMedicalInfo(pPatientId)
    
    Do ..LogAccess("MEDICAL_ACCESS", pPatientId, ..UserName)
    
    Quit tData
}

/// Get patient billing information
/// 
/// @param pPatientId Patient identifier
/// @return Billing data
Method GetPatientBillingInfo(pPatientId As %String) As %DynamicObject
{
    If '..CheckPermission("billing") Quit ""
    
    Set tSC = ..LoadRealService()
    If $$$ISERR(tSC) Quit ""
    
    Set tData = ..RealService.GetPatientBillingInfo(pPatientId)
    
    // Mask SSN for billing department
    If ..UserRole = "Billing" {
        If tData.%IsDefined("ssn") {
            Set tData.ssn = "XXX-XX-" _ $Extract(tData.ssn, $Length(tData.ssn)-3, $Length(tData.ssn))
        }
    }
    
    Do ..LogAccess("BILLING_ACCESS", pPatientId, ..UserName)
    
    Quit tData
}

/// Update patient record
/// 
/// @param pPatientId Patient identifier
/// @param pUpdates Updates to apply
/// @return Status of update
Method UpdatePatientRecord(pPatientId As %String, pUpdates As %DynamicObject) As %Status
{
    If '..CheckPermission("update") {
        Quit $$$ERROR($$$GeneralError, "Permission denied for update operation")
    }
    
    Set tSC = ..LoadRealService()
    If $$$ISERR(tSC) Quit tSC
    
    // Log what fields are being updated
    Set tFieldList = ""
    Set tIterator = pUpdates.%GetIterator()
    While tIterator.%GetNext(.tKey, .tValue) {
        Set tFieldList = tFieldList _ tKey _ ", "
    }
    
    Do ..LogAccess("UPDATE_REQUEST", pPatientId _ " Fields: " _ tFieldList, ..UserName)
    
    Set tSC = ..RealService.UpdatePatientRecord(pPatientId, pUpdates)
    
    Quit tSC
}

/// Delete patient record (admin only)
/// 
/// @param pPatientId Patient identifier
/// @return Status of deletion
Method DeletePatientRecord(pPatientId As %String) As %Status
{
    If '..CheckPermission("delete") {
        Quit $$$ERROR($$$GeneralError, "Only Admin can delete patient records")
    }
    
    Set tSC = ..LoadRealService()
    If $$$ISERR(tSC) Quit tSC
    
    Do ..LogAccess("DELETE_REQUEST", pPatientId, ..UserName)
    
    Set tSC = ..RealService.DeletePatientRecord(pPatientId)
    
    Quit tSC
}

/// Get medical image with lazy loading and caching
/// 
/// @param pImageId Image identifier
/// @return Image data
Method GetMedicalImage(pImageId As %String) As %String
{
    If '..CheckPermission("images") {
        Quit "Access denied to medical images"
    }
    
    // Check cache first (virtual proxy behavior)
    If ..CachedData.IsDefined("IMG_" _ pImageId) {
        Do ..LogAccess("IMAGE_CACHE_HIT", pImageId, ..UserName)
        Quit ..CachedData.GetAt("IMG_" _ pImageId)
    }
    
    Set tSC = ..LoadRealService()
    If $$$ISERR(tSC) Quit "Service unavailable"
    
    // Load image (expensive operation)
    Set tImageData = ..RealService.GetMedicalImage(pImageId)
    
    // Cache for future use
    Do ..CachedData.SetAt(tImageData, "IMG_" _ pImageId)
    
    Do ..LogAccess("IMAGE_ACCESS", pImageId, ..UserName)
    
    Quit tImageData
}

/// Get clinical notes
/// 
/// @param pNoteId Note identifier
/// @return Clinical note
Method GetClinicalNote(pNoteId As %String) As %String
{
    If '..CheckPermission("notes") {
        Quit "Access denied to clinical notes"
    }
    
    Set tSC = ..LoadRealService()
    If $$$ISERR(tSC) Quit "Service unavailable"
    
    Set tNote = ..RealService.GetClinicalNote(pNoteId)
    
    Do ..LogAccess("NOTE_ACCESS", pNoteId, ..UserName)
    
    Quit tNote
}

/// Calculate patient history (lazy loading with caching)
/// 
/// @param pPatientId Patient identifier
/// @return History summary
Method CalculatePatientHistory(pPatientId As %String) As %String
{
    If '..CheckPermission("medical") {
        Quit "Access denied to patient history"
    }
    
    // Check cache first
    Set tCacheKey = "HISTORY_" _ pPatientId
    If ..CachedData.IsDefined(tCacheKey) {
        Do ..LogAccess("HISTORY_CACHE_HIT", pPatientId, ..UserName)
        Quit ..CachedData.GetAt(tCacheKey)
    }
    
    Set tSC = ..LoadRealService()
    If $$$ISERR(tSC) Quit "Service unavailable"
    
    // Expensive operation - delegate to real service
    Set tHistory = ..RealService.CalculatePatientHistory(pPatientId)
    
    // Cache the result
    Do ..CachedData.SetAt(tHistory, tCacheKey)
    
    Do ..LogAccess("HISTORY_CALCULATED", pPatientId, ..UserName)
    
    Quit tHistory
}

/// Mask sensitive data based on role
/// 
/// @param pData Patient data to mask
/// @return Masked data
Method MaskSensitiveData(pData As %DynamicObject) As %DynamicObject [ Private ]
{
    // Create copy of data
    Set tMasked = {}.%FromJSON(pData.%ToJSON())
    
    // Mask SSN if not allowed
    If 'tMasked.%IsDefined("ssn") || '..CheckPermission("ssn") {
        If tMasked.%IsDefined("ssn") {
            Set tSSN = tMasked.ssn
            Set tMasked.ssn = "XXX-XX-" _ $Extract(tSSN, $Length(tSSN)-3, $Length(tSSN))
        }
    }
    
    // Remove emergency contact for non-medical roles
    If ..UserRole = "Billing" || ..UserRole = "Admin" {
        If tMasked.%IsDefined("emergencyContact") {
            Do tMasked.%Remove("emergencyContact")
        }
    }
    
    // Remove medical details for non-medical roles
    If ..UserRole = "Billing" {
        Do tMasked.%Remove("allergies")
        Do tMasked.%Remove("medications")
        Do tMasked.%Remove("diagnosis")
        Do tMasked.%Remove("bloodType")
    }
    
    Quit tMasked
}

/// Log access for HIPAA compliance
/// 
/// @param pAction Action performed
/// @param pDetails Details of access
/// @param pUser User performing action
Method LogAccess(pAction As %String, pDetails As %String, pUser As %String) [ Private ]
{
    If pUser = "" Set pUser = ..UserName
    
    Set tLogEntry = $ZDateTime($Horolog, 3) _ "|" _ pAction _ "|" _ pDetails _ "|" _ pUser _ "|" _ ..UserRole
    
    // Add to internal log
    Do ..AccessLog.Insert(tLogEntry)
    
    // Store in HIPAA audit global
    Set ^Patterns.HIPAAAudit($Increment(^Patterns.HIPAAAudit)) = tLogEntry
}

/// Get proxy statistics
/// 
/// @return Statistics object
Method GetStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Set tStats.userRole = ..UserRole
    Set tStats.userName = ..UserName
    Set tStats.isServiceLoaded = ..IsServiceLoaded
    Set tStats.accessCount = ..AccessCount
    Set tStats.deniedCount = ..DeniedCount
    Set tStats.cacheSize = ..CachedData.Count()
    Set tStats.auditLogSize = ..AccessLog.Count()
    
    If ..AccessCount + ..DeniedCount > 0 {
        Set tStats.allowRate = $Normalize(..AccessCount / (..AccessCount + ..DeniedCount) * 100, 2) _ "%"
    } Else {
        Set tStats.allowRate = "N/A"
    }
    
    Quit tStats
}

/// Class method to demonstrate role-based access
/// 
/// @param pShowOutput Whether to display output
/// @return Demonstration results
ClassMethod DemonstrateRoleBasedAccess(pShowOutput As %Boolean = 1) As %String
{
    Set tResult = ""
    
    Set tResult = tResult _ "Healthcare Proxy Pattern Demonstration:" _ $Char(13, 10)
    Set tResult = tResult _ $Char(13, 10)
    
    // Test with different roles
    Set tPatientId = "PAT001"
    
    // Doctor access (full privileges)
    Set tResult = tResult _ "=== DOCTOR ACCESS ===" _ $Char(13, 10)
    Set tDoctorProxy = ##class(PatientDataProxy).%New("Doctor", "Dr. Smith")
    Set tData = tDoctorProxy.GetPatientRecord(tPatientId)
    If tData '= "" {
        Set tResult = tResult _ "  ✓ Full record accessed" _ $Char(13, 10)
        Set tResult = tResult _ "  - SSN visible: " _ tData.ssn _ $Char(13, 10)
        Set tResult = tResult _ "  - Medical info: " _ tData.diagnosis.%ToJSON() _ $Char(13, 10)
    }
    
    // Nurse access (medical info only)
    Set tResult = tResult _ $Char(13, 10) _ "=== NURSE ACCESS ===" _ $Char(13, 10)
    Set tNurseProxy = ##class(PatientDataProxy).%New("Nurse", "Nurse Johnson")
    Set tData = tNurseProxy.GetPatientRecord(tPatientId)
    If tData '= "" {
        Set tResult = tResult _ "  ✓ Medical info accessed" _ $Char(13, 10)
        Set tResult = tResult _ "  - Can see: allergies, medications, diagnosis" _ $Char(13, 10)
        Set tResult = tResult _ "  - Cannot see: SSN, billing info" _ $Char(13, 10)
    }
    
    // Billing access (billing info only)
    Set tResult = tResult _ $Char(13, 10) _ "=== BILLING ACCESS ===" _ $Char(13, 10)
    Set tBillingProxy = ##class(PatientDataProxy).%New("Billing", "Bill Clerk")
    Set tData = tBillingProxy.GetPatientBillingInfo(tPatientId)
    If tData '= "" {
        Set tResult = tResult _ "  ✓ Billing info accessed" _ $Char(13, 10)
        Set tResult = tResult _ "  - Insurance ID: " _ tData.insuranceId _ $Char(13, 10)
        Set tResult = tResult _ "  - SSN masked: " _ tData.ssn _ $Char(13, 10)
    }
    
    // Admin access (administrative functions)
    Set tResult = tResult _ $Char(13, 10) _ "=== ADMIN ACCESS ===" _ $Char(13, 10)
    Set tAdminProxy = ##class(PatientDataProxy).%New("Admin", "Admin User")
    Set tData = tAdminProxy.GetPatientRecord(tPatientId)
    If tData '= "" {
        Set tResult = tResult _ "  ✓ Administrative access granted" _ $Char(13, 10)
        Set tResult = tResult _ "  - Can see: demographics, billing" _ $Char(13, 10)
        Set tResult = tResult _ "  - Can perform: updates, deletions" _ $Char(13, 10)
    }
    
    // Test lazy loading of expensive operations
    Set tResult = tResult _ $Char(13, 10) _ "=== LAZY LOADING TEST ===" _ $Char(13, 10)
    
    Set tStartTime = $Piece($Now(), ",", 2)
    Set tHistory1 = tDoctorProxy.CalculatePatientHistory(tPatientId)  // First call - slow
    Set tTime1 = $Piece($Now(), ",", 2) - tStartTime
    
    Set tStartTime = $Piece($Now(), ",", 2)
    Set tHistory2 = tDoctorProxy.CalculatePatientHistory(tPatientId)  // Second call - cached
    Set tTime2 = $Piece($Now(), ",", 2) - tStartTime
    
    Set tResult = tResult _ "  First call (calculated): " _ tTime1 _ " ms" _ $Char(13, 10)
    Set tResult = tResult _ "  Second call (cached): " _ tTime2 _ " ms" _ $Char(13, 10)
    If tTime2 > 0 {
        Set tResult = tResult _ "  Speedup: " _ $Normalize(tTime1 / tTime2, 2) _ "x faster" _ $Char(13, 10)
    }
    
    // Get statistics
    Set tStats = tDoctorProxy.GetStatistics()
    Set tResult = tResult _ $Char(13, 10) _ "=== STATISTICS ===" _ $Char(13, 10)
    Set tResult = tResult _ "  - Total accesses: " _ tStats.accessCount _ $Char(13, 10)
    Set tResult = tResult _ "  - Denied accesses: " _ tStats.deniedCount _ $Char(13, 10)
    Set tResult = tResult _ "  - Allow rate: " _ tStats.allowRate _ $Char(13, 10)
    Set tResult = tResult _ "  - Cache size: " _ tStats.cacheSize _ $Char(13, 10)
    
    If pShowOutput {
        Write tResult
    }
    
    // Clean up
    Do tDoctorProxy.%Close()
    Do tNurseProxy.%Close()
    Do tBillingProxy.%Close()
    Do tAdminProxy.%Close()
    
    Quit tResult
}

}
