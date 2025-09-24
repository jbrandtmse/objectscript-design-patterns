/// Simplified Lab System Facade
/// Provides a simple interface to the complex laboratory testing system
/// Demonstrates the Facade pattern in a healthcare context
/// 
/// Intent:
/// Hide the complexity of lab test ordering, processing, and reporting
/// behind a simple, easy-to-use interface for healthcare applications
Class Patterns.Examples.SimplifiedLabFacade Extends %RegisteredObject
{

/// Lab system subsystems
Property TestOrderer As LabTestOrderer;

Property TestProcessor As LabTestProcessor;

Property ResultFormatter As LabResultFormatter;

/// Tracking for simplified operations
Property OrderTracker [ MultiDimensional ];

Property OperationCounter As %Integer [ InitialExpression = 0 ];

/// Initialize the facade with all subsystems
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize test orderer subsystem
        Set ..TestOrderer = ##class(Patterns.Examples.LabTestOrderer).%New()
        If '..TestOrderer {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to initialize LabTestOrderer")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Initialize test processor with dependency on orderer
        Set ..TestProcessor = ##class(Patterns.Examples.LabTestProcessor).%New(..TestOrderer)
        If '..TestProcessor {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to initialize LabTestProcessor")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Initialize result formatter with default PDF format
        Set ..ResultFormatter = ##class(Patterns.Examples.LabResultFormatter).%New("PDF")
        If '..ResultFormatter {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to initialize LabResultFormatter")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Wire up subsystem dependencies
        Set tSC = ..TestProcessor.SetTestOrderer(..TestOrderer)
        If $$$ISERR(tSC) Quit
        
        Set tSC = ..ResultFormatter.SetSubsystems(..TestOrderer, ..TestProcessor)
        If $$$ISERR(tSC) Quit
        
        // Initialize tracking
        Set ..OrderTracker("initialized") = $HOROLOG
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Simple method to order a lab test - hides all complexity
/// This is the main benefit of the Facade pattern
Method OrderTest(pPatientId As %String, pTestCode As %String, pPriority As %String = "ROUTINE") As %String
{
    Set tResult = ""
    Set ..OperationCounter = ..OperationCounter + 1
    
    Try {
        // Step 1: Create test order (complex process hidden)
        Set tOrderInfo = ..TestOrderer.CreateTestOrder(pPatientId, pTestCode, pPriority)
        If tOrderInfo [ "ERROR" {
            Set tResult = "FAILED:"_$PIECE(tOrderInfo, ":", 2, *)
            Quit
        }
        
        // Step 2: Process the order (complex workflow hidden)
        Set tProcessResult = ..TestProcessor.ProcessTestOrder(tOrderInfo)
        If tProcessResult [ "ERROR" {
            Set tResult = "FAILED:"_$PIECE(tProcessResult, ":", 2, *)
            Quit
        }
        
        // Step 3: Track the order for later retrieval
        Set tOrderId = $PIECE($PIECE(tOrderInfo, "ORDER:", 2), "|", 1)
        Set tSpecimenId = ""
        If tProcessResult [ "SPECIMEN:" {
            Set tSpecimenId = $PIECE($PIECE(tProcessResult, "SPECIMEN:", 2), "|", 1)
        } ElseIf tProcessResult [ "QUEUED:SPECIMEN:" {
            Set tSpecimenId = $PIECE($PIECE(tProcessResult, "SPECIMEN:", 2), "|", 1)
        }
        
        // Store tracking information
        Set ..OrderTracker(tOrderId, "patientId") = pPatientId
        Set ..OrderTracker(tOrderId, "testCode") = pTestCode
        Set ..OrderTracker(tOrderId, "specimenId") = tSpecimenId
        Set ..OrderTracker(tOrderId, "status") = $SELECT(tProcessResult["QUEUED":"PENDING", 1:"PROCESSING")
        Set ..OrderTracker(tOrderId, "created") = $ZDATETIME($HOROLOG, 3)
        
        // Return simple success message
        Set tResult = "SUCCESS:"_tOrderId
    }
    Catch ex {
        Set tResult = "FAILED:SYSTEM_ERROR"
    }
    
    Quit tResult
}

/// Simple method to get test results - hides all complexity
Method GetResults(pOrderId As %String, pFormat As %String = "") As %String
{
    Set tResults = ""
    
    Try {
        // Check if order exists
        If '$DATA(..OrderTracker(pOrderId)) {
            Set tResults = "ERROR:ORDER_NOT_FOUND"
            Quit
        }
        
        // Get specimen ID from tracking
        Set tSpecimenId = ..OrderTracker(pOrderId, "specimenId")
        If tSpecimenId = "" {
            Set tResults = "ERROR:NO_SPECIMEN_ASSOCIATED"
            Quit
        }
        
        // Check if results are ready (may need to process batch first)
        If ..OrderTracker(pOrderId, "status") = "PENDING" {
            // Process any pending batch
            Set tBatchResult = ..TestProcessor.ProcessBatch()
            Set ..OrderTracker(pOrderId, "status") = "COMPLETED"
        }
        
        // Get results from processor
        Set tRawResults = ..TestProcessor.GetTestResults(tSpecimenId)
        If tRawResults [ "ERROR" {
            Set tResults = tRawResults
            Quit
        }
        
        // Format results (complex formatting hidden)
        Set tFormattedResults = ..ResultFormatter.FormatLabResults(tRawResults, pFormat)
        
        // Update tracking
        Set ..OrderTracker(pOrderId, "retrieved") = $ZDATETIME($HOROLOG, 3)
        
        Set tResults = tFormattedResults
    }
    Catch ex {
        Set tResults = "ERROR:RETRIEVAL_FAILED"
    }
    
    Quit tResults
}

/// Extremely simple method for common CBC test
Method OrderCompleteBloodCount(pPatientId As %String) As %String
{
    // This shows how facade can provide task-specific simple methods
    Quit ..OrderTest(pPatientId, "CBC", "ROUTINE")
}

/// Simple method for urgent glucose test
Method OrderUrgentGlucose(pPatientId As %String) As %String
{
    // Facade provides convenient methods for common scenarios
    Quit ..OrderTest(pPatientId, "CMP", "URGENT")
}

/// Get all available tests - simplified view
Method GetAvailableTests() As %String
{
    // Hide the complexity of the test catalog
    Quit ..TestOrderer.GetAvailableTests()
}

/// Get patient information - simplified access
Method GetPatientInfo(pPatientId As %String) As %String
{
    // Provide simple access to patient data
    Quit ..TestOrderer.GetPatientInfo(pPatientId)
}

/// Check order status - simple tracking
Method GetOrderStatus(pOrderId As %String) As %String
{
    If '$DATA(..OrderTracker(pOrderId)) {
        Quit "ERROR:ORDER_NOT_FOUND"
    }
    
    Set tStatus = "ORDER:"_pOrderId
    Set tStatus = tStatus_"|STATUS:"_..OrderTracker(pOrderId, "status")
    Set tStatus = tStatus_"|PATIENT:"_..OrderTracker(pOrderId, "patientId")
    Set tStatus = tStatus_"|TEST:"_..OrderTracker(pOrderId, "testCode")
    Set tStatus = tStatus_"|CREATED:"_..OrderTracker(pOrderId, "created")
    
    If $DATA(..OrderTracker(pOrderId, "retrieved")) {
        Set tStatus = tStatus_"|RETRIEVED:"_..OrderTracker(pOrderId, "retrieved")
    }
    
    Quit tStatus
}

/// Generate comprehensive report - one simple call
Method GeneratePatientReport(pPatientId As %String, pFormat As %String = "") As %String
{
    Set tReport = ""
    
    Try {
        // Build request for formatter
        Set tRequest = {}
        Set tRequest.patientId = pPatientId
        If pFormat '= "" {
            Set tRequest.format = pFormat
        }
        
        // Get all specimen IDs for patient
        Set tSpecimenList = ..getPatientSpecimens(pPatientId)
        If tSpecimenList '= "" {
            Set tRequest.specimenId = $PIECE(tSpecimenList, ",", 1)  // Use most recent
        }
        
        // Generate report (all complexity hidden)
        Set tReport = ..ResultFormatter.GenerateLabReport(tRequest)
    }
    Catch ex {
        Set tReport = "ERROR:REPORT_GENERATION_FAILED"
    }
    
    Quit tReport
}

/// Set report format preference
Method SetReportFormat(pFormat As %String) As %Status
{
    // Simple configuration change
    If $ISOBJECT(..ResultFormatter) {
        If $LISTFIND(..ResultFormatter.SupportedFormats, pFormat) {
            Set ..ResultFormatter.DefaultFormat = pFormat
            Quit $$$OK
        }
        Quit $$$ERROR($$$GeneralError, "Unsupported format: "_pFormat)
    }
    Quit $$$ERROR($$$GeneralError, "ResultFormatter not initialized")
}

/// Get system statistics - simplified view
Method GetSystemStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Try {
        // Aggregate statistics from all subsystems
        Set tStats.operations = ..OperationCounter
        Set tStats.orderer = ..TestOrderer.GetStatistics()
        Set tStats.processor = ..TestProcessor.GetStatistics()
        Set tStats.formatter = ..ResultFormatter.GetStatistics()
        Set tStats.trackedOrders = ..countTrackedOrders()
    }
    Catch ex {
        Set tStats.error = "Failed to collect statistics"
    }
    
    Quit tStats
}

/// Process all pending tests - one simple call
Method ProcessPendingTests() As %String
{
    Set tResult = ""
    
    Try {
        // Process any queued tests
        Set tBatchResult = ..TestProcessor.ProcessBatch()
        
        // Update tracking for processed tests
        Set tOrderId = ""
        For {
            Set tOrderId = $ORDER(..OrderTracker(tOrderId))
            Quit:tOrderId=""
            Continue:tOrderId="initialized"
            
            If ..OrderTracker(tOrderId, "status") = "PENDING" {
                Set ..OrderTracker(tOrderId, "status") = "COMPLETED"
            }
        }
        
        Set tResult = "PROCESSED:"_tBatchResult
    }
    Catch ex {
        Set tResult = "ERROR:BATCH_PROCESSING_FAILED"
    }
    
    Quit tResult
}

/// Helper: Get patient specimens
Method getPatientSpecimens(pPatientId As %String) As %String [ Private ]
{
    Set tSpecimens = ""
    Set tOrderId = ""
    
    For {
        Set tOrderId = $ORDER(..OrderTracker(tOrderId))
        Quit:tOrderId=""
        Continue:tOrderId="initialized"
        
        If ..OrderTracker(tOrderId, "patientId") = pPatientId {
            Set tSpecimenId = ..OrderTracker(tOrderId, "specimenId")
            If tSpecimenId '= "" {
                If tSpecimens '= "" Set tSpecimens = tSpecimens_","
                Set tSpecimens = tSpecimens_tSpecimenId
            }
        }
    }
    
    Quit tSpecimens
}

/// Helper: Count tracked orders
Method countTrackedOrders() As %Integer [ Private ]
{
    Set tCount = 0
    Set tOrderId = ""
    
    For {
        Set tOrderId = $ORDER(..OrderTracker(tOrderId))
        Quit:tOrderId=""
        Continue:tOrderId="initialized"
        Set tCount = tCount + 1
    }
    
    Quit tCount
}

/// Demonstration of complexity without facade
ClassMethod DemonstrateWithoutFacade(pPatientId As %String, pTestCode As %String) As %String
{
    Set tResult = ""
    
    Try {
        // This shows what clients would need to do without the facade
        // Much more complex than: facade.OrderTest(pPatientId, pTestCode)
        
        // Step 1: Create and initialize orderer
        Set tOrderer = ##class(Patterns.Examples.LabTestOrderer).%New()
        
        // Step 2: Create test order with validation
        Set tOrderInfo = tOrderer.CreateTestOrder(pPatientId, pTestCode, "ROUTINE")
        If tOrderInfo [ "ERROR" Quit
        
        // Step 3: Create processor with dependency
        Set tProcessor = ##class(Patterns.Examples.LabTestProcessor).%New(tOrderer)
        
        // Step 4: Set dependency
        Do tProcessor.SetTestOrderer(tOrderer)
        
        // Step 5: Process the order
        Set tProcessResult = tProcessor.ProcessTestOrder(tOrderInfo)
        If tProcessResult [ "ERROR" Quit
        
        // Step 6: Extract specimen ID
        Set tSpecimenId = $PIECE($PIECE(tProcessResult, "SPECIMEN:", 2), "|", 1)
        
        // Step 7: If queued, process batch
        If tProcessResult [ "QUEUED" {
            Do tProcessor.ProcessBatch()
        }
        
        // Step 8: Get results
        Set tRawResults = tProcessor.GetTestResults(tSpecimenId)
        
        // Step 9: Create formatter
        Set tFormatter = ##class(Patterns.Examples.LabResultFormatter).%New("PDF")
        
        // Step 10: Set dependencies
        Do tFormatter.SetSubsystems(tOrderer, tProcessor)
        
        // Step 11: Format results
        Set tResult = tFormatter.FormatLabResults(tRawResults)
    }
    Catch ex {
        Set tResult = "ERROR:"_ex.DisplayString()
    }
    
    Quit tResult
}

/// Create facade with specific configuration
ClassMethod CreateLabFacade() As SimplifiedLabFacade
{
    Set tFacade = ""
    
    Try {
        Set tFacade = ##class(Patterns.Examples.SimplifiedLabFacade).%New()
    }
    Catch ex {
        Set tFacade = ""
    }
    
    Quit tFacade
}

}
