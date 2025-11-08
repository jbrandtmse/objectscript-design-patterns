# Value Object Pattern

## Pattern Type
**Data Source Pattern** - Object-Relational Behavioral

## Intent
A small simple object, like money or date range, whose equality isn't based on identity. Value objects are immutable and should be equal based on their property values, not their identity.

## Also Known As
- Immutable Value
- Value Type

## Motivation
In many object-oriented systems, we distinguish between **entities** (objects with identity) and **value objects** (objects without identity). Consider two $50 bills: they're not the same physical object (different serial numbers), but for most purposes, they're interchangeable—they have the same value.

Problems that arise without Value Objects:
1. **Aliasing Bugs**: When two parts of the code share a mutable object and one modifies it, unexpected side effects occur
2. **Complex Equality**: Reference equality (same object) doesn't match domain semantics (same value)
3. **Thread Safety Issues**: Mutable objects shared across threads require synchronization
4. **Temporal Coupling**: Order of operations matters when objects can be modified

Value Objects solve these problems through **immutability** and **value-based equality**.

## Applicability
Use the Value Object pattern when:

- Objects are distinguished by their values, not identity (money, dates, coordinates)
- Objects should be immutable after creation
- Objects need value-based equality semantics (`Equals()` compares values, not references)
- You want to avoid aliasing bugs from shared mutable objects
- Objects represent measurements, quantities, or descriptive aspects of entities
- Objects are frequently passed as parameters or return values
- Objects can be safely used as hash map keys
- You need thread-safe objects without synchronization

Don't use Value Objects when:
- Objects have a unique identity (use Entity pattern instead)
- Objects need to be modified after creation
- Creating new instances for each "change" would be too expensive
- Object graphs are cyclic (Value Objects work best with tree structures)

## Structure

### Class Diagram
```
┌─────────────────────────────┐
│    ValueObject (Abstract)   │
├─────────────────────────────┤
│ + Equals(pOther): %Boolean  │
│ + GetHashCode(): %Integer   │
│ + ToString(): %String       │
│ + Copy(): ValueObject       │
│ + Validate(): %Status       │
└──────────────┬──────────────┘
               │
      ┌────────┴────────┐
      │                  │
┌─────▼──────┐   ┌──────▼───────┐
│ VitalSigns │   │   LabResult   │
├────────────┤   ├───────────────┤
│ Temperature│   │ TestName      │
│ HeartRate  │   │ Value         │
│ BP Sys/Dia │   │ Unit          │
│ RespRate   │   │ RefRange      │
│ O2Sat      │   │ IsAbnormal    │
└────────────┘   └───────────────┘
```

### Key Components

1. **ValueObject Base Class**
   - Defines contract for immutable value objects
   - Provides Equals() for value-based comparison
   - Provides GetHashCode() for hash-based collections
   - Provides ToString() for string representation

2. **Concrete Value Objects**
   - Extend ValueObject base
   - Implement immutability (Private property setters)
   - Override Equals() to compare all property values
   - Override GetHashCode() to hash all property values
   - Validate invariants in constructor

## Implementation

### ObjectScript Immutability Patterns

ObjectScript doesn't have built-in immutability, so we implement it using conventions:

#### Pattern 1: Private Property Setters
```objectscript
/// Temperature property (read-only after construction)
Property Temperature As %Numeric [ Private ];

/// Constructor sets property using internal storage
Method %OnNew(pTemperature As %Numeric) As %Status
{
    // Set using i%PropertyName to bypass property methods
    Set i%Temperature = pTemperature
    Quit ..Validate()
}

/// Public getter only
Method TemperatureGet() As %Numeric
{
    Quit i%Temperature
}
```

This pattern:
- Makes the property setter private (cannot be called from outside)
- Provides a public getter for reading
- Sets values in constructor using `i%PropertyName` internal storage
- Prevents modification after construction

#### Pattern 2: Copy-on-Modify
```objectscript
/// Create new instance with modified temperature
Method WithTemperature(pNewTemp As %Numeric) As VitalSigns
{
    // Return NEW instance with modified value
    Quit ##class(VitalSigns).%New(
        pNewTemp,           // new temperature
        ..BloodPressureSystolic,
        ..BloodPressureDiastolic,
        ..HeartRate,
        ..RespiratoryRate,
        ..OxygenSaturation
    )
}
```

### Value-Based Equality

```objectscript
Method Equals(pOther As ValueObject) As %Boolean
{
    Set tEquals = 0

    Try {
        // Null check
        If '$IsObject(pOther) {
            Quit
        }

        // Type check - must be same class
        If (pOther.%ClassName(1) '= ..%ClassName(1)) {
            Quit
        }

        // Compare all property values
        If (..Temperature '= pOther.Temperature) {
            Quit
        }
        If (..HeartRate '= pOther.HeartRate) {
            Quit
        }
        // ... compare all properties ...

        Set tEquals = 1

    } Catch ex {
        Set tEquals = 0
    }

    Quit tEquals
}
```

### Hash Code Implementation

```objectscript
Method GetHashCode() As %Integer
{
    Set tHash = 0

    Try {
        // Combine all values into hash
        Set tHash = $LENGTH(..%ClassName(1))
        Set tHash = ((tHash * 31) + (..Temperature * 100)) # 2147483647
        Set tHash = ((tHash * 31) + ..HeartRate) # 2147483647
        // ... hash all properties ...

    } Catch ex {
        Set tHash = 0
    }

    Quit tHash
}
```

Key points:
- Equal objects MUST have equal hash codes
- Use prime multiplier (31) for distribution
- Modulo by large prime to prevent overflow
- Include all properties used in Equals()

### Validation

```objectscript
Method Validate() As %Status
{
    Set tSC = $$$OK

    Try {
        // Validate temperature range
        If (..Temperature < 95) || (..Temperature > 110) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid temperature")
            Quit
        }

        // Validate heart rate range
        If (..HeartRate < 30) || (..HeartRate > 250) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid heart rate")
            Quit
        }

        // ... validate all invariants ...

    } Catch ex {
        Set tSC = ex.AsStatus()
    }

    Quit tSC
}
```

## Healthcare Examples

### Example 1: Vital Signs
```objectscript
// Create immutable vital signs
Set vitals = ##class(VitalSigns).%New(98.6, 120, 80, 72, 16, 98)

// Read values
Write vitals.Temperature  // 98.6
Write vitals.HeartRate     // 72

// Cannot modify - properties are private
// Set vitals.Temperature = 100  // ERROR

// Create modified copy instead
Set vitals2 = vitals.WithTemperature(99.1)
Write vitals.Temperature   // 98.6 (original unchanged)
Write vitals2.Temperature  // 99.1 (new instance)

// Value-based equality
Set vitals3 = ##class(VitalSigns).%New(98.6, 120, 80, 72, 16, 98)
Write vitals.Equals(vitals3)  // 1 (same values)

// Check if normal
Write vitals.IsNormal()  // 1 or 0
```

### Example 2: Lab Result
```objectscript
// Create lab result
Set result = ##class(LabResult).%New(
    "Hemoglobin",     // test name
    "12.5",           // value
    "g/dL",           // unit
    "12.0-16.0",      // reference range
    0                 // not abnormal
)

// Immutable measurement
Write result.Value  // "12.5"
Write result.GetSeverity()  // "Normal"

// Create modified copy with abnormal flag
Set abnormal = result.WithAbnormalFlag(1)
```

### Example 3: Medication Dosage
```objectscript
// Create dosage
Set dosage = ##class(Dosage).%New(
    "500",           // amount
    "mg",            // unit
    "twice daily",   // frequency
    "oral"           // route
)

// Calculate daily dose
Write dosage.CalculateDailyDose()  // "1000 mg/day"

// Create modified copy
Set newDosage = dosage.WithFrequency("three times daily")
```

### Example 4: Value Objects in Collections
```objectscript
// Store vital signs by time
Set measurements = ##class(%ArrayOfObjects).%New()

Set morning = ##class(VitalSigns).%New(98.6, 120, 80, 72, 16, 98)
Set evening = ##class(VitalSigns).%New(99.1, 125, 82, 78, 18, 97)

Do measurements.SetAt(morning, "08:00")
Do measurements.SetAt(evening, "20:00")

// Retrieve safely - immutability guarantees integrity
Set retrieved = measurements.GetAt("08:00")
Write retrieved.Temperature  // 98.6
```

## Consequences

### Benefits
1. **Thread Safety**: Immutable objects are inherently thread-safe, no synchronization needed
2. **No Aliasing Bugs**: Shared references can't cause unexpected side effects
3. **Simplicity**: No temporal coupling, order of operations doesn't matter
4. **Safe Sharing**: Can be freely passed and cached without defensive copying
5. **Hash Key Safety**: Can be used as hash map keys without breaking collections
6. **Predictability**: Values don't change unexpectedly, easier to reason about
7. **Testability**: Easy to create and compare in tests

### Liabilities
1. **Creation Overhead**: Must create new instance for each "modification"
2. **Memory Usage**: More objects created, though typically short-lived
3. **Circular References**: Difficult with cyclic object graphs
4. **Large Objects**: Expensive if value objects contain many properties
5. **Learning Curve**: Developers must learn copy-on-modify pattern

## Implementation Notes

### When to Use Value Objects vs Entities

| Criterion | Value Object | Entity |
|-----------|--------------|--------|
| Identity | No unique ID | Has unique ID |
| Equality | Based on values | Based on ID |
| Mutability | Immutable | Often mutable |
| Lifespan | Short-lived | Long-lived |
| Examples | Money, Date, Address | Person, Account, Order |
| Persistence | Embedded in Entity | Separate table/row |

### Collections and Hash Codes
When using value objects as hash map keys:
1. Equal objects MUST return same hash code
2. Hash code must be stable (never change)
3. Include all properties used in `Equals()`
4. Use good distribution algorithm

### Performance Considerations
1. **Small Objects**: Best for lightweight objects (< 10 properties)
2. **Caching**: Consider caching commonly-used values (e.g., Money(0))
3. **Builder Pattern**: For value objects with many properties, consider a Builder
4. **Pooling**: For very frequently created values, consider object pooling

## Related Patterns

- **Entity**: Contrasts with Value Object—has identity and mutability
- **Flyweight**: Can be used to share Value Object instances efficiently
- **Money Pattern**: Specialized Value Object for currency amounts
- **Quantity Pattern**: Value Object representing measurements with units
- **Range Pattern**: Value Object representing start/end boundaries
- **Embedded Value**: How to persist Value Objects in databases

## Known Uses

1. **Java**: `String`, `Integer`, `LocalDate` are immutable value objects
2. **C#**: `DateTime`, `TimeSpan`, `Decimal` are value types
3. **Python**: tuples, `datetime.date` are immutable
4. **Healthcare**: Vital signs, lab results, medication dosages, diagnoses
5. **Finance**: Money, interest rates, exchange rates
6. **Geometry**: Point, Rectangle, Color

## References

- Martin Fowler, "Patterns of Enterprise Application Architecture", Chapter on Value Object
- Eric Evans, "Domain-Driven Design", Chapter 5: A Model Expressed in Software
- Vernon, Vaughn, "Implementing Domain-Driven Design", Chapter 6: Value Objects

## See Also

- [Entity Pattern](../entity.md) - For objects with identity
- [Data Mapper Pattern](../data-mapper.md) - For persisting value objects
- [Identity Map Pattern](../identity-map.md) - Contrasts with value object sharing
- [Repository Pattern](../repository.md) - Works with both entities and value objects
