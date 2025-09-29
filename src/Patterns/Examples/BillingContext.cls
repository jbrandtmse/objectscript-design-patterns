/// Healthcare Billing Context - Manages Billing Strategies
/// 
/// This class demonstrates the Strategy Pattern context in a healthcare
/// billing scenario, managing different billing strategies based on payer type.
/// 
/// <example>
/// Set context = ##class(Patterns.Examples.BillingContext).%New()
/// Set data = {}
/// Set data.charges = 1500.00
/// Set data.patientInfo = {"patientId": "P123", "insuranceId": "INS456"}
/// Set data.strategyType = "Insurance"
/// Do context.SelectStrategyByType(data.strategyType)
/// Set result = context.CalculateBill(data)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.StrategyContext
/// @see Patterns.Examples.BillingStrategy
/// @since 1.0.0
Class Patterns.Examples.BillingContext Extends Patterns.GoF.Behavioral.StrategyContext
{

/// Parameter for context type
Parameter CONTEXTTYPE = "HealthcareBilling";

/// Constructor - Initialize with billing strategies
Method %OnNew(initvalue As %String = "") As %Status
{
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    // Register available billing strategies
    Do ..RegisterStrategy("Standard", "Patterns.Examples.StandardBillingStrategy")
    Do ..RegisterStrategy("Insurance", "Patterns.Examples.InsuranceBillingStrategy")
    
    // Set default strategy
    Do ..SetDefaultStrategy("Standard")
    
    Quit tSC
}

/// Calculate bill using current strategy
/// 
/// @param pBillingData The billing data including charges and patient info
/// @return %DynamicObject with billing calculation results
Method CalculateBill(pBillingData As %DynamicObject) As %DynamicObject
{
    Set result = {}
    
    // Validate input
    If '$IsObject(pBillingData) {
        Set result.error = "Invalid billing data"
        Set result.success = 0
        Quit result
    }
    
    // Execute strategy
    Set strategyResult = ..ExecuteStrategy(pBillingData)
    
    // If strategy returned a string (final amount), create full result
    If '$IsObject(strategyResult) {
        Set result.finalAmount = strategyResult
        Set result.strategy = ..GetCurrentStrategyName()
        Set result.success = 1
    } Else {
        Set result = strategyResult
        Set result.success = 1
    }
    
    // Add context information
    Set result.contextType = ..#CONTEXTTYPE
    Set result.timestamp = $ZDATETIME($ZTIMESTAMP, 3)
    
    Quit result
}

/// Select strategy based on billing type
/// 
/// @param pBillingType The type of billing (Standard, Insurance, etc.)
/// @return %Status
Method SelectStrategyByType(pBillingType As %String) As %Status
{
    Set tSC = $$$OK
    
    If pBillingType = "" {
        Set pBillingType = "Standard"
    }
    
    Set tSC = ..SelectStrategy(pBillingType)
    
    Quit tSC
}

/// Get current strategy name
/// 
/// @return Strategy name or empty string
Method GetCurrentStrategyName() As %String
{
    If '$IsObject(..CurrentStrategy) Quit ""
    Quit ..CurrentStrategy.GetStrategyName()
}

/// Auto-select best strategy based on data
/// 
/// @param pBillingData The billing data
/// @return %Status
Method AutoSelectStrategy(pBillingData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    If '$IsObject(pBillingData) {
        Quit ..SelectStrategy("Standard")
    }
    
    // Check if strategy type is specified
    If pBillingData.%IsDefined("strategyType") && (pBillingData.strategyType '= "") {
        Quit ..SelectStrategy(pBillingData.strategyType)
    }
    
    // Auto-detect based on patient info
    If pBillingData.%IsDefined("patientInfo") {
        Set patientInfo = pBillingData.patientInfo
        If $IsObject(patientInfo) {
            // Check for insurance
            If patientInfo.%IsDefined("insuranceId") && (patientInfo.insuranceId '= "") {
                Quit ..SelectStrategy("Insurance")
            }
        }
    }
    
    // Default to standard billing
    Quit ..SelectStrategy("Standard")
}

/// Get available billing strategies
/// 
/// @return %DynamicObject with strategy information
Method GetAvailableStrategies() As %DynamicObject
{
    Set strategies = {}
    Set strategies.available = []
    
    Set registered = ..GetRegisteredStrategies()
    Set key = ""
    
    For {
        Set key = registered.Next(key)
        Quit:key=""
        
        Set strategyInfo = {}
        Set strategyInfo.name = key
        Set strategyInfo.className = registered.GetAt(key)
        
        // Try to get rules from strategy
        Try {
            Set strategy = $CLASSMETHOD(strategyInfo.className, "%New")
            If $IsObject(strategy) {
                Set strategyInfo.rules = strategy.GetBillingRules()
            }
        }
        Catch ex {
            Set strategyInfo.rules = {}
        }
        
        Do strategies.available.%Push(strategyInfo)
    }
    
    Quit strategies
}

/// Process batch of billing calculations
/// 
/// @param pBillingBatch Array of billing data objects
/// @return %DynamicObject with batch results
Method ProcessBatch(pBillingBatch As %DynamicArray) As %DynamicObject
{
    Set batchResult = {}
    Set batchResult.processed = 0
    Set batchResult.successful = 0
    Set batchResult.failed = 0
    Set batchResult.totalAmount = 0
    Set batchResult.results = []
    
    If '$IsObject(pBillingBatch) {
        Set batchResult.error = "Invalid batch data"
        Quit batchResult
    }
    
    // Process each billing item
    For i=0:1:pBillingBatch.%Size()-1 {
        Set billingData = pBillingBatch.%Get(i)
        
        // Auto-select strategy for each item
        Set tSC = ..AutoSelectStrategy(billingData)
        
        // Calculate billing
        Set itemResult = ..CalculateBill(billingData)
        
        // Track results
        Set batchResult.processed = batchResult.processed + 1
        If itemResult.success {
            Set batchResult.successful = batchResult.successful + 1
            If itemResult.%IsDefined("finalAmount") {
                Set batchResult.totalAmount = batchResult.totalAmount + itemResult.finalAmount
            }
        } Else {
            Set batchResult.failed = batchResult.failed + 1
        }
        
        Do batchResult.results.%Push(itemResult)
    }
    
    // Add summary
    Set batchResult.averageAmount = 0
    If batchResult.successful > 0 {
        Set batchResult.averageAmount = $FNUMBER(batchResult.totalAmount / batchResult.successful, "", 2)
    }
    Set batchResult.totalAmount = $FNUMBER(batchResult.totalAmount, "", 2)
    
    Quit batchResult
}

/// Create billing data object helper
/// 
/// @param pCharges Base charges
/// @param pPatientId Patient identifier
/// @param pInsuranceId Insurance identifier (optional)
/// @return %DynamicObject with billing data
ClassMethod CreateBillingData(pCharges As %Decimal, pPatientId As %String, pInsuranceId As %String = "") As %DynamicObject
{
    Set data = {}
    Set data.charges = pCharges
    Set data.patientInfo = {}
    Set data.patientInfo.patientId = pPatientId
    Set data.patientInfo.serviceDate = $ZDATE($HOROLOG, 3)
    
    If pInsuranceId '= "" {
        Set data.patientInfo.insuranceId = pInsuranceId
        Set data.strategyType = "Insurance"
    } Else {
        Set data.strategyType = "Standard"
    }
    
    Quit data
}

}
