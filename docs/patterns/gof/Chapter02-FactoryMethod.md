# Chapter 02: The Factory Method Pattern

## What is the Factory Method Pattern?
Imagine you run a hospital that needs different types of patient records: some for emergency visits, some for regular appointments, and others for overnight stays. Rather than having one giant form that tries to handle everything, you create specialized departments that each know how to create the right type of record. Each department (Inpatient, Outpatient, Emergency) has its own "factory" that creates exactly the right kind of patient record with all the necessary fields and defaults. This is the Factory Method pattern - letting specialized subclasses decide which type of object to create.

## Intent
The Factory Method pattern defines an interface for creating an object, but lets subclasses decide which class to instantiate. It lets a class defer instantiation to subclasses, promoting loose coupling by eliminating the need to bind application-specific classes into your code.

**Implementation Files:**
- Abstract Factory: `/src/Patterns/GoF/Creational/FactoryMethod.cls`
- Concrete Products: `/src/Patterns/GoF/Creational/ConcreteProductA.cls`, `ConcreteProductB.cls`
- Healthcare Example: `/src/Patterns/Examples/PatientRecordFactory.cls` and related classes

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
Class Patterns.GoF.Creational.FactoryMethod {
    // Template method that uses the factory method
    Method FactoryMethod() As Product {
        // Delegates to subclass to create product
        Set product = ..CreateProduct()
        // Common initialization
        Do product.Initialize()
        Return product
    }
    
    // Abstract method - subclasses must implement
    Method CreateProduct() As Product [ Abstract ] { }
}
```

2. **Concrete Factory Implementation:**
```objectscript
Class ConcreteFactoryA Extends FactoryMethod {
    Method CreateProduct() As Product {
        // Creates specific product type
        Return ##class(ConcreteProductA).%New()
    }
}
```

3. **Healthcare Example - Patient Record Factory:**
```objectscript
Class PatientRecordFactory {
    // Common factory method with initialization
    Method FactoryMethod(pPatientName, pMRN, pProvider) {
        Set record = ..CreateRecord()  // Delegate to subclass
        Set record.PatientName = pPatientName
        Set record.CreatedAt = $H
        Do ..RegisterRecord(record)    // Track in registry
        Return record
    }
    
    // Abstract - each factory type implements
    Method CreateRecord() As PatientRecord [ Abstract ] { }
}
```

## What Happens When You Use It (Consequences)

### The Good Parts ✅
- **Flexibility:** Easy to add new product types without changing existing code
```objectscript
// Adding a new factory is simple
Class TelemedicineRecordFactory Extends PatientRecordFactory {
    Method CreateRecord() { Return ##class(TelemedicineRecord).%New() }
}
```

- **Encapsulation:** Each factory knows exactly how to configure its products
```objectscript
// InpatientRecordFactory handles room assignment automatically
Method CreateRecord() {
    Set record = ##class(InpatientRecord).%New()
    Set record.RoomNumber = ..AssignRoom()
    Set record.AuthorizationCode = ..GenerateAuthCode()
    Return record
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
    Method AdmitPatient(pType, pName, pMRN) {
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
        Do record.ProcessRecord()
        Set billingCode = record.CalculateBillingCode()
        
        Write "Created ", record.RecordType, " record", !
        Write "Priority: ", record.Priority, !
        Write "Billing Code: ", billingCode, !
    }
}

// Emergency records get high priority and special triage
Class EmergencyRecordFactory {
    Method CreateRecord() {
        Set record = ##class(EmergencyRecord).%New()
        Set record.TriageLevel = ..AssignTriageLevel()
        Set record.Priority = 11 - (record.TriageLevel * 2)
        Set record.TraumaAlert = ..CheckTraumaAlert()
        Return record
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
        Do record.ProcessRecord()
        Set code = record.CalculateBillingCode()
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
