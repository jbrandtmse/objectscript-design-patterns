/// Unit tests for Strategy Pattern implementation
/// 
/// Tests the Strategy pattern including runtime strategy switching,
/// healthcare billing calculations, and advanced features.
/// 
/// @see Patterns.GoF.Behavioral.Strategy
/// @see Patterns.GoF.Behavioral.StrategyContext
/// @see Patterns.Examples.BillingStrategy
/// @since 1.0.0
Class Patterns.Test.Unit.GoF.Behavioral.StrategyTest Extends %UnitTest.TestCase
{

/// Debug flag for additional output
Property Debug As %Boolean [ InitialExpression = 1 ];

/// Constructor - Initialize test properties
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter - REQUIRED
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    // Initialize debug output
    If ..Debug {
        Set ^ClineDebug = ""
        Set ^ClineDebug = ^ClineDebug_"StrategyTest initialized; "
    }
    
    Quit $$$OK
}

/// Set up test environment before each test
Method OnBeforeOneTest() As %Status
{
    Set tSC = $$$OK
    
    // Clear debug global
    If ..Debug Set ^ClineDebug = ""
    
    Quit tSC
}

/// Clean up after each test
Method OnAfterOneTest() As %Status
{
    Set tSC = $$$OK
    
    Quit tSC
}

/// Test basic strategy pattern creation
Method TestStrategyCreation() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStrategyCreation started; "
    
    // Test abstract strategy creation (should fail)
    Try {
        Set abstractStrategy = ##class(Patterns.GoF.Behavioral.Strategy).%New()
        Do $$$AssertTrue(0, "Should not create abstract strategy")
    }
    Catch ex {
        Do $$$AssertTrue(1, "Cannot instantiate abstract strategy")
    }
    
    // Test concrete strategy creation
    Set standardStrategy = ##class(Patterns.Examples.StandardBillingStrategy).%New()
    Do $$$AssertTrue($IsObject(standardStrategy), "StandardBillingStrategy created")
    Do $$$AssertEquals(standardStrategy.GetStrategyName(), "Patterns.Examples.StandardBillingStrategy", "Strategy name correct")
    
    Set insuranceStrategy = ##class(Patterns.Examples.InsuranceBillingStrategy).%New()
    Do $$$AssertTrue($IsObject(insuranceStrategy), "InsuranceBillingStrategy created")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStrategyCreation completed; "
    
    Quit $$$OK
}

/// Test strategy context functionality
Method TestStrategyContext() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStrategyContext started; "
    
    // Initialize context
    Set testContext = ##class(Patterns.GoF.Behavioral.StrategyContext).%New()
    
    // Test context creation
    Do $$$AssertTrue($IsObject(testContext), "Context created")
    
    // Test setting strategy
    Set strategy = ##class(Patterns.Examples.StandardBillingStrategy).%New()
    Set tSC = testContext.SetStrategy(strategy)
    Do $$$AssertStatusOK(tSC, "Strategy set successfully")
    
    // Test invalid strategy
    Set tSC = testContext.SetStrategy("")
    Do $$$AssertStatusNotOK(tSC, "Setting null strategy fails")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStrategyContext completed; "
    
    Quit $$$OK
}

/// Test runtime strategy switching
Method TestStrategySwitch() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStrategySwitch started; "
    
    // Initialize billing context
    Set billingContext = ##class(Patterns.Examples.BillingContext).%New()
    
    // Create billing data
    Set data = ##class(Patterns.Examples.BillingContext).CreateBillingData(1000, "P001")
    
    // Test with standard strategy
    Set tSC = billingContext.SelectStrategyByType("Standard")
    Do $$$AssertStatusOK(tSC, "Standard strategy selected")
    Do $$$AssertEquals(billingContext.GetCurrentStrategyName(), "Patterns.Examples.StandardBillingStrategy", "Standard strategy active")
    
    // Calculate with standard strategy
    Set result1 = billingContext.CalculateBill(data)
    Do $$$AssertTrue($IsObject(result1), "Result 1 is object")
    Do $$$AssertTrue(result1.success, "Billing calculation successful")
    
    // Switch to insurance strategy
    Set data.patientInfo.insuranceId = "INS123"
    Set tSC = billingContext.SelectStrategyByType("Insurance")
    Do $$$AssertStatusOK(tSC, "Insurance strategy selected")
    Do $$$AssertEquals(billingContext.GetCurrentStrategyName(), "Patterns.Examples.InsuranceBillingStrategy", "Insurance strategy active")
    
    // Calculate with insurance strategy
    Set result2 = billingContext.CalculateBill(data)
    Do $$$AssertTrue($IsObject(result2), "Result 2 is object")
    Do $$$AssertTrue(result2.success, "Insurance calculation successful")
    
    // Results should be different
    Do $$$AssertNotEquals(result1.finalAmount, result2.finalAmount, "Different strategies produce different results")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStrategySwitch completed; "
    
    Quit $$$OK
}

/// Test standard billing calculations
Method TestStandardBilling() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStandardBilling started; "
    
    Set strategy = ##class(Patterns.Examples.StandardBillingStrategy).%New()
    Set charges = 1000
    Set patientInfo = {}
    Set patientInfo.patientId = "P001"
    Set patientInfo.serviceDate = $ZDATE($HOROLOG, 3)
    
    // Test basic calculation
    Set result = strategy.CalculateBilling(charges, patientInfo)
    Do $$$AssertTrue($IsObject(result), "Billing result is object")
    Do $$$AssertEquals(result.strategy, "Standard", "Strategy type correct")
    
    // Check calculations
    Set expectedAdmin = charges * 0.02  // 2% admin fee
    Set expectedTotal = charges + expectedAdmin  // No prompt pay discount
    Do $$$AssertEquals(+result.administrativeFee, expectedAdmin, "Admin fee correct")
    Do $$$AssertEquals(+result.finalAmount, expectedTotal, "Final amount correct")
    
    // Test with prompt payment
    Set patientInfo.promptPayment = 1
    Set result = strategy.CalculateBilling(charges, patientInfo)
    Set expectedDiscount = expectedTotal * 0.05  // 5% prompt payment
    Set expectedFinal = expectedTotal - expectedDiscount
    Do $$$AssertEquals($FNUMBER(result.finalAmount, "", 2), $FNUMBER(expectedFinal, "", 2), "Prompt payment discount applied")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStandardBilling completed; "
    
    Quit $$$OK
}

/// Test insurance billing calculations
Method TestInsuranceBilling() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestInsuranceBilling started; "
    
    Set strategy = ##class(Patterns.Examples.InsuranceBillingStrategy).%New()
    Set charges = 1000
    Set patientInfo = {}
    Set patientInfo.patientId = "P002"
    Set patientInfo.insuranceId = "INS456"
    Set patientInfo.copay = 25
    Set patientInfo.deductibleMet = 200
    Set patientInfo.deductibleMax = 500
    Set patientInfo.coinsurance = 20
    
    // Test calculation
    Set result = strategy.CalculateBilling(charges, patientInfo)
    Do $$$AssertTrue($IsObject(result), "Insurance result is object")
    Do $$$AssertEquals(result.strategy, "Insurance", "Strategy type correct")
    
    // Verify components exist
    Do $$$AssertTrue(result.%IsDefined("negotiatedDiscount"), "Has negotiated discount")
    Do $$$AssertTrue(result.%IsDefined("allowedAmount"), "Has allowed amount")
    Do $$$AssertTrue(result.%IsDefined("copayment"), "Has copayment")
    Do $$$AssertTrue(result.%IsDefined("deductibleApplied"), "Has deductible")
    Do $$$AssertTrue(result.%IsDefined("coinsuranceAmount"), "Has coinsurance")
    Do $$$AssertTrue(result.%IsDefined("patientResponsibility"), "Has patient responsibility")
    
    // Verify copay is applied
    Do $$$AssertEquals(+result.copayment, 25, "Copayment applied")
    
    // Test with met deductible
    Set patientInfo.deductibleMet = 500  // Fully met
    Set result = strategy.CalculateBilling(charges, patientInfo)
    Do $$$AssertEquals(+result.deductibleApplied, 0, "No deductible when fully met")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestInsuranceBilling completed; "
    
    Quit $$$OK
}

/// Test strategy auto-selection
Method TestAutoSelection() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestAutoSelection started; "
    
    // Initialize billing context
    Set billingContext = ##class(Patterns.Examples.BillingContext).%New()
    
    // Test with no insurance - should select Standard
    Set data1 = ##class(Patterns.Examples.BillingContext).CreateBillingData(500, "P003")
    Set tSC = billingContext.AutoSelectStrategy(data1)
    Do $$$AssertStatusOK(tSC, "Auto-selection successful")
    Do $$$AssertEquals(billingContext.GetCurrentStrategyName(), "Patterns.Examples.StandardBillingStrategy", "Standard strategy auto-selected")
    
    // Test with insurance - should select Insurance
    Set data2 = ##class(Patterns.Examples.BillingContext).CreateBillingData(500, "P004", "INS789")
    Set tSC = billingContext.AutoSelectStrategy(data2)
    Do $$$AssertStatusOK(tSC, "Auto-selection with insurance successful")
    Do $$$AssertEquals(billingContext.GetCurrentStrategyName(), "Patterns.Examples.InsuranceBillingStrategy", "Insurance strategy auto-selected")
    
    // Test with explicit strategy type
    Set data3 = {}
    Set data3.charges = 750
    Set data3.strategyType = "Standard"
    Set data3.patientInfo = {"patientId": "P005", "insuranceId": "INS999"}
    Set tSC = billingContext.AutoSelectStrategy(data3)
    Do $$$AssertStatusOK(tSC, "Explicit strategy selection")
    Do $$$AssertEquals(billingContext.GetCurrentStrategyName(), "Patterns.Examples.StandardBillingStrategy", "Explicit strategy type honored")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestAutoSelection completed; "
    
    Quit $$$OK
}

/// Test strategy registry and caching
Method TestRegistryAndCache() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestRegistryAndCache started; "
    
    // Initialize test context
    Set testContext = ##class(Patterns.GoF.Behavioral.StrategyContext).%New()
    
    // Test registry
    Set tSC = testContext.RegisterStrategy("Custom", "Some.Custom.Strategy")
    Do $$$AssertStatusOK(tSC, "Strategy registered")
    
    Set registered = testContext.GetRegisteredStrategies()
    Do $$$AssertTrue($IsObject(registered), "Registry retrieved")
    Do $$$AssertTrue(registered.IsDefined("Custom"), "Custom strategy in registry")
    
    // Test cache clearing
    Set tSC = testContext.ClearCache()
    Do $$$AssertStatusOK(tSC, "Cache cleared")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestRegistryAndCache completed; "
    
    Quit $$$OK
}

/// Test batch processing
Method TestBatchProcessing() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestBatchProcessing started; "
    
    // Initialize billing context
    Set billingContext = ##class(Patterns.Examples.BillingContext).%New()
    
    // Create batch of billing data
    Set batch = []
    Do batch.%Push(##class(Patterns.Examples.BillingContext).CreateBillingData(100, "P101"))
    Do batch.%Push(##class(Patterns.Examples.BillingContext).CreateBillingData(200, "P102", "INS001"))
    Do batch.%Push(##class(Patterns.Examples.BillingContext).CreateBillingData(300, "P103"))
    
    // Process batch
    Set batchResult = billingContext.ProcessBatch(batch)
    Do $$$AssertTrue($IsObject(batchResult), "Batch result is object")
    Do $$$AssertEquals(batchResult.processed, 3, "All items processed")
    Do $$$AssertEquals(batchResult.successful, 3, "All items successful")
    Do $$$AssertEquals(batchResult.failed, 0, "No failures")
    Do $$$AssertTrue(batchResult.totalAmount > 0, "Total amount calculated")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestBatchProcessing completed; "
    
    Quit $$$OK
}

/// Test strategy validation
Method TestStrategyValidation() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStrategyValidation started; "
    
    Set strategy = ##class(Patterns.Examples.StandardBillingStrategy).%New()
    
    // Test CanHandle method
    Set data1 = {"charges": 500, "strategyType": "Standard"}
    Do $$$AssertTrue(strategy.CanHandle(data1), "Can handle standard data")
    
    Set data2 = {"charges": 500, "strategyType": "Insurance"}
    Do $$$AssertTrue('strategy.CanHandle(data2), "Cannot handle insurance data")
    
    // Test eligibility validation
    Set patientInfo = {"patientId": "P201", "serviceDate": "2025-09-28"}
    Do $$$AssertTrue(strategy.ValidateEligibility(patientInfo), "Valid patient info")
    
    Set invalidInfo = {"serviceDate": "2025-09-28"}  // Missing patientId
    Do $$$AssertTrue('strategy.ValidateEligibility(invalidInfo), "Invalid patient info")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestStrategyValidation completed; "
    
    Quit $$$OK
}

/// Test audit trail functionality
Method TestAuditTrail() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestAuditTrail started; "
    
    Set strategy = ##class(Patterns.Examples.StandardBillingStrategy).%New()
    Set charges = 1500
    Set patientInfo = {"patientId": "P301"}
    
    // Calculate and check audit trail
    Set result = strategy.CalculateBilling(charges, patientInfo)
    Do $$$AssertTrue(result.%IsDefined("auditTrail"), "Audit trail exists")
    
    Set audit = result.auditTrail
    Do $$$AssertTrue($IsObject(audit), "Audit trail is object")
    Do $$$AssertTrue(audit.%IsDefined("timestamp"), "Has timestamp")
    Do $$$AssertTrue(audit.%IsDefined("strategyUsed"), "Has strategy name")
    Do $$$AssertEquals(+audit.originalAmount, charges, "Original amount recorded")
    Do $$$AssertTrue(audit.%IsDefined("finalAmount"), "Final amount recorded")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestAuditTrail completed; "
    
    Quit $$$OK
}

/// Test execution metrics tracking
Method TestExecutionMetrics() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestExecutionMetrics started; "
    
    // Initialize billing context
    Set billingContext = ##class(Patterns.Examples.BillingContext).%New()
    
    // Execute multiple strategies
    Set data = ##class(Patterns.Examples.BillingContext).CreateBillingData(750, "P401")
    
    For i=1:1:3 {
        Set result = billingContext.CalculateBill(data)
    }
    
    // Check metrics
    Set metrics = billingContext.GetMetrics()
    Do $$$AssertTrue($IsObject(metrics), "Metrics object exists")
    Do $$$AssertEquals(metrics.totalExecutions, 3, "Execution count tracked")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestExecutionMetrics completed; "
    
    Quit $$$OK
}

/// Test error handling
Method TestErrorHandling() As %Status
{
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestErrorHandling started; "
    
    // Initialize billing context
    Set billingContext = ##class(Patterns.Examples.BillingContext).%New()
    
    // Test invalid billing data
    Set result = billingContext.CalculateBill("")
    Do $$$AssertTrue($IsObject(result), "Result returned for invalid data")
    Do $$$AssertTrue('result.success, "Calculation marked as failed")
    Do $$$AssertTrue(result.%IsDefined("error"), "Error message present")
    
    // Test invalid strategy selection
    Set tSC = billingContext.SelectStrategy("NonExistentStrategy")
    Do $$$AssertStatusNotOK(tSC, "Invalid strategy selection fails")
    
    If ..Debug Set ^ClineDebug = ^ClineDebug_"TestErrorHandling completed; "
    
    Quit $$$OK
}

}
