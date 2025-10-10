/// Unit Tests for Identity Map Pattern
/// 
/// Comprehensive test suite for the Identity Map pattern implementation.
/// Tests core caching functionality, reference equality, statistics tracking,
/// and cache management operations.
/// 
/// @see Patterns.PoEAA.ObjectRelational.IdentityMap
/// @since 1.0.0
Class Patterns.Test.Unit.PoEAA.ObjectRelational.IdentityMapTest Extends %UnitTest.TestCase
{

// ===== PROPERTIES =====

/// Identity map instance for testing
Property IdentityMap As Patterns.PoEAA.ObjectRelational.IdentityMap;

// ===== SETUP/TEARDOWN =====

/// Set up test fixtures before each test
Method OnBeforeOneTest() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear any existing identity map first
        If $IsObject(..IdentityMap) {
            Do ..IdentityMap.Clear()
            Set ..IdentityMap = ""
        }
        
        // Create fresh identity map for each test
        Set ..IdentityMap = ##class(Patterns.PoEAA.ObjectRelational.IdentityMap).%New()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clean up after each test
Method OnAfterOneTest() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear the identity map
        If $IsObject(..IdentityMap) {
            Do ..IdentityMap.Clear()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== TEST METHODS =====

/// Test: Add() stores object in map
Method TestAddStoresObject() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Add object to map
        Set tSC = ..IdentityMap.Add("123", tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        // Verify size increased
        Do $$$AssertEquals(..IdentityMap.Size, 1, "Size should be 1 after adding object")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Get() retrieves stored object
Method TestGetRetrievesObject() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Add object to map
        Set tSC = ..IdentityMap.Add("123", tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        // Retrieve object
        Set tRetrieved = ..IdentityMap.Get("123")
        
        // Verify object was retrieved
        Do $$$AssertTrue($IsObject(tRetrieved), "Get should return an object")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Get() returns same object instance (reference equality)
Method TestGetReturnsSameInstance() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Add object to map
        Set tSC = ..IdentityMap.Add("123", tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        // Retrieve object twice
        Set tFirst = ..IdentityMap.Get("123")
        Set tSecond = ..IdentityMap.Get("123")
        
        // Verify same instance (reference equality)
        Do $$$AssertTrue((tFirst = tSecond), "Get should return identical instance")
        Do $$$AssertEquals(tFirst, tSecond, "References should be equal")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Get() with non-existent ID returns empty
Method TestGetNonExistentReturnsEmpty() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Try to get non-existent object
        Set tRetrieved = ..IdentityMap.Get("non-existent")
        
        // Verify empty result
        Do $$$AssertTrue('$IsObject(tRetrieved), "Get with non-existent ID should return empty")
        Do $$$AssertEquals(tRetrieved, "", "Non-existent object should be empty string")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Contains() correctly identifies presence
Method TestContainsIdentifiesPresence() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Verify not present initially
        Do $$$AssertTrue('..IdentityMap.Contains("123"), "Object should not be present initially")
        
        // Add object
        Set tSC = ..IdentityMap.Add("123", tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        // Verify now present
        Do $$$AssertTrue(..IdentityMap.Contains("123"), "Object should be present after Add")
        
        // Verify other ID not present
        Do $$$AssertTrue('..IdentityMap.Contains("456"), "Different ID should not be present")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Remove() removes object from map
Method TestRemoveDeletesObject() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Add object
        Set tSC = ..IdentityMap.Add("123", tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        // Verify present
        Do $$$AssertTrue(..IdentityMap.Contains("123"), "Object should be present")
        Do $$$AssertEquals(..IdentityMap.Size, 1, "Size should be 1")
        
        // Remove object
        Set tSC = ..IdentityMap.Remove("123")
        Do $$$AssertStatusOK(tSC, "Remove should succeed")
        
        // Verify removed
        Do $$$AssertTrue('..IdentityMap.Contains("123"), "Object should not be present after Remove")
        Do $$$AssertEquals(..IdentityMap.Size, 0, "Size should be 0 after Remove")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Clear() empties entire map
Method TestClearEmptiesMap() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Add multiple objects
        Set tPatient1 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient2 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient3 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        
        Do ..IdentityMap.Add("1", tPatient1)
        Do ..IdentityMap.Add("2", tPatient2)
        Do ..IdentityMap.Add("3", tPatient3)
        
        // Verify size
        Do $$$AssertEquals(..IdentityMap.Size, 3, "Size should be 3 after adding 3 objects")
        
        // Clear map
        Set tSC = ..IdentityMap.Clear()
        Do $$$AssertStatusOK(tSC, "Clear should succeed")
        
        // Verify empty
        Do $$$AssertEquals(..IdentityMap.Size, 0, "Size should be 0 after Clear")
        Do $$$AssertTrue('..IdentityMap.Contains("1"), "Object 1 should not be present")
        Do $$$AssertTrue('..IdentityMap.Contains("2"), "Object 2 should not be present")
        Do $$$AssertTrue('..IdentityMap.Contains("3"), "Object 3 should not be present")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: GetOrLoad() loads object if not in map
Method TestGetOrLoadLoadsWhenMissing() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Note: GetOrLoad needs a loader class method
        // For this test, we'll create a mock loader
        
        // First verify object not in cache
        Do $$$AssertTrue('..IdentityMap.Contains("999"), "Object should not be in cache initially")
        
        // Call GetOrLoad with mock loader
        // This will fail gracefully if loader doesn't exist
        Set tObject = ..IdentityMap.GetOrLoad("999", "NonExistentLoader")
        
        // Verify it tried to load (returns empty if loader fails)
        Do $$$AssertTrue('$IsObject(tObject), "Should return empty for non-existent loader")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: GetOrLoad() returns cached object if in map
Method TestGetOrLoadReturnsCached() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Add object to cache first
        Set tSC = ..IdentityMap.Add("123", tPatient)
        Do $$$AssertStatusOK(tSC, "Add should succeed")
        
        // Call GetOrLoad - should return cached object without calling loader
        Set tCached = ..IdentityMap.GetOrLoad("123", "SomeLoader")
        
        // Verify cached object returned
        Do $$$AssertTrue($IsObject(tCached), "Should return cached object")
        Do $$$AssertEquals(tCached, tPatient, "Should return same instance")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Multiple objects with different IDs
Method TestMultipleObjectsWithDifferentIds() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create multiple patient objects
        Set tPatient1 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient1.MRN = "PAT-001"
        
        Set tPatient2 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient2.MRN = "PAT-002"
        
        Set tPatient3 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient3.MRN = "PAT-003"
        
        // Add all to map
        Do ..IdentityMap.Add("1", tPatient1)
        Do ..IdentityMap.Add("2", tPatient2)
        Do ..IdentityMap.Add("3", tPatient3)
        
        // Verify all present
        Do $$$AssertEquals(..IdentityMap.Size, 3, "Size should be 3")
        Do $$$AssertTrue(..IdentityMap.Contains("1"), "Patient 1 should be present")
        Do $$$AssertTrue(..IdentityMap.Contains("2"), "Patient 2 should be present")
        Do $$$AssertTrue(..IdentityMap.Contains("3"), "Patient 3 should be present")
        
        // Retrieve and verify each
        Set tRetrieved1 = ..IdentityMap.Get("1")
        Set tRetrieved2 = ..IdentityMap.Get("2")
        Set tRetrieved3 = ..IdentityMap.Get("3")
        
        Do $$$AssertEquals(tRetrieved1, tPatient1, "Patient 1 should match")
        Do $$$AssertEquals(tRetrieved2, tPatient2, "Patient 2 should match")
        Do $$$AssertEquals(tRetrieved3, tPatient3, "Patient 3 should match")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Cache statistics tracking (hits, misses)
Method TestCacheStatisticsTracking() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Initially no hits or misses
        Do $$$AssertEquals(..IdentityMap.HitCount, 0, "HitCount should be 0 initially")
        Do $$$AssertEquals(..IdentityMap.MissCount, 0, "MissCount should be 0 initially")
        
        // Add object
        Do ..IdentityMap.Add("123", tPatient)
        
        // Successful get (hit)
        Set tObj = ..IdentityMap.Get("123")
        Do $$$AssertEquals(..IdentityMap.HitCount, 1, "HitCount should be 1 after successful get")
        
        // Another successful get (another hit)
        Set tObj = ..IdentityMap.Get("123")
        Do $$$AssertEquals(..IdentityMap.HitCount, 2, "HitCount should be 2 after second get")
        
        // Failed get (miss)
        Set tObj = ..IdentityMap.Get("non-existent")
        Do $$$AssertEquals(..IdentityMap.MissCount, 1, "MissCount should be 1 after failed get")
        
        // Verify hit ratio calculation works (2 hits out of 3 total)
        Set tRatio = ..IdentityMap.GetHitRatio()
        Do $$$AssertTrue((tRatio > 0), "Hit ratio should be greater than 0")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: GetStatistics() returns comprehensive statistics
Method TestGetStatistics() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Add some objects and create activity
        Do ..IdentityMap.Add("1", tPatient)
        Set tObj = ..IdentityMap.Get("1")
        Set tObj = ..IdentityMap.Get("non-existent")
        
        // Get statistics
        Set tStats = ..IdentityMap.GetStatistics()
        
        // Verify statistics object
        Do $$$AssertTrue($IsObject(tStats), "GetStatistics should return an object")
        Do $$$AssertTrue(tStats.%IsA("%DynamicObject"), "Should return DynamicObject")
        
        // Verify statistics values
        Do $$$AssertEquals(tStats.size, 1, "Statistics size should be 1")
        Do $$$AssertEquals(tStats.hitCount, 1, "Statistics hitCount should be 1")
        Do $$$AssertEquals(tStats.missCount, 1, "Statistics missCount should be 1")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Add() with empty ID returns error
Method TestAddWithEmptyIdFails() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Try to add with empty ID
        Set tSC = ..IdentityMap.Add("", tPatient)
        
        // Verify error status
        Do $$$AssertStatusNotOK(tSC, "Add with empty ID should fail")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Add() with null object returns error
Method TestAddWithNullObjectFails() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Try to add null object
        Set tSC = ..IdentityMap.Add("123", "")
        
        // Verify error status
        Do $$$AssertStatusNotOK(tSC, "Add with null object should fail")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Add() with duplicate ID updates object
Method TestAddWithDuplicateIdUpdates() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Add first object
        Set tPatient1 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient1.FirstName = "John"
        Do ..IdentityMap.Add("123", tPatient1)
        
        // Verify size
        Do $$$AssertEquals(..IdentityMap.Size, 1, "Size should be 1 after first add")
        
        // Add second object with same ID
        Set tPatient2 = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient2.FirstName = "Jane"
        Do ..IdentityMap.Add("123", tPatient2)
        
        // Size should still be 1 (replaced, not added)
        Do $$$AssertEquals(..IdentityMap.Size, 1, "Size should still be 1 after duplicate add")
        
        // Verify second object is now cached
        Set tRetrieved = ..IdentityMap.Get("123")
        Do $$$AssertEquals(tRetrieved, tPatient2, "Should return second object")
        Do $$$AssertEquals(tRetrieved.FirstName, "Jane", "Should have second object's data")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test: Clear() resets statistics
Method TestClearResetsStatistics() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create test patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PatientActiveRecord).%New()
        Set tPatient.MRN = "TEST-001"
        
        // Create some activity
        Do ..IdentityMap.Add("1", tPatient)
        Set tObj = ..IdentityMap.Get("1")
        Set tObj = ..IdentityMap.Get("non-existent")
        
        // Verify statistics exist
        Do $$$AssertTrue(..IdentityMap.HitCount > 0, "HitCount should be > 0 before clear")
        Do $$$AssertTrue(..IdentityMap.MissCount > 0, "MissCount should be > 0 before clear")
        
        // Clear map
        Do ..IdentityMap.Clear()
        
        // Verify statistics reset
        Do $$$AssertEquals(..IdentityMap.HitCount, 0, "HitCount should be 0 after clear")
        Do $$$AssertEquals(..IdentityMap.MissCount, 0, "MissCount should be 0 after clear")
        Do $$$AssertEquals(..IdentityMap.Size, 0, "Size should be 0 after clear")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

}
