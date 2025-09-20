# Chapter 11: Facade Pattern

## Intent

Provide a unified interface to a set of interfaces in a subsystem. Facade defines a higher-level interface that makes the subsystem easier to use.

## Also Known As

- Wrapper (when applied to a subsystem)

## Motivation

Structuring a system into subsystems helps reduce complexity. A common design goal is to minimize the communication and dependencies between subsystems. One way to achieve this goal is to introduce a facade object that provides a single, simplified interface to the more general facilities of a subsystem.

Consider a healthcare laboratory system. The lab system consists of several complex subsystems:
- **Test Ordering System**: Manages test requisitions, patient validation, and order tracking
- **Test Processing System**: Handles specimen processing, test execution, and quality control
- **Result Formatting System**: Formats results, generates reports, and distributes findings

Without a facade, healthcare applications would need to interact with all these subsystems directly, understanding their complex interactions and dependencies. A facade (SimplifiedLabFacade) provides simple methods like `OrderTest()` and `GetResults()` that hide this complexity.

## Applicability

Use the Facade pattern when:

- You want to provide a simple interface to a complex subsystem. Subsystems often get more complex as they evolve. Most patterns, when applied, result in more and smaller classes. This makes the subsystem more reusable and easier to customize, but it also becomes harder to use for clients that don't need to customize it. A facade can provide a simple default view of the subsystem that is good enough for most clients.

- There are many dependencies between clients and the implementation classes of an abstraction. Introduce a facade to decouple the subsystem from clients and other subsystems, thereby promoting subsystem independence and portability.

- You want to layer your subsystems. Use a facade to define an entry point to each subsystem level. If subsystems are dependent, then you can simplify the dependencies between them by making them communicate with each other solely through their facades.

## Structure

```
     Client
        |
        v
    +--------+
    | Facade |
    +--------+
    /    |    \
   v     v     v
+----+ +----+ +----+
|Sub | |Sub | |Sub |
|sys | |sys | |sys |
|A   | |B   | |C   |
+----+ +----+ +----+
```

## Participants

- **Facade** (SimplifiedLabFacade)
  - Knows which subsystem classes are responsible for a request
  - Delegates client requests to appropriate subsystem objects

- **Subsystem classes** (LabTestOrderer, LabTestProcessor, LabResultFormatter)
  - Implement subsystem functionality
  - Handle work assigned by the Facade object
  - Have no knowledge of the facade; that is, they keep no references to it

## Collaborations

- Clients communicate with the subsystem by sending requests to Facade, which forwards them to the appropriate subsystem object(s). Although the subsystem objects perform the actual work, the facade may have to do work of its own to translate its interface to subsystem interfaces.

- Clients that use the facade don't have to access its subsystem objects directly.

## Consequences

The Facade pattern offers the following benefits:

1. **It shields clients from subsystem components**, thereby reducing the number of objects that clients deal with and making the subsystem easier to use.

2. **It promotes weak coupling** between the subsystem and its clients. Often the components in a subsystem are strongly coupled. Weak coupling lets you vary the components of the subsystem without affecting its clients. Facades help layer a system and the dependencies between objects. They can eliminate complex or circular dependencies.

3. **It doesn't prevent applications from using subsystem classes if they need to**. Thus you can choose between ease of use and generality.

## Implementation

Consider the following implementation issues when using the Facade pattern:

1. **Reducing client-subsystem coupling**. The coupling between clients and the subsystem can be reduced even further by making Facade an abstract class with concrete subclasses for different implementations of a subsystem.

2. **Public versus private subsystem classes**. A subsystem is analogous to a class in that both have interfaces, and both encapsulate something. ObjectScript doesn't have a namespace mechanism to hide subsystem classes, but you can use naming conventions to indicate which classes are part of the subsystem's public interface.

## ObjectScript-Specific Considerations

### Constructor Pattern
```objectscript
Method %OnNew(pConfig As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize subsystems with proper error handling
        Set ..SubsystemA = ##class(SubsystemA).%New()
        If '..SubsystemA {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "Failed to initialize SubsystemA"))
        }
        
        // Wire dependencies between subsystems
        Set tSC = ..SubsystemB.SetSubsystemA(..SubsystemA)
        If $$$ISERR(tSC) Quit
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}
```

### Error Aggregation Pattern
```objectscript
Method SimplifyOperation(pRequest As %String) As %String
{
    Set tResult = ""
    Try {
        // Step through subsystems with error checking
        Set tStep1 = ..SubsystemA.Process(pRequest)
        If tStep1 [ "ERROR" {
            Set tResult = tStep1
            Quit
        }
        
        Set tStep2 = ..SubsystemB.Transform(tStep1)
        If tStep2 [ "ERROR" {
            Set tResult = tStep2
            Quit
        }
        
        Set tResult = ..SubsystemC.Format(tStep2)
    }
    Catch ex {
        Set tResult = "ERROR:FACADE_OPERATION_FAILED:"_ex.DisplayString()
    }
    Quit tResult
}
```

### Direct Access Pattern
```objectscript
// Facade allows direct subsystem access when needed
Method GetSubsystemA() As SubsystemA
{
    Quit ..SubsystemA
}

// Clients can choose simple or detailed interaction
Set facade = ##class(Facade).%New()
// Simple way
Set result = facade.SimplifyOperation("data")
// Direct access for advanced users
Set subsystem = facade.GetSubsystemA()
Set detailedResult = subsystem.ComplexOperation2("data", options)
```

## Sample Code

### Basic Facade Implementation

```objectscript
/// Gang of Four Facade Pattern Implementation
Class Patterns.GoF.Structural.Facade Extends %RegisteredObject
{
    Property SubsystemA As SubsystemA;
    Property SubsystemB As SubsystemB;
    Property SubsystemC As SubsystemC;
    Property Configuration As %DynamicObject;
    Property OperationCount As %Integer [ InitialExpression = 0 ];
    
    Method %OnNew(pConfig As %DynamicObject = "") As %Status
    {
        Set tSC = $$$OK
        Try {
            // Initialize configuration
            If $ISOBJECT(pConfig) {
                Set ..Configuration = pConfig
            } Else {
                Set ..Configuration = {}
                Set ..Configuration.mode = "STANDARD"
                Set ..Configuration.format = "JSON"
                Set ..Configuration.validation = 1
            }
            
            // Initialize subsystems
            Set ..SubsystemA = ##class(SubsystemA).%New(..Configuration.mode)
            Set ..SubsystemB = ##class(SubsystemB).%New(..SubsystemA)
            Set ..SubsystemC = ##class(SubsystemC).%New(..Configuration.format)
            
            // Wire dependencies
            Set tSC = ..SubsystemB.SetSubsystemA(..SubsystemA)
            If $$$ISERR(tSC) Quit
            
            Set tSC = ..SubsystemC.SetSubsystems(..SubsystemA, ..SubsystemB)
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    /// Simplified operation hiding subsystem complexity
    Method SimplifyOperation(pRequest As %String) As %String
    {
        Set tResult = ""
        Set ..OperationCount = ..OperationCount + 1
        
        Try {
            // Validate if configured
            If ..Configuration.validation {
                If pRequest = "" {
                    Set tResult = "ERROR:EMPTY_REQUEST"
                    Quit
                }
            }
            
            // Process through subsystems
            Set tStep1 = ..SubsystemA.ComplexOperation1(pRequest)
            If tStep1 [ "ERROR" Quit
            
            Set tStep2 = ..SubsystemB.ProcessData(tStep1)
            If tStep2 [ "ERROR" Quit
            
            Set tResult = ..SubsystemC.FormatOutput(tStep2)
        }
        Catch ex {
            Set tResult = "ERROR:FACADE_OPERATION_FAILED"
        }
        
        Quit tResult
    }
}
```

### Healthcare Lab System Facade

```objectscript
/// Simplified Lab System Facade
Class Patterns.Examples.SimplifiedLabFacade Extends %RegisteredObject
{
    Property TestOrderer As LabTestOrderer;
    Property TestProcessor As LabTestProcessor;
    Property ResultFormatter As LabResultFormatter;
    Property OrderTracker [ MultiDimensional ];
    
    /// Simple method to order a lab test - hides all complexity
    Method OrderTest(pPatientId As %String, 
                     pTestCode As %String, 
                     pPriority As %String = "ROUTINE") As %String
    {
        Set tResult = ""
        
        Try {
            // Complex workflow reduced to simple steps
            Set tOrderInfo = ..TestOrderer.CreateTestOrder(
                pPatientId, pTestCode, pPriority)
            If tOrderInfo [ "ERROR" {
                Set tResult = "FAILED:"_$PIECE(tOrderInfo, ":", 2, *)
                Quit
            }
            
            Set tProcessResult = ..TestProcessor.ProcessTestOrder(tOrderInfo)
            If tProcessResult [ "ERROR" {
                Set tResult = "FAILED:"_$PIECE(tProcessResult, ":", 2, *)
                Quit
            }
            
            // Track for later retrieval
            Set tOrderId = $PIECE($PIECE(tOrderInfo, "ORDER:", 2), "|", 1)
            Set ..OrderTracker(tOrderId, "patientId") = pPatientId
            Set ..OrderTracker(tOrderId, "testCode") = pTestCode
            Set ..OrderTracker(tOrderId, "status") = "PROCESSING"
            
            Set tResult = "SUCCESS:"_tOrderId
        }
        Catch ex {
            Set tResult = "FAILED:SYSTEM_ERROR"
        }
        
        Quit tResult
    }
    
    /// Simple method to get results
    Method GetResults(pOrderId As %String, 
                     pFormat As %String = "") As %String
    {
        Set tResults = ""
        
        Try {
            // Check if order exists
            If '$DATA(..OrderTracker(pOrderId)) {
                Set tResults = "ERROR:ORDER_NOT_FOUND"
                Quit
            }
            
            // Get specimen ID
            Set tSpecimenId = ..OrderTracker(pOrderId, "specimenId")
            
            // Get and format results
            Set tRawResults = ..TestProcessor.GetTestResults(tSpecimenId)
            Set tResults = ..ResultFormatter.FormatLabResults(
                tRawResults, pFormat)
        }
        Catch ex {
            Set tResults = "ERROR:RETRIEVAL_FAILED"
        }
        
        Quit tResults
    }
    
    /// Demonstration of complexity without facade
    ClassMethod DemonstrateWithoutFacade(
        pPatientId As %String, 
        pTestCode As %String) As %String
    {
        // This shows what clients would need to do without the facade
        // 11+ complex steps reduced to 1 simple method call
        
        // Step 1: Create orderer
        // Step 2: Validate patient
        // Step 3: Create order
        // Step 4: Create processor
        // Step 5: Set dependencies
        // Step 6: Process order
        // Step 7: Extract specimen
        // Step 8: Process batch if needed
        // Step 9: Get results
        // Step 10: Create formatter
        // Step 11: Format results
        
        // With facade: facade.OrderTest(patientId, testCode)
    }
}
```

## API Design Principles

### 1. Interface Simplification

The facade should provide the simplest possible interface for common use cases:

```objectscript
// Without Facade: Multiple steps, complex coordination
Set orderer = ##class(LabTestOrderer).%New()
Set orderInfo = orderer.CreateTestOrder(patientId, testCode, priority)
Set processor = ##class(LabTestProcessor).%New(orderer)
Do processor.SetTestOrderer(orderer)
Set processResult = processor.ProcessTestOrder(orderInfo)
// ... many more steps ...

// With Facade: Single, intuitive call
Set facade = ##class(SimplifiedLabFacade).%New()
Set result = facade.OrderTest(patientId, testCode)
```

### 2. Principle of Least Knowledge (Law of Demeter)

Clients should only know about the facade, not the subsystems:

```objectscript
// Good: Client only knows about facade
Method UseLabSystem(facade As SimplifiedLabFacade)
{
    Set result = facade.OrderTest("P001", "CBC")
}

// Avoid: Client knows about subsystem structure
Method UseLabSystemBadly(orderer, processor, formatter)
{
    // Client shouldn't need to know about these components
}
```

### 3. Progressive Disclosure

Provide simple methods for common cases, complex methods for advanced needs:

```objectscript
// Level 1: Simplest interface
Method OrderCompleteBloodCount(pPatientId)
{
    Quit ..OrderTest(pPatientId, "CBC", "ROUTINE")
}

// Level 2: More control
Method OrderTest(pPatientId, pTestCode, pPriority)

// Level 3: Full access when needed
Method GetSubsystemA() As SubsystemA
```

### 4. Error Aggregation

Facades should provide meaningful error messages without exposing subsystem details:

```objectscript
// Facade aggregates and simplifies errors
Method HandleErrors(pError As %String) As %String
{
    If pError [ "SUBSYSTEM_A_ERROR_CODE_42" {
        Quit "INVALID_PATIENT_ID"
    }
    If pError [ "SUBSYSTEM_B_TIMEOUT" {
        Quit "SYSTEM_BUSY_TRY_LATER"
    }
    Quit "GENERAL_ERROR"
}
```

### 5. Subsystem Decoupling Benefits

- **Reduced Dependencies**: Clients depend only on the facade
- **Version Independence**: Subsystem changes don't affect clients
- **Testing Simplification**: Mock the facade instead of multiple subsystems
- **Migration Path**: Replace subsystems without changing client code

### 6. When to Use Facades

**Use a Facade when:**
- Subsystems have many interdependent classes
- You want to provide a simple interface to complex functionality
- You need to decouple clients from subsystem implementations
- You're creating a higher-level interface for a specific use case

**Don't use a Facade when:**
- The subsystem is already simple
- Clients need full access to subsystem functionality
- You're just renaming methods without simplification

### 7. Facade Method Design Guidelines

```objectscript
/// Good facade method: Clear purpose, simple parameters, meaningful return
Method OrderTest(pPatientId As %String, 
                pTestCode As %String, 
                pPriority As %String = "ROUTINE") As %String
{
    // Hides: validation, ordering, processing, tracking
    // Returns: Simple success/failure with order ID
}

/// Avoid: Exposing subsystem complexity in facade interface
Method ProcessTestWithOptions(pOrderer, pProcessor, 
                             pFormatter, pOptions...) As %Complex
{
    // This defeats the purpose of having a facade
}
```

### 8. API Surface Area Best Practices

- **Minimize Methods**: Provide the fewest methods that cover all use cases
- **Consistent Naming**: Use domain language, not technical terms
- **Default Values**: Supply sensible defaults for optional parameters
- **Method Grouping**: Group related operations logically
- **Version Stability**: Keep facade interface stable even as subsystems evolve

## Known Uses

- **Compiler Systems**: Facades provide simple interfaces to complex compilation subsystems
- **Database Access Layers**: Hide complex SQL and connection management
- **Web Service Clients**: Simplify complex SOAP/REST API interactions
- **Graphics Libraries**: Provide simple drawing methods hiding complex rendering pipelines
- **Healthcare Integration Engines**: Simplify complex HL7/FHIR message processing

## Related Patterns

- **Abstract Factory**: Can be used with Facade to provide an interface for creating subsystem objects in a subsystem-independent way
- **Mediator**: Similar to Facade in that it abstracts functionality of existing classes. However, Mediator's purpose is to abstract arbitrary communication between colleague objects, whereas Facade merely abstracts the interface to subsystem objects to make them easier to use
- **Singleton**: Facade objects are often Singletons because only one Facade object is required
- **Adapter**: Whereas Facade defines a new interface, Adapter reuses an old interface. Adapter makes two existing interfaces work together as opposed to defining an entirely new one
- **Decorator**: Both can be used to add functionality, but Decorator adds responsibilities to objects without changing their interface, while Facade provides a simplified interface

## Summary

The Facade pattern is essential for managing complexity in large systems. By providing a simplified interface to complex subsystems, it makes systems easier to use and understand. In ObjectScript applications, facades are particularly valuable for:

- Simplifying access to complex business logic
- Creating domain-specific interfaces
- Reducing coupling between system layers
- Providing migration paths for legacy code

The key to a successful facade is finding the right balance between simplification and flexibility, ensuring that common cases are easy while still allowing advanced users to access full functionality when needed.
