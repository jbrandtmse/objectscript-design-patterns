/// Gang of Four Proxy Pattern - Healthcare Example (Real Subject)
/// 
/// Intent:
/// Represents the actual patient data service that contains
/// sensitive medical information. This is the real subject that
/// the proxy controls access to.
/// 
/// This implementation demonstrates:
/// - Storage of sensitive patient data (PII/PHI)
/// - Medical records with various data types
/// - Patient history and imaging data
/// - Clinical notes and treatment plans
/// 
/// Structure:
/// <example>
/// // Direct access (would be restricted in production)
/// Set service = ##class(Patterns.Examples.PatientDataService).%New()
/// Set patientData = service.GetPatientRecord("12345")
/// 
/// // Through proxy (controlled access)
/// Set proxy = ##class(Patterns.Examples.PatientDataProxy).%New()
/// Set patientData = proxy.GetPatientRecord("12345")  // Access checked
/// </example>
Class Patterns.Examples.PatientDataService Extends %RegisteredObject
{

/// Property PatientDatabase - Simulated patient database
Property PatientDatabase As %ArrayOfObjects [ Private ];

/// Property MedicalImages - Large medical imaging data
Property MedicalImages As %ArrayOfDataTypes [ Private ];

/// Property ClinicalNotes - Detailed clinical notes
Property ClinicalNotes As %ArrayOfDataTypes [ Private ];

/// Property AccessCount - Track number of accesses
Property AccessCount As %Integer [ InitialExpression = 0 ];

/// Constructor - Initialize patient data service
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    // Initialize data structures
    Set ..PatientDatabase = ##class(%ArrayOfObjects).%New()
    Set ..MedicalImages = ##class(%ArrayOfDataTypes).%New()
    Set ..ClinicalNotes = ##class(%ArrayOfDataTypes).%New()
    
    // Load sample patient data
    Do ..LoadSamplePatients()
    
    Quit tSC
}

/// Load sample patient data for demonstration
Method LoadSamplePatients() [ Private ]
{
    // Patient 1: John Doe
    Set tPatient1 = {}
    Set tPatient1.patientId = "PAT001"
    Set tPatient1.firstName = "John"
    Set tPatient1.lastName = "Doe"
    Set tPatient1.dateOfBirth = "1975-03-15"
    Set tPatient1.ssn = "123-45-6789"  // Sensitive PII
    Set tPatient1.gender = "Male"
    Set tPatient1.bloodType = "O+"
    Set tPatient1.allergies = ["Penicillin", "Peanuts"]
    Set tPatient1.medications = ["Lisinopril", "Metformin"]
    Set tPatient1.diagnosis = ["Hypertension", "Type 2 Diabetes"]
    Set tPatient1.insuranceId = "INS123456"
    Set tPatient1.emergencyContact = {
        "name": "Jane Doe",
        "relationship": "Spouse",
        "phone": "555-0123"
    }
    Set tPatient1.lastVisit = "2025-09-15"
    Set tPatient1.nextAppointment = "2025-10-15"
    Do ..PatientDatabase.SetAt(tPatient1, "PAT001")
    
    // Patient 2: Jane Smith
    Set tPatient2 = {}
    Set tPatient2.patientId = "PAT002"
    Set tPatient2.firstName = "Jane"
    Set tPatient2.lastName = "Smith"
    Set tPatient2.dateOfBirth = "1982-07-22"
    Set tPatient2.ssn = "987-65-4321"  // Sensitive PII
    Set tPatient2.gender = "Female"
    Set tPatient2.bloodType = "A-"
    Set tPatient2.allergies = ["Latex"]
    Set tPatient2.medications = ["Birth Control", "Vitamin D"]
    Set tPatient2.diagnosis = ["Asthma"]
    Set tPatient2.insuranceId = "INS789012"
    Set tPatient2.emergencyContact = {
        "name": "Bob Smith",
        "relationship": "Husband",
        "phone": "555-0456"
    }
    Set tPatient2.lastVisit = "2025-09-10"
    Set tPatient2.nextAppointment = "2025-09-25"
    Do ..PatientDatabase.SetAt(tPatient2, "PAT002")
    
    // Patient 3: Minor patient (special privacy rules)
    Set tPatient3 = {}
    Set tPatient3.patientId = "PAT003"
    Set tPatient3.firstName = "Tommy"
    Set tPatient3.lastName = "Johnson"
    Set tPatient3.dateOfBirth = "2012-11-30"
    Set tPatient3.ssn = "456-78-9012"  // Sensitive PII
    Set tPatient3.gender = "Male"
    Set tPatient3.bloodType = "B+"
    Set tPatient3.allergies = []
    Set tPatient3.medications = ["Albuterol"]
    Set tPatient3.diagnosis = ["Childhood Asthma"]
    Set tPatient3.insuranceId = "INS345678"
    Set tPatient3.guardian = "Mary Johnson"
    Set tPatient3.isMinor = 1
    Set tPatient3.emergencyContact = {
        "name": "Mary Johnson",
        "relationship": "Mother",
        "phone": "555-0789"
    }
    Set tPatient3.lastVisit = "2025-09-01"
    Set tPatient3.nextAppointment = "2025-10-01"
    Do ..PatientDatabase.SetAt(tPatient3, "PAT003")
    
    // Load sample medical images (simulated large data)
    Do ..MedicalImages.SetAt("X-RAY: Chest radiograph data (2MB)...", "PAT001_XRAY_001")
    Do ..MedicalImages.SetAt("MRI: Brain scan data (50MB)...", "PAT002_MRI_001")
    Do ..MedicalImages.SetAt("CT: Abdominal scan data (30MB)...", "PAT001_CT_001")
    
    // Load sample clinical notes
    Do ..ClinicalNotes.SetAt("2025-09-15: Patient presents with elevated blood pressure...", "PAT001_NOTE_001")
    Do ..ClinicalNotes.SetAt("2025-09-10: Routine checkup, asthma well controlled...", "PAT002_NOTE_001")
    Do ..ClinicalNotes.SetAt("2025-09-01: Pediatric visit, growth normal, immunizations up to date...", "PAT003_NOTE_001")
}

/// Get complete patient record
/// 
/// @param pPatientId Patient identifier
/// @return Patient data as JSON object
Method GetPatientRecord(pPatientId As %String) As %DynamicObject
{
    Set ..AccessCount = ..AccessCount + 1
    
    If '..PatientDatabase.IsDefined(pPatientId) {
        Quit ""
    }
    
    Set tPatient = ..PatientDatabase.GetAt(pPatientId)
    
    // Log access (would integrate with audit system)
    Do ..LogAccess("FULL_ACCESS", pPatientId, $Username)
    
    Quit tPatient
}

/// Get patient demographics only
/// 
/// @param pPatientId Patient identifier
/// @return Limited patient data
Method GetPatientDemographics(pPatientId As %String) As %DynamicObject
{
    Set ..AccessCount = ..AccessCount + 1
    
    If '..PatientDatabase.IsDefined(pPatientId) {
        Quit ""
    }
    
    Set tFullPatient = ..PatientDatabase.GetAt(pPatientId)
    
    // Return only demographic information
    Set tDemographics = {}
    Set tDemographics.patientId = tFullPatient.patientId
    Set tDemographics.firstName = tFullPatient.firstName
    Set tDemographics.lastName = tFullPatient.lastName
    Set tDemographics.gender = tFullPatient.gender
    Set tDemographics.lastVisit = tFullPatient.lastVisit
    Set tDemographics.nextAppointment = tFullPatient.nextAppointment
    
    Do ..LogAccess("DEMOGRAPHICS_ACCESS", pPatientId, $Username)
    
    Quit tDemographics
}

/// Get patient medical information
/// 
/// @param pPatientId Patient identifier
/// @return Medical data only
Method GetPatientMedicalInfo(pPatientId As %String) As %DynamicObject
{
    Set ..AccessCount = ..AccessCount + 1
    
    If '..PatientDatabase.IsDefined(pPatientId) {
        Quit ""
    }
    
    Set tFullPatient = ..PatientDatabase.GetAt(pPatientId)
    
    // Return medical information
    Set tMedical = {}
    Set tMedical.patientId = tFullPatient.patientId
    Set tMedical.bloodType = tFullPatient.bloodType
    Set tMedical.allergies = tFullPatient.allergies
    Set tMedical.medications = tFullPatient.medications
    Set tMedical.diagnosis = tFullPatient.diagnosis
    
    Do ..LogAccess("MEDICAL_ACCESS", pPatientId, $Username)
    
    Quit tMedical
}

/// Get patient billing information
/// 
/// @param pPatientId Patient identifier
/// @return Billing data only
Method GetPatientBillingInfo(pPatientId As %String) As %DynamicObject
{
    Set ..AccessCount = ..AccessCount + 1
    
    If '..PatientDatabase.IsDefined(pPatientId) {
        Quit ""
    }
    
    Set tFullPatient = ..PatientDatabase.GetAt(pPatientId)
    
    // Return billing-relevant information
    Set tBilling = {}
    Set tBilling.patientId = tFullPatient.patientId
    Set tBilling.firstName = tFullPatient.firstName
    Set tBilling.lastName = tFullPatient.lastName
    Set tBilling.insuranceId = tFullPatient.insuranceId
    Set tBilling.dateOfBirth = tFullPatient.dateOfBirth  // For insurance verification
    
    Do ..LogAccess("BILLING_ACCESS", pPatientId, $Username)
    
    Quit tBilling
}

/// Update patient record
/// 
/// @param pPatientId Patient identifier
/// @param pUpdates Updates to apply
/// @return Status of update operation
Method UpdatePatientRecord(pPatientId As %String, pUpdates As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    If '..PatientDatabase.IsDefined(pPatientId) {
        Set tSC = $$$ERROR($$$GeneralError, "Patient not found: " _ pPatientId)
        Quit tSC
    }
    
    Set tPatient = ..PatientDatabase.GetAt(pPatientId)
    
    // Apply updates (simplified for demo)
    Set tIterator = pUpdates.%GetIterator()
    While tIterator.%GetNext(.tKey, .tValue) {
        Do tPatient.%Set(tKey, tValue)
    }
    
    // Save updated patient
    Do ..PatientDatabase.SetAt(tPatient, pPatientId)
    
    Do ..LogAccess("UPDATE", pPatientId, $Username)
    
    Quit tSC
}

/// Get medical image data (simulated large data)
/// 
/// @param pImageId Image identifier
/// @return Image data or metadata
Method GetMedicalImage(pImageId As %String) As %String
{
    // Simulate expensive operation
    Hang 0.5  // Simulate loading time
    
    If '..MedicalImages.IsDefined(pImageId) {
        Quit "Image not found"
    }
    
    Do ..LogAccess("IMAGE_ACCESS", pImageId, $Username)
    
    Quit ..MedicalImages.GetAt(pImageId)
}

/// Get clinical notes
/// 
/// @param pNoteId Note identifier
/// @return Clinical note text
Method GetClinicalNote(pNoteId As %String) As %String
{
    If '..ClinicalNotes.IsDefined(pNoteId) {
        Quit "Note not found"
    }
    
    Do ..LogAccess("NOTE_ACCESS", pNoteId, $Username)
    
    Quit ..ClinicalNotes.GetAt(pNoteId)
}

/// Delete patient record (requires special permission)
/// 
/// @param pPatientId Patient identifier
/// @return Status of deletion
Method DeletePatientRecord(pPatientId As %String) As %Status
{
    Set tSC = $$$OK
    
    If '..PatientDatabase.IsDefined(pPatientId) {
        Set tSC = $$$ERROR($$$GeneralError, "Patient not found: " _ pPatientId)
        Quit tSC
    }
    
    // Remove patient data
    Do ..PatientDatabase.RemoveAt(pPatientId)
    
    Do ..LogAccess("DELETE", pPatientId, $Username)
    
    Quit tSC
}

/// Log access for audit trail (HIPAA compliance)
/// 
/// @param pAction Action performed
/// @param pResource Resource accessed
/// @param pUser User performing action
Method LogAccess(pAction As %String, pResource As %String, pUser As %String) [ Private ]
{
    // Store in audit global for HIPAA compliance
    Set tAuditEntry = $ZDateTime($Horolog, 3) _ "|" _ pAction _ "|" _ pResource _ "|" _ pUser
    Set ^Patterns.PatientDataAudit($Increment(^Patterns.PatientDataAudit)) = tAuditEntry
}

/// Get list of all patient IDs
/// 
/// @return List of patient identifiers
Method GetPatientList() As %ListOfDataTypes
{
    Set tList = ##class(%ListOfDataTypes).%New()
    
    Set tKey = ""
    For {
        Set tKey = ..PatientDatabase.Next(tKey)
        Quit:tKey=""
        
        Do tList.Insert(tKey)
    }
    
    Quit tList
}

/// Get service statistics
/// 
/// @return Statistics object
Method GetStatistics() As %DynamicObject
{
    Set tStats = {}
    Set tStats.totalPatients = ..PatientDatabase.Count()
    Set tStats.totalImages = ..MedicalImages.Count()
    Set tStats.totalNotes = ..ClinicalNotes.Count()
    Set tStats.accessCount = ..AccessCount
    
    Quit tStats
}

/// Perform expensive patient history calculation
/// 
/// @param pPatientId Patient identifier
/// @return Historical summary
Method CalculatePatientHistory(pPatientId As %String) As %String
{
    // Simulate expensive operation
    Hang 1  // Simulate complex calculation
    
    If '..PatientDatabase.IsDefined(pPatientId) {
        Quit "Patient not found"
    }
    
    Set tPatient = ..PatientDatabase.GetAt(pPatientId)
    
    Set tHistory = "Patient History Summary for " _ tPatient.firstName _ " " _ tPatient.lastName _ ": "
    Set tHistory = tHistory _ "Diagnosed with " _ tPatient.diagnosis.%ToJSON() _ ", "
    Set tHistory = tHistory _ "Currently on " _ tPatient.medications.%ToJSON() _ ", "
    Set tHistory = tHistory _ "Known allergies: " _ tPatient.allergies.%ToJSON()
    
    Do ..LogAccess("HISTORY_CALC", pPatientId, $Username)
    
    Quit tHistory
}

}
