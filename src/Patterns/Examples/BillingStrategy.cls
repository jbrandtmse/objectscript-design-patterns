/// Healthcare Billing Strategy - Abstract Base for Billing Calculations
/// 
/// This class demonstrates the Strategy Pattern in a healthcare billing context
/// where different payer types require different calculation algorithms.
/// 
/// <example>
/// Set billingContext = ##class(BillingContext).%New()
/// Set strategy = ##class(StandardBillingStrategy).%New()
/// Do billingContext.SetStrategy(strategy)
/// Set totalAmount = billingContext.CalculateBill(charges)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Strategy
/// @since 1.0.0
Class Patterns.Examples.BillingStrategy Extends Patterns.GoF.Behavioral.Strategy [ Abstract ]
{

/// Parameter for strategy type
Parameter STRATEGYTYPE = "HealthcareBilling";

/// Calculate the billing amount based on charges
/// 
/// @param pContext The billing context
/// @param pData The billing data (charges, patient info, etc.)
/// @return Calculated amount as string
Method Execute(pContext As %RegisteredObject, pData As %RegisteredObject) As %String [ Abstract ]
{
    Quit ""
}

/// Calculate billing amount with detailed breakdown
/// 
/// @param pCharges The base charges
/// @param pPatientInfo Patient information
/// @return %DynamicObject with calculated amounts and breakdown
Method CalculateBilling(pCharges As %Decimal, pPatientInfo As %DynamicObject = "") As %DynamicObject [ Abstract ]
{
    Quit {}
}

/// Apply discount based on strategy rules
/// 
/// @param pAmount Original amount
/// @param pDiscountInfo Discount information
/// @return Discounted amount
Method ApplyDiscount(pAmount As %Decimal, pDiscountInfo As %DynamicObject = "") As %Decimal
{
    Set discount = 0
    
    If $IsObject(pDiscountInfo) {
        If pDiscountInfo.%IsDefined("percentage") {
            Set discount = pAmount * (pDiscountInfo.percentage / 100)
        } ElseIf pDiscountInfo.%IsDefined("fixed") {
            Set discount = pDiscountInfo.fixed
        }
    }
    
    Set finalAmount = pAmount - discount
    If finalAmount < 0 Set finalAmount = 0
    
    Quit finalAmount
}

/// Apply adjustments based on billing rules
/// 
/// @param pAmount Original amount
/// @param pAdjustments Adjustment information
/// @return Adjusted amount
Method ApplyAdjustments(pAmount As %Decimal, pAdjustments As %DynamicObject = "") As %Decimal
{
    Set adjustedAmount = pAmount
    
    If $IsObject(pAdjustments) {
        If pAdjustments.%IsDefined("contractualAdjustment") {
            Set adjustedAmount = adjustedAmount - pAdjustments.contractualAdjustment
        }
        If pAdjustments.%IsDefined("writeOff") {
            Set adjustedAmount = adjustedAmount - pAdjustments.writeOff
        }
    }
    
    If adjustedAmount < 0 Set adjustedAmount = 0
    
    Quit adjustedAmount
}

/// Create audit trail entry for billing calculation
/// 
/// @param pOriginalAmount Original charge amount
/// @param pFinalAmount Final calculated amount
/// @param pDetails Calculation details
/// @return Audit trail entry as JSON
Method CreateAuditTrail(pOriginalAmount As %Decimal, pFinalAmount As %Decimal, pDetails As %DynamicObject = "") As %DynamicObject
{
    Set audit = {}
    Set audit.timestamp = $ZDATETIME($ZTIMESTAMP, 3)
    Set audit.strategyUsed = ..GetStrategyName()
    Set audit.originalAmount = pOriginalAmount
    Set audit.finalAmount = pFinalAmount
    Set audit.adjustmentAmount = pOriginalAmount - pFinalAmount
    
    If $IsObject(pDetails) {
        Set audit.details = pDetails
    }
    
    Quit audit
}

/// Validate patient eligibility for this billing strategy
/// 
/// @param pPatientInfo Patient information
/// @return %Boolean indicating eligibility
Method ValidateEligibility(pPatientInfo As %DynamicObject) As %Boolean
{
    // Default implementation - can be overridden
    If '$IsObject(pPatientInfo) Quit 0
    
    // Check basic required fields
    If 'pPatientInfo.%IsDefined("patientId") Quit 0
    If 'pPatientInfo.%IsDefined("serviceDate") Quit 0
    
    Quit 1
}

/// Get billing rules for this strategy
/// 
/// @return %DynamicObject with billing rules
Method GetBillingRules() As %DynamicObject
{
    Set rules = {}
    Set rules.strategyType = ..#STRATEGYTYPE
    Set rules.version = ..GetVersion()
    Quit rules
}

}
