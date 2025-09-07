/// WiFi communication interface implementation
/// Provides WiFi connectivity for medical monitoring devices
Class Patterns.Examples.WiFiInterface Extends Patterns.Examples.DeviceInterface
{

/// Network SSID
Property NetworkSSID As %String;

/// Network password
Property NetworkPassword As %String;

/// IP address
Property IPAddress As %String;

/// Signal strength (dBm)
Property SignalStrength As %Integer [ InitialExpression = -30 ];

/// WiFi standard (e.g., "802.11ac", "802.11n")
Property WiFiStandard As %String [ InitialExpression = "802.11ac" ];

/// Encryption type
Property EncryptionType As %String [ InitialExpression = "WPA2" ];

/// Network bandwidth (Mbps)
Property Bandwidth As %Integer [ InitialExpression = 100 ];

/// Connection quality (0-100)
Property ConnectionQuality As %Integer [ InitialExpression = 100 ];

/// Gateway address
Property GatewayAddress As %String [ InitialExpression = "192.168.1.1" ];

/// DNS server
Property DNSServer As %String [ InitialExpression = "8.8.8.8" ];

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Set WiFi-specific configuration
    Do ..Configuration.SetAt("wifi.standard", ..WiFiStandard)
    Do ..Configuration.SetAt("wifi.encryption", ..EncryptionType)
    Do ..Configuration.SetAt("wifi.frequency", "5GHz")
    Do ..Configuration.SetAt("wifi.channel", "auto")
    
    Quit $$$OK
}

/// Connect via WiFi
Method Connect() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if already connected
        If ..IsConnected {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "WiFi already connected"))
        }
        
        // Set default network if not specified
        If ..NetworkSSID = "" {
            Set ..NetworkSSID = "HealthcareNetwork"
            Set ..NetworkPassword = "SecureHealth2024"
        }
        
        Write !, "WiFi: Scanning for networks..."
        
        // Simulate network discovery
        Write !, "WiFi: Found network: "_..NetworkSSID
        Write !, "  Signal: "_..SignalStrength_" dBm ("_..GetSignalQuality()_")"
        Write !, "  Encryption: "_..EncryptionType
        
        // Simulate authentication
        Write !, "WiFi: Authenticating..."
        
        // Generate IP address
        Set ..IPAddress = "192.168.1."_(100 + $RANDOM(155))
        
        // Calculate connection quality based on signal
        Set ..ConnectionQuality = ..GetSignalQuality()
        
        If ..ConnectionQuality < 20 {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "WiFi signal too weak for reliable connection"))
        }
        
        Write !, "WiFi: Connected successfully"
        Write !, "  IP Address: "_..IPAddress
        Write !, "  Gateway: "_..GatewayAddress
        Write !, "  DNS: "_..DNSServer
        Write !, "  Bandwidth: "_..Bandwidth_" Mbps"
        
        Set ..IsConnected = 1
        Set ..LastActivity = $ZDATETIME($HOROLOG, 3)
        
        // Update statistics
        Set ..Statistics("connections") = ..Statistics("connections") + 1
        Set ..Statistics("last.connect") = ..LastActivity
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "WiFi: Connection failed - "_$SYSTEM.Status.GetErrorText(tSC)
    }
    
    Quit tSC
}

/// Disconnect WiFi
Method Disconnect() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '..IsConnected {
            Quit
        }
        
        Write !, "WiFi: Disconnecting from "_..NetworkSSID_"..."
        
        // Clear network information
        Set ..IPAddress = ""
        Set ..IsConnected = 0
        Set ..LastActivity = $ZDATETIME($HOROLOG, 3)
        
        // Update statistics
        Set ..Statistics("disconnections") = ..Statistics("disconnections") + 1
        Set ..Statistics("last.disconnect") = ..LastActivity
        
        Write !, "WiFi: Disconnected successfully"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Send data via WiFi
Method SendData(pData As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '..IsConnected {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "WiFi not connected"))
        }
        
        // Check connection quality
        Set ..ConnectionQuality = ..GetSignalQuality()
        If ..ConnectionQuality < 15 {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "WiFi connection quality too poor"))
        }
        
        // Calculate transmission metrics
        Set tDataSize = $LENGTH(pData)
        Set tEffectiveBandwidth = ..Bandwidth * (..ConnectionQuality / 100)
        Set tTransmissionTime = (tDataSize * 8) / (tEffectiveBandwidth * 1000000)
        
        // Add packet overhead - use integer arithmetic instead of $CEILING
        Set tPacketSize = 1500  // MTU size
        Set tPackets = (tDataSize + tPacketSize - 1) \ tPacketSize
        Set tOverhead = tPackets * 40  // TCP/IP header overhead
        
        Write !, "WiFi: Sending "_tDataSize_" bytes..."
        Write !, "  Network: "_..NetworkSSID
        Write !, "  Destination: "_..GatewayAddress
        Write !, "  Packets: "_tPackets
        Write !, "  Effective Bandwidth: "_$FNUMBER(tEffectiveBandwidth, "", 1)_" Mbps"
        
        // Simulate network latency
        Hang $SELECT(tTransmissionTime<0.01:0.01, 1:tTransmissionTime)
        
        // Random signal fluctuation
        Set ..SignalStrength = ..SignalStrength + $RANDOM(11) - 5  // ±5 dBm
        If ..SignalStrength > -20 Set ..SignalStrength = -20
        If ..SignalStrength < -90 Set ..SignalStrength = -90
        
        Set ..LastActivity = $ZDATETIME($HOROLOG, 3)
        
        // Update statistics
        Set ..Statistics("bytes.sent") = ..Statistics("bytes.sent") + tDataSize + tOverhead
        Set ..Statistics("messages.sent") = ..Statistics("messages.sent") + 1
        Set ..Statistics("packets.sent") = ..Statistics("packets.sent") + tPackets
        
        Write !, "WiFi: Data sent successfully"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "WiFi: Send failed - "_$SYSTEM.Status.GetErrorText(tSC)
        Set ..Statistics("errors") = ..Statistics("errors") + 1
        
        // Check for connection drop
        If ..ConnectionQuality < 10 {
            Set ..IsConnected = 0
            Write !, "WiFi: Connection lost"
        }
    }
    
    Quit tSC
}

/// Receive data via WiFi
Method ReceiveData(Output pData As %String) As %Status
{
    Set tSC = $$$OK
    Set pData = ""
    
    Try {
        If '..IsConnected {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR(5001, "WiFi not connected"))
        }
        
        // Simulate receiving data
        Write !, "WiFi: Receiving data..."
        
        // Generate simulated response with network info
        Set tResponseType = $RANDOM(4)
        Set pData = $CASE(tResponseType,
            0: "ACK|"_$ZDATETIME($HOROLOG, 3)_"|IP="_..IPAddress,
            1: "PING|RTT="_($RANDOM(50)+1)_"ms|TTL=64",
            2: "STATUS|Network="_..NetworkSSID_"|Signal="_..SignalStrength_"dBm",
            3: "BANDWIDTH|Current="_..Bandwidth_"Mbps|Quality="_..ConnectionQuality_"%"
        )
        
        Write !, "WiFi: Received: "_pData
        
        Set ..LastActivity = $ZDATETIME($HOROLOG, 3)
        
        // Update statistics
        Set ..Statistics("bytes.received") = ..Statistics("bytes.received") + $LENGTH(pData)
        Set ..Statistics("messages.received") = ..Statistics("messages.received") + 1
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "WiFi: Receive failed - "_$SYSTEM.Status.GetErrorText(tSC)
        Set ..Statistics("errors") = ..Statistics("errors") + 1
    }
    
    Quit tSC
}

/// Calculate signal quality percentage from dBm
Method GetSignalQuality() As %Integer [ Private ]
{
    // Convert dBm to quality percentage
    // -30 dBm = 100% (excellent)
    // -67 dBm = 50% (fair)
    // -80 dBm = 20% (poor)
    // -90 dBm = 0% (no signal)
    
    If ..SignalStrength >= -30 Quit 100
    If ..SignalStrength <= -90 Quit 0
    
    Set tQuality = 100 - (((-30 - ..SignalStrength) / 60) * 100)
    Quit $SELECT(tQuality<0:0, tQuality>100:100, 1:$NUMBER(tQuality, 0))
}

/// Get WiFi-specific status
Method GetInterfaceStatus() As %String
{
    Set tStatus = "WiFi Interface Status:"
    Set tStatus = tStatus_$CHAR(10)_"  Standard: "_..WiFiStandard
    Set tStatus = tStatus_$CHAR(10)_"  Connected: "_$SELECT(..IsConnected:"YES",1:"NO")
    If ..IsConnected {
        Set tStatus = tStatus_$CHAR(10)_"  Network: "_..NetworkSSID
        Set tStatus = tStatus_$CHAR(10)_"  IP Address: "_..IPAddress
        Set tStatus = tStatus_$CHAR(10)_"  Gateway: "_..GatewayAddress
        Set tStatus = tStatus_$CHAR(10)_"  DNS: "_..DNSServer
        Set tStatus = tStatus_$CHAR(10)_"  Signal: "_..SignalStrength_" dBm ("_..GetSignalQuality()_"%)"
        Set tStatus = tStatus_$CHAR(10)_"  Bandwidth: "_..Bandwidth_" Mbps"
        Set tStatus = tStatus_$CHAR(10)_"  Quality: "_..ConnectionQuality_"%"
    }
    Set tStatus = tStatus_$CHAR(10)_"  Encryption: "_..EncryptionType
    
    Quit tStatus
}

/// Change WiFi network
Method ChangeNetwork(pSSID As %String, pPassword As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Disconnect from current network if connected
        If ..IsConnected {
            Set tSC = ..Disconnect()
            If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Set new network credentials
        Set ..NetworkSSID = pSSID
        Set ..NetworkPassword = pPassword
        
        // Attempt to connect to new network
        Set tSC = ..Connect()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Run network diagnostics
Method RunDiagnostics() As %String
{
    Set tDiag = "WiFi Network Diagnostics:"
    Set tDiag = tDiag_$CHAR(10)_"========================"
    
    If ..IsConnected {
        // Ping test
        Set tPingTime = $RANDOM(50) + 1
        Set tDiag = tDiag_$CHAR(10)_"Ping to Gateway: "_tPingTime_" ms"
        
        // Bandwidth test
        Set tActualBandwidth = ..Bandwidth * (..ConnectionQuality / 100)
        Set tDiag = tDiag_$CHAR(10)_"Bandwidth Test: "_$FNUMBER(tActualBandwidth, "", 1)_" Mbps"
        
        // Packet loss
        Set tPacketLoss = $SELECT(..ConnectionQuality>80:0, ..ConnectionQuality>50:$RANDOM(3), 1:$RANDOM(10))
        Set tDiag = tDiag_$CHAR(10)_"Packet Loss: "_tPacketLoss_"%"
        
        // Jitter
        Set tJitter = $SELECT(..ConnectionQuality>70:$RANDOM(5), 1:$RANDOM(20))
        Set tDiag = tDiag_$CHAR(10)_"Jitter: "_tJitter_" ms"
        
        // Connection uptime
        Set tDiag = tDiag_$CHAR(10)_"Last Activity: "_..LastActivity
    } Else {
        Set tDiag = tDiag_$CHAR(10)_"Status: Not Connected"
    }
    
    Quit tDiag
}

}
