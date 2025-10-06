/// Unit tests for Table Data Gateway Pattern
Class Patterns.Test.Unit.PoEAA.DataSource.TableDataGatewayTest Extends %UnitTest.TestCase
{

/// Clear test data before each test
Method OnBeforeOneTest() As %Status
{
    // Clear any existing test patients using %KillExtent for thorough cleanup
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Clear debug global
    Set ^ClineDebug = ""
    
    Quit $$$OK
}

/// Clean up after each test
Method OnAfterOneTest() As %Status
{
    // Clear test data using %KillExtent for thorough cleanup
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    Quit $$$OK
}

/// Test FindAll returns all records
Method TestFindAllReturnsAllRecords() As %Status
{
    // Explicit cleanup to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Arrange - Insert test patients
    Set tPatient1 = {
        "FirstName": "John",
        "LastName": "Smith",
        "Gender": "M",
        "Department": "Cardiology",
        "Status": "Active",
        "MRN": "MRN001"
    }
    Set tPatient2 = {
        "FirstName": "Jane",
        "LastName": "Doe",
        "Gender": "F",
        "Department": "Neurology",
        "Status": "Active",
        "MRN": "MRN002"
    }
    
    Set tId1 = ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient1)
    Set tId2 = ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient2)
    
    // Act
    Set tResults = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindAllPatients()
    
    // Assert
    Do $$$AssertEquals(tResults.Count(), 2, "Should return 2 patients")
    
    Quit $$$OK
}

/// Test FindAll returns empty list for empty table
Method TestFindAllReturnsEmptyListForEmptyTable() As %Status
{
    // Explicit cleanup to ensure empty table
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Act
    Set tResults = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindAllPatients()
    
    // Assert
    Do $$$AssertEquals(tResults.Count(), 0, "Should return empty list")
    
    Quit $$$OK
}

/// Test FindById returns correct record
Method TestFindByIdReturnsCorrectRecord() As %Status
{
    // Arrange
    Set tPatient = {
        "FirstName": "John",
        "LastName": "Smith",
        "Gender": "M",
        "Department": "Cardiology",
        "Status": "Active",
        "MRN": "MRN001"
    }
    Set tId = ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient)
    
    // Act
    Set tResult = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientById(tId)
    
    // Assert
    Do $$$AssertTrue($IsObject(tResult), "Should return an object")
    Do $$$AssertEquals(tResult.FirstName, "John", "FirstName should match")
    Do $$$AssertEquals(tResult.LastName, "Smith", "LastName should match")
    Do $$$AssertEquals(tResult.MRN, "MRN001", "MRN should match")
    
    Quit $$$OK
}

/// Test FindById with non-existent ID returns empty string
Method TestFindByIdWithNonExistentIdReturnsEmpty() As %Status
{
    // Act
    Set tResult = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientById("999999")
    
    // Assert
    Do $$$AssertEquals(tResult, "", "Should return empty string for non-existent ID")
    
    Quit $$$OK
}

/// Test Insert creates new record and returns ID
Method TestInsertCreatesNewRecordAndReturnsId() As %Status
{
    // Arrange
    Set tPatient = {
        "FirstName": "Alice",
        "LastName": "Johnson",
        "Gender": "F",
        "Department": "Oncology",
        "Status": "Active",
        "MRN": "MRN003"
    }
    
    // Act
    Set tId = ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient)
    
    // Assert
    Do $$$AssertTrue(tId '= "", "Should return non-empty ID")
    
    // Verify record was created
    Set tFound = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientById(tId)
    Do $$$AssertTrue($IsObject(tFound), "Record should exist in database")
    Do $$$AssertEquals(tFound.FirstName, "Alice", "FirstName should match")
    
    Quit $$$OK
}

/// Test Update modifies existing record
Method TestUpdateModifiesExistingRecord() As %Status
{
    // Arrange - Create patient
    Set tPatient = {
        "FirstName": "Bob",
        "LastName": "Williams",
        "Gender": "M",
        "Department": "Orthopedics",
        "Status": "Active",
        "MRN": "MRN004"
    }
    Set tId = ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient)
    
    // Act - Update the patient
    Set tUpdateData = {
        "Status": "Discharged",
        "Department": "Recovery"
    }
    Set tSC = ##class(Patterns.Examples.Clinical.PatientDataGateway).UpdatePatient(tId, tUpdateData)
    
    // Assert
    Do $$$AssertStatusOK(tSC, "Update should succeed")
    
    // Verify changes
    Set tUpdated = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientById(tId)
    Do $$$AssertEquals(tUpdated.Status, "Discharged", "Status should be updated")
    Do $$$AssertEquals(tUpdated.Department, "Recovery", "Department should be updated")
    Do $$$AssertEquals(tUpdated.FirstName, "Bob", "FirstName should remain unchanged")
    
    Quit $$$OK
}

/// Test Delete removes record
Method TestDeleteRemovesRecord() As %Status
{
    // Arrange - Create patient
    Set tPatient = {
        "FirstName": "Charlie",
        "LastName": "Brown",
        "Gender": "M",
        "Department": "Pediatrics",
        "Status": "Active",
        "MRN": "MRN005"
    }
    Set tId = ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient)
    
    // Verify exists
    Set tBefore = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientById(tId)
    Do $$$AssertTrue($IsObject(tBefore), "Patient should exist before delete")
    
    // Act - Delete
    Set tSC = ##class(Patterns.Examples.Clinical.PatientDataGateway).DeletePatient(tId)
    
    // Assert
    Do $$$AssertStatusOK(tSC, "Delete should succeed")
    
    // Verify deleted
    Set tAfter = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientById(tId)
    Do $$$AssertEquals(tAfter, "", "Patient should not exist after delete")
    
    Quit $$$OK
}

/// Test FindPatientsByLastName returns matching records
Method TestFindPatientsByLastNameReturnsMatches() As %Status
{
    // Explicit cleanup to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Arrange - Insert patients with same last name
    Set tPatient1 = {
        "FirstName": "John",
        "LastName": "Smith",
        "Gender": "M",
        "Department": "Cardiology",
        "Status": "Active",
        "MRN": "MRN006"
    }
    Set tPatient2 = {
        "FirstName": "Jane",
        "LastName": "Smith",
        "Gender": "F",
        "Department": "Neurology",
        "Status": "Active",
        "MRN": "MRN007"
    }
    Set tPatient3 = {
        "FirstName": "Bob",
        "LastName": "Jones",
        "Gender": "M",
        "Department": "Cardiology",
        "Status": "Active",
        "MRN": "MRN008"
    }
    
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient1)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient2)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient3)
    
    // Act
    Set tResults = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientsByLastName("Smith")
    
    // Assert
    Do $$$AssertEquals(tResults.Count(), 2, "Should return 2 Smiths")
    
    Quit $$$OK
}

/// Test FindPatientsByDepartment returns matching records
Method TestFindPatientsByDepartmentReturnsMatches() As %Status
{
    // Explicit cleanup to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Arrange
    Set tPatient1 = {
        "FirstName": "Alice",
        "LastName": "Cooper",
        "Gender": "F",
        "Department": "Cardiology",
        "Status": "Active",
        "MRN": "MRN009"
    }
    Set tPatient2 = {
        "FirstName": "David",
        "LastName": "Lee",
        "Gender": "M",
        "Department": "Cardiology",
        "Status": "Active",
        "MRN": "MRN010"
    }
    
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient1)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient2)
    
    // Act
    Set tResults = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientsByDepartment("Cardiology")
    
    // Assert
    Do $$$AssertEquals(tResults.Count(), 2, "Should return 2 Cardiology patients")
    
    Quit $$$OK
}

/// Test FindPatientByMRN returns correct patient
Method TestFindPatientByMRNReturnsCorrectPatient() As %Status
{
    // Arrange
    Set tPatient = {
        "FirstName": "Emily",
        "LastName": "Davis",
        "Gender": "F",
        "Department": "Radiology",
        "Status": "Active",
        "MRN": "MRN011"
    }
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient)
    
    // Act
    Set tResult = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientByMRN("MRN011")
    
    // Assert
    Do $$$AssertTrue($IsObject(tResult), "Should return an object")
    Do $$$AssertEquals(tResult.FirstName, "Emily", "FirstName should match")
    Do $$$AssertEquals(tResult.MRN, "MRN011", "MRN should match")
    
    Quit $$$OK
}

/// Test GetPatientCount returns correct count
Method TestGetPatientCountReturnsCorrectCount() As %Status
{
    // Explicit cleanup to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Arrange - Insert 3 patients
    Set tPatient1 = {"FirstName": "P1", "LastName": "L1", "MRN": "MRN012", "Status": "Active", "Department": "D1"}
    Set tPatient2 = {"FirstName": "P2", "LastName": "L2", "MRN": "MRN013", "Status": "Active", "Department": "D1"}
    Set tPatient3 = {"FirstName": "P3", "LastName": "L3", "MRN": "MRN014", "Status": "Active", "Department": "D2"}
    
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient1)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient2)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient3)
    
    // Act
    Set tCount = ##class(Patterns.Examples.Clinical.PatientDataGateway).GetPatientCount()
    
    // Assert
    Do $$$AssertEquals(tCount, 3, "Should return count of 3")
    
    Quit $$$OK
}

/// Test GetPatientCountByDepartment returns correct count
Method TestGetPatientCountByDepartmentReturnsCorrectCount() As %Status
{
    // Explicit cleanup to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Arrange - Insert patients in different departments
    Set tPatient1 = {"FirstName": "P1", "LastName": "L1", "MRN": "MRN015", "Status": "Active", "Department": "Cardiology"}
    Set tPatient2 = {"FirstName": "P2", "LastName": "L2", "MRN": "MRN016", "Status": "Active", "Department": "Cardiology"}
    Set tPatient3 = {"FirstName": "P3", "LastName": "L3", "MRN": "MRN017", "Status": "Active", "Department": "Neurology"}
    
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient1)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient2)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient3)
    
    // Act
    Set tCount = ##class(Patterns.Examples.Clinical.PatientDataGateway).GetPatientCountByDepartment("Cardiology")
    
    // Assert
    Do $$$AssertEquals(tCount, 2, "Should return count of 2 for Cardiology")
    
    Quit $$$OK
}

/// Test GetPatientCountByStatus returns correct count
Method TestGetPatientCountByStatusReturnsCorrectCount() As %Status
{
    // Explicit cleanup to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Arrange
    Set tPatient1 = {"FirstName": "P1", "LastName": "L1", "MRN": "MRN018", "Status": "Active", "Department": "D1"}
    Set tPatient2 = {"FirstName": "P2", "LastName": "L2", "MRN": "MRN019", "Status": "Discharged", "Department": "D1"}
    Set tPatient3 = {"FirstName": "P3", "LastName": "L3", "MRN": "MRN020", "Status": "Active", "Department": "D2"}
    
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient1)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient2)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient3)
    
    // Act
    Set tCount = ##class(Patterns.Examples.Clinical.PatientDataGateway).GetPatientCountByStatus("Active")
    
    // Assert
    Do $$$AssertEquals(tCount, 2, "Should return count of 2 for Active status")
    
    Quit $$$OK
}

/// Test parameterized queries prevent SQL injection
Method TestParameterizedQueriesPreventSQLInjection() As %Status
{
    // Arrange - Insert normal patient
    Set tPatient = {"FirstName": "Normal", "LastName": "Patient", "MRN": "MRN021", "Status": "Active", "Department": "Cardiology"}
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient)
    
    // Act - Try SQL injection in last name search
    Set tMaliciousInput = "Smith' OR '1'='1"
    Set tResults = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientsByLastName(tMaliciousInput)
    
    // Assert - Should not return all records (SQL injection blocked)
    Do $$$AssertEquals(tResults.Count(), 0, "SQL injection attempt should return no results")
    
    Quit $$$OK
}

/// Test result set to object mapping accuracy
Method TestResultSetToObjectMappingAccuracy() As %Status
{
    // Arrange
    Set tPatient = {
        "FirstName": "TestFirst",
        "LastName": "TestLast",
        "Gender": "F",
        "Department": "TestDept",
        "Status": "Active",
        "MRN": "MRN022"
    }
    Set tId = ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient)
    
    // Act
    Set tResult = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientById(tId)
    
    // Assert - Verify all fields mapped correctly
    Do $$$AssertTrue($IsObject(tResult), "Should return object")
    Do $$$AssertEquals(tResult.FirstName, "TestFirst", "FirstName mapping")
    Do $$$AssertEquals(tResult.LastName, "TestLast", "LastName mapping")
    Do $$$AssertEquals(tResult.Gender, "F", "Gender mapping")
    Do $$$AssertEquals(tResult.Department, "TestDept", "Department mapping")
    Do $$$AssertEquals(tResult.Status, "Active", "Status mapping")
    Do $$$AssertEquals(tResult.MRN, "MRN022", "MRN mapping")
    
    Quit $$$OK
}

/// Test FindPatientsByStatus returns correct results
Method TestFindPatientsByStatusReturnsCorrectResults() As %Status
{
    // Explicit cleanup to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Arrange
    Set tPatient1 = {"FirstName": "Active1", "LastName": "Test", "MRN": "MRN023", "Status": "Active", "Department": "D1"}
    Set tPatient2 = {"FirstName": "Discharged1", "LastName": "Test", "MRN": "MRN024", "Status": "Discharged", "Department": "D1"}
    Set tPatient3 = {"FirstName": "Active2", "LastName": "Test", "MRN": "MRN025", "Status": "Active", "Department": "D2"}
    
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient1)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient2)
    Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient3)
    
    // Act
    Set tResults = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientsByStatus("Active")
    
    // Assert
    Do $$$AssertEquals(tResults.Count(), 2, "Should return 2 Active patients")
    
    Quit $$$OK
}

}
