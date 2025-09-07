/// USB communication interface implementation
/// Provides USB connectivity for medical monitoring devices
Class Patterns.Examples.USBInterface Extends Patterns.Examples.DeviceInterface
{

/// USB port number
Property PortNumber As %Integer;

/// USB version (e.g., "2.0", "3.0", "3.1")
Property USBVersion As %String [ InitialExpression = "3.0" ];

/// Device vendor ID
Property VendorID As %String;

/// Device product ID
Property ProductID As %String;

/// Transfer speed (Mbps)
Property TransferSpeed As %Integer;

/// USB device class
Property DeviceClass As %String [ InitialExpression = "Medical Device" ];

/// Power consumption (mA)
Property PowerDraw As %Integer [ InitialExpression = 500 ];

/// Connection type (Type-A, Type-C, etc.)
Property ConnectionType As %String [ InitialExpression = "Type-C" ];

/// Device serial number
Property SerialNumber As %String;

/// Enumeration status
Property IsEnumerated As %Boolean [ InitialExpression = 0 ];

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Generate USB identifiers
    Set ..VendorID = "0x"_$ZHEX($RANDOM(65536))
    Set ..ProductID = "0x"_$ZHEX($RANDOM(65536))
    Set ..SerialNumber = "USB-MED-"_$RANDOM(999999)
    
    // Set transfer speed based on USB version
    Set ..TransferSpeed = $CASE(..USBVersion,
        "3.1": 10000,   // 10 Gbps
        "3.0": 5000,    // 5 Gbps
        "2.0": 480,     // 480 Mbps
        "1.1": 12,      // 12 Mbps
        : 480           // Default to USB 2.0
    )
    
    // Set USB-specific configuration
    Do ..Configuration.SetAt("usb.version", ..USBVersion)
    Do ..Configuration.SetAt("usb.class", ..DeviceClass)
    Do ..Configuration.SetAt("usb.power.mode", "bus-powered")
    
    Quit $$$OK
}

/// Connect via USB
Method Connect() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if already connected
        If ..IsConnected {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "USB already connected"))
        }
        
        Write !, "USB: Detecting device..."
        
        // Simulate USB enumeration process
        Write !, "USB: Device detected on port "_..GetAvailablePort()
        Set ..PortNumber = ..GetAvailablePort()
        
        Write !, "USB: Enumerating device..."
        Write !, "  Vendor ID: "_..VendorID
        Write !, "  Product ID: "_..ProductID
        Write !, "  Serial: "_..SerialNumber
        
        // Check USB compatibility
        Write !, "USB: Checking compatibility..."
        Write !, "  USB Version: "_..USBVersion
        Write !, "  Connection Type: "_..ConnectionType
        Write !, "  Device Class: "_..DeviceClass
        
        // Simulate driver loading
        Write !, "USB: Loading device drivers..."
        Hang 0.5  // Simulate driver load time
        
        // Configure power
        Write !, "USB: Configuring power..."
        Write !, "  Power Draw: "_..PowerDraw_" mA"
        
        If ..PowerDraw > 900 && (..USBVersion = "2.0") {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "USB 2.0 cannot provide sufficient power"))
        }
        
        Set ..IsEnumerated = 1
        Write !, "USB: Device enumerated successfully"
        
        // Final connection
        Write !, "USB: Establishing data connection..."
        Write !, "  Transfer Speed: "_..GetFormattedSpeed()
        
        Set ..IsConnected = 1
        Set ..LastActivity = $ZDATETIME($HOROLOG, 3)
        
        // Update statistics
        Set ..Statistics("connections") = ..Statistics("connections") + 1
        Set ..Statistics("last.connect") = ..LastActivity
        
        Write !, "USB: Connected successfully on port "_..PortNumber
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "USB: Connection failed - "_$SYSTEM.Status.GetErrorText(tSC)
        Set ..IsEnumerated = 0
    }
    
    Quit tSC
}

/// Disconnect USB
Method Disconnect() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '..IsConnected {
            Quit
        }
        
        Write !, "USB: Safely removing device..."
        
        // Flush any pending data
        Write !, "USB: Flushing buffers..."
        
        // De-enumerate device
        Set ..IsEnumerated = 0
        Write !, "USB: Device de-enumerated"
        
        // Clear connection
        Set ..IsConnected = 0
        Set ..PortNumber = 0
        Set ..LastActivity = $ZDATETIME($HOROLOG, 3)
        
        // Update statistics
        Set ..Statistics("disconnections") = ..Statistics("disconnections") + 1
        Set ..Statistics("last.disconnect") = ..LastActivity
        
        Write !, "USB: Device safely removed"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Send data via USB
Method SendData(pData As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '..IsConnected {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "USB not connected"))
        }
        
        If '..IsEnumerated {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "USB device not enumerated"))
        }
        
        // Calculate transfer metrics
        Set tDataSize = $LENGTH(pData)
        Set tTransferTime = (tDataSize * 8) / (..TransferSpeed * 1000000)
        
        // USB packet size based on version
        Set tPacketSize = $CASE(..USBVersion,
            "3.1": 1024,    // SuperSpeed+
            "3.0": 1024,    // SuperSpeed
            "2.0": 512,     // High Speed
            : 64            // Full Speed
        )
        
        // Calculate ceiling division: (tDataSize + tPacketSize - 1) \ tPacketSize
        Set tPackets = (tDataSize + tPacketSize - 1) \ tPacketSize
        
        Write !, "USB: Transferring "_tDataSize_" bytes..."
        Write !, "  Port: "_..PortNumber
        Write !, "  Speed: "_..GetFormattedSpeed()
        Write !, "  Packets: "_tPackets_" x "_tPacketSize_" bytes"
        
        // Simulate bulk transfer
        Write !, "USB: Bulk transfer in progress..."
        
        // Simulate transfer delay (USB is typically very fast)
        Hang $SELECT(tTransferTime<0.001:0.001, 1:tTransferTime)
        
        // Update power consumption during transfer
        Set tActivePower = ..PowerDraw * 1.2  // 20% increase during transfer
        
        Set ..LastActivity = $ZDATETIME($HOROLOG, 3)
        
        // Update statistics
        Set ..Statistics("bytes.sent") = ..Statistics("bytes.sent") + tDataSize
        Set ..Statistics("messages.sent") = ..Statistics("messages.sent") + 1
        Set ..Statistics("packets.sent") = ..Statistics("packets.sent") + tPackets
        
        // Check for USB errors (rare)
        If $RANDOM(1000) < 2 {  // 0.2% error rate
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "USB transfer error - CRC check failed"))
        }
        
        Write !, "USB: Transfer completed successfully"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "USB: Transfer failed - "_$SYSTEM.Status.GetErrorText(tSC)
        Set ..Statistics("errors") = ..Statistics("errors") + 1
        
        // USB errors might require re-enumeration
        If $SYSTEM.Status.GetErrorText(tSC) [ "CRC" {
            Write !, "USB: Re-enumeration required"
            Set ..IsEnumerated = 0
        }
    }
    
    Quit tSC
}

/// Receive data via USB
Method ReceiveData(Output pData As %String) As %Status
{
    Set tSC = $$$OK
    Set pData = ""
    
    Try {
        If '..IsConnected {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "USB not connected"))
        }
        
        If '..IsEnumerated {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "USB device not enumerated"))
        }
        
        // Simulate receiving data
        Write !, "USB: Polling for data..."
        
        // Generate simulated response
        Set tResponseType = $RANDOM(4)
        Set pData = $CASE(tResponseType,
            0: "ACK|"_$ZDATETIME($HOROLOG, 3)_"|Port="_..PortNumber,
            1: "DEVICE|VID="_..VendorID_"|PID="_..ProductID_"|Serial="_..SerialNumber,
            2: "STATUS|Connected|Speed="_..GetFormattedSpeed()_"|Power="_..PowerDraw_"mA",
            3: "BULK|Transfer=Complete|Packets="_$RANDOM(100)_"|Errors=0"
        )
        
        Write !, "USB: Received: "_pData
        
        Set ..LastActivity = $ZDATETIME($HOROLOG, 3)
        
        // Update statistics
        Set ..Statistics("bytes.received") = ..Statistics("bytes.received") + $LENGTH(pData)
        Set ..Statistics("messages.received") = ..Statistics("messages.received") + 1
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "USB: Receive failed - "_$SYSTEM.Status.GetErrorText(tSC)
        Set ..Statistics("errors") = ..Statistics("errors") + 1
    }
    
    Quit tSC
}

/// Get available USB port
Method GetAvailablePort() As %Integer [ Private ]
{
    // Simulate finding an available USB port
    Quit $RANDOM(8) + 1  // Ports 1-8
}

/// Format transfer speed for display
Method GetFormattedSpeed() As %String [ Private ]
{
    If ..TransferSpeed >= 1000 {
        Quit $FNUMBER(..TransferSpeed/1000, "", 1)_" Gbps"
    }
    Quit ..TransferSpeed_" Mbps"
}

/// Get USB-specific status
Method GetInterfaceStatus() As %String
{
    Set tStatus = "USB Interface Status:"
    Set tStatus = tStatus_$CHAR(10)_"  Version: USB "_..USBVersion
    Set tStatus = tStatus_$CHAR(10)_"  Connection Type: "_..ConnectionType
    Set tStatus = tStatus_$CHAR(10)_"  Connected: "_$SELECT(..IsConnected:"YES",1:"NO")
    If ..IsConnected {
        Set tStatus = tStatus_$CHAR(10)_"  Port: "_..PortNumber
        Set tStatus = tStatus_$CHAR(10)_"  Enumerated: "_$SELECT(..IsEnumerated:"YES",1:"NO")
        Set tStatus = tStatus_$CHAR(10)_"  Transfer Speed: "_..GetFormattedSpeed()
    }
    Set tStatus = tStatus_$CHAR(10)_"  Vendor ID: "_..VendorID
    Set tStatus = tStatus_$CHAR(10)_"  Product ID: "_..ProductID
    Set tStatus = tStatus_$CHAR(10)_"  Serial Number: "_..SerialNumber
    Set tStatus = tStatus_$CHAR(10)_"  Device Class: "_..DeviceClass
    Set tStatus = tStatus_$CHAR(10)_"  Power Draw: "_..PowerDraw_" mA"
    
    Quit tStatus
}

/// Reset USB connection
Method ResetConnection() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write !, "USB: Resetting connection..."
        
        // Disconnect if connected
        If ..IsConnected {
            Set tSC = ..Disconnect()
            If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Brief delay
        Hang 1
        
        // Reconnect
        Set tSC = ..Connect()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check USB power requirements
Method CheckPowerRequirements() As %Boolean
{
    // USB 2.0: max 500mA
    // USB 3.0: max 900mA
    // USB Type-C: up to 1500mA (or more with USB-PD)
    
    Set tMaxPower = $CASE(..USBVersion,
        "3.1": 900,
        "3.0": 900,
        "2.0": 500,
        : 500
    )
    
    // Type-C can provide more power
    If ..ConnectionType = "Type-C" {
        Set tMaxPower = 1500
    }
    
    Quit (..PowerDraw <= tMaxPower)
}

}
