/// Standard Billing Strategy - List Price with Standard Adjustments
/// 
/// This strategy applies standard billing rates without insurance
/// or special program adjustments.
/// 
/// <example>
/// Set strategy = ##class(Patterns.Examples.StandardBillingStrategy).%New()
/// Set charges = 1000.00
/// Set patientInfo = {"patientId": "12345", "serviceDate": "2025-09-28"}
/// Set result = strategy.CalculateBilling(charges, patientInfo)
/// </example>
/// 
/// @see Patterns.Examples.BillingStrategy
/// @since 1.0.0
Class Patterns.Examples.StandardBillingStrategy Extends Patterns.Examples.BillingStrategy
{

/// Standard discount percentage for prompt payment
Parameter PROMPTPAYMENTDISCOUNT = 5;

/// Standard administrative fee percentage
Parameter ADMINFEEPERCENTAGE = 2;

/// Execute the standard billing calculation
/// 
/// @param pContext The billing context
/// @param pData The billing data
/// @return Calculated amount as string
Method Execute(pContext As %RegisteredObject, pData As %RegisteredObject) As %String
{
    Set charges = 0
    Set patientInfo = ""
    
    // Extract charges and patient info from data
    If $IsObject(pData) {
        If pData.%IsA("%DynamicObject") {
            If pData.%IsDefined("charges") {
                Set charges = pData.charges
            }
            If pData.%IsDefined("patientInfo") {
                Set patientInfo = pData.patientInfo
            }
        }
    }
    
    // Calculate billing
    Set result = ..CalculateBilling(charges, patientInfo)
    
    // Return final amount as string
    If $IsObject(result) {
        Quit result.finalAmount
    }
    
    Quit "0"
}

/// Calculate standard billing with breakdown
/// 
/// @param pCharges The base charges
/// @param pPatientInfo Patient information
/// @return %DynamicObject with calculated amounts
Method CalculateBilling(pCharges As %Decimal, pPatientInfo As %DynamicObject = "") As %DynamicObject
{
    Set result = {}
    Set result.originalCharges = pCharges
    Set result.strategy = "Standard"
    
    // Apply administrative fee
    Set adminFee = pCharges * (..#ADMINFEEPERCENTAGE / 100)
    Set totalWithFees = pCharges + adminFee
    
    // Check for prompt payment eligibility
    Set promptPayDiscount = 0
    If ..IsEligibleForPromptPayment(pPatientInfo) {
        Set promptPayDiscount = totalWithFees * (..#PROMPTPAYMENTDISCOUNT / 100)
    }
    
    // Calculate final amount
    Set finalAmount = totalWithFees - promptPayDiscount
    
    // Build result breakdown
    Set result.baseCharges = pCharges
    Set result.administrativeFee = $FNUMBER(adminFee, "", 2)
    Set result.promptPaymentDiscount = $FNUMBER(promptPayDiscount, "", 2)
    Set result.subtotal = $FNUMBER(totalWithFees, "", 2)
    Set result.finalAmount = $FNUMBER(finalAmount, "", 2)
    
    // Add audit trail
    Set result.auditTrail = ..CreateAuditTrail(pCharges, finalAmount, result)
    
    Quit result
}

/// Check if patient is eligible for prompt payment discount
/// 
/// @param pPatientInfo Patient information
/// @return %Boolean
Method IsEligibleForPromptPayment(pPatientInfo As %DynamicObject) As %Boolean [ Private ]
{
    If '$IsObject(pPatientInfo) Quit 0
    
    // Check payment history if available
    If pPatientInfo.%IsDefined("paymentHistory") {
        If pPatientInfo.paymentHistory = "Good" {
            Quit 1
        }
    }
    
    // Check if marked for prompt payment
    If pPatientInfo.%IsDefined("promptPayment") {
        Quit pPatientInfo.promptPayment
    }
    
    Quit 0
}

/// Validate if this strategy can handle the data
/// 
/// @param pData The data to validate
/// @return 1 if can handle, 0 otherwise
Method CanHandle(pData As %RegisteredObject) As %Boolean
{
    // Standard billing can handle any valid data
    If '$IsObject(pData) Quit 1  // Can handle simple amounts
    
    If pData.%IsA("%DynamicObject") {
        // Check if it's marked for a different strategy
        If pData.%IsDefined("strategyType") {
            If pData.strategyType '= "" && (pData.strategyType '= "Standard") {
                Quit 0
            }
        }
    }
    
    Quit 1
}

/// Get billing rules for standard strategy
/// 
/// @return %DynamicObject with billing rules
Method GetBillingRules() As %DynamicObject
{
    Set rules = ##super()
    Set rules.promptPaymentDiscount = ..#PROMPTPAYMENTDISCOUNT_"%"
    Set rules.administrativeFee = ..#ADMINFEEPERCENTAGE_"%"
    Set rules.eligibilityRequirements = "None - Standard billing for all patients"
    Set rules.paymentTerms = "Net 30 days"
    Quit rules
}

}
