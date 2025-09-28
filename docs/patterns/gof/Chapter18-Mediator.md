# Chapter 18: Mediator Pattern

## Intent
**Define an object that encapsulates how a set of objects interact. Mediator promotes loose coupling by keeping objects from referring to each other explicitly, and it lets you vary their interaction independently.**

## Also Known As
- Controller
- Intermediary

## Motivation
Object-oriented design encourages the distribution of behavior among objects. However, this distribution can result in a structure where objects have many connections to each other. In the worst case, every object knows about every other object.

As object interconnections increase, it becomes harder to reuse objects in different contexts because they're coupled to many other objects they interact with. Moreover, it becomes difficult to change the system's behavior significantly without defining many subclasses.

The Mediator pattern addresses this problem by introducing a mediator object between interacting objects. Instead of objects communicating directly, they communicate through the mediator, which encapsulates the interaction logic.

### Healthcare System Example
Consider a hospital system where different departments need to coordinate:
- Emergency Department admits patients and requests tests
- Radiology Department performs imaging studies
- Laboratory Department runs blood tests
- Pharmacy Department dispenses medications
- Billing Department processes charges

Without a mediator, each department would need to know about and communicate directly with every other department. This creates a complex web of dependencies. With a mediator (Hospital Coordinator), departments only need to know about the mediator, which handles routing and coordination.

## Applicability
Use the Mediator pattern when:
- A set of objects communicate in well-defined but complex ways
- Reusing an object is difficult because it refers to and communicates with many other objects
- A behavior distributed between several classes should be customizable without excessive subclassing
- You want to encapsulate protocols and make the protocol reusable

## Structure
```
    Mediator                    Colleague
    ┌──────────────┐           ┌──────────────┐
    │ <<interface>>│◄──────────│ <<abstract>> │
    │   Mediator   │           │  Colleague   │
    ├──────────────┤           ├──────────────┤
    │ +Notify()    │           │ +Send()      │
    └──────────────┘           │ +Receive()   │
           ▲                   └──────────────┘
           │                          ▲
           │                          │
    ┌──────────────┐           ┌──────────────┐
    │   Concrete   │◄─────────►│   Concrete   │
    │   Mediator   │           │  Colleague1  │
    └──────────────┘           └──────────────┘
           ▲                          ▲
           │                          │
           └──────────────────────────┘
                                ┌──────────────┐
                                │   Concrete   │
                                │  Colleague2  │
                                └──────────────┘
```

## Participants

### Mediator (Patterns.GoF.Behavioral.Mediator)
- Defines an interface for communicating with Colleague objects

### ConcreteMediator (Patterns.GoF.Behavioral.ConcreteMediator)
- Implements cooperative behavior by coordinating Colleague objects
- Knows and maintains its colleagues

### Colleague (Patterns.GoF.Behavioral.Colleague)
- Each Colleague class knows its Mediator object
- Each colleague communicates with its mediator when it would otherwise communicate directly with another colleague

### ConcreteColleague (EmergencyDepartment, RadiologyDepartment, etc.)
- Implements the colleague interface
- Communicates with other colleagues through the mediator

## Collaborations
- Colleagues send and receive messages through the Mediator
- The Mediator implements the cooperative behavior by routing messages between appropriate Colleagues

## Consequences
The Mediator pattern has the following benefits and liabilities:

### Benefits
1. **Reduced coupling**: The Mediator pattern reduces coupling between Colleagues. Colleagues don't need to know about each other, only about the mediator.

2. **Increased reusability**: Individual Colleague classes can be reused more easily because they're not coupled to other Colleagues.

3. **Simplified object protocols**: The mediator replaces many-to-many interactions with one-to-many interactions between the mediator and its colleagues.

4. **Centralized control**: The mediator centralizes control logic. This makes it easier to understand, maintain, and modify interaction logic.

5. **Simplified colleague implementation**: Colleagues are simpler because they only need to know how to communicate with the mediator, not with other colleagues.

### Liabilities
1. **Mediator complexity**: The mediator can become complex as more colleagues and interactions are added. This can make the mediator itself difficult to maintain and extend.

2. **Single point of failure**: The mediator becomes a critical component. If it fails, the entire communication system fails.

3. **Performance overhead**: All communication goes through the mediator, which can become a bottleneck in high-traffic scenarios.

## Implementation
Consider the following implementation issues:

### 1. Omitting the Abstract Mediator Class
When there's only one mediator, you don't need an abstract Mediator class. The Colleague classes can communicate directly with the concrete mediator.

### 2. Colleague-Mediator Communication
Colleagues need to communicate with their mediator when an event of interest occurs. Different approaches include:
- **Observer Pattern**: Implement the mediator as an Observer where colleagues are Subjects
- **Specialized notification interface**: Define a specialized interface that lets colleagues be more direct in their communication

### 3. Message-Based Communication
Our implementation uses message objects for decoupled communication:
```objectscript
Class Patterns.GoF.Behavioral.Message {
    Property Type As %String;
    Property Sender As %String;
    Property Data As %DynamicObject;
    Property Priority As %Integer;
}
```

### 4. Event Dispatching
The EventDispatcher provides publish-subscribe capabilities:
```objectscript
// Subscribe to events
Set tSC = dispatcher.Subscribe("EVENT_TYPE", "Handler", priority)

// Dispatch events
Set tSC = dispatcher.Dispatch(event)
```

### 5. Dynamic Colleague Registration
The ColleagueRegistry allows runtime registration and discovery:
```objectscript
// Register colleague with metadata
Set tSC = registry.RegisterColleague(id, colleague, type, metadata)

// Find colleagues by type
Set colleagues = registry.FindByType("Emergency")
```

## Sample Code
Here's the implementation of the Mediator pattern in ObjectScript:

### Abstract Mediator
```objectscript
Class Patterns.GoF.Behavioral.Mediator [ Abstract ]
{
    Method Notify(pColleague As Colleague, pEvent As %String, 
                  pData As %DynamicObject = "") As %Status [ Abstract ]
    {
        Quit $$$OK
    }
    
    Method RegisterColleague(pColleague As Colleague) As %Status [ Abstract ]
    {
        Quit $$$OK
    }
    
    Method DeregisterColleague(pColleague As Colleague) As %Status [ Abstract ]
    {
        Quit $$$OK
    }
}
```

### Concrete Mediator with Event Routing
```objectscript
Class Patterns.GoF.Behavioral.ConcreteMediator Extends Mediator
{
    Property Colleagues As %ListOfObjects [ Private ];
    Property EventDispatcher As EventDispatcher;
    
    Method Notify(pColleague As Colleague, pEvent As %String, 
                  pData As %DynamicObject = "") As %Status
    {
        // Route based on event type
        If pEvent = "BROADCAST" {
            Quit ..BroadcastToAll(pColleague, pData)
        } ElseIf pEvent = "REQUEST" {
            Quit ..HandleRequest(pColleague, pData)
        }
        Quit $$$OK
    }
    
    Method BroadcastToAll(pSender As Colleague, 
                          pData As %DynamicObject) As %Status [ Private ]
    {
        For i=1:1:..Colleagues.Count() {
            Set colleague = ..Colleagues.GetAt(i)
            If colleague '= pSender {
                Do colleague.Receive("BROADCAST", pData)
            }
        }
        Quit $$$OK
    }
}
```

### Hospital Mediator Example
```objectscript
Class Patterns.Examples.HospitalMediator Extends ConcreteMediator
{
    Method InitiatePatientTransfer(pFromDept As %String, pToDept As %String,
                                    pPatientId As %String, pPriority As %String) As %Status
    {
        Set transferData = {
            "action": "PATIENT_TRANSFER",
            "from": (pFromDept),
            "to": (pToDept),
            "patientId": (pPatientId),
            "priority": (pPriority),
            "timestamp": ($ZDATETIME($ZTIMESTAMP,3))
        }
        
        // Notify receiving department
        Set toDept = ..GetDepartment(pToDept)
        If $ISOBJECT(toDept) {
            Set tSC = toDept.Receive("INCOMING_PATIENT", transferData)
        }
        
        Quit $$$OK
    }
    
    Method BroadcastEmergency(pSendingDept As %String, 
                              pEmergencyType As %String, pDetails As %String) As %Status
    {
        Set emergencyData = {
            "type": (pEmergencyType),
            "department": (pSendingDept),
            "details": (pDetails),
            "timestamp": ($ZDATETIME($ZTIMESTAMP,3)),
            "priority": "CRITICAL"
        }
        
        // Create high-priority event
        Set event = ##class(Event).%New()
        Set event.EventType = "EMERGENCY_BROADCAST"
        Set event.Priority = 100
        Set event.Payload = emergencyData
        
        // Broadcast to all departments
        Quit ..BroadcastToAll("", emergencyData)
    }
}
```

### Department Colleague Example
```objectscript
Class Patterns.Examples.EmergencyDepartment Extends Colleague
{
    Property DepartmentName As %String [ InitialExpression = "EMERGENCY" ];
    Property PatientQueue As %ListOfDataTypes;
    
    Method Receive(pEvent As %String, pData As %DynamicObject) As %Status
    {
        If pEvent = "INCOMING_PATIENT" {
            Write !, "Emergency Dept received patient transfer:"
            Write !, "  Patient: "_pData.patientId
            Write !, "  From: "_pData.from
            Write !, "  Priority: "_pData.priority
            // Process patient admission
            Do ..AdmitPatient(pData.patientId, pData.priority)
        } ElseIf pEvent = "LAB_RESULTS" {
            Write !, "Emergency Dept received lab results:"
            Write !, "  Patient: "_pData.patientId
            Write !, "  Results: "_pData.results
            // Process lab results
            Do ..UpdatePatientChart(pData.patientId, pData.results)
        }
        Quit $$$OK
    }
    
    Method RequestLabTest(pPatientId As %String, pTests As %ListOfDataTypes) As %Status
    {
        Set labRequest = {
            "patientId": (pPatientId),
            "tests": (pTests),
            "requestingDept": (..DepartmentName),
            "priority": "STAT"
        }
        Quit ..Send("LAB_REQUEST", labRequest)
    }
}
```

## Known Uses
The Mediator pattern appears in various systems:

### 1. GUI Frameworks
Dialog boxes use mediators to coordinate widgets. The dialog acts as a mediator between buttons, text fields, and list boxes.

### 2. Air Traffic Control
The control tower acts as a mediator, coordinating communication between aircraft rather than having planes communicate directly.

### 3. Chat Room Systems
The chat server mediates between clients, routing messages appropriately without clients knowing about each other.

### 4. Enterprise Service Bus (ESB)
In service-oriented architectures, the ESB acts as a mediator between services, handling routing, transformation, and orchestration.

### 5. MVC Frameworks
The Controller in MVC acts as a mediator between the Model and View components.

## Related Patterns

### Facade vs Mediator
- **Facade** provides a simplified interface to a subsystem but doesn't add functionality
- **Mediator** adds functionality and intelligence to coordinate colleagues

### Observer vs Mediator
- **Observer** enables broadcast communication through loose coupling
- **Mediator** can use Observer for colleague-mediator communication

### Command vs Mediator
- **Command** encapsulates a request as an object
- **Mediator** can use Commands to implement colleague requests

### Chain of Responsibility vs Mediator
- **Chain of Responsibility** passes requests along a chain until handled
- **Mediator** routes requests to the appropriate handler directly

## Implementation Checklist

### Essential Features
- [x] Abstract mediator interface definition
- [x] Colleague base class with mediator reference
- [x] Concrete mediator implementation
- [x] Colleague registration/deregistration mechanism
- [x] Message routing logic
- [x] Broadcast communication support
- [x] Targeted communication support

### ObjectScript-Specific Features
- [x] Use of %DynamicObject for flexible message payloads
- [x] MultiDimensional properties for colleague registry (without datatype)
- [x] Proper handling of %Status returns
- [x] Abstract method implementation with return values
- [x] Try/Catch block restrictions handled correctly

### Communication Patterns
- [x] Synchronous messaging
- [x] Event-based communication
- [x] Priority-based message handling
- [x] Message filtering and transformation
- [x] Colleague discovery mechanism
- [x] Dynamic colleague registration

### Healthcare-Specific Features
- [x] Department coordination implementation
- [x] Patient transfer workflows
- [x] Lab test request routing
- [x] Emergency broadcast system
- [x] Consultation request handling
- [x] Priority levels (Routine, Urgent, Emergency, Critical)
- [x] Audit trail for communications

### Performance Considerations
- [x] Efficient colleague lookup
- [x] Message queue management
- [x] Lazy colleague initialization
- [x] Colleague active/inactive states
- [x] Memory cleanup on deregistration

## Scalability Considerations

### Design for Growth
1. **Modular Communication Protocols**: Define clear interfaces for adding new message types
2. **Plugin Architecture**: Allow new colleague types to be added without modifying the mediator
3. **Hierarchical Mediators**: Use mediator hierarchies for large systems
4. **Load Balancing**: Distribute load across multiple mediator instances when needed

### Performance Optimization
1. **Message Queuing**: Implement asynchronous message queues for high-throughput scenarios
2. **Caching**: Cache frequently accessed colleague references
3. **Batch Processing**: Process multiple messages in batches when possible
4. **Circuit Breakers**: Implement circuit breakers for failing colleagues

### Monitoring
1. **Message Metrics**: Track message throughput, latency, and failure rates
2. **Colleague Health**: Monitor colleague availability and response times
3. **Queue Depth**: Monitor message queue depths to detect bottlenecks
4. **Audit Logging**: Maintain comprehensive audit logs for compliance

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: Circular Message Routing
**Symptom**: Messages loop infinitely between colleagues
**Solution**: 
- Implement message tracking with unique IDs
- Add loop detection in the mediator
- Use TTL (Time To Live) for messages

#### Issue 2: Memory Leaks
**Symptom**: Memory usage grows over time
**Solution**:
- Ensure proper cleanup in DeregisterColleague
- Clear object references when removing colleagues
- Implement weak references where appropriate

#### Issue 3: Performance Degradation
**Symptom**: System slows down as colleagues increase
**Solution**:
- Use indexed lookups for colleague discovery
- Implement message priorities and filtering
- Consider asynchronous message processing
- Use batch processing for bulk operations

#### Issue 4: Colleague Not Receiving Messages
**Symptom**: Messages sent but not received by target colleague
**Solution**:
- Verify colleague is registered and active
- Check message routing logic
- Ensure Receive method is implemented correctly
- Verify mediator reference is set

#### Issue 5: Try/Catch Block Errors
**Symptom**: QUIT with arguments error in Try/Catch blocks
**Solution**:
- Initialize return variable before Try block
- Use argumentless QUIT in Try/Catch
- Return variable after Try/Catch block

#### Issue 6: MultiDimensional Property Errors
**Symptom**: Compilation errors with MultiDimensional properties
**Solution**:
- Remove datatype specifications from MultiDimensional properties
- Use `Property MyProperty [ MultiDimensional ]` without type

### Debugging Tips
1. **Use Debug Globals**: Set ^ClineDebug for tracing message flow
2. **Log Message Path**: Track message routing through the mediator
3. **Monitor Queue States**: Check message queue depths regularly
4. **Test Isolation**: Test colleagues independently before integration
5. **Use Unit Tests**: Comprehensive test coverage for all communication patterns

## Summary
The Mediator pattern is essential for managing complex interactions between objects while maintaining loose coupling. By centralizing communication logic in a mediator, the pattern simplifies colleague objects and makes the system easier to understand and maintain.

Key takeaways:
- Use when objects have complex but well-defined communication patterns
- Centralizes control logic in the mediator
- Reduces coupling between colleague objects
- Can become complex as interactions grow
- Consider message-based communication for further decoupling
- Useful in UI coordination, workflow systems, and service orchestration

The pattern is particularly valuable in systems where objects need to interact in varied and complex ways, but you want to keep the objects themselves simple and reusable.
