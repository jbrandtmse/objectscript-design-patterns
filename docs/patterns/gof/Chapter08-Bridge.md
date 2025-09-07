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
    
    /// Set the implementation
    Method SetImplementation(pImplementation As Implementor) As %Status
    {
        Set ..Implementation = pImplementation
        Quit $$$OK
    }
    
    /// Operation that uses the implementation
    Method Operation() As %String
    {
        If '$IsObject(..Implementation) {
            Quit "No implementation"
        }
        Quit "Abstraction: " _ ..Implementation.OperationImpl()
    }
}

/// Refined abstraction
Class Patterns.GoF.Structural.RefinedAbstraction Extends Abstraction
{
    Method ExtendedOperation() As %String
    {
        If '$IsObject(..Implementation) {
            Quit "No implementation"
        }
        Set result = "RefinedAbstraction: Extended -> "
        Set result = result _ ..Implementation.OperationImpl()
        Quit result
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
    Property IsMonitoring As %Boolean;
    
    Method SetInterface(pInterface As DeviceInterface) As %Status
    {
        If $IsObject(..Interface) {
            Do ..Interface.Disconnect()
        }
        Set ..Interface = pInterface
        Quit $$$OK
    }
    
    Method SendData(pData As %String) As %Status
    {
        If '$IsObject(..Interface) {
            Quit $$$ERROR($$$GeneralError, "No interface")
        }
        Quit ..Interface.SendData(pData)
    }
}

/// Vital signs monitor implementation
Class Patterns.Examples.VitalSignsMonitor Extends MonitoringDevice
{
    Property HeartRate As %Integer;
    Property BloodPressure As %String;
    
    Method StartMonitoring() As %Status
    {
        Set ..IsMonitoring = 1
        Do ..Interface.Connect()
        // Monitor vital signs
        Quit $$$OK
    }
}

/// Bluetooth communication implementor
Class Patterns.Examples.BluetoothInterface Extends DeviceInterface
{
    Method Connect() As %Status
    {
        // Bluetooth-specific connection
        Set ..IsConnected = 1
        Quit $$$OK
    }
    
    Method SendData(pData As %String) As %Status
    {
        // Send via Bluetooth protocol
        Quit $$$OK
    }
}
```

### Usage Example
```objectscript
// Create monitoring device
Set monitor = ##class(VitalSignsMonitor).%New()

// Use Bluetooth initially
Set bluetooth = ##class(BluetoothInterface).%New()
Do monitor.SetInterface(bluetooth)
Do monitor.StartMonitoring()

// Switch to WiFi at runtime
Set wifi = ##class(WiFiInterface).%New()
Do monitor.SetInterface(wifi)
Do monitor.SendData("Vital signs data")
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
