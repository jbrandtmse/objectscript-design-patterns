/// Lab Result Value Object - Healthcare Example
/// 
/// Represents a laboratory test result as an immutable value object.
/// Lab results are diagnostic measurements with reference ranges and abnormal flags.
/// 
/// This implementation demonstrates:
/// - Immutability of test results
/// - Value-based equality
/// - Healthcare data validation
/// - Domain-specific calculations (IsAbnormal)
/// 
/// Example:
/// <example>
/// Set result = ##class(LabResult).%New("Hemoglobin", "12.5", "g/dL", "12.0-16.0", 0)
/// Write result.TestName  // "Hemoglobin"
/// Write result.Value  // "12.5"
/// Write result.IsAbnormal  // 0 (within range)
/// </example>
Class Patterns.Examples.Clinical.LabResult Extends Patterns.PoEAA.Base.ValueObject
{

Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Value Object";

Parameter DOMAIN = "Healthcare";

/// Name of the laboratory test (read-only)
Property TestName As %String(MAXLEN = 200) [ Private ];

/// Test result value as string (can be numeric or text) (read-only)
Property Value As %String(MAXLEN = 100) [ Private ];

/// Unit of measurement (read-only)
Property Unit As %String(MAXLEN = 50) [ Private ];

/// Reference range as string (e.g., "12.0-16.0", "<5.0", ">90") (read-only)
Property ReferenceRange As %String(MAXLEN = 100) [ Private ];

/// Flag indicating if result is abnormal (read-only)
Property IsAbnormal As %Boolean [ Private ];

/// Constructor - initializes immutable lab result
/// 
/// @param pTestName Name of the test
/// @param pValue Result value
/// @param pUnit Unit of measurement
/// @param pReferenceRange Reference range string
/// @param pIsAbnormal Abnormal flag (0 or 1)
/// @return %Status
Method %OnNew(pTestName As %String = "", pValue As %String = "", pUnit As %String = "", pReferenceRange As %String = "", pIsAbnormal As %Boolean = 0) As %Status
{
    Set tSC = $$$OK

    Try {
        // Set immutable properties
        Set i%TestName = pTestName
        Set i%Value = pValue
        Set i%Unit = pUnit
        Set i%ReferenceRange = pReferenceRange
        Set i%IsAbnormal = pIsAbnormal

        // Validate
        Set tSC = ..Validate()

    } Catch ex {
        Set tSC = ex.AsStatus()
    }

    Quit tSC
}

/// Getter for TestName
Method TestNameGet() As %String
{
    Quit i%TestName
}

/// Getter for Value
Method ValueGet() As %String
{
    Quit i%Value
}

/// Getter for Unit
Method UnitGet() As %String
{
    Quit i%Unit
}

/// Getter for ReferenceRange
Method ReferenceRangeGet() As %String
{
    Quit i%ReferenceRange
}

/// Getter for IsAbnormal
Method IsAbnormalGet() As %Boolean
{
    Quit i%IsAbnormal
}

/// Validates lab result data
Method Validate() As %Status
{
    Set tSC = $$$OK

    Try {
        // Test name is required
        If (..TestName = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Test name is required")
            Quit
        }

        // Value is required
        If (..Value = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Test value is required")
            Quit
        }

        // Unit is required
        If (..Unit = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Unit is required")
            Quit
        }

        // IsAbnormal must be boolean
        If (..IsAbnormal '= 0) && (..IsAbnormal '= 1) {
            Set tSC = $$$ERROR($$$GeneralError, "IsAbnormal must be 0 or 1")
            Quit
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
        If (..TestName '= pOther.TestName) {
            Quit
        }

        If (..Value '= pOther.Value) {
            Quit
        }

        If (..Unit '= pOther.Unit) {
            Quit
        }

        If (..ReferenceRange '= pOther.ReferenceRange) {
            Quit
        }

        If (..IsAbnormal '= pOther.IsAbnormal) {
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

        // Hash test name
        For tIdx = 1:1:$LENGTH(..TestName) {
            Set tChar = $ASCII(..TestName, tIdx)
            Set tHash = ((tHash * 31) + tChar) # 2147483647
        }

        // Hash value
        For tIdx = 1:1:$LENGTH(..Value) {
            Set tChar = $ASCII(..Value, tIdx)
            Set tHash = ((tHash * 31) + tChar) # 2147483647
        }

        // Hash unit
        For tIdx = 1:1:$LENGTH(..Unit) {
            Set tChar = $ASCII(..Unit, tIdx)
            Set tHash = ((tHash * 31) + tChar) # 2147483647
        }

        // Add abnormal flag
        Set tHash = ((tHash * 31) + ..IsAbnormal) # 2147483647

    } Catch ex {
        Set tHash = 0
    }

    Quit tHash
}

/// String representation of lab result
Method ToString() As %String
{
    Set tString = ""

    Try {
        Set tString = "LabResult["
        Set tString = tString _ "Test=" _ ..TestName _ ", "
        Set tString = tString _ "Value=" _ ..Value _ " " _ ..Unit _ ", "
        Set tString = tString _ "Range=" _ ..ReferenceRange _ ", "
        Set tString = tString _ "Abnormal=" _ ..IsAbnormal
        Set tString = tString _ "]"

    } Catch ex {
        Set tString = "LabResult[error]"
    }

    Quit tString
}

/// Copy with different abnormal flag
Method WithAbnormalFlag(pNewFlag As %Boolean) As Patterns.Examples.Clinical.LabResult
{
    Quit ##class(Patterns.Examples.Clinical.LabResult).%New(..TestName, ..Value, ..Unit, ..ReferenceRange, pNewFlag)
}

/// Get severity level based on how far outside reference range
/// Returns: "Normal", "Mild", "Moderate", "Severe", or "Unknown"
Method GetSeverity() As %String
{
    Set tSeverity = "Unknown"

    Try {
        // If not abnormal, it's normal
        If '..IsAbnormal {
            Set tSeverity = "Normal"
            Quit
        }

        // For numeric values, calculate deviation
        If +..Value = ..Value {
            // Extract numeric range boundaries if possible
            If ..ReferenceRange [ "-" {
                Set tLow = $PIECE(..ReferenceRange, "-", 1)
                Set tHigh = $PIECE(..ReferenceRange, "-", 2)

                If (+tLow = tLow) && (+tHigh = tHigh) {
                    Set tNumValue = +..Value
                    Set tNumLow = +tLow
                    Set tNumHigh = +tHigh
                    Set tRange = tNumHigh - tNumLow

                    // Below range
                    If tNumValue < tNumLow {
                        Set tDeviation = tNumLow - tNumValue
                        If (tDeviation / tRange) < 0.1 {
                            Set tSeverity = "Mild"
                        } ElseIf (tDeviation / tRange) < 0.3 {
                            Set tSeverity = "Moderate"
                        } Else {
                            Set tSeverity = "Severe"
                        }
                    }
                    // Above range
                    ElseIf tNumValue > tNumHigh {
                        Set tDeviation = tNumValue - tNumHigh
                        If (tDeviation / tRange) < 0.1 {
                            Set tSeverity = "Mild"
                        } ElseIf (tDeviation / tRange) < 0.3 {
                            Set tSeverity = "Moderate"
                        } Else {
                            Set tSeverity = "Severe"
                        }
                    }
                }
            }
        } Else {
            // Non-numeric abnormal
            Set tSeverity = "Moderate"
        }

    } Catch ex {
        Set tSeverity = "Unknown"
    }

    Quit tSeverity
}

}
