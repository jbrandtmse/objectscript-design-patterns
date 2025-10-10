/// Unit Tests for Data Mapper Pattern
/// 
/// Comprehensive test coverage for Data Mapper pattern implementation
/// Tests mapping operations, Identity Map, domain/persistence separation
/// 
/// @see Patterns.PoEAA.DataSource.DataMapper
/// @see Patterns.Examples.Clinical.ClinicalEncounterMapper
/// @since 1.0.0
Class Patterns.Test.Unit.PoEAA.DataSource.DataMapperTest Extends %UnitTest.TestCase
{

/// Setup before each test
Method OnBeforeOneTest() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clean up any existing test data
        &sql(DELETE FROM Patterns_Examples_Clinical.ClinicalEncounterTable WHERE PatientMRN LIKE 'TEST%')
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Cleanup after each test
Method OnAfterOneTest() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clean up test data
        &sql(DELETE FROM Patterns_Examples_Clinical.ClinicalEncounterTable WHERE PatientMRN LIKE 'TEST%')
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test Insert creates new database row from domain object
Method TestInsertCreatesNewRow() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange
    Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEncounter.PatientMRN = "TEST001"
    Set tEncounter.ProviderName = "Dr. Smith"
    Set tEncounter.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEncounter.EncounterType = "Outpatient"
    Set tEncounter.ChiefComplaint = "Headache"
    Set tEncounter.Diagnosis = "Migraine"
    Set tEncounter.TreatmentPlan = "Pain management"
    
    // Act
    Set tSC = tMapper.Insert(tEncounter)
    
    // Assert
    Do $$$AssertStatusOK(tSC, "Insert should succeed")
    Do $$$AssertTrue(tEncounter.EncounterId '= "", "EncounterId should be set after insert")
    
    // Verify in database
    Set tId = tEncounter.EncounterId
    &sql(SELECT PatientMRN INTO :tMRN FROM Patterns_Examples_Clinical.ClinicalEncounterTable WHERE ID = :tId)
    Do $$$AssertEquals(tMRN, "TEST001", "Database row should exist with correct MRN")
    
    Quit $$$OK
}

/// Test Update modifies existing row from domain object changes
Method TestUpdateModifiesExistingRow() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange - create initial encounter
    Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEncounter.PatientMRN = "TEST002"
    Set tEncounter.ProviderName = "Dr. Jones"
    Set tEncounter.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEncounter.EncounterType = "Emergency"
    Set tEncounter.ChiefComplaint = "Chest pain"
    Set tEncounter.Diagnosis = "Initial diagnosis"
    Set tEncounter.TreatmentPlan = "Initial plan"
    
    Set tSC = tMapper.Insert(tEncounter)
    Do $$$AssertStatusOK(tSC, "Insert should succeed")
    
    // Act - update the encounter
    Set tEncounter.Diagnosis = "Updated diagnosis"
    Set tEncounter.TreatmentPlan = "Updated treatment plan"
    Set tSC = tMapper.Update(tEncounter)
    
    // Assert
    Do $$$AssertStatusOK(tSC, "Update should succeed")
    
    // Verify in database
    Set tId = tEncounter.EncounterId
    &sql(SELECT Diagnosis, TreatmentPlan INTO :tDiag, :tPlan 
         FROM Patterns_Examples_Clinical.ClinicalEncounterTable WHERE ID = :tId)
    Do $$$AssertEquals(tDiag, "Updated diagnosis", "Diagnosis should be updated in database")
    Do $$$AssertEquals(tPlan, "Updated treatment plan", "Treatment plan should be updated in database")
    
    Quit $$$OK
}

/// Test Delete removes row from database
Method TestDeleteRemovesRow() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange
    Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEncounter.PatientMRN = "TEST003"
    Set tEncounter.ProviderName = "Dr. Williams"
    Set tEncounter.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEncounter.EncounterType = "Inpatient"
    Set tEncounter.ChiefComplaint = "Surgery"
    Set tEncounter.Diagnosis = "Appendicitis"
    Set tEncounter.TreatmentPlan = "Appendectomy"
    
    Set tSC = tMapper.Insert(tEncounter)
    Do $$$AssertStatusOK(tSC, "Insert should succeed")
    Set tId = tEncounter.EncounterId
    
    // Act
    Set tSC = tMapper.Delete(tEncounter)
    
    // Assert
    Do $$$AssertStatusOK(tSC, "Delete should succeed")
    
    // Verify row is deleted
    &sql(SELECT COUNT(*) INTO :tCount FROM Patterns_Examples_Clinical.ClinicalEncounterTable WHERE ID = :tId)
    Do $$$AssertEquals(tCount, 0, "Row should be deleted from database")
    
    Quit $$$OK
}

/// Test Find returns correct domain object
Method TestFindReturnsCorrectDomainObject() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange
    Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEncounter.PatientMRN = "TEST004"
    Set tEncounter.ProviderName = "Dr. Brown"
    Set tEncounter.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEncounter.EncounterType = "Outpatient"
    Set tEncounter.ChiefComplaint = "Follow-up"
    Set tEncounter.Diagnosis = "Recovery"
    Set tEncounter.TreatmentPlan = "Continue medication"
    
    Set tSC = tMapper.Insert(tEncounter)
    Do $$$AssertStatusOK(tSC, "Insert should succeed")
    Set tId = tEncounter.EncounterId
    
    // Act
    Set tFound = tMapper.Find(tId)
    
    // Assert
    Do $$$AssertTrue($IsObject(tFound), "Find should return object")
    Do $$$AssertEquals(tFound.EncounterId, tId, "EncounterId should match")
    Do $$$AssertEquals(tFound.PatientMRN, "TEST004", "PatientMRN should match")
    Do $$$AssertEquals(tFound.ProviderName, "Dr. Brown", "ProviderName should match")
    Do $$$AssertEquals(tFound.Diagnosis, "Recovery", "Diagnosis should match")
    
    Quit $$$OK
}

/// Test Find returns same object instance from Identity Map
Method TestFindReturnsSameInstanceFromIdentityMap() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange
    Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEncounter.PatientMRN = "TEST005"
    Set tEncounter.ProviderName = "Dr. Davis"
    Set tEncounter.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEncounter.EncounterType = "Emergency"
    Set tEncounter.ChiefComplaint = "Accident"
    Set tEncounter.Diagnosis = "Fracture"
    Set tEncounter.TreatmentPlan = "Cast"
    
    Set tSC = tMapper.Insert(tEncounter)
    Do $$$AssertStatusOK(tSC, "Insert should succeed")
    Set tId = tEncounter.EncounterId
    
    // Act - find same object twice
    Set tFound1 = tMapper.Find(tId)
    Set tFound2 = tMapper.Find(tId)
    
    // Assert - should be same object instance
    Do $$$AssertTrue(tFound1 = tFound2, "Identity Map should return same object instance")
    
    Quit $$$OK
}

/// Test FindAll returns list of domain objects
Method TestFindAllReturnsListOfDomainObjects() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange - insert multiple encounters
    Set tEnc1 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEnc1.PatientMRN = "TEST006A"
    Set tEnc1.ProviderName = "Dr. Miller"
    Set tEnc1.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEnc1.EncounterType = "Outpatient"
    Do tMapper.Insert(tEnc1)
    
    Set tEnc2 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEnc2.PatientMRN = "TEST006B"
    Set tEnc2.ProviderName = "Dr. Wilson"
    Set tEnc2.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEnc2.EncounterType = "Inpatient"
    Do tMapper.Insert(tEnc2)
    
    // Act
    Set tList = tMapper.FindAll()
    
    // Assert
    Do $$$AssertTrue($IsObject(tList), "FindAll should return list")
    Do $$$AssertTrue(tList.Count() >= 2, "FindAll should return at least 2 encounters")
    
    Quit $$$OK
}

/// Test FindByPatientMRN returns correct encounters
Method TestFindByPatientMRNReturnsCorrectEncounters() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange - create multiple encounters for same patient
    Set tMRN = "TEST007"
    
    Set tEnc1 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEnc1.PatientMRN = tMRN
    Set tEnc1.ProviderName = "Dr. Taylor"
    Set tEnc1.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEnc1.EncounterType = "Outpatient"
    Do tMapper.Insert(tEnc1)
    
    Set tEnc2 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEnc2.PatientMRN = tMRN
    Set tEnc2.ProviderName = "Dr. Anderson"
    Set tEnc2.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEnc2.EncounterType = "Follow-up"
    Do tMapper.Insert(tEnc2)
    
    // Act
    Set tList = tMapper.FindByPatientMRN(tMRN)
    
    // Assert
    Do $$$AssertTrue($IsObject(tList), "FindByPatientMRN should return list")
    Do $$$AssertEquals(tList.Count(), 2, "Should find 2 encounters for patient")
    
    // Verify all encounters have correct MRN
    For i=1:1:tList.Count() {
        Set tEnc = tList.GetAt(i)
        Do $$$AssertEquals(tEnc.PatientMRN, tMRN, "All encounters should have correct MRN")
    }
    
    Quit $$$OK
}

/// Test FindByDateRange returns correct encounters
Method TestFindByDateRangeReturnsCorrectEncounters() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange
    Set tStartDate = $ZDateTime($Horolog, 3)
    Set tEndDate = $ZDateTime($Horolog + 7, 3)
    
    Set tEnc = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEnc.PatientMRN = "TEST008"
    Set tEnc.ProviderName = "Dr. Thomas"
    Set tEnc.EncounterDate = tStartDate
    Set tEnc.EncounterType = "Outpatient"
    Do tMapper.Insert(tEnc)
    
    // Act
    Set tList = tMapper.FindByDateRange(tStartDate, tEndDate)
    
    // Assert
    Do $$$AssertTrue($IsObject(tList), "FindByDateRange should return list")
    Do $$$AssertTrue(tList.Count() >= 1, "Should find at least 1 encounter in range")
    
    Quit $$$OK
}

/// Test MapToDomain correctly populates domain object
Method TestMapToDomainCorrectlyPopulatesDomainObject() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange
    Set tData = {}
    Set tData.PatientMRN = "TEST009"
    Set tData.ProviderName = "Dr. Jackson"
    Set tData.EncounterDate = $ZDateTime($Horolog, 3)
    Set tData.EncounterType = "Emergency"
    Set tData.ChiefComplaint = "Test complaint"
    Set tData.Diagnosis = "Test diagnosis"
    Set tData.TreatmentPlan = "Test plan"
    
    // Act
    Set tDomain = tMapper.MapToDomain("123", tData)
    
    // Assert
    Do $$$AssertTrue($IsObject(tDomain), "MapToDomain should return object")
    Do $$$AssertEquals(tDomain.EncounterId, "123", "EncounterId should be set")
    Do $$$AssertEquals(tDomain.PatientMRN, "TEST009", "PatientMRN should be mapped")
    Do $$$AssertEquals(tDomain.ProviderName, "Dr. Jackson", "ProviderName should be mapped")
    Do $$$AssertEquals(tDomain.EncounterType, "Emergency", "EncounterType should be mapped")
    
    Quit $$$OK
}

/// Test MapToDatabase extracts data for SQL
Method TestMapToDatabaseExtractsDataForSQL() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange
    Set tDomain = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tDomain.PatientMRN = "TEST010"
    Set tDomain.ProviderName = "Dr. White"
    Set tDomain.EncounterDate = $ZDateTime($Horolog, 3)
    Set tDomain.EncounterType = "Inpatient"
    Set tDomain.ChiefComplaint = "Surgery prep"
    Set tDomain.Diagnosis = "Pre-op"
    Set tDomain.TreatmentPlan = "Surgery scheduled"
    
    // Act
    Set tData = tMapper.MapToDatabase(tDomain)
    
    // Assert
    Do $$$AssertTrue($IsObject(tData), "MapToDatabase should return object")
    Do $$$AssertEquals(tData.PatientMRN, "TEST010", "PatientMRN should be extracted")
    Do $$$AssertEquals(tData.ProviderName, "Dr. White", "ProviderName should be extracted")
    Do $$$AssertEquals(tData.EncounterType, "Inpatient", "EncounterType should be extracted")
    Do $$$AssertEquals(tData.Diagnosis, "Pre-op", "Diagnosis should be extracted")
    
    Quit $$$OK
}

/// Test domain object has no database dependencies
Method TestDomainObjectHasNoDatabaseDependencies() As %Status
{
    // Arrange & Act
    Set tDomain = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tDomain.PatientMRN = "TEST011"
    Set tDomain.ProviderName = "Dr. Harris"
    Set tDomain.EncounterDate = $ZDateTime($Horolog, 3)
    Set tDomain.EncounterType = "Outpatient"
    Set tDomain.ChiefComplaint = "Chronic pain"
    Set tDomain.Diagnosis = "Arthritis"
    Set tDomain.TreatmentPlan = "Physical therapy with follow-up"
    
    // Assert - verify domain object business logic works without database
    Set tSC = tDomain.ValidateEncounter()
    Do $$$AssertStatusOK(tSC, "Domain validation should work without database")
    
    Set tBillingCode = tDomain.CalculateBillingCode()
    Do $$$AssertEquals(tBillingCode, "OP-99214", "Business logic should work without database")
    
    Set tRequiresFollowUp = tDomain.RequiresFollowUp()
    Do $$$AssertTrue(tRequiresFollowUp = 1, "Business logic should detect follow-up need")
    
    Set tSummary = tDomain.GetSummary()
    Do $$$AssertTrue(tSummary [ "TEST011", "Summary should be generated without database")
    
    Quit $$$OK
}

/// Test mapper handles null and missing values
Method TestMapperHandlesNullAndMissingValues() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange - create encounter with minimal data
    Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    Set tEncounter.PatientMRN = "TEST012"
    Set tEncounter.ProviderName = "Dr. Martin"
    Set tEncounter.EncounterDate = $ZDateTime($Horolog, 3)
    Set tEncounter.EncounterType = "Outpatient"
    // Leave optional fields empty
    
    // Act
    Set tSC = tMapper.Insert(tEncounter)
    
    // Assert
    Do $$$AssertStatusOK(tSC, "Insert with null values should succeed")
    
    Set tFound = tMapper.Find(tEncounter.EncounterId)
    Do $$$AssertTrue($IsObject(tFound), "Should find encounter with null values")
    
    Quit $$$OK
}

/// Test error handling for invalid mappings
Method TestErrorHandlingForInvalidMappings() As %Status
{
    Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
    
    // Arrange - create invalid encounter (missing required fields)
    Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
    // Don't set required fields
    
    // Act
    Set tSC = tMapper.Insert(tEncounter)
    
    // Assert
    Do $$$AssertStatusNotOK(tSC, "Insert with invalid data should fail")
    
    Quit $$$OK
}

}
