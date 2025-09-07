/// DeviceInterface: Abstract interface for medical device communication
/// Healthcare example of Bridge Pattern implementor
/// 
/// <p>This abstract class defines the interface for different communication
/// protocols (Bluetooth, WiFi, USB) that medical devices can use.
/// It demonstrates the implementor side of the Bridge pattern.</p>
Class Patterns.Examples.DeviceInterface Extends %RegisteredObject [ Abstract ]
{

/// Connection status
Property IsConnected As %Boolean [ InitialExpression = 0 ];

/// Interface configuration
Property InterfaceConfig As %String [ MultiDimensional ];

/// Device configuration
Property Configuration As %String [ MultiDimensional ];

/// Last activity timestamp
Property LastActivity As %String;

/// Last error message
Property LastError As %String;

/// Connection statistics
Property Statistics As %String [ MultiDimensional ];

/// Constructor - Initialize interface
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize statistics
        Set ..Statistics("PacketsSent") = 0
        Set ..Statistics("PacketsReceived") = 0
        Set ..Statistics("BytesSent") = 0
        Set ..Statistics("BytesReceived") = 0
        Set ..Statistics("Errors") = 0
        Set ..Statistics("ConnectionTime") = 0
        
        // Initialize configuration
        Set ..InterfaceConfig("Protocol") = "Standard"
        Set ..InterfaceConfig("Timeout") = 30
        Set ..InterfaceConfig("RetryCount") = 3
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Abstract method to get interface type
Method GetInterfaceType() As %String [ Abstract ]
{
    Quit ""
}

/// Abstract method to establish connection
Method Connect() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Abstract method to close connection
Method Disconnect() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Abstract method to send data
Method SendData(pData As %String) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Abstract method to receive data
Method ReceiveData(Output pData As %String) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Abstract method to test connection
Method TestConnection() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Configure interface with device information
Method Configure(pDeviceSerial As %String, pDeviceModel As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..InterfaceConfig("DeviceSerial") = pDeviceSerial
        Set ..InterfaceConfig("DeviceModel") = pDeviceModel
        Set ..InterfaceConfig("ConfigTime") = $ZDateTime($Horolog,3)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get current bandwidth usage
Method GetBandwidthUsage() As %String
{
    Set totalBytes = ..Statistics("BytesSent") + ..Statistics("BytesReceived")
    Set connectionTime = ..Statistics("ConnectionTime")
    
    If connectionTime = 0 {
        Quit "No active connection"
    }
    
    Set bandwidth = totalBytes / connectionTime
    Quit $Justify(bandwidth, 0, 2)_" bytes/sec"
}

/// Get connection statistics
Method GetStatistics() As %String
{
    Set stats = "=== Interface Statistics ==="_$Char(13,10)
    Set stats = stats_"Type: "_..GetInterfaceType()_$Char(13,10)
    Set stats = stats_"Connected: "_$Select(..IsConnected:"Yes",1:"No")_$Char(13,10)
    Set stats = stats_"Packets Sent: "_..Statistics("PacketsSent")_$Char(13,10)
    Set stats = stats_"Packets Received: "_..Statistics("PacketsReceived")_$Char(13,10)
    Set stats = stats_"Bytes Sent: "_..Statistics("BytesSent")_$Char(13,10)
    Set stats = stats_"Bytes Received: "_..Statistics("BytesReceived")_$Char(13,10)
    Set stats = stats_"Errors: "_..Statistics("Errors")_$Char(13,10)
    Set stats = stats_"Bandwidth: "_..GetBandwidthUsage()
    
    Quit stats
}

/// Reset statistics
Method ResetStatistics() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Statistics("PacketsSent") = 0
        Set ..Statistics("PacketsReceived") = 0
        Set ..Statistics("BytesSent") = 0
        Set ..Statistics("BytesReceived") = 0
        Set ..Statistics("Errors") = 0
        Set ..Statistics("ConnectionTime") = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Update statistics after sending data
Method UpdateSendStatistics(pDataSize As %Integer)
{
    Set ..Statistics("PacketsSent") = ..Statistics("PacketsSent") + 1
    Set ..Statistics("BytesSent") = ..Statistics("BytesSent") + pDataSize
}

/// Update statistics after receiving data
Method UpdateReceiveStatistics(pDataSize As %Integer)
{
    Set ..Statistics("PacketsReceived") = ..Statistics("PacketsReceived") + 1
    Set ..Statistics("BytesReceived") = ..Statistics("BytesReceived") + pDataSize
}

/// Record an error
Method RecordError(pErrorMsg As %String)
{
    Set ..LastError = pErrorMsg
    Set ..Statistics("Errors") = ..Statistics("Errors") + 1
}

/// Get interface configuration
Method GetConfiguration() As %String
{
    Set config = ""
    Set key = $Order(..InterfaceConfig(""))
    While key '= "" {
        If config '= "" Set config = config_", "
        Set config = config_key_"="_..InterfaceConfig(key)
        Set key = $Order(..InterfaceConfig(key))
    }
    Quit config
}

/// Set interface parameter
Method SetParameter(pKey As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        If pKey = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Parameter key cannot be empty")
            Quit
        }
        Set ..InterfaceConfig(pKey) = pValue
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get interface parameter
Method GetParameter(pKey As %String) As %String
{
    If pKey = "" Quit ""
    If $Data(..InterfaceConfig(pKey)) {
        Quit ..InterfaceConfig(pKey)
    }
    Quit ""
}

}
