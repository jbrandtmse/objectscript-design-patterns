/// Simple test for Strategy Pattern functionality
/// This test directly validates the core strategy pattern works
Class Patterns.Test.Unit.GoF.Behavioral.StrategySimpleTest
{

/// Run a simple test of the Strategy pattern
ClassMethod RunTest() As %String
{
    Set ^ClineDebug = ""
    Set result = ""
    Set passed = 0
    Set failed = 0
    
    Try {
        // Test 1: Create billing context
        Set ^ClineDebug = ^ClineDebug_"Test 1: Create billing context; "
        Set context = ##class(Patterns.Examples.BillingContext).%New()
        If '$IsObject(context) {
            Set result = result_"FAIL: Could not create BillingContext; "
            Set failed = failed + 1
        } Else {
            Set result = result_"PASS: BillingContext created; "
            Set passed = passed + 1
        }
        
        // Test 2: Create billing data
        Set ^ClineDebug = ^ClineDebug_"Test 2: Create billing data; "
        Set data = ##class(Patterns.Examples.BillingContext).CreateBillingData(1000, "P001")
        If '$IsObject(data) {
            Set result = result_"FAIL: Could not create billing data; "
            Set failed = failed + 1
        } Else {
            Set result = result_"PASS: Billing data created; "
            Set passed = passed + 1
        }
        
        // Test 3: Select standard strategy
        Set ^ClineDebug = ^ClineDebug_"Test 3: Select standard strategy; "
        Set tSC = context.SelectStrategyByType("Standard")
        If $$$ISERR(tSC) {
            Set result = result_"FAIL: Could not select standard strategy; "
            Set failed = failed + 1
        } Else {
            Set result = result_"PASS: Standard strategy selected; "
            Set passed = passed + 1
        }
        
        // Test 4: Calculate with standard strategy
        Set ^ClineDebug = ^ClineDebug_"Test 4: Calculate with standard; "
        Set calcResult = context.CalculateBill(data)
        If '$IsObject(calcResult) {
            Set result = result_"FAIL: Calculation returned null; "
            Set failed = failed + 1
        } ElseIf 'calcResult.success {
            Set result = result_"FAIL: Calculation not successful; "
            Set failed = failed + 1
        } Else {
            Set result = result_"PASS: Standard calculation successful (amount="_calcResult.finalAmount_"); "
            Set passed = passed + 1
        }
        
        // Test 5: Switch to insurance strategy
        Set ^ClineDebug = ^ClineDebug_"Test 5: Switch to insurance; "
        Set data.patientInfo.insuranceId = "INS123"
        Set tSC = context.SelectStrategyByType("Insurance")
        If $$$ISERR(tSC) {
            Set result = result_"FAIL: Could not select insurance strategy; "
            Set failed = failed + 1
        } Else {
            Set result = result_"PASS: Insurance strategy selected; "
            Set passed = passed + 1
        }
        
        // Test 6: Calculate with insurance strategy
        Set ^ClineDebug = ^ClineDebug_"Test 6: Calculate with insurance; "
        Set calcResult2 = context.CalculateBill(data)
        If '$IsObject(calcResult2) {
            Set result = result_"FAIL: Insurance calculation returned null; "
            Set failed = failed + 1
        } ElseIf 'calcResult2.success {
            Set result = result_"FAIL: Insurance calculation not successful; "
            Set failed = failed + 1
        } Else {
            Set result = result_"PASS: Insurance calculation successful (amount="_calcResult2.finalAmount_"); "
            Set passed = passed + 1
        }
        
        // Test 7: Verify different results
        Set ^ClineDebug = ^ClineDebug_"Test 7: Compare results; "
        If calcResult.finalAmount = calcResult2.finalAmount {
            Set result = result_"FAIL: Same amount for different strategies; "
            Set failed = failed + 1
        } Else {
            Set result = result_"PASS: Different strategies produce different results; "
            Set passed = passed + 1
        }
        
        // Test 8: Direct strategy creation
        Set ^ClineDebug = ^ClineDebug_"Test 8: Direct strategy creation; "
        Set standardStrategy = ##class(Patterns.Examples.StandardBillingStrategy).%New()
        If '$IsObject(standardStrategy) {
            Set result = result_"FAIL: Could not create StandardBillingStrategy; "
            Set failed = failed + 1
        } Else {
            Set result = result_"PASS: StandardBillingStrategy created; "
            Set passed = passed + 1
        }
        
        // Test 9: Calculate with direct strategy
        Set ^ClineDebug = ^ClineDebug_"Test 9: Direct calculation; "
        Set patientInfo = {}
        Set patientInfo.patientId = "P002"
        Set directResult = standardStrategy.CalculateBilling(1500, patientInfo)
        If '$IsObject(directResult) {
            Set result = result_"FAIL: Direct calculation failed; "
            Set failed = failed + 1
        } Else {
            Set result = result_"PASS: Direct calculation successful (amount="_directResult.finalAmount_"); "
            Set passed = passed + 1
        }
        
        // Test 10: Test auto-selection
        Set ^ClineDebug = ^ClineDebug_"Test 10: Auto-selection; "
        Set data3 = ##class(Patterns.Examples.BillingContext).CreateBillingData(500, "P003", "INS789")
        Set tSC = context.AutoSelectStrategy(data3)
        If $$$ISERR(tSC) {
            Set result = result_"FAIL: Auto-selection failed; "
            Set failed = failed + 1
        } Else {
            Set strategyName = context.GetCurrentStrategyName()
            If strategyName [ "Insurance" {
                Set result = result_"PASS: Auto-selected Insurance strategy correctly; "
                Set passed = passed + 1
            } Else {
                Set result = result_"FAIL: Wrong strategy auto-selected: "_strategyName_"; "
                Set failed = failed + 1
            }
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set result = result_"ERROR: "_ex.DisplayString()_"; "
        Set failed = failed + 1
    }
    
    Set ^ClineDebug = ^ClineDebug_"Test complete; "
    Set summary = $CHAR(10,10)_"=== STRATEGY PATTERN TEST RESULTS ==="_$CHAR(10)
    Set summary = summary_"Passed: "_passed_$CHAR(10)
    Set summary = summary_"Failed: "_failed_$CHAR(10)
    Set summary = summary_"Total: "_(passed+failed)_$CHAR(10,10)
    Set summary = summary_"Details:"_$CHAR(10)_result_$CHAR(10)
    
    Quit summary
}

}
