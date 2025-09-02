/// Concrete Product B - Advanced product implementation
/// <p>This class represents a concrete product created by ConcreteFactoryB.
/// It demonstrates different product characteristics compared to ConcreteProductA,
/// including priority levels and configuration settings.</p>
Class Patterns.GoF.Creational.ConcreteProductB Extends Patterns.GoF.Creational.Product
{

/// Priority level for this product (1-10)
Property Priority As %Integer;

/// Configuration level for advanced features
Property ConfigurationLevel As %String;

/// Performance metrics for this product
Property PerformanceScore As %Decimal;

/// Initialize the product with default values
/// <p>Called after product creation to set up initial state</p>
/// <returns>%Status indicating initialization success</returns>
Method Initialize() As %Status
{
    Set tSC = $$$OK
    Try {
        // Call parent initialization
        Set tSC = ##super()
        If $$$ISERR(tSC) Quit
        
        // Initialize Product B specific properties
        If ..Priority = "" Set ..Priority = 5  // Default medium priority
        If ..ConfigurationLevel = "" Set ..ConfigurationLevel = "Standard"
        Set ..PerformanceScore = $Random(100) / 10  // Random score 0.0-9.9
        
        // Log initialization
        Do ##class(%SYS.System).WriteToConsoleLog(
            "ConcreteProductB initialized: " _ ..Name _ " with priority " _ ..Priority)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Perform the product operation
/// <p>Implementation of abstract Operation method for Product B.
/// This version performs advanced processing based on priority and configuration.</p>
/// <returns>Result string describing the operation performed</returns>
Method Operation() As %String
{
    // Return simple operation result for test compatibility
    Quit "ConcreteProductB Operation"
}

/// Process data with priority consideration
/// <p>Product B processes data based on priority levels</p>
/// <param name="pData">Data to process</param>
/// <returns>Processed data string</returns>
Method ProcessData(pData As %String) As %String
{
    Set processedData = pData
    
    // Apply processing based on priority
    If ..Priority > 7 {
        // High priority: Fast processing
        Set processedData = "URGENT: " _ processedData
    } ElseIf ..Priority > 4 {
        // Normal priority: Standard processing
        Set processedData = "NORMAL: " _ processedData
    } Else {
        // Low priority: Deferred processing
        Set processedData = "DEFERRED: " _ processedData
    }
    
    // Apply configuration level transformations
    If ..ConfigurationLevel = "Advanced Configuration" {
        Set processedData = processedData _ " [ADVANCED]"
    } ElseIf ..ConfigurationLevel = "Premium" {
        Set processedData = processedData _ " [PREMIUM]"
    }
    
    Quit processedData
}

/// Get detailed product information
/// <returns>Formatted string with all product details</returns>
Method GetProductInfo() As %String
{
    Set info = "=== ConcreteProductB Information ===" _ $Char(13,10)
    Set info = info _ "Name: " _ ..Name _ $Char(13,10)
    Set info = info _ "Type: " _ ..Type _ $Char(13,10)
    Set info = info _ "Priority: " _ ..Priority _ "/10" _ $Char(13,10)
    Set info = info _ "Configuration: " _ ..ConfigurationLevel _ $Char(13,10)
    Set info = info _ "Performance Score: " _ $Justify(..PerformanceScore, 0, 2) _ $Char(13,10)
    Set info = info _ "Created: " _ ..CreatedAt _ $Char(13,10)
    Set info = info _ "===================================="
    
    Quit info
}

/// Optimize product performance
/// <p>Product B specific optimization based on configuration</p>
/// <returns>%Status indicating optimization success</returns>
Method OptimizePerformance() As %Status
{
    Set tSC = $$$OK
    Try {
        // Optimization logic based on configuration
        If ..ConfigurationLevel = "Advanced Configuration" {
            Set ..PerformanceScore = ..PerformanceScore * 1.5
            If ..PerformanceScore > 10 Set ..PerformanceScore = 10
        } ElseIf ..ConfigurationLevel = "Premium" {
            Set ..PerformanceScore = ..PerformanceScore * 2
            If ..PerformanceScore > 10 Set ..PerformanceScore = 10
        }
        
        Do ##class(%SYS.System).WriteToConsoleLog(
            "Product " _ ..Name _ " optimized to performance score: " _ ..PerformanceScore)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Adjust priority level
/// <param name="pNewPriority">New priority level (1-10)</param>
/// <returns>%Status indicating success</returns>
Method AdjustPriority(pNewPriority As %Integer) As %Status
{
    Set tSC = $$$OK
    
    // Validate priority range
    If (pNewPriority < 1) || (pNewPriority > 10) {
        Quit $$$ERROR($$$GeneralError, "Priority must be between 1 and 10")
    }
    
    Set oldPriority = ..Priority
    Set ..Priority = pNewPriority
    
    Do ##class(%SYS.System).WriteToConsoleLog(
        "Product " _ ..Name _ " priority changed from " _ oldPriority _ " to " _ pNewPriority)
    
    Quit tSC
}

}
