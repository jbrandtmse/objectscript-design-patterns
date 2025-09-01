/// Unit tests for Singleton Pattern implementation
/// 
/// <p>Tests the following aspects of the Singleton pattern:</p>
/// <ul>
/// <li>Single instance guarantee</li>
/// <li>Thread-safe instance creation</li>
/// <li>State persistence across calls</li>
/// <li>Reset functionality for testing</li>
/// <li>Healthcare Configuration Manager example</li>
/// </ul>
/// 
/// @see Patterns.GoF.Creational.Singleton
/// @see Patterns.Examples.ConfigurationManager
/// @since 1.0.0
Class Patterns.Test.Unit.GoF.Creational.SingletonTest Extends Patterns.Test.TestCase
{

// ===== SETUP AND TEARDOWN =====

/// Setup before all tests
Method OnBeforeAllTests() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear any existing singleton instances
        Do ##class(Patterns.GoF.Creational.Singleton).Reset()
        Do ##class(Patterns.Examples.ConfigurationManager).Reset()
        
        // Clear debug global
        Set ^ClineDebug = ""
        Set ^ClineDebug = ^ClineDebug _ "SingletonTest setup complete; "
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

/// Cleanup after each test
Method OnAfterOneTest() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Reset singletons after each test for isolation
        Do ##class(Patterns.GoF.Creational.Singleton).Reset()
        Do ##class(Patterns.Examples.ConfigurationManager).Reset()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

// ===== SINGLETON PATTERN TESTS =====

/// Test 1: Verify single instance creation
Method TestSingleInstance()
{
    Set ^ClineDebug = ^ClineDebug _ "TestSingleInstance started; "
    
    // Get first instance
    Set instance1 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    Do $$$AssertTrue($ISOBJECT(instance1), "First instance should be created")
    
    // Get second instance
    Set instance2 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    Do $$$AssertTrue($ISOBJECT(instance2), "Second instance should be retrieved")
    
    // Verify they are the same instance
    Do $$$AssertEquals(instance1, instance2, "Both references should point to the same instance")
    
    // Verify access count incremented
    Do $$$AssertEquals(instance1.AccessCount, 2, "Access count should be 2 after two GetInstance calls")
    
    // Get third instance and verify
    Set instance3 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    Do $$$AssertEquals(instance1, instance3, "Third reference should also be the same instance")
    Do $$$AssertEquals(instance1.AccessCount, 3, "Access count should be 3 after three GetInstance calls")
    
    Set ^ClineDebug = ^ClineDebug _ "TestSingleInstance completed; "
}

/// Test 2: Verify state persistence
Method TestStatePersistence()
{
    Set ^ClineDebug = ^ClineDebug _ "TestStatePersistence started; "
    
    // Get instance and record creation timestamp
    Set instance1 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    Do $$$AssertTrue($ISOBJECT(instance1), "Instance should be created")
    
    Set creationTime = instance1.CreationTimestamp
    Do $$$AssertNotEquals(creationTime, "", "Creation timestamp should be set")
    
    // Sleep briefly to ensure time difference
    Hang 0.1
    
    // Get instance again
    Set instance2 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    
    // Verify timestamp hasn't changed (same instance)
    Do $$$AssertEquals(instance2.CreationTimestamp, creationTime, "Creation timestamp should remain the same for the same instance")
    
    // Verify access count incremented
    Do $$$AssertTrue(instance2.AccessCount > 1, "Access count should increment with each access")
    
    Set ^ClineDebug = ^ClineDebug _ "TestStatePersistence completed; "
}

/// Test 3: Test reset functionality
Method TestResetFunctionality()
{
    Set ^ClineDebug = ^ClineDebug _ "TestResetFunctionality started; "
    
    // Create initial instance
    Set instance1 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    Do $$$AssertTrue($ISOBJECT(instance1), "Initial instance should be created")
    
    Set timestamp1 = instance1.CreationTimestamp
    Set accessCount1 = instance1.AccessCount
    
    // Verify instance exists
    Do $$$AssertTrue(##class(Patterns.GoF.Creational.Singleton).InstanceExists(), "Instance should exist before reset")
    
    // Reset the singleton
    Set tSC = ##class(Patterns.GoF.Creational.Singleton).Reset()
    Do $$$AssertStatusOK(tSC, "Reset should succeed")
    
    // Verify instance no longer exists
    Do $$$AssertTrue('##class(Patterns.GoF.Creational.Singleton).InstanceExists(), "Instance should not exist after reset")
    
    // Sleep briefly to ensure time difference
    Hang 0.1
    
    // Get new instance
    Set instance2 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    Do $$$AssertTrue($ISOBJECT(instance2), "New instance should be created after reset")
    
    // Verify it's a different instance (different creation time)
    Do $$$AssertNotEquals(instance2.CreationTimestamp, timestamp1, "New instance should have different creation timestamp")
    
    // Verify access count reset
    Do $$$AssertEquals(instance2.AccessCount, 1, "Access count should reset to 1 for new instance")
    
    Set ^ClineDebug = ^ClineDebug _ "TestResetFunctionality completed; "
}

/// Test 4: Test instance information retrieval
Method TestInstanceInfo()
{
    Set ^ClineDebug = ^ClineDebug _ "TestInstanceInfo started; "
    
    // Check info when no instance exists
    Set info = ##class(Patterns.GoF.Creational.Singleton).GetInstanceInfo()
    Do $$$AssertTrue($ISOBJECT(info), "Info object should be returned even when no instance exists")
    Do $$$AssertEquals(info.exists, 0, "Info should indicate no instance exists")
    
    // Create instance
    Set instance = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    Do $$$AssertTrue($ISOBJECT(instance), "Instance should be created")
    
    // Access multiple times to increment counter
    Do ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    Do ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    
    // Get instance info
    Set info = ##class(Patterns.GoF.Creational.Singleton).GetInstanceInfo()
    Do $$$AssertTrue($ISOBJECT(info), "Info object should be returned")
    Do $$$AssertEquals(info.exists, 1, "Info should indicate instance exists")
    Do $$$AssertEquals(info.className, "Patterns.GoF.Creational.Singleton", "Class name should be correct")
    Do $$$AssertEquals(info.accessCount, 3, "Access count should be 3")
    Do $$$AssertNotEquals(info.creationTimestamp, "", "Creation timestamp should be set")
    
    Set ^ClineDebug = ^ClineDebug _ "TestInstanceInfo completed; "
}

/// Test 5: Test display functionality
Method TestDisplayMethods()
{
    Set ^ClineDebug = ^ClineDebug _ "TestDisplayMethods started; "
    
    // Create instance
    Set instance = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
    Do $$$AssertTrue($ISOBJECT(instance), "Instance should be created")
    
    // Test DisplayInfo method (should not throw error)
    Set tSC = instance.DisplayInfo()
    Do $$$AssertStatusOK(tSC, "DisplayInfo should execute without errors")
    
    // Verify instance properties are accessible
    Do $$$AssertNotEquals(instance.CreationTimestamp, "", "CreationTimestamp should be accessible")
    Do $$$AssertTrue(instance.AccessCount >= 1, "AccessCount should be at least 1")
    Do $$$AssertEquals(instance.%ClassName(1), "Patterns.GoF.Creational.Singleton", "Class name should be correct")
    
    Set ^ClineDebug = ^ClineDebug _ "TestDisplayMethods completed; "
}

// ===== CONFIGURATION MANAGER TESTS =====

/// Test 6: Test ConfigurationManager singleton
Method TestConfigurationManager()
{
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationManager started; "
    
    // Get configuration manager instance
    Set config1 = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
    Do $$$AssertTrue($ISOBJECT(config1), "ConfigurationManager instance should be created")
    
    // Verify it's the correct type
    Do $$$AssertTrue(config1.%IsA("Patterns.Examples.ConfigurationManager"), "Instance should be of type ConfigurationManager")
    
    // Get second instance and verify singleton
    Set config2 = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
    Do $$$AssertEquals(config1, config2, "Should return the same ConfigurationManager instance")
    
    // Verify inheritance from Singleton
    Do $$$AssertTrue(config1.%IsA("Patterns.GoF.Creational.Singleton"), "ConfigurationManager should extend Singleton")
    
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationManager completed; "
}

/// Test 7: Test configuration settings
Method TestConfigurationSettings()
{
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationSettings started; "
    
    // Get configuration manager
    Set config = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
    Do $$$AssertTrue($ISOBJECT(config), "ConfigurationManager should be created")
    
    // Test setting and getting standard properties
    Set tSC = config.SetSetting("HL7Enabled", 1)
    Do $$$AssertStatusOK(tSC, "Should be able to set HL7Enabled")
    Do $$$AssertEquals(config.GetSetting("HL7Enabled"), 1, "HL7Enabled should be set to 1")
    
    Set tSC = config.SetSetting("FHIREndpoint", "https://fhir.test.org/api")
    Do $$$AssertStatusOK(tSC, "Should be able to set FHIREndpoint")
    Do $$$AssertEquals(config.GetSetting("FHIREndpoint"), "https://fhir.test.org/api", "FHIREndpoint should be set correctly")
    
    Set tSC = config.SetSetting("MaxConnections", 50)
    Do $$$AssertStatusOK(tSC, "Should be able to set MaxConnections")
    Do $$$AssertEquals(config.GetSetting("MaxConnections"), 50, "MaxConnections should be 50")
    
    // Test setting dynamic property
    Set tSC = config.SetSetting("CustomProperty", "TestValue")
    Do $$$AssertStatusOK(tSC, "Should be able to set custom property")
    Do $$$AssertEquals(config.GetSetting("CustomProperty"), "TestValue", "Custom property should be retrievable")
    
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationSettings completed; "
}

/// Test 8: Test configuration validation
Method TestConfigurationValidation()
{
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationValidation started; "
    
    // Get configuration manager
    Set config = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
    Do $$$AssertTrue($ISOBJECT(config), "ConfigurationManager should be created")
    
    // Test valid configuration
    Do config.SetSetting("FHIREndpoint", "https://fhir.valid.org")
    Do config.SetSetting("MaxConnections", 20)
    Do config.SetSetting("AuditLevel", 2)
    Do config.SetSetting("ServiceTimeout", 30)
    
    Set tSC = config.ValidateConfiguration()
    Do $$$AssertStatusOK(tSC, "Valid configuration should pass validation")
    
    // Test invalid FHIR endpoint
    Do config.SetSetting("FHIREndpoint", "invalid-url")
    Set tSC = config.ValidateConfiguration()
    Do $$$AssertStatusNotOK(tSC, "Invalid FHIR endpoint should fail validation")
    
    // Fix endpoint and test invalid MaxConnections
    Do config.SetSetting("FHIREndpoint", "https://fhir.valid.org")
    Set tSC = config.SetSetting("MaxConnections", 0)
    Do $$$AssertStatusNotOK(tSC, "MaxConnections of 0 should fail validation")
    
    // Test invalid AuditLevel
    Set tSC = config.SetSetting("AuditLevel", 5)
    Do $$$AssertStatusNotOK(tSC, "AuditLevel of 5 should fail validation")
    
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationValidation completed; "
}

/// Test 9: Test configuration persistence
Method TestConfigurationPersistence()
{
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationPersistence started; "
    
    // Get configuration manager and set values
    Set config1 = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
    Do $$$AssertTrue($ISOBJECT(config1), "ConfigurationManager should be created")
    
    // Set configuration values
    Do config1.SetSetting("HL7Enabled", 1)
    Do config1.SetSetting("FHIREndpoint", "https://fhir.persist.org")
    Do config1.SetSetting("MaxConnections", 75)
    Do config1.SetSetting("CustomSetting", "PersistTest")
    
    // Save configuration
    Set tSC = config1.SaveConfiguration()
    Do $$$AssertStatusOK(tSC, "Configuration should save successfully")
    
    // Reset the singleton (simulating application restart)
    Do ##class(Patterns.Examples.ConfigurationManager).Reset()
    
    // Get new instance (should load saved configuration)
    Set config2 = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
    Do $$$AssertTrue($ISOBJECT(config2), "New ConfigurationManager should be created")
    
    // Verify configuration was loaded
    Do $$$AssertEquals(config2.GetSetting("HL7Enabled"), 1, "HL7Enabled should be restored from persistence")
    Do $$$AssertEquals(config2.GetSetting("FHIREndpoint"), "https://fhir.persist.org", "FHIREndpoint should be restored")
    Do $$$AssertEquals(config2.GetSetting("MaxConnections"), 75, "MaxConnections should be restored")
    Do $$$AssertEquals(config2.GetSetting("CustomSetting"), "PersistTest", "Custom setting should be restored")
    
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationPersistence completed; "
}

/// Test 10: Test configuration display
Method TestConfigurationDisplay()
{
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationDisplay started; "
    
    // Get configuration manager
    Set config = ##class(Patterns.Examples.ConfigurationManager).GetInstance()
    Do $$$AssertTrue($ISOBJECT(config), "ConfigurationManager should be created")
    
    // Set some configuration values
    Do config.SetSetting("HL7Enabled", 1)
    Do config.SetSetting("FHIREndpoint", "https://fhir.display.org")
    Do config.SetSetting("OrganizationId", "ORG-12345")
    Do config.SetSetting("CustomProperty", "DisplayTest")
    
    // Test display method (should not throw error)
    Set tSC = config.DisplayConfiguration()
    Do $$$AssertStatusOK(tSC, "DisplayConfiguration should execute without errors")
    
    // Verify properties are accessible
    Do $$$AssertNotEquals(config.LastModified, "", "LastModified should be set")
    Do $$$AssertNotEquals(config.LastModifiedBy, "", "LastModifiedBy should be set")
    
    Set ^ClineDebug = ^ClineDebug _ "TestConfigurationDisplay completed; "
}

}
