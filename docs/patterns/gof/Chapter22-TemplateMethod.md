# Chapter 22: Template Method Pattern

## Intent
Define the skeleton of an algorithm in an operation, deferring some steps to subclasses. Template Method lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure.

## Also Known As
- Don't call us, we'll call you (Hollywood Principle)

## Motivation
Consider a framework for applications that process documents. The framework provides an abstract `Application` class that defines the skeleton of the document processing algorithm. The algorithm consists of opening a document, reading its content, processing the data, and saving the results. However, the specific implementations of these steps vary depending on the document type (PDF, Word, Excel, etc.).

In our healthcare context, we implement a report generation system where different types of medical reports (Patient Summary, Lab Results, Billing Statement, Discharge Report) follow the same general workflow but differ in their specific content gathering and processing steps.

## Applicability
Use the Template Method pattern when:
- You want to implement the invariant parts of an algorithm once and leave it up to subclasses to implement the behavior that can vary
- Common behavior among subclasses should be factored and localized in a common class to avoid code duplication
- You want to control subclass extensions. You can define a template method that calls "hook" operations at specific points, thereby permitting extensions only at those points

## Structure
```
                  ┌─────────────────────────┐
                  │   AbstractClass         │
                  ├─────────────────────────┤
                  │ + TemplateMethod()      │ ◄─── [ Final ]
                  │ + PrimitiveOperation1() │ ◄─── Abstract
                  │ + PrimitiveOperation2() │ ◄─── Abstract
                  │ + ConcreteOperation()   │
                  │ + Hook()                │ ◄─── Optional Override
                  └─────────────────────────┘
                              △
                              │
                  ┌───────────┴───────────┐
                  │                       │
      ┌───────────────────┐   ┌───────────────────┐
      │  ConcreteClassA   │   │  ConcreteClassB   │
      ├───────────────────┤   ├───────────────────┤
      │ + PrimitiveOp1()  │   │ + PrimitiveOp1()  │
      │ + PrimitiveOp2()  │   │ + PrimitiveOp2()  │
      │ + Hook()          │   │ + Hook()          │
      └───────────────────┘   └───────────────────┘
```

## Participants
- **AbstractClass** (TemplateMethod)
  - Defines abstract primitive operations that concrete subclasses define to implement steps of an algorithm
  - Implements a template method defining the skeleton of an algorithm
  - The template method calls primitive operations as well as operations defined in AbstractClass or those of other objects

- **ConcreteClass** (PatientSummaryReport, LabResultsReport)
  - Implements the primitive operations to carry out subclass-specific steps of the algorithm
  - May override hook methods to extend functionality

## Collaborations
- ConcreteClass relies on AbstractClass to implement the invariant steps of the algorithm
- AbstractClass calls primitive operations and hook methods at the appropriate times
- The template method follows the "Hollywood Principle": Don't call us, we'll call you

## Implementation in ObjectScript

### Core Template Method Pattern
```objectscript
/// Abstract Template Method base class
Class Patterns.GoF.Behavioral.TemplateMethod Extends %RegisteredObject [ Abstract ]
{
    /// Template method - defines algorithm skeleton [ Final ] prevents override
    Method Execute() As %Status [ Final ]
    {
        Set tSC = $$$OK
        
        Try {
            // Step 1: Initialize (hook method - optional override)
            Do ..Initialize()
            
            // Step 2: Primitive operation 1 (must be implemented)
            Set tSC = ..PrimitiveOperation1()
            If $$$ISERR(tSC) Quit
            
            // Step 3: Concrete operation (provided by base)
            Do ..ConcreteOperation()
            
            // Step 4: Primitive operation 2 (must be implemented)
            Set tSC = ..PrimitiveOperation2()
            If $$$ISERR(tSC) Quit
            
            // Step 5: Hook for optional operations
            If ..Hook() {
                Do ..OptionalOperation()
            }
            
            // Step 6: Finalize (hook method - optional override)
            Do ..Finalize()
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Abstract primitive operations - subclasses must implement
    Method PrimitiveOperation1() As %Status [ Abstract ]
    {
        Quit $$$OK
    }
    
    Method PrimitiveOperation2() As %Status [ Abstract ]
    {
        Quit $$$OK
    }
    
    /// Concrete operation - shared by all subclasses
    Method ConcreteOperation() [ Private ]
    {
        // Common functionality
    }
    
    /// Hook methods - optional override points
    Method Initialize() { }
    Method Finalize() { }
    Method Hook() As %Boolean { Quit 0 }
    Method OptionalOperation() { }
}
```

### Healthcare Report Generator Example
```objectscript
/// Healthcare Report Generator using Template Method
Class Patterns.Examples.ReportGenerator Extends TemplateMethod
{
    Property PatientInfo As %String [ MultiDimensional ];
    Property ReportContent As %String [ MultiDimensional ];
    Property OutputFormat As %String;
    
    /// Generate report using template method
    Method GenerateReport(pFormat As %String = "Text") As %String
    {
        Set ..OutputFormat = pFormat
        Set tSC = ..Execute()
        
        If $$$ISOK(tSC) {
            Quit ..%FormatReport()
        } Else {
            Quit "Error: " _ $SYSTEM.Status.GetErrorText(tSC)
        }
    }
    
    /// Map primitive operations to domain-specific methods
    Method PrimitiveOperation1() As %Status
    {
        Quit ..GatherReportData()
    }
    
    Method PrimitiveOperation2() As %Status
    {
        Quit ..ProcessReportContent()
    }
    
    /// Abstract methods for subclasses
    Method GatherReportData() As %Status [ Abstract ]
    {
        Quit $$$OK
    }
    
    Method ProcessReportContent() As %Status [ Abstract ]
    {
        Quit $$$OK
    }
}

/// Concrete implementation - Patient Summary Report
Class Patterns.Examples.PatientSummaryReport Extends ReportGenerator
{
    Method GatherReportData() As %Status
    {
        // Gather demographics, diagnoses, medications, allergies
        Set ..ReportContent("Body", "Demographics", "Age") = "45 years"
        Set ..ReportContent("Body", "Diagnoses", "Primary") = "Type 2 Diabetes"
        Set ..ReportContent("Body", "Medications", "Med1") = "Metformin 500mg"
        Quit $$$OK
    }
    
    Method ProcessReportContent() As %Status
    {
        // Add summary statistics and care team info
        Set ..ReportContent("Body", "Summary", "Total Diagnoses") = "3"
        Set ..ReportContent("Body", "Care Team", "PCP") = "Dr. Smith"
        Quit $$$OK
    }
    
    Method Hook() As %Boolean
    {
        // Include optional sections
        Quit 1
    }
}
```

## ObjectScript-Specific Considerations

### 1. Method Finality
ObjectScript uses the `[ Final ]` keyword to prevent method override:
```objectscript
Method Execute() As %Status [ Final ]
{
    // This method cannot be overridden in subclasses
}
```

### 2. Abstract Methods
In ObjectScript, abstract methods must have a body that returns an appropriate value:
```objectscript
Method AbstractMethod() As %Status [ Abstract ]
{
    Quit $$$OK  // Required even for abstract methods
}
```

### 3. MultiDimensional Properties
For complex data structures, use MultiDimensional properties:
```objectscript
Property ReportContent As %String [ MultiDimensional ];
```

### 4. Error Handling in Try/Catch
Avoid argumented QUIT within Try/Catch blocks:
```objectscript
Method MyMethod() As %String
{
    Set result = ""
    Try {
        Set result = "value"
        Quit  // Argumentless QUIT
    } Catch ex {
        Quit  // Argumentless QUIT
    }
    Quit result  // Return after Try/Catch
}
```

## Consequences

### Benefits
- **Promotes code reuse**: Common algorithm structure is implemented once
- **Enforces algorithm structure**: Subclasses cannot change the algorithm's skeleton
- **Provides controlled extension points**: Hook methods allow controlled customization
- **Follows DRY principle**: Eliminates duplicate code across similar classes
- **Hollywood Principle**: High-level components control when and how low-level components are called

### Trade-offs
- **Increased number of classes**: Each variation requires a new subclass
- **Limited flexibility**: The algorithm structure is fixed
- **Debugging complexity**: Control flow jumps between parent and child classes
- **Documentation overhead**: The sequence of calls must be well-documented

## Known Uses
- **IRIS Productions**: Business Services and Operations use template methods for message processing
- **%CSP.Page**: OnPreHTTP, OnPage methods follow template pattern
- **%Persistent**: %OnNew, %OnOpen are hooks in the persistence template
- **Report Generators**: Medical report systems with common workflow
- **ETL Processes**: Extract-Transform-Load operations with customizable steps

## Related Patterns
- **Factory Method**: Often used within Template Methods to create objects
- **Strategy**: Defines a family of algorithms that can be interchanged, while Template Method defines an algorithm's structure
- **Hook Method**: A degenerate form of Template Method with only one abstract step

## Implementation Guidelines

### Best Practices
1. **Minimize primitive operations**: Too many abstract methods make the pattern harder to use
2. **Use meaningful names**: Clearly indicate which methods are hooks vs. required implementations
3. **Document the algorithm**: Clearly explain the sequence and purpose of each step
4. **Consider using Final**: Prevent the template method from being overridden
5. **Provide default implementations**: For optional hook methods

### Common Pitfalls
1. **Over-engineering**: Don't use Template Method for simple algorithms
2. **Too many hooks**: Excessive customization points complicate the design
3. **Unclear contracts**: Failing to document when hooks are called
4. **Deep inheritance**: Avoid multiple levels of template methods

## Sample Use Cases

### Healthcare Report Generation
```objectscript
// Generate various report types using same workflow
Set patientReport = ##class(PatientSummaryReport).%New("12345")
Set summary = patientReport.GenerateReport("HTML")

Set labReport = ##class(LabResultsReport).%New("12345") 
Set results = labReport.GenerateReport("PDF")

Set billReport = ##class(BillingStatementReport).%New("12345")
Set statement = billReport.GenerateReport("Text")
```

### Document Processing Pipeline
```objectscript
Class DocumentProcessor Extends TemplateMethod
{
    Method ProcessDocument(pFilePath As %String) As %Status [ Final ]
    {
        Do ..ValidateFile(pFilePath)
        Set content = ..ReadContent(pFilePath)
        Set processed = ..TransformContent(content)
        Do ..SaveResults(processed)
        Quit $$$OK
    }
}
```

## Summary
The Template Method pattern is a fundamental design pattern that defines the skeleton of an algorithm while allowing subclasses to provide specific implementations for certain steps. In ObjectScript, the pattern is particularly useful for healthcare workflows, report generation, and business process automation where a common structure exists but specific details vary by implementation. The pattern promotes code reuse, enforces consistency, and provides controlled customization points through hook methods.
