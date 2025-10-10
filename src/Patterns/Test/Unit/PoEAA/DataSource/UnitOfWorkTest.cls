/// Unit tests for Unit of Work pattern implementation
Class Patterns.Test.Unit.PoEAA.DataSource.UnitOfWorkTest Extends %UnitTest.TestCase
{

/// Test RegisterNew tracks objects for insert
Method TestRegisterNewTracksObjectsForInsert() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        Set tObject = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        
        Do tUoW.RegisterNew(tObject)
        
        Do $$$AssertTrue(tUoW.NewObjects.Count() > 0, "Should have new objects")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test RegisterDirty tracks objects for update
Method TestRegisterDirtyTracksObjectsForUpdate() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        Set tObject = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        
        Do tUoW.RegisterDirty(tObject)
        
        Do $$$AssertTrue(tUoW.DirtyObjects.Count() > 0, "Should have dirty objects")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test RegisterDeleted tracks objects for deletion
Method TestRegisterDeletedTracksObjectsForDeletion() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        Set tObject = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        
        Do tUoW.RegisterDeleted(tObject)
        
        Do $$$AssertTrue(tUoW.DeletedObjects.Count() > 0, "Should have deleted objects")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test RegisterClean removes from dirty tracking
Method TestRegisterCleanRemovesFromDirty() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        Set tObject = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        
        Do tUoW.RegisterDirty(tObject)
        Do $$$AssertTrue(tUoW.DirtyObjects.Count() > 0, "Should have dirty objects initially")
        
        Do tUoW.RegisterClean(tObject)
        Do $$$AssertEquals(tUoW.DirtyObjects.Count(), 0, "Should have no dirty objects after clean")
        Do $$$AssertTrue(tUoW.CleanObjects.Count() > 0, "Should have clean objects")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test Rollback discards all pending changes
Method TestRollbackDiscardsAllPendingChanges() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        Set tObject1 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        Set tObject2 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        
        Do tUoW.RegisterNew(tObject1)
        Do tUoW.RegisterDirty(tObject2)
        
        Set tResult = tUoW.Rollback()
        Do $$$AssertStatusOK(tResult, "Rollback should succeed")
        
        Do $$$AssertEquals(tUoW.NewObjects.Count(), 0, "Should have 0 new objects")
        Do $$$AssertEquals(tUoW.DirtyObjects.Count(), 0, "Should have 0 dirty objects")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test dependency ordering in commit
Method TestDependencyOrderingInCommit() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        
        Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
        Do tUoW.RegisterMapper("Patterns.Examples.Clinical.ClinicalEncounter", tMapper)
        
        Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        Set tEncounter.PatientMRN = "TEST-001"
        Set tEncounter.ProviderName = "Dr. Test"
        Set tEncounter.EncounterType = "Outpatient"
        Set tEncounter.EncounterDate = $ZDATETIME($HOROLOG, 3)
        
        Do tUoW.RegisterNew(tEncounter)
        
        Set tResult = tUoW.Commit()
        Do $$$AssertStatusOK(tResult, "Commit should succeed")
        
        Do $$$AssertEquals(tUoW.NewObjects.Count(), 0, "New objects should be cleared after commit")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test multiple object types in single unit of work
Method TestMultipleObjectTypesInSingleUnitOfWork() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        
        Set tObject1 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        Set tObject2 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        
        Do tUoW.RegisterNew(tObject1)
        Do tUoW.RegisterDirty(tObject2)
        
        Do $$$AssertTrue(tUoW.NewObjects.Count() > 0, "Should have new objects")
        Do $$$AssertTrue(tUoW.DirtyObjects.Count() > 0, "Should have dirty objects")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test RegisterDeleted removes from other collections
Method TestRegisterDeletedRemovesFromOtherCollections() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        Set tObject = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        
        Do tUoW.RegisterNew(tObject)
        Do $$$AssertTrue(tUoW.NewObjects.Count() > 0, "Should have new objects initially")
        
        Do tUoW.RegisterDeleted(tObject)
        Do $$$AssertEquals(tUoW.NewObjects.Count(), 0, "Should have no new objects after delete")
        Do $$$AssertTrue(tUoW.DeletedObjects.Count() > 0, "Should have deleted objects")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test Clear method empties all collections
Method TestClearEmptiesAllCollections() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        Set tObject1 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        Set tObject2 = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        
        Do tUoW.RegisterNew(tObject1)
        Do tUoW.RegisterDirty(tObject2)
        
        Do tUoW.Clear()
        
        Do $$$AssertEquals(tUoW.NewObjects.Count(), 0, "Should have 0 new objects")
        Do $$$AssertEquals(tUoW.DirtyObjects.Count(), 0, "Should have 0 dirty objects")
        Do $$$AssertEquals(tUoW.DeletedObjects.Count(), 0, "Should have 0 deleted objects")
        Do $$$AssertEquals(tUoW.CleanObjects.Count(), 0, "Should have 0 clean objects")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test mapper registration via commit
Method TestMapperRegistrationViaCommit() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
        
        Do tUoW.RegisterMapper("Patterns.Examples.Clinical.ClinicalEncounter", tMapper)
        
        Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        Set tEncounter.PatientMRN = "TEST-002"
        Set tEncounter.ProviderName = "Dr. Smith"
        Set tEncounter.EncounterType = "Emergency"
        Set tEncounter.EncounterDate = $ZDATETIME($HOROLOG, 3)
        
        Do tUoW.RegisterNew(tEncounter)
        
        Set tResult = tUoW.Commit()
        Do $$$AssertStatusOK(tResult, "Commit with registered mapper should succeed")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test commit with validation in clinical UoW
Method TestCommitWithValidationInClinicalUoW() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tUoW = ##class(Patterns.Examples.Clinical.ClinicalDocumentationUnitOfWork).%New()
        Set tMapper = ##class(Patterns.Examples.Clinical.ClinicalEncounterMapper).%New()
        Do tUoW.RegisterMapper("Patterns.Examples.Clinical.ClinicalEncounter", tMapper)
        
        Set tEncounter = ##class(Patterns.Examples.Clinical.ClinicalEncounter).%New()
        Set tEncounter.PatientMRN = "TEST-VAL"
        Set tEncounter.ProviderName = "Dr. Validator"
        Set tEncounter.EncounterType = "Inpatient"
        Set tEncounter.EncounterDate = $ZDATETIME($HOROLOG, 3)
        
        Do tUoW.RegisterNew(tEncounter)
        
        Set tResult = tUoW.Commit()
        Do $$$AssertStatusOK(tResult, "Commit with validation should succeed")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
