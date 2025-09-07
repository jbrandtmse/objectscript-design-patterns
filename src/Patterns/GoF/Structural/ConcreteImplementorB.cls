/// ConcreteImplementorB: Alternative concrete implementation with different behavior
/// Part of Bridge Pattern implementation (GoF Structural Pattern)
/// 
/// <p>This class provides an alternative implementation of the Implementor interface.
/// It demonstrates how different implementations can be plugged into the same abstraction,
/// featuring enhanced metrics, validation, and optimization capabilities.</p>
Class Patterns.GoF.Structural.ConcreteImplementorB Extends Patterns.GoF.Structural.Implementor
{

/// Performance metrics for this implementation
Property PerformanceMetrics As %String [ MultiDimensional ];

/// Configuration settings
Property OptimizationLevel As %Integer [ InitialExpression = 1 ];

/// Flag for enhanced mode
Property EnhancedMode As %Boolean [ InitialExpression = 0 ];

/// Cache for optimization
Property Cache As %String [ MultiDimensional ];

/// Constructor - Initialize performance metrics
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize performance tracking
        Set ..PerformanceMetrics("TotalOperations") = 0
        Set ..PerformanceMetrics("CacheHits") = 0
        Set ..PerformanceMetrics("CacheMisses") = 0
        Set ..PerformanceMetrics("ProcessingTime") = 0
        Set ..PerformanceMetrics("OptimizationsSaved") = 0
        
        // Initialize cache
        Kill ..Cache
        Set ..Cache("Initialized") = 1
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Implementation of primitive operation with enhanced features
/// <p>This implementation features caching, optimization, and performance tracking.</p>
Method OperationImpl() As %String
{
    Set result = ""
    
    Try {
        // Track operation
        Set ..PerformanceMetrics("TotalOperations") = ..PerformanceMetrics("TotalOperations") + 1
        
        // Check cache if optimization is enabled
        If (..OptimizationLevel > 0) {
            Set cacheKey = "Op_"_..OptimizationLevel_"_"_..EnhancedMode
            If $Data(..Cache(cacheKey)) {
                Set ..PerformanceMetrics("CacheHits") = ..PerformanceMetrics("CacheHits") + 1
                Set result = "ConcreteImplementorB [CACHED]: "_..Cache(cacheKey)
                Quit
            }
            Set ..PerformanceMetrics("CacheMisses") = ..PerformanceMetrics("CacheMisses") + 1
        }
        
        // Perform actual operation
        Set startTime = $ZHorolog
        
        If ..EnhancedMode {
            Set result = "ConcreteImplementorB [ENHANCED]: Optimized operation level "_..OptimizationLevel
            // Simulate complex processing
            For i=1:1:..OptimizationLevel {
                Set result = result_" [Processing step "_i_"]"
            }
        }
        Else {
            Set result = "ConcreteImplementorB [STANDARD]: Basic operation"
        }
        
        // Track processing time
        Set endTime = $ZHorolog
        Set processingTime = endTime - startTime
        Set ..PerformanceMetrics("ProcessingTime") = ..PerformanceMetrics("ProcessingTime") + processingTime
        
        // Cache result if optimization is enabled
        If (..OptimizationLevel > 0) {
            Set ..Cache(cacheKey) = result
            Set ..PerformanceMetrics("OptimizationsSaved") = ..PerformanceMetrics("OptimizationsSaved") + processingTime
        }
    }
    Catch ex {
        Set result = "ConcreteImplementorB: Error - "_ex.DisplayString()
    }
    
    Quit result
}

/// Get implementation-specific information
Method GetImplementationInfo() As %String
{
    Set info = "ConcreteImplementorB - Enhanced Implementation"
    Set info = info_" | Mode: "_$Select(..EnhancedMode:"Enhanced",1:"Standard")
    Set info = info_" | OptLevel: "_..OptimizationLevel
    Set info = info_" | Operations: "_..PerformanceMetrics("TotalOperations")
    Set info = info_" | CacheHits: "_..PerformanceMetrics("CacheHits")
    Quit info
}

/// Validate implementation state
Method ValidateState() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate optimization level
        If (..OptimizationLevel < 0) || (..OptimizationLevel > 10) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid optimization level: "_..OptimizationLevel)
            Quit
        }
        
        // Validate performance metrics integrity
        If '($Data(..PerformanceMetrics("TotalOperations"))) {
            Set tSC = $$$ERROR($$$GeneralError, "Performance metrics not initialized")
            Quit
        }
        
        // Validate cache if optimization is enabled
        If (..OptimizationLevel > 0) && '($Data(..Cache("Initialized"))) {
            Set tSC = $$$ERROR($$$GeneralError, "Cache not initialized for optimization")
            Quit
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Enable or disable enhanced mode
Method SetEnhancedMode(pEnabled As %Boolean) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..EnhancedMode = pEnabled
        // Clear cache when mode changes
        Kill ..Cache
        Set ..Cache("Initialized") = 1
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Set optimization level (0-10)
Method SetOptimizationLevel(pLevel As %Integer) As %Status
{
    Set tSC = $$$OK
    Try {
        If (pLevel < 0) || (pLevel > 10) {
            Set tSC = $$$ERROR($$$GeneralError, "Optimization level must be between 0 and 10")
            Quit
        }
        Set ..OptimizationLevel = pLevel
        // Clear cache when optimization level changes
        Kill ..Cache
        Set ..Cache("Initialized") = 1
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get performance report
Method GetPerformanceReport() As %String
{
    Set report = "=== Performance Report ==="_$Char(13,10)
    Set report = report_"Total Operations: "_..PerformanceMetrics("TotalOperations")_$Char(13,10)
    Set report = report_"Cache Hits: "_..PerformanceMetrics("CacheHits")_$Char(13,10)
    Set report = report_"Cache Misses: "_..PerformanceMetrics("CacheMisses")_$Char(13,10)
    
    If ..PerformanceMetrics("CacheHits") + ..PerformanceMetrics("CacheMisses") > 0 {
        Set hitRate = (..PerformanceMetrics("CacheHits") / (..PerformanceMetrics("CacheHits") + ..PerformanceMetrics("CacheMisses"))) * 100
        Set report = report_"Cache Hit Rate: "_$Justify(hitRate,0,2)_"%"_$Char(13,10)
    }
    
    Set report = report_"Total Processing Time: "_..PerformanceMetrics("ProcessingTime")_$Char(13,10)
    Set report = report_"Time Saved by Optimization: "_..PerformanceMetrics("OptimizationsSaved")_$Char(13,10)
    
    Quit report
}

/// Clear all caches and reset metrics
Method Reset() As %Status
{
    Set tSC = $$$OK
    Try {
        // Reset performance metrics
        Set ..PerformanceMetrics("TotalOperations") = 0
        Set ..PerformanceMetrics("CacheHits") = 0
        Set ..PerformanceMetrics("CacheMisses") = 0
        Set ..PerformanceMetrics("ProcessingTime") = 0
        Set ..PerformanceMetrics("OptimizationsSaved") = 0
        
        // Clear cache
        Kill ..Cache
        Set ..Cache("Initialized") = 1
        
        // Reset to defaults
        Set ..OptimizationLevel = 1
        Set ..EnhancedMode = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
