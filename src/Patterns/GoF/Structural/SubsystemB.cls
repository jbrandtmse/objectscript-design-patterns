/// Facade Pattern - Subsystem B
/// Complex subsystem that handles data processing and transformation
/// Depends on SubsystemA for preprocessed data
Class Patterns.GoF.Structural.SubsystemB Extends %RegisteredObject
{

/// Reference to SubsystemA for dependency
Property SubsystemARef As SubsystemA;

/// Processing queue for batch operations
Property ProcessingQueue [ MultiDimensional ];

/// Queue counter
Property QueueSize As %Integer [ InitialExpression = 0 ];

/// Processing configuration
Property Config As %DynamicObject;

/// Statistics tracking
Property ProcessedCount As %Integer [ InitialExpression = 0 ];

Property ErrorCount As %Integer [ InitialExpression = 0 ];

/// Complex initialization requiring SubsystemA
Method %OnNew(pSubsystemA As SubsystemA = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize configuration
        Set ..Config = {}
        Set ..Config.timeout = 30
        Set ..Config.retryCount = 3
        Set ..Config.batchSize = 10
        Set ..Config.validationLevel = "STRICT"
        
        // Set SubsystemA reference if provided
        If $ISOBJECT(pSubsystemA) {
            Set ..SubsystemARef = pSubsystemA
        }
        
        // Initialize processing queue
        Set ..ProcessingQueue("initialized") = $HOROLOG
        Set ..ProcessingQueue("status") = "READY"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Process data with dependency on SubsystemA
Method ProcessData(pData As %String) As %String
{
    Set tResult = ""
    
    // Step 1: Parse input from SubsystemA format
    Set tParsed = ..parseSubsystemAFormat(pData)
    If tParsed = "" {
        Set ..ErrorCount = ..ErrorCount + 1
        Quit "ERROR:PARSE_FAILED"
    }
    
    // Step 2: Validate against SubsystemA if available
    If $ISOBJECT(..SubsystemARef) {
        Set tValidation = ..validateWithSubsystemA(tParsed)
        If 'tValidation {
            Set ..ErrorCount = ..ErrorCount + 1
            Quit "ERROR:VALIDATION_FAILED"
        }
    }
    
    // Step 3: Complex multi-stage processing
    Set tStage1 = ..stageOneProcessing(tParsed)
    Set tStage2 = ..stageTwoProcessing(tStage1)
    Set tStage3 = ..stageThreeProcessing(tStage2)
    
    // Step 4: Queue for batch processing if needed
    If ..shouldBatchProcess(tStage3) {
        Do ..addToQueue(tStage3)
        Set tResult = "QUEUED:"_..QueueSize
    } Else {
        Set tResult = ..finalizeProcessing(tStage3)
    }
    
    // Update statistics
    Set ..ProcessedCount = ..ProcessedCount + 1
    
    Quit tResult
}

/// Complex batch processing operation
Method ProcessBatch() As %String
{
    Set tResults = ""
    Set tProcessed = 0
    Set tErrors = 0
    
    // Process items in queue
    Set tKey = ""
    For {
        Set tKey = $ORDER(..ProcessingQueue(tKey))
        Quit:tKey=""
        
        // Skip metadata entries
        Continue:((tKey="initialized")||(tKey="status"))
        
        Set tItem = ..ProcessingQueue(tKey)
        Set tProcessResult = ..processBatchItem(tItem)
        
        If tProcessResult [ "ERROR" {
            Set tErrors = tErrors + 1
        } Else {
            Set tProcessed = tProcessed + 1
        }
        
        // Remove from queue
        Kill ..ProcessingQueue(tKey)
    }
    
    // Update queue size
    Set ..QueueSize = 0
    Set ..ProcessingQueue("status") = "READY"
    
    Set tResults = "BATCH:COMPLETE|Processed:"_tProcessed_"|Errors:"_tErrors
    Quit tResults
}

/// Prepare data for SubsystemC with complex formatting
Method PrepareForSubsystemC(pData As %String) As %DynamicObject
{
    Set tOutput = {}
    
    // Parse the processed data
    Set tParts = $LISTFROMSTRING(pData, "|")
    
    // Build complex output structure
    Set tOutput.source = "SubsystemB"
    Set tOutput.timestamp = $ZDATE($HOROLOG, 3)_" "_$ZTIME($PIECE($HOROLOG, ",", 2))
    Set tOutput.data = {}
    
    // Extract and format data components
    Set tOutput.data.primary = $LISTGET(tParts, 1, "")
    Set tOutput.data.secondary = $LISTGET(tParts, 2, "")
    Set tOutput.data.metadata = {}
    
    // Add processing metadata
    Set tOutput.data.metadata.processedCount = ..ProcessedCount
    Set tOutput.data.metadata.errorCount = ..ErrorCount
    Set tOutput.data.metadata.queueSize = ..QueueSize
    Set tOutput.data.metadata.validationLevel = ..Config.validationLevel
    
    // Add checksum for integrity
    Set tChecksum = ..calculateChecksum(pData)
    Set tOutput.checksum = tChecksum
    
    Quit tOutput
}

/// Parse SubsystemA format - complex parsing logic
Method parseSubsystemAFormat(pData As %String) As %String [ Private ]
{
    Set tParsed = ""
    
    // Expected format: STAGE1|MODE|DATA
    If pData '[ "STAGE1" {
        Quit ""
    }
    
    Set tParts = $LISTFROMSTRING(pData, "|")
    If $LISTLENGTH(tParts) < 3 {
        Quit ""
    }
    
    // Extract components
    Set tStage = $LISTGET(tParts, 1)
    Set tMode = $LISTGET(tParts, 2)
    Set tData = $LISTGET(tParts, 3)
    
    // Reconstruct in SubsystemB format
    Set tParsed = "B-PARSED:"_tMode_":"_tData
    
    // Additional parsing for complex data
    If tData [ "CK" {
        Set tChecksum = $PIECE(tData, "CK", 2)
        Set tChecksum = $PIECE(tChecksum, "|", 1)
        Set tParsed = tParsed_":VERIFIED:"_tChecksum
    }
    
    Quit tParsed
}

/// Validate with SubsystemA
Method validateWithSubsystemA(pData As %String) As %Boolean [ Private ]
{
    Set tValid = 1
    
    Try {
        // Get validation from SubsystemA
        Set tStats = ..SubsystemARef.GetStatistics()
        
        // Check if SubsystemA has processed data
        If tStats '[ "Steps:" {
            Set tValid = 0
        }
        
        // Additional validation logic
        Set tSteps = $PIECE($PIECE(tStats, "Steps:", 2), "|", 1)
        If +tSteps = 0 {
            Set tValid = 0
        }
    }
    Catch ex {
        Set tValid = 0
    }
    
    Quit tValid
}

/// Stage one processing - data enrichment
Method stageOneProcessing(pData As %String) As %String [ Private ]
{
    Set tResult = pData
    
    // Add processing timestamp
    Set tTimestamp = $PIECE($HOROLOG, ",", 2)
    Set tResult = tResult_"|S1:"_tTimestamp
    
    // Data enrichment
    Set tEnriched = ..enrichData(pData)
    Set tResult = tResult_"|DATA:"_tEnriched
    
    Quit tResult
}

/// Stage two processing - transformation
Method stageTwoProcessing(pData As %String) As %String [ Private ]
{
    Set tResult = pData
    
    // Complex transformation rules
    Set tTransformRules = $LISTBUILD("UPPER", "REVERSE", "ENCODE")
    Set tRuleCount = $LISTLENGTH(tTransformRules)
    
    For i=1:1:tRuleCount {
        Set tRule = $LISTGET(tTransformRules, i)
        Set tTransformed = ..applyTransformation(tResult, tRule)
        Set tResult = tTransformed
    }
    
    Set tResult = tResult_"|S2:COMPLETE"
    
    Quit tResult
}

/// Stage three processing - aggregation
Method stageThreeProcessing(pData As %String) As %String [ Private ]
{
    Set tResult = pData
    
    // Aggregate with historical data
    Set tAggregated = ..aggregateData(pData)
    Set tResult = tResult_"|S3:"_tAggregated
    
    // Add final processing marker
    Set tResult = tResult_"|FINAL"
    
    Quit tResult
}

/// Determine if batch processing is needed
Method shouldBatchProcess(pData As %String) As %Boolean [ Private ]
{
    // Batch if queue is building up
    If ..QueueSize >= ..Config.batchSize {
        Quit 1
    }
    
    // Batch if data is marked for batch
    If pData [ "BATCH" {
        Quit 1
    }
    
    // Don't batch final items
    If pData [ "FINAL" {
        Quit 0
    }
    
    Quit 0
}

/// Add item to processing queue
Method addToQueue(pData As %String) [ Private ]
{
    Set ..QueueSize = ..QueueSize + 1
    Set tKey = "ITEM_"_..QueueSize_"_"_$PIECE($HOROLOG, ",", 2)
    Set ..ProcessingQueue(tKey) = pData
    Set ..ProcessingQueue("status") = "ITEMS_PENDING"
}

/// Finalize processing for immediate output
Method finalizeProcessing(pData As %String) As %String [ Private ]
{
    Set tFinal = "B-PROCESSED|"
    
    // Extract key components
    Set tComponents = $LISTFROMSTRING(pData, "|")
    Set tCount = $LISTLENGTH(tComponents)
    
    For i=1:1:tCount {
        Set tComponent = $LISTGET(tComponents, i)
        If tComponent [ ":" {
            Set tKey = $PIECE(tComponent, ":", 1)
            Set tValue = $PIECE(tComponent, ":", 2, *)
            Set tFinal = tFinal_tKey_"="_tValue_";"
        }
    }
    
    Set tFinal = tFinal_"STATUS=SUCCESS"
    
    Quit tFinal
}

/// Process individual batch item
Method processBatchItem(pItem As %String) As %String [ Private ]
{
    Set tResult = ""
    
    Try {
        // Simulate complex batch processing
        Set tProcessed = ..finalizeProcessing(pItem)
        Set tResult = "BATCH_ITEM:"_tProcessed
    }
    Catch ex {
        Set tResult = "ERROR:"_ex.DisplayString()
    }
    
    Quit tResult
}

/// Enrich data with additional information
Method enrichData(pData As %String) As %String [ Private ]
{
    Set tEnriched = ""
    
    // Add system information
    Set tEnriched = tEnriched_"SYS="_$SYSTEM_";"
    
    // Add processing context
    Set tEnriched = tEnriched_"CTX="_..Config.validationLevel_";"
    
    // Add correlation ID
    Set tCorrelationId = $SYSTEM.Util.CreateGUID()
    Set tEnriched = tEnriched_"CORR="_$EXTRACT(tCorrelationId, 1, 8)
    
    Quit tEnriched
}

/// Apply transformation based on rule
Method applyTransformation(pData As %String, pRule As %String) As %String [ Private ]
{
    Set tTransformed = pData
    
    If pRule = "UPPER" {
        Set tTransformed = $ZCONVERT(tTransformed, "U")
    } ElseIf pRule = "REVERSE" {
        // Reverse segments between pipes
        Set tParts = $LISTFROMSTRING(tTransformed, "|")
        Set tReversed = ""
        For i=$LISTLENGTH(tParts):-1:1 {
            If tReversed = "" {
                Set tReversed = $LISTGET(tParts, i)
            } Else {
                Set tReversed = tReversed_"|"_$LISTGET(tParts, i)
            }
        }
        Set tTransformed = tReversed
    } ElseIf pRule = "ENCODE" {
        // Simple encoding - just add encoding markers instead of actual encoding
        Set tTransformed = "[ENCODED]"_tTransformed_"[/ENCODED]"
    }
    
    Quit tTransformed
}

/// Aggregate data with historical context
Method aggregateData(pData As %String) As %String [ Private ]
{
    Set tAggregated = "AGG["
    
    // Add processing statistics
    Set tAggregated = tAggregated_"TOTAL="_..ProcessedCount_";"
    Set tAggregated = tAggregated_"ERRS="_..ErrorCount_";"
    Set tAggregated = tAggregated_"QUEUE="_..QueueSize
    
    Set tAggregated = tAggregated_"]"
    
    Quit tAggregated
}

/// Calculate checksum for data integrity
Method calculateChecksum(pData As %String) As %String [ Private ]
{
    Set tChecksum = 0
    
    For i=1:1:$LENGTH(pData) {
        Set tChar = $EXTRACT(pData, i)
        Set tChecksum = tChecksum + $ASCII(tChar)
        Set tChecksum = tChecksum # 65536  // Keep it manageable
    }
    
    Set tHex = $ZHEX(tChecksum)
    Quit tHex
}

/// Get processing statistics
Method GetStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Set tStats.processed = ..ProcessedCount
    Set tStats.errors = ..ErrorCount
    Set tStats.queueSize = ..QueueSize
    Set tStats.config = ..Config
    Set tStats.status = $GET(..ProcessingQueue("status"), "UNKNOWN")
    
    Quit tStats
}

/// Reset subsystem state
Method Reset() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..ProcessedCount = 0
        Set ..ErrorCount = 0
        Set ..QueueSize = 0
        Kill ..ProcessingQueue
        Set ..ProcessingQueue("initialized") = $HOROLOG
        Set ..ProcessingQueue("status") = "READY"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Set dependency on SubsystemA
Method SetSubsystemA(pSubsystemA As SubsystemA) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$ISOBJECT(pSubsystemA) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid SubsystemA reference")
        } Else {
            Set ..SubsystemARef = pSubsystemA
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
