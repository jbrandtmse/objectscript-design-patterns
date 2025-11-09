/// Unit Tests for Money Pattern
Class Patterns.Test.Unit.PoEAA.Base.MoneyTest Extends %UnitTest.TestCase
{

/// Test constructor creates money with amount and currency
Method TestConstructorWithDefaults() As %Status
{
    Set tMoney = ##class(Patterns.PoEAA.Base.Money).%New()
    Do $$$AssertEquals(tMoney.Amount, 0, "Default amount should be 0")
    Do $$$AssertEquals(tMoney.Currency, "USD", "Default currency should be USD")
    Quit $$$OK
}

/// Test constructor with custom amount and currency
Method TestConstructorWithCustomValues() As %Status
{
    Set tMoney = ##class(Patterns.PoEAA.Base.Money).%New(100.50, "EUR")
    Do $$$AssertEquals(tMoney.Amount, 100.50, "Amount should be 100.50")
    Do $$$AssertEquals(tMoney.Currency, "EUR", "Currency should be EUR")
    Quit $$$OK
}

/// Test Add() with same currency
Method TestAddSameCurrency() As %Status
{
    Set tMoney1 = ##class(Patterns.PoEAA.Base.Money).%New(100.50, "USD")
    Set tMoney2 = ##class(Patterns.PoEAA.Base.Money).%New(25.25, "USD")
    Set tResult = tMoney1.Add(tMoney2)

    Do $$$AssertTrue($IsObject(tResult), "Result should not be null")
    Do $$$AssertEquals(tResult.Amount, 125.75, "Sum should be 125.75")
    Do $$$AssertEquals(tResult.Currency, "USD", "Currency should be USD")
    Quit $$$OK
}

/// Test Add() with different currencies returns null
Method TestAddDifferentCurrencies() As %Status
{
    Set tMoney1 = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
    Set tMoney2 = ##class(Patterns.PoEAA.Base.Money).%New(100, "EUR")
    Set tResult = tMoney1.Add(tMoney2)

    Do $$$AssertNotTrue($IsObject(tResult), "Adding different currencies should return null")
    Quit $$$OK
}

/// Test Subtract() calculates correctly
Method TestSubtract() As %Status
{
    Set tMoney1 = ##class(Patterns.PoEAA.Base.Money).%New(100.75, "USD")
    Set tMoney2 = ##class(Patterns.PoEAA.Base.Money).%New(25.25, "USD")
    Set tResult = tMoney1.Subtract(tMoney2)

    Do $$$AssertTrue($IsObject(tResult), "Result should not be null")
    Do $$$AssertEquals(tResult.Amount, 75.50, "Difference should be 75.50")
    Do $$$AssertEquals(tResult.Currency, "USD", "Currency should be USD")
    Quit $$$OK
}

/// Test Subtract() with different currencies returns null
Method TestSubtractDifferentCurrencies() As %Status
{
    Set tMoney1 = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
    Set tMoney2 = ##class(Patterns.PoEAA.Base.Money).%New(50, "EUR")
    Set tResult = tMoney1.Subtract(tMoney2)

    Do $$$AssertNotTrue($IsObject(tResult), "Subtracting different currencies should return null")
    Quit $$$OK
}

/// Test Multiply() with rounding
Method TestMultiply() As %Status
{
    Set tMoney = ##class(Patterns.PoEAA.Base.Money).%New(10.50, "USD")
    Set tResult = tMoney.Multiply(3)

    Do $$$AssertTrue($IsObject(tResult), "Result should not be null")
    Do $$$AssertEquals(tResult.Amount, 31.50, "Product should be 31.50")
    Do $$$AssertEquals(tResult.Currency, "USD", "Currency should be USD")
    Quit $$$OK
}

/// Test Multiply() rounds correctly
Method TestMultiplyRounding() As %Status
{
    Set tMoney = ##class(Patterns.PoEAA.Base.Money).%New(10.33, "USD")
    Set tResult = tMoney.Multiply(3)

    Do $$$AssertTrue($IsObject(tResult), "Result should not be null")
    Do $$$AssertEquals(tResult.Amount, 30.99, "Product should be 30.99")
    Quit $$$OK
}

/// Test Divide() with HALF_UP rounding
Method TestDivideHalfUp() As %Status
{
    Set tMoney = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
    Set tResult = tMoney.Divide(3, "HALF_UP")

    Do $$$AssertTrue($IsObject(tResult), "Result should not be null")
    Do $$$AssertEquals(tResult.Amount, 33.33, "Quotient should be 33.33")
    Do $$$AssertEquals(tResult.Currency, "USD", "Currency should be USD")
    Quit $$$OK
}

/// Test Divide() with HALF_EVEN rounding
Method TestDivideHalfEven() As %Status
{
    Set tMoney = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
    Set tResult = tMoney.Divide(3, "HALF_EVEN")

    Do $$$AssertTrue($IsObject(tResult), "Result should not be null")
    Do $$$AssertEquals(tResult.Currency, "USD", "Currency should be USD")
    Quit $$$OK
}

/// Test Divide() by zero returns null
Method TestDivideByZero() As %Status
{
    Set tMoney = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
    Set tResult = tMoney.Divide(0)

    Do $$$AssertNotTrue($IsObject(tResult), "Dividing by zero should return null")
    Quit $$$OK
}

/// Test Equals() for money comparison
Method TestEquals() As %Status
{
    Set tMoney1 = ##class(Patterns.PoEAA.Base.Money).%New(50, "USD")
    Set tMoney2 = ##class(Patterns.PoEAA.Base.Money).%New(50, "USD")
    Set tMoney3 = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")

    Do $$$AssertTrue(tMoney1.Equals(tMoney2), "Same amounts should be equal")
    Do $$$AssertNotTrue(tMoney1.Equals(tMoney3), "Different amounts should not be equal")
    Quit $$$OK
}

/// Test Equals() with different currencies
Method TestEqualsDifferentCurrencies() As %Status
{
    Set tMoney1 = ##class(Patterns.PoEAA.Base.Money).%New(50, "USD")
    Set tMoney2 = ##class(Patterns.PoEAA.Base.Money).%New(50, "EUR")

    Do $$$AssertNotTrue(tMoney1.Equals(tMoney2), "Same amounts with different currencies should not be equal")
    Quit $$$OK
}

/// Test GreaterThan()
Method TestGreaterThan() As %Status
{
    Set tMoney1 = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
    Set tMoney2 = ##class(Patterns.PoEAA.Base.Money).%New(50, "USD")

    Do $$$AssertTrue(tMoney1.GreaterThan(tMoney2), "100 should be greater than 50")
    Do $$$AssertNotTrue(tMoney2.GreaterThan(tMoney1), "50 should not be greater than 100")
    Quit $$$OK
}

/// Test LessThan()
Method TestLessThan() As %Status
{
    Set tMoney1 = ##class(Patterns.PoEAA.Base.Money).%New(50, "USD")
    Set tMoney2 = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")

    Do $$$AssertTrue(tMoney1.LessThan(tMoney2), "50 should be less than 100")
    Do $$$AssertNotTrue(tMoney2.LessThan(tMoney1), "100 should not be less than 50")
    Quit $$$OK
}

/// Test comparison with different currencies returns false
Method TestComparisonDifferentCurrencies() As %Status
{
    Set tMoney1 = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
    Set tMoney2 = ##class(Patterns.PoEAA.Base.Money).%New(50, "EUR")

    Do $$$AssertNotTrue(tMoney1.GreaterThan(tMoney2), "Cannot compare different currencies")
    Do $$$AssertNotTrue(tMoney1.LessThan(tMoney2), "Cannot compare different currencies")
    Quit $$$OK
}

/// Test ToString() format
Method TestToString() As %Status
{
    Set tMoney = ##class(Patterns.PoEAA.Base.Money).%New(100.50, "USD")
    Set tString = tMoney.ToString()

    Do $$$AssertEquals(tString, "USD 100.50", "String format should be 'USD 100.50'")
    Quit $$$OK
}

/// Test immutability - operations return new instance
Method TestImmutability() As %Status
{
    Set tOriginal = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
    Set tOther = ##class(Patterns.PoEAA.Base.Money).%New(50, "USD")
    Set tResult = tOriginal.Add(tOther)

    Do $$$AssertEquals(tOriginal.Amount, 100, "Original amount should remain 100")
    Do $$$AssertEquals(tResult.Amount, 150, "Result amount should be 150")
    Do $$$AssertNotEquals(tOriginal, tResult, "Result should be a new instance")
    Quit $$$OK
}

/// Test precision preservation in calculations
Method TestPrecisionPreservation() As %Status
{
    Set tMoney = ##class(Patterns.PoEAA.Base.Money).%New(10.11, "USD")
    Set tResult = tMoney.Add(##class(Patterns.PoEAA.Base.Money).%New(20.22, "USD"))

    Do $$$AssertEquals(tResult.Amount, 30.33, "Precision should be preserved")
    Quit $$$OK
}

/// Test healthcare billing discount
Method TestApplyDiscount() As %Status
{
    Set tBilling = ##class(Patterns.Examples.Clinical.BillingAmount).%New(100, "USD")
    Set tResult = tBilling.ApplyDiscount(10)

    Do $$$AssertTrue($IsObject(tResult), "Result should not be null")
    Do $$$AssertEquals(tResult.Amount, 90, "10% discount on 100 should be 90")
    Quit $$$OK
}

/// Test healthcare billing tax
Method TestApplyTax() As %Status
{
    Set tBilling = ##class(Patterns.Examples.Clinical.BillingAmount).%New(100, "USD")
    Set tResult = tBilling.ApplyTax(8)

    Do $$$AssertTrue($IsObject(tResult), "Result should not be null")
    Do $$$AssertEquals(tResult.Amount, 108, "8% tax on 100 should be 108")
    Quit $$$OK
}

/// Test insurance portion calculation
Method TestInsurancePortion() As %Status
{
    Set tBilling = ##class(Patterns.Examples.Clinical.BillingAmount).%New(1000, "USD")
    Set tInsurance = tBilling.CalculateInsurancePortion(80)

    Do $$$AssertTrue($IsObject(tInsurance), "Result should not be null")
    Do $$$AssertEquals(tInsurance.Amount, 800, "80% coverage should be 800")
    Quit $$$OK
}

/// Test patient portion calculation
Method TestPatientPortion() As %Status
{
    Set tBilling = ##class(Patterns.Examples.Clinical.BillingAmount).%New(1000, "USD")
    Set tPatient = tBilling.CalculatePatientPortion(80)

    Do $$$AssertTrue($IsObject(tPatient), "Result should not be null")
    Do $$$AssertEquals(tPatient.Amount, 200, "Patient should pay 200 with 80% coverage")
    Quit $$$OK
}

/// Test calculate total from multiple items
Method TestCalculateTotal() As %Status
{
    Set tItems = ##class(%ListOfObjects).%New()
    Do tItems.Insert(##class(Patterns.Examples.Clinical.BillingAmount).%New(100, "USD"))
    Do tItems.Insert(##class(Patterns.Examples.Clinical.BillingAmount).%New(200, "USD"))
    Do tItems.Insert(##class(Patterns.Examples.Clinical.BillingAmount).%New(300, "USD"))

    Set tTotal = ##class(Patterns.Examples.Clinical.BillingAmount).CalculateTotal(tItems)

    Do $$$AssertTrue($IsObject(tTotal), "Result should not be null")
    Do $$$AssertEquals(tTotal.Amount, 600, "Total should be 600")
    Quit $$$OK
}

/// Test procedure charge creation
Method TestProcedureCharge() As %Status
{
    Set tProc = ##class(Patterns.Examples.Clinical.ProcedureCharge).%New("99213", "Office Visit", 150, "USD")

    Do $$$AssertTrue($IsObject(tProc), "Procedure should not be null")
    Do $$$AssertEquals(tProc.ProcedureCode, "99213", "Code should be 99213")
    Do $$$AssertEquals(tProc.GetAmount(), 150, "Amount should be 150")
    Do $$$AssertEquals(tProc.GetCurrency(), "USD", "Currency should be USD")
    Quit $$$OK
}

/// Test procedure charge discount
Method TestProcedureChargeDiscount() As %Status
{
    Set tProc = ##class(Patterns.Examples.Clinical.ProcedureCharge).%New("99213", "Office Visit", 100, "USD")
    Set tDiscounted = tProc.ApplyDiscount(20)

    Do $$$AssertTrue($IsObject(tDiscounted), "Result should not be null")
    Do $$$AssertEquals(tDiscounted.GetAmount(), 80, "20% discount should result in 80")
    Quit $$$OK
}

}
