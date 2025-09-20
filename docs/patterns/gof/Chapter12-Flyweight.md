# Chapter 12: Flyweight Pattern

## Intent
Use sharing to support large numbers of fine-grained objects efficiently.

## Also Known As
- Cache
- Token

## Motivation

Consider a document editor that needs to represent each character in a document as an object. This would allow the application to treat characters uniformly and support advanced formatting features. However, a naive implementation would require enormous amounts of memory - a document with 100,000 characters would need 100,000 character objects.

The Flyweight pattern describes how to share objects to allow their use at fine granularities without prohibitive memory cost. A flyweight is a shared object that can be used in multiple contexts simultaneously. The key is the distinction between intrinsic and extrinsic state:

- **Intrinsic state** is stored in the flyweight and consists of information that's independent of the flyweight's context. This makes it sharable.
- **Extrinsic state** depends on and varies with the flyweight's context and therefore can't be shared. Client objects pass extrinsic state to the flyweight when they invoke its operations.

## Applicability

Apply the Flyweight pattern when ALL of the following are true:

- An application uses a large number of objects
- Storage costs are high because of the sheer quantity of objects
- Most object state can be made extrinsic
- Many groups of objects may be replaced by relatively few shared objects once extrinsic state is removed
- The application doesn't depend on object identity (since flyweight objects may be shared, identity tests will return true for conceptually distinct objects)

## Structure

```
                ┌──────────────────────┐
                │   FlyweightFactory   │
                ├──────────────────────┤
                │ - flyweights         │
                ├──────────────────────┤
                │ + GetFlyweight(key)  │
                └──────────────────────┘
                            │ creates/manages
                            ▼
                    ┌──────────────┐
                    │  Flyweight   │
                    ├──────────────┤
                    │              │
                    ├──────────────┤
                    │ + Operation( │
                    │   extrinsic) │
                    └──────────────┘
                            △
                            │
            ┌───────────────┴───────────────┐
            │                               │
    ┌──────────────────┐         ┌──────────────────────┐
    │ ConcreteFlyweight│         │UnsharedConcreteFlyweight│
    ├──────────────────┤         ├──────────────────────┤
    │ - intrinsicState │         │ - allState            │
    ├──────────────────┤         ├──────────────────────┤
    │ + Operation(     │         │ + Operation(          │
    │   extrinsic)     │         │   extrinsic)          │
    └──────────────────┘         └──────────────────────┘
            △
            │ shared by
    ┌──────────────┐
    │    Client    │
    └──────────────┘
```

## Participants

### Flyweight
- Declares an interface through which flyweights can receive and act on extrinsic state

### ConcreteFlyweight
- Implements the Flyweight interface and adds storage for intrinsic state, if any
- Must be sharable - any state it stores must be intrinsic (independent of context)

### UnsharedConcreteFlyweight
- Not all Flyweight subclasses need to be shared
- The Flyweight interface enables sharing but doesn't enforce it
- Commonly has ConcreteFlyweight objects as children at some level

### FlyweightFactory
- Creates and manages flyweight objects
- Ensures that flyweights are shared properly
- When a client requests a flyweight, returns an existing instance or creates one if none exists

### Client
- Maintains references to flyweights
- Computes or stores extrinsic state of flyweights

## Collaborations

- State that a flyweight needs to function must be characterized as either intrinsic or extrinsic
- Intrinsic state is stored in the ConcreteFlyweight object
- Extrinsic state is stored or computed by Client objects
- Clients pass extrinsic state to the flyweight when they invoke its operations
- Clients should not instantiate ConcreteFlyweights directly - they must obtain them from the FlyweightFactory

## Consequences

### Benefits

1. **Storage Savings**: The reduction in storage comes from:
   - Reducing the total number of instances through sharing
   - Reducing the amount of intrinsic state per object
   - Computing extrinsic state rather than storing it

2. **Memory Efficiency**: Most effective when objects contain substantial amounts of both intrinsic and extrinsic state, and the extrinsic state can be computed

### Liabilities

1. **Runtime Costs**: May introduce runtime costs for transferring, finding, and/or computing extrinsic state
2. **Complexity**: The pattern complicates the code structure

## Implementation

### Implementation Issues

1. **Removing Extrinsic State**: The pattern's applicability depends on how easy it is to identify and remove extrinsic state from objects

2. **Managing Shared Objects**: Objects are shared using a pool or registry. The FlyweightFactory uses an associative array to find existing instances quickly

3. **Computing Extrinsic State**: Consider the trade-off between storage and computation time when determining whether to compute or store extrinsic state

### ObjectScript-Specific Considerations

1. **Global-Based Pool Management**: ObjectScript globals provide an ideal persistent storage mechanism for flyweight pools
   ```objectscript
   // Store flyweights in globals
   Set ^Patterns.Flyweight.Pool(key) = flyweightObject
   ```

2. **Reference Counting**: Track usage to enable cleanup of unused flyweights
   ```objectscript
   Property ReferenceCount As %Integer;
   
   Method IncrementReference() As %Integer
   {
       Set ..ReferenceCount = ..ReferenceCount + 1
       Quit ..ReferenceCount
   }
   ```

3. **Memory Efficiency Measurement**: Calculate actual memory savings
   ```objectscript
   Method GetMemoryEstimate() As %Integer
   {
       // Calculate size of extrinsic state only
       // Intrinsic state cost is amortized across all clients
   }
   ```

## Sample Code

### Basic Flyweight Pattern Implementation

```objectscript
/// Base Flyweight class
Class Patterns.GoF.Structural.Flyweight Extends %RegisteredObject [ Abstract ]
{
    Property IntrinsicState As %String;
    
    Method Operation(pExtrinsicState As %String) As %String [ Abstract ]
    {
        Quit ""
    }
}

/// Concrete Flyweight with shared intrinsic state
Class Patterns.GoF.Structural.ConcreteFlyweight Extends Flyweight
{
    Property SharedData As %String;
    Property ReferenceCount As %Integer [ InitialExpression = 0 ];
    
    Method Operation(pExtrinsicState As %String) As %String
    {
        Set tResult = "ConcreteFlyweight: ["
        Set tResult = tResult_"Intrinsic='"_..IntrinsicState_"'"
        Set tResult = tResult_"] + Extrinsic='"_pExtrinsicState_"'"
        Quit tResult
    }
}

/// Factory managing the flyweight pool
Class Patterns.GoF.Structural.FlyweightFactory
{
    Property FlyweightPool [ MultiDimensional ];
    
    Method GetFlyweight(pKey As %String) As ConcreteFlyweight
    {
        // Check if flyweight exists
        If $DATA(..FlyweightPool(pKey)) {
            Set tFlyweight = ..FlyweightPool(pKey)
            Do tFlyweight.IncrementReference()
        }
        Else {
            // Create new flyweight
            Set tFlyweight = ##class(ConcreteFlyweight).%New(pKey)
            Set ..FlyweightPool(pKey) = tFlyweight
        }
        Quit tFlyweight
    }
}
```

### Healthcare Example - Medication Reference System

```objectscript
/// Medication as Flyweight (intrinsic state)
Class Patterns.Examples.Medication Extends Flyweight
{
    Property DrugName As %String;
    Property GenericName As %String;
    Property DrugClass As %String;
    Property Interactions As %String;
    
    Method Operation(pExtrinsicState As %String) As %String
    {
        // Parse extrinsic state: "PatientID|Dosage|Frequency"
        Set tPatientID = $PIECE(pExtrinsicState, "|", 1)
        Set tDosage = $PIECE(pExtrinsicState, "|", 2)
        Set tFrequency = $PIECE(pExtrinsicState, "|", 3)
        
        Set tResult = "Prescription: "_..DrugName
        Set tResult = tResult_" for Patient "_tPatientID
        Set tResult = tResult_", "_tDosage_", "_tFrequency
        Quit tResult
    }
}

/// Prescribed Medication Context (extrinsic state)
Class Patterns.Examples.PrescribedMedication
{
    Property PatientID As %String;      // Extrinsic
    Property Medication As Medication;   // Reference to flyweight
    Property Dosage As %String;         // Extrinsic
    Property Frequency As %String;      // Extrinsic
    
    Method Display() As %String
    {
        Set tExtrinsic = ..PatientID_"|"_..Dosage_"|"_..Frequency
        Quit ..Medication.Operation(tExtrinsic)
    }
}

/// Factory with global-based pool
Class Patterns.Examples.MedicationFactory
{
    ClassMethod GetMedication(pName As %String) As Medication
    {
        If $DATA(^Patterns.Examples.MedicationPool(pName)) {
            Set tMedication = ^Patterns.Examples.MedicationPool(pName)
            Set ^Patterns.Examples.MedicationStats("Hits") = 
                $GET(^Patterns.Examples.MedicationStats("Hits"), 0) + 1
        } Else {
            Set tMedication = ##class(Medication).%New(pName)
            Set ^Patterns.Examples.MedicationPool(pName) = tMedication
            Set ^Patterns.Examples.MedicationStats("Misses") = 
                $GET(^Patterns.Examples.MedicationStats("Misses"), 0) + 1
        }
        Quit tMedication
    }
}
```

### Usage Example

```objectscript
// Load standard medications
Do ##class(MedicationFactory).LoadStandardMedications()

// Create prescriptions - medications are shared
Set prescription1 = ##class(PrescribedMedication).%New("P001", "Aspirin")
Set prescription1.Dosage = "81mg"
Set prescription1.Frequency = "Once daily"

Set prescription2 = ##class(PrescribedMedication).%New("P002", "Aspirin")
Set prescription2.Dosage = "325mg"
Set prescription2.Frequency = "Twice daily"

// Both prescriptions share the same Aspirin medication object
Write prescription1.Medication = prescription2.Medication  // 1 (true)

// Memory savings demonstration
Write ##class(MedicationFactory).DemonstrateMemorySavings()
// Output: Total Prescriptions=1000, Memory Saved=180000 bytes (64.3%)
```

## Known Uses

1. **Document Editors**: Character and glyph objects in text processing systems
2. **Game Development**: Shared terrain tiles, textures, and sprites
3. **Graphical User Interfaces**: Icon and image management
4. **Compiler Symbol Tables**: Sharing string literals and identifiers
5. **Healthcare Systems**: Reference data like medications, procedures, diagnoses

## Related Patterns

### Composite
- The Flyweight pattern is often combined with Composite to implement a hierarchical structure as a graph with shared leaf nodes

### State and Strategy
- Flyweight objects can be shared State or Strategy objects when they don't contain instance-specific state

### Singleton
- The FlyweightFactory often uses Singleton to ensure a single instance manages the pool

### Factory Method
- The FlyweightFactory uses Factory Method to create new flyweight instances

## ObjectScript Global Usage Documentation

### Global Structure for Flyweight Pools

ObjectScript globals provide persistent, efficient storage for flyweight pools:

```objectscript
// Pool structure
^Patterns.Flyweight.Pool(key) = objectReference
^Patterns.Flyweight.Pool("Key1") = <OREF>
^Patterns.Flyweight.Pool("Key2") = <OREF>

// Statistics tracking
^Patterns.Flyweight.Stats("Hits") = hitCount
^Patterns.Flyweight.Stats("Misses") = missCount
^Patterns.Flyweight.Stats("LastCleanup") = timestamp
```

### Benefits of Global-Based Caching

1. **Persistence**: Flyweights survive process termination
2. **Sharing Across Sessions**: Multiple processes can share the same pool
3. **Atomic Operations**: Global operations are inherently thread-safe
4. **Efficient Indexing**: Direct key-based access with O(1) complexity
5. **Memory Management**: Globals handle memory allocation automatically

### Cleanup and Maintenance

```objectscript
// Cleanup stale references
ClassMethod CleanupGlobalPool() As %Status
{
    Set tKey = ""
    For {
        Set tKey = $ORDER(^Patterns.Flyweight.Pool(tKey))
        Quit:tKey=""
        
        Set tOREF = ^Patterns.Flyweight.Pool(tKey)
        If '$ISOBJECT(tOREF) {
            Kill ^Patterns.Flyweight.Pool(tKey)
        }
    }
    Quit $$$OK
}
```

### Performance Considerations

- Global access is faster than object instantiation
- Pool hits avoid object creation overhead
- Trade-off between lookup time and memory savings
- Consider pool size limits for bounded caching
