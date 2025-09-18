# Chapter 05: The Builder Pattern

## What is the Builder Pattern?
Imagine you're at a sandwich shop. The person behind the counter doesn't just throw all the ingredients at you - they build your sandwich step by step, asking what bread you want, what meat, what cheese, what vegetables. They're following a process to construct something complex piece by piece. That's exactly what the Builder pattern does in software - it constructs complex objects step by step, allowing you to create different variations using the same building process.

## Intent
The Builder pattern separates the construction of a complex object from its representation, allowing you to create different types of objects using the same construction process. It's especially useful when you need to create objects with many optional parts or when the creation process involves multiple steps that need to be done in a specific order.

**Implementation Location:** `src/Patterns/GoF/Creational/`

## When Should You Use It? (Applicability)
- When creating an object involves many steps that need to be performed in a specific sequence
- When you want to create different representations of the same data
- When the construction process must allow different representations of the object being built
- When you need to isolate complex construction code from the business logic
- **Healthcare Examples:**
  - Building complex medical reports (lab reports, radiology reports, discharge summaries)
  - Constructing patient care plans with multiple components
  - Creating medical device configurations with various parameters
  - Assembling clinical trial protocols with different phases

## How It Works (Structure)
```
    Director                Builder
        |                      ^
        |                      |
        v                      |
    construct() -----> ConcreteBuilder1
                              |
                       ConcreteBuilder2
                              |
                           Product
```

### Step-by-Step Code Walkthrough:
1. **Builder (Abstract Class):** Defines the interface for creating parts of a Product
2. **ConcreteBuilder:** Implements the Builder interface to construct and assemble parts
3. **Director:** Constructs an object using the Builder interface
4. **Product:** The complex object being built

```objectscript
// 1. Create a builder
Set builder = ##class(LabReportBuilder).%New()

// 2. Director uses builder to construct product
Set director = ##class(Director).%New()
Set report = director.Construct(builder, "full")
// Constructs with BuildPartA(), BuildPartB(), BuildPartC()

// 3. Or use custom construction steps
Set stepList = $LISTBUILD("A", "C")  // Skip part B
Set customReport = director.ConstructWithSteps(builder, stepList)
```

## What Happens When You Use It (Consequences)

### The Good Parts ✅
- **Isolation of complex construction:** The construction code is separate from the representation
- **Fine control over construction:** You can control each step of the building process
- **Reusable construction process:** The same construction process can create different representations
- **Fluent interface support:** Methods can chain together for readable code:
  ```objectscript
  Set report = builder.SetPatientInfo("John Doe", "12345")
                      .BuildFindings()
                      .BuildInterpretation()
                      .AddSignature("Dr. Smith")
                      .GetResult()
  ```

### The Challenging Parts ⚠️
- **More classes to manage:** You need separate builder classes for each product type
- **Not ideal for simple objects:** Overkill for objects that don't require complex construction
- **Mutable builders:** Builders maintain state during construction, which can be tricky in concurrent scenarios
- **Must know the construction sequence:** Clients need to understand the proper order of method calls

## Real Example: Building Medical Reports

Our healthcare implementation demonstrates building different types of medical reports:

```objectscript
// Building a Complete Blood Count Lab Report
Set labBuilder = ##class(LabReportBuilder).%New()
// BuildCBCReport creates a complete report with interpretation
Set labReport = labBuilder.BuildCBCReport(
    "RPT001",                  // Report ID
    "P12345",                  // Patient ID  
    "John Doe",                // Patient Name
    7.5,                       // WBC (K/uL)
    4.8,                       // RBC (M/uL)
    14.2,                      // Hemoglobin (g/dL)
    42.5,                      // Hematocrit (%)
    250)                       // Platelets (K/uL)
// Returns completed report with status "Final" and priority 3 (Routine)

// Building a Chest X-Ray Report
Set radioBuilder = ##class(RadiologyReportBuilder).%New()
Set xrayReport = radioBuilder.BuildChestXRayReport(
    "RPT002",                  // Report ID
    "P12345",                  // Patient ID
    "Jane Smith",              // Patient Name
    "Rule out pneumonia",      // Indication
    "Clear",                   // Lungs finding
    "Normal size",             // Heart finding
    "No acute abnormality")    // Bones finding
// Returns report with impression and metadata (StudyType: XR, BodyPart: CHEST)

// Building a Medical Discharge Summary
Set dischargeBuilder = ##class(DischargeReportBuilder).%New()
Set dischargeSummary = dischargeBuilder.BuildMedicalDischarge(
    "RPT003",                  // Report ID
    "P12345",                  // Patient ID
    "Robert Johnson",          // Patient Name
    "Pneumonia",               // Admission diagnosis
    "Resolved pneumonia",      // Discharge diagnosis
    "Patient responded well to antibiotics")  // Hospital course
// Includes discharge instructions, follow-up appointments, and metadata

// Alternative: Building CT Scan Report with Contrast
Set ctReport = radioBuilder.BuildCTScanReport(
    "RPT004", "P67890", "Alice Brown",
    "ABDOMEN",                 // Body part
    "Abdominal pain",          // Indication
    "No acute findings",       // Findings
    1)                         // Contrast used (Boolean)
// Priority set to 2 (Urgent) for CT scans
```

Each builder handles the complexity of creating its specific report type while maintaining a consistent interface for common operations like adding signatures and setting status.

## Testing the Pattern

**Test Class:** `src/Patterns/Test/Unit/GoF/Creational/BuilderTest.cls`

Key test scenarios covered:
- Basic construction with ConcreteBuilder1 and ConcreteBuilder2
- Fluent interface method chaining
- Director-controlled construction
- Builder reset and reuse
- Healthcare-specific builders (Lab, Radiology, Discharge)
- Error handling and validation
- Complex report building with metadata and attachments

## ObjectScript-Specific Features

### Director Template Options
```objectscript
// The Director supports three built-in templates:
Set director = ##class(Director).%New()

// "minimal" - Only builds PartA (essential components)
Set minimalProduct = director.Construct(builder, "minimal")

// "full" - Builds PartA, PartB, and PartC (complete product)
Set fullProduct = director.Construct(builder, "full")

// "custom" - Builds PartA and PartC (skips PartB)
Set customProduct = director.Construct(builder, "custom")

// Get available templates
Set templates = ##class(Director).GetAvailableTemplates()
// Returns: $LISTBUILD("minimal", "full", "custom")
```

### Builder Abstract Methods
```objectscript
// Every builder must implement these core methods:
Method Reset()                    // Clear builder state
Method BuildPartA()               // Build essential component
Method BuildPartB()               // Build supplementary component  
Method BuildPartC()               // Build optional component
Method GetResult()                // Return constructed product
Method SetProperty(name, value)  // Set property (for fluent interface)
Method Validate()                 // Validate construction state
```

### Healthcare Builder Specializations
```objectscript
// LabReportBuilder specific methods
Method BuildCBCReport(...)           // Complete Blood Count
Method BuildMetabolicPanelReport(...) // Basic Metabolic Panel

// RadiologyReportBuilder specific methods  
Method BuildChestXRayReport(...)     // Chest X-Ray
Method BuildCTScanReport(...)        // CT Scan with contrast option
Method BuildMRIReport(...)           // MRI with gadolinium option

// DischargeReportBuilder specific methods
Method BuildMedicalDischarge(...)    // Medical discharge summary
Method BuildSurgicalDischarge(...)   // Post-surgical discharge
Method BuildICUDischarge(...)        // ICU transfer summary
```

## Summary

The Builder pattern is your go-to solution when you need to:
1. Create complex objects with many optional parts
2. Control the construction process step by step
3. Create different representations using the same building process
4. Keep construction logic separate from business logic

In healthcare systems, it's particularly valuable for creating various types of reports and documents that share common elements but require different specialized content.

## Try It Yourself

1. **Create a new builder:** Implement a `SurgicalReportBuilder` that creates operative reports
2. **Add validation:** Modify a builder to require certain fields before allowing `GetResult()`
3. **Chain builders:** Create a workflow where multiple builders work together to create a complete patient record
4. **Custom director:** Write a director that creates emergency vs. routine reports differently
5. **Builder factory:** Create a factory that returns the appropriate builder based on report type
