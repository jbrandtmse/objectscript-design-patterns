# Lazy Load Pattern

## Pattern Type
**Category:** Object-Relational Behavioral  
**Complexity:** Medium  
**Source:** Patterns of Enterprise Application Architecture (Fowler)

## Intent

An object that doesn't contain all of the data you need but knows how to get it. Defers initialization of an object or loading of data until the point at which it is first accessed.

## Also Known As

- Lazy Initialization
- Lazy Evaluation
- Deferred Loading

## Motivation

When loading an object from a database, you often have to decide how much data to load at once. Loading everything eagerly can be expensive, especially with complex object graphs containing many related objects. Lazy Load provides a way to defer loading expensive data until it's actually needed, improving performance for common use cases.

Consider a patient record in a healthcare system. The basic patient demographics (name, date of birth, MRN) are frequently accessed, but the complete medical history (thousands of lab results, imaging studies, medications) is only needed in specific scenarios. Loading all medical history upfront would be wasteful when you only need to display a patient list.

Lazy Load solves this by creating placeholder objects or using proxies that defer the expensive loading operation until the data is actually accessed.

## Applicability

Use Lazy Load when:

- Loading object data is expensive (network calls, database queries, large computations)
- The data may not be needed in all code paths
- You want to optimize performance by deferring expensive operations
- You can identify parts of an object graph that are infrequently accessed
- The application has performance bottlenecks due to over-eager loading

Don't use Lazy Load when:

- Data will always be needed (lazy loading adds overhead)
- Loading is already fast (premature optimization)
- You cannot tolerate the potential delay on first access
- The code complexity outweighs the performance benefit
- N+1 query problems would result from lazy loading in loops

## Structure

### Class Diagram

```
┌─────────────────────────────────────┐
│         <<abstract>>                │
│          LazyLoad                   │
├─────────────────────────────────────┤
│ + IsLoaded: Boolean                 │
├─────────────────────────────────────┤
│ + Load(): %Status                   │
│ + SetLoaded(Boolean): %Status       │
└─────────────────────────────────────┘
           △
           │
    ┌──────┴──────────┬─────────────────┐
    │                 │                 │
┌───┴────────┐  ┌─────┴──────┐  ┌──────┴────────┐
│VirtualProxy│  │GhostObject │  │  ValueHolder  │
├────────────┤  ├────────────┤  ├───────────────┤
│RealSubject │  │LoaderClass │  │Value          │
│LoaderClass │  │ObjectId    │  │LoaderClass    │
│LoaderId    │  ├────────────┤  │LoaderId       │
├────────────┤  │Load()      │  │LoaderMethod   │
│Load()      │  │Populate()  │  ├───────────────┤
│GetReal()   │  │Ensure()    │  │Load()         │
└────────────┘  └────────────┘  │GetValue()     │
                                 │SetValue()     │
                                 └───────────────┘
```

## Participants

### LazyLoad (Abstract Base)
- **Responsibility:** Defines the lazy loading interface
- **Collaborators:** None
- **Key Methods:**
  - `Load()`: Trigger deferred loading
  - `IsLoaded`: Check if data has been loaded
  - `SetLoaded()`: Mark as loaded

### VirtualProxy (Variant)
- **Responsibility:** Stands in for real object, loads on first access
- **Collaborators:** Real object, Loader
- **Key Methods:**
  - `GetRealSubject()`: Returns real object, loading if necessary
  - `HasRealSubject()`: Check if real object is loaded

### GhostObject (Variant)
- **Responsibility:** Real object with uninitialized state, loads on property access
- **Collaborators:** Loader
- **Key Methods:**
  - `EnsureLoaded()`: Guarantee data is loaded
  - `PopulateFromData()`: Fill properties from loaded data

### ValueHolder (Variant)
- **Responsibility:** Generic wrapper for any lazy-loaded value
- **Collaborators:** Loader
- **Key Methods:**
  - `GetValue()`: Returns value, loading if necessary
  - `SetValue()`: Set value directly (testing/caching)

## Collaborations

1. **Client → Virtual Proxy:**
   - Client requests operation on proxy
   - Proxy checks if real object is loaded
   - If not loaded, proxy triggers load
   - Proxy delegates to real object

2. **Client → Ghost Object:**
   - Client accesses ghost's property
   - Ghost checks if loaded
   - If not loaded, ghost triggers load
   - Ghost returns property value

3. **Client → Value Holder:**
   - Client calls GetValue()
   - Holder checks if value loaded
   - If not loaded, holder calls loader
   - Holder returns cached value

## Implementation

### Virtual Proxy Pattern

**Best for:** When you want a proxy object that loads the real object on demand

```objectscript
Class VirtualProxyPatient Extends %RegisteredObject
{
    Property PatientMRN As %String;
    Property MedicalHistory As %ListOfObjects [ Private ];
    Property MedicalHistoryLoaded As %Boolean [ InitialExpression = 0, Private ];
    
    Method GetMedicalHistory() As %ListOfObjects
    {
        // Lazy load on first access
        If '..MedicalHistoryLoaded {
            Set ..MedicalHistory = ##class(MedicalHistoryLazyLoader).LoadMedicalHistory(..PatientMRN)
            Set ..MedicalHistoryLoaded = 1
        }
        
        Quit ..MedicalHistory
    }
}
```

### Ghost Object Pattern

**Best for:** When you want the real object with delayed property loading

```objectscript
Class GhostPatient Extends GhostObject
{
    Property PatientId As %String;
    Property FirstName As %String [ Private ];
    
    Method FirstNameGet() As %String
    {
        // Load on first property access
        Do ..EnsureLoaded()
        Quit i%FirstName
    }
    
    Method PopulateFromData(pData As %RegisteredObject) As %Status
    {
        Set i%FirstName = pData.FirstName
        // ... populate other properties
        Quit $$$OK
    }
}
```

### Value Holder Pattern

**Best for:** Generic lazy loading without specialized proxy classes

```objectscript
// Using Value Holder
Set tHolder = ##class(ValueHolder).%New(
    "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
    "MRN123",
    "LoadLabResults"
)

// No load yet
Set tLabs = tHolder.GetValue()  // Triggers load
```

## Sample Code

### Healthcare Example: Lazy Loading Medical History

```objectscript
/// Create patient with lazy-loaded medical history
Set tPatient = ##class(VirtualProxyPatient).%New()
Set tPatient.PatientMRN = "MRN123"
Set tPatient.FirstName = "John"
Set tPatient.LastName = "Doe"

// No medical history loaded yet (fast)
// Patient can be displayed in a list without loading expensive data

// Later, when medical history is actually needed:
Set tHistory = tPatient.GetMedicalHistory()  // Triggers lazy load
Write "Loaded ", tHistory.Count(), " medical history records"

// Subsequent accesses use cached data (no reload)
Set tHistory2 = tPatient.GetMedicalHistory()  // No database hit
```

### Performance Comparison

```objectscript
/// Demonstrate performance benefit
Set tMetrics = ##class(VirtualProxyPatient).DemonstratePerformanceBenefit()

// Scenario 1: Only demographics needed (common case)
// Lazy loading: 10ms (no history loaded)
// Eager loading: 450ms (loaded everything)
// Improvement: 88% faster

// Scenario 2: Demographics + labs only
// Lazy loading: 60ms (only labs loaded)
// Eager loading: 450ms (loaded everything)
// Improvement: 87% faster
```

## Known Uses

### InterSystems IRIS
- **Lazy Loading of Relationships:** IRIS automatically lazy-loads one-to-many relationships in persistent classes
- **Stream Properties:** Large text/binary data in stream properties is lazy-loaded
- **SQL Projections:** Complex SQL joins can be lazy-loaded to avoid expensive operations

### Healthcare Systems
- **Patient Medical History:** Defer loading complete history until needed
- **Lab Results:** Load thousands of lab results only when accessed
- **Imaging Studies:** Defer loading large imaging data and metadata
- **Medication History:** Load medication list on demand

### Enterprise Applications
- **Order Details:** Load order line items only when viewing order
- **Document Attachments:** Defer loading large attachments
- **Audit Trails:** Load audit history only when explicitly requested
- **Related Entities:** Lazy-load navigation properties in ORMs

## Consequences

### Benefits

1. **Improved Performance:** Defers expensive operations until needed
2. **Reduced Memory Usage:** Loads only what's necessary
3. **Faster Initial Load:** Quick object creation without full data
4. **Transparent to Clients:** Loading happens automatically
5. **Flexible Loading Strategies:** Can mix eager and lazy loading

### Liabilities

1. **Complexity:** Adds code complexity with proxies/holders
2. **Potential Delays:** First access may be slower than expected
3. **N+1 Query Problem:** Lazy loading in loops can cause many database hits
4. **Hidden Dependencies:** Not obvious when database access occurs
5. **Debugging Difficulty:** Harder to trace when loads happen
6. **Thread Safety:** Concurrent access requires careful handling

### Performance Considerations

- **Measure First:** Profile before optimizing with lazy loading
- **Batch Loading:** Consider loading multiple related objects together
- **Cache Loaded Data:** Don't reload on subsequent access
- **Avoid N+1:** Be careful with lazy loading in loops
- **Mixed Strategy:** Use eager loading for frequently accessed data

## Variants

### 1. Virtual Proxy
- **Description:** Proxy object that loads real object on demand
- **Pros:** Clean separation, real object unchanged
- **Cons:** Extra object overhead, must implement proxy interface

### 2. Ghost Object
- **Description:** Real object with uninitialized state
- **Pros:** No proxy overhead, IS the real object
- **Cons:** Requires property getter interception

### 3. Value Holder
- **Description:** Generic wrapper for any lazy value
- **Pros:** Reusable, no specialized proxies needed
- **Cons:** Less type-safe, wrapper indirection

### 4. Lazy Initialization
- **Description:** Object initializes data on first use
- **Pros:** Simple, no proxies or holders
- **Cons:** Initialization code in domain object

## Related Patterns

### Complementary Patterns

- **Identity Map:** Prevents duplicate loading of same object
- **Data Mapper:** Provides loading logic for lazy load
- **Unit of Work:** Coordinates lazy loading with transactions
- **Repository:** Encapsulates lazy loading strategy

### Alternative Patterns

- **Eager Loading:** Load everything upfront (simpler but slower)
- **Batch Fetching:** Load multiple objects at once
- **Explicit Loading:** Client explicitly requests loading

## Testing Strategy

### Unit Tests

```objectscript
Method TestVirtualProxyDelaysLoading() As %Status
{
    // Arrange
    Set tProxy = ##class(VirtualProxy).%New("LoaderClass", "ID123")
    
    // Assert - Creating proxy doesn't trigger load
    Do $$$AssertEquals(tProxy.IsLoaded, 0, "Should not be loaded")
    
    // Act - Access triggers load
    Set tReal = tProxy.GetRealSubject()
    
    // Assert - Now loaded
    Do $$$AssertEquals(tProxy.IsLoaded, 1, "Should be loaded")
    
    Quit $$$OK
}
```

### Performance Tests

```objectscript
Method TestPerformanceImprovement() As %Status
{
    // Measure lazy loading time
    Set tStart = $HOROLOG
    Set tPatient = ##class(VirtualProxyPatient).%New()
    Set tPatient.PatientMRN = "MRN123"
    Set tLazyTime = $HOROLOG - tStart
    
    // Compare to eager loading
    Set tStart = $HOROLOG
    Set tHistory = ##class(Loader).LoadMedicalHistory("MRN123")
    Set tLabs = ##class(Loader).LoadLabResults("MRN123")
    Set tEagerTime = $HOROLOG - tStart
    
    // Assert improvement
    Do $$$AssertTrue(tLazyTime < tEagerTime, "Lazy should be faster")
    
    Quit $$$OK
}
```

## See Also

- [Identity Map Pattern](identity-map.md) - Prevents duplicate loads
- [Data Mapper Pattern](data-mapper.md) - Provides loading logic
- [Unit of Work Pattern](../data-source/unit-of-work.md) - Transaction coordination
- [Repository Pattern](repository.md) - Encapsulates data access

## References

1. Fowler, Martin. *Patterns of Enterprise Application Architecture*. Addison-Wesley, 2002.
   - Chapter: "Lazy Load" (pages 200-214)
   - Discusses all four variants in detail

2. Gamma, Erich, et al. *Design Patterns: Elements of Reusable Object-Oriented Software*. Addison-Wesley, 1994.
   - "Proxy Pattern" (pages 207-217)
   - Foundation for Virtual Proxy variant

3. InterSystems IRIS Documentation
   - "Working with Relationships"
   - "Lazy Loading in IRIS Objects"

## Implementation Notes

### ObjectScript-Specific Considerations

1. **Property Getters:** Use property getter methods for Ghost Object pattern
2. **$CLASSMETHOD:** Dynamic class method calls for flexible loaders
3. **Object References:** Check with $IsObject() before accessing
4. **Status Returns:** Use %Status for error handling in Load() methods
5. **Private Properties:** Hide internal state with Private keyword

### Healthcare Domain Considerations

1. **HIPAA Compliance:** Lazy loading shouldn't bypass security checks
2. **Audit Trails:** Log when sensitive data is lazy-loaded
3. **Performance:** Medical history can be very large, lazy loading is critical
4. **Real-time Systems:** Consider impact of load delays in critical workflows

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-10 | Initial implementation with all variants |
