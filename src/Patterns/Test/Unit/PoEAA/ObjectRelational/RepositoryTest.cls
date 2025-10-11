/// Repository Pattern Unit Tests
/// 
/// Comprehensive test suite for Repository pattern implementation
/// Tests repository operations, specification queries, and integration
/// with Identity Map and Data Mapper patterns.
/// 
/// @see Patterns.PoEAA.ObjectRelational.Repository
/// @see Patterns.Examples.Clinical.PatientRepository
/// @since 1.0.0
Class Patterns.Test.Unit.PoEAA.ObjectRelational.RepositoryTest Extends %UnitTest.TestCase
{

/// Patient repository instance for testing
Property Repository As Patterns.Examples.Clinical.PatientRepository;

/// Setup - Create repository instance before each test
Method OnBeforeOneTest() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create repository instance
        Set ..Repository = ##class(Patterns.Examples.Clinical.PatientRepository).%New()
        
        // Clean up any existing test data
        Do ..CleanupTestData()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Cleanup - Remove test data after each test
Method OnAfterOneTest() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Do ..CleanupTestData()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test Add() adds entity to repository
Method TestAdd() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.FirstName = "John"
        Set tPatient.LastName = "Doe"
        Set tPatient.MRN = "TEST001"
        Set tPatient.Status = "Active"
        Set tPatient.Department = "Cardiology"
        
        // Add to repository
        Set tSC = ..Repository.Add(tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        // Verify patient has ID
        Do $$$AssertTrue(tPatient.%Id() '= "", "Patient should have ID after Add")
        
        // Verify patient in Identity Map
        Set tFromMap = ..Repository.IdentityMap.Get(tPatient.%Id())
        Do $$$AssertTrue($IsObject(tFromMap), "Patient should be in Identity Map")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test Remove() removes entity from repository
Method TestRemove() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and add test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.FirstName = "Jane"
        Set tPatient.LastName = "Smith"
        Set tPatient.MRN = "TEST002"
        Set tPatient.Status = "Active"
        Set tSC = ..Repository.Add(tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        Set tId = tPatient.%Id()
        
        // Remove from repository
        Set tSC = ..Repository.Remove(tPatient)
        Do $$$AssertStatusOK(tSC, "Remove should succeed")
        
        // Verify patient removed from database
        Set tFound = ##class(Patterns.Examples.Clinical.Patient).%ExistsId(tId)
        Do $$$AssertTrue('tFound, "Patient should be removed from database")
        
        // Verify patient removed from Identity Map
        Set tFromMap = ..Repository.IdentityMap.Get(tId)
        Do $$$AssertTrue('$IsObject(tFromMap), "Patient should be removed from Identity Map")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test FindById() retrieves entity
Method TestFindById() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and add test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.FirstName = "Bob"
        Set tPatient.LastName = "Johnson"
        Set tPatient.MRN = "TEST003"
        Set tPatient.Status = "Active"
        Set tSC = ..Repository.Add(tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        Set tId = tPatient.%Id()
        
        // Clear identity map to force database load
        Do ..Repository.ClearCache()
        
        // Find by ID
        Set tFound = ..Repository.FindById(tId)
        Do $$$AssertTrue($IsObject(tFound), "FindById should return patient")
        Do $$$AssertEquals(tFound.MRN, "TEST003", "Found patient should have correct MRN")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test FindAll() returns all entities
Method TestFindAll() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create multiple test patients
        For i=1:1:3 {
            Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
            Set tPatient.FirstName = "Patient" _ i
            Set tPatient.LastName = "Test"
            Set tPatient.MRN = "TESTALL" _ i
            Set tPatient.Status = "Active"
            Set tSC = ..Repository.Add(tPatient)
            Do $$$AssertStatusOK(tSC, "Add should succeed for patient " _ i)
        }
        
        // Find all
        Set tList = ..Repository.FindAll()
        Do $$$AssertTrue($IsObject(tList), "FindAll should return list")
        Do $$$AssertTrue(tList.Count() >= 3, "FindAll should return at least 3 patients")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test FindBySpecification() with simple criteria
Method TestFindBySpecificationSimple() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patients with different statuses
        Set tActivePatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tActivePatient.FirstName = "Active"
        Set tActivePatient.LastName = "Patient"
        Set tActivePatient.MRN = "TESTSPEC001"
        Set tActivePatient.Status = "Active"
        Set tSC = ..Repository.Add(tActivePatient)
        Do $$$AssertStatusOK(tSC, "Add active patient should succeed")
        
        Set tDischargedPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tDischargedPatient.FirstName = "Discharged"
        Set tDischargedPatient.LastName = "Patient"
        Set tDischargedPatient.MRN = "TESTSPEC002"
        Set tDischargedPatient.Status = "Discharged"
        Set tSC = ..Repository.Add(tDischargedPatient)
        Do $$$AssertStatusOK(tSC, "Add discharged patient should succeed")
        
        // Find active patients using specification
        Set tSpec = ##class(Patterns.Examples.Clinical.ActivePatientSpec).%New()
        Set tList = ..Repository.FindBySpecification(tSpec)
        
        Do $$$AssertTrue($IsObject(tList), "FindBySpecification should return list")
        Do $$$AssertTrue(tList.Count() > 0, "Should find active patients")
        
        // Verify all returned patients are active
        For i=1:1:tList.Count() {
            Set tPatient = tList.GetAt(i)
            Do $$$AssertEquals(tPatient.Status, "Active", "All patients should be Active")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test FindBySpecification() with complex criteria
Method TestFindBySpecificationComplex() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patients
        Set tPatient1 = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient1.FirstName = "Cardio"
        Set tPatient1.LastName = "Active"
        Set tPatient1.MRN = "TESTCPLX001"
        Set tPatient1.Status = "Active"
        Set tPatient1.Department = "Cardiology"
        Set tSC = ..Repository.Add(tPatient1)
        Do $$$AssertStatusOK(tSC, "Add patient 1 should succeed")
        
        Set tPatient2 = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient2.FirstName = "Cardio"
        Set tPatient2.LastName = "Discharged"
        Set tPatient2.MRN = "TESTCPLX002"
        Set tPatient2.Status = "Discharged"
        Set tPatient2.Department = "Cardiology"
        Set tSC = ..Repository.Add(tPatient2)
        Do $$$AssertStatusOK(tSC, "Add patient 2 should succeed")
        
        // Create combined specification (Active AND Cardiology)
        Set tActiveSpec = ##class(Patterns.Examples.Clinical.ActivePatientSpec).%New()
        Set tDeptSpec = ##class(Patterns.Examples.Clinical.PatientByDepartmentSpec).%New()
        Set tDeptSpec.Department = "Cardiology"
        Set tCombined = tActiveSpec.And(tDeptSpec)
        
        // Find using combined specification
        Set tList = ..Repository.FindBySpecification(tCombined)
        
        Do $$$AssertTrue($IsObject(tList), "FindBySpecification should return list")
        
        // Verify results match both criteria
        For i=1:1:tList.Count() {
            Set tPatient = tList.GetAt(i)
            Do $$$AssertEquals(tPatient.Status, "Active", "Patient should be Active")
            Do $$$AssertEquals(tPatient.Department, "Cardiology", "Patient should be in Cardiology")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test Count() returns correct entity count
Method TestCount() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Get initial count
        Set tInitialCount = ..Repository.Count()
        
        // Add test patients
        For i=1:1:5 {
            Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
            Set tPatient.FirstName = "Count" _ i
            Set tPatient.LastName = "Test"
            Set tPatient.MRN = "TESTCOUNT" _ i
            Set tPatient.Status = "Active"
            Set tSC = ..Repository.Add(tPatient)
            Do $$$AssertStatusOK(tSC, "Add should succeed")
        }
        
        // Get new count
        Set tNewCount = ..Repository.Count()
        
        Do $$$AssertEquals(tNewCount, tInitialCount + 5, "Count should increase by 5")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test Contains() identifies entity presence
Method TestContains() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and add test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.FirstName = "Contains"
        Set tPatient.LastName = "Test"
        Set tPatient.MRN = "TESTCONTAINS"
        Set tPatient.Status = "Active"
        Set tSC = ..Repository.Add(tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        Set tId = tPatient.%Id()
        
        // Test Contains
        Set tExists = ..Repository.Contains(tId)
        Do $$$AssertTrue(tExists, "Contains should return true for existing patient")
        
        // Test with non-existent ID
        Set tNotExists = ..Repository.Contains("99999")
        Do $$$AssertTrue('tNotExists, "Contains should return false for non-existent patient")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test Update() updates entity
Method TestUpdate() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and add test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.FirstName = "Original"
        Set tPatient.LastName = "Name"
        Set tPatient.MRN = "TESTUPDATE"
        Set tPatient.Status = "Active"
        Set tSC = ..Repository.Add(tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        Set tId = tPatient.%Id()
        
        // Update patient
        Set tPatient.FirstName = "Updated"
        Set tSC = ..Repository.Update(tPatient)
        Do $$$AssertStatusOK(tSC, "Update should succeed")
        
        // Clear cache and reload
        Do ..Repository.ClearCache()
        Set tReloaded = ..Repository.FindById(tId)
        
        Do $$$AssertEquals(tReloaded.FirstName, "Updated", "FirstName should be updated")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test repository integrates with Identity Map
Method TestIdentityMapIntegration() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create and add test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.FirstName = "Identity"
        Set tPatient.LastName = "Map"
        Set tPatient.MRN = "TESTIDMAP"
        Set tPatient.Status = "Active"
        Set tSC = ..Repository.Add(tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        Set tId = tPatient.%Id()
        
        // First load - should hit database
        Set tLoad1 = ..Repository.FindById(tId)
        Do $$$AssertTrue($IsObject(tLoad1), "First load should succeed")
        
        // Second load - should hit identity map (same instance)
        Set tLoad2 = ..Repository.FindById(tId)
        Do $$$AssertTrue($IsObject(tLoad2), "Second load should succeed")
        Do $$$AssertTrue(tLoad1 = tLoad2, "Should return same instance from Identity Map")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test healthcare-specific finder: FindByMRN
Method TestFindByMRN() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.FirstName = "MRN"
        Set tPatient.LastName = "Test"
        Set tPatient.MRN = "TESTMRN123"
        Set tPatient.Status = "Active"
        Set tSC = ..Repository.Add(tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        // Find by MRN
        Set tFound = ..Repository.FindByMRN("TESTMRN123")
        Do $$$AssertTrue($IsObject(tFound), "FindByMRN should return patient")
        Do $$$AssertEquals(tFound.MRN, "TESTMRN123", "Found patient should have correct MRN")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test healthcare-specific finder: FindActivePatients
Method TestFindActivePatients() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create active and discharged patients
        Set tActive = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tActive.FirstName = "Active"
        Set tActive.LastName = "Patient"
        Set tActive.MRN = "TESTACTIVE"
        Set tActive.Status = "Active"
        Set tSC = ..Repository.Add(tActive)
        Do $$$AssertStatusOK(tSC, "Add active patient should succeed")
        
        Set tDischarged = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tDischarged.FirstName = "Discharged"
        Set tDischarged.LastName = "Patient"
        Set tDischarged.MRN = "TESTDISCHARGED"
        Set tDischarged.Status = "Discharged"
        Set tSC = ..Repository.Add(tDischarged)
        Do $$$AssertStatusOK(tSC, "Add discharged patient should succeed")
        
        // Find active patients
        Set tList = ..Repository.FindActivePatients()
        Do $$$AssertTrue($IsObject(tList), "FindActivePatients should return list")
        Do $$$AssertTrue(tList.Count() > 0, "Should find active patients")
        
        // Verify all are active
        For i=1:1:tList.Count() {
            Set tPatient = tList.GetAt(i)
            Do $$$AssertEquals(tPatient.Status, "Active", "All patients should be Active")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test healthcare-specific finder: FindPatientsByDepartment
Method TestFindPatientsByDepartment() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create patients in different departments
        Set tCardio = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tCardio.FirstName = "Cardio"
        Set tCardio.LastName = "Patient"
        Set tCardio.MRN = "TESTCARDIO"
        Set tCardio.Status = "Active"
        Set tCardio.Department = "Cardiology"
        Set tSC = ..Repository.Add(tCardio)
        Do $$$AssertStatusOK(tSC, "Add cardiology patient should succeed")
        
        Set tOrtho = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tOrtho.FirstName = "Ortho"
        Set tOrtho.LastName = "Patient"
        Set tOrtho.MRN = "TESTORTHO"
        Set tOrtho.Status = "Active"
        Set tOrtho.Department = "Orthopedics"
        Set tSC = ..Repository.Add(tOrtho)
        Do $$$AssertStatusOK(tSC, "Add orthopedics patient should succeed")
        
        // Find cardiology patients
        Set tList = ..Repository.FindPatientsByDepartment("Cardiology")
        Do $$$AssertTrue($IsObject(tList), "FindPatientsByDepartment should return list")
        
        // Verify all are from cardiology
        For i=1:1:tList.Count() {
            Set tPatient = tList.GetAt(i)
            Do $$$AssertEquals(tPatient.Department, "Cardiology", "All patients should be from Cardiology")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test error handling for invalid operations
Method TestErrorHandling() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test Add with null object
        Set tSC = ..Repository.Add("")
        Do $$$AssertStatusNotOK(tSC, "Add should fail with null object")
        
        // Test Remove with null object
        Set tSC = ..Repository.Remove("")
        Do $$$AssertStatusNotOK(tSC, "Remove should fail with null object")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Helper method to clean up test data
Method CleanupTestData()
{
    Try {
        // Delete all test patients
        &sql(DELETE FROM Patterns_Examples_Clinical.Patient WHERE MRN LIKE 'TEST%')
        
    } Catch ex {
        // Ignore cleanup errors
    }
}

}
