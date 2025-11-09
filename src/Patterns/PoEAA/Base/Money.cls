/// Money Pattern Implementation
/// Represents a monetary value with currency for precise decimal arithmetic
Class Patterns.PoEAA.Base.Money Extends %RegisteredObject
{

Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Value Object";

/// The monetary amount with precise decimal storage (2 decimal places)
Property Amount As %Numeric(SCALE = 2);

/// ISO 4217 currency code (USD, EUR, GBP, etc.)
Property Currency As %String(MAXLEN = 3);

/// Constructor to create Money instance
Method %OnNew(pAmount As %Numeric = 0, pCurrency As %String = "USD") As %Status
{
    Set i%Amount = pAmount
    Set i%Currency = pCurrency
    Quit $$$OK
}

/// Add another Money value (must be same currency)
Method Add(pOther As Patterns.PoEAA.Base.Money) As Patterns.PoEAA.Base.Money
{
    If (..Currency '= pOther.Currency) {
        Quit $$$NULLOREF
    }

    Set tNewAmount = ..Amount + pOther.Amount
    Quit ##class(Patterns.PoEAA.Base.Money).%New(tNewAmount, ..Currency)
}

/// Subtract another Money value (must be same currency)
Method Subtract(pOther As Patterns.PoEAA.Base.Money) As Patterns.PoEAA.Base.Money
{
    If (..Currency '= pOther.Currency) {
        Quit $$$NULLOREF
    }

    Set tNewAmount = ..Amount - pOther.Amount
    Quit ##class(Patterns.PoEAA.Base.Money).%New(tNewAmount, ..Currency)
}

/// Multiply Money by a numeric factor
Method Multiply(pFactor As %Numeric) As Patterns.PoEAA.Base.Money
{
    Set tNewAmount = ..Amount * pFactor
    Set tRounded = +$FNUMBER(tNewAmount, "", 2)
    Quit ##class(Patterns.PoEAA.Base.Money).%New(tRounded, ..Currency)
}

/// Divide Money by a numeric divisor with rounding strategy
Method Divide(pDivisor As %Numeric, pRounding As %String = "HALF_UP") As Patterns.PoEAA.Base.Money
{
    If (pDivisor = 0) {
        Quit $$$NULLOREF
    }

    Set tResult = ..Amount / pDivisor

    If (pRounding = "HALF_UP") {
        Set tRounded = +$FNUMBER(tResult, "", 2)
    } ElseIf (pRounding = "HALF_EVEN") {
        Set tRounded = +$JUSTIFY(tResult, 0, 2)
    } Else {
        Set tRounded = +$FNUMBER(tResult, "", 2)
    }

    Quit ##class(Patterns.PoEAA.Base.Money).%New(tRounded, ..Currency)
}

/// Check if this Money equals another Money value
Method Equals(pOther As Patterns.PoEAA.Base.Money) As %Boolean
{
    If '$IsObject(pOther) {
        Quit 0
    }

    If (..Currency '= pOther.Currency) {
        Quit 0
    }

    If (..Amount '= pOther.Amount) {
        Quit 0
    }

    Quit 1
}

/// Check if this Money is greater than another Money value
Method GreaterThan(pOther As Patterns.PoEAA.Base.Money) As %Boolean
{
    If '$IsObject(pOther) {
        Quit 0
    }

    If (..Currency '= pOther.Currency) {
        Quit 0
    }

    Quit (..Amount > pOther.Amount)
}

/// Check if this Money is less than another Money value
Method LessThan(pOther As Patterns.PoEAA.Base.Money) As %Boolean
{
    If '$IsObject(pOther) {
        Quit 0
    }

    If (..Currency '= pOther.Currency) {
        Quit 0
    }

    Quit (..Amount < pOther.Amount)
}

/// Get formatted money string
Method ToString() As %String
{
    Quit ..Currency _ " " _ $FNUMBER(..Amount, "", 2)
}

}
