/// Debug helper for Bridge pattern tests
Class Patterns.Test.BridgeDebugHelper Extends %RegisteredObject
{

/// Run a specific test and capture debug info
ClassMethod RunSingleTest(pTestName As %String = "TestBasicBridge") As %Status
{
    // Clear debug global
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "Starting test: " _ pTestName _ "; "
    Set tResult = $$$OK
    
    Try {
        // Create test instance
        Set tTest = ##class(Patterns.Test.Unit.GoF.Structural.BridgeTest).%New()
        Set ^ClineDebug = ^ClineDebug _ "Test instance created; "
        
        // Run the specific test method
        If pTestName = "TestBasicBridge" {
            Set tResult = tTest.TestBasicBridge()
        } ElseIf pTestName = "TestVitalSignsMonitorWithBluetooth" {
            Set tResult = tTest.TestVitalSignsMonitorWithBluetooth()
        } ElseIf pTestName = "TestAllInterfaces" {
            Set tResult = tTest.TestAllInterfaces()
        } Else {
            Set tResult = $$$ERROR($$$GeneralError, "Unknown test: " _ pTestName)
        }
        
        If $$$ISERR(tResult) {
            Set ^ClineDebug = ^ClineDebug _ "Test failed: " _ $System.Status.GetErrorText(tResult) _ "; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Test completed successfully; "
        }
        
        Quit  // Argumentless QUIT
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "Exception: " _ ex.DisplayString() _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Location: " _ ex.Location _ "; "
        Set tResult = ex.AsStatus()
        Quit  // Argumentless QUIT
    }
    
    Quit tResult
}

/// Check if interface classes have required methods
ClassMethod CheckInterfaceMethods() As %Status
{
    Set ^ClineDebug = ""
    Set tResult = $$$OK
    
    Try {
        // Check BluetoothInterface
        Set ^ClineDebug = ^ClineDebug _ "Checking BluetoothInterface; "
        Set tBluetooth = ##class(Patterns.Examples.BluetoothInterface).%New()
        
        // Check for GetInterfaceType method
        If ##class(%Dictionary.CompiledMethod).%ExistsId("Patterns.Examples.BluetoothInterface||GetInterfaceType") {
            Set ^ClineDebug = ^ClineDebug _ "GetInterfaceType exists; "
            Set tType = tBluetooth.GetInterfaceType()
            Set ^ClineDebug = ^ClineDebug _ "Type: " _ tType _ "; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "GetInterfaceType NOT FOUND; "
        }
        
        // Check Statistics property
        Set ^ClineDebug = ^ClineDebug _ "Statistics check: "
        If $Data(tBluetooth.Statistics) {
            Set ^ClineDebug = ^ClineDebug _ "exists; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "NOT FOUND; "
        }
        
        Quit  // Argumentless QUIT
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "Error: " _ ex.DisplayString() _ "; "
        Set tResult = ex.AsStatus()
        Quit  // Argumentless QUIT
    }
    
    Quit tResult
}

}
