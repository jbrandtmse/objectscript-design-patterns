# Chapter 8: Bridge Pattern

## Intent
Decouple an abstraction from its implementation so that the two can vary independently. The Bridge pattern lets you split a large class or a set of closely related classes into two separate hierarchies—abstraction and implementation—which can be developed independently of each other.

## Also Known As
Handle/Body

## Motivation
When an abstraction can have one of several possible implementations, the usual way to accommodate them is to use inheritance. An abstract class defines the interface to the abstraction, and concrete subclasses implement it in different ways. But this approach isn't always flexible enough. Inheritance binds an implementation to the abstraction permanently, which makes it difficult to modify, extend, and reuse abstractions and implementations independently.

Consider a medical monitoring device system in a hospital. You have different types of monitoring devices (vital signs monitors, portable monitors) that need to communicate through different interfaces (Bluetooth, WiFi, USB). Using inheritance alone would lead to a proliferation of classes: BluetoothVitalSignsMonitor, WiFiVitalSignsMonitor, USBVitalSignsMonitor, BluetoothPortableMonitor, WiFiPortableMonitor, USBPortableMonitor, etc.

The Bridge pattern addresses these problems by putting the abstraction and its implementation in separate class hierarchies. In our medical device example, we have:
- An abstraction hierarchy: MonitoringDevice → VitalSignsMonitor, PortableMonitor
- An implementation hierarchy: DeviceInterface → BluetoothInterface, WiFiInterface, USBInterface

This separation allows you to:
- Switch communication interfaces at runtime
- Add new device types without modifying existing interfaces
- Add new interface types without modifying existing devices
- Combine any device with any interface

## Applicability
Use the Bridge pattern when:
- You want to avoid a permanent binding between an abstraction and its implementation
- Both the abstractions and their implementations should be extensible by subclassing
- Changes in the implementation of an abstraction should have no impact on clients
- You want to share an implementation among multiple objects
- You have a proliferation of classes resulting from a coupled interface and numerous implementations
- You want to switch implementations at runtime

## Structure
```
     Abstraction                    Implementor
     +-----------+                  +-------------+
     |           |                  |             |
     |impl-------|----------------->|OperationImpl|
     |Operation()|                  |    <<abstract>>
     +-----------+                  +-------------+
          ^                              ^     ^
          |                              |     |
    RefinedAbstraction         ConcreteImplA ConcreteImplB
    +----------------+         +------------+ +------------+
    |                |         |            | |            |
    |RefinedOperation|         |OperationImpl |OperationImpl
    +----------------+         +------------+ +------------+
```

## Participants
- **Abstraction** (MonitoringDevice)
  - Defines the abstraction's interface
  - Maintains a reference to an object of type Implementor
  
- **RefinedAbstraction** (VitalSignsMonitor, PortableMonitor)
  - Extends the interface defined by Abstraction
  
- **Implementor** (DeviceInterface)
  - Defines the interface for implementation classes
  - This interface doesn't have to correspond exactly to Abstraction's interface
  
- **ConcreteImplementor** (BluetoothInterface, WiFiInterface, USBInterface)
  - Implements the Implementor interface and defines its concrete implementation

## Collaborations
- Abstraction forwards client requests to its Implementor object
- The abstraction and implementation can be extended independently
- The implementation can be selected or switched at runtime

## Consequences
The Bridge pattern has the following benefits and liabilities:

### Benefits
1. **Decoupling interface and implementation** - An implementation is not bound permanently to an interface
2. **Improved extensibility** - You can extend the Abstraction and Implementor hierarchies independently
3. **Hiding implementation details from clients** - You can shield clients from implementation details
4. **Runtime implementation switching** - You can switch implementations at runtime
5. **Reduced combinatorial explosion** - Avoids the proliferation of classes

### Liabilities
1. **Increased complexity** - The pattern introduces additional indirection
2. **Performance overhead** - The delegation from abstraction to implementation adds a small runtime cost

## Implementation
Consider the following implementation issues:

### 1. Only One Implementor
In situations where there's only one implementation, creating an abstract Implementor class isn't necessary. This is a degenerate case of the Bridge pattern; there's a one-to-one relationship between Abstraction and Implementor.

### 2. Creating the Right Implementor Object
How, when, and where do you decide which Implementor class to instantiate?
- If Abstraction knows about all ConcreteImplementor classes, it can instantiate one in its constructor
- You can use an Abstract Factory to create implementors
- You can defer the decision to runtime using configuration

### 3. Sharing Implementors
Multiple Abstraction objects can share the same Implementor object. This requires reference counting or garbage collection.

### 4. ObjectScript-Specific Considerations
- Use property references to maintain the implementor link
- Leverage %Status return values for error handling
- Consider using %RegisteredObject for automatic memory management
- Use MultiDimensional properties for complex configuration data

## Sample Code
Here's the ObjectScript implementation of the Bridge pattern:

### Core Pattern Classes
```objectscript
/// Abstraction in Bridge pattern
Class Patterns.GoF.Structural.Abstraction Extends %RegisteredObject [ Abstract ]
{
    /// Reference to the implementor
    Property Implementation As Patterns.GoF.Structural.Implementor;
    
    /// Set the implementation with validation
    Method SetImplementation(pImplementation As Implementor) As %Status
    {
        Set tSC = $$$OK
        Try {
            If '$IsObject(pImplementation) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(
                    $$$ERROR($$$GeneralError, "Implementation object is required"))
            }
            
            Set ..Implementation = pImplementation
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    /// Abstract operation that uses the implementation
    Method Operation() As %String [ Abstract ]
    {
        // Abstract method must have implementation body in ObjectScript
        Quit ""
    }
    
    /// Check if implementation is set
    Method HasImplementation() As %Boolean
    {
        Quit $IsObject(..Implementation)
    }
    
    /// Get the current implementation class name
    Method GetImplementationType() As %String
    {
        If ..HasImplementation() {
            Quit ..Implementation.%ClassName(1)
        }
        Quit ""
    }
}

/// Refined abstraction
Class Patterns.GoF.Structural.RefinedAbstraction Extends Abstraction
{
    Property AdditionalState As %String [ InitialExpression = "Refined" ];
    
    /// Implementation of the abstract Operation method
    Method Operation() As %String
    {
        Set tResult = ""
        
        If ..HasImplementation() {
            Set tImplResult = ..Implementation.OperationImpl()
            Set tResult = "RefinedAbstraction: Based on (" _ tImplResult _ ")"
        } Else {
            Set tResult = "RefinedAbstraction: No implementation set"
        }
        
        Quit tResult
    }
    
    /// Additional refined operation
    Method RefinedOperation() As %String
    {
        Set tResult = ""
        
        If ..HasImplementation() {
            Set tImplResult1 = ..Implementation.OperationImpl()
            Set tImplResult2 = ..Implementation.OperationImpl()
            Set tResult = "RefinedOperation: Combining [" _ tImplResult1 _ "] and [" _ tImplResult2 _ "]"
            Set tResult = tResult _ " with state: " _ ..AdditionalState
        } Else {
            Set tResult = "RefinedOperation: No implementation available"
        }
        
        Quit tResult
    }
    
    /// Extended operation with parameters
    Method ExtendedOperation(pParameter As %String) As %String
    {
        Set tResult = ""
        
        If ..HasImplementation() {
            Set tImplResult = ..Implementation.OperationImpl()
            Set tResult = "Extended[" _ pParameter _ "]: " _ tImplResult
        } Else {
            Set tResult = "ExtendedOperation: No implementation"
        }
        
        Quit tResult
    }
    
    /// Get status information
    Method GetStatus() As %String
    {
        Set tStatus = "RefinedAbstraction Status: "
        Set tStatus = tStatus _ "State=" _ ..AdditionalState _ ", "
        
        If ..HasImplementation() {
            Set tStatus = tStatus _ "Implementation=" _ ..GetImplementationType()
        } Else {
            Set tStatus = tStatus _ "Implementation=None"
        }
        
        Quit tStatus
    }
}
```

### Healthcare Example
```objectscript
/// Medical monitoring device abstraction
Class Patterns.Examples.MonitoringDevice Extends %RegisteredObject [ Abstract ]
{
    Property Interface As DeviceInterface;
    Property SerialNumber As %String;
    Property ModelName As %String;
    Property Status As %String [ InitialExpression = "Initialized" ];
    Property Configuration As %String [ MultiDimensional ];
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
    
    Method SetInterface(pInterface As DeviceInterface) As %Status
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
    
    /// Abstract methods
    Method StartMonitoring() As %Status [ Abstract ] { Quit $$$OK }
    Method StopMonitoring() As %Status [ Abstract ] { Quit $$$OK }
    Method GetCurrentReadings() As %String [ Abstract ] { Quit "" }
}

/// Vital signs monitor implementation
Class Patterns.Examples.VitalSignsMonitor Extends MonitoringDevice
{
    Property VitalSigns As %String [ MultiDimensional ];
    Property AlertThresholds As %String [ MultiDimensional ];
    Property MonitoringFrequency As %Integer [ InitialExpression = 60 ];
    Property AlertActive As %Boolean [ InitialExpression = 0 ];
    Property PatientID As %String;
    Property IsActive As %Boolean [ InitialExpression = 0 ];
    
    Method %OnNew(pSerialNumber As %String = "", pPatientID As %String = "") As %Status
    {
        // Call parent constructor
        Set tSC = ##super(pSerialNumber, "VitalSignsMonitor-VSM2000")
        If $$$ISERR(tSC) Quit tSC
        
        Try {
            Set ..PatientID = pPatientID
            
            // Initialize vital signs
            Set ..VitalSigns("HeartRate") = 0
            Set ..VitalSigns("SystolicBP") = 0
            Set ..VitalSigns("DiastolicBP") = 0
            Set ..VitalSigns("OxygenSaturation") = 0
            Set ..VitalSigns("Temperature") = 0
            Set ..VitalSigns("RespiratoryRate") = 0
            
            // Set default alert thresholds
            Set ..AlertThresholds("HeartRate","Min") = 50
            Set ..AlertThresholds("HeartRate","Max") = 120
            Set ..AlertThresholds("OxygenSaturation","Min") = 92
            // ... additional thresholds ...
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    Method StartMonitoring() As %Status
    {
        Set tSC = $$$OK
        Try {
            If '$IsObject(..Interface) {
                Set tSC = $$$ERROR($$$GeneralError, "No communication interface configured")
                Quit
            }
            
            // Connect through interface
            Set tSC = ..Connect()
            If $$$ISERR(tSC) Quit
            
            Set ..Status = "Monitoring Active"
            Set ..IsActive = 1
            
            // Simulate initial readings
            Do ..SimulateVitalSigns()
            
            // Send initial data
            Set tSC = ..TransmitVitalSigns()
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    Method GetCurrentReadings() As %String
    {
        Set readings = {}
        Set readings.timestamp = $ZDateTime($Horolog,3)
        Set readings.patientId = ..PatientID
        Set readings.heartRate = ..VitalSigns("HeartRate")
        Set readings.bloodPressure = ..VitalSigns("SystolicBP")_"/"_..VitalSigns("DiastolicBP")
        Set readings.oxygenSaturation = ..VitalSigns("OxygenSaturation")
        Set readings.temperature = ..VitalSigns("Temperature")
        Set readings.respiratoryRate = ..VitalSigns("RespiratoryRate")
        Set readings.alertActive = ..AlertActive
        
        Quit readings.%ToJSON()
    }
}

/// Abstract DeviceInterface implementor
Class Patterns.Examples.DeviceInterface Extends %RegisteredObject [ Abstract ]
{
    Property IsConnected As %Boolean [ InitialExpression = 0 ];
    Property InterfaceConfig As %String [ MultiDimensional ];
    Property Statistics As %String [ MultiDimensional ];
    
    Method GetInterfaceType() As %String [ Abstract ] { Quit "" }
    Method Connect() As %Status [ Abstract ] { Quit $$$OK }
    Method Disconnect() As %Status [ Abstract ] { Quit $$$OK }
    Method SendData(pData As %String) As %Status [ Abstract ] { Quit $$$OK }
    Method ReceiveData(Output pData As %String) As %Status [ Abstract ] { Quit $$$OK }
    Method TestConnection() As %Status [ Abstract ] { Quit $$$OK }
    
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
}

/// Bluetooth communication implementor
Class Patterns.Examples.BluetoothInterface Extends DeviceInterface
{
    Property BluetoothAddress As %String;
    Property SignalStrength As %Integer;
    Property Pairing As %String [ MultiDimensional ];
    
    Method GetInterfaceType() As %String
    {
        Quit "Bluetooth"
    }
    
    Method Connect() As %Status
    {
        Set tSC = $$$OK
        Try {
            // Bluetooth-specific connection logic
            Set ..IsConnected = 1
            Set ..SignalStrength = 80 + $Random(20)
            // Additional connection logic...
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    Method SendData(pData As %String) As %Status
    {
        Set tSC = $$$OK
        Try {
            If '..IsConnected {
                Set tSC = $$$ERROR($$$GeneralError, "Bluetooth not connected")
                Quit
            }
            // Bluetooth protocol implementation
            Do ..UpdateSendStatistics($Length(pData))
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
}

/// WiFi communication implementor
Class Patterns.Examples.WiFiInterface Extends DeviceInterface
{
    Property SSID As %String;
    Property SignalQuality As %Integer;
    
    Method GetInterfaceType() As %String
    {
        Quit "WiFi"
    }
    
    Method Connect() As %Status
    {
        Set tSC = $$$OK
        Try {
            // WiFi-specific connection logic
            Set ..IsConnected = 1
            Set ..SignalQuality = 70 + $Random(30)
            // Additional connection logic...
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
}

/// USB communication implementor
Class Patterns.Examples.USBInterface Extends DeviceInterface
{
    Property USBPort As %String;
    Property USBSpeed As %String;
    
    Method GetInterfaceType() As %String
    {
        Quit "USB"
    }
    
    Method Connect() As %Status
    {
        Set tSC = $$$OK
        Try {
            // USB-specific connection logic
            Set ..IsConnected = 1
            Set ..USBSpeed = "USB 3.0"
            // Additional connection logic...
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
}
```

### Usage Example
```objectscript
// Create monitoring device with patient ID
Set monitor = ##class(VitalSignsMonitor).%New("", "PATIENT-001")

// Use Bluetooth initially
Set bluetooth = ##class(BluetoothInterface).%New()
Set tSC = monitor.SetInterface(bluetooth)
If $$$ISOK(tSC) {
    Set tSC = monitor.StartMonitoring()
}

// Get current readings
Write monitor.GetCurrentReadings(), !

// Switch to WiFi at runtime
Set wifi = ##class(WiFiInterface).%New()
Set tSC = monitor.SetInterface(wifi)

// Send updated data through new interface
Set tSC = monitor.TransmitVitalSigns()

// Stop monitoring when done
Set tSC = monitor.StopMonitoring()
```

## Known Uses
- GUI frameworks separate window abstraction from window system implementation
- Device drivers separate logical device interface from hardware-specific implementation
- Database systems separate logical queries from physical execution strategies
- Healthcare systems separate medical device interfaces from communication protocols

## Related Patterns
- **Abstract Factory** can create and configure a particular Bridge
- **Adapter** is geared toward making unrelated classes work together. Bridge is designed up-front to let abstractions and implementations vary independently
- **Strategy** pattern is similar but focuses on algorithms rather than implementations

## Healthcare Context
In healthcare systems, the Bridge pattern is particularly valuable for:
- Medical device integration with multiple communication protocols
- Patient monitoring systems that work with various sensor types
- Laboratory equipment that supports different data formats
- Healthcare information exchanges with multiple transport mechanisms
- Medical imaging systems with various storage backends

The pattern ensures that medical devices can be upgraded or replaced without affecting the monitoring software, and new communication protocols can be added without modifying device implementations.
