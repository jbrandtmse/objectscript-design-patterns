/// Healthcare Patient Admission Transaction Script Example
/// 
/// Demonstrates the Transaction Script pattern for managing
/// patient admission workflows in a healthcare setting.
/// 
/// Procedures:
/// - Patient Registration
/// - Bed Assignment
/// - Insurance Verification
/// - Medical History Collection
/// 
/// Example:
/// <example>
/// Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
/// Set patientData = {"firstName":"John","lastName":"Doe","dob":"1980-01-01"}
/// Set status = admission.ProcessAdmission(patientData)
/// </example>
Class Patterns.Examples.PatientAdmissionScript Extends Patterns.PoEAA.DomainLogic.TransactionScript
{

/// Admission data storage
Property AdmissionData As %DynamicObject;

/// Patient ID generated during registration
Property PatientID As %String;

/// Bed assignment
Property AssignedBed As %String;

/// Insurance verification result
Property InsuranceVerified As %Boolean;

/// Medical history collected flag
Property MedicalHistoryCollected As %Boolean;

/// Admission status
Property AdmissionStatus As %String [ InitialExpression = "PENDING" ];

/// Constructor - Initialize admission script
Method %OnNew() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        // Initialize admission properties
        Set ..AdmissionData = {}
        Set ..PatientID = ""
        Set ..AssignedBed = ""
        Set ..InsuranceVerified = 0
        Set ..MedicalHistoryCollected = 0
        Set ..AdmissionStatus = "PENDING"
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process complete patient admission workflow
/// @param pPatientData Patient information as dynamic object
/// @return Status indicating success or failure
Method ProcessAdmission(pPatientData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Start transaction for entire admission process
        Set tSC = ..StartTransaction()
        If $$$ISERR(tSC) {
            Set ..AdmissionStatus = "FAILED"
            Quit
        }
        
        // Step 1: Register patient
        Set tSC = ..RegisterPatient(pPatientData)
        If $$$ISERR(tSC) {
            Do ..RollbackTransaction()
            Set ..AdmissionStatus = "FAILED"
            Quit
        }
        
        // Step 2: Verify insurance
        Set tSC = ..VerifyInsurance(pPatientData)
        If $$$ISERR(tSC) {
            Do ..RollbackTransaction()
            Set ..AdmissionStatus = "FAILED"
            Quit
        }
        
        // Step 3: Assign bed
        Set tSC = ..AssignBed(pPatientData)
        If $$$ISERR(tSC) {
            Do ..RollbackTransaction()
            Set ..AdmissionStatus = "FAILED"
            Quit
        }
        
        // Step 4: Collect medical history
        Set tSC = ..CollectMedicalHistory(pPatientData)
        If $$$ISERR(tSC) {
            Do ..RollbackTransaction()
            Set ..AdmissionStatus = "FAILED"
            Quit
        }
        
        // Step 5: Finalize admission
        Set tSC = ..FinalizeAdmission()
        If $$$ISERR(tSC) {
            Do ..RollbackTransaction()
            Set ..AdmissionStatus = "FAILED"
            Quit
        }
        
        // Commit if all steps successful
        Set tSC = ..CommitTransaction()
        
        // Update admission status
        Set ..AdmissionStatus = "COMPLETED"
        
    } Catch ex {
        // Rollback on any error
        Do ..RollbackTransaction()
        Set tSC = ex.AsStatus()
        Set ..LastError = "Admission process failed: "_ex.DisplayString()
        Set ..AdmissionStatus = "FAILED"
    }
    
    Quit tSC
}

/// Register a new patient
/// @param pPatientData Patient demographic information
/// @return Status indicating success or failure
Method RegisterPatient(pPatientData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate required fields
        If '..ValidatePatientData(pPatientData) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid patient data")
            Set ..LastError = "Invalid patient data"
            Quit
        }
        
        // Generate patient ID
        Set ..PatientID = ..GeneratePatientID()
        
        // Store patient demographics in global
        Set ^Patterns.Examples.Patient(..PatientID, "firstName") = pPatientData.firstName
        Set ^Patterns.Examples.Patient(..PatientID, "lastName") = pPatientData.lastName
        Set ^Patterns.Examples.Patient(..PatientID, "dob") = pPatientData.dob
        
        // Store optional fields
        If pPatientData.%IsDefined("ssn") {
            Set ^Patterns.Examples.Patient(..PatientID, "ssn") = pPatientData.ssn
        }
        If pPatientData.%IsDefined("phone") {
            Set ^Patterns.Examples.Patient(..PatientID, "phone") = pPatientData.phone
        }
        If pPatientData.%IsDefined("email") {
            Set ^Patterns.Examples.Patient(..PatientID, "email") = pPatientData.email
        }
        
        // Store emergency contact if provided
        If pPatientData.%IsDefined("emergencyContact") {
            Set contact = pPatientData.emergencyContact
            Set ^Patterns.Examples.Patient(..PatientID, "emergency", "name") = contact.name
            Set ^Patterns.Examples.Patient(..PatientID, "emergency", "phone") = contact.phone
            Set ^Patterns.Examples.Patient(..PatientID, "emergency", "relationship") = contact.relationship
        }
        
        // Log registration
        Set ..TransactionLog("registration", $HOROLOG) = "Patient "_..PatientID_" registered"
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..LastError = "Patient registration failed: "_ex.DisplayString()
    }
    
    Quit tSC
}

/// Verify patient insurance coverage
/// @param pPatientData Patient information including insurance details
/// @return Status indicating success or failure
Method VerifyInsurance(pPatientData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate patient ID
        If ..PatientID = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Patient must be registered first")
            Quit
        }
        
        // Extract insurance information
        If 'pPatientData.%IsDefined("insurance") {
            Set tSC = $$$ERROR($$$GeneralError, "Insurance information required")
            Quit
        }
        
        Set insurance = pPatientData.insurance
        
        // Validate required insurance fields
        If '((insurance.%IsDefined("provider")) && (insurance.%IsDefined("policyNumber"))) {
            Set tSC = $$$ERROR($$$GeneralError, "Insurance provider and policy number required")
            Quit
        }
        
        // Store insurance information
        Set ^Patterns.Examples.Patient(..PatientID, "insurance", "provider") = insurance.provider
        Set ^Patterns.Examples.Patient(..PatientID, "insurance", "policyNumber") = insurance.policyNumber
        
        If insurance.%IsDefined("groupNumber") {
            Set ^Patterns.Examples.Patient(..PatientID, "insurance", "groupNumber") = insurance.groupNumber
        }
        
        // Simulate insurance verification (in real system, would call external service)
        Set verificationResult = ..SimulateInsuranceVerification(insurance)
        
        If verificationResult {
            Set ..InsuranceVerified = 1
            Set ^Patterns.Examples.Patient(..PatientID, "insurance", "verified") = 1
            Set ^Patterns.Examples.Patient(..PatientID, "insurance", "verifiedDate") = $HOROLOG
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "Insurance verification failed")
            Quit
        }
        
        // Log verification
        Set ..TransactionLog("insurance", $HOROLOG) = "Insurance verified for patient "_..PatientID
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..LastError = "Insurance verification failed: "_ex.DisplayString()
    }
    
    Quit tSC
}

/// Assign a bed to the patient
/// @param pPatientData Patient information including bed preferences
/// @return Status indicating success or failure
Method AssignBed(pPatientData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate patient ID
        If ..PatientID = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Patient must be registered first")
            Quit
        }
        
        // Get bed preferences if provided
        Set bedPreference = ""
        If pPatientData.%IsDefined("bedPreference") {
            Set bedPreference = pPatientData.bedPreference
        }
        
        // Find available bed
        Set availableBed = ..FindAvailableBed(bedPreference)
        
        If availableBed = "" {
            Set tSC = $$$ERROR($$$GeneralError, "No beds available")
            Quit
        }
        
        // Assign bed
        Set ..AssignedBed = availableBed
        Set ^Patterns.Examples.Patient(..PatientID, "bed") = availableBed
        Set ^Patterns.Examples.Bed(availableBed, "occupied") = 1
        Set ^Patterns.Examples.Bed(availableBed, "patientID") = ..PatientID
        Set ^Patterns.Examples.Bed(availableBed, "assignedDate") = $HOROLOG
        
        // Log bed assignment
        Set ..TransactionLog("bedAssignment", $HOROLOG) = "Bed "_availableBed_" assigned to patient "_..PatientID
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..LastError = "Bed assignment failed: "_ex.DisplayString()
    }
    
    Quit tSC
}

/// Collect patient medical history
/// @param pPatientData Patient information including medical history
/// @return Status indicating success or failure
Method CollectMedicalHistory(pPatientData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate patient ID
        If ..PatientID = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Patient must be registered first")
            Quit
        }
        
        // Collect medical history if provided
        If pPatientData.%IsDefined("medicalHistory") {
            Set history = pPatientData.medicalHistory
            
            // Store allergies
            If history.%IsDefined("allergies") {
                Set allergies = history.allergies
                Set iterator = allergies.%GetIterator()
                Set index = 0
                While iterator.%GetNext(.key, .value) {
                    Set ^Patterns.Examples.Patient(..PatientID, "history", "allergies", index) = value
                    Set index = index + 1
                }
            }
            
            // Store current medications
            If history.%IsDefined("medications") {
                Set medications = history.medications
                Set iterator = medications.%GetIterator()
                Set index = 0
                While iterator.%GetNext(.key, .value) {
                    Set ^Patterns.Examples.Patient(..PatientID, "history", "medications", index) = value
                    Set index = index + 1
                }
            }
            
            // Store previous conditions
            If history.%IsDefined("conditions") {
                Set conditions = history.conditions
                Set iterator = conditions.%GetIterator()
                Set index = 0
                While iterator.%GetNext(.key, .value) {
                    Set ^Patterns.Examples.Patient(..PatientID, "history", "conditions", index) = value
                    Set index = index + 1
                }
            }
            
            // Store previous surgeries
            If history.%IsDefined("surgeries") {
                Set surgeries = history.surgeries
                Set iterator = surgeries.%GetIterator()
                Set index = 0
                While iterator.%GetNext(.key, .value) {
                    Set ^Patterns.Examples.Patient(..PatientID, "history", "surgeries", index) = value
                    Set index = index + 1
                }
            }
        }
        
        Set ..MedicalHistoryCollected = 1
        Set ^Patterns.Examples.Patient(..PatientID, "history", "collected") = 1
        Set ^Patterns.Examples.Patient(..PatientID, "history", "collectedDate") = $HOROLOG
        
        // Log medical history collection
        Set ..TransactionLog("medicalHistory", $HOROLOG) = "Medical history collected for patient "_..PatientID
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..LastError = "Medical history collection failed: "_ex.DisplayString()
    }
    
    Quit tSC
}

/// Finalize the admission process
/// @return Status indicating success or failure
Method FinalizeAdmission() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Verify all steps completed
        If ..PatientID = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Patient not registered")
            Quit
        }
        
        If '..InsuranceVerified {
            Set tSC = $$$ERROR($$$GeneralError, "Insurance not verified")
            Quit
        }
        
        If ..AssignedBed = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Bed not assigned")
            Quit
        }
        
        // Create admission record
        Set admissionID = ..GenerateAdmissionID()
        Set ^Patterns.Examples.Admission(admissionID, "patientID") = ..PatientID
        Set ^Patterns.Examples.Admission(admissionID, "bed") = ..AssignedBed
        Set ^Patterns.Examples.Admission(admissionID, "admissionDate") = $HOROLOG
        Set ^Patterns.Examples.Admission(admissionID, "status") = "ACTIVE"
        
        // Link admission to patient
        Set ^Patterns.Examples.Patient(..PatientID, "currentAdmission") = admissionID
        
        // Log finalization
        Set ..TransactionLog("finalization", $HOROLOG) = "Admission "_admissionID_" finalized for patient "_..PatientID
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..LastError = "Admission finalization failed: "_ex.DisplayString()
    }
    
    Quit tSC
}

/// Validate patient data has required fields
/// @param pPatientData Patient information to validate
/// @return 1 if valid, 0 otherwise
Method ValidatePatientData(pPatientData As %DynamicObject) As %Boolean
{
    // Check required fields
    If 'pPatientData.%IsDefined("firstName") Quit 0
    If 'pPatientData.%IsDefined("lastName") Quit 0
    If 'pPatientData.%IsDefined("dob") Quit 0
    
    // Validate names are not empty
    If pPatientData.firstName = "" Quit 0
    If pPatientData.lastName = "" Quit 0
    
    Quit 1
}

/// Generate unique patient ID
/// @return New patient ID
Method GeneratePatientID() As %String
{
    // Use timestamp-based ID with counter
    Set baseID = "P"_$TRANSLATE($HOROLOG, ",", "")
    Set counter = $INCREMENT(^Patterns.Examples.PatientIDCounter)
    Quit baseID_"-"_counter
}

/// Generate unique admission ID
/// @return New admission ID
Method GenerateAdmissionID() As %String
{
    // Use timestamp-based ID with counter
    Set baseID = "A"_$TRANSLATE($HOROLOG, ",", "")
    Set counter = $INCREMENT(^Patterns.Examples.AdmissionIDCounter)
    Quit baseID_"-"_counter
}

/// Simulate insurance verification (placeholder for external service call)
/// @param pInsurance Insurance information
/// @return 1 if verified, 0 otherwise
Method SimulateInsuranceVerification(pInsurance As %DynamicObject) As %Boolean
{
    // In real system, would call external insurance verification service
    // For demo, verify if policy number is not empty
    If pInsurance.policyNumber '= "" {
        Quit 1
    }
    Quit 0
}

/// Find available bed based on preference
/// @param pPreference Bed preference (e.g., "private", "semi-private", "ward")
/// @return Bed ID or empty string if none available
Method FindAvailableBed(pPreference As %String = "") As %String
{
    // Simple bed assignment algorithm
    // In real system, would check actual bed availability, room types, etc.
    
    // For demo, generate bed ID based on preference
    Set bedType = "WARD"
    If pPreference = "private" Set bedType = "PRIVATE"
    If pPreference = "semi-private" Set bedType = "SEMI"
    
    Set roomNumber = $RANDOM(100) + 1
    Set bedLetter = $CHAR(65 + $RANDOM(4))  // A-D
    
    Set bedID = bedType_"-"_roomNumber_bedLetter
    
    // Check if bed already occupied
    If $DATA(^Patterns.Examples.Bed(bedID, "occupied")) {
        If ^Patterns.Examples.Bed(bedID, "occupied") = 1 {
            // Try another bed (recursive)
            Quit ..FindAvailableBed(pPreference)
        }
    }
    
    Quit bedID
}

/// Get admission summary
/// @return Dynamic object with admission details
Method GetAdmissionSummary() As %DynamicObject
{
    Set summary = {}
    Set summary.patientID = ..PatientID
    Set summary.assignedBed = ..AssignedBed
    Set summary.insuranceVerified = ..InsuranceVerified
    Set summary.medicalHistoryCollected = ..MedicalHistoryCollected
    Set summary.admissionStatus = ..AdmissionStatus
    Set summary.transactionState = ..TransactionState
    
    Quit summary
}

/// Clean up admission data (for testing)
ClassMethod CleanupTestData()
{
    Kill ^Patterns.Examples.Patient
    Kill ^Patterns.Examples.Admission
    Kill ^Patterns.Examples.Bed
    Kill ^Patterns.Examples.PatientIDCounter
    Kill ^Patterns.Examples.AdmissionIDCounter
}

}
