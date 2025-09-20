/// Debug class for investigating Facade test failures
Class Patterns.Test.Unit.GoF.Structural.FacadeDebug
{

/// Debug method to test facade operations
ClassMethod TestFacade() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear debug global
        Set ^ClineDebug = ""
        
        // Create facade
        Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
        Set ^ClineDebug = ^ClineDebug_"Facade created: "_$ISOBJECT(tFacade)_"; "
        
        // Test SimplifyOperation
        Set tResult = tFacade.SimplifyOperation("TestData123")
        Set ^ClineDebug = ^ClineDebug_"SimplifyOperation result: "_tResult_"; "
        
        // Test with empty string
        Set tResult2 = tFacade.SimplifyOperation("")
        Set ^ClineDebug = ^ClineDebug_"Empty input result: "_tResult2_"; "
        
        // Test ProcessBatch
        Set tRequests = $LISTBUILD("Data1", "Data2", "Data3")
        Set tBatchResults = tFacade.ProcessBatch(tRequests)
        Set ^ClineDebug = ^ClineDebug_"Batch total: "_tBatchResults.total_"; "
        Set ^ClineDebug = ^ClineDebug_"Batch success count: "_tBatchResults.success.%Size()_"; "
        
        // Test GenerateReport
        Set tOptions = {}
        Set tOptions.title = "Test Report"
        Set tOptions.author = "Unit Test"
        Set tReport = tFacade.GenerateReport(tOptions)
        Set ^ClineDebug = ^ClineDebug_"Report result: "_tReport_"; "
        
        // Test concurrent operations
        Set tCount = 0
        For i=1:1:5 {
            Set tConcurrentResult = tFacade.SimplifyOperation("Concurrent"_i)
            If tConcurrentResult '[ "ERROR" {
                Set tCount = tCount + 1
            }
            Set ^ClineDebug = ^ClineDebug_"Concurrent"_i_": "_tConcurrentResult_"; "
        }
        Set ^ClineDebug = ^ClineDebug_"Successful concurrent ops: "_tCount_"; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Debug string contains operator issue
ClassMethod DebugStringContains() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear debug global
        Set ^ClineDebug = ""
        
        // Create facade and get a result
        Set tFacade = ##class(Patterns.GoF.Structural.Facade).%New()
        Set tResult = tFacade.SimplifyOperation("TestData123")
        
        Set ^ClineDebug = ^ClineDebug_"Result: "_tResult_"; "
        
        // Test various string contains operations
        Set ^ClineDebug = ^ClineDebug_"Contains STATUS=SUCCESS? "_(tResult [ "STATUS=SUCCESS")_"; "
        Set ^ClineDebug = ^ClineDebug_"Contains ERROR? "_(tResult [ "ERROR")_"; "
        Set ^ClineDebug = ^ClineDebug_"Does not contain ERROR? "_(tResult '[ "ERROR")_"; "
        
        // Test the exact condition from the failing test
        Set tTestCondition = ((tResult '[ "ERROR") && (tResult [ "STATUS=SUCCESS"))
        Set ^ClineDebug = ^ClineDebug_"Test condition result: "_tTestCondition_"; "
        
        // Test with $FIND function as alternative
        Set ^ClineDebug = ^ClineDebug_"$FIND for STATUS=SUCCESS: "_$FIND(tResult, "STATUS=SUCCESS")_"; "
        Set ^ClineDebug = ^ClineDebug_"$FIND for ERROR: "_$FIND(tResult, "ERROR")_"; "
        
        // Check result length and if it's empty
        Set ^ClineDebug = ^ClineDebug_"Result length: "_$LENGTH(tResult)_"; "
        Set ^ClineDebug = ^ClineDebug_"Result is empty? "_(tResult = "")_"; "
        
        // Try upper case conversion
        Set tUpperResult = $ZCONVERT(tResult, "U")
        Set ^ClineDebug = ^ClineDebug_"Upper result contains STATUS=SUCCESS? "_(tUpperResult [ "STATUS=SUCCESS")_"; "
        
        // Extract just the part with STATUS
        Set tStatusPart = $PIECE(tResult, ";STATUS=", 2)
        Set ^ClineDebug = ^ClineDebug_"Status part: "_tStatusPart_"; "
        
        // Test individual conditions separately
        Set tNoError = (tResult '[ "ERROR")
        Set tHasSuccess = (tResult [ "STATUS=SUCCESS")
        Set ^ClineDebug = ^ClineDebug_"NoError="_tNoError_" HasSuccess="_tHasSuccess_"; "
        
        // Test with parentheses
        Set tCombined = (tNoError && tHasSuccess)
        Set ^ClineDebug = ^ClineDebug_"Combined with &&: "_tCombined_"; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
