# Chapter 02: The Factory Method Pattern

## What is the Factory Method Pattern?
Imagine you run a hospital that needs different types of patient records: some for emergency visits, some for regular appointments, and others for overnight stays. Rather than having one giant form that tries to handle everything, you create specialized departments that each know how to create the right type of record. Each department (Inpatient, Outpatient, Emergency) has its own "factory" that creates exactly the right kind of patient record with all the necessary fields and defaults. This is the Factory Method pattern - letting specialized subclasses decide which type of object to create.

## Intent
The Factory Method pattern defines an interface for creating an object, but lets subclasses decide which class to instantiate. It lets a class defer instantiation to subclasses, promoting loose coupling by eliminating the need to bind application-specific classes into your code.

**Implementation Files:**
- Abstract Factory: `/src/Patterns/GoF/Creational/FactoryMethod.cls`
- Abstract Product: `/src/Patterns/GoF/Creational/Product.cls`
- Concrete Products: `/src/Patterns/GoF/Creational/ConcreteProductA.cls`, `ConcreteProductB.cls`
- Concrete Factories: `/src/Patterns/GoF/Creational/ConcreteFactoryA.cls`, `ConcreteFactoryB.cls`
- Healthcare Example Factory: `/src/Patterns/Examples/PatientRecordFactory.cls`
- Healthcare Example Concrete Factories: `/src/Patterns/Examples/EmergencyRecordFactory.cls`, `InpatientRecordFactory.cls`, `OutpatientRecordFactory.cls`
- Healthcare Example Products: `/src/Patterns/Examples/EmergencyRecord.cls`, `InpatientRecord.cls`, `OutpatientRecord.cls`

## When Should You Use It? (Applicability)
- When a class can't anticipate the type of objects it needs to create
- When a class wants its subclasses to specify the objects it creates
- When you want to localize the knowledge of which specific class to instantiate
- When you have several similar classes that differ only in the objects they create

**Real-world Healthcare Examples:**
- Creating different types of patient records (Inpatient, Outpatient, Emergency)
- Generating lab orders based on test type (Blood work, Imaging, Pathology)
- Creating insurance claims for different providers (Medicare, Private, Medicaid)
- Generating medical reports based on department (Radiology, Cardiology, Neurology)

## How It Works (Structure)

```
     ┌──────────────────┐
     │  FactoryMethod   │ <---- Abstract Creator
     ├──────────────────┤
     │ +FactoryMethod() │ <---- Calls CreateProduct()
     │ +CreateProduct() │ <---- Abstract method
     └──────────────────┘
              △
              │
     ┌────────┴────────┐
     │                 │
┌─────────────┐  ┌─────────────┐
│ConcreteFactoryA│  │ConcreteFactoryB│
├─────────────┤  ├─────────────┤
│+CreateProduct()│  │+CreateProduct()│
└─────────────┘  └─────────────┘
      Creates           Creates
        ↓                 ↓
┌─────────────┐  ┌─────────────┐
│ConcreteProductA│  │ConcreteProductB│
└─────────────┘  └─────────────┘
```

**Step-by-Step Code Walkthrough:**

1. **Abstract Factory Class:**
```objectscript
Class Patterns.GoF.Creational.FactoryMethod Extends %RegisteredObject [ Abstract ] {
    
    // Properties for tracking
    Property ProductCount As %Integer [ InitialExpression = 0 ];
    Property TrackProducts As %Boolean [ InitialExpression = 0 ];
    
    // Template method that uses the factory method
    Method FactoryMethod(pType As %String = "") As Patterns.GoF.Creational.Product {
        // Delegates to subclass to create product
        Set product = ..CreateProduct(pType)
        
        // Common initialization
        If $IsObject(product) {
            Do product.Initialize()
            
            // Track the product if needed
            If ..TrackProducts {
                Set ..ProductCount = ..ProductCount + 1
            }
        }
        
        Quit product
    }
    
    // Abstract method - subclasses must implement
    // NOTE: In ObjectScript, abstract methods must have a body that returns a value
    Method CreateProduct(pType As %String) As Patterns.GoF.Creational.Product [ Abstract ] {
        Quit $$$NULLOREF
    }
}
```

2. **Abstract Product Class:**
```objectscript
Class Patterns.GoF.Creational.Product Extends %RegisteredObject [ Abstract ] {
    
    Property Name As %String;
    Property Type As %String;
    Property CreatedAt As %TimeStamp;
    
    // Initialize the product
    Method Initialize() As %Status {
        Set ..CreatedAt = $ZDateTime($H, 3)
        Quit $$$OK
    }
    
    // Abstract operation that products must implement
    Method Operation() As %String [ Abstract ] {
        Quit ""
    }
    
    // Get product description
    Method GetDescription() As %String {
        Quit "Product: " _ ..Name _ " (Type: " _ ..Type _ ") created at " _ ..CreatedAt
    }
}
```

3. **Concrete Factory Implementation:**
```objectscript
Class ConcreteFactoryA Extends FactoryMethod {
    
    Method CreateProduct(pType As %String) As Product {
        // Creates specific product type
        Set product = ##class(ConcreteProductA).%New()
        Set product.Name = "Product A-" _ $Random(1000)
        Set product.Type = "TypeA"
        Quit product
    }
}
```

4. **Healthcare Example - Patient Record Factory:**
```objectscript
Class PatientRecordFactory Extends %RegisteredObject [ Abstract ] {
    
    Property RecordRegistry As list Of PatientRecord;
    Property RecordsCreated As %Integer [ InitialExpression = 0 ];
    Property FactoryName As %String;
    Property DefaultDepartment As %String;
    
    // Abstract method with proper ObjectScript return
    Method CreateRecord() As PatientRecord [ Abstract ] {
        Quit $$$NULLOREF
    }
    
    // Common factory method with initialization
    Method FactoryMethod(pPatientName As %String = "", pPatientMRN As %String = "", pProvider As %String = "") As PatientRecord {
        Set record = ""
        
        Try {
            // Delegate to subclass
            Set record = ..CreateRecord()
            
            // Set common properties
            If pPatientName '= "" {
                Set record.PatientName = pPatientName
            } Else {
                Set record.PatientName = "Patient-" _ $Random(10000)
            }
            
            If pPatientMRN '= "" {
                Set record.PatientMRN = pPatientMRN
            }
            
            If pProvider '= "" {
                Set record.AttendingProvider = pProvider
            } Else {
                Set record.AttendingProvider = "Dr. " _ $Piece("Smith,Johnson,Williams", ",", $Random(3) + 1)
            }
            
            // Set department from factory default
            If (record.Department = "") && (..DefaultDepartment '= "") {
                Set record.Department = ..DefaultDepartment
            }
            
            // Initialize the record
            Set tSC = record.Initialize()
            If $$$ISERR(tSC) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
            }
            
            // Register the created record
            Do ..RegisterRecord(record)
            
        } Catch ex {
            Write "Error creating patient record: ", ex.DisplayString(), !
            Set record = ""
        }
        
        Quit record
    }
    
    // Track created records
    Method RegisterRecord(pRecord As PatientRecord) {
        Do ..RecordRegistry.Insert(pRecord)
        Set ..RecordsCreated = ..RecordsCreated + 1
    }
}
```

## What Happens When You Use It (Consequences)

### The Good Parts ✅
- **Flexibility:** Easy to add new product types without changing existing code
```objectscript
// Adding a new factory is simple
Class TelemedicineRecordFactory Extends PatientRecordFactory {
    Method CreateRecord() As PatientRecord { 
        Quit ##class(TelemedicineRecord).%New() 
    }
}
```

- **Encapsulation:** Each factory knows exactly how to configure its products
```objectscript
// EmergencyRecordFactory handles emergency-specific initialization
Method CreateRecord() As PatientRecord {
    Set record = ##class(EmergencyRecord).%New()
    
    // Generate unique RecordID
    Set record.RecordID = "ER-" _ $ZDT($H, 8) _ "-" _ $Random(10000)
    
    // Set emergency-specific defaults
    Set record.RecordType = "EMERGENCY"
    Set record.Department = ..#DEFAULTDEPARTMENT
    
    // Initialize emergency fields
    Set record.TriageLevel = ..AssignTriageLevel()
    Set record.ChiefComplaint = ..GenerateChiefComplaint()
    Set record.ArrivalTime = $ZTime($H, 1)
    Set record.ArrivalMode = ..DetermineArrivalMode()
    Set record.VitalSigns = ..RecordVitalSigns()
    Set record.SeverityIndex = ..CalculateSeverityIndex(record.TriageLevel)
    
    // Set priority based on triage level
    Set record.Priority = 11 - (record.TriageLevel * 2)
    
    Quit record
}
```

- **Consistency:** Common behavior handled by the base class
- **Testability:** Each factory can be tested independently

### The Challenging Parts ⚠️
- **Complexity:** Requires creating parallel class hierarchies (factories and products)
- **Overhead:** May be overkill for simple object creation
- **Coupling:** Still couples code to concrete factory classes (though not products)

## Real Example: Hospital Patient Record System

```objectscript
// Using the factory pattern for patient records
Class HospitalAdmissionSystem {
    
    Method AdmitPatient(pType As %String, pName As %String, pMRN As %String) As %Status {
        Set tSC = $$$OK
        
        Try {
            // Select appropriate factory based on admission type
            If pType = "EMERGENCY" {
                Set factory = ##class(EmergencyRecordFactory).%New()
            } ElseIf pType = "INPATIENT" {
                Set factory = ##class(InpatientRecordFactory).%New()
            } Else {
                Set factory = ##class(OutpatientRecordFactory).%New()
            }
            
            // Factory creates the right type of record
            Set record = factory.FactoryMethod(pName, pMRN, "Dr. Smith")
            
            // Process the record (polymorphically)
            Set processResult = record.ProcessRecord()
            Set billingCode = record.CalculateBillingCode()
            
            Write "Created ", record.RecordType, " record", !
            Write "Priority: ", record.Priority, !
            Write "Billing Code: ", billingCode, !
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}

// Emergency records get high priority and special triage
Class EmergencyRecordFactory Extends PatientRecordFactory {
    
    Parameter FACTORYTYPE = "EMERGENCY";
    Parameter DEFAULTDEPARTMENT = "Emergency Department";
    
    Method CreateRecord() As PatientRecord {
        Set record = ##class(EmergencyRecord).%New()
        
        // Set emergency-specific fields
        Set record.RecordID = "ER-" _ $ZDT($H, 8) _ "-" _ $Random(10000)
        Set record.RecordType = "EMERGENCY"
        Set record.Department = ..#DEFAULTDEPARTMENT
        
        // Assign triage level
        Set record.TriageLevel = ..AssignTriageLevel()
        
        // Set severity based on triage
        If record.TriageLevel <= 2 {
            Set record.Severity = "Critical"
        } ElseIf record.TriageLevel = 3 {
            Set record.Severity = "Urgent"
        } ElseIf record.TriageLevel = 4 {
            Set record.Severity = "Less Urgent"
        } Else {
            Set record.Severity = "Non-Urgent"
        }
        
        // Set priority (higher priority for more severe cases)
        Set record.Priority = 11 - (record.TriageLevel * 2)
        
        // Additional emergency initialization
        Set record.TraumaAlert = ..CheckTraumaAlert(record.TriageLevel, record.ChiefComplaint)
        Set record.WaitTimeMinutes = ..EstimateWaitTime(record.TriageLevel)
        Set record.Disposition = "Pending Evaluation"
        
        Quit record
    }
    
    Method AssignTriageLevel() As %Integer [ Private ] {
        // Simulate realistic triage distribution
        Set rand = $Random(100)
        If rand < 2 Quit 1        // Critical - 2%
        If rand < 12 Quit 2       // Emergent - 10%
        If rand < 47 Quit 3       // Urgent - 35%
        If rand < 87 Quit 4       // Less Urgent - 40%
        Quit 5                    // Non-Urgent - 13%
    }
}
```

## Testing the Pattern

**Test Class:** `/src/Patterns/Test/Unit/GoF/Creational/FactoryMethodTest.cls`

**Key Test Scenarios:**
- Abstract factory behavior delegation
- Each concrete factory creates correct product type
- Healthcare factories properly initialize domain-specific fields
- Polymorphic behavior of created products
- Registry tracking of created records
- Error handling with invalid parameters

```objectscript
Method TestPolymorphicBehavior() {
    // All factories can be used interchangeably
    Set factories(1) = ##class(InpatientRecordFactory).%New()
    Set factories(2) = ##class(OutpatientRecordFactory).%New()
    Set factories(3) = ##class(EmergencyRecordFactory).%New()
    
    For i=1:1:3 {
        Set record = factories(i).FactoryMethod("Test", "MRN"_i, "Dr. Test")
        // All records implement the same interface
        Set processResult = record.ProcessRecord()
        Set code = record.CalculateBillingCode()
        Do $$$AssertTrue($IsObject(record), "Factory " _ i _ " created valid record")
    }
}
```

## Factory Method vs Similar Patterns

| Pattern | Purpose | Key Difference |
|---------|---------|---------------|
| **Factory Method** | Subclasses decide which class to instantiate | Uses inheritance |
| **Abstract Factory** | Creates families of related objects | Multiple factory methods |
| **Simple Factory** | Single class creates objects based on parameters | Not a true pattern, just a method |
| **Builder** | Constructs complex objects step by step | Focus on construction process |

## Summary
The Factory Method pattern is like having specialized departments in a hospital - each knows exactly how to handle its specific type of case. The Emergency Department knows to check triage levels and assign trauma teams, while the Outpatient Clinic focuses on scheduling follow-ups and calculating copays. By letting each specialized factory handle its own creation logic, we get:

- Clean separation of concerns
- Easy addition of new types
- Consistent object initialization
- Type-safe object creation
- Testable, maintainable code

## Try It Yourself
1. **Add a Telemedicine Factory:** Create a `TelemedicineRecordFactory` that creates virtual visit records with fields like `VideoURL`, `ConnectionQuality`, and `TechPlatform`

2. **Implement Statistics:** Add a method to track how many records each factory has created and their average processing time

3. **Create a Lab Test Factory:** Build factories for different lab test types (BloodTest, UrineTest, ImagingTest) with appropriate fields and validation

4. **Add Validation:** Enhance the factories to validate that required fields are present based on record type (e.g., Emergency must have TriageLevel)

5. **Build a Report Generator:** Create factories for different medical reports (DischargeReport, ProgressNote, ConsultationReport) with appropriate templates
