/// Gang of Four Strategy Pattern - Context for Strategy Execution
/// 
/// Intent:
/// Maintains a reference to a Strategy object and delegates algorithm execution to it.
/// Allows clients to switch strategies at runtime.
/// 
/// Structure:
/// <example>
/// Set context = ##class(Patterns.GoF.Behavioral.StrategyContext).%New()
/// Set strategy = ##class(ConcreteStrategy).%New()
/// Do context.SetStrategy(strategy)
/// Set result = context.ExecuteStrategy(data)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Strategy
/// @since 1.0.0
Class Patterns.GoF.Behavioral.StrategyContext Extends %RegisteredObject
{

/// Current strategy instance
Property CurrentStrategy As Patterns.GoF.Behavioral.Strategy;

/// Strategy cache for performance
Property StrategyCache As %ArrayOfObjects [ Private ];

/// Strategy registry for available strategies
Property StrategyRegistry As %ArrayOfDataTypes [ Private ];

/// Execution metrics
Property ExecutionMetrics As %DynamicObject [ Private ];

/// Default strategy name
Property DefaultStrategyName As %String;

/// Constructor
Method %OnNew(initvalue As %String = "") As %Status
{
    Set tSC = $$$OK
    
    // Initialize collections
    Set ..StrategyCache = ##class(%ArrayOfObjects).%New()
    Set ..StrategyRegistry = ##class(%ArrayOfDataTypes).%New()
    Set ..ExecutionMetrics = {}
    Set ..ExecutionMetrics.totalExecutions = 0
    Set ..ExecutionMetrics.strategyExecutions = {}
    
    // Register default strategies if needed
    Do ..InitializeRegistry()
    
    Quit tSC
}

/// Initialize the strategy registry
Method InitializeRegistry() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    // This will be populated with concrete strategies
    // Can be extended to load strategies dynamically
    
    Quit tSC
}

/// Set the current strategy
/// 
/// @param pStrategy The strategy to use
/// @return %Status
Method SetStrategy(pStrategy As Patterns.GoF.Behavioral.Strategy) As %Status
{
    Set tSC = $$$OK
    
    If '$IsObject(pStrategy) {
        Quit $$$ERROR($$$GeneralError, "Invalid strategy object")
    }
    
    // Validate strategy is proper type
    If '(pStrategy.%IsA("Patterns.GoF.Behavioral.Strategy")) {
        Quit $$$ERROR($$$GeneralError, "Object is not a valid Strategy")
    }
    
    Set ..CurrentStrategy = pStrategy
    
    // Cache the strategy for reuse
    Set strategyName = pStrategy.GetStrategyName()
    Do ..StrategyCache.SetAt(pStrategy, strategyName)
    
    Quit tSC
}

/// Execute using current strategy
/// 
/// @param pData The data to process
/// @return Result from strategy execution
Method ExecuteStrategy(pData As %RegisteredObject = "") As %String
{
    Set result = ""
    Set startTime = $ZHOROLOG
    
    If '$IsObject(..CurrentStrategy) {
        // Try to use default strategy
        If ..DefaultStrategyName '= "" {
            Set tSC = ..SelectStrategy(..DefaultStrategyName)
            If $$$ISERR(tSC) {
                Quit ""
            }
        } Else {
            Quit ""
        }
    }
    
    // Check if strategy can handle the data
    If '..CurrentStrategy.CanHandle(pData) {
        Quit ""
    }
    
    // Execute the strategy
    Set result = ..CurrentStrategy.Execute($this, pData)
    
    // Update metrics
    Set endTime = $ZHOROLOG
    Set executionTime = endTime - startTime
    Do ..UpdateMetrics(..CurrentStrategy.GetStrategyName(), executionTime)
    
    Quit result
}

/// Select strategy based on criteria
/// 
/// @param pCriteria Strategy selection criteria
/// @return %Status
Method SelectStrategy(pCriteria As %String) As %Status
{
    Set tSC = $$$OK
    
    // Check cache first
    If ..StrategyCache.IsDefined(pCriteria) {
        Set ..CurrentStrategy = ..StrategyCache.GetAt(pCriteria)
        Quit tSC
    }
    
    // Check registry for class name
    If ..StrategyRegistry.IsDefined(pCriteria) {
        Set className = ..StrategyRegistry.GetAt(pCriteria)
        Set tSC = ..CreateAndSetStrategy(className)
        Quit tSC
    }
    
    // Try to create strategy directly by class name
    Set tSC = ..CreateAndSetStrategy(pCriteria)
    
    Quit tSC
}

/// Create and set a strategy by class name
/// 
/// @param pClassName The class name to instantiate
/// @return %Status
Method CreateAndSetStrategy(pClassName As %String) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Check if class exists
        If '##class(%Dictionary.CompiledClass).%ExistsId(pClassName) {
            Set tSC = $$$ERROR($$$GeneralError, "Strategy class does not exist: "_pClassName)
            Quit
        }
        
        // Create instance
        Set strategy = $CLASSMETHOD(pClassName, "%New")
        If '$IsObject(strategy) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to create strategy: "_pClassName)
            Quit
        }
        
        // Set as current strategy
        Set tSC = ..SetStrategy(strategy)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Register a strategy in the registry
/// 
/// @param pAlias Alias for the strategy
/// @param pClassName Full class name
/// @return %Status
Method RegisterStrategy(pAlias As %String, pClassName As %String) As %Status
{
    Set tSC = $$$OK
    
    If pAlias = "" {
        Quit $$$ERROR($$$GeneralError, "Strategy alias cannot be empty")
    }
    
    If pClassName = "" {
        Quit $$$ERROR($$$GeneralError, "Strategy class name cannot be empty")
    }
    
    Do ..StrategyRegistry.SetAt(pClassName, pAlias)
    
    Quit tSC
}

/// Get list of registered strategies
/// 
/// @return %ArrayOfDataTypes with strategy aliases
Method GetRegisteredStrategies() As %ArrayOfDataTypes
{
    Set result = ##class(%ArrayOfDataTypes).%New()
    Set key = ""
    
    For {
        Set key = ..StrategyRegistry.Next(key)
        Quit:key=""
        Set className = ..StrategyRegistry.GetAt(key)
        Do result.SetAt(className, key)
    }
    
    Quit result
}

/// Clear strategy cache
/// 
/// @return %Status
Method ClearCache() As %Status
{
    Do ..StrategyCache.Clear()
    Quit $$$OK
}

/// Update execution metrics
/// 
/// @param pStrategyName Name of the executed strategy
/// @param pExecutionTime Time taken for execution
Method UpdateMetrics(pStrategyName As %String, pExecutionTime As %Numeric) [ Private ]
{
    Set ..ExecutionMetrics.totalExecutions = ..ExecutionMetrics.totalExecutions + 1
    
    If '..ExecutionMetrics.strategyExecutions.%IsDefined(pStrategyName) {
        Set newMetrics = {}
        Set newMetrics.count = 0
        Set newMetrics.totalTime = 0
        Do ..ExecutionMetrics.strategyExecutions.%Set(pStrategyName, newMetrics)
    }
    
    Set strategyMetrics = ..ExecutionMetrics.strategyExecutions.%Get(pStrategyName)
    Set strategyMetrics.count = strategyMetrics.count + 1
    Set strategyMetrics.totalTime = strategyMetrics.totalTime + pExecutionTime
    Set strategyMetrics.averageTime = strategyMetrics.totalTime / strategyMetrics.count
    Set strategyMetrics.lastTime = pExecutionTime
}

/// Get execution metrics
/// 
/// @return %DynamicObject with metrics
Method GetMetrics() As %DynamicObject
{
    Quit ..ExecutionMetrics
}

/// Switch strategy conditionally based on data
/// 
/// @param pData Data to evaluate
/// @param pStrategies Array of strategies to test
/// @return %Status
Method SelectStrategyByData(pData As %RegisteredObject, pStrategies As %ListOfDataTypes) As %Status
{
    Set tSC = $$$OK
    
    For i=1:1:pStrategies.Count() {
        Set strategyName = pStrategies.GetAt(i)
        Set tSC = ..SelectStrategy(strategyName)
        If $$$ISERR(tSC) Continue
        
        If ..CurrentStrategy.CanHandle(pData) {
            Quit  // Found suitable strategy
        }
    }
    
    If '$IsObject(..CurrentStrategy) ! ('..CurrentStrategy.CanHandle(pData)) {
        Set tSC = $$$ERROR($$$GeneralError, "No suitable strategy found for data")
    }
    
    Quit tSC
}

/// Set default strategy
/// 
/// @param pStrategyName Default strategy name or alias
/// @return %Status
Method SetDefaultStrategy(pStrategyName As %String) As %Status
{
    Set ..DefaultStrategyName = pStrategyName
    Quit $$$OK
}

}
