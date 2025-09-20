/// Healthcare Lab System - Test Processor Subsystem
/// Complex subsystem for processing laboratory tests
/// Handles specimen tracking, test execution, and quality control
Class Patterns.Examples.LabTestProcessor Extends %RegisteredObject
{

/// Reference to test orderer for order validation
Property TestOrdererRef As LabTestOrderer;

/// Specimen tracking database
Property SpecimenDatabase [ MultiDimensional ];

/// Test results storage
Property TestResults [ MultiDimensional ];

/// Quality control data
Property QCData [ MultiDimensional ];

/// Processing queue
Property ProcessingQueue [ MultiDimensional ];

/// Queue size tracker
Property QueueSize As %Integer [ InitialExpression = 0 ];

/// Result counter
Property ResultCounter As %Integer [ InitialExpression = 5000 ];

/// Initialize processor with complex setup
Method %OnNew(pTestOrderer As LabTestOrderer = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Set orderer reference if provided
        If $ISOBJECT(pTestOrderer) {
            Set ..TestOrdererRef = pTestOrderer
        }
        
        // Initialize specimen database
        Set ..SpecimenDatabase("initialized") = $HOROLOG
        
        // Initialize test results storage
        Set ..TestResults("initialized") = $HOROLOG
        
        // Initialize quality control data
        Set ..QCData("CBC", "lastRun") = $HOROLOG
        Set ..QCData("CBC", "status") = "PASS"
        Set ..QCData("CBC", "cv") = "2.5%"
        
        Set ..QCData("CMP", "lastRun") = $HOROLOG
        Set ..QCData("CMP", "status") = "PASS"
        Set ..QCData("CMP", "cv") = "3.1%"
        
        // Initialize processing queue
        Set ..ProcessingQueue("status") = "READY"
        Set ..ProcessingQueue("maxSize") = 50
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Process test order with complex workflow
Method ProcessTestOrder(pOrderInfo As %String) As %String
{
    Set tResult = ""
    
    // Step 1: Validate order format
    If pOrderInfo = "" {
        Quit "ERROR:EMPTY_ORDER"
    }
    
    If pOrderInfo '[ "ORDER:" {
        Quit "ERROR:INVALID_ORDER_FORMAT"
    }
    
    // Step 2: Validate with orderer if available
    If $ISOBJECT(..TestOrdererRef) {
        If '..TestOrdererRef.ValidateOrderDetails(pOrderInfo) {
            Quit "ERROR:ORDER_VALIDATION_FAILED"
        }
    }
    
    // Step 3: Register specimen
    Set tSpecimenId = ..registerSpecimen(pOrderInfo)
    If tSpecimenId [ "ERROR" {
        Quit tSpecimenId
    }
    
    // Step 4: Check quality control
    Set tTestCode = $PIECE($PIECE(pOrderInfo, "TEST:", 2), "|", 1)
    Set tQCStatus = ..checkQualityControl(tTestCode)
    If tQCStatus '= "PASS" {
        Quit "ERROR:QC_FAILED:"_tQCStatus
    }
    
    // Step 5: Determine if batch processing needed
    Set tPriority = $PIECE($PIECE(pOrderInfo, "PRIORITY:", 2), "|", 1)
    If tPriority = "ROUTINE" {
        // Add to batch queue
        Do ..addToProcessingQueue(tSpecimenId, pOrderInfo)
        Set tResult = "QUEUED:SPECIMEN:"_tSpecimenId_"|POSITION:"_..QueueSize
    } Else {
        // Process immediately
        Set tResult = ..processSpecimen(tSpecimenId, pOrderInfo)
    }
    
    Quit tResult
}

/// Process batch of queued tests
Method ProcessBatch() As %String
{
    Set tBatchResults = ""
    Set tProcessed = 0
    Set tErrors = 0
    
    Set tKey = ""
    For {
        Set tKey = $ORDER(..ProcessingQueue(tKey))
        Quit:tKey=""
        
        // Skip metadata
        Continue:((tKey="status")||(tKey="maxSize"))
        
        Set tSpecimenId = $PIECE(tKey, ":", 2)
        Set tOrderInfo = ..ProcessingQueue(tKey)
        
        Set tResult = ..processSpecimen(tSpecimenId, tOrderInfo)
        If tResult [ "ERROR" {
            Set tErrors = tErrors + 1
        } Else {
            Set tProcessed = tProcessed + 1
        }
        
        // Remove from queue
        Kill ..ProcessingQueue(tKey)
    }
    
    // Reset queue
    Set ..QueueSize = 0
    Set ..ProcessingQueue("status") = "READY"
    
    Set tBatchResults = "BATCH:COMPLETE|PROCESSED:"_tProcessed_"|ERRORS:"_tErrors
    Quit tBatchResults
}

/// Get test results
Method GetTestResults(pSpecimenId As %String) As %String
{
    If '$DATA(..TestResults(pSpecimenId)) {
        Quit "ERROR:RESULTS_NOT_FOUND:"_pSpecimenId
    }
    
    Set tResults = ..TestResults(pSpecimenId)
    
    // Add metadata
    Set tResults = tResults_"|RETRIEVED:"_$ZDATETIME($HOROLOG, 3)
    
    Quit tResults
}

/// Prepare results for formatting subsystem
Method PrepareResultsForFormatting(pResultData As %String) As %DynamicObject
{
    Set tOutput = {}
    
    Set tOutput.source = "LabTestProcessor"
    Set tOutput.timestamp = $ZDATETIME($HOROLOG, 3)
    Set tOutput.data = {}
    
    // Parse result data
    If pResultData [ "RESULT:" {
        Set tResultId = $PIECE($PIECE(pResultData, "RESULT:", 2), "|", 1)
        Set tOutput.data.resultId = tResultId
    }
    
    If pResultData [ "SPECIMEN:" {
        Set tSpecimenId = $PIECE($PIECE(pResultData, "SPECIMEN:", 2), "|", 1)
        Set tOutput.data.specimenId = tSpecimenId
    }
    
    If pResultData [ "VALUES:" {
        Set tValues = $PIECE($PIECE(pResultData, "VALUES:", 2), "|", 1)
        Set tOutput.data.testValues = tValues
    }
    
    // Add processing metadata
    Set tOutput.metadata = {}
    Set tOutput.metadata.totalProcessed = ..ResultCounter
    Set tOutput.metadata.queueSize = ..QueueSize
    Set tOutput.metadata.qcStatus = ..getOverallQCStatus()
    
    // Calculate checksum
    Set tOutput.checksum = ..calculateChecksum(pResultData)
    
    Quit tOutput
}

/// Register specimen in tracking system
Method registerSpecimen(pOrderInfo As %String) As %String [ Private ]
{
    // Generate specimen ID
    Set tOrderId = $PIECE($PIECE(pOrderInfo, "ORDER:", 2), "|", 1)
    Set tSpecimenId = "SPEC-"_$PIECE(tOrderId, "-", 2)_"-"_$RANDOM(9999)
    
    // Extract order details
    Set tPatientId = $PIECE($PIECE(pOrderInfo, "PATIENT:", 2), "|", 1)
    Set tTestCode = $PIECE($PIECE(pOrderInfo, "TEST:", 2), "|", 1)
    
    // Register in database
    Set ..SpecimenDatabase(tSpecimenId, "orderId") = tOrderId
    Set ..SpecimenDatabase(tSpecimenId, "patientId") = tPatientId
    Set ..SpecimenDatabase(tSpecimenId, "testCode") = tTestCode
    Set ..SpecimenDatabase(tSpecimenId, "received") = $HOROLOG
    Set ..SpecimenDatabase(tSpecimenId, "status") = "RECEIVED"
    
    Quit tSpecimenId
}

/// Check quality control status
Method checkQualityControl(pTestCode As %String) As %String [ Private ]
{
    // Check if QC data exists
    If '$DATA(..QCData(pTestCode)) {
        // Run QC for new test type
        Do ..runQualityControl(pTestCode)
    }
    
    // Check QC status
    Set tStatus = $GET(..QCData(pTestCode, "status"), "UNKNOWN")
    
    // Check if QC is current (within 24 hours)
    Set tLastRun = $GET(..QCData(pTestCode, "lastRun"), 0)
    If tLastRun '= 0 {
        Set tHoursSince = ($HOROLOG - tLastRun) * 24
        If tHoursSince > 24 {
            // QC expired, run again
            Do ..runQualityControl(pTestCode)
            Set tStatus = ..QCData(pTestCode, "status")
        }
    }
    
    Quit tStatus
}

/// Run quality control for test
Method runQualityControl(pTestCode As %String) [ Private ]
{
    // Simulate QC run
    Set tRandom = $RANDOM(100)
    
    // 95% pass rate
    If tRandom < 95 {
        Set ..QCData(pTestCode, "status") = "PASS"
        Set ..QCData(pTestCode, "cv") = ($RANDOM(30) / 10)_"%"
    } Else {
        Set ..QCData(pTestCode, "status") = "FAIL"
        Set ..QCData(pTestCode, "cv") = ($RANDOM(50) + 50) / 10_"%"
    }
    
    Set ..QCData(pTestCode, "lastRun") = $HOROLOG
}

/// Add to processing queue
Method addToProcessingQueue(pSpecimenId As %String, pOrderInfo As %String) [ Private ]
{
    Set ..QueueSize = ..QueueSize + 1
    Set tKey = "QUEUE:"_pSpecimenId
    Set ..ProcessingQueue(tKey) = pOrderInfo
    Set ..ProcessingQueue("status") = "ITEMS_PENDING"
    
    // Update specimen status
    Set ..SpecimenDatabase(pSpecimenId, "status") = "QUEUED"
}

/// Process individual specimen
Method processSpecimen(pSpecimenId As %String, pOrderInfo As %String) As %String [ Private ]
{
    // Update status
    Set ..SpecimenDatabase(pSpecimenId, "status") = "PROCESSING"
    Set ..SpecimenDatabase(pSpecimenId, "processStart") = $HOROLOG
    
    // Extract test code
    Set tTestCode = $PIECE($PIECE(pOrderInfo, "TEST:", 2), "|", 1)
    
    // Simulate test execution
    Set tTestValues = ..executeTest(tTestCode)
    
    // Generate result ID
    Set ..ResultCounter = ..ResultCounter + 1
    Set tResultId = "RES-"_..ResultCounter
    
    // Store results
    Set tResultData = "RESULT:"_tResultId
    Set tResultData = tResultData_"|SPECIMEN:"_pSpecimenId
    Set tResultData = tResultData_"|TEST:"_tTestCode
    Set tResultData = tResultData_"|VALUES:"_tTestValues
    Set tResultData = tResultData_"|PROCESSED:"_$ZDATETIME($HOROLOG, 3)
    
    Set ..TestResults(pSpecimenId) = tResultData
    Set ..TestResults(tResultId) = tResultData
    
    // Update specimen status
    Set ..SpecimenDatabase(pSpecimenId, "status") = "COMPLETED"
    Set ..SpecimenDatabase(pSpecimenId, "processEnd") = $HOROLOG
    Set ..SpecimenDatabase(pSpecimenId, "resultId") = tResultId
    
    Quit tResultData
}

/// Execute test and generate values
Method executeTest(pTestCode As %String) As %String [ Private ]
{
    Set tValues = ""
    
    // Generate test-specific values
    If pTestCode = "CBC" {
        Set tWBC = (4.5 + ($RANDOM(100) / 10))
        Set tRBC = (4.2 + ($RANDOM(10) / 10))
        Set tHGB = (12 + ($RANDOM(60) / 10))
        Set tValues = "WBC="_tWBC_";RBC="_tRBC_";HGB="_tHGB
    } ElseIf pTestCode = "CMP" {
        Set tGlucose = (70 + $RANDOM(50))
        Set tBUN = (7 + $RANDOM(20))
        Set tCreatinine = (0.5 + ($RANDOM(10) / 10))
        Set tValues = "Glucose="_tGlucose_";BUN="_tBUN_";Creatinine="_tCreatinine
    } ElseIf pTestCode = "TSH" {
        Set tTSH = (0.5 + ($RANDOM(40) / 10))
        Set tValues = "TSH="_tTSH_" mIU/L"
    } ElseIf pTestCode = "HBA1C" {
        Set tHBA1C = (4.0 + ($RANDOM(40) / 10))
        Set tValues = "HbA1c="_tHBA1C_"%"
    } Else {
        Set tValues = "Value="_(50 + $RANDOM(50))
    }
    
    Quit tValues
}

/// Get overall QC status
Method getOverallQCStatus() As %String [ Private ]
{
    Set tOverallStatus = "PASS"
    Set tTestCode = ""
    
    For {
        Set tTestCode = $ORDER(..QCData(tTestCode))
        Quit:tTestCode=""
        
        Set tStatus = $GET(..QCData(tTestCode, "status"), "UNKNOWN")
        If tStatus = "FAIL" {
            Set tOverallStatus = "FAIL"
            Quit
        }
    }
    
    Quit tOverallStatus
}

/// Calculate checksum for data
Method calculateChecksum(pData As %String) As %String [ Private ]
{
    Set tChecksum = 0
    
    For i=1:1:$LENGTH(pData) {
        Set tChecksum = tChecksum + $ASCII($EXTRACT(pData, i))
        Set tChecksum = tChecksum # 65536
    }
    
    Quit $ZHEX(tChecksum)
}

/// Get processing statistics
Method GetStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Set tStats.resultsGenerated = ..ResultCounter - 5000
    Set tStats.specimensProcessed = ..countSpecimens()
    Set tStats.queueSize = ..QueueSize
    Set tStats.qcStatus = ..getOverallQCStatus()
    
    Quit tStats
}

/// Count processed specimens
Method countSpecimens() As %Integer [ Private ]
{
    Set tCount = 0
    Set tSpecimenId = ""
    
    For {
        Set tSpecimenId = $ORDER(..SpecimenDatabase(tSpecimenId))
        Quit:tSpecimenId=""
        Continue:tSpecimenId="initialized"
        Set tCount = tCount + 1
    }
    
    Quit tCount
}

/// Set reference to test orderer
Method SetTestOrderer(pTestOrderer As LabTestOrderer) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$ISOBJECT(pTestOrderer) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid TestOrderer reference")
        } Else {
            Set ..TestOrdererRef = pTestOrderer
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
