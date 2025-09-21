# Chapter 14: Chain of Responsibility Pattern

## Intent
The Chain of Responsibility pattern avoids coupling the sender of a request to its receiver by giving more than one object a chance to handle the request. It chains the receiving objects and passes the request along the chain until an object handles it.

## Also Known As
- CoR
- Chain of Command

## Motivation
Consider a help system for a graphical user interface. The user can obtain help information on any part of the interface by clicking on it. The help that's provided depends on the part of the interface that's selected and its context. In healthcare systems, approval requests often need to go through multiple levels of authority based on the amount, risk level, or type of request. A nurse might approve small medication requests, while larger equipment purchases require department head or administrator approval.

## Applicability
Use the Chain of Responsibility pattern when:
- More than one object may handle a request, and the handler isn't known a priori
- You want to issue a request to one of several objects without specifying the receiver explicitly
- The set of objects that can handle a request should be specified dynamically
- You want to avoid coupling the sender of a request to its receiver

## Structure
```
     Client                     Handler
        |                    /-----------\
        |                   | +HandleRequest() |
        v                   | +SetNext()       |
   ConcreteHandler1         | #NextHandler     |
        |                    \-----------/
        |                         ^  ^
        v                         |  |
   ConcreteHandler2              /    \
        |                       /      \
        |              ConcreteHandler1 ConcreteHandler2
        v                       |              |
   ConcreteHandler3    +HandleRequest() +HandleRequest()
```

## Participants
### Handler (Patterns.GoF.Behavioral.Handler)
- Defines an interface for handling requests
- Implements the successor link to the next handler in the chain
- Provides default request handling behavior

### ConcreteHandler (NurseApprovalHandler, DoctorApprovalHandler, etc.)
- Handles requests it is responsible for
- Can access its successor
- If the ConcreteHandler can handle the request, it does so; otherwise it forwards the request to its successor

### Client
- Initiates the request to a ConcreteHandler object on the chain

## Collaborations
- When a client issues a request, the request propagates along the chain until a ConcreteHandler object takes responsibility for handling it
- Each handler decides either to process the request or to pass it along the chain
- The chain can be configured dynamically, allowing flexible request routing

## Consequences
### Benefits
1. **Reduced coupling** - The pattern frees an object from knowing which other object handles a request
2. **Added flexibility** - You can add or change responsibilities for handling a request by adding to or changing the chain at runtime
3. **Separation of concerns** - Each handler focuses on its specific responsibility

### Liabilities
1. **Receipt isn't guaranteed** - Since a request has no explicit receiver, there's no guarantee it'll be handled
2. **Performance concerns** - Request processing might be slower due to chain traversal
3. **Debugging difficulty** - It can be hard to observe the runtime characteristics and debug

## Implementation in ObjectScript

### Basic Handler Abstract Class
```objectscript
Class Patterns.GoF.Behavioral.Handler Extends %RegisteredObject [ Abstract ]
{
Property HandlerName As %String;
Property NextHandler As Handler;
Property Priority As %Integer [ InitialExpression = 10 ];
Property Enabled As %Boolean [ InitialExpression = 1 ];
Property Configuration As %DynamicObject;

/// Set the next handler in chain
Method SetNext(pHandler As Handler) As %Status
{
    Set ..NextHandler = pHandler
    Quit $$$OK
}

/// Handle request - template method pattern
Method HandleRequest(pRequest As Request) As Response
{
    If '..Enabled {
        Quit ..PassToNext(pRequest)
    }
    
    If ..CanHandle(pRequest) {
        Quit ..Process(pRequest)
    }
    
    Quit ..PassToNext(pRequest)
}

/// Check if this handler can process the request
Method CanHandle(pRequest As Request) As %Boolean [ Abstract ]
{
    Quit 0
}

/// Process the request
Method Process(pRequest As Request) As Response [ Abstract ]
{
    Quit ##class(Response).%New()
}

/// Pass request to next handler
Method PassToNext(pRequest As Request) As Response [ Private ]
{
    If $IsObject(..NextHandler) {
        Quit ..NextHandler.HandleRequest(pRequest)
    }
    Quit ##class(Response).Failure("End of chain reached", "NO_HANDLER")
}
}
```

### Healthcare Approval Example
```objectscript
Class Patterns.Examples.NurseApprovalHandler Extends Patterns.GoF.Behavioral.Handler
{
Parameter MAXAMOUNT = 500;
Parameter MAXRISKLEVEL = 1;

Method %OnNew() As %Status
{
    Set ..HandlerName = "Nurse"
    Set ..Priority = 10
    Quit $$$OK
}

Method CanHandle(pRequest As Request) As %Boolean
{
    If pRequest.%IsA("Patterns.Examples.ApprovalRequest") {
        Set tApproval = pRequest
        If (tApproval.Amount <= ..#MAXAMOUNT) && (tApproval.RiskLevel <= ..#MAXRISKLEVEL) {
            Quit 1
        }
    }
    Quit 0
}

Method Process(pRequest As Request) As Response
{
    Set tApproval = pRequest
    Set tApproval.ApprovalStatus = "Approved"
    Set tApproval.ApprovedBy.Insert(..HandlerName)
    
    Set tResponse = ##class(Response).Success("Request approved by " _ ..HandlerName)
    Set tResponse.HandledBy = ..HandlerName
    Do tResponse.SetMetadata("approvalLevel", "L1")
    Do tResponse.SetMetadata("approvalTime", $ZDateTime($Horolog, 3))
    
    Quit tResponse
}
}
```

### Dynamic Chain Builder
```objectscript
Class Patterns.GoF.Behavioral.ChainBuilder Extends %RegisteredObject
{
Property Handlers As list Of Handler;
Property SortByPriority As %Boolean [ InitialExpression = 1 ];

/// Add handler to builder
Method AddHandler(pHandler As Handler) As %Status
{
    Do ..Handlers.Insert(pHandler)
    Quit $$$OK
}

/// Build the chain
Method Build() As Handler
{
    If ..SortByPriority {
        Do ..SortHandlersByPriority()
    }
    
    Set tFirst = ""
    Set tPrevious = ""
    
    For i=1:1:..Handlers.Count() {
        Set tHandler = ..Handlers.GetAt(i)
        If tFirst = "" Set tFirst = tHandler
        If $IsObject(tPrevious) {
            Do tPrevious.SetNext(tHandler)
        }
        Set tPrevious = tHandler
    }
    
    Quit tFirst
}

/// Build chain from JSON configuration
ClassMethod BuildFromJSON(pConfig As %DynamicObject) As Handler
{
    Set tBuilder = ..%New()
    Set tBuilder.SortByPriority = pConfig.sortByPriority
    
    Set tIter = pConfig.handlers.%GetIterator()
    While tIter.%GetNext(.key, .handlerConfig) {
        Set tClass = pConfig.registry.%Get(handlerConfig.type)
        Set tHandler = $ClassMethod(tClass, "%New")
        Set tHandler.Priority = handlerConfig.priority
        Set tHandler.Enabled = handlerConfig.enabled
        Set tHandler.Configuration = handlerConfig
        Do tBuilder.AddHandler(tHandler)
    }
    
    Quit tBuilder.Build()
}
}
```

## Sample Code

### Setting Up an Approval Chain
```objectscript
// Create handlers
Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
Set tDeptHead = ##class(Patterns.Examples.DepartmentHeadApprovalHandler).%New()
Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()

// Build chain
Do tNurse.SetNext(tDoctor)
Do tDoctor.SetNext(tDeptHead)
Do tDeptHead.SetNext(tAdmin)

// Create request
Set tRequest = ##class(Patterns.Examples.ApprovalRequest).%New("Equipment", 25000, 3)
Set tRequest.Department = "Radiology"
Set tRequest.Reason = "New X-ray machine"

// Process request
Set tResponse = tNurse.HandleRequest(tRequest)
Write "Approved by: " _ tResponse.HandledBy, !
Write "Approval level: " _ tResponse.GetMetadata("approvalLevel"), !
```

### Dynamic Chain Configuration
```objectscript
// Using ChainBuilder
Set tBuilder = ##class(Patterns.GoF.Behavioral.ChainBuilder).%New()

// Register handlers
Do tBuilder.AddHandler(##class(NurseApprovalHandler).%New())
Do tBuilder.AddHandler(##class(DoctorApprovalHandler).%New())
Do tBuilder.AddHandler(##class(AdministratorApprovalHandler).%New())

// Build sorted chain
Set tChain = tBuilder.Build()

// Process multiple requests
For i=1:1:3 {
    Set tAmount = $Random(100000) + 100
    Set tRequest = ##class(ApprovalRequest).CreateTestRequest("Budget", tAmount)
    Set tResponse = tChain.HandleRequest(tRequest)
    Write "Amount: $" _ tAmount _ " -> Handled by: " _ tResponse.HandledBy, !
}
```

## Known Uses
- GUI event handling systems
- Logging frameworks (different log levels)
- Authentication and authorization systems
- Middleware in web frameworks
- Exception handling mechanisms
- Workflow and approval systems

## Related Patterns
- **Composite**: Chain of Responsibility is often applied in conjunction with Composite. A component's parent can act as its successor
- **Command**: Commands can be handled using Chain of Responsibility
- **Decorator**: Both patterns rely on recursive composition, but have different intents
- **Template Method**: Handlers often use Template Method to define the skeleton of request handling

## Implementation Checklist
- [x] Define abstract Handler with successor link
- [x] Implement concrete handlers for each responsibility level
- [x] Create request and response classes for communication
- [x] Implement chain building and configuration
- [x] Add dynamic handler registration
- [x] Include error handling and circuit breaker
- [x] Create healthcare approval example
- [x] Implement handler priorities and sorting
- [x] Add request validation and tracking
- [x] Write comprehensive unit tests

## Advanced Features

### Circuit Breaker Pattern Integration
```objectscript
Class Patterns.GoF.Behavioral.ErrorHandler Extends Handler
{
Property CircuitState As %String [ InitialExpression = "CLOSED" ];
Property FailureCount As %Integer [ InitialExpression = 0 ];
Property FailureThreshold As %Integer [ InitialExpression = 3 ];
Property RecoveryStrategy As %String [ InitialExpression = "RETRY" ];

Method Process(pRequest As Request) As Response
{
    If ..CircuitState = "OPEN" {
        Quit ..HandleCircuitOpen(pRequest)
    }
    
    Try {
        Set tResponse = ..ExecuteRecovery(pRequest)
        Set ..FailureCount = 0
        Set ..CircuitState = "CLOSED"
        Quit tResponse
    } Catch ex {
        Set ..FailureCount = ..FailureCount + 1
        If ..FailureCount >= ..FailureThreshold {
            Set ..CircuitState = "OPEN"
        }
        Quit ##class(Response).Failure(ex.DisplayString(), "CIRCUIT_BREAKER")
    }
}
}
```

### Request Tracking and Audit
```objectscript
Class Patterns.GoF.Behavioral.Request Extends %RegisteredObject
{
Property Type As %String [ Required ];
Property Data As %String;
Property Priority As %Integer [ InitialExpression = 5 ];
Property Context As %DynamicObject;
Property ProcessingHistory As list Of %String;
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDateTime($H,3)} ];

Method AddToHistory(pHandler As %String, pAction As %String)
{
    Do ..ProcessingHistory.Insert($ZDT($H,3) _ "|" _ pHandler _ "|" _ pAction)
}
}
```

## Testing Strategies

### Unit Testing Chain Formation
```objectscript
Method TestChainFormation()
{
    Set tHandler1 = ##class(ConcreteHandler).%New("H1", 10)
    Set tHandler2 = ##class(ConcreteHandler).%New("H2", 20)
    Set tHandler3 = ##class(ConcreteHandler).%New("H3", 30)
    
    Do tHandler1.SetNext(tHandler2)
    Do tHandler2.SetNext(tHandler3)
    
    Do $$$AssertEquals(tHandler1.GetChainLength(), 3)
    Do $$$AssertTrue(tHandler1.ValidateChain())
}
```

### Testing Request Escalation
```objectscript
Method TestEscalation()
{
    Set tChain = ..BuildTestChain()
    Set tRequest = ##class(ApprovalRequest).%New("Budget", 50000, 4)
    Set tResponse = tChain.HandleRequest(tRequest)
    
    Do $$$AssertEquals(tResponse.HandledBy, "Administrator")
    Do $$$AssertTrue(tRequest.ProcessingHistory.Count() > 1)
}
```

## Performance Considerations

1. **Chain Length**: Keep chains reasonably short to avoid performance degradation
2. **Caching**: Consider caching handler decisions for repeated similar requests
3. **Async Processing**: For long-running handlers, consider asynchronous processing
4. **Priority Ordering**: Order handlers by likelihood of handling to minimize traversal

## Conclusion

The Chain of Responsibility pattern provides a flexible way to decouple request senders from receivers, allowing dynamic configuration of request processing chains. In healthcare systems, it's particularly useful for approval workflows, escalation procedures, and multi-level authorization systems. The pattern's strength lies in its ability to add, remove, or reorder handlers without affecting client code, making it ideal for systems with evolving business rules and approval hierarchies.
