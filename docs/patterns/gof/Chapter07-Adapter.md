# Chapter 07: The Adapter Pattern

## What is the Adapter Pattern?
Imagine you're traveling internationally with your laptop. Your charger has a three-pronged plug, but the hotel room only has two-pronged outlets. You don't throw away your charger or rewire the hotel - you use a simple adapter that bridges the incompatibility. The Adapter pattern works exactly the same way in software - it allows classes with incompatible interfaces to work together by wrapping one interface to match what the other expects.

## Intent
The Adapter pattern converts the interface of a class into another interface that clients expect. It lets classes work together that couldn't otherwise because of incompatible interfaces. Think of it as a translator between two systems that speak different languages.

**Implementation Location:** `src/Patterns/GoF/Structural/`

## When Should You Use It? (Applicability)
- When you want to use an existing class but its interface doesn't match what you need
- When you need to create a reusable class that cooperates with unrelated or unforeseen classes
- When you need to use several existing subclasses, but it's impractical to adapt their interface by subclassing each one
- When dealing with legacy code that can't be modified
- **Healthcare Examples:**
  - Converting HL7 v2 messages to FHIR resources
  - Adapting legacy laboratory systems to modern EMR interfaces
  - Integrating third-party medical device data formats
  - Bridging different insurance claim processing systems
  - Converting between different drug database formats

## How It Works (Structure)
```
Class Adapter (Inheritance):
     Target
       ^
       |
   ClassAdapter -----> Adaptee
   (inherits)      (also inherits)
       |
   Request() --> SpecificRequest()

Object Adapter (Composition):
     Target
       ^
       |
   ObjectAdapter
       |
   adaptee: Adaptee -----> Adaptee
       |
   Request() --> adaptee.SpecificRequest()
```

### Step-by-Step Code Walkthrough:
1. **Target:** The domain-specific interface that Client uses
2. **Adaptee:** An existing interface that needs adapting
3. **Adapter:** Adapts the interface of Adaptee to Target interface
4. **Client:** Collaborates with objects conforming to Target interface

```objectscript
// 1. Client expects Target interface
Set client = ##class(MedicalSystem).%New()

// 2. But we have an incompatible Adaptee
Set legacySystem = ##class(LegacyAdaptee).%New()

// 3. Use an Adapter to bridge them
Set adapter = ##class(ObjectAdapter).%New()
Do adapter.SetAdaptee(legacySystem)

// 4. Client can now use the adapted interface
Set result = client.ProcessRequest(adapter)
```

## What Happens When You Use It (Consequences)

### The Good Parts ✅
- **Separation of concerns:** Business logic separated from data conversion code
- **Open/Closed Principle:** Add new adapters without modifying existing code
- **Legacy integration:** Use old code with new systems without modification
- **Multiple adaptations:** Same adaptee can be adapted to different targets
- **ObjectScript advantages:**
  - Method delegation simplifies adapter implementation
  - `%Extends` for single inheritance in class adapters
  - Dynamic typing reduces interface complexity
  - Global access for legacy system integration

### The Challenging Parts ⚠️
- **Code complexity:** Extra layer of indirection
- **Performance overhead:** Additional method calls for each operation
- **Multiple inheritance limitations:** ObjectScript doesn't support true multiple inheritance
- **Debugging difficulty:** More layers to trace through
- **Two-way adaptation:** Complex when both systems need to call each other

## Real Example: HL7 to FHIR Healthcare Adapter

Our healthcare implementation demonstrates adapting HL7 v2 messages to FHIR resources:

```objectscript
// Original HL7 Message (pipe-delimited format)
Set hl7Message = ##class(HL7Message).%New()
Do hl7Message.AddSegment("MSH|^~\&|LAB|HOSPITAL|EMR|CLINIC|20240904120000||ADT^A01|MSG001|P|2.5")
Do hl7Message.AddSegment("PID|1||12345678||DOE^JOHN^M||19800515|M||")

// Create the adapter
Set adapter = ##class(HL7ToFHIRAdapter).%New()

// Convert to FHIR Patient resource
Set fhirPatient = adapter.ConvertPatient(hl7Message)
Write "FHIR Patient ID: "_fhirPatient.Identifier, !
Write "Name: "_fhirPatient.Name, !
Write "Birth Date: "_fhirPatient.BirthDate, !

// Convert lab results to FHIR Observation
Do hl7Message.AddSegment("OBX|1|NM|GLU^Glucose|1|120|mg/dL|70-105|H||")
Set fhirObservation = adapter.ConvertObservation(hl7Message)
Write "Observation Code: "_fhirObservation.Code, !
Write "Value: "_fhirObservation.ValueQuantity, !
```

## ObjectScript-Specific Features

### Class Adapter Pattern (Limited Multiple Inheritance)
```objectscript
Class Patterns.GoF.Structural.ClassAdapter 
    Extends (Target, Adaptee)
{
    Method Request() As %String
    {
        // Delegate to inherited SpecificRequest
        Quit ..SpecificRequest()
    }
}
```

### Object Adapter Pattern (Composition Approach)
```objectscript
Class Patterns.GoF.Structural.ObjectAdapter Extends Target
{
    Property AdapteeInstance As Adaptee;
    
    Method Request() As %String
    {
        If $IsObject(..AdapteeInstance) {
            Quit ..AdapteeInstance.SpecificRequest()
        }
        Quit "No adaptee configured"
    }
    
    Method SetAdaptee(pAdaptee As Adaptee) As %Status
    {
        Set ..AdapteeInstance = pAdaptee
        Quit $$$OK
    }
}
```

### Legacy Code Wrapper
```objectscript
Class Patterns.GoF.Structural.LegacyCodeAdapter Extends Target
{
    Property SessionID As %String;
    
    Method Request() As %String
    {
        // Wrap legacy global-based operations
        Set ^LegacyData(..SessionID, "request") = $H
        
        // Call legacy routine
        Set result = $$ProcessLegacy^OLDCODE(..SessionID)
        
        // Clean up
        Kill ^LegacyData(..SessionID)
        
        Quit result
    }
}
```

## Testing the Pattern

**Test Class:** `src/Patterns/Test/Unit/GoF/Structural/AdapterTest.cls`

Key test scenarios covered:
- Class adapter request delegation
- Object adapter with different adaptee instances
- Null adaptee handling
- Legacy code wrapper functionality
- HL7 to FHIR conversion accuracy
- Multiple adapter chaining
- Performance comparison between adapter types
- Error handling and validation

## Summary

The Adapter pattern is your bridge when you need to:
1. Make incompatible interfaces work together
2. Integrate legacy systems with modern code
3. Use third-party libraries with different interfaces
4. Create reusable classes that work with various systems

In healthcare systems, it's essential for:
- Data format conversions (HL7, FHIR, DICOM)
- Legacy system integration
- Medical device interoperability
- Cross-platform data exchange

## Try It Yourself

1. **Create a DICOM adapter:** Build an adapter for medical imaging data
2. **Implement two-way adaptation:** Create adapters that work in both directions
3. **Add caching:** Optimize repeated conversions with result caching
4. **Build an adapter chain:** Connect multiple adapters for complex transformations
5. **Performance monitoring:** Add metrics to track adapter overhead
6. **Error recovery:** Implement fallback strategies for conversion failures
7. **Create a plugin system:** Use adapters to support multiple data sources dynamically
8. **Implement validation:** Add data validation between conversion steps
