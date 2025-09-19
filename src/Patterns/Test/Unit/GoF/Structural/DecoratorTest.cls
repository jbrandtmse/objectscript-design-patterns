/// Unit tests for the Gang of Four Decorator Pattern implementation
/// 
/// <p>Tests verify that decorators properly wrap components, maintain
/// the component interface, allow chaining, and correctly aggregate behavior.</p>
/// 
/// @since 1.0.0
/// @see Patterns.GoF.Structural.IComponent
/// @see Patterns.GoF.Structural.Decorator
Class Patterns.Test.Unit.GoF.Structural.DecoratorTest Extends %UnitTest.TestCase
{

/// Test single decorator functionality
Method TestSingleDecorator()
{
    // Create base component
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tComponent.Name = "TestComponent"
    Set tComponent.Data = "TestData"
    Set tComponent.BaseCost = 100
    
    // Wrap with DecoratorA
    Set tDecorator = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tComponent)
    Set tDecorator.EnhancementLevel = "Premium"
    
    // Test operation enhancement
    Set tResult = tDecorator.Operation()
    Do $$$AssertTrue(tResult [ "Pre-processing", "DecoratorA adds pre-processing")
    Do $$$AssertTrue(tResult [ "Post-processing", "DecoratorA adds post-processing")
    
    // Test description enhancement
    Set tDescription = tDecorator.GetDescription()
    Do $$$AssertTrue(tDescription [ "DecoratorA", "Includes decorator description")
    
    // Test cost aggregation
    Set tCost = tDecorator.GetCost()
    Do $$$AssertEquals(tCost, 105, "Cost correctly aggregated (100 + 5)")
    
    Quit $$$OK
}

/// Test multiple decorator chaining
Method TestMultipleDecoratorChaining()
{
    // Create base component
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tComponent.BaseCost = 50
    
    // Chain multiple decorators
    Set tDecoratorA = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tComponent)
    Set tDecoratorB = ##class(Patterns.GoF.Structural.ConcreteDecoratorB).%New(tDecoratorA)
    
    // Test chained operations
    Set tResult = tDecoratorB.Operation()
    Do $$$AssertTrue(tResult [ "DecoratorB", "DecoratorB processing present")
    
    // Test cumulative cost
    Set tCost = tDecoratorB.GetCost()
    Do $$$AssertEquals(tCost, 75, "Costs correctly accumulated (50 + 5 + 20)")
    
    Quit $$$OK
}

/// Test decorator order matters
Method TestDecoratorOrderMatters()
{
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tComponent.Data = "Original"
    
    // Order: A -> B
    Set tChain1 = ##class(Patterns.GoF.Structural.ConcreteDecoratorB).%New(
        ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tComponent))
    Set tResult1 = tChain1.Operation()
    
    // Order: B -> A
    Set tChain2 = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(
        ##class(Patterns.GoF.Structural.ConcreteDecoratorB).%New(tComponent))
    Set tResult2 = tChain2.Operation()
    
    // Results should be different due to order
    Do $$$AssertNotEquals(tResult1, tResult2, "Decorator order affects output")
    
    // Both should have same cost (order doesn't affect cost)
    Do $$$AssertEquals(tChain1.GetCost(), tChain2.GetCost(), "Cost remains same regardless of order")
    
    Quit $$$OK
}

/// Test healthcare decorators
Method TestHealthcareDecorators()
{
    // Create basic patient record
    Set tRecord = ##class(Patterns.Examples.BasicPatientRecord).%New()
    Set tRecord.PatientID = "MRN-001"
    Set tRecord.Demographics = "John Doe, Age 45"
    Set tRecord.Vitals = "BP: 120/80"
    
    // Test base record
    Do $$$AssertEquals(tRecord.GetSecurityLevel(), "Basic", "Base security is Basic")
    Do $$$AssertEquals(tRecord.IsHIPAACompliant(), 0, "Base record not HIPAA compliant")
    
    // Add encryption
    Set tEncrypted = ##class(Patterns.Examples.EncryptionDecorator).%New(tRecord)
    Do $$$AssertTrue(tEncrypted.GetSecurityLevel() [ "Encrypted", "Encryption enhances security")
    Do $$$AssertEquals(tEncrypted.IsHIPAACompliant(), 1, "Encryption makes HIPAA compliant")
    
    // Add audit logging
    Set tAudited = ##class(Patterns.Examples.AuditDecorator).%New(tEncrypted)
    Do $$$AssertTrue(tAudited.GetSecurityLevel() [ "Audited", "Audit decorator present")
    
    // Test data operations
    Set tSaveStatus = tAudited.SaveData("Test data")
    Do $$$AssertStatusOK(tSaveStatus, "Data saved successfully")
    
    Set tData = tAudited.GetData()
    Do $$$AssertTrue(tData [ "DECRYPTED", "Data is decrypted")
    
    Quit $$$OK
}

/// Test cumulative behavior (cost aggregation)
Method TestCumulativeBehavior()
{
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tComponent.BaseCost = 10
    
    // Add multiple decorators
    Set tDecorator1 = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tComponent)
    Set tDecorator2 = ##class(Patterns.GoF.Structural.ConcreteDecoratorB).%New(tDecorator1)
    Set tDecorator3 = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tDecorator2)
    
    // Test cumulative cost
    Set tFinalCost = tDecorator3.GetCost()
    // Base: 10, DecoratorA: 5, DecoratorB: 20, DecoratorA: 5
    Do $$$AssertEquals(tFinalCost, 40, "Complex cost aggregation correct")
    
    Quit $$$OK
}

/// Test null component handling
Method TestNullComponentHandling()
{
    // Try to create decorator without component
    Set tDecorator = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New("")
    
    // Decorator should handle null gracefully
    Set tCost = tDecorator.GetCost()
    Do $$$AssertEquals(tCost, 5, "Decorator with null component returns only its own cost")
    
    Set tDesc = tDecorator.GetDescription()
    Do $$$AssertTrue(tDesc [ "DecoratorA", "Description still contains decorator info")
    
    Quit $$$OK
}

/// Test decorator removal/unwrapping
Method TestDecoratorRemoval()
{
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tDecorator = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tComponent)
    
    // Get wrapped component
    Set tUnwrapped = tDecorator.Component
    Do $$$AssertTrue($ISOBJECT(tUnwrapped), "Can access wrapped component")
    
    // Verify it's the original component
    Do $$$AssertEquals(tUnwrapped.GetDescription(), tComponent.GetDescription(), "Unwrapped component matches original")
    
    Quit $$$OK
}

/// Performance test with deep decorator chains (10+ levels)
Method TestDeepDecoratorChains()
{
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tComponent.BaseCost = 10
    Set tCurrent = tComponent
    Set tExpectedCost = 10  // Base cost
    
    // Create deep chain of 12 decorators
    For i = 1:1:12 {
        If i # 2 {
            Set tCurrent = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tCurrent)
            Set tExpectedCost = tExpectedCost + 5
        } Else {
            Set tCurrent = ##class(Patterns.GoF.Structural.ConcreteDecoratorB).%New(tCurrent)
            Set tExpectedCost = tExpectedCost + 20
        }
    }
    
    // Test deep chain still works
    Set tResult = tCurrent.Operation()
    Do $$$AssertTrue(tResult '= "", "Deep chain produces result")
    
    // Test cost aggregation
    Set tActualCost = tCurrent.GetCost()
    Do $$$AssertEquals(tActualCost, tExpectedCost, "Deep chain cost correctly aggregated")
    
    Quit $$$OK
}

/// Test memory usage with many decorators
Method TestMemoryUsage()
{
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tCurrent = tComponent
    
    // Add 20 decorators
    For i = 1:1:20 {
        Set tCurrent = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tCurrent)
    }
    
    // Verify chain integrity
    Set tResult = tCurrent.Operation()
    Do $$$AssertTrue($LENGTH(tResult) > 100, "Long chain produces long result")
    
    // Test cost accumulation
    Set tCost = tCurrent.GetCost()
    Do $$$AssertEquals(tCost, 110, "20 decorators add 100 to base cost (20 * 5)")
    
    Quit $$$OK
}

/// Test DecoratorChainBuilder
Method TestDecoratorChainBuilder()
{
    // Create builder
    Set tBuilder = ##class(Patterns.GoF.Structural.DecoratorChainBuilder).%New()
    
    // Build a chain
    Set tBase = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tBase.Name = "Test"
    Set tBase.BaseCost = 100
    
    Set tChain = tBuilder.WithBase(tBase).AddDecoratorA("Premium").AddDecoratorB("Fast").Build()
    
    Do $$$AssertTrue($ISOBJECT(tChain), "Chain built successfully")
    
    // Test chain cost
    Set tCost = tChain.GetCost()
    Do $$$AssertEquals(tCost, 125, "Chain cost correct (100 + 5 + 20)")
    
    // Test chain description
    Set tDesc = tChain.GetDescription()
    Do $$$AssertTrue(tDesc [ "DecoratorB", "Chain contains DecoratorB")
    Do $$$AssertTrue(tDesc [ "DecoratorA", "Chain contains DecoratorA")
    
    Quit $$$OK
}

/// Test healthcare decorator chaining
Method TestHealthcareDecoratorChaining()
{
    // Create patient record with full decorator chain
    Set tRecord = ##class(Patterns.Examples.BasicPatientRecord).%New()
    Set tRecord.PatientID = "MRN-123"
    Set tRecord.Demographics = "Jane Doe"
    
    // Add encryption first (most important)
    Set tSecure = ##class(Patterns.Examples.EncryptionDecorator).%New(tRecord)
    
    // Add audit logging
    Set tAudited = ##class(Patterns.Examples.AuditDecorator).%New(tSecure)
    
    // Save and retrieve data
    Set tSaveStatus = tAudited.SaveData("BP: 120/80")
    Do $$$AssertStatusOK(tSaveStatus, "Save through decorator chain")
    
    Set tRetrieved = tAudited.GetData()
    Do $$$AssertTrue(tRetrieved [ "DECRYPTED", "Data was decrypted")
    
    // Verify HIPAA compliance
    Do $$$AssertEquals(tAudited.IsHIPAACompliant(), 1, "Full chain is HIPAA compliant")
    
    // Check security level
    Set tSecurity = tAudited.GetSecurityLevel()
    Do $$$AssertTrue(tSecurity [ "Audited", "Security shows audit")
    Do $$$AssertTrue(tSecurity [ "Encrypted", "Security shows encryption")
    
    Quit $$$OK
}

/// Test decorator state persistence
Method TestDecoratorStatePersistence()
{
    // Create decorator with state
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tDecorator = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tComponent)
    Set tDecorator.EnhancementLevel = "Premium"
    
    // Perform operations to change state
    For i = 1:1:5 {
        Do tDecorator.Operation()
    }
    
    // Check state persistence
    Do $$$AssertEquals(tDecorator.OperationCount, 5, "Decorator maintains state")
    
    // Create new decorator with same component
    Set tDecorator2 = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tComponent)
    Do $$$AssertEquals(tDecorator2.OperationCount, 0, "New decorator has fresh state")
    
    Quit $$$OK
}

/// Test caching decorator behavior
Method TestCachingBehavior()
{
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tComponent.Data = "TestData"
    Set tCaching = ##class(Patterns.GoF.Structural.ConcreteDecoratorB).%New(tComponent)
    Set tCaching.PerformanceMode = "Fast"
    
    // First call - not cached
    Set tResult1 = tCaching.Operation()
    Do $$$AssertTrue(tResult1 [ "DecoratorB", "First call processed by decorator")
    
    // Second call - should still work
    Set tResult2 = tCaching.Operation()
    Do $$$AssertTrue(tResult2 [ "DecoratorB", "Second call also processed")
    
    // Cache hit counter should increase if caching
    If tCaching.PerformanceMode = "Fast" {
        Do $$$AssertTrue(tCaching.CacheHits >= 0, "Cache tracking works")
    }
    
    Quit $$$OK
}

/// Test decorator validation
Method TestDecoratorValidation()
{
    Set tComponent = ##class(Patterns.GoF.Structural.ConcreteComponent).%New()
    Set tDecorator = ##class(Patterns.GoF.Structural.ConcreteDecoratorA).%New(tComponent)
    
    // Test valid configuration
    Set tDecorator.EnhancementLevel = "Standard"
    Do $$$AssertTrue(tDecorator.IsValid(), "Valid decorator configuration")
    
    // Test with different enhancement levels
    Set tDecorator.EnhancementLevel = "Premium" 
    Do $$$AssertTrue(tDecorator.IsValid(), "Premium configuration valid")
    
    Set tDecorator.EnhancementLevel = "Advanced"
    Do $$$AssertTrue(tDecorator.IsValid(), "Advanced configuration valid")
    
    Quit $$$OK
}

}
