/// Procedure Charge Value Object
/// Represents a charge for a medical procedure with code and amount
Class Patterns.Examples.Clinical.ProcedureCharge Extends %RegisteredObject
{

/// Procedure code (CPT, ICD-10, etc.)
Property ProcedureCode As %String(MAXLEN = 50);

/// Description of the procedure
Property Description As %String(MAXLEN = 500);

/// Charge amount as Money
Property Charge As Patterns.Examples.Clinical.BillingAmount;

/// Constructor
Method %OnNew(pCode As %String, pDescription As %String, pAmount As %Numeric, pCurrency As %String = "USD") As %Status
{
    Set i%ProcedureCode = pCode
    Set i%Description = pDescription
    Set i%Charge = ##class(Patterns.Examples.Clinical.BillingAmount).%New(pAmount, pCurrency)
    Quit $$$OK
}

/// Get the charge amount
Method GetAmount() As %Numeric
{
    If $IsObject(..Charge) {
        Quit ..Charge.Amount
    }
    Quit 0
}

/// Get the currency
Method GetCurrency() As %String
{
    If $IsObject(..Charge) {
        Quit ..Charge.Currency
    }
    Quit "USD"
}

/// Apply discount to this procedure charge
Method ApplyDiscount(pPercent As %Numeric) As Patterns.Examples.Clinical.ProcedureCharge
{
    Set tNewCharge = ..Charge.ApplyDiscount(pPercent)
    Set tNewProc = ##class(Patterns.Examples.Clinical.ProcedureCharge).%New(
        ..ProcedureCode,
        ..Description,
        tNewCharge.Amount,
        tNewCharge.Currency
    )
    Quit tNewProc
}

/// String representation
Method ToString() As %String
{
    If $IsObject(..Charge) {
        Quit ..ProcedureCode _ ": " _ ..Description _ " - " _ ..Charge.ToString()
    }
    Quit ..ProcedureCode _ ": " _ ..Description
}

}
