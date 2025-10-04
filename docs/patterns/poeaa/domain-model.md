# Domain Model Pattern

## Pattern Classification
- **Type**: Domain Logic Pattern
- **Source**: Patterns of Enterprise Application Architecture (PoEAA)
- **Category**: Business Logic Organization

## Intent

Create a rich object model that contains both business data and business logic, with objects that encapsulate behavior and maintain their own invariants. Domain Model organizes complex business logic into a network of interconnected objects that mirror the problem domain.

## Also Known As
- Rich Domain Model
- Object-Oriented Domain Logic

## Motivation

As business logic grows in complexity, procedural approaches like Transaction Scripts become difficult to maintain. Multiple scripts may duplicate logic, business rules become scattered, and the relationship between different business concepts becomes unclear.

Domain Model addresses these issues by organizing business logic around the core domain concepts. Each domain object is responsible for its own behavior and invariants, making the system more maintainable and aligned with how domain experts think about the problem.

### Problem
- Complex business logic scattered across multiple procedural scripts
- Duplication of business rules in different operations
- Difficulty expressing relationships between business concepts
- Hard to test business logic in isolation from database operations
- Code structure doesn't reflect domain expert vocabulary

### Solution
Create domain objects that are "rich" with both data and behavior. These objects:
- Encapsulate their own business rules and validation
- Maintain their own invariants and consistency
- Express relationships with other domain objects
- Raise domain events for significant state changes
- Can be tested independently of infrastructure concerns

## Structure

```
┌─────────────────────────────────────┐
│      DomainModel (Abstract)         │
├─────────────────────────────────────┤
│ + Identity: String                  │
│ + ValidationErrors: MultiDimensional│
│ + IsValid: Boolean                  │
│ + DomainEvents: MultiDimensional    │
├─────────────────────────────────────┤
│ + Initialize(): Status              │
│ + ValidateRules(): Status           │
│ + CheckInvariants(): Boolean        │
│ + PerformValidation(): Status       │
│ + ExecuteBusinessLogic(): Status    │
│ + RaiseDomainEvent(type, data)      │
│ + GetValidationErrors(): Array      │
└─────────────────────────────────────┘
                    ▲
                    │ extends
        ┌───────────┴───────────┐
        │                       │
┌───────┴──────────┐    ┌──────┴────────┐
│     Patient      │    │   Diagnosis   │
├──────────────────┤    ├───────────────┤
│ + MedicalRecord  │    │ + Code        │
│ + Allergies      │    │ + Description │
│ + Medications    │    │ + Severity    │
├──────────────────┤    ├───────────────┤
│ + AddAllergy()   │    │ + Resolve()   │
│ + CalculateBMI() │    │ + MarkChronic()│
└──────────────────┘    └───────────────┘
        │                       │
        └───────────┬───────────┘
                    │ aggregated by
            ┌───────┴────────────┐
            │   MedicalRecord    │
            │ (Aggregate Root)   │
            ├────────────────────┤
            │ + Patient          │
            │ + Diagnoses[]      │
            │ + Treatments[]     │
            ├────────────────────┤
            │ + AdmitPatient()   │
            │ + AddDiagnosis()   │
            │ + AddTreatment()   │
            │ + CheckSafety()    │
            └────────────────────┘
```

### Key Components

1. **Domain Model Base Class** (`Patterns.PoEAA.DomainLogic.DomainModel`)
   - Provides common domain object infrastructure
   - Identity management for domain objects
   - Validation framework with error collection
   - Domain event handling capabilities
   - Abstract methods for domain-specific behavior

2. **Domain Objects** (Patient, Diagnosis, Treatment)
   - Rich objects with both data and behavior
   - Encapsulate domain-specific business rules
   - Validate their own invariants
   - Raise domain events for state changes

3. **Aggregate Root** (MedicalRecord)
   - Coordinates related domain objects
   - Enforces consistency boundaries
   - Manages complex business rules across objects
   - Single entry point for operations on the aggregate

## Implementation in ObjectScript

### Base Domain Model Class

```objectscript
Class Patterns.PoEAA.DomainLogic.DomainModel Extends %RegisteredObject [ Abstract ]
{
    /// Domain object unique identifier
    Property Identity As %String;
    
    /// Validation errors collection
    Property ValidationErrors [ MultiDimensional ];
    
    /// Domain events raised by this object
    Property DomainEvents [ MultiDimensional ];
    
    /// Validate all business rules and invariants
    Method ValidateRules() As %Status
    {
        Set tSC = $$$OK
        Try {
            Kill ..ValidationErrors
            
            // Check domain invariants
            If '..CheckInvariants() {
                Set tSC = $$$ERROR($$$GeneralError, "Domain invariants violated")
                Quit
            }
            
            // Perform domain-specific validation
            Set tSC = ..PerformValidation()
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    /// Abstract methods to override
    Method CheckInvariants() As %Boolean [ Abstract ]
    Method PerformValidation() As %Status [ Abstract ]
    Method ExecuteBusinessLogic() As %Status [ Abstract ]
}
```

### Rich Domain Object Example

```objectscript
Class Patterns.Examples.Clinical.Patient Extends Patterns.PoEAA.DomainLogic.DomainModel
{
    Property MedicalRecordNumber As %String;
    Property FullName As %String;
    Property Allergies [ MultiDimensional ];
    Property WeightKg As %Numeric;
    Property HeightCm As %Numeric;
    
    /// Check patient domain invariants
    Method CheckInvariants() As %Boolean
    {
        If (..MedicalRecordNumber = "") Quit 0
        If (..FullName = "") Quit 0
        If (..WeightKg < 0) Quit 0
        Quit 1
    }
    
    /// Add allergy with business rule
    Method AddAllergy(pAllergen As %String, pSeverity As %String) As %Status
    {
        // Business logic encapsulated in domain object
        If ..HasAllergy(pAllergen) {
            Quit $$$ERROR($$$GeneralError, "Allergy already recorded")
        }
        
        // Add to collection
        Set tCount = $GET(..Allergies) + 1
        Set ..Allergies = tCount
        Set ..Allergies(tCount, "allergen") = pAllergen
        Set ..Allergies(tCount, "severity") = pSeverity
        
        // Raise domain event
        Do ..RaiseDomainEvent("AllergyAdded", {"allergen": pAllergen})
        
        Quit $$$OK
    }
    
    /// Calculate BMI - business logic in domain object
    Method CalculateBMI() As %Numeric
    {
        If (..WeightKg <= 0) || (..HeightCm <= 0) Quit 0
        Set tHeightM = ..HeightCm / 100
        Quit ..WeightKg / (tHeightM * tHeightM)
    }
}
```

### Aggregate Root Example

```objectscript
Class Patterns.Examples.Clinical.MedicalRecord Extends Patterns.PoEAA.DomainLogic.DomainModel
{
    Property Patient As Patterns.Examples.Clinical.Patient;
    Property Diagnoses [ MultiDimensional ];
    Property Treatments [ MultiDimensional ];
    
    /// Add treatment with comprehensive safety checks
    Method AddTreatment(pTreatment As Treatment) As %Status
    {
        // Validate treatment
        Set tSC = pTreatment.ValidateRules()
        If $$$ISERR(tSC) Quit tSC
        
        // Check drug interactions
        Set tSC = ..CheckDrugInteractions(pTreatment)
        If $$$ISERR(tSC) Quit tSC
        
        // Check contraindications
        Set tSC = ..CheckContraindications(pTreatment)
        If $$$ISERR(tSC) Quit tSC
        
        // Check patient allergies
        If ..Patient.HasAllergy(pTreatment.MedicationName) {
            Quit $$$ERROR($$$GeneralError, "Patient allergic to medication")
        }
        
        // Check dosage safety
        If 'pTreatment.IsSafeForWeight(..Patient.WeightKg, 50) {
            Quit $$$ERROR($$$GeneralError, "Unsafe dosage")
        }
        
        // All checks passed - add treatment
        // ... add to collection ...
        
        Quit $$$OK
    }
}
```

## When to Use

Use Domain Model when:

1. **Complex Business Logic**
   - Multiple interrelated business rules
   - Rich behavior beyond simple CRUD
   - Complex calculations and validations
   - Business rules that change frequently

2. **Rich Domain Concepts**
   - Domain has clear concepts with behavior
   - Objects have meaningful relationships
   - Domain experts use specific vocabulary
   - Business logic naturally groups around concepts

3. **Need for Testability**
   - Business logic must be tested in isolation
   - Unit testing without database required
   - Complex scenarios to validate

4. **Long-term Maintainability**
   - System will evolve over time
   - New features will be added regularly
   - Business rules will change
   - Multiple developers will work on the code

## When Not to Use

Avoid Domain Model when:

1. **Simple CRUD Operations**
   - Mostly database read/write operations
   - Minimal business logic
   - Simple validation rules
   - Transaction Script would be simpler

2. **Performance Critical**
   - Very high throughput requirements
   - Minimal object overhead needed
   - Direct SQL more efficient
   - Response time is critical

3. **Small Team/Short Timeline**
   - Team unfamiliar with OO design
   - Quick prototype or proof of concept
   - Short-lived application
   - Simple requirements

4. **Reporting/Analytics**
   - Primarily data retrieval
   - Complex queries across many tables
   - Read-only operations
   - Set-based operations more efficient

## ObjectScript-Specific Considerations

### Rich vs Anemic Domain Models

**Anemic Domain Model (AVOID)**
```objectscript
// Bad: Just data, no behavior
Class Patient Extends %Persistent
{
    Property Name As %String;
    Property Weight As %Numeric;
}

// Business logic in separate service
Class PatientService
{
    ClassMethod CalculateBMI(pPatient) {
        // Logic should be in Patient class
    }
}
```

**Rich Domain Model (PREFERRED)**
```objectscript
// Good: Data + Behavior
Class Patient Extends DomainModel
{
    Property Name As %String;
    Property WeightKg As %Numeric;
    Property HeightCm As %Numeric;
    
    // Behavior encapsulated in domain object
    Method CalculateBMI() As %Numeric {
        Set tHeightM = ..HeightCm / 100
        Quit ..WeightKg / (tHeightM * tHeightM)
    }
}
```

### ObjectScript Object Modeling Techniques

1. **Use MultiDimensional Properties for Collections**
   ```objectscript
   Property Allergies [ MultiDimensional ];
   ```

2. **Encapsulate Business Rules in Methods**
   ```objectscript
   Method IsSafeForWeight(pWeightKg, pMaxDosePerKg) As %Boolean
   ```

3. **Maintain Object Identity Separate from Database ID**
   ```objectscript
   Property Identity As %String;  // Domain identity
   // vs %Id from %Persistent (database identity)
   ```

4. **Use Domain Events for Significant State Changes**
   ```objectscript
   Do ..RaiseDomainEvent("PatientAdmitted", eventData)
   ```

5. **Validate Invariants Before Persistence**
   ```objectscript
   If '..CheckInvariants() { /* reject */ }
   ```

## Domain Model vs Transaction Script

| Aspect | Domain Model | Transaction Script |
|--------|--------------|-------------------|
| **Complexity** | Handles complex logic well | Best for simple logic |
| **Organization** | Object-oriented | Procedural |
| **Reusability** | High - methods on objects | Low - in procedures |
| **Testability** | Easy to unit test | Harder to test in isolation |
| **Learning Curve** | Steeper | Easier to learn |
| **Performance** | Object overhead | More direct |
| **Maintenance** | Better for evolving requirements | Gets messy as complexity grows |
| **Use Case** | Complex business rules | Simple CRUD operations |

## Healthcare Clinical Example

### Scenario
A hospital admission system that manages patients, diagnoses, and treatments with complex safety rules.

### Domain Objects

**Patient** - Demographics, allergies, medications, medical history
- `AddAllergy()` - Records patient allergies
- `CalculateBMI()` - Calculates body mass index
- `CalculateAge()` - Determines patient age
- `HasAllergy()` - Checks for specific allergies

**Diagnosis** - Medical conditions with ICD-10 codes
- `AddContraindication()` - Records treatment contraindications
- `Resolve()` - Marks diagnosis as resolved
- `MarkAsChronic()` - Designates as chronic condition

**Treatment** - Medication orders with dosage calculations
- `CalculateDailyDosage()` - Computes total daily dose
- `IsSafeForWeight()` - Validates dosage safety
- `Start()`, `Complete()`, `Discontinue()` - Lifecycle management

**MedicalRecord (Aggregate Root)** - Coordinates all clinical data
- `AdmitPatient()` - Admits patient to hospital
- `AddDiagnosis()` - Records diagnosis with validation
- `AddTreatment()` - Orders treatment with safety checks
  - Drug interaction checking
  - Contraindication validation
  - Allergy verification
  - Weight-based dosage safety
- `DischargePatient()` - Completes admission

### Business Rules Implemented

1. **Allergy Safety**: Treatment rejected if patient allergic to medication
2. **Drug Interactions**: Duplicate medications detected and rejected
3. **Contraindications**: Treatments checked against diagnosis contraindications
4. **Dosage Safety**: Weight-based dosage limits enforced
5. **Data Validation**: All data validated before acceptance
6. **Domain Events**: State changes tracked for audit/notification

## Benefits

1. **Alignment with Domain**
   - Code mirrors how domain experts think
   - Clear domain vocabulary in code
   - Easy communication with domain experts

2. **Encapsulation**
   - Business logic co-located with data
   - Reduced coupling between components
   - Easier to understand and modify

3. **Testability**
   - Unit test business logic without database
   - Mock relationships easily
   - Test complex scenarios in isolation

4. **Maintainability**
   - Changes localized to relevant objects
   - Less code duplication
   - Easier to add new features

5. **Flexibility**
   - Adapt to changing requirements
   - Extend behavior through inheritance
   - Compose complex behaviors

## Drawbacks

1. **Complexity**
   - Higher initial development cost
   - Requires OO design skills
   - More classes to manage

2. **Performance**
   - Object creation overhead
   - More memory usage
   - Potentially slower than direct SQL

3. **Learning Curve**
   - Team needs OO expertise
   - Domain-driven design concepts
   - Aggregate pattern understanding

4. **Overkill for Simple Cases**
   - Too complex for CRUD operations
   - Unnecessary for simple logic
   - Transaction Script would be simpler

## Related Patterns

- **Transaction Script**: Simpler alternative for procedural business logic
- **Table Module**: Middle ground between Transaction Script and Domain Model
- **Repository**: Provides persistence for domain objects
- **Unit of Work**: Manages transactional consistency for domain changes
- **Aggregate**: Defines consistency boundaries in complex domain models
- **Domain Event**: Captures significant occurrences in the domain

## Known Uses

1. **Healthcare Systems**
   - Clinical decision support
   - Patient management
   - Treatment protocols

2. **Financial Systems**
   - Account management
   - Transaction processing
   - Risk calculations

3. **E-Commerce**
   - Order processing
   - Inventory management
   - Pricing rules

4. **Enterprise Applications**
   - Complex business workflows
   - Multi-step processes
   - Domain-specific logic

## Implementation Checklist

- [ ] Create base DomainModel class with common infrastructure
- [ ] Implement identity management for domain objects
- [ ] Add validation framework with error collection
- [ ] Implement domain event handling
- [ ] Define domain object hierarchy
- [ ] Identify aggregate roots and boundaries
- [ ] Implement business rules in domain objects
- [ ] Create comprehensive unit tests
- [ ] Document domain model design
- [ ] Ensure rich (not anemic) domain objects

## References

1. Fowler, Martin. "Patterns of Enterprise Application Architecture", Chapter on Domain Logic Patterns
2. Evans, Eric. "Domain-Driven Design: Tackling Complexity in the Heart of Software"
3. Vernon, Vaughn. "Implementing Domain-Driven Design"

## See Also

- [Transaction Script Pattern](transaction-script.md) - Alternative for simpler logic
- [Architecture Documentation](../../architecture.md) - Overall system architecture
- [Coding Standards](../../architecture/coding-standards.md) - ObjectScript conventions
