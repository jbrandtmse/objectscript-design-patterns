/// Simple test for Bridge pattern implementation
Class Patterns.Test.BridgeSimpleTest
{

/// Test basic Bridge pattern functionality
ClassMethod TestBasicBridge() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting basic bridge test; "
    Set tResult = $$$OK
    
    Try {
        // Test basic abstraction
        Set ^ClineDebug = ^ClineDebug _ "Creating RefinedAbstraction; "
        Set tAbstraction = ##class(Patterns.GoF.Structural.RefinedAbstraction).%New()
        
        Set ^ClineDebug = ^ClineDebug _ "Creating ConcreteImplementorA; "
        Set tImplementorA = ##class(Patterns.GoF.Structural.ConcreteImplementorA).%New()
        
        Set ^ClineDebug = ^ClineDebug _ "Setting implementation; "
        Set tSC = tAbstraction.SetImplementation(tImplementorA)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Error setting implementation: " _ $System.Status.GetErrorText(tSC) _ "; "
            Set tResult = tSC
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "Calling Operation; "
        Set tOpResult = tAbstraction.Operation()
        Set ^ClineDebug = ^ClineDebug _ "Result: " _ tOpResult _ "; "
        
        If tOpResult '= "RefinedAbstraction: ConcreteImplementorA.OperationImpl() [StateA, Count=1]" {
            Set ^ClineDebug = ^ClineDebug _ "FAILED: Unexpected result; "
            Set tResult = $$$ERROR($$$GeneralError, "Unexpected result: " _ tOpResult)
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "PASSED: Basic bridge test; "
        Quit
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "Exception: " _ ex.DisplayString() _ "; "
        Set tResult = ex.AsStatus()
        Quit
    }
    
    Quit tResult
}

/// Test VitalSignsMonitor with Bluetooth interface
ClassMethod TestVitalSignsMonitor() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting VitalSignsMonitor test; "
    Set tResult = $$$OK
    
    Try {
        // Create monitor
        Set ^ClineDebug = ^ClineDebug _ "Creating VitalSignsMonitor; "
        Set tMonitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("VSM-TEST-001")
        
        // Create Bluetooth interface
        Set ^ClineDebug = ^ClineDebug _ "Creating BluetoothInterface; "
        Set tBluetooth = ##class(Patterns.Examples.BluetoothInterface).%New()
        
        // Check GetInterfaceType method
        Set ^ClineDebug = ^ClineDebug _ "Testing GetInterfaceType; "
        Set tType = tBluetooth.GetInterfaceType()
        Set ^ClineDebug = ^ClineDebug _ "Interface type: " _ tType _ "; "
        
        If tType '= "Bluetooth" {
            Set ^ClineDebug = ^ClineDebug _ "FAILED: Wrong interface type; "
            Set tResult = $$$ERROR($$$GeneralError, "Wrong interface type: " _ tType)
            Quit
        }
        
        // Set interface
        Set ^ClineDebug = ^ClineDebug _ "Setting interface; "
        Set tSC = tMonitor.SetInterface(tBluetooth)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Error setting interface: " _ $System.Status.GetErrorText(tSC) _ "; "
            Set tResult = tSC
            Quit
        }
        
        // Connect
        Set ^ClineDebug = ^ClineDebug _ "Connecting; "
        Set tSC = tMonitor.Connect()
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Error connecting: " _ $System.Status.GetErrorText(tSC) _ "; "
            Set tResult = tSC
            Quit
        }
        
        // Check if active
        Set ^ClineDebug = ^ClineDebug _ "Checking IsActive; "
        If 'tMonitor.IsActive {
            Set ^ClineDebug = ^ClineDebug _ "FAILED: Monitor not active; "
            Set tResult = $$$ERROR($$$GeneralError, "Monitor should be active after connection")
            Quit
        }
        
        // Read data
        Set ^ClineDebug = ^ClineDebug _ "Reading data; "
        Set tData = tMonitor.ReadData()
        Set ^ClineDebug = ^ClineDebug _ "Data: " _ tData _ "; "
        
        // Disconnect
        Set ^ClineDebug = ^ClineDebug _ "Disconnecting; "
        Set tSC = tMonitor.Disconnect()
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Error disconnecting: " _ $System.Status.GetErrorText(tSC) _ "; "
            Set tResult = tSC
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "PASSED: VitalSignsMonitor test; "
        Quit
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "Exception: " _ ex.DisplayString() _ "; "
        Set tResult = ex.AsStatus()
        Quit
    }
    
    Quit tResult
}

/// Test all interface types
ClassMethod TestAllInterfaces() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting all interfaces test; "
    Set tResult = $$$OK
    
    Try {
        // Test Bluetooth
        Set ^ClineDebug = ^ClineDebug _ "Testing Bluetooth; "
        Set tBluetooth = ##class(Patterns.Examples.BluetoothInterface).%New()
        If tBluetooth.GetInterfaceType() '= "Bluetooth" {
            Set ^ClineDebug = ^ClineDebug _ "FAILED: Wrong Bluetooth type; "
            Set tResult = $$$ERROR($$$GeneralError, "Wrong Bluetooth type")
            Quit
        }
        
        // Test WiFi
        Set ^ClineDebug = ^ClineDebug _ "Testing WiFi; "
        Set tWiFi = ##class(Patterns.Examples.WiFiInterface).%New()
        If tWiFi.GetInterfaceType() '= "WiFi" {
            Set ^ClineDebug = ^ClineDebug _ "FAILED: Wrong WiFi type; "
            Set tResult = $$$ERROR($$$GeneralError, "Wrong WiFi type")
            Quit
        }
        
        // Test USB
        Set ^ClineDebug = ^ClineDebug _ "Testing USB; "
        Set tUSB = ##class(Patterns.Examples.USBInterface).%New()
        If tUSB.GetInterfaceType() '= "USB" {
            Set ^ClineDebug = ^ClineDebug _ "FAILED: Wrong USB type; "
            Set tResult = $$$ERROR($$$GeneralError, "Wrong USB type")
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "PASSED: All interfaces have correct types; "
        Quit
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "Exception: " _ ex.DisplayString() _ "; "
        Set tResult = ex.AsStatus()
        Quit
    }
    
    Quit tResult
}

/// Run all simple tests
ClassMethod RunAll() As %Status
{
    Write !, "Running Bridge Simple Tests..."
    Write !, "=============================="
    
    // Test 1: Basic Bridge
    Write !, "Test 1: Basic Bridge Pattern..."
    Set tSC = ..TestBasicBridge()
    If $$$ISOK(tSC) {
        Write !, "  ✓ PASSED"
    } Else {
        Write !, "  ✗ FAILED: " _ $System.Status.GetErrorText(tSC)
    }
    
    // Test 2: VitalSignsMonitor
    Write !, "Test 2: VitalSignsMonitor with Bluetooth..."
    Set tSC = ..TestVitalSignsMonitor()
    If $$$ISOK(tSC) {
        Write !, "  ✓ PASSED"
    } Else {
        Write !, "  ✗ FAILED: " _ $System.Status.GetErrorText(tSC)
    }
    
    // Test 3: All Interfaces
    Write !, "Test 3: All Interface Types..."
    Set tSC = ..TestAllInterfaces()
    If $$$ISOK(tSC) {
        Write !, "  ✓ PASSED"
    } Else {
        Write !, "  ✗ FAILED: " _ $System.Status.GetErrorText(tSC)
    }
    
    Write !, "=============================="
    Write !, "Tests Complete"
    Write !
    
    // Show debug log
    Write !, "Debug Log:"
    Write !, ^ClineDebug
    
    Quit $$$OK
}

}
