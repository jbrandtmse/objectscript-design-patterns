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

Our healthcare implementation demonstrates adapting HL7 v2 messages to FHIR resources. Note that HL7ToFHIRAdapter is a standalone adapter that doesn't extend Target, showing a more practical implementation pattern:

```objectscript
// Create sample HL7 ADT message
Set hl7Message = ##class(HL7Message).%New()
Do hl7Message.AddSegment("MSH|^~\&|LAB|HOSPITAL|EMR|CLINIC|20240904120000||ADT^A01|MSG001|P|2.5")
Do hl7Message.AddSegment("PID|1||12345678||DOE^JOHN^M||19800515|M||")

// Create adapter with the HL7 message
Set adapter = ##class(HL7ToFHIRAdapter).%New(hl7Message)

// Convert the entire message
Set tSC = adapter.Convert()
If $$$ISOK(tSC) {
    // Display conversion results
    Do adapter.DisplayResults()
    
    // Get FHIR Bundle with all converted resources
    Set fhirBundle = adapter.GetFHIRBundle()
    Write "Total Resources: "_fhirBundle.total, !
    
    // Access individual resources
    For i = 1:1:adapter.FHIRResources.Count() {
        Set resource = adapter.FHIRResources.GetAt(i)
        Write "Resource "_i_": "_resource.GetSummary(), !
    }
}

// Example with ORU (lab results) message
Set hl7ORU = ##class(HL7Message).%New()
Do hl7ORU.AddSegment("MSH|^~\&|LAB|HOSPITAL|EMR|CLINIC|20240904120000||ORU^R01|MSG002|P|2.5")
Do hl7ORU.AddSegment("PID|1||12345678||DOE^JOHN^M||19800515|M||")
Do hl7ORU.AddSegment("OBX|1|NM|GLU^Glucose|1|120|mg/dL|70-105|H||")

Set adapter = ##class(HL7ToFHIRAdapter).%New(hl7ORU)
Set tSC = adapter.Convert()
```

### HL7ToFHIRAdapter Implementation Details
```objectscript
Class Patterns.Examples.HL7ToFHIRAdapter Extends %RegisteredObject
{
    Property HL7Message As HL7Message;
    Property FHIRResources As list Of FHIRResource;
    Property ConversionErrors As list Of %String;
    Property ConversionStats As %DynamicObject;
    
    Method %OnNew(pHL7Message As HL7Message = "") As %Status
    {
        If $ISOBJECT(pHL7Message) {
            Set ..HL7Message = pHL7Message
        }
        
        // Initialize conversion statistics
        Set ..ConversionStats = {}
        Set ..ConversionStats.total_segments = 0
        Set ..ConversionStats.converted_resources = 0
        Set ..ConversionStats.errors = 0
        
        Quit $$$OK
    }
    
    /// Main conversion method
    Method Convert(pHL7Message As HL7Message = "") As %Status
    {
        // Use provided message or stored message
        If $ISOBJECT(pHL7Message) {
            Set ..HL7Message = pHL7Message
        }
        
        // Parse and route based on message type
        Set tMSH = ..HL7Message.GetSegment("MSH", 1)
        Set tMessageType = $PIECE($PIECE(tMSH, "|", 9), "^", 1)
        
        If tMessageType = "ADT" {
            Set tSC = ..ConvertADTMessage()
        } ElseIf tMessageType = "ORU" {
            Set tSC = ..ConvertORUMessage()
        }
        
        // Update statistics
        Set ..ConversionStats.converted_resources = ..FHIRResources.Count()
        
        Quit tSC
    }
}
```

## ObjectScript-Specific Features

### Class Adapter Pattern (Composition-Based)
```objectscript
// ObjectScript doesn't support multiple inheritance, so ClassAdapter
// uses composition by maintaining an internal Adaptee instance
Class Patterns.GoF.Structural.ClassAdapter Extends Target
{
    Property InternalAdaptee As Adaptee [ Private ];
    
    Method %OnNew() As %Status
    {
        Set tSC = $$$OK
        Try {
            Set ..InternalAdaptee = ##class(Adaptee).%New()
            If '$IsObject(..InternalAdaptee) {
                Set tSC = $$$ERROR($$$GeneralError, "Failed to create Adaptee instance")
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    Method Request() As %String
    {
        Set result = ""
        Try {
            If $IsObject(..InternalAdaptee) {
                Set adapteeResponse = ..InternalAdaptee.SpecificRequest()
                // Parse and adapt the response
                If adapteeResponse [ "SpecificRequest:" {
                    Set specificPart = $Piece(adapteeResponse, "SpecificRequest:", 2)
                    Set result = "Adapted: " _ $ZSTRIP(specificPart, "<>W")
                }
                Else {
                    Set result = "Adapted: " _ adapteeResponse
                }
            }
            Else {
                Set result = "Error: Adaptee not initialized"
            }
        }
        Catch ex {
            Set result = "Error: " _ ex.DisplayString()
        }
        Quit result
    }
}
```

### Object Adapter Pattern (Composition Approach)
```objectscript
Class Patterns.GoF.Structural.ObjectAdapter Extends Target
{
    Property Adaptee As Adaptee;
    
    Method %OnNew(pAdaptee As Adaptee = "") As %Status
    {
        Set tSC = $$$OK
        Try {
            // If no adaptee provided, create a default one
            If pAdaptee = "" {
                Set ..Adaptee = ##class(Adaptee).%New()
            }
            ElseIf $IsObject(pAdaptee) {
                Set ..Adaptee = pAdaptee
            }
            Else {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid Adaptee parameter")
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    Method Request() As %String
    {
        Set result = ""
        Try {
            If $IsObject(..Adaptee) {
                Set adapteeClass = ..Adaptee.%ClassName(1)
                
                // Handle LegacyAdaptee differently
                If adapteeClass = "Patterns.GoF.Structural.LegacyAdaptee" {
                    Set adapteeResponse = ..Adaptee.OldMethod()
                    If adapteeResponse [ "LegacyOperation:" {
                        Set legacyPart = $Piece(adapteeResponse, "LegacyOperation:", 2)
                        Set result = "Object Adapted: " _ $ZSTRIP(legacyPart, "<>W")
                    }
                    Else {
                        Set result = "Object Adapted: " _ adapteeResponse
                    }
                }
                Else {
                    // Standard Adaptee with SpecificRequest method
                    Set adapteeResponse = ..Adaptee.SpecificRequest()
                    If adapteeResponse [ "SpecificRequest:" {
                        Set specificPart = $Piece(adapteeResponse, "SpecificRequest:", 2)
                        Set result = "Object Adapted: " _ $ZSTRIP(specificPart, "<>W")
                    }
                    Else {
                        Set result = "Object Adapted: " _ adapteeResponse
                    }
                }
            }
            Else {
                Set result = "Error: No adaptee"
            }
        }
        Catch ex {
            Set result = "Error: " _ ex.DisplayString()
        }
        Quit result
    }
    
    Method SetAdaptee(pNewAdaptee As Adaptee) As %Status
    {
        Set tSC = $$$OK
        Try {
            If $IsObject(pNewAdaptee) {
                Set ..Adaptee = pNewAdaptee
            }
            Else {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid Adaptee object")
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
}
```

### Legacy Code Wrapper with LegacyAdaptee
```objectscript
Class Patterns.GoF.Structural.LegacyCodeAdapter Extends Target
{
    Property LegacyAdaptee As Patterns.GoF.Structural.LegacyAdaptee;
    Property SessionID As %String;
    
    Method %OnNew(pAdaptee As LegacyAdaptee = "") As %Status
    {
        Set tSC = $$$OK
        Try {
            // Use provided adaptee or create new one
            If $IsObject(pAdaptee) {
                Set ..LegacyAdaptee = pAdaptee
            }
            Else {
                Set ..LegacyAdaptee = ##class(LegacyAdaptee).%New()
            }
            
            // Get the session ID from the legacy adaptee
            Set ..SessionID = ..LegacyAdaptee.SessionID
            If ..SessionID = "" {
                Set tSC = $$$ERROR($$$GeneralError, "Failed to get legacy session ID")
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    Method Request() As %String
    {
        Set result = ""
        Try {
            If $IsObject(..LegacyAdaptee) {
                // Call ProcessLegacyRequest with session ID
                Set legacyResponse = ..LegacyAdaptee.ProcessLegacyRequest(..SessionID)
                
                // Parse the legacy pipe-delimited format
                // Format: "LEGACY|{count}|{date}|{processed}"
                Set responseType = $Piece(legacyResponse, "|", 1)
                Set countPart = $Piece(legacyResponse, "|", 2)
                Set datePart = $Piece(legacyResponse, "|", 3)
                Set processedPart = $Piece(legacyResponse, "|", 4)
                
                // Convert to modern format
                If responseType = "LEGACY" {
                    Set result = "Modern Adapted: Count=" _ countPart _ 
                                " Date=" _ datePart _ 
                                " Data=" _ processedPart
                }
                Else {
                    Set result = "Modern Adapted: " _ legacyResponse
                }
            }
            Else {
                Set result = "Error: Legacy system not initialized"
            }
        }
        Catch ex {
            Set result = "Error: " _ ex.DisplayString()
        }
        Quit result
    }
}

/// LegacyAdaptee simulates legacy code with global variables
Class Patterns.GoF.Structural.LegacyAdaptee Extends %RegisteredObject
{
    Property SessionID As %String;
    
    Method %OnNew() As %Status
    {
        Set ..SessionID = $ZCONVERT($SYSTEM.Util.CreateGUID(), "L")
        Do ..InitializeLegacySystem()
        Quit $$$OK
    }
    
    Method InitializeLegacySystem()
    {
        // Simulate legacy initialization using globals
        Set ^LegacyAdaptee("SYSTEM", "STATUS") = "INITIALIZED"
        Set ^LegacyAdaptee("SESSION", ..SessionID, "CREATED") = $HOROLOG
        Set ^LegacyAdaptee("SESSION", ..SessionID, "COUNTER") = 0
    }
    
    Method ProcessLegacyRequest(pInput As %String) As %String
    {
        Set tCounter = $INCREMENT(^LegacyAdaptee("SESSION", ..SessionID, "COUNTER"))
        
        // Store request in global
        Set ^LegacyAdaptee("REQUESTS", ..SessionID, tCounter, "INPUT") = pInput
        Set ^LegacyAdaptee("REQUESTS", ..SessionID, tCounter, "TIMESTAMP") = $HOROLOG
        
        // Process and build legacy-style response
        Set tProcessed = ..LegacyTransform(pInput)
        Set tResponse = "LEGACY|"_tCounter_"|"_$PIECE($HOROLOG, ",", 1)_"|"_tProcessed
        
        Quit tResponse
    }
    
    Method OldMethod() As %String
    {
        Set tCounter = $INCREMENT(^LegacyAdaptee("SESSION", ..SessionID, "COUNTER"))
        Quit "LegacyOperation: Processing via legacy system (Count="_tCounter_")"
    }
    
    Method %OnClose() As %Status
    {
        // Clean up session-specific globals
        Kill ^LegacyAdaptee("SESSION", ..SessionID)
        Kill ^LegacyAdaptee("REQUESTS", ..SessionID)
        Quit $$$OK
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
