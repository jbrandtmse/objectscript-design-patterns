/// VitalSignsMonitor: Medical device that supports both Observer and Bridge patterns
/// Healthcare example demonstrating multiple pattern integration
/// 
/// <p>This class represents a vital signs monitor that:
/// 1. Acts as a Subject in the Observer pattern - notifying observers of vital sign changes
/// 2. Acts as an Abstraction in the Bridge pattern - using different communication interfaces
/// It demonstrates how real-world objects often participate in multiple patterns.</p>
Class Patterns.Examples.VitalSignsMonitor Extends Patterns.GoF.Behavioral.Observer.Subject
{

// ===== OBSERVER PATTERN PROPERTIES =====

/// Patient ID being monitored
Property PatientID As %String;

/// Current heart rate in beats per minute
Property HeartRate As %Integer [ InitialExpression = 0 ];

/// Blood pressure as systolic/diastolic string
Property BloodPressure As %String [ InitialExpression = "0/0" ];

/// Body temperature in Fahrenheit
Property Temperature As %Numeric [ InitialExpression = 0 ];

/// Oxygen saturation percentage
Property OxygenSaturation As %Integer [ InitialExpression = 0 ];

/// Alert level based on vital signs
Property AlertLevel As %String [ InitialExpression = "Normal" ];

/// Last update timestamp
Property LastUpdate As %TimeStamp;

// ===== BRIDGE PATTERN PROPERTIES =====

/// Reference to the communication interface (for Bridge pattern)
Property Interface As Patterns.Examples.DeviceInterface;

/// Device serial number for identification
Property SerialNumber As %String;

/// Device model name
Property ModelName As %String;

/// Current device status
Property Status As %String [ InitialExpression = "Initialized" ];

/// Monitoring frequency in seconds
Property MonitoringFrequency As %Integer [ InitialExpression = 60 ];

/// Device active status (connected and monitoring)
Property IsActive As %Boolean [ InitialExpression = 0 ];

/// Device configuration settings
Property Configuration As %String [ MultiDimensional ];

/// Current vital signs readings (for Bridge pattern compatibility)
Property VitalSigns As %String [ MultiDimensional ];

/// Alert thresholds
Property AlertThresholds As %String [ MultiDimensional ];

// ===== CONSTRUCTOR =====

/// Constructor - Initialize vital signs monitor
Method %OnNew(pPatientID As %String = "", pSerialNumber As %String = "") As %Status
{
    // Call parent constructor (Subject)
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        // Initialize Observer pattern properties
        Set ..PatientID = pPatientID
        Set ..LastUpdate = $ZDateTime($Horolog, 3)
        Set ..HeartRate = 72
        Set ..BloodPressure = "120/80"
        Set ..Temperature = 98.6
        Set ..OxygenSaturation = 98
        Set ..AlertLevel = "Normal"
        
        // Initialize Bridge pattern properties
        Set ..SerialNumber = $Select(pSerialNumber'="":pSerialNumber,1:"VSM-"_$Random(99999))
        Set ..ModelName = "VitalSignsMonitor-VSM2000"
        
        // Initialize configuration
        Set ..Configuration("PowerMode") = "Normal"
        Set ..Configuration("SamplingRate") = "1Hz"
        Set ..Configuration("DataFormat") = "JSON"
        Set ..Configuration("Encryption") = "Enabled"
        
        // Initialize vital signs array (for Bridge compatibility)
        Set ..VitalSigns("HeartRate") = 0
        Set ..VitalSigns("SystolicBP") = 0
        Set ..VitalSigns("DiastolicBP") = 0
        Set ..VitalSigns("OxygenSaturation") = 0
        Set ..VitalSigns("Temperature") = 0
        Set ..VitalSigns("RespiratoryRate") = 0
        
        // Set default alert thresholds
        Set ..AlertThresholds("HeartRate","Min") = 50
        Set ..AlertThresholds("HeartRate","Max") = 120
        Set ..AlertThresholds("SystolicBP","Min") = 90
        Set ..AlertThresholds("SystolicBP","Max") = 140
        Set ..AlertThresholds("DiastolicBP","Min") = 60
        Set ..AlertThresholds("DiastolicBP","Max") = 90
        Set ..AlertThresholds("OxygenSaturation","Min") = 92
        Set ..AlertThresholds("Temperature","Min") = 35.5
        Set ..AlertThresholds("Temperature","Max") = 38.5
        Set ..AlertThresholds("RespiratoryRate","Min") = 12
        Set ..AlertThresholds("RespiratoryRate","Max") = 20
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

// ===== OBSERVER PATTERN METHODS =====

/// Get the current alert level based on vital signs
Method GetAlertLevel() As %String
{
    // Critical conditions
    If (..HeartRate < 40) || (..HeartRate > 120) {
        Quit "Critical"
    }
    If (..OxygenSaturation < 90) || (..OxygenSaturation > 100) {
        Quit "Critical"
    }
    If (..Temperature < 95) || (..Temperature > 103) {
        Quit "Critical"
    }
    
    // Parse blood pressure
    Set systolic = $Piece(..BloodPressure, "/", 1)
    Set diastolic = $Piece(..BloodPressure, "/", 2)
    If (systolic > 180) || (systolic < 90) || (diastolic > 120) || (diastolic < 60) {
        Quit "Critical"
    }
    
    // Warning conditions
    If (..HeartRate < 50) || (..HeartRate > 90) {
        Quit "Warning"
    }
    If (..OxygenSaturation < 95) {
        Quit "Warning"
    }
    If (..Temperature < 97) || (..Temperature > 100.5) {
        Quit "Warning"
    }
    If (systolic > 140) || (systolic < 100) || (diastolic > 90) || (diastolic < 65) {
        Quit "Warning"
    }
    
    // Normal
    Quit "Normal"
}

/// Update vital signs and notify observers
Method UpdateVitals(pHeartRate As %Integer = "", pBloodPressure As %String = "", pTemperature As %Numeric = "", pOxygenSat As %Integer = "") As %Status
{
    Set tSC = $$$OK
    Try {
        Set changed = 0
        
        If pHeartRate '= "" {
            Set ..HeartRate = pHeartRate
            Set ..VitalSigns("HeartRate") = pHeartRate
            Set changed = 1
        }
        
        If pBloodPressure '= "" {
            Set ..BloodPressure = pBloodPressure
            Set systolic = $Piece(pBloodPressure, "/", 1)
            Set diastolic = $Piece(pBloodPressure, "/", 2)
            Set ..VitalSigns("SystolicBP") = systolic
            Set ..VitalSigns("DiastolicBP") = diastolic
            Set changed = 1
        }
        
        If pTemperature '= "" {
            Set ..Temperature = pTemperature
            Set ..VitalSigns("Temperature") = pTemperature
            Set changed = 1
        }
        
        If pOxygenSat '= "" {
            Set ..OxygenSaturation = pOxygenSat
            Set ..VitalSigns("OxygenSaturation") = pOxygenSat
            Set changed = 1
        }
        
        If changed {
            Set ..LastUpdate = $ZDateTime($Horolog, 3)
            Set ..AlertLevel = ..GetAlertLevel()
            
            // Notify all observers with current data
            Set tSC = ..Notify()
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

// ===== BRIDGE PATTERN METHODS =====

/// Set or switch the communication interface (Bridge pattern)
Method SetInterface(pInterface As Patterns.Examples.DeviceInterface) As %Status
{
    Set tSC = $$$OK
    Try {
        // Disconnect current interface if exists
        If $IsObject(..Interface) {
            Set tSC = ..Interface.Disconnect()
            If $$$ISERR(tSC) Quit
        }
        
        // Set new interface
        Set ..Interface = pInterface
        Set ..Status = "Interface Changed"
        
        // Configure the new interface with device info
        If $IsObject(pInterface) {
            Set tSC = pInterface.Configure(..SerialNumber, ..ModelName)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Connect the device using current interface (Bridge pattern)
Method Connect() As %Status
{
    Set tSC = $$$OK
    Try {
        If '$IsObject(..Interface) {
            Set tSC = $$$ERROR($$$GeneralError, "No communication interface configured")
            Quit
        }
        
        Set tSC = ..Interface.Connect()
        If $$$ISOK(tSC) {
            Set ..Status = "Connected"
            Set ..IsActive = 1
            Set ..State = "Monitoring Active"  // For Observer pattern
        }
        Else {
            Set ..Status = "Connection Failed"
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Disconnect the device (Bridge pattern)
Method Disconnect() As %Status
{
    Set tSC = $$$OK
    Try {
        If '$IsObject(..Interface) {
            Set ..Status = "Not Connected"
            Quit
        }
        
        Set tSC = ..Interface.Disconnect()
        If $$$ISOK(tSC) {
            Set ..Status = "Disconnected"
            Set ..IsActive = 0
            Set ..State = "Monitoring Stopped"  // For Observer pattern
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Read data from the device (Bridge pattern)
Method ReadData() As %String
{
    // Check if connected via interface
    If '$IsObject(..Interface) || '..Interface.IsConnected {
        Quit "Device not connected"
    }
    
    // Generate new vital signs readings
    Do ..SimulateVitalSigns()
    
    // Format the output
    Set output = ""
    Set output = output _ "Heart Rate: " _ ..VitalSigns("HeartRate") _ " bpm | "
    Set output = output _ "Blood Pressure: " _ ..VitalSigns("SystolicBP") _ "/" _ ..VitalSigns("DiastolicBP") _ " mmHg | "
    Set output = output _ "O2 Sat: " _ ..VitalSigns("OxygenSaturation") _ "% | "
    Set output = output _ "Temp: " _ ..VitalSigns("Temperature") _ "°C | "
    Set output = output _ "Resp Rate: " _ ..VitalSigns("RespiratoryRate") _ " breaths/min"
    
    Quit output
}

/// Generate alert if thresholds are exceeded (Bridge pattern)
Method GenerateAlert() As %String
{
    Set alert = ""
    
    // Check if any vital sign is out of range
    If ..VitalSigns("HeartRate") < ..AlertThresholds("HeartRate","Min") || 
       (..VitalSigns("HeartRate") > ..AlertThresholds("HeartRate","Max")) {
        Set alert = "ALERT: Heart Rate out of range"
    }
    
    If ..VitalSigns("OxygenSaturation") < ..AlertThresholds("OxygenSaturation","Min") {
        If alert '= "" Set alert = alert _ " | "
        Set alert = alert _ "ALERT: Low oxygen saturation"
    }
    
    If ..VitalSigns("SystolicBP") > ..AlertThresholds("SystolicBP","Max") {
        If alert '= "" Set alert = alert _ " | "
        Set alert = alert _ "ALERT: High blood pressure"
    }
    
    If alert '= "" {
        Set alert = "ALERT [" _ ..SerialNumber _ "]: " _ alert
    }
    
    Quit alert
}

/// Send data through the current interface (Bridge pattern)
Method SendData(pData As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$IsObject(..Interface) {
            Set tSC = $$$ERROR($$$GeneralError, "No communication interface configured")
            Quit
        }
        
        // Prepare data packet
        Set packet = {}
        Set packet.deviceId = ..SerialNumber
        Set packet.model = ..ModelName
        Set packet.timestamp = $ZDateTime($Horolog,3)
        Set packet.data = pData
        Set packet.encrypted = $Get(..Configuration("Encryption"), "Enabled")
        
        // Send through interface
        Set tSC = ..Interface.SendData(packet.%ToJSON())
        If $$$ISERR(tSC) {
            Set ..Status = "Transmission Error"
            Quit
        }
        
        Set ..Status = "Data Sent"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ..Status = "Send Failed"
    }
    Quit tSC
}

/// Get device information (Bridge pattern)
Method GetDeviceInfo() As %String
{
    Set info = "Device: "_..ModelName
    Set info = info_" | S/N: "_..SerialNumber
    Set info = info_" | Status: "_..Status
    
    If $IsObject(..Interface) {
        Set info = info_" | Interface: "_..Interface.GetInterfaceType()
    }
    Else {
        Set info = info_" | Interface: None"
    }
    
    Quit info
}

// ===== SHARED METHODS =====

/// Start monitoring vital signs
Method StartMonitoring() As %Status
{
    Set tSC = $$$OK
    Try {
        // For Bridge pattern
        If $IsObject(..Interface) {
            Set tSC = ..Connect()
            If $$$ISERR(tSC) Quit
        }
        
        Set ..IsActive = 1
        Set ..State = "Monitoring Active"
        Set ..Status = "Monitoring Active"
        
        // Simulate initial readings
        Do ..SimulateVitalSigns()
        
        // Notify observers (Observer pattern)
        Set tSC = ..Notify()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Stop monitoring
Method StopMonitoring() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..IsActive = 0
        Set ..State = "Monitoring Stopped"
        Set ..Status = "Monitoring Stopped"
        
        // For Bridge pattern
        If $IsObject(..Interface) {
            Set tSC = ..Disconnect()
        }
        
        // Notify observers (Observer pattern)
        Set tSC = ..Notify()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get current vital signs as JSON string
Method GetCurrentReadings() As %String
{
    Set readings = {}
    Set readings.timestamp = ..LastUpdate
    Set readings.patientId = ..PatientID
    Set readings.heartRate = ..HeartRate
    Set readings.bloodPressure = ..BloodPressure
    Set readings.oxygenSaturation = ..OxygenSaturation
    Set readings.temperature = ..Temperature
    Set readings.alertLevel = ..AlertLevel
    Set readings.isActive = ..IsActive
    
    Quit readings.%ToJSON()
}

/// Get monitoring summary
Method GetMonitoringSummary() As %String
{
    Set summary = "=== Vital Signs Monitor ==="_$Char(13,10)
    Set summary = summary_"Patient ID: "_..PatientID_$Char(13,10)
    Set summary = summary_"Device: "_..SerialNumber_$Char(13,10)
    Set summary = summary_"Status: "_..Status_$Char(13,10)
    Set summary = summary_"Alert Level: "_..AlertLevel_$Char(13,10)
    Set summary = summary_$Char(13,10)_"Current Readings:"_$Char(13,10)
    Set summary = summary_"  Heart Rate: "_..HeartRate_" bpm"_$Char(13,10)
    Set summary = summary_"  Blood Pressure: "_..BloodPressure_" mmHg"_$Char(13,10)
    Set summary = summary_"  O2 Saturation: "_..OxygenSaturation_"%"_$Char(13,10)
    Set summary = summary_"  Temperature: "_..Temperature_"°F"_$Char(13,10)
    Set summary = summary_"  Last Update: "_..LastUpdate
    
    Quit summary
}

/// Simulate vital signs readings (for testing)
Method SimulateVitalSigns() [ Private ]
{
    // Generate realistic vital signs
    Set ..HeartRate = 60 + $Random(40)  // 60-100 bpm
    Set systolic = 110 + $Random(30)    // 110-140 mmHg
    Set diastolic = 70 + $Random(20)    // 70-90 mmHg
    Set ..BloodPressure = systolic_"/"_diastolic
    Set ..OxygenSaturation = 95 + $Random(5)  // 95-100%
    Set ..Temperature = 97.5 + ($Random(20) / 10)  // 97.5-99.5°F
    
    // Update VitalSigns array for Bridge pattern
    Set ..VitalSigns("HeartRate") = ..HeartRate
    Set ..VitalSigns("SystolicBP") = systolic
    Set ..VitalSigns("DiastolicBP") = diastolic
    Set ..VitalSigns("OxygenSaturation") = ..OxygenSaturation
    Set ..VitalSigns("Temperature") = ..Temperature
    Set ..VitalSigns("RespiratoryRate") = 12 + $Random(8)  // 12-20 breaths/min
    
    Set ..LastUpdate = $ZDateTime($Horolog, 3)
    Set ..AlertLevel = ..GetAlertLevel()
}

/// Clear all alerts
Method ClearAlerts() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..AlertLevel = "Normal"
        Set ..State = "Alerts Cleared"
        
        // Notify observers
        Set tSC = ..Notify()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Transmit current vital signs (Bridge pattern compatibility)
Method TransmitVitalSigns() As %Status
{
    Set tSC = $$$OK
    Try {
        Set data = ..GetCurrentReadings()
        Set tSC = ..SendData(data)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
