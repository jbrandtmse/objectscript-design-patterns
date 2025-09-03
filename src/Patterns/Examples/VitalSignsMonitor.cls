/// Healthcare Example - Vital Signs Monitor (Observer Pattern Subject)
/// 
/// Purpose:
/// Demonstrates the Observer pattern in a healthcare context where a vital signs
/// monitor acts as the subject, notifying various observers (nurse station, 
/// doctor pager, medical records) when vital signs change.
/// 
/// Real-World Scenario:
/// In a hospital ICU, vital signs monitors continuously track patient metrics.
/// When values change or exceed thresholds, multiple systems need to be notified
/// simultaneously without tight coupling between systems.
/// 
/// @see Patterns.GoF.Behavioral.Observer.Subject
/// @since 1.0.0
Class Patterns.Examples.VitalSignsMonitor Extends Patterns.GoF.Behavioral.Observer.Subject
{

// ===== PARAMETERS =====

Parameter VERSION = "1.0.0";

// ===== PROPERTIES =====

/// Patient identifier
Property PatientID As %String;

/// Patient name for display
Property PatientName As %String;

/// Current heart rate (beats per minute)
Property HeartRate As %Integer [ InitialExpression = 72 ];

/// Current blood pressure (systolic/diastolic)
Property BloodPressure As %String [ InitialExpression = "120/80" ];

/// Current temperature (Fahrenheit)
Property Temperature As %Decimal [ InitialExpression = 98.6 ];

/// Current oxygen saturation (percentage)
Property OxygenSaturation As %Integer [ InitialExpression = 98 ];

/// Alert level: Normal, Warning, Critical
Property AlertLevel As %String [ InitialExpression = "Normal" ];

// ===== CONSTRUCTORS =====

/// Initialize monitor with patient information
Method %OnNew(pPatientID As %String = "", pPatientName As %String = "") As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        Set ..PatientID = pPatientID
        Set ..PatientName = pPatientName
        
        // Initialize with normal vital signs
        Set ..HeartRate = 72
        Set ..BloodPressure = "120/80"
        Set ..Temperature = 98.6
        Set ..OxygenSaturation = 98
        Set ..AlertLevel = "Normal"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Get current alert level based on vital signs
Method GetAlertLevel() As %String
{
    Set alertLevel = "Normal"
    
    // Check heart rate
    If (..HeartRate < 60) || ((..HeartRate >= 90) && (..HeartRate < 120)) {
        Set alertLevel = "Warning"
    }
    If (..HeartRate < 40) || (..HeartRate >= 120) {
        Quit "Critical"
    }
    
    // Check temperature
    If (..Temperature < 97) || ((..Temperature > 100.4) && (..Temperature < 103)) {
        Set alertLevel = "Warning"
    }
    If (..Temperature < 95) || (..Temperature >= 103) {
        Quit "Critical"
    }
    
    // Check oxygen saturation
    If ((..OxygenSaturation < 95) && (..OxygenSaturation >= 90)) {
        Set alertLevel = "Warning"
    }
    If (..OxygenSaturation < 90) {
        Quit "Critical"
    }
    
    // Check for invalid values
    If (..HeartRate < 0) || (..OxygenSaturation > 100) {
        Quit "Critical"
    }
    
    Quit alertLevel
}

/// Update heart rate and check thresholds
Method UpdateHeartRate(pRate As %Integer) As %Status
{
    Set tSC = $$$OK
    Try {
        Set oldRate = ..HeartRate
        Set ..HeartRate = pRate
        
        // Determine alert level
        Set ..AlertLevel = ..GetAlertLevel()
        
        // Create notification data
        Set data = "HeartRate|" _ pRate _ "|" _ ..AlertLevel _ "|Previous:" _ oldRate
        
        // Update state and notify
        Set ..State = "HeartRate:" _ pRate _ " BPM"
        Set tSC = ..Notify(data)
        
        Write "Monitor: Heart rate updated to ", pRate, " BPM (", ..AlertLevel, ")", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Update blood pressure and check thresholds
Method UpdateBloodPressure(pBloodPressure As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Set oldBP = ..BloodPressure
        Set ..BloodPressure = pBloodPressure
        
        // Determine alert level
        Set ..AlertLevel = ..GetAlertLevel()
        
        // Create notification data
        Set data = "BloodPressure|" _ pBloodPressure _ "|" _ ..AlertLevel _ "|Previous:" _ oldBP
        
        // Update state and notify
        Set ..State = "BP:" _ pBloodPressure _ " mmHg"
        Set tSC = ..Notify(data)
        
        Write "Monitor: Blood pressure updated to ", pBloodPressure, " mmHg (", ..AlertLevel, ")", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Update temperature and check thresholds
Method UpdateTemperature(pTemp As %Decimal) As %Status
{
    Set tSC = $$$OK
    Try {
        Set oldTemp = ..Temperature
        Set ..Temperature = pTemp
        
        // Determine alert level
        Set ..AlertLevel = ..GetAlertLevel()
        
        // Create notification data
        Set data = "Temperature|" _ pTemp _ "|" _ ..AlertLevel _ "|Previous:" _ oldTemp
        
        // Update state and notify
        Set ..State = "Temp:" _ pTemp _ "°F"
        Set tSC = ..Notify(data)
        
        Write "Monitor: Temperature updated to ", pTemp, "°F (", ..AlertLevel, ")", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Update oxygen saturation and check thresholds
Method UpdateOxygenSaturation(pSat As %Integer) As %Status
{
    Set tSC = $$$OK
    Try {
        Set oldSat = ..OxygenSaturation
        Set ..OxygenSaturation = pSat
        
        // Determine alert level
        Set ..AlertLevel = ..GetAlertLevel()
        
        // Create notification data
        Set data = "OxygenSaturation|" _ pSat _ "|" _ ..AlertLevel _ "|Previous:" _ oldSat
        
        // Update state and notify
        Set ..State = "O2Sat:" _ pSat _ "%"
        Set tSC = ..Notify(data)
        
        Write "Monitor: Oxygen saturation updated to ", pSat, "% (", ..AlertLevel, ")", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Update all vital signs at once
Method UpdateAllVitals(pHR As %Integer, pBP As %String, pTemp As %Decimal, pO2 As %Integer) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..HeartRate = pHR
        Set ..BloodPressure = pBP
        Set ..Temperature = pTemp
        Set ..OxygenSaturation = pO2
        
        // Determine overall alert level
        Set ..AlertLevel = ..GetAlertLevel()
        
        // Create comprehensive notification
        Set data = "AllVitals|HR:" _ pHR _ "|BP:" _ pBP
        Set data = data _ "|Temp:" _ pTemp _ "|O2:" _ pO2 _ "|Alert:" _ ..AlertLevel
        
        // Update state and notify
        Set ..State = "Complete vital signs update - Alert: " _ ..AlertLevel
        Set tSC = ..Notify(data)
        
        Write "Monitor: All vital signs updated - Alert Level: ", ..AlertLevel, !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get current vital signs as formatted string
Method GetVitalSignsSummary() As %String
{
    Set summary = "Patient: " _ ..PatientName _ " (ID: " _ ..PatientID _ ")"
    Set summary = summary _ " | HR: " _ ..HeartRate _ " BPM"
    Set summary = summary _ " | BP: " _ ..BloodPressure
    Set summary = summary _ " | Temp: " _ ..Temperature _ "°F"
    Set summary = summary _ " | O2: " _ ..OxygenSaturation _ "%"
    Set summary = summary _ " | Alert: " _ ..AlertLevel
    Quit summary
}

}
