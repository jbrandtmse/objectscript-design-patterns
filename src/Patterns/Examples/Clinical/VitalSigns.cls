/// Vital Signs Value Object - Healthcare Example
/// 
/// Represents a complete set of vital sign measurements as an immutable value object.
/// Vital signs are critical measurements indicating the state of the body's life-sustaining functions.
/// 
/// This implementation demonstrates:
/// - Immutability through read-only properties
/// - Value-based equality comparison
/// - Validation of medical measurement ranges
/// - Healthcare domain value object patterns
/// 
/// Example:
/// <example>
/// Set vitals = ##class(VitalSigns).%New(98.6, 120, 80, 72, 16, 98)
/// Write vitals.Temperature  // 98.6
/// Write vitals.BloodPressureSystolic  // 120
/// Write vitals.IsNormal()  // 1 or 0
/// 
/// // Create modified copy
/// Set vitals2 = vitals.WithTemperature(99.1)
/// </example>
Class Patterns.Examples.Clinical.VitalSigns Extends Patterns.PoEAA.Base.ValueObject
{

Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Value Object";

Parameter DOMAIN = "Healthcare";

/// Temperature in Fahrenheit (read-only after construction)
Property Temperature As %Numeric [ Private ];

/// Systolic blood pressure in mmHg (read-only after construction)
Property BloodPressureSystolic As %Integer [ Private ];

/// Diastolic blood pressure in mmHg (read-only after construction)
Property BloodPressureDiastolic As %Integer [ Private ];

/// Heart rate in beats per minute (read-only after construction)
Property HeartRate As %Integer [ Private ];

/// Respiratory rate in breaths per minute (read-only after construction)
Property RespiratoryRate As %Integer [ Private ];

/// Oxygen saturation percentage (read-only after construction)
Property OxygenSaturation As %Numeric [ Private ];

/// Constructor - initializes immutable vital signs
/// 
/// @param pTemperature Temperature in Fahrenheit (95-110)
/// @param pBPSystolic Systolic BP in mmHg (60-250)
/// @param pBPDiastolic Diastolic BP in mmHg (40-150)
/// @param pHeartRate Heart rate in BPM (30-250)
/// @param pRespiratoryRate Respiratory rate in breaths/min (5-60)
/// @param pOxygenSaturation O2 saturation percentage (0-100)
/// @return %Status
Method %OnNew(pTemperature As %Numeric = "", pBPSystolic As %Integer = "", pBPDiastolic As %Integer = "", pHeartRate As %Integer = "", pRespiratoryRate As %Integer = "", pOxygenSaturation As %Numeric = "") As %Status
{
    Set tSC = $$$OK

    Try {
        // Set immutable properties using internal storage
        Set i%Temperature = pTemperature
        Set i%BloodPressureSystolic = pBPSystolic
        Set i%BloodPressureDiastolic = pBPDiastolic
        Set i%HeartRate = pHeartRate
        Set i%RespiratoryRate = pRespiratoryRate
        Set i%OxygenSaturation = pOxygenSaturation

        // Validate all measurements
        Set tSC = ..Validate()

    } Catch ex {
        Set tSC = ex.AsStatus()
    }

    Quit tSC
}

/// Getter for Temperature
Method TemperatureGet() As %Numeric
{
    Quit i%Temperature
}

/// Getter for BloodPressureSystolic
Method BloodPressureSystolicGet() As %Integer
{
    Quit i%BloodPressureSystolic
}

/// Getter for BloodPressureDiastolic
Method BloodPressureDiastolicGet() As %Integer
{
    Quit i%BloodPressureDiastolic
}

/// Getter for HeartRate
Method HeartRateGet() As %Integer
{
    Quit i%HeartRate
}

/// Getter for RespiratoryRate
Method RespiratoryRateGet() As %Integer
{
    Quit i%RespiratoryRate
}

/// Getter for OxygenSaturation
Method OxygenSaturationGet() As %Numeric
{
    Quit i%OxygenSaturation
}

/// Validates vital sign measurements are within acceptable ranges
Method Validate() As %Status
{
    Set tSC = $$$OK

    Try {
        // Validate temperature (95-110°F)
        If (..Temperature < 95) || (..Temperature > 110) {
            Set tSC = $$$ERROR($$$GeneralError, "Temperature must be between 95 and 110°F")
            Quit
        }

        // Validate systolic BP (60-250 mmHg)
        If (..BloodPressureSystolic < 60) || (..BloodPressureSystolic > 250) {
            Set tSC = $$$ERROR($$$GeneralError, "Systolic BP must be between 60 and 250 mmHg")
            Quit
        }

        // Validate diastolic BP (40-150 mmHg)
        If (..BloodPressureDiastolic < 40) || (..BloodPressureDiastolic > 150) {
            Set tSC = $$$ERROR($$$GeneralError, "Diastolic BP must be between 40 and 150 mmHg")
            Quit
        }

        // Validate BP relationship (systolic > diastolic)
        If (..BloodPressureSystolic <= ..BloodPressureDiastolic) {
            Set tSC = $$$ERROR($$$GeneralError, "Systolic BP must be greater than Diastolic BP")
            Quit
        }

        // Validate heart rate (30-250 BPM)
        If (..HeartRate < 30) || (..HeartRate > 250) {
            Set tSC = $$$ERROR($$$GeneralError, "Heart rate must be between 30 and 250 BPM")
            Quit
        }

        // Validate respiratory rate (5-60 breaths/min)
        If (..RespiratoryRate < 5) || (..RespiratoryRate > 60) {
            Set tSC = $$$ERROR($$$GeneralError, "Respiratory rate must be between 5 and 60 breaths/min")
            Quit
        }

        // Validate oxygen saturation (0-100%)
        If (..OxygenSaturation < 0) || (..OxygenSaturation > 100) {
            Set tSC = $$$ERROR($$$GeneralError, "Oxygen saturation must be between 0 and 100%")
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

        // Compare all vital sign values
        If (..Temperature '= pOther.Temperature) {
            Quit
        }

        If (..BloodPressureSystolic '= pOther.BloodPressureSystolic) {
            Quit
        }

        If (..BloodPressureDiastolic '= pOther.BloodPressureDiastolic) {
            Quit
        }

        If (..HeartRate '= pOther.HeartRate) {
            Quit
        }

        If (..RespiratoryRate '= pOther.RespiratoryRate) {
            Quit
        }

        If (..OxygenSaturation '= pOther.OxygenSaturation) {
            Quit
        }

        Set tEquals = 1

    } Catch ex {
        Set tEquals = 0
    }

    Quit tEquals
}

/// Generate hash code based on all vital sign values
Method GetHashCode() As %Integer
{
    Set tHash = 0

    Try {
        // Combine all values into hash
        Set tHash = $LENGTH(..%ClassName(1))
        Set tHash = ((tHash * 31) + (..Temperature * 100)) # 2147483647
        Set tHash = ((tHash * 31) + ..BloodPressureSystolic) # 2147483647
        Set tHash = ((tHash * 31) + ..BloodPressureDiastolic) # 2147483647
        Set tHash = ((tHash * 31) + ..HeartRate) # 2147483647
        Set tHash = ((tHash * 31) + ..RespiratoryRate) # 2147483647
        Set tHash = ((tHash * 31) + (..OxygenSaturation * 100)) # 2147483647

    } Catch ex {
        Set tHash = 0
    }

    Quit tHash
}

/// String representation of vital signs
Method ToString() As %String
{
    Set tString = ""

    Try {
        Set tString = "VitalSigns["
        Set tString = tString _ "Temp=" _ ..Temperature _ "°F, "
        Set tString = tString _ "BP=" _ ..BloodPressureSystolic _ "/" _ ..BloodPressureDiastolic _ ", "
        Set tString = tString _ "HR=" _ ..HeartRate _ ", "
        Set tString = tString _ "RR=" _ ..RespiratoryRate _ ", "
        Set tString = tString _ "SpO2=" _ ..OxygenSaturation _ "%"
        Set tString = tString _ "]"

    } Catch ex {
        Set tString = "VitalSigns[error]"
    }

    Quit tString
}

/// Copy with modified temperature
Method WithTemperature(pNewTemp As %Numeric) As Patterns.Examples.Clinical.VitalSigns
{
    Quit ##class(Patterns.Examples.Clinical.VitalSigns).%New(pNewTemp, ..BloodPressureSystolic, ..BloodPressureDiastolic, ..HeartRate, ..RespiratoryRate, ..OxygenSaturation)
}

/// Copy with modified blood pressure
Method WithBloodPressure(pNewSystolic As %Integer, pNewDiastolic As %Integer) As Patterns.Examples.Clinical.VitalSigns
{
    Quit ##class(Patterns.Examples.Clinical.VitalSigns).%New(..Temperature, pNewSystolic, pNewDiastolic, ..HeartRate, ..RespiratoryRate, ..OxygenSaturation)
}

/// Copy with modified heart rate
Method WithHeartRate(pNewHR As %Integer) As Patterns.Examples.Clinical.VitalSigns
{
    Quit ##class(Patterns.Examples.Clinical.VitalSigns).%New(..Temperature, ..BloodPressureSystolic, ..BloodPressureDiastolic, pNewHR, ..RespiratoryRate, ..OxygenSaturation)
}

/// Check if vital signs are within normal ranges
Method IsNormal() As %Boolean
{
    Set tNormal = 1

    Try {
        // Normal temp: 97.0-99.0°F
        If (..Temperature < 97.0) || (..Temperature > 99.0) {
            Set tNormal = 0
            Quit
        }

        // Normal BP: Systolic 90-120, Diastolic 60-80
        If (..BloodPressureSystolic < 90) || (..BloodPressureSystolic > 120) {
            Set tNormal = 0
            Quit
        }
        If (..BloodPressureDiastolic < 60) || (..BloodPressureDiastolic > 80) {
            Set tNormal = 0
            Quit
        }

        // Normal HR: 60-100 BPM
        If (..HeartRate < 60) || (..HeartRate > 100) {
            Set tNormal = 0
            Quit
        }

        // Normal RR: 12-20 breaths/min
        If (..RespiratoryRate < 12) || (..RespiratoryRate > 20) {
            Set tNormal = 0
            Quit
        }

        // Normal SpO2: >= 95%
        If (..OxygenSaturation < 95) {
            Set tNormal = 0
            Quit
        }

    } Catch ex {
        Set tNormal = 0
    }

    Quit tNormal
}

}
