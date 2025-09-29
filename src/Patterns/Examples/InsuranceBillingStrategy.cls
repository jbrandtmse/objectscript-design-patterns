/// Insurance Billing Strategy - Negotiated Rates with Copays and Deductibles
/// 
/// This strategy applies insurance-specific billing rules including
/// negotiated rates, copayments, deductibles, and coinsurance.
/// 
/// <example>
/// Set strategy = ##class(Patterns.Examples.InsuranceBillingStrategy).%New()
/// Set charges = 1000.00
/// Set patientInfo = {"patientId": "12345", "insuranceId": "INS789", 
///                    "deductibleMet": 500, "deductibleMax": 1000,
///                    "copay": 25, "coinsurance": 20}
/// Set result = strategy.CalculateBilling(charges, patientInfo)
/// </example>
/// 
/// @see Patterns.Examples.BillingStrategy
/// @since 1.0.0
Class Patterns.Examples.InsuranceBillingStrategy Extends Patterns.Examples.BillingStrategy
{

/// Standard negotiated rate discount percentage
Parameter NEGOTIATEDRATE = 35;

/// Default coinsurance percentage
Parameter DEFAULTCOINSURANCE = 20;

/// Execute the insurance billing calculation
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
    
    // Return patient responsibility as string
    If $IsObject(result) {
        Quit result.patientResponsibility
    }
    
    Quit "0"
}

/// Calculate insurance billing with breakdown
/// 
/// @param pCharges The base charges
/// @param pPatientInfo Patient and insurance information
/// @return %DynamicObject with calculated amounts
Method CalculateBilling(pCharges As %Decimal, pPatientInfo As %DynamicObject = "") As %DynamicObject
{
    Set result = {}
    Set result.originalCharges = pCharges
    Set result.strategy = "Insurance"
    
    // Apply negotiated rate discount
    Set negotiatedRate = ..#NEGOTIATEDRATE
    If $IsObject(pPatientInfo) && pPatientInfo.%IsDefined("negotiatedRate") {
        Set negotiatedRate = pPatientInfo.negotiatedRate
    }
    
    Set discountAmount = pCharges * (negotiatedRate / 100)
    Set allowedAmount = pCharges - discountAmount
    
    // Get insurance information
    Set copay = 0
    Set deductibleMet = 0
    Set deductibleMax = 0
    Set coinsurance = ..#DEFAULTCOINSURANCE
    Set outOfPocketMet = 0
    Set outOfPocketMax = 0
    
    If $IsObject(pPatientInfo) {
        If pPatientInfo.%IsDefined("copay") Set copay = pPatientInfo.copay
        If pPatientInfo.%IsDefined("deductibleMet") Set deductibleMet = pPatientInfo.deductibleMet
        If pPatientInfo.%IsDefined("deductibleMax") Set deductibleMax = pPatientInfo.deductibleMax
        If pPatientInfo.%IsDefined("coinsurance") Set coinsurance = pPatientInfo.coinsurance
        If pPatientInfo.%IsDefined("outOfPocketMet") Set outOfPocketMet = pPatientInfo.outOfPocketMet
        If pPatientInfo.%IsDefined("outOfPocketMax") Set outOfPocketMax = pPatientInfo.outOfPocketMax
    }
    
    // Calculate deductible amount
    Set deductibleRemaining = deductibleMax - deductibleMet
    Set deductibleAmount = 0
    If deductibleRemaining > 0 {
        If allowedAmount >= deductibleRemaining {
            Set deductibleAmount = deductibleRemaining
        } Else {
            Set deductibleAmount = allowedAmount
        }
    }
    
    // Calculate coinsurance amount
    Set amountAfterDeductible = allowedAmount - deductibleAmount
    Set coinsuranceAmount = amountAfterDeductible * (coinsurance / 100)
    
    // Calculate patient responsibility
    Set patientResponsibility = copay + deductibleAmount + coinsuranceAmount
    
    // Apply out-of-pocket maximum if applicable
    Set outOfPocketRemaining = outOfPocketMax - outOfPocketMet
    If (outOfPocketMax > 0) && (patientResponsibility > outOfPocketRemaining) {
        Set patientResponsibility = outOfPocketRemaining
    }
    
    // Calculate insurance payment
    Set insurancePayment = allowedAmount - deductibleAmount - coinsuranceAmount - copay
    If insurancePayment < 0 Set insurancePayment = 0
    
    // Build result breakdown
    Set result.baseCharges = pCharges
    Set result.negotiatedDiscount = $FNUMBER(discountAmount, "", 2)
    Set result.allowedAmount = $FNUMBER(allowedAmount, "", 2)
    Set result.copayment = $FNUMBER(copay, "", 2)
    Set result.deductibleApplied = $FNUMBER(deductibleAmount, "", 2)
    Set result.coinsuranceAmount = $FNUMBER(coinsuranceAmount, "", 2)
    Set result.insurancePayment = $FNUMBER(insurancePayment, "", 2)
    Set result.patientResponsibility = $FNUMBER(patientResponsibility, "", 2)
    Set result.writeOff = $FNUMBER(discountAmount, "", 2)
    Set result.finalAmount = $FNUMBER(patientResponsibility, "", 2)
    
    // Add insurance details
    Set result.insuranceDetails = {}
    Set result.insuranceDetails.negotiatedRate = negotiatedRate_"%"
    Set result.insuranceDetails.coinsurance = coinsurance_"%"
    Set result.insuranceDetails.deductibleStatus = deductibleMet_" of "_deductibleMax
    Set result.insuranceDetails.outOfPocketStatus = outOfPocketMet_" of "_outOfPocketMax
    
    // Add audit trail
    Set result.auditTrail = ..CreateAuditTrail(pCharges, patientResponsibility, result)
    
    Quit result
}

/// Validate if this strategy can handle the data
/// 
/// @param pData The data to validate
/// @return 1 if can handle, 0 otherwise
Method CanHandle(pData As %RegisteredObject) As %Boolean
{
    If '$IsObject(pData) Quit 0
    
    If pData.%IsA("%DynamicObject") {
        // Check if it's marked for insurance billing
        If pData.%IsDefined("strategyType") {
            Quit (pData.strategyType = "Insurance")
        }
        // Check for insurance-specific fields
        If pData.%IsDefined("patientInfo") {
            Set info = pData.patientInfo
            If $IsObject(info) {
                If info.%IsDefined("insuranceId") && (info.insuranceId '= "") {
                    Quit 1
                }
            }
        }
    }
    
    Quit 0
}

/// Validate patient eligibility for insurance billing
/// 
/// @param pPatientInfo Patient information
/// @return %Boolean indicating eligibility
Method ValidateEligibility(pPatientInfo As %DynamicObject) As %Boolean
{
    If '##super(pPatientInfo) Quit 0
    
    // Check insurance-specific requirements
    If 'pPatientInfo.%IsDefined("insuranceId") Quit 0
    If pPatientInfo.insuranceId = "" Quit 0
    
    // Check if insurance is active
    If pPatientInfo.%IsDefined("insuranceStatus") {
        If pPatientInfo.insuranceStatus '= "Active" Quit 0
    }
    
    Quit 1
}

/// Get billing rules for insurance strategy
/// 
/// @return %DynamicObject with billing rules
Method GetBillingRules() As %DynamicObject
{
    Set rules = ##super()
    Set rules.negotiatedRate = ..#NEGOTIATEDRATE_"%"
    Set rules.defaultCoinsurance = ..#DEFAULTCOINSURANCE_"%"
    Set rules.eligibilityRequirements = "Active insurance coverage required"
    Set rules.preAuthorizationRequired = "May be required for certain services"
    Set rules.claimSubmission = "Electronic submission within 90 days"
    Set rules.paymentTerms = "Payment expected within 30-45 days"
    Quit rules
}

}
