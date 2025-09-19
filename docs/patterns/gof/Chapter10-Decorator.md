# Chapter 10: Decorator Pattern

## Intent
Attach additional responsibilities to an object dynamically. Decorators provide a flexible alternative to subclassing for extending functionality. The pattern allows behavior to be added to individual objects, either statically or dynamically, without affecting the behavior of other objects from the same class.

## Also Known As
- Wrapper

## Motivation
Sometimes we want to add responsibilities to individual objects, not to an entire class. A graphical user interface toolkit, for example, should let you add properties like borders or behaviors like scrolling to any user interface component.

One way to add responsibilities is with inheritance. Inheriting a border from another class puts a border around every subclass instance. This is inflexible, however, because the choice of border is made statically. A client can't control how and when to decorate the component with a border.

A more flexible approach is to enclose the component in another object that adds the border. The enclosing object is called a decorator. The decorator forwards requests to the component and may perform additional actions before or after forwarding. Transparency is key—the decorator conforms to the interface of the component it decorates so that its presence is invisible to the component's clients.

Consider a healthcare system where patient records need various enhancements depending on context. A basic patient record might need encryption for security, audit logging for compliance, privacy filters for HIPAA, and alert mechanisms for critical values. Rather than creating separate classes for each combination (EncryptedPatientRecord, AuditedPatientRecord, EncryptedAndAuditedPatientRecord, etc.), we can use decorators to add these features dynamically. A patient record can be wrapped with an EncryptionDecorator, which itself can be wrapped with an AuditDecorator, creating a flexible chain of responsibilities.

## Applicability
Use the Decorator pattern when:
- You want to add responsibilities to individual objects dynamically and transparently, without affecting other objects
- You want to add responsibilities that can be withdrawn
- Extension by subclassing is impractical due to the explosion of subclasses to support every combination
- A class definition may be hidden or otherwise unavailable for subclassing

## Structure
```
        Component
        +-----------------+
        |                 |
        |Operation()      |
        |GetDescription() |
        |GetCost()        |
        +-----------------+
              ^
              |
     +--------+--------+
     |                 |
ConcreteComponent  Decorator
+----------------+ +------------------+
|                | |component         |
|Operation()     | |Operation()       |
|GetDescription()| |GetDescription()  |
|GetCost()       | |GetCost()         |
+----------------+ +------------------+
                            ^
                            |
                   +--------+--------+
                   |                 |
            ConcreteDecoratorA  ConcreteDecoratorB
            +----------------+  +----------------+
            |AddedState      |  |                |
            |Operation()     |  |Operation()     |
            |GetDescription()|  |GetDescription()|
            |GetCost()       |  |GetCost()       |
            |AddedBehavior() |  |AddedBehavior() |
            +----------------+  +----------------+
```

## Participants
- **Component** (IComponent)
  - Defines the interface for objects that can have responsibilities added to them dynamically
  
- **ConcreteComponent** (ConcreteComponent, BasicPatientRecord)
  - Defines an object to which additional responsibilities can be attached
  
- **Decorator** (Decorator)
  - Maintains a reference to a Component object and defines an interface that conforms to Component's interface
  
- **ConcreteDecorator** (ConcreteDecoratorA, ConcreteDecoratorB, EncryptionDecorator, AuditDecorator)
  - Adds responsibilities to the component

## Collaborations
- Decorator forwards requests to its Component object. It may optionally perform additional operations before and after forwarding the request

## Consequences
The Decorator pattern has the following benefits and liabilities:

### Benefits
1. **More flexibility than static inheritance** - Decorator pattern provides a more flexible way to add responsibilities to objects than can be had with static (multiple) inheritance
2. **Avoids feature-laden classes high up in the hierarchy** - Instead of trying to support all foreseeable features in a complex, customizable class, you can define a simple class and add functionality incrementally with Decorator objects
3. **Pay-as-you-go approach** - You can define new Decorators independently from the classes of objects they extend, even for unforeseen extensions
4. **Decorator and its component aren't identical** - A decorator acts as a transparent enclosure, but from an object identity point of view, a decorated component is not identical to the component itself

### Liabilities
1. **Lots of little objects** - A design that uses Decorator often results in systems composed of lots of little objects that all look alike
2. **Debugging complexity** - Can be harder to debug since the behavior is built up through composition

## Implementation
Consider the following implementation issues:

### 1. Interface Conformance
A decorator object's interface must conform to the interface of the component it decorates. ConcreteDecorator classes must therefore inherit from a common class.

### 2. Omitting the Abstract Decorator Class
When you only need to add one responsibility, there's no need to define an abstract Decorator class. You can merge Decorator's responsibility for forwarding requests to the component into the ConcreteDecorator.

### 3. Keeping Component Classes Lightweight
To ensure a conforming interface, components and decorators must descend from a common Component class. It's important to keep this common class lightweight; it should focus on defining an interface, not on storing data.

### 4. Changing the Skin of an Object versus Changing Its Guts
Think of a decorator as a skin over an object that changes its behavior. An alternative is to change the object's guts. The Strategy pattern is a good example of a pattern for changing the guts.

### 5. ObjectScript-Specific Considerations
- Use ##super() to call parent implementation in decorated methods
- Implement proper %OnNew() constructor to accept wrapped component
- Use %RegisteredObject for automatic memory management
- Consider %Status return values for operations that can fail
- Be careful with object references to avoid memory leaks

## Sample Code
Here's the ObjectScript implementation of the Decorator pattern:

### Core Pattern Classes
```objectscript
/// Component interface for Decorator pattern
Class Patterns.GoF.Structural.IComponent Extends %RegisteredObject [ Abstract ]
{
    /// Perform the component's operation
    Method Operation() As %String [ Abstract ]
    {
        Quit ""
    }
    
    /// Get the component's description
    Method GetDescription() As %String [ Abstract ]
    {
        Quit ""
    }
    
    /// Get the component's cost
    Method GetCost() As %Numeric [ Abstract ]
    {
        Quit 0
    }
}

/// Concrete component with base implementation
Class Patterns.GoF.Structural.ConcreteComponent Extends IComponent
{
    Property Name As %String;
    Property Data As %String;
    Property BaseCost As %Numeric [ InitialExpression = 10 ];
    
    Method Operation() As %String
    {
        Quit "ConcreteComponent: Processing " _ ..Data
    }
    
    Method GetDescription() As %String
    {
        Quit "ConcreteComponent[" _ ..Name _ "]"
    }
    
    Method GetCost() As %Numeric
    {
        Quit ..BaseCost
    }
}

/// Abstract decorator class
Class Patterns.GoF.Structural.Decorator Extends IComponent [ Abstract ]
{
    Property Component As IComponent;
    
    /// Constructor accepting component to wrap
    Method %OnNew(pComponent As IComponent) As %Status
    {
        Set ..Component = pComponent
        Quit $$$OK
    }
    
    /// Default operation delegates to wrapped component
    Method Operation() As %String
    {
        If $IsObject(..Component) {
            Quit ..Component.Operation()
        }
        Quit ""
    }
    
    /// Default description delegates to wrapped component
    Method GetDescription() As %String
    {
        If $IsObject(..Component) {
            Quit ..Component.GetDescription()
        }
        Quit ""
    }
    
    /// Default cost delegates to wrapped component
    Method GetCost() As %Numeric
    {
        If $IsObject(..Component) {
            Quit ..Component.GetCost()
        }
        Quit 0
    }
}

/// Concrete decorator adding pre/post processing
Class Patterns.GoF.Structural.ConcreteDecoratorA Extends Decorator
{
    Property EnhancementLevel As %String [ InitialExpression = "Standard" ];
    Property OperationCount As %Integer [ InitialExpression = 0 ];
    
    Method Operation() As %String
    {
        // Pre-processing
        Set ..OperationCount = ..OperationCount + 1
        Set tResult = "DecoratorA[" _ ..EnhancementLevel _ "] Pre-processing -> "
        
        // Delegate to wrapped component
        Set tResult = tResult _ ##super()
        
        // Post-processing
        Set tResult = tResult _ " -> DecoratorA Post-processing"
        
        Quit tResult
    }
    
    Method GetDescription() As %String
    {
        Quit "DecoratorA(" _ ##super() _ ")"
    }
    
    Method GetCost() As %Numeric
    {
        Quit ##super() + 5
    }
}
```

### Healthcare Example
```objectscript
/// Patient record component interface
Class Patterns.Examples.PatientRecordComponent Extends %RegisteredObject [ Abstract ]
{
    /// Get patient data
    Method GetData() As %String [ Abstract ]
    {
        Quit ""
    }
    
    /// Save patient data
    Method SaveData(pData As %String) As %Status [ Abstract ]
    {
        Quit $$$OK
    }
    
    /// Check if HIPAA compliant
    Method IsHIPAACompliant() As %Boolean [ Abstract ]
    {
        Quit 0
    }
    
    /// Get security level
    Method GetSecurityLevel() As %String [ Abstract ]
    {
        Quit "None"
    }
}

/// Basic patient record implementation
Class Patterns.Examples.BasicPatientRecord Extends PatientRecordComponent
{
    Property PatientID As %String;
    Property Demographics As %String;
    Property Vitals As %String;
    Property Medications As %String;
    
    Method GetData() As %String
    {
        Set tData = "Patient:" _ ..PatientID
        Set tData = tData _ "|Demographics:" _ ..Demographics
        Set tData = tData _ "|Vitals:" _ ..Vitals
        Set tData = tData _ "|Medications:" _ ..Medications
        Quit tData
    }
    
    Method SaveData(pData As %String) As %Status
    {
        // Basic save without encryption or audit
        Write "BasicRecord: Saving data - ", pData, !
        Quit $$$OK
    }
    
    Method IsHIPAACompliant() As %Boolean
    {
        // Basic record alone is not HIPAA compliant
        Quit 0
    }
    
    Method GetSecurityLevel() As %String
    {
        Quit "Basic"
    }
}

/// Encryption decorator for patient records
Class Patterns.Examples.EncryptionDecorator Extends PatientRecordComponent
{
    Property WrappedRecord As PatientRecordComponent;
    Property EncryptionKey As %String;
    Property EncryptionAlgorithm As %String [ InitialExpression = "AES-256" ];
    
    Method %OnNew(pRecord As PatientRecordComponent) As %Status
    {
        Set ..WrappedRecord = pRecord
        Set ..EncryptionKey = $System.Util.CreateGUID()
        Quit $$$OK
    }
    
    Method GetData() As %String
    {
        Set tData = ..WrappedRecord.GetData()
        // Decrypt data
        Set tData = "[DECRYPTED with " _ ..EncryptionAlgorithm _ "] " _ tData
        Quit tData
    }
    
    Method SaveData(pData As %String) As %Status
    {
        // Encrypt before saving
        Set tEncrypted = "[ENCRYPTED with " _ ..EncryptionAlgorithm _ "] " _ pData
        Quit ..WrappedRecord.SaveData(tEncrypted)
    }
    
    Method IsHIPAACompliant() As %Boolean
    {
        // Encryption makes it HIPAA compliant
        Quit 1
    }
    
    Method GetSecurityLevel() As %String
    {
        Quit "Encrypted(" _ ..WrappedRecord.GetSecurityLevel() _ ")"
    }
}

/// Audit decorator for patient records
Class Patterns.Examples.AuditDecorator Extends PatientRecordComponent
{
    Property WrappedRecord As PatientRecordComponent;
    Property AuditLog As %ListOfDataTypes;
    Property AccessCount As %Integer [ InitialExpression = 0 ];
    
    Method %OnNew(pRecord As PatientRecordComponent) As %Status
    {
        Set ..WrappedRecord = pRecord
        Set ..AuditLog = ##class(%ListOfDataTypes).%New()
        Quit $$$OK
    }
    
    Method GetData() As %String
    {
        Set ..AccessCount = ..AccessCount + 1
        Set tTimestamp = $ZDateTime($Horolog, 3)
        Do ..AuditLog.Insert("READ|" _ tTimestamp _ "|User:" _ $Username)
        Quit ..WrappedRecord.GetData()
    }
    
    Method SaveData(pData As %String) As %Status
    {
        Set tTimestamp = $ZDateTime($Horolog, 3)
        Do ..AuditLog.Insert("WRITE|" _ tTimestamp _ "|User:" _ $Username)
        Quit ..WrappedRecord.SaveData(pData)
    }
    
    Method IsHIPAACompliant() As %Boolean
    {
        Quit ..WrappedRecord.IsHIPAACompliant()
    }
    
    Method GetSecurityLevel() As %String
    {
        Quit "Audited(" _ ..WrappedRecord.GetSecurityLevel() _ ")"
    }
}
```

### Decorator Chain Builder
```objectscript
/// Builder for creating decorator chains
Class Patterns.GoF.Structural.DecoratorChainBuilder Extends %RegisteredObject
{
    Property BaseComponent As IComponent [ Private ];
    Property CurrentComponent As IComponent [ Private ];
    
    /// Set the base component
    Method WithBase(pComponent As IComponent) As DecoratorChainBuilder
    {
        Set ..BaseComponent = pComponent
        Set ..CurrentComponent = pComponent
        Quit $this
    }
    
    /// Add DecoratorA to the chain
    Method AddDecoratorA(pEnhancementLevel As %String = "Standard") As DecoratorChainBuilder
    {
        If '$IsObject(..CurrentComponent) {
            Write "Error: No base component set", !
            Quit $this
        }
        
        Set tDecorator = ##class(ConcreteDecoratorA).%New(..CurrentComponent)
        Set tDecorator.EnhancementLevel = pEnhancementLevel
        Set ..CurrentComponent = tDecorator
        Quit $this
    }
    
    /// Add DecoratorB to the chain
    Method AddDecoratorB(pMode As %String = "Balanced") As DecoratorChainBuilder
    {
        If '$IsObject(..CurrentComponent) {
            Write "Error: No base component set", !
            Quit $this
        }
        
        Set tDecorator = ##class(ConcreteDecoratorB).%New(..CurrentComponent)
        Set tDecorator.PerformanceMode = pMode
        Set ..CurrentComponent = tDecorator
        Quit $this
    }
    
    /// Build and return the decorated component
    Method Build() As IComponent
    {
        Quit ..CurrentComponent
    }
}
```

### Usage Example
```objectscript
// Basic usage
Set component = ##class(ConcreteComponent).%New()
Set component.Name = "Base"
Set component.Data = "Original Data"

// Add single decorator
Set decorated = ##class(ConcreteDecoratorA).%New(component)
Write decorated.Operation(), !
Write "Cost: ", decorated.GetCost(), !

// Chain multiple decorators
Set builder = ##class(DecoratorChainBuilder).%New()
Set chain = builder.WithBase(component)
                  .AddDecoratorA("Premium")
                  .AddDecoratorB("Fast")
                  .Build()

Write chain.Operation(), !
Write "Description: ", chain.GetDescription(), !
Write "Total Cost: ", chain.GetCost(), !

// Healthcare example
Set patientRecord = ##class(BasicPatientRecord).%New()
Set patientRecord.PatientID = "12345"
Set patientRecord.Demographics = "John Doe, Age 45"
Set patientRecord.Vitals = "BP: 120/80, HR: 72"

// Add encryption and audit
Set encrypted = ##class(EncryptionDecorator).%New(patientRecord)
Set audited = ##class(AuditDecorator).%New(encrypted)

Write "HIPAA Compliant: ", audited.IsHIPAACompliant(), !
Write "Security Level: ", audited.GetSecurityLevel(), !

Do audited.SaveData("Updated vital signs")
Write "Data: ", audited.GetData(), !
```

## Method Overriding in ObjectScript
ObjectScript provides several mechanisms for method overriding in the decorator pattern:

### Using ##super()
The ##super() syntax calls the parent class implementation:
```objectscript
Method Operation() As %String
{
    // Add behavior before
    Set tResult = "Before: "
    
    // Call parent implementation
    Set tResult = tResult _ ##super()
    
    // Add behavior after
    Set tResult = tResult _ " :After"
    
    Quit tResult
}
```

### Method Keywords
- **[ Abstract ]** - Method must be overridden in subclasses
- **[ Final ]** - Method cannot be overridden in subclasses
- **[ Private ]** - Method not visible to subclasses
- **[ ClassMethod ]** - Static method (class-level)

### Best Practices for Overriding
1. Always check for null objects before delegating
2. Use ##super() for calling parent implementations
3. Maintain method signatures when overriding
4. Document override behavior clearly
5. Consider performance impact of deep decorator chains

## Known Uses
- I/O Streams in many programming languages use decorators for buffering, compression, encryption
- GUI toolkits use decorators for adding scrollbars, borders, and other embellishments
- Middleware systems use decorator chains for request/response processing
- Healthcare systems use decorators for security, audit, and compliance features
- Web frameworks use decorators for authentication, caching, and logging
- Database systems use decorators for connection pooling and transaction management

## Related Patterns
- **Adapter** changes an object's interface, Decorator enhances its responsibilities
- **Composite** can be viewed as a decorator with only one component but manages child components
- **Strategy** changes the guts of an object, Decorator changes its skin
- **Proxy** provides a placeholder or surrogate, while Decorator adds responsibilities

## Healthcare Context
In healthcare systems, the Decorator pattern is particularly valuable for:
- **Security Layers**: Adding encryption, digital signatures, and access control to patient data
- **Audit Trail**: Wrapping operations with comprehensive logging for regulatory compliance
- **Privacy Filters**: Dynamically applying HIPAA-compliant data masking based on user roles
- **Alert Mechanisms**: Adding critical value monitoring and notification to lab results
- **Data Transformation**: Converting between different healthcare standards (HL7, FHIR, DICOM)
- **Performance Monitoring**: Adding metrics collection without modifying core medical logic
- **Caching Layers**: Improving response times for frequently accessed patient data
- **Validation Layers**: Ensuring data integrity and clinical decision support rules

The pattern's ability to combine these features dynamically is crucial in healthcare, where different contexts require different combinations of security, privacy, and functionality. For example:
- A research context might need anonymization but not encryption
- A clinical context needs both encryption and audit logging
- An emergency context might bypass certain privacy filters but increase audit detail

## Performance Considerations
When implementing the Decorator pattern in ObjectScript:

### Memory Impact
- Each decorator adds an object to the chain
- Deep chains can impact memory usage
- Consider object pooling for frequently used decorators

### Performance Optimization
```objectscript
/// Cached decorator for expensive operations
Class CachedDecorator Extends Decorator
{
    Property Cache As %String [ MultiDimensional ];
    Property CacheTimeout As %Integer [ InitialExpression = 300 ];
    
    Method Operation() As %String
    {
        Set tKey = $ZDateTime($H, 3)
        
        // Check cache
        If $Data(..Cache(tKey)) {
            Quit ..Cache(tKey)
        }
        
        // Compute and cache
        Set tResult = ##super()
        Set ..Cache(tKey) = tResult
        
        // Clear old cache entries
        Set tCutoff = $H - (..CacheTimeout / 86400)
        Set tOldKey = ""
        For {
            Set tOldKey = $Order(..Cache(tOldKey))
            Quit:tOldKey=""
            If tOldKey < tCutoff {
                Kill ..Cache(tOldKey)
            }
        }
        
        Quit tResult
    }
}
```

### Chain Depth Guidelines
- Keep decorator chains to 3-5 levels for optimal performance
- Consider composite decorators for common combinations
- Profile deep chains to identify bottlenecks
- Use lazy initialization where appropriate

This pattern provides a powerful mechanism for extending object functionality while maintaining clean separation of concerns and flexible runtime configuration.
