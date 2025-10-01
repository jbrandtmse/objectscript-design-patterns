# Chapter 23: Visitor Pattern

## Intent

Represent an operation to be performed on the elements of an object structure. Visitor lets you define a new operation without changing the classes of the elements on which it operates.

## Also Known As

Double Dispatch

## Motivation

Consider a healthcare system that needs to perform different operations on medical records - auditing for HIPAA compliance, generating billing reports, calculating statistics, or exporting to different formats. Each operation is distinct and may be added frequently, but the medical record structure remains stable.

Without the Visitor pattern, you would need to add methods to each medical record class for every new operation:

```objectscript
Class PatientRecord Extends MedicalRecord
{
    Method GenerateAuditReport() { ... }
    Method CalculateBilling() { ... }
    Method ExportToHL7() { ... }
    Method GenerateStatistics() { ... }
    // More operations added over time...
}
```

This approach violates the Open/Closed Principle and scatters unrelated functionality across medical record classes. The Visitor pattern solves this by separating operations from the object structure.

## Applicability

Use the Visitor pattern when:

- An object structure contains many classes of objects with differing interfaces, and you want to perform operations on these objects that depend on their concrete classes
- Many distinct and unrelated operations need to be performed on objects in an object structure, and you want to avoid "polluting" their classes with these operations
- The classes defining the object structure rarely change, but you often want to define new operations over the structure
- You need to perform operations across a class hierarchy and want to avoid using instanceof or type checking

## Structure

```
                    ┌─────────────────┐
                    │     Client      │
                    └─────────────────┘
                             │
                             ▼
    ┌─────────────────┐              ┌─────────────────┐
    │    Visitor      │◄─────────────┤    Element      │
    │                 │              │                 │
    │ +VisitElementA()│              │ +Accept(Visitor)│
    │ +VisitElementB()│              └─────────────────┘
    └─────────────────┘                       △
             △                                │
             │                                │
    ┌─────────────────┐              ┌─────────────────┐
    │ ConcreteVisitor │              │ ConcreteElement │
    │                 │              │                 │
    │ +VisitElementA()│              │ +Accept(Visitor)│
    │ +VisitElementB()│              │ +Operation()    │
    └─────────────────┘              └─────────────────┘
```

## Participants

- **Visitor** (AuditVisitor, BillingVisitor)
  - Declares a Visit operation for each class of ConcreteElement in the object structure
  - The operation's name and signature identifies the class that sends the Visit request to the visitor

- **ConcreteVisitor** (AuditVisitor, BillingVisitor)
  - Implements each operation declared by Visitor
  - Each operation implements a fragment of the algorithm defined for the corresponding class of object in the structure
  - Provides context for the algorithm and stores its local state

- **Element** (MedicalRecordElement)
  - Defines an Accept operation that takes a visitor as an argument

- **ConcreteElement** (PatientRecord, LabResult, Prescription)
  - Implements an Accept operation that takes a visitor as an argument
  - Typically calls the visitor method that corresponds to its class

- **ObjectStructure** (MedicalRecordCollection)
  - Can enumerate its elements
  - May provide a high-level interface to allow the visitor to visit its elements
  - May either be a composite or a collection such as a list or set

## Collaborations

1. A client that uses the Visitor pattern must create a ConcreteVisitor object and traverse the object structure, visiting each element with the visitor
2. When an element is visited, it calls the Visitor operation that corresponds to its class. The element supplies itself as an argument so the visitor can access its state if necessary
3. The following sequence diagram shows the interactions between a client, an element, and a visitor:

```
Client          ConcreteElement          ConcreteVisitor
  │                    │                       │
  │ Accept(visitor)    │                       │
  ├────────────────────▶                       │
  │                    │ VisitConcreteElement()│
  │                    ├───────────────────────▶
  │                    │                       │
```

## Consequences

The Visitor pattern has the following benefits and liabilities:

### Benefits

1. **Adding new operations is easy**: Simply define a new visitor class
2. **Gathers related operations**: Collects related behavior in a single class
3. **Separates unrelated operations**: Keeps unrelated behavior in separate visitor classes
4. **Visiting across class hierarchies**: Can work on heterogeneous object structures
5. **Accumulating state**: Visitors can accumulate state as they traverse

### Liabilities

1. **Adding new ConcreteElement classes is hard**: Requires updating all visitor interfaces
2. **Breaking encapsulation**: Elements may need to expose internal state to visitors
3. **Circular dependencies**: Visitor and Element hierarchies depend on each other

## Implementation

### ObjectScript Implementation Considerations

1. **Abstract Methods**: In ObjectScript, abstract methods must have a body with a Quit statement:

```objectscript
Method VisitPatientRecord(pElement As PatientRecord) As %Status [ Abstract ]
{
    Quit $$$OK
}
```

2. **Double Dispatch**: Use `$THIS` to pass the element to the visitor:

```objectscript
Method Accept(pVisitor As Visitor) As %Status
{
    // Double dispatch - element tells visitor its specific type
    Quit pVisitor.VisitPatientRecord($THIS)
}
```

3. **Type Safety**: Use proper parameter types to ensure compile-time checking:

```objectscript
Method VisitPatientRecord(pElement As Patterns.Examples.PatientRecord) As %Status
```

4. **Error Handling**: Use Try/Catch blocks and %Status returns:

```objectscript
Method Accept(pVisitor As Visitor) As %Status
{
    Set tSC = $$$OK
    Try {
        Set tSC = pVisitor.VisitPatientRecord($THIS)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}
```

### Implementation Steps

1. **Define the Visitor interface** with visit methods for each element type
2. **Define the Element interface** with an Accept method
3. **Implement ConcreteElement classes** that implement Accept
4. **Implement ConcreteVisitor classes** for specific operations
5. **Create object structures** that can be traversed

### ObjectScript-Specific Features

- **Dynamic Method Dispatch**: Use `$CLASSMETHOD` for dynamic visitor selection
- **Collection Integration**: Support for `%Collection` classes in traversal
- **Performance Optimization**: Cache method references for repeated operations
- **Global Integration**: Use globals for visitor state persistence if needed

## Sample Code

### Basic Visitor Implementation

```objectscript
/// Abstract Visitor Base Class
Class Patterns.GoF.Behavioral.Visitor Extends %RegisteredObject [ Abstract ]
{
    /// Visit method for PatientRecord
    Method VisitPatientRecord(pElement As PatientRecord) As %Status [ Abstract ]
    {
        Quit $$$OK
    }
    
    /// Visit method for LabResult
    Method VisitLabResult(pElement As LabResult) As %Status [ Abstract ]
    {
        Quit $$$OK
    }
    
    /// Initialize visitor before traversal
    Method Initialize() As %Status
    {
        Quit $$$OK
    }
    
    /// Finalize visitor after traversal
    Method Finalize() As %Status
    {
        Quit $$$OK
    }
}

/// Abstract Element Base Class
Class Patterns.GoF.Behavioral.Element Extends %RegisteredObject [ Abstract ]
{
    /// Accept a visitor - implements double dispatch
    Method Accept(pVisitor As Visitor) As %Status [ Abstract ]
    {
        Quit $$$OK
    }
}

/// Concrete Element Implementation
Class Patterns.Examples.PatientRecord Extends Element
{
    Property PatientId As %String;
    Property FirstName As %String;
    Property LastName As %String;
    Property DateOfBirth As %String;
    
    /// Accept visitor using double dispatch
    Method Accept(pVisitor As Visitor) As %Status
    {
        Quit pVisitor.VisitPatientRecord($THIS)
    }
    
    Method GetFullName() As %String
    {
        Quit ..FirstName_" "_..LastName
    }
}
```

### Healthcare Audit Visitor Example

```objectscript
/// HIPAA Compliance Audit Visitor
Class Patterns.Examples.AuditVisitor Extends Patterns.GoF.Behavioral.Visitor
{
    Property AuditFindings As %String [ Private ];
    Property ViolationsFound As %Integer [ Private ];
    Property AuditorUserId As %String;
    
    /// Visit PatientRecord for HIPAA compliance
    Method VisitPatientRecord(pElement As PatientRecord) As %Status
    {
        Set tSC = $$$OK
        Set tViolations = 0
        
        Try {
            // Check required patient information
            If pElement.FirstName = "" {
                Do ..AddFinding("VIOLATION: Missing first name", 1)
                Set tViolations = tViolations + 1
            }
            
            If pElement.LastName = "" {
                Do ..AddFinding("VIOLATION: Missing last name", 1)
                Set tViolations = tViolations + 1
            }
            
            If pElement.DateOfBirth = "" {
                Do ..AddFinding("VIOLATION: Missing date of birth", 1)
                Set tViolations = tViolations + 1
            }
            
            // Log compliance status
            Set tStatus = $SELECT(tViolations=0:"COMPLIANT", 1:"VIOLATIONS FOUND")
            Do ..AddFinding("Patient "_pElement.PatientId_": "_tStatus)
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Add finding to audit report
    Method AddFinding(pFinding As %String, pIsViolation As %Boolean = 0) [ Private ]
    {
        Set tTimestamp = $ZDATETIME($HOROLOG,3)
        Set tEntry = tTimestamp_" - "_pFinding
        
        If ..AuditFindings '= "" {
            Set ..AuditFindings = ..AuditFindings_$CHAR(13,10)_tEntry
        } Else {
            Set ..AuditFindings = tEntry
        }
        
        If pIsViolation {
            Set ..ViolationsFound = ..ViolationsFound + 1
        }
    }
    
    Method GetAuditReport() As %String
    {
        Quit "HEALTHCARE AUDIT REPORT"_$CHAR(13,10)_..AuditFindings
    }
}
```

### Usage Example

```objectscript
// Create patient records
Set patient1 = ##class(PatientRecord).%New()
Set patient1.PatientId = "PAT001"
Set patient1.FirstName = "John"
Set patient1.LastName = "Doe"
Set patient1.DateOfBirth = "1980-01-15"

Set patient2 = ##class(PatientRecord).%New()
Set patient2.PatientId = "PAT002"
// Missing required information

// Create audit visitor
Set auditVisitor = ##class(AuditVisitor).%New()
Set auditVisitor.AuditorUserId = "AUDITOR_123"

// Perform audit
Do auditVisitor.Initialize()
Do patient1.Accept(auditVisitor)
Do patient2.Accept(auditVisitor)
Do auditVisitor.Finalize()

// Get results
Write auditVisitor.GetAuditReport()
Write "Violations found: "_auditVisitor.ViolationsFound
```

## Extending Closed Classes in ObjectScript

The Visitor pattern is particularly valuable in ObjectScript for extending closed class hierarchies without modification:

### Problem: Closed Medical Record System

```objectscript
// Existing medical record system (cannot modify)
Class Legacy.PatientRecord Extends %Persistent
{
    Property PatientId As %String;
    Property Demographics As %String;
    // Cannot add new methods without recompilation
}

Class Legacy.LabResult Extends %Persistent  
{
    Property TestName As %String;
    Property Value As %String;
    // Cannot add billing calculations
}
```

### Solution: Visitor Pattern Extension

```objectscript
// Create visitor interface for new operations
Class Extensions.MedicalRecordVisitor Extends %RegisteredObject [ Abstract ]
{
    Method VisitPatientRecord(pRecord As Legacy.PatientRecord) As %Status [ Abstract ]
    Method VisitLabResult(pResult As Legacy.LabResult) As %Status [ Abstract ]
}

// Add new billing functionality without modifying existing classes
Class Extensions.BillingVisitor Extends Extensions.MedicalRecordVisitor
{
    Property TotalCharges As %Currency [ InitialExpression = 0 ];
    
    Method VisitPatientRecord(pRecord As Legacy.PatientRecord) As %Status
    {
        // Calculate patient visit charges
        Set ..TotalCharges = ..TotalCharges + 150.00  // Base visit fee
        Quit $$$OK
    }
    
    Method VisitLabResult(pResult As Legacy.LabResult) As %Status
    {
        // Calculate lab test charges
        Set tCharge = ..GetTestCharge(pResult.TestName)
        Set ..TotalCharges = ..TotalCharges + tCharge
        Quit $$$OK
    }
    
    Method GetTestCharge(pTestName As %String) As %Currency [ Private ]
    {
        // Lookup test charges
        Set tCharges("CBC") = 45.00
        Set tCharges("Lipid Panel") = 75.00
        Set tCharges("Glucose") = 25.00
        Quit $GET(tCharges(pTestName), 50.00)  // Default charge
    }
}
```

## Advanced Visitor Patterns

### Composite Visitor for Complex Structures

```objectscript
Class Patterns.Examples.CompositeVisitor Extends Visitor
{
    /// Visit composite medical record with multiple components
    Method VisitMedicalRecord(pRecord As CompositeRecord) As %Status
    {
        Set tSC = $$$OK
        
        // Visit the record itself
        Set tSC = ..ProcessRecord(pRecord)
        If $$$ISERR(tSC) Quit tSC
        
        // Visit all child components
        Set tChildren = pRecord.GetChildren()
        For i=1:1:tChildren.Count() {
            Set tChild = tChildren.GetAt(i)
            Set tSC = tChild.Accept($THIS)
            If $$$ISERR(tSC) Quit
        }
        
        Quit tSC
    }
}
```

### Visitor with State Accumulation

```objectscript
Class Patterns.Examples.StatisticsVisitor Extends Visitor
{
    Property PatientCount As %Integer [ InitialExpression = 0 ];
    Property AverageAge As %Numeric [ InitialExpression = 0 ];
    Property TotalAge As %Integer [ InitialExpression = 0 ];
    Property DiagnosisCounts [ MultiDimensional ];
    
    Method VisitPatientRecord(pRecord As PatientRecord) As %Status
    {
        // Accumulate statistics
        Set ..PatientCount = ..PatientCount + 1
        Set tAge = pRecord.GetAge()
        Set ..TotalAge = ..TotalAge + tAge
        Set ..AverageAge = ..TotalAge / ..PatientCount
        
        // Count diagnoses
        Set tDiagnoses = pRecord.GetDiagnoses()
        For i=1:1:tDiagnoses.Count() {
            Set tDiagnosis = tDiagnoses.GetAt(i)
            Set ..DiagnosisCounts(tDiagnosis) = $GET(..DiagnosisCounts(tDiagnosis)) + 1
        }
        
        Quit $$$OK
    }
    
    Method GetStatisticsReport() As %DynamicObject
    {
        Set tReport = ##class(%DynamicObject).%New()
        Do tReport.%Set("patientCount", ..PatientCount)
        Do tReport.%Set("averageAge", ..AverageAge)
        
        Set tDiagnoses = ##class(%DynamicArray).%New()
        Set tDiagnosis = $ORDER(..DiagnosisCounts(""))
        While tDiagnosis '= "" {
            Set tDiagData = ##class(%DynamicObject).%New()
            Do tDiagData.%Set("diagnosis", tDiagnosis)
            Do tDiagData.%Set("count", ..DiagnosisCounts(tDiagnosis))
            Do tDiagnoses.%Push(tDiagData)
            Set tDiagnosis = $ORDER(..DiagnosisCounts(tDiagnosis))
        }
        Do tReport.%Set("diagnosisCounts", tDiagnoses)
        
        Quit tReport
    }
}
```

## Known Uses

1. **Healthcare Information Systems**
   - HIPAA compliance auditing
   - Clinical decision support
   - Billing and insurance processing
   - Quality metrics calculation

2. **Document Processing Systems**
   - Format conversion (HTML, PDF, XML)
   - Content validation
   - Metadata extraction
   - Accessibility compliance

3. **Compiler Design**
   - Syntax tree traversal
   - Code generation
   - Optimization passes
   - Error checking

4. **Object-Relational Mapping**
   - Schema generation
   - Query optimization
   - Cache management
   - Validation

## Related Patterns

- **Composite**: Visitor can be used to apply operations over Composite structures
- **Interpreter**: Visitor can be used to interpret language constructs
- **Iterator**: Iterator can be used to traverse structures that Visitor operates on
- **Strategy**: Strategy encapsulates algorithms; Visitor encapsulates operations on object structures
- **Command**: Command encapsulates requests; Visitor encapsulates operations

## Visitor vs Other Patterns

| Pattern | Purpose | When to Use |
|---------|---------|-------------|
| **Visitor** | Add operations to object structures | Stable structure, changing operations |
| **Strategy** | Encapsulate algorithms | Interchangeable algorithms |
| **Command** | Encapsulate requests | Decouple sender from receiver |
| **Observer** | Notify of state changes | Publish-subscribe relationships |
| **Template Method** | Define algorithm skeleton | Fixed algorithm steps, varying implementations |

## Performance Considerations

### ObjectScript Optimizations

1. **Method Caching**: Cache visitor method references for repeated operations
2. **Lazy Evaluation**: Defer expensive calculations until needed
3. **Global State**: Use globals for persistent visitor state across sessions
4. **Memory Management**: Clean up visitor state in Finalize() method
5. **Batch Processing**: Process multiple elements efficiently

```objectscript
/// Optimized visitor with caching
Class Patterns.Examples.OptimizedVisitor Extends Visitor
{
    Property MethodCache [ MultiDimensional, Private ];
    
    Method VisitElement(pElement As Element) As %Status
    {
        Set tClassName = pElement.%ClassName(1)
        Set tMethodName = "Visit"_tClassName
        
        // Cache method reference
        If '$DATA(..MethodCache(tMethodName)) {
            Set ..MethodCache(tMethodName) = $METHOD($THIS, tMethodName)
        }
        
        // Use cached method
        Set tMethod = ..MethodCache(tMethodName)
        Quit $XECUTE("Quit "_tMethod_"(pElement)", pElement)
    }
}
```

## Testing Visitor Patterns

### Unit Testing Strategies

```objectscript
Class Patterns.Test.VisitorTest Extends %UnitTest.TestCase
{
    Method TestVisitorAcceptance()
    {
        // Arrange
        Set tVisitor = ##class(TestVisitor).%New()
        Set tElement = ##class(TestElement).%New()
        
        // Act
        Set tSC = tElement.Accept(tVisitor)
        
        // Assert
        Do $$$AssertStatusOK(tSC, "Element should accept visitor")
        Do $$$AssertTrue(tVisitor.WasVisited(), "Visitor should be called")
    }
    
    Method TestDoubleDispatch()
    {
        // Test that correct visitor method is called based on element type
        Set tVisitor = ##class(TrackingVisitor).%New()
        Set tElementA = ##class(ConcreteElementA).%New()
        Set tElementB = ##class(ConcreteElementB).%New()
        
        Do tElementA.Accept(tVisitor)
        Do tElementB.Accept(tVisitor)
        
        Do $$$AssertEquals(tVisitor.GetVisitedTypes(), "A,B", "Should visit correct types")
    }
}
```

## Conclusion

The Visitor pattern is a powerful tool for adding operations to object structures without modifying the classes themselves. In ObjectScript healthcare applications, it's particularly useful for:

- **Regulatory Compliance**: Adding audit and compliance checking
- **Business Intelligence**: Collecting statistics and generating reports  
- **Integration**: Converting data to different formats
- **Quality Assurance**: Validating data integrity and completeness

The pattern works best when the object structure is stable but operations change frequently. While it can make adding new element types difficult, the benefits of separating operations from structure often outweigh this limitation in enterprise healthcare systems.

Key ObjectScript considerations include proper abstract method implementation, error handling with %Status returns, and leveraging ObjectScript's dynamic features for enhanced flexibility.
