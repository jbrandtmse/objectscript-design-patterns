/// Unit Tests for Table Module Pattern
/// 
/// Tests the Table Module pattern implementation including:
/// - Table module initialization and SQL execution
/// - Single-row and multi-row retrieval operations
/// - INSERT, UPDATE, DELETE operations with validation
/// - Result set processing and object conversion
/// - Healthcare patient table module scenarios
/// - Error handling and SQL exception management
Class Patterns.Test.Unit.PoEAA.DomainLogic.TableModuleTest Extends %UnitTest.TestCase
{

/// Test table module basic FindById operation
Method TestFindById() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "John Doe"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tPatient.WeightKg = 75
        Set tPatient.HeightCm = 175
        Set tSC = tPatient.%Save()
        Do $$$AssertStatusOK(tSC, "Patient saved successfully")
        
        Set tPatientId = tPatient.%Id()
        
        // Test FindById
        Set tResult = ##class(Patterns.Examples.Clinical.PatientTableModule).FindById(tPatientId)
        Do $$$AssertTrue($IsObject(tResult), "FindById returned object")
        Do $$$AssertEquals(tResult.FullName, "John Doe", "Correct patient retrieved")
        
        // Cleanup
        Set tSC = ##class(Patterns.Examples.Clinical.PersistentPatient).%DeleteId(tPatientId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test FindById with non-existent ID
Method TestFindByIdNotFound() As %Status
{
    Set tSC = $$$OK
    Try {
        // Search for non-existent ID
        Set tResult = ##class(Patterns.Examples.Clinical.PatientTableModule).FindById(999999)
        Do $$$AssertTrue(tResult = "", "Non-existent ID returns empty string")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test FindAll operation
Method TestFindAll() As %Status
{
    Set tSC = $$$OK
    Set tPatientIds = []
    Try {
        // Create multiple test patients
        For tIndex = 1:1:3 {
            Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
            Set tPatient.MedicalRecordNumber = "1234567" _ tIndex
            Set tPatient.FullName = "Test Patient " _ tIndex
            Set tPatient.DateOfBirth = +$HOROLOG - (10000 + tIndex)
            Set tPatient.WeightKg = 70 + tIndex
            Set tPatient.HeightCm = 170 + tIndex
            Set tSC = tPatient.%Save()
            Do tPatientIds.%Push(tPatient.%Id())
        }
        
        // Test FindAll
        Set tResults = ##class(Patterns.Examples.Clinical.PatientTableModule).FindAll()
        Do $$$AssertTrue($IsObject(tResults), "FindAll returned array")
        Do $$$AssertTrue(tResults.%Size() >= 3, "At least 3 patients found")
        
        // Cleanup
        For tIndex = 0:1:(tPatientIds.%Size()-1) {
            Set tId = tPatientIds.%Get(tIndex)
            Set tSC = ##class(Patterns.Examples.Clinical.PersistentPatient).%DeleteId(tId)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test FindByMedicalRecordNumber
Method TestFindByMedicalRecordNumber() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        Set tPatient.MedicalRecordNumber = "87654321"
        Set tPatient.FullName = "Jane Smith"
        Set tPatient.DateOfBirth = +$HOROLOG - 12000
        Set tPatient.WeightKg = 65
        Set tPatient.HeightCm = 165
        Set tSC = tPatient.%Save()
        Set tPatientId = tPatient.%Id()
        
        // Test FindByMedicalRecordNumber
        Set tResult = ##class(Patterns.Examples.Clinical.PatientTableModule).FindByMedicalRecordNumber("87654321")
        Do $$$AssertTrue($IsObject(tResult), "Patient found by MRN")
        Do $$$AssertEquals(tResult.FullName, "Jane Smith", "Correct patient retrieved by MRN")
        
        // Cleanup
        Set tSC = ##class(Patterns.Examples.Clinical.PersistentPatient).%DeleteId(tPatientId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test FindPatientsByName with partial matching
Method TestFindPatientsByName() As %Status
{
    Set tSC = $$$OK
    Set tPatientIds = []
    Try {
        // Create test patients with similar names
        Set tPatient1 = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        Set tPatient1.MedicalRecordNumber = "11111111"
        Set tPatient1.FullName = "Smith, John"
        Set tPatient1.DateOfBirth = +$HOROLOG - 10000
        Set tSC = tPatient1.%Save()
        Do tPatientIds.%Push(tPatient1.%Id())
        
        Set tPatient2 = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        Set tPatient2.MedicalRecordNumber = "22222222"
        Set tPatient2.FullName = "Smith, Jane"
        Set tPatient2.DateOfBirth = +$HOROLOG - 11000
        Set tSC = tPatient2.%Save()
        Do tPatientIds.%Push(tPatient2.%Id())
        
        // Test partial name search
        Set tResults = ##class(Patterns.Examples.Clinical.PatientTableModule).FindPatientsByName("Smith")
        Do $$$AssertTrue($IsObject(tResults), "Search returned array")
        Do $$$AssertTrue(tResults.%Size() >= 2, "At least 2 patients named Smith found")
        
        // Cleanup
        For tIndex = 0:1:(tPatientIds.%Size()-1) {
            Set tId = tPatientIds.%Get(tIndex)
            Set tSC = ##class(Patterns.Examples.Clinical.PersistentPatient).%DeleteId(tId)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test Insert operation with validation
Method TestInsertPatient() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient data object
        Set tPatientData = {}
        Set tPatientData.MedicalRecordNumber = "55555555"
        Set tPatientData.FullName = "Test Insert Patient"
        Set tPatientData.DateOfBirth = +$HOROLOG - 10000
        Set tPatientData.WeightKg = 80
        Set tPatientData.HeightCm = 180
        
        // Test Insert
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).InsertPatient(tPatientData)
        Do $$$AssertStatusOK(tSC, "Patient inserted successfully")
        
        // Verify insertion
        Set tFound = ##class(Patterns.Examples.Clinical.PatientTableModule).FindByMedicalRecordNumber("55555555")
        Do $$$AssertTrue($IsObject(tFound), "Inserted patient found")
        
        // Cleanup - use direct SQL to find ID for deletion
        &sql(SELECT ID INTO :tPatientId FROM Patterns_Examples_Clinical.PersistentPatient WHERE MedicalRecordNumber = '55555555')
        If SQLCODE = 0 {
            Set tSC = ##class(Patterns.Examples.Clinical.PersistentPatient).%DeleteId(tPatientId)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test Insert with invalid data
Method TestInsertPatientValidationFailure() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create invalid patient data (short MRN)
        Set tPatientData = {}
        Set tPatientData.MedicalRecordNumber = "123"  // Invalid - too short
        Set tPatientData.FullName = "Invalid Patient"
        Set tPatientData.DateOfBirth = +$HOROLOG - 10000
        
        // Test Insert with validation failure
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).InsertPatient(tPatientData)
        Do $$$AssertStatusNotOK(tSC, "Invalid patient data rejected")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test Update operation
Method TestUpdatePatient() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        Set tPatient.MedicalRecordNumber = "66666666"
        Set tPatient.FullName = "Original Name"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tPatient.WeightKg = 70
        Set tPatient.HeightCm = 170
        Set tSC = tPatient.%Save()
        Set tPatientId = tPatient.%Id()
        
        // Create update data
        Set tUpdateData = {}
        Set tUpdateData.FullName = "Updated Name"
        Set tUpdateData.WeightKg = 75
        
        // Test Update
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).UpdatePatient(tPatientId, tUpdateData)
        Do $$$AssertStatusOK(tSC, "Patient updated successfully")
        
        // Verify update
        Set tUpdated = ##class(Patterns.Examples.Clinical.PatientTableModule).FindById(tPatientId)
        Do $$$AssertEquals(tUpdated.FullName, "Updated Name", "Name updated correctly")
        
        // Cleanup
        Set tSC = ##class(Patterns.Examples.Clinical.PersistentPatient).%DeleteId(tPatientId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test Update with invalid data
Method TestUpdatePatientValidationFailure() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        Set tPatient.MedicalRecordNumber = "77777777"
        Set tPatient.FullName = "Test Patient"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tSC = tPatient.%Save()
        Set tPatientId = tPatient.%Id()
        
        // Create invalid update data (future date of birth)
        Set tUpdateData = {}
        Set tUpdateData.DateOfBirth = +$HOROLOG + 100  // Future date - invalid
        
        // Test Update with validation failure
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).UpdatePatient(tPatientId, tUpdateData)
        Do $$$AssertStatusNotOK(tSC, "Invalid update data rejected")
        
        // Cleanup
        Set tSC = ##class(Patterns.Examples.Clinical.PersistentPatient).%DeleteId(tPatientId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test Delete operation
Method TestDeletePatient() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        Set tPatient.MedicalRecordNumber = "88888888"
        Set tPatient.FullName = "Delete Test Patient"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tSC = tPatient.%Save()
        Set tPatientId = tPatient.%Id()
        
        // Test Delete
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).DeletePatient(tPatientId)
        Do $$$AssertStatusOK(tSC, "Patient deleted successfully")
        
        // Verify deletion
        Set tExists = ##class(Patterns.Examples.Clinical.PatientTableModule).Exists(tPatientId)
        Do $$$AssertTrue('tExists, "Patient no longer exists")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test GetCount operation
Method TestGetCount() As %Status
{
    Set tSC = $$$OK
    Try {
        // Get initial count
        Set tInitialCount = ##class(Patterns.Examples.Clinical.PatientTableModule).GetCount()
        Do $$$AssertTrue(tInitialCount >= 0, "Count is non-negative")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test Exists operation
Method TestExists() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        Set tPatient.MedicalRecordNumber = "99999999"
        Set tPatient.FullName = "Exists Test"
        Set tPatient.DateOfBirth = +$HOROLOG - 10000
        Set tSC = tPatient.%Save()
        Set tPatientId = tPatient.%Id()
        
        // Test Exists for existing patient
        Set tExists = ##class(Patterns.Examples.Clinical.PatientTableModule).Exists(tPatientId)
        Do $$$AssertTrue(tExists, "Existing patient found")
        
        // Test Exists for non-existent patient
        Set tNotExists = ##class(Patterns.Examples.Clinical.PatientTableModule).Exists(999999)
        Do $$$AssertTrue('tNotExists, "Non-existent patient not found")
        
        // Cleanup
        Set tSC = ##class(Patterns.Examples.Clinical.PersistentPatient).%DeleteId(tPatientId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test GetAllActivePatients
Method TestGetAllActivePatients() As %Status
{
    Set tSC = $$$OK
    Try {
        // Test GetAllActivePatients
        Set tActivePatients = ##class(Patterns.Examples.Clinical.PatientTableModule).GetAllActivePatients()
        Do $$$AssertTrue($IsObject(tActivePatients), "Active patients array returned")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test ValidatePatientData with valid data
Method TestValidatePatientDataValid() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create valid patient data
        Set tPatientData = {}
        Set tPatientData.MedicalRecordNumber = "12345678"
        Set tPatientData.FullName = "Valid Patient"
        Set tPatientData.DateOfBirth = +$HOROLOG - 10000
        Set tPatientData.WeightKg = 75
        Set tPatientData.HeightCm = 175
        
        // Test validation
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).ValidatePatientData(tPatientData)
        Do $$$AssertStatusOK(tSC, "Valid patient data passes validation")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test ValidatePatientData with invalid MRN
Method TestValidatePatientDataInvalidMRN() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient data with invalid MRN
        Set tPatientData = {}
        Set tPatientData.MedicalRecordNumber = "ABC"  // Not 8 digits
        Set tPatientData.FullName = "Test Patient"
        Set tPatientData.DateOfBirth = +$HOROLOG - 10000
        
        // Test validation
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).ValidatePatientData(tPatientData)
        Do $$$AssertStatusNotOK(tSC, "Invalid MRN fails validation")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test ValidatePatientData with invalid name
Method TestValidatePatientDataInvalidName() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient data with invalid name
        Set tPatientData = {}
        Set tPatientData.MedicalRecordNumber = "12345678"
        Set tPatientData.FullName = "X"  // Too short
        Set tPatientData.DateOfBirth = +$HOROLOG - 10000
        
        // Test validation
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).ValidatePatientData(tPatientData)
        Do $$$AssertStatusNotOK(tSC, "Short name fails validation")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test ValidatePatientData with future date of birth
Method TestValidatePatientDataFutureDateOfBirth() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient data with future DOB
        Set tPatientData = {}
        Set tPatientData.MedicalRecordNumber = "12345678"
        Set tPatientData.FullName = "Test Patient"
        Set tPatientData.DateOfBirth = +$HOROLOG + 100  // Future date
        
        // Test validation
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).ValidatePatientData(tPatientData)
        Do $$$AssertStatusNotOK(tSC, "Future DOB fails validation")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test ValidatePatientData with invalid weight
Method TestValidatePatientDataInvalidWeight() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient data with invalid weight
        Set tPatientData = {}
        Set tPatientData.MedicalRecordNumber = "12345678"
        Set tPatientData.FullName = "Test Patient"
        Set tPatientData.DateOfBirth = +$HOROLOG - 10000
        Set tPatientData.WeightKg = 600  // Exceeds maximum
        
        // Test validation
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).ValidatePatientData(tPatientData)
        Do $$$AssertStatusNotOK(tSC, "Invalid weight fails validation")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test GetCountByAgeRange
Method TestGetCountByAgeRange() As %Status
{
    Set tSC = $$$OK
    Try {
        // Test age range query
        Set tCount = ##class(Patterns.Examples.Clinical.PatientTableModule).GetCountByAgeRange(20, 40)
        Do $$$AssertTrue(tCount >= 0, "Age range count is non-negative")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test CalculateAverageAge
Method TestCalculateAverageAge() As %Status
{
    Set tSC = $$$OK
    Try {
        // Test average age calculation
        Set tAverage = ##class(Patterns.Examples.Clinical.PatientTableModule).CalculateAverageAge()
        Do $$$AssertTrue(tAverage >= 0, "Average age is non-negative")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

/// Test complete healthcare workflow
Method TestCompleteHealthcareWorkflow() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create patient data
        Set tPatientData = {}
        Set tPatientData.MedicalRecordNumber = "11223344"
        Set tPatientData.FullName = "Workflow Test Patient"
        Set tPatientData.DateOfBirth = +$HOROLOG - 15000
        Set tPatientData.WeightKg = 70
        Set tPatientData.HeightCm = 170
        
        // Insert patient
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).InsertPatient(tPatientData)
        Do $$$AssertStatusOK(tSC, "Patient inserted in workflow")
        
        // Find patient by MRN and get ID
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientTableModule).FindByMedicalRecordNumber("11223344")
        Do $$$AssertTrue($IsObject(tPatient), "Patient found in workflow")
        
        // Get ID using direct SQL for reliable ID retrieval
        &sql(SELECT ID INTO :tPatientId FROM Patterns_Examples_Clinical.PersistentPatient WHERE MedicalRecordNumber = '11223344')
        Do $$$AssertTrue(SQLCODE = 0, "Patient ID retrieved successfully")
        
        // Update patient
        Set tUpdateData = {}
        Set tUpdateData.WeightKg = 72
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).UpdatePatient(tPatientId, tUpdateData)
        Do $$$AssertStatusOK(tSC, "Patient updated in workflow")
        
        // Verify update
        Set tUpdated = ##class(Patterns.Examples.Clinical.PatientTableModule).FindById(tPatientId)
        Do $$$AssertTrue($IsObject(tUpdated), "Updated patient retrieved")
        
        // Delete patient
        Set tSC = ##class(Patterns.Examples.Clinical.PatientTableModule).DeletePatient(tPatientId)
        Do $$$AssertStatusOK(tSC, "Patient deleted in workflow")
        
        // Verify deletion
        Set tExists = ##class(Patterns.Examples.Clinical.PatientTableModule).Exists(tPatientId)
        Do $$$AssertTrue('tExists, "Patient deleted from system")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit $$$OK
}

}
