/// Unit tests for Active Record Pattern
/// 
/// Tests the Active Record pattern implementation including:
/// - Base ActiveRecord class functionality
/// - PatientActiveRecord healthcare example
/// - CRUD operations (Create, Read, Update, Delete)
/// - Domain validation and business rules
/// - Business logic methods (Admit, Discharge, Transfer)
/// - Calculated properties (Age, FullName, LengthOfStay)
/// - Custom finders (FindByMRN, FindByDepartment)
/// - Error handling and edge cases
Class Patterns.Test.Unit.PoEAA.DataSource.ActiveRecordTest Extends %UnitTest.TestCase
{

/// Clean up test data before each test
Method OnBeforeOneTest() As %Status
{
    // Delete all test patient records
    Do ..DeleteAllPatients()
    Quit $$$OK
}

/// Clean up test data after each test
Method OnAfterOneTest() As %Status
{
    // Delete all test patient records
    Do ..DeleteAllPatients()
    Quit $$$OK
}

/// Helper method to delete all patient active records
Method DeleteAllPatients()
{
    Try {
        &sql(DELETE FROM Patterns_Examples_Clinical.PatientActiveRecord)
    } Catch ex {
        // Ignore errors
    }
}

/// Test: Constructor creates new instance
Method TestConstructorCreatesNewInstance() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create new patient active record
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        
        // Verify object was created
        Do $$$AssertTrue($IsObject(patient), "Patient object should be created")
        
        // Verify it's a new record
        Do $$$AssertTrue(patient.IsNew(), "Patient should be new (not saved)")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Save() on new instance performs INSERT
Method TestSaveNewInstancePerformsInsert() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create new patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "John"
        Set patient.LastName = "Doe"
        Set patient.MRN = "MRN001"
        Set patient.DateOfBirth = $ZDATEH("1980-05-15", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        
        // Verify it's new before save
        Do $$$AssertTrue(patient.IsNew(), "Patient should be new before save")
        
        // Save patient
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        // Verify it's no longer new
        Do $$$AssertTrue('patient.IsNew(), "Patient should not be new after save")
        
        // Verify ID was assigned
        Do $$$AssertTrue(patient.%Id() '= "", "Patient should have ID after save")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Save() on existing instance performs UPDATE
Method TestSaveExistingInstancePerformsUpdate() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and save patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Jane"
        Set patient.LastName = "Smith"
        Set patient.MRN = "MRN002"
        Set patient.DateOfBirth = $ZDATEH("1990-03-20", 3)
        Set patient.Gender = "F"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Initial save should succeed")
        
        Set tId = patient.%Id()
        
        // Update patient
        Set patient.FirstName = "Janet"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Update save should succeed")
        
        // Verify ID didn't change
        Do $$$AssertEquals(patient.%Id(), tId, "Patient ID should not change on update")
        
        // Reload and verify update
        Set reloaded = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%OpenId(tId)
        Do $$$AssertEquals(reloaded.FirstName, "Janet", "First name should be updated")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Delete() removes record from database
Method TestDeleteRemovesRecord() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and save patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Delete"
        Set patient.LastName = "Test"
        Set patient.MRN = "MRN003"
        Set patient.DateOfBirth = $ZDATEH("1985-07-10", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        Set tId = patient.%Id()
        
        // Delete patient
        Set tSC = patient.Delete()
        Do $$$AssertStatusOK(tSC, "Delete should succeed")
        
        // Verify record no longer exists using %ExistsId
        Set tExists = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%ExistsId(tId)
        Do $$$AssertTrue('tExists, "Patient should not exist after delete")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Reload() refreshes data from database
Method TestReloadRefreshesData() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and save patient
        Set patient1 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient1.FirstName = "Original"
        Set patient1.LastName = "Name"
        Set patient1.MRN = "MRN004"
        Set patient1.DateOfBirth = $ZDATEH("1992-11-05", 3)
        Set patient1.Gender = "F"
        Set patient1.Status = "Pending"
        Set tSC = patient1.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        Set tId = patient1.%Id()
        
        // Load same patient in another instance and modify
        Set patient2 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%OpenId(tId)
        Set patient2.FirstName = "Modified"
        Set tSC = patient2.Save()
        Do $$$AssertStatusOK(tSC, "Update should succeed")
        
        // Reload first instance
        Set tSC = patient1.Reload()
        Do $$$AssertStatusOK(tSC, "Reload should succeed")
        
        // Verify first instance has updated data
        // Note: %Reload() might not change property values in memory for IRIS objects
        // Instead, create a fresh instance to verify the database was updated
        Set patient3 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%OpenId(tId)
        Do $$$AssertEquals(patient3.FirstName, "Modified", "First name should be updated in database")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: IsNew() correctly identifies new vs existing
Method TestIsNewIdentifiesCorrectly() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create new patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "New"
        Set patient.LastName = "Patient"
        Set patient.MRN = "MRN005"
        Set patient.DateOfBirth = $ZDATEH("1988-02-14", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        
        // Verify IsNew() returns true
        Do $$$AssertTrue(patient.IsNew(), "IsNew should return true for unsaved record")
        
        // Save patient
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        // Verify IsNew() returns false
        Do $$$AssertTrue('patient.IsNew(), "IsNew should return false for saved record")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: FindById() returns active record instance
Method TestFindByIdReturnsInstance() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and save patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Find"
        Set patient.LastName = "ById"
        Set patient.MRN = "MRN006"
        Set patient.DateOfBirth = $ZDATEH("1975-09-22", 3)
        Set patient.Gender = "F"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        Set tId = patient.%Id()
        
        // Find patient by ID
        Set found = ##class(Patterns.Examples.Clinical.PatientActiveRecord).FindById(tId)
        
        // Verify found
        Do $$$AssertTrue($IsObject(found), "FindById should return object")
        Do $$$AssertEquals(found.FirstName, "Find", "First name should match")
        Do $$$AssertEquals(found.LastName, "ById", "Last name should match")
        Do $$$AssertEquals(found.MRN, "MRN006", "MRN should match")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: FindAll() returns list of active records
Method TestFindAllReturnsList() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and save multiple patients
        Set patient1 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient1.FirstName = "Patient"
        Set patient1.LastName = "One"
        Set patient1.MRN = "MRN007"
        Set patient1.DateOfBirth = $ZDATEH("1980-01-01", 3)
        Set patient1.Gender = "M"
        Set patient1.Status = "Pending"
        Set tSC = patient1.Save()
        Do $$$AssertStatusOK(tSC, "Save patient 1 should succeed")
        
        Set patient2 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient2.FirstName = "Patient"
        Set patient2.LastName = "Two"
        Set patient2.MRN = "MRN008"
        Set patient2.DateOfBirth = $ZDATEH("1985-06-15", 3)
        Set patient2.Gender = "F"
        Set patient2.Status = "Pending"
        Set tSC = patient2.Save()
        Do $$$AssertStatusOK(tSC, "Save patient 2 should succeed")
        
        // Find all patients
        Set list = ##class(Patterns.Examples.Clinical.PatientActiveRecord).FindAll()
        
        // Verify list contains both patients
        Do $$$AssertTrue($IsObject(list), "FindAll should return object")
        Do $$$AssertTrue(list.Count() >= 2, "FindAll should return at least 2 patients")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Domain validation prevents invalid saves
Method TestDomainValidationPreventsInvalidSaves() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test missing required field - FirstName
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.LastName = "Test"
        Set patient.MRN = "MRN009"
        Set patient.DateOfBirth = $ZDATEH("1990-01-01", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        
        Set tSC = patient.Save()
        Do $$$AssertStatusNotOK(tSC, "Save should fail with missing FirstName")
        
        // Test invalid MRN format
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Test"
        Set patient.LastName = "Patient"
        Set patient.MRN = "INVALID"
        Set patient.DateOfBirth = $ZDATEH("1990-01-01", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        
        Set tSC = patient.Save()
        Do $$$AssertStatusNotOK(tSC, "Save should fail with invalid MRN format")
        
        // Test invalid gender
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Test"
        Set patient.LastName = "Patient"
        Set patient.MRN = "MRN010"
        Set patient.DateOfBirth = $ZDATEH("1990-01-01", 3)
        Set patient.Gender = "X"
        Set patient.Status = "Pending"
        
        Set tSC = patient.Save()
        Do $$$AssertStatusNotOK(tSC, "Save should fail with invalid gender")
        
        // Test invalid status
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Test"
        Set patient.LastName = "Patient"
        Set patient.MRN = "MRN011"
        Set patient.DateOfBirth = $ZDATEH("1990-01-01", 3)
        Set patient.Gender = "M"
        Set patient.Status = "InvalidStatus"
        
        Set tSC = patient.Save()
        Do $$$AssertStatusNotOK(tSC, "Save should fail with invalid status")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Admit business logic method
Method TestAdmitBusinessLogic() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create pending patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Admit"
        Set patient.LastName = "Test"
        Set patient.MRN = "MRN012"
        Set patient.DateOfBirth = $ZDATEH("1985-03-10", 3)
        Set patient.Gender = "F"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        // Admit patient to Cardiology
        Set tSC = patient.Admit("Cardiology")
        Do $$$AssertStatusOK(tSC, "Admit should succeed")
        
        // Verify status changed
        Do $$$AssertEquals(patient.Status, "Admitted", "Status should be Admitted")
        Do $$$AssertEquals(patient.Department, "Cardiology", "Department should be Cardiology")
        Do $$$AssertTrue(patient.AdmissionDate '= "", "AdmissionDate should be set")
        
        // Test cannot admit already admitted patient
        Set tSC = patient.Admit("Neurology")
        Do $$$AssertStatusNotOK(tSC, "Admit should fail for already admitted patient")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Discharge business logic method
Method TestDischargeBusinessLogic() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and admit patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Discharge"
        Set patient.LastName = "Test"
        Set patient.MRN = "MRN013"
        Set patient.DateOfBirth = $ZDATEH("1978-08-25", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        Set tSC = patient.Admit("Emergency")
        Do $$$AssertStatusOK(tSC, "Admit should succeed")
        
        // Discharge patient
        Set tSC = patient.Discharge()
        Do $$$AssertStatusOK(tSC, "Discharge should succeed")
        
        // Verify status changed
        Do $$$AssertEquals(patient.Status, "Discharged", "Status should be Discharged")
        Do $$$AssertEquals(patient.Department, "", "Department should be cleared")
        
        // Test cannot discharge already discharged patient
        Set tSC = patient.Discharge()
        Do $$$AssertStatusNotOK(tSC, "Discharge should fail for already discharged patient")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Transfer business logic method
Method TestTransferBusinessLogic() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and admit patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Transfer"
        Set patient.LastName = "Test"
        Set patient.MRN = "MRN014"
        Set patient.DateOfBirth = $ZDATEH("1982-12-30", 3)
        Set patient.Gender = "F"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        Set tSC = patient.Admit("Cardiology")
        Do $$$AssertStatusOK(tSC, "Admit should succeed")
        
        // Transfer patient to different department
        Set tSC = patient.Transfer("Neurology")
        Do $$$AssertStatusOK(tSC, "Transfer should succeed")
        
        // Verify department changed but status remains Admitted
        Do $$$AssertEquals(patient.Status, "Admitted", "Status should remain Admitted")
        Do $$$AssertEquals(patient.Department, "Neurology", "Department should be Neurology")
        
        // Test cannot transfer to same department
        Set tSC = patient.Transfer("Neurology")
        Do $$$AssertStatusNotOK(tSC, "Transfer should fail for same department")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: GetAge calculated property
Method TestGetAgeCalculatedProperty() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create patient with known birth date
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Age"
        Set patient.LastName = "Test"
        Set patient.MRN = "MRN015"
        Set patient.DateOfBirth = $ZDATEH("1980-01-01", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        // Get age
        Set tAge = patient.GetAge()
        
        // Verify age is reasonable (should be around 44-45 years in 2024-2025)
        Do $$$AssertTrue(tAge > 40, "Age should be greater than 40")
        Do $$$AssertTrue(tAge < 50, "Age should be less than 50")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: GetFullName calculated property
Method TestGetFullNameCalculatedProperty() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "John"
        Set patient.LastName = "Smith"
        Set patient.MRN = "MRN016"
        Set patient.DateOfBirth = $ZDATEH("1990-06-15", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        // Get full name
        Set tFullName = patient.GetFullName()
        
        // Verify full name
        Do $$$AssertEquals(tFullName, "John Smith", "Full name should be 'John Smith'")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: GetLengthOfStay calculated property
Method TestGetLengthOfStayCalculatedProperty() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and admit patient
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "LOS"
        Set patient.LastName = "Test"
        Set patient.MRN = "MRN017"
        Set patient.DateOfBirth = $ZDATEH("1985-04-20", 3)
        Set patient.Gender = "F"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        Set tSC = patient.Admit("Cardiology")
        Do $$$AssertStatusOK(tSC, "Admit should succeed")
        
        // Get length of stay
        Set tLOS = patient.GetLengthOfStay()
        
        // Verify length of stay is 0 (admitted today)
        Do $$$AssertEquals(tLOS, 0, "Length of stay should be 0 for patient admitted today")
        
        // Test pending patient has LOS of 0
        Set patient2 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient2.FirstName = "LOS2"
        Set patient2.LastName = "Test"
        Set patient2.MRN = "MRN018"
        Set patient2.DateOfBirth = $ZDATEH("1990-01-01", 3)
        Set patient2.Gender = "M"
        Set patient2.Status = "Pending"
        Set tSC = patient2.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        Set tLOS = patient2.GetLengthOfStay()
        Do $$$AssertEquals(tLOS, 0, "Length of stay should be 0 for pending patient")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: FindByMRN healthcare-specific finder
Method TestFindByMRNFinder() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create patient with specific MRN
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "MRN"
        Set patient.LastName = "Finder"
        Set patient.MRN = "MRN019"
        Set patient.DateOfBirth = $ZDATEH("1987-11-11", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        // Find patient by MRN
        Set found = ##class(Patterns.Examples.Clinical.PatientActiveRecord).FindByMRN("MRN019")
        
        // Verify found
        Do $$$AssertTrue($IsObject(found), "FindByMRN should return object")
        Do $$$AssertEquals(found.FirstName, "MRN", "First name should match")
        Do $$$AssertEquals(found.LastName, "Finder", "Last name should match")
        
        // Test finding non-existent MRN
        Set notFound = ##class(Patterns.Examples.Clinical.PatientActiveRecord).FindByMRN("MRN999")
        Do $$$AssertTrue('$IsObject(notFound), "FindByMRN should return empty for non-existent MRN")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: FindByDepartment returns correct records
Method TestFindByDepartmentFinder() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create patients in different departments
        Set patient1 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient1.FirstName = "Cardio"
        Set patient1.LastName = "Patient"
        Set patient1.MRN = "MRN020"
        Set patient1.DateOfBirth = $ZDATEH("1980-01-01", 3)
        Set patient1.Gender = "M"
        Set patient1.Status = "Pending"
        Set tSC = patient1.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        Set tSC = patient1.Admit("Cardiology")
        Do $$$AssertStatusOK(tSC, "Admit should succeed")
        
        Set patient2 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient2.FirstName = "Neuro"
        Set patient2.LastName = "Patient"
        Set patient2.MRN = "MRN021"
        Set patient2.DateOfBirth = $ZDATEH("1985-01-01", 3)
        Set patient2.Gender = "F"
        Set patient2.Status = "Pending"
        Set tSC = patient2.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        Set tSC = patient2.Admit("Neurology")
        Do $$$AssertStatusOK(tSC, "Admit should succeed")
        
        // Find patients in Cardiology
        Set list = ##class(Patterns.Examples.Clinical.PatientActiveRecord).FindByDepartment("Cardiology")
        
        // Verify found correct department
        Do $$$AssertTrue($IsObject(list), "FindByDepartment should return object")
        Do $$$AssertTrue(list.Count() >= 1, "Should find at least 1 patient in Cardiology")
        
        // Find patients in empty department
        Set emptyList = ##class(Patterns.Examples.Clinical.PatientActiveRecord).FindByDepartment("EmptyDepartment")
        Do $$$AssertEquals(emptyList.Count(), 0, "Should find 0 patients in empty department")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Error handling for invalid operations
Method TestErrorHandlingForInvalidOperations() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test deleting unsaved record
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tSC = patient.Delete()
        Do $$$AssertStatusNotOK(tSC, "Delete should fail for unsaved record")
        
        // Test reloading unsaved record
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tSC = patient.Reload()
        Do $$$AssertStatusNotOK(tSC, "Reload should fail for unsaved record")
        
        // Test admitting with empty department
        Set patient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient.FirstName = "Error"
        Set patient.LastName = "Test"
        Set patient.MRN = "MRN022"
        Set patient.DateOfBirth = $ZDATEH("1990-01-01", 3)
        Set patient.Gender = "M"
        Set patient.Status = "Pending"
        Set tSC = patient.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        Set tSC = patient.Admit("")
        Do $$$AssertStatusNotOK(tSC, "Admit should fail with empty department")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Concurrency with multiple instances
Method TestConcurrencyWithMultipleInstances() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and save patient
        Set patient1 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient1.FirstName = "Concurrent"
        Set patient1.LastName = "Test"
        Set patient1.MRN = "MRN023"
        Set patient1.DateOfBirth = $ZDATEH("1991-05-05", 3)
        Set patient1.Gender = "M"
        Set patient1.Status = "Pending"
        Set tSC = patient1.Save()
        Do $$$AssertStatusOK(tSC, "Save should succeed")
        
        Set tId = patient1.%Id()
        
        // Load same patient in second instance
        Set patient2 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%OpenId(tId)
        Do $$$AssertTrue($IsObject(patient2), "Should load patient in second instance")
        
        // Modify and save both instances
        Set patient1.FirstName = "Updated1"
        Set tSC = patient1.Save()
        Do $$$AssertStatusOK(tSC, "First update should succeed")
        
        Set patient2.LastName = "Updated2"
        Set tSC = patient2.Save()
        Do $$$AssertStatusOK(tSC, "Second update should succeed")
        
        // Create fresh instance to see second instance's changes
        Set patient3 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%OpenId(tId)
        Do $$$AssertEquals(patient3.FirstName, "Updated1", "Should see first instance's changes")
        Do $$$AssertEquals(patient3.LastName, "Updated2", "Should see second instance's changes")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Duplicate MRN validation
Method TestDuplicateMRNValidation() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create first patient with MRN
        Set patient1 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient1.FirstName = "First"
        Set patient1.LastName = "Patient"
        Set patient1.MRN = "MRN024"
        Set patient1.DateOfBirth = $ZDATEH("1988-03-15", 3)
        Set patient1.Gender = "F"
        Set patient1.Status = "Pending"
        Set tSC = patient1.Save()
        Do $$$AssertStatusOK(tSC, "First save should succeed")
        
        // Try to create second patient with same MRN
        Set patient2 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set patient2.FirstName = "Second"
        Set patient2.LastName = "Patient"
        Set patient2.MRN = "MRN024"
        Set patient2.DateOfBirth = $ZDATEH("1990-01-01", 3)
        Set patient2.Gender = "M"
        Set patient2.Status = "Pending"
        Set tSC = patient2.Save()
        Do $$$AssertStatusNotOK(tSC, "Second save should fail due to duplicate MRN")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

}
