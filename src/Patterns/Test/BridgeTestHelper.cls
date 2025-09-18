/// Helper class to test Bridge pattern without timeout issues
Class Patterns.Test.BridgeTestHelper Extends %RegisteredObject
{

/// Test basic Bridge pattern functionality
ClassMethod TestBridgePattern() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ""
    
    Try {
        // Test 1: Basic pattern classes
        Set ^ClineDebug = ^ClineDebug _ "Test 1: Creating RefinedAbstraction... "
        Set tAbstraction = ##class(Patterns.GoF.Structural.RefinedAbstraction).%New()
        Set ^ClineDebug = ^ClineDebug _ "OK; "
        
        // Test without implementation
        Set ^ClineDebug = ^ClineDebug _ "Testing without implementation... "
        Set tResult = tAbstraction.Operation()
        Set ^ClineDebug = ^ClineDebug _ "Result: " _ tResult _ "; "
        
        // Test with implementation A
        Set ^ClineDebug = ^ClineDebug _ "Creating ConcreteImplementorA... "
        Set tImplementorA = ##class(Patterns.GoF.Structural.ConcreteImplementorA).%New()
        Set tSC = tAbstraction.SetImplementation(tImplementorA)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ $SYSTEM.Status.GetErrorText(tSC) _ "; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "OK; "
        
        Set tResult = tAbstraction.Operation()
        Set ^ClineDebug = ^ClineDebug _ "Result with A: " _ tResult _ "; "
        
        // Test with implementation B
        Set ^ClineDebug = ^ClineDebug _ "Creating ConcreteImplementorB... "
        Set tImplementorB = ##class(Patterns.GoF.Structural.ConcreteImplementorB).%New()
        Set tSC = tAbstraction.SetImplementation(tImplementorB)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ $SYSTEM.Status.GetErrorText(tSC) _ "; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "OK; "
        
        Set tResult = tAbstraction.Operation()
        Set ^ClineDebug = ^ClineDebug _ "Result with B: " _ tResult _ "; "
        
        // Test 2: Healthcare example
        Set ^ClineDebug = ^ClineDebug _ $CHAR(10) _ "Test 2: Creating VitalSignsMonitor... "
        Set tMonitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("VSM-TEST-001")
        Set ^ClineDebug = ^ClineDebug _ "OK; "
        
        // Test with Bluetooth
        Set ^ClineDebug = ^ClineDebug _ "Creating BluetoothInterface... "
        Set tBluetooth = ##class(Patterns.Examples.BluetoothInterface).%New()
        Set tSC = tMonitor.SetInterface(tBluetooth)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ $SYSTEM.Status.GetErrorText(tSC) _ "; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "OK; "
        
        // Test ReadData method
        Set ^ClineDebug = ^ClineDebug _ "Testing ReadData (not connected): "
        Set tData = tMonitor.ReadData()
        Set ^ClineDebug = ^ClineDebug _ tData _ "; "
        
        // Test 3: Portable Monitor
        Set ^ClineDebug = ^ClineDebug _ $CHAR(10) _ "Test 3: Creating PortableMonitor... "
        Set tPortable = ##class(Patterns.Examples.PortableMonitor).%New("PM-TEST-001")
        Set ^ClineDebug = ^ClineDebug _ "OK; "
        
        // Test with WiFi
        Set ^ClineDebug = ^ClineDebug _ "Creating WiFiInterface... "
        Set tWiFi = ##class(Patterns.Examples.WiFiInterface).%New()
        Set tSC = tPortable.SetInterface(tWiFi)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ $SYSTEM.Status.GetErrorText(tSC) _ "; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "OK; "
        
        // Test battery functions
        Set ^ClineDebug = ^ClineDebug _ "Battery level: " _ tPortable.BatteryLevel _ "%; "
        Set ^ClineDebug = ^ClineDebug _ "Is battery low? " _ tPortable.IsBatteryLow() _ "; "
        
        // Test ChargeBattery
        Set ^ClineDebug = ^ClineDebug _ "Charging battery... "
        Set tSC = tPortable.ChargeBattery()
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "OK (correctly failed while not active); "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Charged to " _ tPortable.BatteryLevel _ "%; "
        }
        
        Set ^ClineDebug = ^ClineDebug _ $CHAR(10) _ "Bridge Pattern Tests Complete!"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug _ $CHAR(10) _ "ERROR: " _ $SYSTEM.Status.GetErrorText(tSC)
    }
    
    Quit tSC
}

/// Get test results
ClassMethod GetResults() As %String
{
    Quit $Get(^ClineDebug, "No test results available")
}

}
