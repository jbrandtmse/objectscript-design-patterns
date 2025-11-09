/// Healthcare Billing Amount Example
/// Demonstrates Money pattern for medical billing calculations
Class Patterns.Examples.Clinical.BillingAmount Extends Patterns.PoEAA.Base.Money
{

/// Apply discount percentage to billing amount
/// Returns new BillingAmount with discount applied
Method ApplyDiscount(pPercent As %Numeric) As Patterns.Examples.Clinical.BillingAmount
{
    Set tDiscountFactor = 1 - (pPercent / 100)
    Set tNewAmount = ..Amount * tDiscountFactor
    Set tRounded = +$FNUMBER(tNewAmount, "", 2)
    Quit ##class(Patterns.Examples.Clinical.BillingAmount).%New(tRounded, ..Currency)
}

/// Apply tax rate to billing amount
/// Returns new BillingAmount with tax included
Method ApplyTax(pRate As %Numeric) As Patterns.Examples.Clinical.BillingAmount
{
    Set tTaxFactor = 1 + (pRate / 100)
    Set tNewAmount = ..Amount * tTaxFactor
    Set tRounded = +$FNUMBER(tNewAmount, "", 2)
    Quit ##class(Patterns.Examples.Clinical.BillingAmount).%New(tRounded, ..Currency)
}

/// Calculate insurance portion based on coverage percentage
Method CalculateInsurancePortion(pCoveragePercent As %Numeric) As Patterns.Examples.Clinical.BillingAmount
{
    Set tInsuranceAmount = ..Amount * (pCoveragePercent / 100)
    Set tRounded = +$FNUMBER(tInsuranceAmount, "", 2)
    Quit ##class(Patterns.Examples.Clinical.BillingAmount).%New(tRounded, ..Currency)
}

/// Calculate patient responsibility after insurance
Method CalculatePatientPortion(pCoveragePercent As %Numeric) As Patterns.Examples.Clinical.BillingAmount
{
    Set tPatientPercent = 100 - pCoveragePercent
    Set tPatientAmount = ..Amount * (tPatientPercent / 100)
    Set tRounded = +$FNUMBER(tPatientAmount, "", 2)
    Quit ##class(Patterns.Examples.Clinical.BillingAmount).%New(tRounded, ..Currency)
}

/// Calculate total from multiple billing items
ClassMethod CalculateTotal(pItems As %ListOfObjects) As Patterns.Examples.Clinical.BillingAmount
{
    Set tTotal = 0
    Set tCurrency = "USD"

    If $IsObject(pItems) {
        For tIdx = 1:1:pItems.Count() {
            Set tItem = pItems.GetAt(tIdx)
            If $IsObject(tItem) {
                If (tIdx = 1) {
                    Set tCurrency = tItem.Currency
                }
                If (tItem.Currency = tCurrency) {
                    Set tTotal = tTotal + tItem.Amount
                }
            }
        }
    }

    Quit ##class(Patterns.Examples.Clinical.BillingAmount).%New(tTotal, tCurrency)
}

}
