/// Portable medical monitoring device (Concrete Abstraction)
/// Lightweight, battery-powered monitor with basic vital signs capabilities
Class Patterns.Examples.PortableMonitor Extends Patterns.Examples.MonitoringDevice
{

/// Battery level (0-100%)
Property BatteryLevel As %Integer [ InitialExpression = 100 ];

/// Power saving mode enabled
Property PowerSavingMode As %Boolean [ InitialExpression = 0 ];

/// Monitoring interval in seconds
Property MonitoringInterval As %Integer [ InitialExpression = 60 ];

/// Last measurement timestamp
Property LastMeasurement As %TimeStamp;

/// Stored measurements (limited capacity)
Property StoredMeasurements [ MultiDimensional ];

/// Maximum stored measurements
Parameter MAXSTORED = 50;

/// Current measurement count
Property MeasurementCount As %Integer [ InitialExpression = 0 ];

/// Device active status
Property IsActive As %Boolean [ InitialExpression = 0 ];

/// Constructor
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    // Initialize battery and power settings
    Set ..BatteryLevel = 100
    Set ..PowerSavingMode = 0
    Set ..MonitoringInterval = 60
    Set ..MeasurementCount = 0
    
    Quit $$$OK
}

/// Start monitoring - portable implementation
Method StartMonitoring() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check battery level
        If ..BatteryLevel < 10 {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "Battery too low to start monitoring"))
        }
        
        // Connect interface
        Set tSC = ..Connect()
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        Set ..IsMonitoring = 1
        Set ..LastMeasurement = $ZDATETIME($HOROLOG, 3)
        
        // Reduce battery for startup
        Set ..BatteryLevel = ..BatteryLevel - 2
        
        // Log status
        Do ..SendData("STATUS: Portable monitor started - Battery: "_..BatteryLevel_"%")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Stop monitoring - portable implementation
Method StopMonitoring() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '..IsMonitoring {
            Quit
        }
        
        // Save any pending measurements
        If ..MeasurementCount > 0 {
            Set tSC = ..TransmitStoredMeasurements()
            If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Disconnect interface
        If $ISOBJECT(..Interface) {
            Set tSC = ..Interface.Disconnect()
            If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Set ..IsMonitoring = 0
        
        // Log status
        Do ..SendData("STATUS: Portable monitor stopped - Battery: "_..BatteryLevel_"%")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Record a measurement
Method RecordMeasurement(pType As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check battery
        If ..BatteryLevel < 5 {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "Battery critical - cannot record"))
        }
        
        // Store measurement locally
        Set tIndex = ..MeasurementCount + 1
        If tIndex > ..#MAXSTORED {
            // Rotate measurements
            For i=1:1:(..#MAXSTORED-1) {
                Set ..StoredMeasurements(i) = ..StoredMeasurements(i+1)
            }
            Set tIndex = ..#MAXSTORED
        } Else {
            Set ..MeasurementCount = tIndex
        }
        
        Set ..StoredMeasurements(tIndex) = $LISTBUILD(
            $ZDATETIME($HOROLOG, 3),
            pType,
            pValue
        )
        
        Set ..LastMeasurement = $ZDATETIME($HOROLOG, 3)
        
        // Reduce battery per measurement
        Set ..BatteryLevel = ..BatteryLevel - 1
        
        // Transmit if not in power saving mode
        If '..PowerSavingMode && ..IsMonitoring {
            Set tSC = ..TransmitMeasurement(pType, pValue)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Transmit a single measurement
Method TransmitMeasurement(pType As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '$ISOBJECT(..Interface) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "No interface configured"))
        }
        
        // Format measurement data
        Set tData = "MEASUREMENT|"_pType_"|"_pValue_"|"_$ZDATETIME($HOROLOG, 3)
        
        Set tSC = ..SendData(tData)
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        // Battery usage for transmission
        Set ..BatteryLevel = ..BatteryLevel - 0.5
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Transmit all stored measurements
Method TransmitStoredMeasurements() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '$ISOBJECT(..Interface) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "No interface configured"))
        }
        
        // Send batch header
        Set tSC = ..SendData("BATCH_START: COUNT="_..MeasurementCount)
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        // Send each measurement
        For i=1:1:..MeasurementCount {
            If $DATA(..StoredMeasurements(i)) {
                Set tMeasurement = ..StoredMeasurements(i)
                Set tTimestamp = $LIST(tMeasurement, 1)
                Set tType = $LIST(tMeasurement, 2)
                Set tValue = $LIST(tMeasurement, 3)
                
                Set tData = "STORED|"_tType_"|"_tValue_"|"_tTimestamp
                Set tSC = ..SendData(tData)
                If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
            }
        }
        
        // Send batch footer
        Set tSC = ..SendData("BATCH_END: TRANSMITTED="_..MeasurementCount)
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        // Clear stored measurements after successful transmission
        Kill ..StoredMeasurements
        Set ..MeasurementCount = 0
        
        // Battery usage for batch transmission
        Set ..BatteryLevel = ..BatteryLevel - (..MeasurementCount * 0.2)
        If ..BatteryLevel < 0 Set ..BatteryLevel = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Enable/disable power saving mode
Method SetPowerSavingMode(pEnabled As %Boolean) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..PowerSavingMode = pEnabled
        
        If pEnabled {
            // Increase monitoring interval in power saving mode
            Set ..MonitoringInterval = ..MonitoringInterval * 2
            Do ..SendData("CONFIG: Power saving mode enabled")
        } Else {
            // Restore normal monitoring interval
            Set ..MonitoringInterval = ..MonitoringInterval / 2
            Do ..SendData("CONFIG: Power saving mode disabled")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Charge the battery
Method ChargeBattery(pAmount As %Integer = 100) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Cannot charge while connected/active
        If ..IsActive {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot charge while device is active")
            Quit
        }
        
        Set ..BatteryLevel = ..BatteryLevel + pAmount
        If ..BatteryLevel > 100 Set ..BatteryLevel = 100
        
        // Only send status if interface is available
        If $IsObject(..Interface) {
            Do ..SendData("STATUS: Battery charged to "_..BatteryLevel_"%")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Read data from the device
Method ReadData() As %String
{
    // Check if connected via interface
    If '$IsObject(..Interface) || '..Interface.IsConnected {
        Quit "Device not connected"
    }
    
    // Simulate reading basic vital signs
    Set heartRate = 60 + $Random(40)  // 60-100 bpm
    Set temp = 36.5 + ($Random(20) / 10)  // 36.5-38.5°C
    Set pulse = 60 + $Random(40)  // 60-100
    
    // Format the output
    Set output = ""
    Set output = output _ "Temp: " _ temp _ "°C | "
    Set output = output _ "Pulse: " _ pulse _ " bpm | "
    Set output = output _ "Battery: " _ ..BatteryLevel _ "%"
    
    // Reduce battery for reading
    Set ..BatteryLevel = ..BatteryLevel - 1
    If ..BatteryLevel < 0 Set ..BatteryLevel = 0
    
    Quit output
}

/// Check if battery is low
Method IsBatteryLow() As %Boolean
{
    Quit (..BatteryLevel < 15)
}

/// Override Connect to set IsActive
Method Connect() As %Status
{
    Set tSC = ##super()
    If $$$ISOK(tSC) {
        Set ..IsActive = 1
    }
    Quit tSC
}

/// Override Disconnect to clear IsActive
Method Disconnect() As %Status
{
    Set tSC = ##super()
    If $$$ISOK(tSC) {
        Set ..IsActive = 0
    }
    Quit tSC
}

/// Get current readings for compatibility
Method GetCurrentReadings() As %String
{
    Quit ..ReadData()
}

/// Get device status
Method GetStatus() As %String
{
    Set tStatus = "Portable Monitor Status:"
    Set tStatus = tStatus_$CHAR(10)_"  Battery: "_..BatteryLevel_"%"
    Set tStatus = tStatus_$CHAR(10)_"  Power Saving: "_$SELECT(..PowerSavingMode:"ON",1:"OFF")
    Set tStatus = tStatus_$CHAR(10)_"  Monitoring: "_$SELECT(..IsMonitoring:"ACTIVE",1:"INACTIVE")
    Set tStatus = tStatus_$CHAR(10)_"  Stored Measurements: "_..MeasurementCount
    Set tStatus = tStatus_$CHAR(10)_"  Monitoring Interval: "_..MonitoringInterval_" seconds"
    If ..LastMeasurement '= "" {
        Set tStatus = tStatus_$CHAR(10)_"  Last Measurement: "_..LastMeasurement
    }
    If $ISOBJECT(..Interface) {
        Set tStatus = tStatus_$CHAR(10)_"  Interface: "_..Interface.%ClassName(1)
    }
    
    Quit tStatus
}

}
