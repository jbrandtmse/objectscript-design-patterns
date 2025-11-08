/// Dosage Value Object - Healthcare Example
/// 
/// Represents a medication dosage as an immutable value object.
/// Dosage includes amount, unit, frequency, and route of administration.
/// 
/// This implementation demonstrates:
/// - Immutability for medication safety
/// - Value-based equality
/// - Healthcare-specific validation
/// - Dosage calculation methods
/// 
/// Example:
/// <example>
/// Set dosage = ##class(Dosage).%New("500", "mg", "twice daily", "oral")
/// Write dosage.Amount  // "500"
/// Write dosage.Unit  // "mg"
/// Write dosage.ToString()  // "Dosage[500 mg, twice daily, oral]"
/// </example>
Class Patterns.Examples.Clinical.Dosage Extends Patterns.PoEAA.Base.ValueObject
{

Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Value Object";

Parameter DOMAIN = "Healthcare";

/// Dosage amount as string (read-only)
Property Amount As %String(MAXLEN = 50) [ Private ];

/// Unit of measurement (mg, mL, units, etc.) (read-only)
Property Unit As %String(MAXLEN = 50) [ Private ];

/// Frequency of administration (read-only)
Property Frequency As %String(MAXLEN = 100) [ Private ];

/// Route of administration (oral, IV, IM, etc.) (read-only)
Property Route As %String(MAXLEN = 50) [ Private ];

/// Constructor - initializes immutable dosage
/// 
/// @param pAmount Dosage amount
/// @param pUnit Unit of measurement
/// @param pFrequency Frequency of administration
/// @param pRoute Route of administration
/// @return %Status
Method %OnNew(pAmount As %String = "", pUnit As %String = "", pFrequency As %String = "", pRoute As %String = "") As %Status
{
    Set tSC = $$$OK

    Try {
        // Set immutable properties
        Set i%Amount = pAmount
        Set i%Unit = pUnit
        Set i%Frequency = pFrequency
        Set i%Route = pRoute

        // Validate
        Set tSC = ..Validate()

    } Catch ex {
        Set tSC = ex.AsStatus()
    }

    Quit tSC
}

/// Getter for Amount
Method AmountGet() As %String
{
    Quit i%Amount
}

/// Getter for Unit
Method UnitGet() As %String
{
    Quit i%Unit
}

/// Getter for Frequency
Method FrequencyGet() As %String
{
    Quit i%Frequency
}

/// Getter for Route
Method RouteGet() As %String
{
    Quit i%Route
}

/// Validates dosage data
Method Validate() As %Status
{
    Set tSC = $$$OK

    Try {
        // Amount is required
        If (..Amount = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Dosage amount is required")
            Quit
        }

        // Unit is required
        If (..Unit = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Dosage unit is required")
            Quit
        }

        // Frequency is required
        If (..Frequency = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Dosage frequency is required")
            Quit
        }

        // Route is required
        If (..Route = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Route of administration is required")
            Quit
        }

        // Validate route is recognized
        Set tValidRoutes = ",oral,IV,IM,subcutaneous,topical,inhalation,rectal,sublingual,transdermal,intrathecal,"
        Set tRouteLower = $ZCONVERT(..Route, "L")
        If (tValidRoutes '[ (","_tRouteLower_",")) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid route of administration: " _ ..Route)
            Quit
        }

        // If amount is numeric, validate it's positive
        If (+..Amount = ..Amount) {
            If (+..Amount <= 0) {
                Set tSC = $$$ERROR($$$GeneralError, "Dosage amount must be positive")
                Quit
            }
        }

    } Catch ex {
        Set tSC = ex.AsStatus()
    }

    Quit tSC
}

/// Value-based equality comparison
Method Equals(pOther As Patterns.PoEAA.Base.ValueObject) As %Boolean
{
    Set tEquals = 0

    Try {
        // Null check
        If '$IsObject(pOther) {
            Quit
        }

        // Type check
        If (pOther.%ClassName(1) '= ..%ClassName(1)) {
            Quit
        }

        // Compare all property values
        If (..Amount '= pOther.Amount) {
            Quit
        }

        If (..Unit '= pOther.Unit) {
            Quit
        }

        If (..Frequency '= pOther.Frequency) {
            Quit
        }

        If (..Route '= pOther.Route) {
            Quit
        }

        Set tEquals = 1

    } Catch ex {
        Set tEquals = 0
    }

    Quit tEquals
}

/// Generate hash code based on all properties
Method GetHashCode() As %Integer
{
    Set tHash = 0

    Try {
        // Combine all string values into hash
        Set tHash = $LENGTH(..%ClassName(1))

        // Hash amount
        For tIdx = 1:1:$LENGTH(..Amount) {
            Set tChar = $ASCII(..Amount, tIdx)
            Set tHash = ((tHash * 31) + tChar) # 2147483647
        }

        // Hash unit
        For tIdx = 1:1:$LENGTH(..Unit) {
            Set tChar = $ASCII(..Unit, tIdx)
            Set tHash = ((tHash * 31) + tChar) # 2147483647
        }

        // Hash frequency
        For tIdx = 1:1:$LENGTH(..Frequency) {
            Set tChar = $ASCII(..Frequency, tIdx)
            Set tHash = ((tHash * 31) + tChar) # 2147483647
        }

        // Hash route
        For tIdx = 1:1:$LENGTH(..Route) {
            Set tChar = $ASCII(..Route, tIdx)
            Set tHash = ((tHash * 31) + tChar) # 2147483647
        }

    } Catch ex {
        Set tHash = 0
    }

    Quit tHash
}

/// String representation of dosage
Method ToString() As %String
{
    Set tString = ""

    Try {
        Set tString = "Dosage["
        Set tString = tString _ ..Amount _ " " _ ..Unit _ ", "
        Set tString = tString _ ..Frequency _ ", "
        Set tString = tString _ ..Route
        Set tString = tString _ "]"

    } Catch ex {
        Set tString = "Dosage[error]"
    }

    Quit tString
}

/// Copy with different amount
Method WithAmount(pNewAmount As %String) As Patterns.Examples.Clinical.Dosage
{
    Quit ##class(Patterns.Examples.Clinical.Dosage).%New(pNewAmount, ..Unit, ..Frequency, ..Route)
}

/// Copy with different frequency
Method WithFrequency(pNewFrequency As %String) As Patterns.Examples.Clinical.Dosage
{
    Quit ##class(Patterns.Examples.Clinical.Dosage).%New(..Amount, ..Unit, pNewFrequency, ..Route)
}

/// Copy with different route
Method WithRoute(pNewRoute As %String) As Patterns.Examples.Clinical.Dosage
{
    Quit ##class(Patterns.Examples.Clinical.Dosage).%New(..Amount, ..Unit, ..Frequency, pNewRoute)
}

/// Calculate daily dose if amount is numeric and frequency can be parsed
/// Returns daily total or empty string if cannot calculate
Method CalculateDailyDose() As %String
{
    Set tDailyDose = ""

    Try {
        // Check if amount is numeric
        If (+..Amount '= ..Amount) {
            Quit
        }

        Set tAmount = +..Amount
        Set tFreqLower = $ZCONVERT(..Frequency, "L")
        Set tTimesPerDay = 0

        // Parse common frequency patterns
        // Check more specific patterns first
        If (tFreqLower [ "twice daily") || (tFreqLower [ "bid") {
            Set tTimesPerDay = 2
        } ElseIf (tFreqLower [ "three times") || (tFreqLower [ "tid") {
            Set tTimesPerDay = 3
        } ElseIf (tFreqLower [ "four times") || (tFreqLower [ "qid") {
            Set tTimesPerDay = 4
        } ElseIf (tFreqLower [ "once daily") || (tFreqLower [ "qd") {
            Set tTimesPerDay = 1
        } ElseIf (tFreqLower [ "daily") {
            Set tTimesPerDay = 1
        } ElseIf (tFreqLower [ "every 12 hours") || (tFreqLower [ "q12h") {
            Set tTimesPerDay = 2
        } ElseIf (tFreqLower [ "every 8 hours") || (tFreqLower [ "q8h") {
            Set tTimesPerDay = 3
        } ElseIf (tFreqLower [ "every 6 hours") || (tFreqLower [ "q6h") {
            Set tTimesPerDay = 4
        }

        If tTimesPerDay > 0 {
            Set tDaily = tAmount * tTimesPerDay
            Set tDailyDose = tDaily _ " " _ ..Unit _ "/day"
        }

    } Catch ex {
        Set tDailyDose = ""
    }

    Quit tDailyDose
}

}
