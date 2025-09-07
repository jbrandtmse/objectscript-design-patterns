/// VitalSignsMonitor: Concrete medical device for monitoring vital signs
/// Healthcare example of Bridge Pattern refined abstraction
/// 
/// <p>This class represents a vital signs monitor that can track heart rate,
/// blood pressure, oxygen saturation, and temperature. It can switch between
/// different communication interfaces at runtime.</p>
Class Patterns.Examples.VitalSignsMonitor Extends Patterns.Examples.MonitoringDevice
{

/// Current vital signs readings
Property VitalSigns As %String [ MultiDimensional ];

/// Alert thresholds
Property AlertThresholds As %String [ MultiDimensional ];

/// Monitoring frequency in seconds
Property MonitoringFrequency As %Integer [ InitialExpression = 60 ];

/// Alert status
Property AlertActive As %Boolean [ InitialExpression = 0 ];

/// Patient ID being monitored
Property PatientID As %String;

/// Constructor - Initialize vital signs monitor
Method %OnNew(pSerialNumber As %String = "", pPatientID As %String = "") As %Status
{
    // Call parent constructor
    Set tSC = ##super(pSerialNumber, "VitalSignsMonitor-VSM2000")
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        Set ..PatientID = pPatientID
        
        // Initialize vital signs
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

/// Start monitoring vital signs
Method StartMonitoring() As %Status
{
    Set tSC = $$$OK
    Try {
        If '$IsObject(..Interface) {
            Set tSC = $$$ERROR($$$GeneralError, "No communication interface configured")
            Quit
        }
        
        // Connect through interface
        Set tSC = ..Connect()
        If $$$ISERR(tSC) Quit
        
        Set ..Status = "Monitoring Active"
        
        // Simulate initial readings
        Do ..SimulateVitalSigns()
        
        // Send initial data
        Set tSC = ..TransmitVitalSigns()
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
        Set ..Status = "Monitoring Stopped"
        
        // Send final readings
        If $IsObject(..Interface) {
            Set tSC = ..TransmitVitalSigns()
            If $$$ISERR(tSC) Quit
            
            // Disconnect
            Set tSC = ..Disconnect()
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get current vital signs readings
Method GetCurrentReadings() As %String
{
    Set readings = {}
    Set readings.timestamp = $ZDateTime($Horolog,3)
    Set readings.patientId = ..PatientID
    Set readings.heartRate = ..VitalSigns("HeartRate")
    Set readings.bloodPressure = ..VitalSigns("SystolicBP")_"/"_..VitalSigns("DiastolicBP")
    Set readings.oxygenSaturation = ..VitalSigns("OxygenSaturation")
    Set readings.temperature = ..VitalSigns("Temperature")
    Set readings.respiratoryRate = ..VitalSigns("RespiratoryRate")
    Set readings.alertActive = ..AlertActive
    
    Quit readings.%ToJSON()
}

/// Update vital sign reading
Method UpdateVitalSign(pType As %String, pValue As %Numeric) As %Status
{
    Set tSC = $$$OK
    Try {
        If pType = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Vital sign type cannot be empty")
            Quit
        }
        
        // Store the reading
        Set ..VitalSigns(pType) = pValue
        
        // Check thresholds
        Do ..CheckAlertThresholds(pType, pValue)
        
        // Auto-transmit if monitoring is active
        If ..Status = "Monitoring Active" {
            Set tSC = ..TransmitVitalSigns()
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Set alert threshold
Method SetAlertThreshold(pType As %String, pLimit As %String, pValue As %Numeric) As %Status
{
    Set tSC = $$$OK
    Try {
        If (pType = "") || (pLimit = "") {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid threshold parameters")
            Quit
        }
        
        If (pLimit '= "Min") && (pLimit '= "Max") {
            Set tSC = $$$ERROR($$$GeneralError, "Limit must be 'Min' or 'Max'")
            Quit
        }
        
        Set ..AlertThresholds(pType, pLimit) = pValue
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Private method to check alert thresholds
Method CheckAlertThresholds(pType As %String, pValue As %Numeric) [ Private ]
{
    Set alertTriggered = 0
    
    // Check minimum threshold
    If $Data(..AlertThresholds(pType, "Min")) {
        If pValue < ..AlertThresholds(pType, "Min") {
            Set alertTriggered = 1
        }
    }
    
    // Check maximum threshold
    If $Data(..AlertThresholds(pType, "Max")) {
        If pValue > ..AlertThresholds(pType, "Max") {
            Set alertTriggered = 1
        }
    }
    
    If alertTriggered {
        Set ..AlertActive = 1
        Do ..SendAlert(pType, pValue)
    }
}

/// Send alert notification
Method SendAlert(pType As %String, pValue As %Numeric) [ Private ]
{
    If '$IsObject(..Interface) Quit
    
    Set alert = {}
    Set alert.type = "VITAL_SIGN_ALERT"
    Set alert.severity = "HIGH"
    Set alert.timestamp = $ZDateTime($Horolog,3)
    Set alert.patientId = ..PatientID
    Set alert.vitalSign = pType
    Set alert.value = pValue
    Set alert.minThreshold = $Get(..AlertThresholds(pType, "Min"), "N/A")
    Set alert.maxThreshold = $Get(..AlertThresholds(pType, "Max"), "N/A")
    Set alert.deviceId = ..SerialNumber
    
    Do ..SendData(alert.%ToJSON())
}

/// Transmit current vital signs
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

/// Simulate vital signs readings (for testing)
Method SimulateVitalSigns() [ Private ]
{
    // Generate realistic vital signs
    Set ..VitalSigns("HeartRate") = 60 + $Random(40)  // 60-100 bpm
    Set ..VitalSigns("SystolicBP") = 110 + $Random(30)  // 110-140 mmHg
    Set ..VitalSigns("DiastolicBP") = 70 + $Random(20)  // 70-90 mmHg
    Set ..VitalSigns("OxygenSaturation") = 95 + $Random(5)  // 95-100%
    Set ..VitalSigns("Temperature") = 36.5 + ($Random(20) / 10)  // 36.5-38.5°C
    Set ..VitalSigns("RespiratoryRate") = 12 + $Random(8)  // 12-20 breaths/min
}

/// Get monitoring summary
Method GetMonitoringSummary() As %String
{
    Set summary = "=== Vital Signs Monitor ==="_$Char(13,10)
    Set summary = summary_"Patient ID: "_..PatientID_$Char(13,10)
    Set summary = summary_"Device: "_..GetDeviceInfo()_$Char(13,10)
    Set summary = summary_"Status: "_..Status_$Char(13,10)
    Set summary = summary_"Alert Active: "_$Select(..AlertActive:"YES",1:"NO")_$Char(13,10)
    Set summary = summary_$Char(13,10)_"Current Readings:"_$Char(13,10)
    Set summary = summary_"  Heart Rate: "_..VitalSigns("HeartRate")_" bpm"_$Char(13,10)
    Set summary = summary_"  Blood Pressure: "_..VitalSigns("SystolicBP")_"/"_..VitalSigns("DiastolicBP")_" mmHg"_$Char(13,10)
    Set summary = summary_"  O2 Saturation: "_..VitalSigns("OxygenSaturation")_"%"_$Char(13,10)
    Set summary = summary_"  Temperature: "_..VitalSigns("Temperature")_"°C"_$Char(13,10)
    Set summary = summary_"  Respiratory Rate: "_..VitalSigns("RespiratoryRate")_" breaths/min"
    
    Quit summary
}

/// Clear all alerts
Method ClearAlerts() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..AlertActive = 0
        
        // Send clear notification
        If $IsObject(..Interface) {
            Set notification = {}
            Set notification.type = "ALERT_CLEARED"
            Set notification.timestamp = $ZDateTime($Horolog,3)
            Set notification.patientId = ..PatientID
            Set notification.deviceId = ..SerialNumber
            
            Set tSC = ..SendData(notification.%ToJSON())
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
