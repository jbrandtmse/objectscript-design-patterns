/// Gang of Four Facade Pattern Implementation
/// Provides a simplified interface to complex subsystems
/// 
/// Intent:
/// Provide a unified interface to a set of interfaces in a subsystem.
/// Facade defines a higher-level interface that makes the subsystem easier to use.
/// 
/// Applicability:
/// - You want to provide a simple interface to a complex subsystem
/// - There are many dependencies between clients and implementation classes
/// - You want to layer your subsystems
Class Patterns.GoF.Structural.Facade Extends %RegisteredObject
{

/// Subsystem instances
Property SubsystemA As SubsystemA;

Property SubsystemB As SubsystemB;

Property SubsystemC As SubsystemC;

/// Configuration for the facade
Property Configuration As %DynamicObject;

/// Track facade operations
Property OperationCount As %Integer [ InitialExpression = 0 ];

/// Constructor initializes all subsystems
Method %OnNew(pConfig As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize configuration
        If $ISOBJECT(pConfig) {
            Set ..Configuration = pConfig
        } Else {
            Set ..Configuration = {}
            Set ..Configuration.mode = "STANDARD"
            Set ..Configuration.format = "JSON"
            Set ..Configuration.validation = 1
        }
        
        // Initialize subsystems with proper configuration
        Set ..SubsystemA = ##class(SubsystemA).%New(..Configuration.mode)
        If '..SubsystemA {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to initialize SubsystemA")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // SubsystemB depends on SubsystemA
        Set ..SubsystemB = ##class(SubsystemB).%New(..SubsystemA)
        If '..SubsystemB {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to initialize SubsystemB")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // SubsystemC gets format from configuration
        Set tFormat = ..Configuration.format
        Set ..SubsystemC = ##class(SubsystemC).%New(tFormat)
        If '..SubsystemC {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to initialize SubsystemC")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Wire up subsystem dependencies
        Set tSC = ..SubsystemB.SetSubsystemA(..SubsystemA)
        If $$$ISERR(tSC) Quit
        
        Set tSC = ..SubsystemC.SetSubsystems(..SubsystemA, ..SubsystemB)
        If $$$ISERR(tSC) Quit
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Simplified operation hiding subsystem complexity
/// This is the main facade method that clients use
Method SimplifyOperation(pRequest As %String) As %String
{
    Set tResult = ""
    Set ..OperationCount = ..OperationCount + 1
    
    Try {
        // Validate input if configured
        If ..Configuration.validation {
            If pRequest = "" {
                Set tResult = "ERROR:EMPTY_REQUEST"
                Quit
            }
            If $LENGTH(pRequest) > 1000 {
                Set tResult = "ERROR:REQUEST_TOO_LARGE"
                Quit
            }
        }
        
        // Step 1: Process through SubsystemA (validation and preprocessing)
        Set tStep1 = ..SubsystemA.ComplexOperation1(pRequest)
        If tStep1 [ "ERROR" {
            Set tResult = tStep1
            Quit
        }
        
        // Step 2: Process through SubsystemB (transformation and enrichment)
        Set tStep2 = ..SubsystemB.ProcessData(tStep1)
        If tStep2 [ "ERROR" {
            Set tResult = tStep2
            Quit
        }
        
        // Step 3: Format output through SubsystemC
        Set tResult = ..SubsystemC.FormatOutput(tStep2)
    }
    Catch ex {
        Set tResult = "ERROR:FACADE_OPERATION_FAILED:"_ex.DisplayString()
    }
    
    Quit tResult
}

/// Process batch of requests - demonstrates facade coordinating complex operations
Method ProcessBatch(pRequests As %List) As %DynamicObject
{
    Set tResults = {}
    Set tResults.success = []
    Set tResults.failed = []
    Set tResults.total = 0
    
    Try {
        Set tCount = $LISTLENGTH(pRequests)
        Set tResults.total = tCount
        
        For i=1:1:tCount {
            Set tRequest = $LISTGET(pRequests, i)
            Set tResult = ..SimplifyOperation(tRequest)
            
            Set tItem = {}
            Set tItem.request = tRequest
            Set tItem.result = tResult
            
            If tResult [ "ERROR" {
                Do tResults.failed.%Push(tItem)
            } Else {
                Do tResults.success.%Push(tItem)
            }
        }
        
        // Process any queued items in SubsystemB
        If ..SubsystemB.QueueSize > 0 {
            Set tBatchResult = ..SubsystemB.ProcessBatch()
            Set tResults.batchProcessing = tBatchResult
        }
    }
    Catch ex {
        Set tResults.error = ex.DisplayString()
    }
    
    Quit tResults
}

/// Generate comprehensive report - facade coordinates all subsystems
Method GenerateReport(pOptions As %DynamicObject = "") As %String
{
    Set tReport = ""
    
    Try {
        // Build request if not provided
        If '$ISOBJECT(pOptions) {
            Set pOptions = {}
        }
        
        // Add default options
        If 'pOptions.%IsDefined("title") {
            Set pOptions.title = "Facade Pattern Report"
        }
        If 'pOptions.%IsDefined("author") {
            Set pOptions.author = "System"
        }
        
        // Generate report through SubsystemC (which collects from A and B)
        Set tReport = ..SubsystemC.GenerateReport(pOptions)
    }
    Catch ex {
        Set tReport = "ERROR:REPORT_GENERATION_FAILED:"_ex.DisplayString()
    }
    
    Quit tReport
}

/// Advanced operation demonstrating facade flexibility
Method AdvancedOperation(pData As %String, pMode As %String = "") As %DynamicObject
{
    Set tResult = {}
    
    Try {
        // Use alternative processing path in SubsystemA
        Set tOptions = {}
        Set tOptions.mode = $SELECT(pMode'="":pMode, 1:"THOROUGH")
        
        Set tProcessed = ..SubsystemA.ComplexOperation2(pData, tOptions)
        
        // Prepare for SubsystemB
        Set tPrepared = ..SubsystemA.PrepareForSubsystemB(tProcessed)
        
        // Process through SubsystemB
        Set tTransformed = ..SubsystemB.ProcessData(tPrepared)
        
        // Get complex output from SubsystemB
        Set tComplexOutput = ..SubsystemB.PrepareForSubsystemC(tTransformed)
        
        // Process through SubsystemC
        Set tFinalOutput = ..SubsystemC.ProcessComplexOutput(tComplexOutput)
        
        // Build result object
        Set tResult.status = "SUCCESS"
        Set tResult.output = tFinalOutput
        Set tResult.statistics = ..GetStatistics()
    }
    Catch ex {
        Set tResult.status = "ERROR"
        Set tResult.error = ex.DisplayString()
    }
    
    Quit tResult
}

/// Change output format - facade manages subsystem configuration
Method SetOutputFormat(pFormat As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate format
        Set tValidFormats = $LISTBUILD("JSON", "XML", "CSV", "HTML", "TEXT")
        If '$LISTFIND(tValidFormats, pFormat) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid format: "_pFormat)
            Quit
        }
        
        // Update configuration
        Set ..Configuration.format = pFormat
        
        // Update SubsystemC
        Set tSC = ..SubsystemC.SetFormat(pFormat)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Reset all subsystems - facade coordinates cleanup
Method Reset() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Reset each subsystem
        Set tSC = ..SubsystemA.Reset()
        If $$$ISERR(tSC) Quit
        
        Set tSC = ..SubsystemB.Reset()
        If $$$ISERR(tSC) Quit
        
        Set tSC = ..SubsystemC.Reset()
        If $$$ISERR(tSC) Quit
        
        // Reset facade state
        Set ..OperationCount = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get comprehensive statistics from all subsystems
Method GetStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Try {
        // Facade statistics
        Set tStats.facade = {}
        Set tStats.facade.operations = ..OperationCount
        Set tStats.facade.configuration = ..Configuration
        
        // SubsystemA statistics
        Set tStats.subsystemA = ..SubsystemA.GetStatistics()
        
        // SubsystemB statistics
        Set tStats.subsystemB = ..SubsystemB.GetStatistics()
        
        // SubsystemC statistics
        Set tStats.subsystemC = ..SubsystemC.GetStatistics()
    }
    Catch ex {
        Set tStats.error = ex.DisplayString()
    }
    
    Quit tStats
}

/// Quick operation for simple cases - maximum simplification
Method QuickProcess(pInput As %String) As %String
{
    Set tResult = ""
    
    Try {
        // Skip validation for quick processing
        Set tOldValidation = ..Configuration.validation
        Set ..Configuration.validation = 0
        
        // Use fast processing mode
        Set tOptions = {}
        Set tOptions.mode = "FAST"
        
        // Process through simplified path
        Set tProcessed = ..SubsystemA.ComplexOperation2(pInput, tOptions)
        Set tResult = ..SubsystemC.FormatOutput(tProcessed)
        
        // Restore validation setting
        Set ..Configuration.validation = tOldValidation
    }
    Catch ex {
        Set tResult = "ERROR:QUICK_PROCESS_FAILED"
    }
    
    Quit tResult
}

/// Demonstrate direct subsystem access is still possible
/// (This is a key feature of Facade - it doesn't prevent direct access)
Method GetSubsystemA() As SubsystemA
{
    Quit ..SubsystemA
}

Method GetSubsystemB() As SubsystemB
{
    Quit ..SubsystemB
}

Method GetSubsystemC() As SubsystemC
{
    Quit ..SubsystemC
}

/// Class method to create facade with specific configuration
ClassMethod CreateFacade(pMode As %String = "STANDARD", pFormat As %String = "JSON") As Facade
{
    Set tFacade = ""
    
    Try {
        Set tConfig = {}
        Set tConfig.mode = pMode
        Set tConfig.format = pFormat
        Set tConfig.validation = 1
        
        Set tFacade = ##class(Facade).%New(tConfig)
    }
    Catch ex {
        // Return empty on error
        Set tFacade = ""
    }
    
    Quit tFacade
}

/// Demonstration method showing the complexity hidden by the facade
ClassMethod DemonstrateWithoutFacade(pInput As %String) As %String
{
    Set tResult = ""
    
    Try {
        // This shows what clients would need to do without the facade
        
        // Step 1: Create and configure SubsystemA
        Set tSubsystemA = ##class(SubsystemA).%New("STANDARD")
        
        // Step 2: Perform complex operation 1
        Set tStep1 = tSubsystemA.ComplexOperation1(pInput)
        If tStep1 [ "ERROR" Quit
        
        // Step 3: Create SubsystemB with dependency
        Set tSubsystemB = ##class(SubsystemB).%New(tSubsystemA)
        
        // Step 4: Set the dependency explicitly
        Do tSubsystemB.SetSubsystemA(tSubsystemA)
        
        // Step 5: Process data
        Set tStep2 = tSubsystemB.ProcessData(tStep1)
        If tStep2 [ "ERROR" Quit
        
        // Step 6: Create SubsystemC
        Set tSubsystemC = ##class(SubsystemC).%New("JSON")
        
        // Step 7: Set multiple dependencies
        Do tSubsystemC.SetSubsystems(tSubsystemA, tSubsystemB)
        
        // Step 8: Format output
        Set tResult = tSubsystemC.FormatOutput(tStep2)
        
        // This is much more complex than: facade.SimplifyOperation(pInput)
    }
    Catch ex {
        Set tResult = "ERROR:"_ex.DisplayString()
    }
    
    Quit tResult
}

}
