/// Gang of Four Strategy Pattern - Abstract Base Strategy
/// 
/// Intent:
/// Define a family of algorithms, encapsulate each one, and make them interchangeable.
/// Strategy lets the algorithm vary independently from clients that use it.
/// 
/// Applicability:
/// - Many related classes differ only in their behavior
/// - You need different variants of an algorithm
/// - An algorithm uses data that clients shouldn't know about
/// - A class defines many behaviors as conditional statements
/// 
/// Structure:
/// <example>
/// Set strategy = ##class(ConcreteStrategyA).%New()
/// Set context = ##class(StrategyContext).%New()
/// Do context.SetStrategy(strategy)
/// Set result = context.ExecuteStrategy(data)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.StrategyContext
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Strategy Extends %RegisteredObject [ Abstract ]
{

/// Parameter for pattern type identification
Parameter PATTERNTYPE = "Behavioral";

/// Parameter for pattern name
Parameter PATTERNNAME = "Strategy";

/// Execute the strategy algorithm
/// 
/// @param pContext The context using the strategy
/// @param pData The data to process
/// @return Result of the algorithm execution
Method Execute(pContext As %RegisteredObject, pData As %RegisteredObject) As %String [ Abstract ]
{
    Quit ""
}

/// Validate if strategy can handle the given data
/// 
/// @param pData The data to validate
/// @return 1 if can handle, 0 otherwise
Method CanHandle(pData As %RegisteredObject) As %Boolean
{
    Quit 1
}

/// Get strategy performance metrics
/// 
/// @return JSON object with metrics
Method GetMetrics() As %DynamicObject
{
    Set metrics = {}
    Set metrics.executionCount = 0
    Set metrics.averageExecutionTime = 0
    Set metrics.lastExecutionTime = 0
    Quit metrics
}

/// Get strategy name for identification
/// 
/// @return Strategy name
Method GetStrategyName() As %String
{
    Quit ..%ClassName(1)
}

/// Validate configuration for the strategy
/// 
/// @param pConfig Configuration object
/// @return %Status indicating validation result
Method ValidateConfiguration(pConfig As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    // Default validation - can be overridden
    If '$IsObject(pConfig) {
        Quit $$$OK  // No config is valid
    }
    
    Quit tSC
}

/// Initialize strategy with configuration
/// 
/// @param pConfig Configuration object
/// @return %Status
Method Initialize(pConfig As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    // Validate configuration first
    Set tSC = ..ValidateConfiguration(pConfig)
    If $$$ISERR(tSC) Quit tSC
    
    // Subclasses can override for specific initialization
    
    Quit tSC
}

/// Clone the strategy for thread safety
/// 
/// @return New instance of the strategy
Method Clone() As Patterns.GoF.Behavioral.Strategy
{
    // Create new instance of same type
    Set className = ..%ClassName(1)
    Set newInstance = $CLASSMETHOD(className, "%New")
    Quit newInstance
}

/// Get strategy version
/// 
/// @return Version string
Method GetVersion() As %String
{
    Quit "1.0.0"
}

}
