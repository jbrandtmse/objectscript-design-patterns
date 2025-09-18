# Chapter 06: The Prototype Pattern

## What is the Prototype Pattern?
Think about how a photocopy machine works. You place an original document on the glass, press a button, and out comes an exact copy. You can make as many copies as you want, and each one can be modified independently - maybe you'll highlight different parts or write notes on each copy. The Prototype pattern works the same way in software - it creates new objects by copying existing ones, giving you a quick way to produce similar objects without rebuilding them from scratch.

## Intent
The Prototype pattern specifies the kinds of objects to create using a prototypical instance, and creates new objects by copying this prototype. It's particularly useful when creating an object is expensive or complex, and you need many similar instances with slight variations.

**Implementation Location:** `src/Patterns/GoF/Creational/`

## When Should You Use It? (Applicability)
- When creating an object is expensive (database lookups, complex calculations)
- When you need many similar objects with only small differences
- When the exact types of objects to create are determined at runtime
- When you want to avoid building complex factory hierarchies
- **Healthcare Examples:**
  - Cloning patient admission templates for different departments
  - Creating variations of standard treatment protocols
  - Duplicating lab test order sets with modifications
  - Generating multiple similar insurance claim forms
  - Copying medication administration templates

## How It Works (Structure)
```
     Prototype
         ^
         |
    +---------+
    |         |
ConcretePrototype1  ConcretePrototype2
    |         |
  Clone()   Clone()
    |         |
    v         v
  New Copy  New Copy

  PrototypeRegistry
      |
  [Manages prototypes]
      |
  Create(key) → Clone
```

### Step-by-Step Code Walkthrough:
1. **Prototype (Abstract Class):** Declares the cloning interface
2. **ConcretePrototype:** Implements the Clone() method
3. **PrototypeRegistry:** Manages a collection of prototypes
4. **Client:** Creates new objects by cloning prototypes

```objectscript
// 1. Register a prototype
Set registry = ##class(PrototypeRegistry).%New()
Set template = ##class(EmergencyPatientRecord).%New()
Do registry.Register("EMERGENCY", template)

// 2. Clone when needed
Set newPatient = registry.Create("EMERGENCY")
Set newPatient.PatientID = "P123456"

// 3. Or use direct cloning
Set anotherPatient = newPatient.Clone()
```

## What Happens When You Use It (Consequences)

### The Good Parts ✅
- **Fast object creation:** Cloning is often faster than creating from scratch
- **Runtime flexibility:** Add and remove prototypes at runtime
- **Reduced initialization code:** Complex setup happens once in the prototype
- **Natural variations:** Easy to create families of related objects
- **ObjectScript advantages:**
  - Built-in `%ConstructClone()` for shallow copying
  - Serialization support for deep copying
  - Native handling of collections and streams

### The Challenging Parts ⚠️
- **Deep vs. Shallow copying:** Must decide how to handle nested objects
- **Circular references:** Deep cloning can get tricky with object cycles
- **Clone independence:** Ensuring changes don't affect other clones
- **Memory considerations:** Many clones can consume significant memory
- **Persistent objects:** Special handling needed for database-backed objects

## Real Example: Patient Record Templates

Our healthcare implementation demonstrates cloning patient admission templates:

```objectscript
// Standard Patient Admission
Set standardTemplate = ##class(StandardPatientRecord).%New()
// Creates a template with default tests: CBC, BMP, Urinalysis
Set patient1 = standardTemplate.CustomizeForPatient(
    "P001", "Dr. Smith", "BlueCross")

// Emergency Admission - Different Template  
Set emergencyTemplate = ##class(EmergencyPatientRecord).%New()
// Includes STAT tests and triage-based priority adjustment
Set emergency = emergencyTemplate.CustomizeForEmergency(
    "E001", "Red", "Chest pain")
// Priority automatically set to 1 for Red triage category

// Pediatric Admission - Special Considerations
Set pediatricTemplate = ##class(PediatricPatientRecord).%New()
Set child = pediatricTemplate.CustomizeForChild(
    "P002", 5, 20, "Jane Doe")
// Automatically calculates weight-based medication dosing:
// - Acetaminophen: 300mg (15mg/kg × 20kg)
// - Ibuprofen: 200mg (10mg/kg × 20kg)
// - Maintenance fluids: 1500ml/day

// Using Registry for Template Management
Set registry = ##class(PrototypeRegistry).%New()
Do registry.Register("STANDARD", standardTemplate)
Do registry.Register("EMERGENCY", emergencyTemplate)
Do registry.Register("PEDIATRIC", pediatricTemplate)

// Quick creation from registry
Set newEmergency = registry.Create("EMERGENCY")
Set newEmergency.PatientID = "E002"

// Check registered templates
Write "Registered templates: "_registry.ListKeys(), !
Write "Total count: "_registry.GetCount(), !
```

## ObjectScript-Specific Features

### PrototypeRegistry Advanced Operations
```objectscript
// Check if a prototype is registered
If registry.IsRegistered("EMERGENCY") {
    Write "Emergency template available", !
}

// Create deep clones when needed
Set deepClone = registry.CreateDeepClone("PEDIATRIC")
// Deep clone has independent collections and nested objects

// Remove a template from registry
Do registry.Unregister("OLD_TEMPLATE")

// Clear all templates
Do registry.Clear()

// Get count of registered templates
Set count = registry.GetCount()
Write "Number of templates: "_count, !
```

### Shallow Cloning with %ConstructClone
```objectscript
Method Clone() As Prototype
{
    // Use ObjectScript's built-in shallow clone
    Set tClone = ..%ConstructClone()
    
    // Call post-clone initialization
    If $IsObject(tClone) {
        Do tClone.InitializeAfterClone()
    }
    
    Quit tClone
}
```

### Deep Cloning with Serialization
```objectscript
Method DeepClone() As Prototype
{
    Set tClone = ""
    Try {
        // Serialize this object to a stream
        Set tStream = ##class(%Stream.GlobalCharacter).%New()
        Set tSC = ..%SerializeObject(tStream)
        If $$$ISERR(tSC) Quit
        
        // Reset stream position
        Do tStream.Rewind()
        
        // Create new instance and deserialize
        Set tClone = ##class(ConcretePrototype1).%New()
        Set tSC = tClone.%DeserializeObject(tStream)
        If $$$ISERR(tSC) {
            Set tClone = ""
            Quit
        }
        
        // Deep clone complex properties if they exist
        If $IsObject(..ComplexProperty) {
            Set tClone.ComplexProperty = ##class(ComplexObject).%New()
            Do tClone.ComplexProperty.CopyFrom(..ComplexProperty)
        }
        
        // Initialize after deep clone
        Do tClone.InitializeAfterClone()
    }
    Catch ex {
        Set tClone = ""
    }
    
    Quit tClone
}
```

## Testing the Pattern

**Test Class:** `src/Patterns/Test/Unit/GoF/Creational/PrototypeTest.cls`

Key test scenarios covered:
- Shallow cloning with shared references
- Deep cloning with independent objects
- PrototypeRegistry operations
- Healthcare template cloning
- Collection and nested object handling
- Error handling for null prototypes
- Performance comparison (shallow vs. deep)
- Clone independence verification

## Summary

The Prototype pattern is your solution when you need to:
1. Create objects by copying existing instances
2. Avoid expensive initialization repeatedly
3. Generate families of similar objects
4. Provide runtime flexibility in object creation

In healthcare systems, it's invaluable for template-based workflows where standard forms, protocols, and records need slight customization for each use.

## Try It Yourself

1. **Create a new template:** Build a `SurgicalProcedureTemplate` with pre-operative checklists
2. **Implement lazy cloning:** Modify deep clone to only copy changed properties
3. **Add validation:** Ensure required fields are set after cloning
4. **Build a template library:** Create a comprehensive set of medical form templates
5. **Performance test:** Compare creation time of 1000 objects via new vs. clone
6. **Handle persistence:** Extend the pattern to work with %Persistent classes
7. **Version templates:** Add versioning to track template evolution
