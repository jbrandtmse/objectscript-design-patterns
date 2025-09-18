/// Test helper for PortableMonitor fixes
Class Patterns.Test.PortableMonitorTestHelper
{

/// Test ChargeBattery method to verify parameter fix
ClassMethod TestChargeBattery() As %String
{
    Set result = ""
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting TestChargeBattery; "
    
    Try {
        // Create portable monitor
        Set monitor = ##class(Patterns.Examples.PortableMonitor).%New()
        Set ^ClineDebug = ^ClineDebug _ "Created monitor; "
        
        // Set interface
        Set wifi = ##class(Patterns.Examples.WiFiInterface).%New()
        Set tSC = monitor.SetInterface(wifi)
        Set ^ClineDebug = ^ClineDebug _ "Set interface: "_$System.Status.GetErrorText(tSC)_"; "
        
        // Test charging without connection (should work)
        Set initialBattery = monitor.BatteryLevel
        Set ^ClineDebug = ^ClineDebug _ "Initial battery: "_initialBattery_"; "
        
        // Reduce battery level first
        Set monitor.BatteryLevel = 50
        
        // Test charging
        Set tSC = monitor.ChargeBattery(30)
        Set ^ClineDebug = ^ClineDebug _ "ChargeBattery status: "_$System.Status.GetErrorText(tSC)_"; "
        Set ^ClineDebug = ^ClineDebug _ "Battery after charge: "_monitor.BatteryLevel_"; "
        
        If $$$ISOK(tSC) {
            Set result = "SUCCESS: ChargeBattery works correctly. Battery level: "_monitor.BatteryLevel
        }
        Else {
            Set result = "FAILED: "_$System.Status.GetErrorText(tSC)
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: "_ex.DisplayString()_"; "
        Set result = "ERROR: "_ex.DisplayString()
    }
    Quit result
}

/// Test SendData fix
ClassMethod TestSendData() As %String
{
    Set result = ""
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting TestSendData; "
    
    Try {
        // Create portable monitor
        Set monitor = ##class(Patterns.Examples.PortableMonitor).%New()
        Set ^ClineDebug = ^ClineDebug _ "Created monitor; "
        
        // Set interface
        Set bt = ##class(Patterns.Examples.BluetoothInterface).%New()
        Set tSC = monitor.SetInterface(bt)
        Set ^ClineDebug = ^ClineDebug _ "Set interface: "_$System.Status.GetErrorText(tSC)_"; "
        
        // Connect
        Set tSC = monitor.Connect()
        Set ^ClineDebug = ^ClineDebug _ "Connect status: "_$System.Status.GetErrorText(tSC)_"; "
        
        // Test SendData with single parameter
        Set tSC = monitor.SendData("TEST DATA")
        Set ^ClineDebug = ^ClineDebug _ "SendData status: "_$System.Status.GetErrorText(tSC)_"; "
        
        If $$$ISOK(tSC) {
            Set result = "SUCCESS: SendData works with single parameter"
        }
        Else {
            Set result = "FAILED: "_$System.Status.GetErrorText(tSC)
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: "_ex.DisplayString()_"; "
        Set result = "ERROR: "_ex.DisplayString()
    }
    Quit result
}

/// Run all tests
ClassMethod RunAll() As %String
{
    Set result = ""
    
    Set result = result _ "Test 1 - ChargeBattery: "
    Set result = result _ ..TestChargeBattery() _ $CHAR(10)
    
    Set result = result _ "Test 2 - SendData: "  
    Set result = result _ ..TestSendData() _ $CHAR(10)
    
    Set result = result _ $CHAR(10) _ "Debug log: " _ $GET(^ClineDebug)
    
    Quit result
}

}
