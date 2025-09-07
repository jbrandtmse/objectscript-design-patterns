/// MonitoringDevice: Abstract medical device with switchable communication interface
/// Healthcare example of Bridge Pattern abstraction
/// 
/// <p>This abstract class represents a medical monitoring device that can switch
/// between different communication interfaces (Bluetooth, WiFi, USB) at runtime.
/// It demonstrates the Bridge pattern in a healthcare context.</p>
Class Patterns.Examples.MonitoringDevice Extends %RegisteredObject [ Abstract ]
{

/// Reference to the communication interface (implementor)
Property Interface As Patterns.Examples.DeviceInterface;

/// Device serial number
Property SerialNumber As %String;

/// Device model name
Property ModelName As %String;

/// Current device status
Property Status As %String [ InitialExpression = "Initialized" ];

/// Device configuration settings
Property Configuration As %String [ MultiDimensional ];

/// Monitoring status flag
Property IsMonitoring As %Boolean [ InitialExpression = 0 ];

/// Constructor - Initialize device with serial number and model
Method %OnNew(pSerialNumber As %String = "", pModelName As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..SerialNumber = $Select(pSerialNumber'="":pSerialNumber,1:"SN-"_$Random(999999))
        Set ..ModelName = $Select(pModelName'="":pModelName,1:"Generic Monitor")
        
        // Initialize configuration
        Set ..Configuration("PowerMode") = "Normal"
        Set ..Configuration("SamplingRate") = "1Hz"
        Set ..Configuration("DataFormat") = "JSON"
        Set ..Configuration("Encryption") = "Enabled"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Set or switch the communication interface
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

/// Abstract method to start monitoring
/// <p>Subclasses must implement specific monitoring logic</p>
Method StartMonitoring() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Abstract method to stop monitoring
Method StopMonitoring() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Abstract method to get current readings
Method GetCurrentReadings() As %String [ Abstract ]
{
    Quit ""
}

/// Send data through the current interface
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
        Set packet.encrypted = ..Configuration("Encryption")
        
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

/// Receive data through the current interface
Method ReceiveData(Output pData As %String) As %Status
{
    Set tSC = $$$OK
    Set pData = ""
    
    Try {
        If '$IsObject(..Interface) {
            Set tSC = $$$ERROR($$$GeneralError, "No communication interface configured")
            Quit
        }
        
        // Receive through interface
        Set tSC = ..Interface.ReceiveData(.rawData)
        If $$$ISERR(tSC) {
            Set ..Status = "Reception Error"
            Quit
        }
        
        // Parse received data
        If rawData '= "" {
            Set json = {}.%FromJSON(rawData)
            Set pData = json.data
            Set ..Status = "Data Received"
        }
        Else {
            Set ..Status = "No Data"
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ..Status = "Receive Failed"
    }
    Quit tSC
}

/// Connect the device using current interface
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

/// Disconnect the device
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
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get device information
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

/// Configure device settings
Method ConfigureDevice(pKey As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        If pKey = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Configuration key cannot be empty")
            Quit
        }
        
        Set ..Configuration(pKey) = pValue
        
        // Apply configuration to interface if applicable
        If $IsObject(..Interface) && ((pKey = "DataFormat") || (pKey = "Encryption")) {
            Set tSC = ..Interface.Configure(..SerialNumber, ..ModelName)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get configuration value
Method GetConfiguration(pKey As %String) As %String
{
    If pKey = "" Quit ""
    If $Data(..Configuration(pKey)) {
        Quit ..Configuration(pKey)
    }
    Quit ""
}

/// Perform device self-test
Method SelfTest() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Status = "Self-Test Running"
        
        // Check basic device functionality
        If ..SerialNumber = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid serial number")
            Set ..Status = "Self-Test Failed"
            Quit
        }
        
        // Test interface if available
        If $IsObject(..Interface) {
            Set tSC = ..Interface.TestConnection()
            If $$$ISERR(tSC) {
                Set ..Status = "Interface Test Failed"
                Quit
            }
        }
        
        Set ..Status = "Self-Test Passed"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ..Status = "Self-Test Error"
    }
    Quit tSC
}

}
