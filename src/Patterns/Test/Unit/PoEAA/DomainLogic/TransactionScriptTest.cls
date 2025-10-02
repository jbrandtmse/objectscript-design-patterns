/// Unit tests for Transaction Script Pattern
/// 
/// Tests the base TransactionScript pattern and the PatientAdmissionScript example
Class Patterns.Test.Unit.PoEAA.DomainLogic.TransactionScriptTest Extends %UnitTest.TestCase
{

/// Test base transaction script initialization
Method TestTransactionScriptInitialization() As %Status
{
    Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
    
    Do $$$AssertTrue($IsObject(script), "Script should be created")
    Do $$$AssertEquals(script.TransactionState, "INACTIVE", "Initial state should be INACTIVE")
    Do $$$AssertEquals(script.TransactionLevel, 0, "Initial transaction level should be 0")
    Do $$$AssertEquals(script.LastError, "", "Initial error should be empty")
    Quit $$$OK
}

/// Test starting a transaction
Method TestStartTransaction() As %Status
{
    Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
    
    Set status = script.StartTransaction()
    
    Do $$$AssertStatusOK(status, "StartTransaction should succeed")
    Do $$$AssertEquals(script.TransactionState, "ACTIVE", "State should be ACTIVE")
    Do $$$AssertTrue(script.TransactionLevel > 0, "Transaction level should be greater than 0")
    Do $$$AssertTrue(script.IsTransactionActive(), "Transaction should be active")
    
    // Clean up
    Do script.RollbackTransaction()
    Quit $$$OK
}

/// Test committing a transaction
Method TestCommitTransaction() As %Status
{
    Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
    
    Set status = script.StartTransaction()
    Do $$$AssertStatusOK(status, "StartTransaction should succeed")
    
    Set status = script.CommitTransaction()
    Do $$$AssertStatusOK(status, "CommitTransaction should succeed")
    Do $$$AssertEquals(script.TransactionState, "COMMITTED", "State should be COMMITTED")
    Do $$$AssertTrue('script.IsTransactionActive(), "Transaction should not be active")
    Quit $$$OK
}

/// Test rolling back a transaction
Method TestRollbackTransaction() As %Status
{
    Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
    
    Set status = script.StartTransaction()
    Do $$$AssertStatusOK(status, "StartTransaction should succeed")
    
    Set status = script.RollbackTransaction()
    Do $$$AssertStatusOK(status, "RollbackTransaction should succeed")
    Do $$$AssertEquals(script.TransactionState, "ROLLEDBACK", "State should be ROLLEDBACK")
    Do $$$AssertTrue('script.IsTransactionActive(), "Transaction should not be active")
    Quit $$$OK
}

/// Test commit without starting transaction
Method TestCommitWithoutStart() As %Status
{
    Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
    
    Set status = script.CommitTransaction()
    
    Do $$$AssertStatusNotOK(status, "Commit without start should fail")
    Quit $$$OK
}

/// Test rollback without starting transaction
Method TestRollbackWithoutStart() As %Status
{
    Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
    
    Set status = script.RollbackTransaction()
    
    Do $$$AssertStatusNotOK(status, "Rollback without start should fail")
    Quit $$$OK
}

/// Test transaction level tracking
Method TestTransactionLevel() As %Status
{
    Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
    
    Do $$$AssertEquals(script.GetTransactionLevel(), 0, "Initial level should be 0")
    
    Do script.StartTransaction()
    Do $$$AssertTrue(script.GetTransactionLevel() > 0, "Level should increase after start")
    
    Do script.CommitTransaction()
    Do $$$AssertEquals(script.GetTransactionLevel(), 0, "Level should return to 0 after commit")
    Quit $$$OK
}

/// Test transaction log
Method TestTransactionLog() As %Status
{
    Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
    
    Do script.StartTransaction()
    Do script.CommitTransaction()
    
    Set log = script.GetTransactionLog()
    
    Do $$$AssertTrue($IsObject(log), "Log should be returned")
    Do $$$AssertTrue(log.%Size() > 0, "Log should contain entries")
    Quit $$$OK
}

/// Test cleanup method
Method TestCleanup() As %Status
{
    Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
    
    Do script.StartTransaction()
    Do script.Cleanup()
    
    Do $$$AssertEquals(script.TransactionState, "INACTIVE", "State should be INACTIVE after cleanup")
    Do $$$AssertEquals(script.TransactionLevel, 0, "Level should be 0 after cleanup")
    Do $$$AssertEquals(script.LastError, "", "Error should be cleared after cleanup")
    Quit $$$OK
}

/// Test patient admission script initialization
Method TestPatientAdmissionInitialization() As %Status
{
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Do $$$AssertTrue($IsObject(admission), "Admission script should be created")
    Do $$$AssertEquals(admission.AdmissionStatus, "PENDING", "Initial status should be PENDING")
    Do $$$AssertEquals(admission.PatientID, "", "Initial patient ID should be empty")
    Do $$$AssertEquals(admission.AssignedBed, "", "Initial bed should be empty")
    Do $$$AssertTrue('admission.InsuranceVerified, "Insurance should not be verified initially")
    Do $$$AssertTrue('admission.MedicalHistoryCollected, "Medical history should not be collected initially")
    Quit $$$OK
}

/// Test patient data validation
Method TestValidatePatientData() As %Status
{
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    // Valid data
    Set validData = {"firstName":"John","lastName":"Doe","dob":"1980-01-01"}
    Do $$$AssertTrue(admission.ValidatePatientData(validData), "Valid data should pass validation")
    
    // Missing firstName
    Set invalidData = {"lastName":"Doe","dob":"1980-01-01"}
    Do $$$AssertTrue('admission.ValidatePatientData(invalidData), "Missing firstName should fail validation")
    
    // Missing lastName
    Set invalidData = {"firstName":"John","dob":"1980-01-01"}
    Do $$$AssertTrue('admission.ValidatePatientData(invalidData), "Missing lastName should fail validation")
    
    // Missing dob
    Set invalidData = {"firstName":"John","lastName":"Doe"}
    Do $$$AssertTrue('admission.ValidatePatientData(invalidData), "Missing dob should fail validation")
    
    // Empty firstName
    Set invalidData = {"firstName":"","lastName":"Doe","dob":"1980-01-01"}
    Do $$$AssertTrue('admission.ValidatePatientData(invalidData), "Empty firstName should fail validation")
    Quit $$$OK
}

/// Test patient registration
Method TestRegisterPatient() As %Status
{
    // Clean up test data first
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set patientData = {
        "firstName": "John",
        "lastName": "Doe",
        "dob": "1980-01-01",
        "ssn": "123-45-6789",
        "phone": "555-1234",
        "email": "john.doe@example.com"
    }
    
    Set status = admission.RegisterPatient(patientData)
    
    Do $$$AssertStatusOK(status, "Patient registration should succeed")
    Do $$$AssertTrue(admission.PatientID '= "", "Patient ID should be generated")
    
    // Verify data stored in global
    Set patientID = admission.PatientID
    Do $$$AssertEquals($GET(^Patterns.Examples.Patient(patientID, "firstName")), "John", "First name should be stored")
    Do $$$AssertEquals($GET(^Patterns.Examples.Patient(patientID, "lastName")), "Doe", "Last name should be stored")
    Do $$$AssertEquals($GET(^Patterns.Examples.Patient(patientID, "dob")), "1980-01-01", "DOB should be stored")
    
    // Clean up
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

/// Test insurance verification
Method TestInsuranceVerification() As %Status
{
    // Clean up test data first
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set patientData = {
        "firstName": "Jane",
        "lastName": "Smith",
        "dob": "1985-05-15",
        "insurance": {
            "provider": "Blue Cross",
            "policyNumber": "BC123456",
            "groupNumber": "GRP001"
        }
    }
    
    // Register patient first
    Set status = admission.RegisterPatient(patientData)
    Do $$$AssertStatusOK(status, "Patient registration should succeed")
    
    // Verify insurance
    Set status = admission.VerifyInsurance(patientData)
    Do $$$AssertStatusOK(status, "Insurance verification should succeed")
    Do $$$AssertTrue(admission.InsuranceVerified, "Insurance should be verified")
    
    // Verify data stored in global
    Set patientID = admission.PatientID
    Do $$$AssertEquals($GET(^Patterns.Examples.Patient(patientID, "insurance", "provider")), "Blue Cross", "Provider should be stored")
    Do $$$AssertEquals($GET(^Patterns.Examples.Patient(patientID, "insurance", "verified")), 1, "Verification flag should be set")
    
    // Clean up
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

/// Test bed assignment
Method TestBedAssignment() As %Status
{
    // Clean up test data first
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set patientData = {
        "firstName": "Bob",
        "lastName": "Johnson",
        "dob": "1975-12-10",
        "bedPreference": "private"
    }
    
    // Register patient first
    Set status = admission.RegisterPatient(patientData)
    Do $$$AssertStatusOK(status, "Patient registration should succeed")
    
    // Assign bed
    Set status = admission.AssignBed(patientData)
    Do $$$AssertStatusOK(status, "Bed assignment should succeed")
    Do $$$AssertTrue(admission.AssignedBed '= "", "Bed should be assigned")
    
    // Verify bed contains "PRIVATE" for private preference
    Set assignedBed = admission.AssignedBed
    Do $$$AssertTrue($FIND(assignedBed, "PRIVATE") > 0, "Private bed should be assigned")
    
    // Verify data stored in global
    Set patientID = admission.PatientID
    Do $$$AssertEquals($GET(^Patterns.Examples.Patient(patientID, "bed")), assignedBed, "Bed should be linked to patient")
    Do $$$AssertEquals($GET(^Patterns.Examples.Bed(assignedBed, "occupied")), 1, "Bed should be marked occupied")
    
    // Clean up
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

/// Test medical history collection
Method TestMedicalHistoryCollection() As %Status
{
    // Clean up test data first
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set patientData = {
        "firstName": "Alice",
        "lastName": "Williams",
        "dob": "1990-03-20",
        "medicalHistory": {
            "allergies": ["Penicillin", "Latex"],
            "medications": ["Aspirin", "Lisinopril"],
            "conditions": ["Hypertension", "Diabetes"],
            "surgeries": ["Appendectomy"]
        }
    }
    
    // Register patient first
    Set status = admission.RegisterPatient(patientData)
    Do $$$AssertStatusOK(status, "Patient registration should succeed")
    
    // Collect medical history
    Set status = admission.CollectMedicalHistory(patientData)
    Do $$$AssertStatusOK(status, "Medical history collection should succeed")
    Do $$$AssertTrue(admission.MedicalHistoryCollected, "Medical history should be collected")
    
    // Verify data stored in global
    Set patientID = admission.PatientID
    Do $$$AssertEquals($GET(^Patterns.Examples.Patient(patientID, "history", "allergies", 0)), "Penicillin", "First allergy should be stored")
    Do $$$AssertEquals($GET(^Patterns.Examples.Patient(patientID, "history", "medications", 0)), "Aspirin", "First medication should be stored")
    Do $$$AssertEquals($GET(^Patterns.Examples.Patient(patientID, "history", "collected")), 1, "Collection flag should be set")
    
    // Clean up
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

/// Test complete admission workflow
Method TestCompleteAdmissionWorkflow() As %Status
{
    // Clean up test data first
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set patientData = {
        "firstName": "Charlie",
        "lastName": "Brown",
        "dob": "1988-07-04",
        "phone": "555-9876",
        "insurance": {
            "provider": "Aetna",
            "policyNumber": "AET789012"
        },
        "bedPreference": "semi-private",
        "medicalHistory": {
            "allergies": ["Sulfa"],
            "medications": ["Metformin"]
        }
    }
    
    Set status = admission.ProcessAdmission(patientData)
    
    Do $$$AssertStatusOK(status, "Complete admission should succeed")
    Do $$$AssertEquals(admission.AdmissionStatus, "COMPLETED", "Status should be COMPLETED")
    Do $$$AssertTrue(admission.PatientID '= "", "Patient ID should be generated")
    Do $$$AssertTrue(admission.InsuranceVerified, "Insurance should be verified")
    Do $$$AssertTrue(admission.AssignedBed '= "", "Bed should be assigned")
    Do $$$AssertTrue(admission.MedicalHistoryCollected, "Medical history should be collected")
    
    // Verify admission record created
    Set patientID = admission.PatientID
    Set admissionID = $GET(^Patterns.Examples.Patient(patientID, "currentAdmission"))
    Do $$$AssertTrue(admissionID '= "", "Admission ID should be created")
    Do $$$AssertEquals($GET(^Patterns.Examples.Admission(admissionID, "status")), "ACTIVE", "Admission status should be ACTIVE")
    
    // Clean up
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

/// Test admission workflow with missing insurance
Method TestAdmissionFailsWithoutInsurance() As %Status
{
    // Clean up test data first
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set patientData = {
        "firstName": "David",
        "lastName": "Davis",
        "dob": "1982-11-15"
    }
    
    Set status = admission.ProcessAdmission(patientData)
    
    Do $$$AssertStatusNotOK(status, "Admission without insurance should fail")
    Do $$$AssertEquals(admission.AdmissionStatus, "FAILED", "Status should be FAILED")
    
    // Clean up
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

/// Test admission rollback on error
Method TestAdmissionRollback() As %Status
{
    // Clean up test data first
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set patientData = {
        "firstName": "Eve",
        "lastName": "Evans",
        "dob": "1995-02-28",
        "insurance": {
            "provider": "UnitedHealth",
            "policyNumber": ""  // Empty policy number will cause verification to fail
        }
    }
    
    Set status = admission.ProcessAdmission(patientData)
    
    Do $$$AssertStatusNotOK(status, "Admission with invalid insurance should fail")
    Do $$$AssertEquals(admission.AdmissionStatus, "FAILED", "Status should be FAILED")
    Do $$$AssertEquals(admission.TransactionState, "ROLLEDBACK", "Transaction should be rolled back")
    
    // Clean up
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

/// Test admission summary
Method TestGetAdmissionSummary() As %Status
{
    // Clean up test data first
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set patientData = {
        "firstName": "Frank",
        "lastName": "Foster",
        "dob": "1978-09-12",
        "insurance": {
            "provider": "Cigna",
            "policyNumber": "CIG456789"
        }
    }
    
    Do admission.ProcessAdmission(patientData)
    
    Set summary = admission.GetAdmissionSummary()
    
    Do $$$AssertTrue($IsObject(summary), "Summary should be returned")
    Do $$$AssertTrue(summary.patientID '= "", "Summary should include patient ID")
    Do $$$AssertTrue(summary.assignedBed '= "", "Summary should include assigned bed")
    Do $$$AssertEquals(summary.admissionStatus, "COMPLETED", "Summary should show completed status")
    
    // Clean up
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

/// Test concurrent admissions
Method TestConcurrentAdmissions() As %Status
{
    // Clean up test data first
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    
    Set admission1 = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    Set admission2 = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set patient1 = {
        "firstName": "George",
        "lastName": "Garcia",
        "dob": "1983-04-22",
        "insurance": {"provider": "Kaiser", "policyNumber": "KP111"}
    }
    
    Set patient2 = {
        "firstName": "Helen",
        "lastName": "Harris",
        "dob": "1991-08-30",
        "insurance": {"provider": "Anthem", "policyNumber": "ANT222"}
    }
    
    Set status1 = admission1.ProcessAdmission(patient1)
    Set status2 = admission2.ProcessAdmission(patient2)
    
    Do $$$AssertStatusOK(status1, "First admission should succeed")
    Do $$$AssertStatusOK(status2, "Second admission should succeed")
    Do $$$AssertTrue(admission1.PatientID '= admission2.PatientID, "Patient IDs should be different")
    Do $$$AssertTrue(admission1.AssignedBed '= admission2.AssignedBed, "Beds should be different")
    
    // Clean up
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

/// Test error handling with invalid patient data
Method TestErrorHandlingInvalidData() As %Status
{
    Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()
    
    Set invalidData = {"firstName": ""}  // Missing required fields
    
    Set status = admission.RegisterPatient(invalidData)
    
    Do $$$AssertStatusNotOK(status, "Registration with invalid data should fail")
    Do $$$AssertTrue(admission.GetLastError() '= "", "Error message should be set")
    Quit $$$OK
}

/// Clean up after each test
Method OnAfterOneTest() As %Status
{
    // Clean up any test data
    Do ##class(Patterns.Examples.PatientAdmissionScript).CleanupTestData()
    Quit $$$OK
}

}
