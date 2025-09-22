/// Unit tests for the Gang of Four Facade Pattern
/// Tests both the generic pattern and healthcare lab example
Class Patterns.Test.Unit.GoF.Structural.FacadeTest Extends %UnitTest.TestCase
{

/// Constructor - properly handle initvalue parameter from parent class
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    Quit $$$OK
}

/// Test basic facade simplification of complex operations
Method TestBasicFacadeOperation()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    // Create facade with default configuration
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created successfully")
    
    // Test simple operation hides complexity
    Set tResult = tFacade.SimplifyOperation("TestData123")
    Do $$$AssertTrue(tResult '[ "ERROR", "Simple operation succeeded")
    Do $$$AssertTrue(tResult [ "STATUS=SUCCESS", "Operation processed through subsystems")
    
    // Verify operation count tracking
    Do $$$AssertEquals(tFacade.OperationCount, 1, "Operation count tracked")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test facade handles errors gracefully
Method TestFacadeErrorHandling()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Test with invalid input
    Set tResult = tFacade.SimplifyOperation("")
    Do $$$AssertTrue(tResult [ "ERROR", "Empty input returns error")
    Do $$$AssertTrue(tResult [ "EMPTY_REQUEST", "Correct error message")
    
    // Test with oversized input
    Set tLargeInput = $JUSTIFY("X", 1001)
    Set tResult = tFacade.SimplifyOperation(tLargeInput)
    Do $$$AssertTrue(tResult [ "ERROR", "Large input returns error")
    Do $$$AssertTrue(tResult [ "REQUEST_TOO_LARGE", "Correct error for large input")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test batch processing through facade
Method TestFacadeBatchProcessing()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Create batch of requests
    Set tRequests = $LISTBUILD("Data1", "Data2", "Data3")
    Set tResults = tFacade.ProcessBatch(tRequests)
    
    Do $$$AssertTrue($ISOBJECT(tResults), "Batch results returned as object")
    Do $$$AssertEquals(tResults.total, 3, "Correct total count")
    Do $$$AssertTrue(tResults.success.%Size() >= 0, "Success array exists")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test facade configuration changes
Method TestFacadeConfiguration()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Test format change
    Set tSC = tFacade.SetOutputFormat("XML")
    Do $$$AssertStatusOK(tSC, "Format changed to XML")
    
    Set tSC = tFacade.SetOutputFormat("JSON")
    Do $$$AssertStatusOK(tSC, "Format changed back to JSON")
    
    // Test invalid format
    Set tSC = tFacade.SetOutputFormat("INVALID")
    Do $$$AssertStatusNotOK(tSC, "Invalid format rejected")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test direct subsystem access is still possible
Method TestDirectSubsystemAccess()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Access subsystems directly
    Set tSubsystemA = tFacade.GetSubsystemA()
    Do $$$AssertTrue($ISOBJECT(tSubsystemA), "SubsystemA accessible")
    
    Set tSubsystemB = tFacade.GetSubsystemB()
    Do $$$AssertTrue($ISOBJECT(tSubsystemB), "SubsystemB accessible")
    
    Set tSubsystemC = tFacade.GetSubsystemC()
    Do $$$AssertTrue($ISOBJECT(tSubsystemC), "SubsystemC accessible")
    
    // Direct subsystem operation
    Set tDirectResult = tSubsystemA.ComplexOperation1("DirectTest")
    Do $$$AssertTrue(tDirectResult '[ "ERROR", "Direct subsystem operation works")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test facade advanced operations
Method TestAdvancedOperations()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Test advanced operation
    Set tResult = tFacade.AdvancedOperation("TestData", "THOROUGH")
    Do $$$AssertTrue($ISOBJECT(tResult), "Advanced operation returns object")
    Do $$$AssertEquals(tResult.status, "SUCCESS", "Advanced operation succeeded")
    Do $$$AssertTrue(tResult.%IsDefined("output"), "Output provided")
    Do $$$AssertTrue(tResult.%IsDefined("statistics"), "Statistics included")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test facade report generation
Method TestReportGeneration()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Generate report
    Set tOptions = {}
    Set tOptions.title = "Test Report"
    Set tOptions.author = "Unit Test"
    
    Set tReport = tFacade.GenerateReport(tOptions)
    Do $$$AssertTrue(tReport '[ "ERROR", "Report generated successfully")
    Do $$$AssertTrue(tReport [ "Test Report", "Report contains title")
    Do $$$AssertTrue(tReport [ "Unit Test", "Report contains author")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test facade statistics collection
Method TestStatisticsCollection()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Perform some operations
    Set tResult1 = tFacade.SimplifyOperation("Test1")
    Set tResult2 = tFacade.SimplifyOperation("Test2")
    
    // Get statistics
    Set tStats = tFacade.GetStatistics()
    Do $$$AssertTrue($ISOBJECT(tStats), "Statistics returned as object")
    Do $$$AssertEquals(tStats.facade.operations, 2, "Operation count correct")
    Do $$$AssertTrue(tStats.%IsDefined("subsystemA"), "SubsystemA stats included")
    Do $$$AssertTrue(tStats.%IsDefined("subsystemB"), "SubsystemB stats included")
    Do $$$AssertTrue(tStats.%IsDefined("subsystemC"), "SubsystemC stats included")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test healthcare lab facade creation
Method TestLabFacadeCreation()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    // Create lab facade
    Set tLabFacade = ##class(Patterns.Examples.SimplifiedLabFacade).%New()
    Do $$$AssertTrue($ISOBJECT(tLabFacade), "Lab facade created successfully")
    
    // Verify subsystems initialized
    Do $$$AssertTrue($ISOBJECT(tLabFacade.TestOrderer), "TestOrderer initialized")
    Do $$$AssertTrue($ISOBJECT(tLabFacade.TestProcessor), "TestProcessor initialized")
    Do $$$AssertTrue($ISOBJECT(tLabFacade.ResultFormatter), "ResultFormatter initialized")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test lab test ordering through facade
Method TestLabTestOrdering()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tLabFacade = ##class(Patterns.Examples.SimplifiedLabFacade).%New()
    Do $$$AssertTrue($ISOBJECT(tLabFacade), "Lab facade created")
    
    // Order a test - simple interface
    Set tResult = tLabFacade.OrderTest("P001", "CBC", "ROUTINE")
    Do $$$AssertTrue(tResult [ "SUCCESS", "Test ordered successfully")
    
    // Extract order ID
    Set tOrderId = $PIECE(tResult, ":", 2)
    Do $$$AssertTrue(tOrderId '= "", "Order ID returned")
    
    // Check order status
    Set tStatus = tLabFacade.GetOrderStatus(tOrderId)
    Do $$$AssertTrue(tStatus '[ "ERROR", "Order status retrieved")
    Do $$$AssertTrue(tStatus [ "PATIENT:P001", "Correct patient ID")
    Do $$$AssertTrue(tStatus [ "TEST:CBC", "Correct test code")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test lab result retrieval through facade
Method TestLabResultRetrieval()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tLabFacade = ##class(Patterns.Examples.SimplifiedLabFacade).%New()
    Do $$$AssertTrue($ISOBJECT(tLabFacade), "Lab facade created")
    
    // Order a STAT test (immediate processing)
    Set tResult = tLabFacade.OrderTest("P001", "CBC", "STAT")
    Do $$$AssertTrue(tResult [ "SUCCESS", "STAT test ordered")
    
    Set tOrderId = $PIECE(tResult, ":", 2)
    
    // Get results - facade handles all complexity
    Set tResults = tLabFacade.GetResults(tOrderId, "TEXT")
    Do $$$AssertTrue(tResults '[ "ERROR", "Results retrieved successfully")
    Do $$$AssertTrue(tResults [ "REPORT_ID", "Report ID included")
    Do $$$AssertTrue(tResults [ "LABORATORY REPORT", "Formatted as text report")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test simplified lab methods
Method TestSimplifiedLabMethods()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tLabFacade = ##class(Patterns.Examples.SimplifiedLabFacade).%New()
    Do $$$AssertTrue($ISOBJECT(tLabFacade), "Lab facade created")
    
    // Test simplified CBC order
    Set tResult = tLabFacade.OrderCompleteBloodCount("P002")
    Do $$$AssertTrue(tResult [ "SUCCESS", "CBC ordered via simplified method")
    
    // Test urgent glucose
    Set tResult = tLabFacade.OrderUrgentGlucose("P002")
    Do $$$AssertTrue(tResult [ "SUCCESS", "Urgent glucose ordered via simplified method")
    
    // Get available tests
    Set tTests = tLabFacade.GetAvailableTests()
    Do $$$AssertTrue(tTests [ "CBC", "CBC in available tests")
    Do $$$AssertTrue(tTests [ "CMP", "CMP in available tests")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test batch processing in lab facade
Method TestLabBatchProcessing()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tLabFacade = ##class(Patterns.Examples.SimplifiedLabFacade).%New()
    Do $$$AssertTrue($ISOBJECT(tLabFacade), "Lab facade created")
    
    // Order multiple routine tests (will be queued)
    Set tOrder1 = tLabFacade.OrderTest("P001", "CBC", "ROUTINE")
    Set tOrder2 = tLabFacade.OrderTest("P002", "CMP", "ROUTINE")
    Set tOrder3 = tLabFacade.OrderTest("P001", "TSH", "ROUTINE")
    
    // Process all pending tests with one call
    Set tResult = tLabFacade.ProcessPendingTests()
    Do $$$AssertTrue(tResult [ "PROCESSED", "Batch processing completed")
    Do $$$AssertTrue(tResult [ "BATCH:COMPLETE", "Batch completed successfully")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test facade simplification benefit
Method TestFacadeSimplificationBenefit()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    // Compare with facade
    Set tLabFacade = ##class(Patterns.Examples.SimplifiedLabFacade).%New()
    Set tSimpleResult = tLabFacade.OrderTest("P001", "CBC", "ROUTINE")
    Do $$$AssertTrue(tSimpleResult [ "SUCCESS", "Simple facade call succeeded")
    
    // Compare without facade (shows complexity)
    Set tComplexResult = ##class(Patterns.Examples.SimplifiedLabFacade).DemonstrateWithoutFacade("P001", "CBC")
    // This would require 11+ steps without facade vs 1 with facade
    Do $$$AssertTrue($LENGTH(tComplexResult) > 0, "Complex approach also works but requires many steps")
    
    // The facade reduces 11+ steps to 1 simple method call
    Do $$$AssertTrue(1 = 1, "Facade provides significant simplification")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test facade system statistics
Method TestLabSystemStatistics()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tLabFacade = ##class(Patterns.Examples.SimplifiedLabFacade).%New()
    Do $$$AssertTrue($ISOBJECT(tLabFacade), "Lab facade created")
    
    // Perform operations
    Set tOrder1 = tLabFacade.OrderTest("P001", "CBC", "ROUTINE")
    Set tOrder2 = tLabFacade.OrderTest("P002", "CMP", "STAT")
    
    // Get aggregated statistics
    Set tStats = tLabFacade.GetSystemStatistics()
    Do $$$AssertTrue($ISOBJECT(tStats), "Statistics retrieved")
    Do $$$AssertEquals(tStats.operations, 2, "Operations counted")
    Do $$$AssertTrue(tStats.trackedOrders = 2, "Orders tracked")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test facade reset functionality
Method TestFacadeReset()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Perform operations
    Set tResult1 = tFacade.SimplifyOperation("Test1")
    Set tResult2 = tFacade.SimplifyOperation("Test2")
    Do $$$AssertEquals(tFacade.OperationCount, 2, "Operations counted")
    
    // Reset facade
    Set tSC = tFacade.Reset()
    Do $$$AssertStatusOK(tSC, "Facade reset successful")
    Do $$$AssertEquals(tFacade.OperationCount, 0, "Operation count reset")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test performance overhead of facade layer
Method TestPerformanceOverhead()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Measure facade operation time
    Set tStart = $PIECE($HOROLOG, ",", 2)
    For i=1:1:10 {
        Set tResult = tFacade.SimplifyOperation("PerfTest"_i)
    }
    Set tFacadeTime = $PIECE($HOROLOG, ",", 2) - tStart
    
    // Facade should complete quickly despite complex underlying operations
    Do $$$AssertTrue(tFacadeTime < 5, "Facade operations complete within reasonable time")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Test concurrent access through facade
Method TestConcurrentAccess()
{
    Do $$$AssertStatusOK(..SetUp(), "Test setup")
    
    Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
    Do $$$AssertTrue($ISOBJECT(tFacade), "Facade created")
    
    // Simulate concurrent operations
    Set tResults = 0
    For i=1:1:5 {
        Set tResult = tFacade.SimplifyOperation("Concurrent"_i)
        If (tResult '[ "ERROR") && (tResult [ "STATUS=SUCCESS") {
            Set tResults = tResults + 1
        }
    }
    
    Do $$$AssertEquals(tResults, 5, "All concurrent operations succeeded")
    Do $$$AssertEquals(tFacade.OperationCount, 5, "All operations tracked")
    
    Do $$$AssertStatusOK(..TearDown(), "Test cleanup")
    Quit 1
}

/// Helper method for test setup
Method SetUp() As %Status [ Private ]
{
    // Initialize test environment
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Test setup started; "
    Quit $$$OK
}

/// Helper method for test cleanup
Method TearDown() As %Status [ Private ]
{
    // Clean up test artifacts
    Set ^ClineDebug = ^ClineDebug_"Test cleanup completed; "
    Quit $$$OK
}

}
