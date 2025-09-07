/// Unit tests for Gang of Four Bridge Pattern
Class Patterns.Test.Unit.GoF.Structural.BridgeTest Extends %UnitTest.TestCase
{

/// Constructor - required for %UnitTest.TestCase
Method %OnNew(initvalue As %String = "") As %Status
{
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    Quit $$$OK
}

/// Test basic abstraction with implementation
Method TestBasicBridge()
{
        Set tAbstraction = ##class(Patterns.GoF.Structural.RefinedAbstraction).%New()
        Set tImplementorA = ##class(Patterns.GoF.Structural.ConcreteImplementorA).%New()
        
        // Test without implementation
        Set tResult = tAbstraction.Operation()
        Do $$$AssertEquals(tResult, "RefinedAbstraction: No implementation set", "Should handle missing implementation")
        
        // Set implementation
        Set tSC = tAbstraction.SetImplementation(tImplementorA)
        Do $$$AssertStatusOK(tSC, "SetImplementation should succeed")
        
        // Test with implementation
        Set tResult = tAbstraction.Operation()
        Do $$$AssertEquals(tResult, "RefinedAbstraction: ConcreteImplementorA operation", "Should use implementation A")
        
        Quit
}

/// Test runtime implementation switching
Method TestImplementationSwitching()
{
        Set tAbstraction = ##class(Patterns.GoF.Structural.RefinedAbstraction).%New()
        Set tImplementorA = ##class(Patterns.GoF.Structural.ConcreteImplementorA).%New()
        Set tImplementorB = ##class(Patterns.GoF.Structural.ConcreteImplementorB).%New()
        
        // Start with Implementation A
        Set tSC = tAbstraction.SetImplementation(tImplementorA)
        Do $$$AssertStatusOK(tSC, "Setting implementation A should succeed")
        Set tResult = tAbstraction.Operation()
        Do $$$AssertEquals(tResult, "RefinedAbstraction: ConcreteImplementorA operation", "Should use implementation A")
        
        // Switch to Implementation B
        Set tSC = tAbstraction.SetImplementation(tImplementorB)
        Do $$$AssertStatusOK(tSC, "Switching to implementation B should succeed")
        Set tResult = tAbstraction.Operation()
        Do $$$AssertEquals(tResult, "RefinedAbstraction: ConcreteImplementorB operation", "Should use implementation B")
        
        Quit
}

/// Test extended operations in refined abstraction
Method TestRefinedAbstractionExtensions()
{
        Set tAbstraction = ##class(Patterns.GoF.Structural.RefinedAbstraction).%New()
        Set tImplementorA = ##class(Patterns.GoF.Structural.ConcreteImplementorA).%New()
        
        Set tSC = tAbstraction.SetImplementation(tImplementorA)
        Do $$$AssertStatusOK(tSC, "Setting implementation should succeed")
        
        // Test extended operation
        Set tResult = tAbstraction.ExtendedOperation()
        Do $$$AssertEquals(tResult, "Extended[ConcreteImplementorA operation]", "Extended operation should wrap implementation")
        
        // Test info method
        Set tInfo = tAbstraction.GetInfo()
        Do $$$AssertTrue(tInfo [ "ConcreteImplementorA", "Info should include implementation type")
        
        Quit
}

/// Test null implementation handling
Method TestNullImplementationHandling()
{
        Set tAbstraction = ##class(Patterns.GoF.Structural.RefinedAbstraction).%New()
        
        // Test setting null implementation
        Set tSC = tAbstraction.SetImplementation("")
        Do $$$AssertStatusNotOK(tSC, "Setting null implementation should fail")
        
        // Verify HasImplementation works correctly
        Do $$$AssertTrue('tAbstraction.HasImplementation(), "Should not have implementation")
        
        Quit
}

/// Test healthcare device with Bluetooth interface
Method TestVitalSignsMonitorWithBluetooth()
{
        Set tMonitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("VSM-TEST-001")
        Set tBluetooth = ##class(Patterns.Examples.BluetoothInterface).%New()
        
        // Configure interface
        Set tSC = tMonitor.SetInterface(tBluetooth)
        Do $$$AssertStatusOK(tSC, "Setting Bluetooth interface should succeed")
        
        // Connect device
        Set tSC = tMonitor.Connect()
        Do $$$AssertStatusOK(tSC, "Bluetooth connection should succeed")
        Do $$$AssertTrue(tMonitor.IsActive, "Device should be active")
        
        // Read data
        Set tData = tMonitor.ReadData()
        Do $$$AssertTrue(tData [ "Heart Rate", "Should read heart rate")
        Do $$$AssertTrue(tData [ "Blood Pressure", "Should read blood pressure")
        Do $$$AssertTrue(tData [ "O2 Sat", "Should read oxygen saturation")
        
        // Disconnect
        Set tSC = tMonitor.Disconnect()
        Do $$$AssertStatusOK(tSC, "Disconnection should succeed")
        Do $$$AssertTrue('tMonitor.IsActive, "Device should be inactive")
        
        Quit
}

/// Test portable monitor with WiFi interface
Method TestPortableMonitorWithWiFi()
{
        Set tMonitor = ##class(Patterns.Examples.PortableMonitor).%New("PM-TEST-002")
        Set tWiFi = ##class(Patterns.Examples.WiFiInterface).%New()
        
        // Configure interface
        Set tSC = tMonitor.SetInterface(tWiFi)
        Do $$$AssertStatusOK(tSC, "Setting WiFi interface should succeed")
        
        // Connect device
        Set tSC = tMonitor.Connect()
        Do $$$AssertStatusOK(tSC, "WiFi connection should succeed")
        
        // Read data
        Set tData = tMonitor.ReadData()
        Do $$$AssertTrue(tData [ "Temp", "Should read temperature")
        Do $$$AssertTrue(tData [ "Pulse", "Should read pulse")
        Do $$$AssertTrue(tData [ "Battery", "Should read battery level")
        
        // Test battery functions
        Do $$$AssertTrue('tMonitor.IsBatteryLow(), "New device should not have low battery")
        
        // Disconnect
        Set tSC = tMonitor.Disconnect()
        Do $$$AssertStatusOK(tSC, "Disconnection should succeed")
        
        Quit
}

/// Test interface switching on same device
Method TestInterfaceSwitching()
{
        Set tMonitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("VSM-SWITCH-003")
        Set tBluetooth = ##class(Patterns.Examples.BluetoothInterface).%New()
        Set tUSB = ##class(Patterns.Examples.USBInterface).%New()
        
        // Start with Bluetooth
        Set tSC = tMonitor.SetInterface(tBluetooth)
        Do $$$AssertStatusOK(tSC, "Setting Bluetooth interface should succeed")
        Set tSC = tMonitor.Connect()
        Do $$$AssertStatusOK(tSC, "Bluetooth connection should succeed")
        
        Set tData1 = tMonitor.ReadData()
        Do $$$AssertTrue(tData1 '= "", "Should read data via Bluetooth")
        
        // Disconnect and switch to USB
        Set tSC = tMonitor.Disconnect()
        Do $$$AssertStatusOK(tSC, "Bluetooth disconnection should succeed")
        
        Set tSC = tMonitor.SetInterface(tUSB)
        Do $$$AssertStatusOK(tSC, "Switching to USB interface should succeed")
        Set tSC = tMonitor.Connect()
        Do $$$AssertStatusOK(tSC, "USB connection should succeed")
        
        Set tData2 = tMonitor.ReadData()
        Do $$$AssertTrue(tData2 '= "", "Should read data via USB")
        
        // Clean up
        Set tSC = tMonitor.Disconnect()
        Do $$$AssertStatusOK(tSC, "USB disconnection should succeed")
        
        Quit
}

/// Test all three interfaces with same device
Method TestAllInterfaces()
{
        Set tMonitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("VSM-ALL-004")
        Set tInterfaces = $ListBuild(
            ##class(Patterns.Examples.BluetoothInterface).%New(),
            ##class(Patterns.Examples.WiFiInterface).%New(),
            ##class(Patterns.Examples.USBInterface).%New()
        )
        
        Set tPtr = 0
        While $ListNext(tInterfaces, tPtr, tInterface) {
            // Set interface
            Set tSC = tMonitor.SetInterface(tInterface)
            Do $$$AssertStatusOK(tSC, "Setting " _ tInterface.GetInterfaceType() _ " should succeed")
            
            // Connect
            Set tSC = tMonitor.Connect()
            Do $$$AssertStatusOK(tSC, tInterface.GetInterfaceType() _ " connection should succeed")
            
            // Read data
            Set tData = tMonitor.ReadData()
            Do $$$AssertTrue(tData '= "", "Should read data via " _ tInterface.GetInterfaceType())
            
            // Disconnect
            Set tSC = tMonitor.Disconnect()
            Do $$$AssertStatusOK(tSC, tInterface.GetInterfaceType() _ " disconnection should succeed")
        }
        
        Quit
}

/// Test vital signs alert generation
Method TestVitalSignsAlerts()
{
        Set tMonitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("VSM-ALERT-005")
        Set tWiFi = ##class(Patterns.Examples.WiFiInterface).%New()
        
        Set tSC = tMonitor.SetInterface(tWiFi)
        Do $$$AssertStatusOK(tSC, "Setting interface should succeed")
        
        Set tSC = tMonitor.Connect()
        Do $$$AssertStatusOK(tSC, "Connection should succeed")
        
        // Read data to populate vitals
        Set tData = tMonitor.ReadData()
        
        // Check alert generation (may or may not generate based on random values)
        Set tAlert = tMonitor.GenerateAlert()
        If tAlert '= "" {
            Do $$$AssertTrue(tAlert [ "ALERT", "Alert should contain ALERT keyword")
            Do $$$AssertTrue(tAlert [ "VSM-ALERT-005", "Alert should contain device ID")
        }
        
        Set tSC = tMonitor.Disconnect()
        Do $$$AssertStatusOK(tSC, "Disconnection should succeed")
        
        Quit
}

/// Test portable monitor battery operations
Method TestPortableMonitorBattery()
{
        Set tMonitor = ##class(Patterns.Examples.PortableMonitor).%New("PM-BATTERY-006")
        Set tUSB = ##class(Patterns.Examples.USBInterface).%New()
        
        Set tSC = tMonitor.SetInterface(tUSB)
        Do $$$AssertStatusOK(tSC, "Setting interface should succeed")
        
        // Test charging while disconnected
        Set tSC = tMonitor.ChargeBattery()
        Do $$$AssertStatusOK(tSC, "Charging while disconnected should succeed")
        Do $$$AssertEquals(tMonitor.BatteryLevel, 100, "Battery should be at 100%")
        
        // Connect and try to charge (should fail)
        Set tSC = tMonitor.Connect()
        Do $$$AssertStatusOK(tSC, "Connection should succeed")
        
        Set tSC = tMonitor.ChargeBattery()
        Do $$$AssertStatusNotOK(tSC, "Charging while connected should fail")
        
        // Simulate battery drain
        For i=1:1:85 {
            Set tData = tMonitor.ReadData()
        }
        
        Do $$$AssertTrue(tMonitor.IsBatteryLow(), "Battery should be low after multiple reads")
        
        Set tSC = tMonitor.Disconnect()
        Do $$$AssertStatusOK(tSC, "Disconnection should succeed")
        
        Quit
}

/// Test device without interface
Method TestDeviceWithoutInterface()
{
        Set tMonitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("VSM-NOIF-007")
        
        // Try to connect without interface
        Set tSC = tMonitor.Connect()
        Do $$$AssertStatusNotOK(tSC, "Connection without interface should fail")
        
        // Try to read data without interface
        Set tData = tMonitor.ReadData()
        Do $$$AssertTrue(tData [ "not connected", "Should indicate no connection")
        
        Quit
}

/// Performance test for delegation overhead
Method TestDelegationPerformance()
{
        Set tAbstraction = ##class(Patterns.GoF.Structural.RefinedAbstraction).%New()
        Set tImplementor = ##class(Patterns.GoF.Structural.ConcreteImplementorA).%New()
        
        Set tSC = tAbstraction.SetImplementation(tImplementor)
        Do $$$AssertStatusOK(tSC, "Setting implementation should succeed")
        
        // Measure time for multiple operations
        Set tIterations = 1000
        Set tStartTime = $ZH
        
        For i=1:1:tIterations {
            Set tResult = tAbstraction.Operation()
        }
        
        Set tEndTime = $ZH
        Set tTotalTime = tEndTime - tStartTime
        Set tAvgTime = tTotalTime / tIterations * 1000  // Convert to milliseconds
        
        // Assert reasonable performance (should be well under 1ms per operation)
        Do $$$AssertTrue(tAvgTime < 1, "Average delegation time should be under 1ms: " _ $Justify(tAvgTime, 0, 3) _ "ms")
        
        Quit
}

}
