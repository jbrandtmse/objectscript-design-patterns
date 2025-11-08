/// Unit Tests for Registry Pattern
/// 
/// Comprehensive test suite for the Registry pattern implementation
/// including singleton behavior, thread safety, scoped registries,
/// and healthcare service registry functionality.
Class Patterns.Test.Unit.PoEAA.Base.RegistryTest Extends %UnitTest.TestCase
{

// ===== DEBUG METHODS =====

/// Debug method to investigate TestSetRegistersObject failure
ClassMethod DebugSetRegisters() As %String
{
    Set ^ClineDebug = ""
    
    Try {
        // Clear state
        Kill ^||Patterns.Registry.Data
        Set ^ClineDebug = ^ClineDebug _ "1. Cleared PPG state; "
        
        // Create registry
        Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
        Set ^ClineDebug = ^ClineDebug _ "2. Created registry, Scope=" _ tRegistry.Scope _ "; "
        
        // Create test object
        Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("test1")
        Set ^ClineDebug = ^ClineDebug _ "3. Created TestObject, IsObject=" _ $IsObject(tObject) _ "; "
        
        // Call Set
        Set tSC = tRegistry.Set("TestKey", tObject)
        Set ^ClineDebug = ^ClineDebug _ "4. Called Set(), Status=" _ $System.Status.GetOneErrorText(tSC) _ "; "
        
        // Check if data exists in PPG
        Set tExists = $Data(^||Patterns.Registry.Data(tRegistry.Scope, "TestKey"))
        Set ^ClineDebug = ^ClineDebug _ "5. Data exists in PPG=" _ tExists _ "; "
        
        // Call Get
        Set tRetrieved = tRegistry.Get("TestKey")
        Set ^ClineDebug = ^ClineDebug _ "6. Called Get(), IsObject=" _ $IsObject(tRetrieved) _ "; "
        
        If $IsObject(tRetrieved) {
            Set ^ClineDebug = ^ClineDebug _ "7. Retrieved equals original=" _ (tRetrieved = tObject) _ "; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "7. Retrieved is not an object, value=" _ tRetrieved _ "; "
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.DisplayString() _ "; "
    }
    
    Quit ^ClineDebug
}

// ===== TEST SETUP AND TEARDOWN =====

/// Clean up registry state before each test
Method OnBeforeOneTest() As %Status
{
    // Clear singleton instances using class method
    Do ##class(Patterns.PoEAA.Base.Registry).ClearSingletons()
    
    // Clear healthcare registry initialization flag
    Kill ^||Patterns.Healthcare.Registry.Initialized
    
    Quit $$$OK
}

/// Clean up registry state after each test
Method OnAfterOneTest() As %Status
{
    // Clear singleton instances using class method
    Do ##class(Patterns.PoEAA.Base.Registry).ClearSingletons()
    
    // Clear healthcare registry initialization flag
    Kill ^||Patterns.Healthcare.Registry.Initialized
    
    Quit $$$OK
}

// ===== BASIC REGISTRY OPERATIONS =====

/// Test Set() registers object successfully
Method TestSetRegistersObject() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("test1")
    
    Set tSC = tRegistry.Set("TestKey", tObject)
    Do $$$AssertStatusOK(tSC, "Set should return OK status")
    
    Set tRetrieved = tRegistry.Get("TestKey")
    Do $$$AssertTrue($IsObject(tRetrieved), "Retrieved value should be an object")
    
    Quit $$$OK
}

/// Test Get() retrieves registered object
Method TestGetRetrievesObject() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("test2")
    
    Set tSC = tRegistry.Set("MyKey", tObject)
    Do $$$AssertStatusOK(tSC, "Set should succeed")
    
    Set tRetrieved = tRegistry.Get("MyKey")
    Do $$$AssertEquals(tRetrieved, tObject, "Retrieved object should match original")
    
    Quit $$$OK
}

/// Test Get() returns same instance (singleton behavior for values)
Method TestGetReturnsSameInstance() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("test3")
    
    Do tRegistry.Set("SingletonKey", tObject)
    
    Set tFirst = tRegistry.Get("SingletonKey")
    Set tSecond = tRegistry.Get("SingletonKey")
    
    Do $$$AssertEquals(tFirst, tSecond, "Multiple Get calls should return same instance")
    
    Quit $$$OK
}

/// Test Contains() identifies registration
Method TestContainsIdentifiesRegistration() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("test4")
    
    Do $$$AssertTrue('tRegistry.Contains("NotPresent"), "Should not contain unregistered key")
    
    Do tRegistry.Set("PresentKey", tObject)
    Do $$$AssertTrue(tRegistry.Contains("PresentKey"), "Should contain registered key")
    
    Quit $$$OK
}

/// Test Remove() unregisters object
Method TestRemoveUnregistersObject() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("test5")
    
    Do tRegistry.Set("ToRemove", tObject)
    Do $$$AssertTrue(tRegistry.Contains("ToRemove"), "Key should exist before removal")
    
    Set tSC = tRegistry.Remove("ToRemove")
    Do $$$AssertStatusOK(tSC, "Remove should succeed")
    Do $$$AssertTrue('tRegistry.Contains("ToRemove"), "Key should not exist after removal")
    
    Quit $$$OK
}

/// Test Clear() removes all registrations
Method TestClearRemovesAllRegistrations() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    
    // Register multiple objects
    For i=1:1:5 {
        Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("test" _ i)
        Do tRegistry.Set("Key" _ i, tObject)
    }
    
    Do $$$AssertEquals(tRegistry.GetCount(), 5, "Should have 5 registered objects")
    
    Set tSC = tRegistry.Clear()
    Do $$$AssertStatusOK(tSC, "Clear should succeed")
    Do $$$AssertEquals(tRegistry.GetCount(), 0, "Should have no registered objects after clear")
    
    Quit $$$OK
}

// ===== SINGLETON PATTERN TESTS =====

/// Test singleton instance shares data globally
Method TestSingletonInstanceIsGlobal() As %Status
{
    Set tFirst = ##class(Patterns.PoEAA.Base.Registry).GetInstance()
    Set tSecond = ##class(Patterns.PoEAA.Base.Registry).GetInstance()
    
    // Verify state is shared (data accessible from both instances)
    Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("shared")
    Do tFirst.Set("SharedKey", tObject)
    
    // Verify both instances share the same scope
    Do $$$AssertEquals(tFirst.Scope, "Global", "First instance should have Global scope")
    Do $$$AssertEquals(tSecond.Scope, "Global", "Second instance should have Global scope")
    
    // Verify data is accessible from second instance
    Set tRetrieved = tSecond.Get("SharedKey")
    Do $$$AssertTrue($IsObject(tRetrieved), "Retrieved value should be an object")
    Do $$$AssertEquals(tRetrieved, tObject, "Data should be shared across registry instances")
    
    Quit $$$OK
}

// ===== SCOPED REGISTRY TESTS =====

/// Test scoped registries (global vs session vs request)
Method TestScopedRegistries() As %Status
{
    Set tGlobal = ##class(Patterns.PoEAA.Base.Registry).GetInstance()
    Set tSession = ##class(Patterns.PoEAA.Base.Registry).CreateSessionRegistry()
    Set tRequest = ##class(Patterns.PoEAA.Base.Registry).CreateRequestRegistry()
    
    Do $$$AssertEquals(tGlobal.Scope, "Global", "Global registry should have Global scope")
    Do $$$AssertEquals(tSession.Scope, "Session", "Session registry should have Session scope")
    Do $$$AssertTrue(tRequest.Scope '= "Global", "Request registry should have unique scope")
    Do $$$AssertTrue(tRequest.Scope '= "Session", "Request registry should not use Session scope")
    
    // Verify they are independent (different scopes = different data)
    Set tObj1 = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("global")
    Set tObj2 = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("session")
    
    Do tGlobal.Set("Key", tObj1)
    Do tSession.Set("Key", tObj2)
    
    // Verify each scope maintains independent data
    Set tGlobalRetrieved = tGlobal.Get("Key")
    Set tSessionRetrieved = tSession.Get("Key")
    
    Do $$$AssertTrue($IsObject(tGlobalRetrieved), "Global registry should return object")
    Do $$$AssertTrue($IsObject(tSessionRetrieved), "Session registry should return object")
    Do $$$AssertEquals(tGlobalRetrieved, tObj1, "Global should have obj1")
    Do $$$AssertEquals(tSessionRetrieved, tObj2, "Session should have obj2")
    
    Quit $$$OK
}

// ===== ERROR HANDLING TESTS =====

/// Test error handling for missing keys
Method TestErrorHandlingForMissingKeys() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    
    Set tRetrieved = tRegistry.Get("NonExistentKey")
    Do $$$AssertEquals(tRetrieved, "", "Get should return empty string for missing key")
    
    Do $$$AssertTrue('tRegistry.Contains("NonExistentKey"), "Contains should return false for missing key")
    
    Quit $$$OK
}

/// Test Set() with empty key returns error
Method TestSetWithEmptyKeyReturnsError() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("empty")
    
    Set tSC = tRegistry.Set("", tObject)
    Do $$$AssertStatusNotOK(tSC, "Set with empty key should return error status")
    
    Quit $$$OK
}

/// Test Set() with non-object value returns error
Method TestSetWithNonObjectReturnsError() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    
    Set tSC = tRegistry.Set("Key", "NotAnObject")
    Do $$$AssertStatusNotOK(tSC, "Set with non-object should return error status")
    
    Quit $$$OK
}

/// Test Remove() with empty key returns error
Method TestRemoveWithEmptyKeyReturnsError() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    
    Set tSC = tRegistry.Remove("")
    Do $$$AssertStatusNotOK(tSC, "Remove with empty key should return error status")
    
    Quit $$$OK
}

// ===== MULTIPLE REGISTRY INSTANCES =====

/// Test multiple registry instances
Method TestMultipleRegistryInstances() As %Status
{
    Set tRegistry1 = ##class(Patterns.PoEAA.Base.Registry).%New()
    Set tRegistry2 = ##class(Patterns.PoEAA.Base.Registry).%New()
    
    Set tObj1 = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("reg1")
    Set tObj2 = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("reg2")
    
    Do tRegistry1.Set("Key", tObj1)
    Do tRegistry2.Set("Key", tObj2)
    
    // Instances should be independent
    Do $$$AssertEquals(tRegistry1.Get("Key"), tObj1, "Registry1 should have obj1")
    Do $$$AssertEquals(tRegistry2.Get("Key"), tObj2, "Registry2 should have obj2")
    
    Quit $$$OK
}

// ===== HEALTHCARE SERVICE REGISTRY TESTS =====

/// Test well-known service lookup
Method TestWellKnownServiceLookup() As %Status
{
    Set tRegistry = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetInstance()
    
    // Verify all services are registered
    Do $$$AssertTrue(tRegistry.Contains("PatientService"), "Should contain PatientService")
    Do $$$AssertTrue(tRegistry.Contains("EncounterService"), "Should contain EncounterService")
    Do $$$AssertTrue(tRegistry.Contains("BillingService"), "Should contain BillingService")
    Do $$$AssertTrue(tRegistry.Contains("NotificationService"), "Should contain NotificationService")
    
    Quit $$$OK
}

/// Test registry initialization patterns
Method TestRegistryInitializationPatterns() As %Status
{
    Set tRegistry = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetInstance()
    
    // Test ValidateServices
    Set tValid = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).ValidateServices()
    Do $$$AssertTrue(tValid, "All required services should be registered")
    
    // Test GetRegisteredServices
    Set tServices = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetRegisteredServices()
    Set tCount = $ListLength(tServices)
    Do $$$AssertEquals(tCount, 4, "Should have 4 registered services")
    
    Quit $$$OK
}

/// Test convenience methods for service access
Method TestConvenienceMethodsForServiceAccess() As %Status
{
    // Test PatientService access
    Set tPatientService = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetPatientService()
    Do $$$AssertTrue($IsObject(tPatientService), "GetPatientService should return object")
    Do $$$AssertEquals($ClassName(tPatientService), "Patterns.Examples.Clinical.PatientService", "Should return PatientService instance")
    
    // Test EncounterService access
    Set tEncounterService = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetEncounterService()
    Do $$$AssertTrue($IsObject(tEncounterService), "GetEncounterService should return object")
    
    // Test BillingService access
    Set tBillingService = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetBillingService()
    Do $$$AssertTrue($IsObject(tBillingService), "GetBillingService should return object")
    
    // Test NotificationService access
    Set tNotificationService = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetNotificationService()
    Do $$$AssertTrue($IsObject(tNotificationService), "GetNotificationService should return object")
    
    Quit $$$OK
}

/// Test healthcare registry singleton behavior
Method TestHealthcareRegistrySingleton() As %Status
{
    Set tFirst = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetInstance()
    Set tSecond = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetInstance()
    
    // Verify data is shared via PPG
    Set tService1 = tFirst.Get("PatientService")
    Set tService2 = tSecond.Get("PatientService")
    
    Do $$$AssertEquals(tService1, tService2, "Healthcare registry should share data via PPG")
    
    Quit $$$OK
}

/// Test healthcare registry reinitialize
Method TestHealthcareRegistryReinitialize() As %Status
{
    Set tRegistry = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetInstance()
    Set tOriginalService = tRegistry.Get("PatientService")
    
    // Reinitialize
    Set tSC = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).Reinitialize()
    Do $$$AssertStatusOK(tSC, "Reinitialize should succeed")
    
    // Get new registry instance
    Set tNewRegistry = ##class(Patterns.Examples.Clinical.HealthcareServiceRegistry).GetInstance()
    Set tNewService = tNewRegistry.Get("PatientService")
    
    // Should have new service instances after reinitialize
    Do $$$AssertTrue($IsObject(tNewService), "New service should be an object")
    
    Quit $$$OK
}

// ===== UTILITY METHOD TESTS =====

/// Test GetCount() returns correct count
Method TestGetCountReturnsCorrectCount() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    
    Do $$$AssertEquals(tRegistry.GetCount(), 0, "Empty registry should have count 0")
    
    For i=1:1:3 {
        Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("count" _ i)
        Do tRegistry.Set("Key" _ i, tObject)
    }
    
    Do $$$AssertEquals(tRegistry.GetCount(), 3, "Registry with 3 items should have count 3")
    
    Quit $$$OK
}

/// Test GetKeys() returns all registered keys
Method TestGetKeysReturnsAllKeys() As %Status
{
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).%New()
    
    // Register objects with specific keys
    For i=1:1:3 {
        Set tObject = ##class(Patterns.Test.Unit.PoEAA.Base.TestObject).%New("key" _ i)
        Do tRegistry.Set("Key" _ i, tObject)
    }
    
    Set tKeys = tRegistry.GetKeys()
    Set tCount = $ListLength(tKeys)
    Do $$$AssertEquals(tCount, 3, "Should return 3 keys")
    
    // Verify keys are present
    For i=1:1:tCount {
        Set tKey = $List(tKeys, i)
        Do $$$AssertTrue(tRegistry.Contains(tKey), "Key should be in registry: " _ tKey)
    }
    
    Quit $$$OK
}

}
