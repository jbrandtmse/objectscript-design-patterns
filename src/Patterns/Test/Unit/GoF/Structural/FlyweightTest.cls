/// Unit Tests for Gang of Four Flyweight Pattern
/// 
/// Tests the Flyweight pattern implementation including:
/// - Intrinsic state sharing between instances
/// - Extrinsic state independence
/// - Factory pool management
/// - Memory efficiency
/// - Healthcare medication example
/// 
/// @see Patterns.GoF.Structural.Flyweight
/// @see Patterns.GoF.Structural.FlyweightFactory
/// @since 1.0.0
Class Patterns.Test.Unit.GoF.Structural.FlyweightTest Extends %UnitTest.TestCase
{

/// Test intrinsic state sharing between instances
Method TestIntrinsicStateSharing() As %Boolean
{
    // Clear debug global
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"TestIntrinsicStateSharing started; "
    
    Try {
        // Create factory
        Set tFactory = ##class(Patterns.GoF.Structural.FlyweightFactory).%New()
        
        // Get two flyweights with same key
        Set tFlyweight1 = tFactory.GetFlyweight("SharedKey")
        Set tFlyweight2 = tFactory.GetFlyweight("SharedKey")
        
        // Test that they are the same object
        Do $$$AssertEquals(tFlyweight1, tFlyweight2, "Same key should return same flyweight object")
        
        // Test intrinsic state is shared
        Do $$$AssertEquals(tFlyweight1.IntrinsicState, tFlyweight2.IntrinsicState, "Intrinsic state should be identical")
        
        // Verify reference count
        Do $$$AssertEquals(tFlyweight1.GetReferenceCount(), 2, "Reference count should be 2 for shared object")
        
        Set ^ClineDebug = ^ClineDebug_"Intrinsic state sharing test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestIntrinsicStateSharing: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestIntrinsicStateSharing: "_ex.Name)
    }
    Quit 1
}

/// Test extrinsic state independence
Method TestExtrinsicStateIndependence() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestExtrinsicStateIndependence started; "
    
    Try {
        // Create a concrete flyweight
        Set tFlyweight = ##class(Patterns.GoF.Structural.ConcreteFlyweight).%New("SharedData")
        
        // Test operations with different extrinsic states
        Set tResult1 = tFlyweight.Operation("ExtrinsicState1")
        Set tResult2 = tFlyweight.Operation("ExtrinsicState2")
        
        // Results should be different due to different extrinsic states
        Do $$$AssertNotEquals(tResult1, tResult2, "Different extrinsic states should produce different results")
        
        // Verify both results contain the intrinsic state
        Do $$$AssertTrue(tResult1 [ "SharedData", "Result should contain intrinsic state")
        Do $$$AssertTrue(tResult2 [ "SharedData", "Result should contain intrinsic state")
        
        // Verify each result contains its own extrinsic state
        Do $$$AssertTrue(tResult1 [ "ExtrinsicState1", "Result should contain first extrinsic state")
        Do $$$AssertTrue(tResult2 [ "ExtrinsicState2", "Result should contain second extrinsic state")
        
        Set ^ClineDebug = ^ClineDebug_"Extrinsic state independence test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestExtrinsicStateIndependence: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestExtrinsicStateIndependence: "_ex.Name)
    }
    Quit 1
}

/// Test factory returns same instance for same key
Method TestFactoryPoolManagement() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestFactoryPoolManagement started; "
    
    Try {
        // Create factory
        Set tFactory = ##class(Patterns.GoF.Structural.FlyweightFactory).%New()
        
        // Get flyweights with different keys
        Set tFly1 = tFactory.GetFlyweight("Key1")
        Set tFly2 = tFactory.GetFlyweight("Key2")
        Set tFly3 = tFactory.GetFlyweight("Key1")  // Same as first
        
        // Test different keys create different objects
        Do $$$AssertNotEquals(tFly1, tFly2, "Different keys should create different flyweight objects")
        
        // Test same key returns same object
        Do $$$AssertEquals(tFly1, tFly3, "Same key should return same flyweight object")
        
        // Test pool size
        Do $$$AssertEquals(tFactory.GetPoolSize(), 2, "Pool should contain 2 unique flyweights")
        
        // Test statistics
        Do $$$AssertEquals(tFactory.PoolHits, 1, "Should have 1 cache hit")
        Do $$$AssertEquals(tFactory.PoolMisses, 2, "Should have 2 cache misses")
        
        Set ^ClineDebug = ^ClineDebug_"Factory pool management test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestFactoryPoolManagement: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestFactoryPoolManagement: "_ex.Name)
    }
    Quit 1
}

/// Test unshared concrete flyweight
Method TestUnsharedConcreteFlyweight() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestUnsharedConcreteFlyweight started; "
    
    Try {
        // Create factory
        Set tFactory = ##class(Patterns.GoF.Structural.FlyweightFactory).%New()
        
        // Get unshared flyweights
        Set tUnshared1 = tFactory.GetUnsharedFlyweight("State1")
        Set tUnshared2 = tFactory.GetUnsharedFlyweight("State1")  // Same state
        
        // Test that unshared flyweights are different objects
        Do $$$AssertNotEquals(tUnshared1, tUnshared2, "Unshared flyweights should be different objects even with same state")
        
        // Test unique identifiers are different
        Do $$$AssertNotEquals(tUnshared1.UniqueIdentifier, tUnshared2.UniqueIdentifier, "Each unshared flyweight should have unique ID")
        
        // Test state modification
        Set tSC = tUnshared1.ModifyState("NewState")
        Do $$$AssertStatusOK(tSC, "Should be able to modify unshared flyweight state")
        Do $$$AssertEquals(tUnshared1.AllState, "NewState", "State should be updated")
        
        Set ^ClineDebug = ^ClineDebug_"Unshared concrete flyweight test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestUnsharedConcreteFlyweight: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestUnsharedConcreteFlyweight: "_ex.Name)
    }
    Quit 1
}

/// Test global-based shared flyweight pool
Method TestGlobalPoolOperations() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestGlobalPoolOperations started; "
    
    Try {
        // Clear global pool
        Set tSC = ##class(Patterns.GoF.Structural.FlyweightFactory).ClearGlobalPool()
        Do $$$AssertStatusOK(tSC, "Should clear global pool successfully")
        
        // Get shared flyweights using class method
        Set tFly1 = ##class(Patterns.GoF.Structural.FlyweightFactory).GetSharedFlyweight("GlobalKey1")
        Set tFly2 = ##class(Patterns.GoF.Structural.FlyweightFactory).GetSharedFlyweight("GlobalKey1")
        
        // Test same object returned from global pool
        Do $$$AssertEquals(tFly1, tFly2, "Global pool should return same object for same key")
        
        // Verify global statistics
        Set tStats = ##class(Patterns.GoF.Structural.FlyweightFactory).GetGlobalPoolStatistics()
        Do $$$AssertTrue(tStats [ "Hits=1", "Should have 1 hit in global pool")
        
        // Test cleanup
        Set tSC = ##class(Patterns.GoF.Structural.FlyweightFactory).CleanupGlobalPool()
        Do $$$AssertStatusOK(tSC, "Cleanup should complete successfully")
        
        Set ^ClineDebug = ^ClineDebug_"Global pool operations test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestGlobalPoolOperations: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestGlobalPoolOperations: "_ex.Name)
    }
    Quit 1
}

/// Test healthcare medication example
Method TestMedicationExample() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestMedicationExample started; "
    
    Try {
        // Load standard medications
        Set tSC = ##class(Patterns.Examples.MedicationFactory).LoadStandardMedications()
        Do $$$AssertStatusOK(tSC, "Should load standard medications successfully")
        
        // Get medication flyweights
        Set tAspirin1 = ##class(Patterns.Examples.MedicationFactory).GetMedication("Aspirin")
        Set tAspirin2 = ##class(Patterns.Examples.MedicationFactory).GetMedication("Aspirin")
        Set tMetformin = ##class(Patterns.Examples.MedicationFactory).GetMedication("Metformin")
        
        // Test sharing
        Do $$$AssertEquals(tAspirin1, tAspirin2, "Same medication should return same object")
        Do $$$AssertNotEquals(tAspirin1, tMetformin, "Different medications should be different objects")
        
        // Test medication properties
        Do $$$AssertEquals(tAspirin1.DrugName, "Aspirin", "Drug name should be Aspirin")
        Do $$$AssertTrue(tAspirin1.GenericName [ "Acetylsalicylic", "Generic name should contain Acetylsalicylic")
        
        // Test prescribe operation
        Set tPrescription = tAspirin1.Prescribe("P12345", "81mg", "Once daily")
        Do $$$AssertTrue(tPrescription [ "P12345", "Prescription should contain patient ID")
        Do $$$AssertTrue(tPrescription [ "81mg", "Prescription should contain dosage")
        
        Set ^ClineDebug = ^ClineDebug_"Medication example test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestMedicationExample: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestMedicationExample: "_ex.Name)
    }
    Quit 1
}

/// Test prescribed medication context
Method TestPrescribedMedication() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestPrescribedMedication started; "
    
    Try {
        // Ensure medications are loaded
        Do ##class(Patterns.Examples.MedicationFactory).LoadStandardMedications()
        
        // Create prescriptions
        Set tPrescription1 = ##class(Patterns.Examples.PrescribedMedication).%New("P001", "Aspirin")
        Set tPrescription1.Dosage = "81mg"
        Set tPrescription1.Frequency = "Once daily"
        Set tPrescription1.Prescriber = "Dr. Smith"
        
        Set tPrescription2 = ##class(Patterns.Examples.PrescribedMedication).%New("P002", "Aspirin")
        Set tPrescription2.Dosage = "325mg"
        Set tPrescription2.Frequency = "Twice daily"
        Set tPrescription2.Prescriber = "Dr. Jones"
        
        // Test that medications are shared
        Do $$$AssertEquals(tPrescription1.Medication, tPrescription2.Medication, "Prescriptions should share same medication object")
        
        // Test different extrinsic states
        Do $$$AssertNotEquals(tPrescription1.Dosage, tPrescription2.Dosage, "Dosages should be different")
        Do $$$AssertNotEquals(tPrescription1.Prescriber, tPrescription2.Prescriber, "Prescribers should be different")
        
        // Test active prescription
        Do $$$AssertTrue(tPrescription1.IsActive(), "New prescription should be active")
        
        // Test memory estimate
        Set tMemSize = tPrescription1.GetMemoryEstimate()
        Do $$$AssertTrue(tMemSize > 0, "Memory estimate should be positive")
        Do $$$AssertTrue(tMemSize < 100, "Memory should be small due to flyweight pattern")
        
        Set ^ClineDebug = ^ClineDebug_"Prescribed medication test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestPrescribedMedication: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestPrescribedMedication: "_ex.Name)
    }
    Quit 1
}

/// Test memory efficiency with large dataset
Method TestMemoryEfficiency() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestMemoryEfficiency started; "
    
    Try {
        // Get memory demonstration results
        Set tResult = ##class(Patterns.Examples.MedicationFactory).DemonstrateMemorySavings()
        
        // Verify results contain expected information
        Do $$$AssertTrue(tResult [ "Total Prescriptions=1000", "Should create 1000 prescriptions")
        Do $$$AssertTrue(tResult [ "Memory Saved=", "Should calculate memory saved")
        
        // Extract savings percentage from result
        Set tSavingsPos = $FIND(tResult, "Memory Saved=")
        If tSavingsPos > 0 {
            Set tSavingsText = $PIECE($EXTRACT(tResult, tSavingsPos, *), "(", 2)
            Set tSavingsPercent = +$PIECE(tSavingsText, "%", 1)
            Do $$$AssertTrue(tSavingsPercent > 50, "Should save at least 50% memory")
        }
        
        // Verify sharing
        Set tVerifyResult = ##class(Patterns.Examples.MedicationFactory).VerifySharing()
        Do $$$AssertTrue(tVerifyResult [ "SUCCESS", "Sharing verification should succeed")
        
        Set ^ClineDebug = ^ClineDebug_"Memory efficiency test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestMemoryEfficiency: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestMemoryEfficiency: "_ex.Name)
    }
    Quit 1
}

/// Test concurrent access to shared flyweights
Method TestConcurrentAccess() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestConcurrentAccess started; "
    
    Try {
        // Create factory
        Set tFactory = ##class(Patterns.GoF.Structural.FlyweightFactory).%New()
        
        // Simulate concurrent access
        For i = 1:1:10 {
            Set tFly = tFactory.GetFlyweight("ConcurrentKey")
            Set tResult = tFly.Operation("Client"_i)
            Do $$$AssertTrue(tResult [ "ConcurrentKey", "Operation should work with concurrent access")
        }
        
        // Verify only one object was created
        Do $$$AssertEquals(tFactory.GetPoolSize(), 1, "Should only have one flyweight for concurrent key")
        
        // Verify hit count
        Do $$$AssertEquals(tFactory.PoolHits, 9, "Should have 9 cache hits for 10 requests")
        
        Set ^ClineDebug = ^ClineDebug_"Concurrent access test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestConcurrentAccess: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestConcurrentAccess: "_ex.Name)
    }
    Quit 1
}

/// Test factory cleanup operations
Method TestFactoryCleanup() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestFactoryCleanup started; "
    
    Try {
        // Create factory and add flyweights
        Set tFactory = ##class(Patterns.GoF.Structural.FlyweightFactory).%New()
        Set tFly1 = tFactory.GetFlyweight("CleanupKey1")
        Set tFly2 = tFactory.GetFlyweight("CleanupKey2")
        
        // Verify pool has objects
        Do $$$AssertEquals(tFactory.GetPoolSize(), 2, "Pool should have 2 objects")
        
        // Clear pool
        Set tSC = tFactory.ClearPool()
        Do $$$AssertStatusOK(tSC, "Clear pool should succeed")
        
        // Verify pool is empty
        Do $$$AssertEquals(tFactory.GetPoolSize(), 0, "Pool should be empty after clear")
        
        // Verify statistics are reset
        Do $$$AssertEquals(tFactory.PoolHits, 0, "Hits should be reset")
        Do $$$AssertEquals(tFactory.PoolMisses, 0, "Misses should be reset")
        
        Set ^ClineDebug = ^ClineDebug_"Factory cleanup test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestFactoryCleanup: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestFactoryCleanup: "_ex.Name)
    }
    Quit 1
}

/// Test drug interaction checking
Method TestDrugInteractions() As %Boolean
{
    Set ^ClineDebug = ^ClineDebug_"TestDrugInteractions started; "
    
    Try {
        // Load medications
        Do ##class(Patterns.Examples.MedicationFactory).LoadStandardMedications()
        
        // Get medications
        Set tAspirin = ##class(Patterns.Examples.MedicationFactory).GetMedication("Aspirin")
        Set tWarfarin = ##class(Patterns.Examples.MedicationFactory).GetMedication("Warfarin")
        
        // Test interaction check
        Do $$$AssertTrue(tAspirin.CheckInteraction("Warfarin"), "Aspirin should interact with Warfarin")
        Do $$$AssertTrue(tAspirin.CheckInteraction("Ibuprofen"), "Aspirin should interact with Ibuprofen")
        Do $$$AssertTrue('tAspirin.CheckInteraction("Acetaminophen"), "Aspirin should not interact with Acetaminophen")
        
        // Create prescriptions and check interactions
        Set tPrescription1 = ##class(Patterns.Examples.PrescribedMedication).%New("P001", "Aspirin")
        Set tPrescription2 = ##class(Patterns.Examples.PrescribedMedication).%New("P001", "Atorvastatin")
        
        // Atorvastatin interacts with Warfarin
        Set tAtorva = ##class(Patterns.Examples.MedicationFactory).GetMedication("Atorvastatin")
        Do $$$AssertTrue(tAtorva.CheckInteraction("Warfarin"), "Atorvastatin should interact with Warfarin")
        
        Set ^ClineDebug = ^ClineDebug_"Drug interactions test passed; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"Error in TestDrugInteractions: "_ex.Name_"; "
        Do $$$AssertTrue(0, "Exception in TestDrugInteractions: "_ex.Name)
    }
    Quit 1
}

/// Cleanup method called after each test
Method OnAfterOneTest() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear any test globals
        Kill ^Patterns.Flyweight.Pool
        Kill ^Patterns.Flyweight.Stats
        Kill ^Patterns.Examples.MedicationPool
        Kill ^Patterns.Examples.MedicationStats
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
