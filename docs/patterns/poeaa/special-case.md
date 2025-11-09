# Special Case Pattern

## Intent

Provide a polymorphic alternative to null checking by creating special case objects that implement the same interface as real objects but provide default behaviors.

## Also Known As

- Null Object
- Active Nothing
- Stub Object

## Motivation

Null checking clutters code and is error-prone. Clients constantly checking for null references create conditional logic throughout the codebase. Special Case objects eliminate null checks by providing safe default behaviors that clients can call without conditionals.

Consider a clinical system that processes patient records:

```objectscript
// Before: Null checks everywhere
Method ProcessPatient(pPatient As Patient) As %Status
{
    If '$IsObject(pPatient) {
        Write "No patient to process"
        Quit $$$OK
    }
    
    Set tName = pPatient.GetDisplayName()
    Set tMRN = pPatient.GetMRN()
    // ... more processing
}

// After: No null checks needed
Method ProcessPatient(pPatient As Patient) As %Status
{
    // Works with real patient or null object
    Set tName = pPatient.GetDisplayName()  // Returns "Unknown Patient" for null
    Set tMRN = pPatient.GetMRN()  // Returns "UNKNOWN" for null
    // ... more processing
}
```

The Special Case pattern uses polymorphism to eliminate these checks.

## Applicability

Use the Special Case pattern when:

- Many clients check for null and execute the same default behavior
- Null objects need to behave polymorphically with real objects
- You want to eliminate conditional logic for missing data
- Default behaviors are well-defined and stable
- Operations on null should be no-ops that don't fail

## Structure

### Class Diagram

```
SpecialCase (abstract)
    + IsNull(): %Boolean
    + IsSpecialCase(): %Boolean
    + SafeNavigate(): SpecialCase
    + CreateNullObject(): SpecialCase
    + CreateUnknownCase(): SpecialCase
    + CreateDefaultCase(): SpecialCase
    
NullObject extends SpecialCase
    + IsNull(): %Boolean (returns 1)
    + Execute(): %Status (no-op)
    + Save(): %Status (no-op)
    + Delete(): %Status (no-op)
    
UnknownCase extends SpecialCase
    + IsNull(): %Boolean (returns 0)
    + GetDisplayLabel(): %String
    + Execute(): %Status
    
DefaultCase extends SpecialCase
    + IsNull(): %Boolean (returns 0)
    + IsDefault(): %Boolean (returns 1)
    + GetDefaultValue(): %String
    + GetDefaultNumeric(): %Numeric
```

### Participants

- **SpecialCase** - Abstract base defining the special case interface
- **NullObject** - Represents null references with no-op behaviors
- **UnknownCase** - Represents unknown or missing data with safe defaults
- **DefaultCase** - Provides default values and behaviors
- **Client** - Uses special cases without null checking

## Implementation

### Basic Special Case Pattern

```objectscript
Class Patterns.PoEAA.Base.SpecialCase Extends %RegisteredObject [ Abstract ]
{
    Method IsNull() As %Boolean
    {
        Quit 0
    }
    
    Method IsSpecialCase() As %Boolean
    {
        Quit 1
    }
    
    Method SafeNavigate() As SpecialCase
    {
        Quit $this
    }
}
```

### Null Object Variant

```objectscript
Class Patterns.PoEAA.Base.NullObject Extends SpecialCase
{
    Method IsNull() As %Boolean
    {
        Quit 1
    }
    
    Method Execute() As %Status
    {
        // No-op for null object
        Quit $$$OK
    }
    
    Method Save() As %Status
    {
        // No-op - don't persist
        Quit $$$OK
    }
    
    ClassMethod CreateNullObject() As NullObject
    {
        Quit ..%New()
    }
}
```

### Unknown Case Variant

```objectscript
Class Patterns.PoEAA.Base.UnknownCase Extends SpecialCase
{
    Parameter UNKNOWNLABEL = "Unknown";
    
    Method IsNull() As %Boolean
    {
        Quit 0
    }
    
    Method GetDisplayLabel() As %String
    {
        Quit ..#UNKNOWNLABEL
    }
    
    ClassMethod CreateUnknownCase() As UnknownCase
    {
        Quit ..%New()
    }
}
```

### Default Case Variant

```objectscript
Class Patterns.PoEAA.Base.DefaultCase Extends SpecialCase
{
    Method IsNull() As %Boolean
    {
        Quit 0
    }
    
    Method IsDefault() As %Boolean
    {
        Quit 1
    }
    
    Method GetDefaultValue() As %String
    {
        Quit ""
    }
    
    Method GetDefaultNumeric() As %Numeric
    {
        Quit 0
    }
}
```

## Sample Code

### Healthcare Example: Unknown Patient Handling

```objectscript
/// Null Patient - eliminates null checks in clinical workflows
Class Patterns.Examples.Clinical.NullPatient Extends Patient
{
    Method %OnNew() As %Status
    {
        Set ..FirstName = ""
        Set ..LastName = ""
        Set ..MRN = "UNKNOWN"
        Set ..Gender = "U"
        Quit $$$OK
    }
    
    Method IsNull() As %Boolean
    {
        Quit 1
    }
    
    Method GetDisplayName() As %String
    {
        Quit "Unknown Patient"
    }
    
    Method GetMRN() As %String
    {
        Quit "UNKNOWN"
    }
}

/// Unknown Patient - for walk-in emergency patients
Class Patterns.Examples.Clinical.UnknownPatient Extends Patient
{
    Parameter TEMPMRNPREFIX = "TEMP-";
    
    Method %OnNew() As %Status
    {
        Set ..FirstName = "Unregistered"
        Set ..LastName = "Patient"
        Set ..MRN = ..GenerateTemporaryMRN()
        Set ..Department = "Emergency"
        Quit $$$OK
    }
    
    Method GetDisplayName() As %String
    {
        Quit "Unregistered Patient"
    }
    
    ClassMethod GenerateTemporaryMRN() As %String
    {
        Set tSequence = $INCREMENT(^Patterns.TempMRNSequence)
        Quit ..#TEMPMRNPREFIX _ tSequence
    }
    
    Method NeedsRegistration() As %Boolean
    {
        Quit 1
    }
}
```

### Client Code Without Null Checks

```objectscript
/// Process patient admission - works with all patient types
Method AdmitPatient(pPatient As Patient) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // No null check needed - works with null/unknown/real patients
        Set tName = pPatient.GetDisplayName()
        Set tMRN = pPatient.GetMRN()
        
        // Log admission
        Do ..LogAdmission(tMRN, tName)
        
        // Check if needs registration
        If pPatient.NeedsRegistration() {
            Do ..QueueForRegistration(pPatient)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}
```

## When to Use

### Use Special Case When:

1. **Frequent Null Checks** - Code has many null checks with same behavior
2. **Polymorphic Behavior** - Null objects should behave like real objects
3. **Safe Defaults** - Default behaviors are well-defined
4. **Client Simplification** - Want to eliminate conditional logic
5. **No-Op Operations** - Operations on null should silently succeed

### Example Use Cases:

- **Unknown Patients** - Walk-in emergency patients without registration
- **Missing Configuration** - Default configuration when none provided
- **Optional Dependencies** - Components that may not be available
- **Empty Collections** - Null collection replaced with empty one
- **Logging** - Null logger for when logging disabled

## When Not to Use

### Avoid Special Case When:

1. **Error Signaling** - Null should indicate an error condition
2. **Varied Behaviors** - Different clients need different null behaviors
3. **State Changes** - Null state needs to be tracked or modified
4. **Complex Logic** - Null handling requires complex decision making
5. **Type Safety** - Need to distinguish null from valid objects

### Anti-Patterns:

- Using special case to hide errors that should be reported
- Creating many special case variants for similar purposes
- Special cases with complex state or behavior
- Using when explicit null checks are clearer

## Defensive Programming Benefits

The Special Case pattern enhances defensive programming by:

1. **Eliminating Null Pointer Errors** - No null references to check
2. **Fail-Safe Defaults** - Safe behaviors prevent crashes
3. **Reduced Conditional Logic** - Simpler, more maintainable code
4. **Polymorphic Safety** - All objects treated uniformly
5. **Clear Intent** - Special cases explicitly identify their nature

### Comparison with Explicit Null Checks

```objectscript
// Explicit Null Checks (error-prone)
Method ProcessOrder(pPatient As Patient) As %Status
{
    If '$IsObject(pPatient) {
        Write "Error: Patient is null"
        Quit $$$ERROR($$$GeneralError, "Null patient")
    }
    
    Set tMRN = pPatient.GetMRN()
    If tMRN = "" {
        Write "Error: MRN is empty"
        Quit $$$ERROR($$$GeneralError, "Empty MRN")
    }
    
    // Process order...
}

// Special Case Pattern (defensive)
Method ProcessOrder(pPatient As Patient) As %Status
{
    // No null checks - safe with null patient
    Set tMRN = pPatient.GetMRN()  // Returns "UNKNOWN" for null
    
    // Check if special case
    If pPatient.IsSpecialCase() {
        Do ..LogSpecialCase(pPatient)
    }
    
    // Process order safely...
}
```

## Collaborations

- **Client** creates or receives special case objects
- **Factory** creates appropriate special case variants
- **Client** calls methods without null checking
- **Special Case** provides safe default behaviors
- **Client** optionally checks IsNull() or IsSpecialCase() for special handling

## Consequences

### Benefits:

1. **Eliminates Null Checks** - Cleaner, more readable code
2. **Fail-Safe Behavior** - No null pointer exceptions
3. **Polymorphism** - Uniform treatment of all objects
4. **Client Simplification** - Less conditional logic
5. **Clear Intent** - Special cases explicitly identified

### Liabilities:

1. **Hidden Nulls** - May mask problems that should be errors
2. **Extra Classes** - More classes in the system
3. **Behavior Definition** - Must define appropriate defaults
4. **Testing Complexity** - Must test both real and special cases
5. **Memory Overhead** - Objects instead of null references

## Known Uses

1. **Collections Framework** - Empty collections instead of null
2. **Logging Systems** - Null logger when logging disabled
3. **UI Components** - Null widgets for optional elements
4. **Healthcare Systems** - Unknown patients in emergency departments
5. **Configuration Management** - Default configuration objects

## Related Patterns

- **Strategy Pattern** - Special case can use strategy for behavior
- **State Pattern** - Special case represents a particular state
- **Proxy Pattern** - Null object is a type of proxy
- **Factory Method** - Creates appropriate special case variants
- **Template Method** - Special cases implement template methods

## Implementation Considerations

### Performance

- Special case objects may have memory overhead vs null
- Consider caching/reusing special case instances
- Profile to ensure acceptable performance

### Threading

- Special cases are typically immutable
- Thread-safe by design if no mutable state
- Can be shared across threads safely

### Persistence

- Null objects typically should not be persisted
- Consider how to handle special cases in database
- May need special serialization logic

### Testing

```objectscript
Class SpecialCaseTest Extends %UnitTest.TestCase
{
    Method TestNullObjectEliminatesChecks()
    {
        Set tNull = ##class(NullPatient).%New()
        
        // No null check needed
        Set tName = tNull.GetDisplayName()
        Do $$$AssertEquals(tName, "Unknown Patient")
        
        // Verify null identification
        Do $$$AssertTrue(tNull.IsNull())
    }
    
    Method TestPolymorphicBehavior()
    {
        Set tReal = ##class(Patient).%New()
        Set tNull = ##class(NullPatient).%New()
        
        // Both can be processed identically
        Do ..ProcessPatient(tReal)
        Do ..ProcessPatient(tNull)
    }
}
```

## See Also

- [Value Object Pattern](value-object.md) - Special cases can be value objects
- [Money Pattern](money.md) - Example of using special cases for currency
- Factory Method Pattern - Creating special case instances
- Strategy Pattern - Behavior variation in special cases
