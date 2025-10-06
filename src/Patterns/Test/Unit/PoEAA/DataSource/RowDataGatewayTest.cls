/// Unit tests for Row Data Gateway Pattern
Class Patterns.Test.Unit.PoEAA.DataSource.RowDataGatewayTest Extends %UnitTest.TestCase
{

/// Clear test data before each test
Method OnBeforeOneTest() As %Status
{
    // Clear any existing test patients using %DeleteExtent for thorough cleanup
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

/// Test Save() on new instance performs INSERT
Method TestSaveNewInstanceInserts() As %Status
{
    // Create new gateway instance
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    
    // Set properties
    Set tGateway.FirstName = "Jane"
    Set tGateway.LastName = "Smith"
    Set tGateway.MRN = "MRN002"
    Set tGateway.Gender = "F"
    Set tGateway.Status = "Active"
    
    // Verify it's new
    Do $$$AssertTrue(tGateway.IsNew(), "Gateway is new before save")
    
    // Save gateway
    Do $$$AssertStatusOK(tGateway.Save(), "Save new gateway")
    
    // Verify INSERT occurred
    Do $$$AssertTrue('tGateway.IsNew(), "Gateway is not new after save")
    Do $$$AssertTrue(tGateway.Id '= "", "ID was generated")
    
    // Verify data persisted using FindById
    Set tFound = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tGateway.Id)
    Do $$$AssertTrue($IsObject(tFound), "Patient persisted")
    Do $$$AssertEquals(tFound.FirstName, "Jane", "FirstName persisted")
    Do $$$AssertEquals(tFound.MRN, "MRN002", "MRN persisted")
    
    Quit $$$OK
}

/// Test Save() on existing instance performs UPDATE
Method TestSaveExistingInstanceUpdates() As %Status
{
    // Create test patient
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway.FirstName = "Bob"
    Set tGateway.LastName = "Johnson"
    Set tGateway.MRN = "MRN003"
    Set tGateway.Status = "Active"
    Do $$$AssertStatusOK(tGateway.Save(), "Save test patient")
    Set tId = tGateway.Id
    
    // Load gateway
    Set tGateway2 = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
    
    // Modify properties
    Set tGateway2.FirstName = "Robert"
    Set tGateway2.Status = "Discharged"
    
    // Save changes
    Do $$$AssertStatusOK(tGateway2.Save(), "Save updated gateway")
    
    // Verify UPDATE occurred using FindById
    Set tUpdated = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
    Do $$$AssertTrue($IsObject(tUpdated), "Patient reloaded")
    Do $$$AssertEquals(tUpdated.FirstName, "Robert", "FirstName updated")
    Do $$$AssertEquals(tUpdated.Status, "Discharged", "Status updated")
    Do $$$AssertEquals(tUpdated.LastName, "Johnson", "LastName unchanged")
    
    Quit $$$OK
}

/// Test Delete() removes row from database
Method TestDeleteRemovesRow() As %Status
{
    // Explicit cleanup to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Create test patient
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway.FirstName = "Alice"
    Set tGateway.LastName = "Williams"
    Set tGateway.MRN = "MRN004"
    Do $$$AssertStatusOK(tGateway.Save(), "Save test patient")
    Set tId = tGateway.Id
    
    // Delete patient
    Do $$$AssertStatusOK(tGateway.Delete(), "Delete gateway")
    
    // Verify deletion using FindById
    Set tFound = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
    Do $$$AssertEquals(tFound, "", "Patient was deleted")
    
    Quit $$$OK
}

/// Test FindById() returns gateway instance
Method TestFindByIdReturnsGateway() As %Status
{
    // Create test patient
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway.FirstName = "Frank"
    Set tGateway.LastName = "Wilson"
    Set tGateway.MRN = "MRN008"
    Do $$$AssertStatusOK(tGateway.Save(), "Save test patient")
    Set tId = tGateway.Id
    
    // Find by ID
    Set tFound = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
    
    // Verify gateway returned
    Do $$$AssertTrue($IsObject(tFound), "Gateway found")
    Do $$$AssertEquals(tFound.FirstName, "Frank", "Correct patient loaded")
    Do $$$AssertEquals(tFound.Id, tId, "ID matches")
    
    Quit $$$OK
}

/// Test FindById() with invalid ID returns empty
Method TestFindByIdInvalidReturnsEmpty() As %Status
{
    // Find by non-existent ID
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById("999999")
    
    // Verify empty returned
    Do $$$AssertEquals(tGateway, "", "Empty string returned for invalid ID")
    
    Quit $$$OK
}

/// Test FindByMRN() healthcare-specific finder
Method TestFindByMRN() As %Status
{
    // Create test patient
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway.FirstName = "Grace"
    Set tGateway.LastName = "Moore"
    Set tGateway.MRN = "MRN009"
    Do $$$AssertStatusOK(tGateway.Save(), "Save test patient")
    
    // Find by MRN
    Set tFound = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindByMRN("MRN009")
    
    // Verify gateway returned
    Do $$$AssertTrue($IsObject(tFound), "Gateway found by MRN")
    Do $$$AssertEquals(tFound.FirstName, "Grace", "Correct patient loaded")
    Do $$$AssertEquals(tFound.MRN, "MRN009", "MRN matches")
    
    Quit $$$OK
}

/// Test FindByLastName() returns list of gateways
Method TestFindByLastName() As %Status
{
    // Create multiple test patients with same last name
    Set tGateway1 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway1.FirstName = "Henry"
    Set tGateway1.LastName = "Taylor"
    Set tGateway1.MRN = "MRN010"
    Do $$$AssertStatusOK(tGateway1.Save(), "Save patient 1")
    
    Set tGateway2 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway2.FirstName = "Ivy"
    Set tGateway2.LastName = "Taylor"
    Set tGateway2.MRN = "MRN011"
    Do $$$AssertStatusOK(tGateway2.Save(), "Save patient 2")
    
    // Find by last name
    Set tList = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindByLastName("Taylor")
    
    // Verify list returned
    Do $$$AssertTrue($IsObject(tList), "List object returned")
    Do $$$AssertEquals(tList.Count(), 2, "Two patients found")
    
    // Verify gateways in list
    Set tFirst = tList.GetAt(1)
    Do $$$AssertTrue($IsObject(tFirst), "First gateway is object")
    Do $$$AssertEquals(tFirst.LastName, "Taylor", "First gateway has correct last name")
    
    Quit $$$OK
}

/// Test FindAll() returns all patients
Method TestFindAllReturnsAllPatients() As %Status
{
    // Explicit cleanup at start to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Create multiple test patients
    Set tGateway1 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway1.FirstName = "Karen"
    Set tGateway1.LastName = "Thomas"
    Set tGateway1.MRN = "MRN013"
    Do $$$AssertStatusOK(tGateway1.Save(), "Save patient 1")
    
    Set tGateway2 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway2.FirstName = "Larry"
    Set tGateway2.LastName = "Jackson"
    Set tGateway2.MRN = "MRN014"
    Do $$$AssertStatusOK(tGateway2.Save(), "Save patient 2")
    
    Set tGateway3 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway3.FirstName = "Mary"
    Set tGateway3.LastName = "White"
    Set tGateway3.MRN = "MRN015"
    Do $$$AssertStatusOK(tGateway3.Save(), "Save patient 3")
    
    // Find all
    Set tList = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindAll()
    
    // Verify all patients returned
    Do $$$AssertTrue($IsObject(tList), "List object returned")
    Do $$$AssertEquals(tList.Count(), 3, "All three patients found")
    
    Quit $$$OK
}

/// Test IsNew() correctly identifies new vs existing
Method TestIsNewIdentifiesState() As %Status
{
    // Test new gateway
    Set tNewGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Do $$$AssertTrue(tNewGateway.IsNew(), "New gateway identified")
    
    // Create and save patient
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway.FirstName = "David"
    Set tGateway.LastName = "Miller"
    Set tGateway.MRN = "MRN006"
    Do $$$AssertStatusOK(tGateway.Save(), "Save test patient")
    Set tId = tGateway.Id
    
    // Test existing gateway
    Set tExistingGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
    Do $$$AssertTrue('tExistingGateway.IsNew(), "Existing gateway identified")
    
    Quit $$$OK
}

/// Test IsDirty() tracks property changes
Method TestIsDirtyTracksChanges() As %Status
{
    // Create and save patient
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway.FirstName = "Eve"
    Set tGateway.LastName = "Davis"
    Set tGateway.MRN = "MRN007"
    Do $$$AssertStatusOK(tGateway.Save(), "Save test patient")
    Set tId = tGateway.Id
    
    // Load gateway
    Set tGateway2 = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
    Do $$$AssertTrue('tGateway2.IsDirty(), "Gateway not dirty after load")
    
    // Modify property
    Set tGateway2.FirstName = "Eva"
    Do $$$AssertTrue(tGateway2.IsDirty(), "Gateway dirty after change")
    
    // Save and verify clean
    Do tGateway2.Save()
    Do $$$AssertTrue('tGateway2.IsDirty(), "Gateway not dirty after save")
    
    Quit $$$OK
}

/// Test Refresh() reloads current data
Method TestRefreshReloadsData() As %Status
{
    // Create test patient
    Set tGateway1 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway1.FirstName = "Charlie"
    Set tGateway1.LastName = "Brown"
    Set tGateway1.MRN = "MRN005"
    Set tGateway1.Status = "Active"
    Do $$$AssertStatusOK(tGateway1.Save(), "Save test patient")
    Set tId = tGateway1.Id
    
    // Load second gateway
    Set tGateway2 = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
    Do $$$AssertEquals(tGateway2.Status, "Active", "Initial status")
    
    // Modify via first gateway
    Set tGateway1.Status = "Discharged"
    Do tGateway1.Save()
    
    // Refresh second gateway
    Do $$$AssertStatusOK(tGateway2.Refresh(), "Refresh gateway")
    
    // Verify data reloaded
    Do $$$AssertEquals(tGateway2.Status, "Discharged", "Status refreshed")
    
    Quit $$$OK
}

/// Test property accessors set and get values
Method TestPropertyAccessors() As %Status
{
    // Create gateway
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    
    // Test FirstName
    Set tGateway.FirstName = "Test"
    Do $$$AssertEquals(tGateway.FirstName, "Test", "FirstName accessor")
    
    // Test LastName
    Set tGateway.LastName = "User"
    Do $$$AssertEquals(tGateway.LastName, "User", "LastName accessor")
    
    // Test MRN
    Set tGateway.MRN = "MRN999"
    Do $$$AssertEquals(tGateway.MRN, "MRN999", "MRN accessor")
    
    // Test Gender
    Set tGateway.Gender = "M"
    Do $$$AssertEquals(tGateway.Gender, "M", "Gender accessor")
    
    // Test Department
    Set tGateway.Department = "Cardiology"
    Do $$$AssertEquals(tGateway.Department, "Cardiology", "Department accessor")
    
    // Test Status
    Set tGateway.Status = "Active"
    Do $$$AssertEquals(tGateway.Status, "Active", "Status accessor")
    
    Quit $$$OK
}

/// Test Delete() on new instance does nothing
Method TestDeleteNewInstanceNoOp() As %Status
{
    // Create new gateway without saving
    Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway.FirstName = "Test"
    Set tGateway.LastName = "User"
    Set tGateway.MRN = "MRN999"
    
    // Attempt to delete
    Do $$$AssertStatusOK(tGateway.Delete(), "Delete new gateway succeeds")
    
    Quit $$$OK
}

/// Test concurrency with multiple gateway instances
Method TestConcurrencyMultipleInstances() As %Status
{
    // Explicit cleanup to ensure clean state
    Do ##class(Patterns.Examples.Clinical.Patient).%KillExtent()
    
    // Create test patient
    Set tGateway1 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
    Set tGateway1.FirstName = "Jack"
    Set tGateway1.LastName = "Anderson"
    Set tGateway1.MRN = "MRN012"
    Set tGateway1.Status = "Active"
    Do $$$AssertStatusOK(tGateway1.Save(), "Save test patient")
    Set tId = tGateway1.Id
    
    // Create two gateway instances for same patient
    Set tGateway2 = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
    Set tGateway3 = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
    
    // Modify first gateway
    Set tGateway2.Status = "Discharged"
    Do tGateway2.Save()
    
    // Verify third gateway has stale data
    Do $$$AssertEquals(tGateway3.Status, "Active", "Gateway3 has stale data")
    
    // Refresh third gateway
    Do tGateway3.Refresh()
    Do $$$AssertEquals(tGateway3.Status, "Discharged", "Gateway3 refreshed")
    
    Quit $$$OK
}

}
