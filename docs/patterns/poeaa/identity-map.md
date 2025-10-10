# Identity Map Pattern

## Pattern Type
**Object-Relational Behavioral Pattern** from Martin Fowler's *Patterns of Enterprise Application Architecture*

## Intent
Ensures that each object gets loaded only once by keeping every loaded object in a map. Looks up objects using the map when referring to them.

## Also Known As
- Object Cache
- Entity Cache
- First-Level Cache

## Motivation

### The Problem
In enterprise applications, multiple parts of the code often need to access the same domain objects. Without a coordinating mechanism:

1. **Multiple Database Reads**: Each access loads the object from the database, causing unnecessary I/O
2. **Multiple In-Memory Copies**: The same logical object exists in multiple variables with different identities
3. **Synchronization Issues**: Updates to one copy don't reflect in other copies
4. **Lost Updates**: Changes made to one copy can overwrite changes to another
5. **Transactional Inconsistency**: Within a transaction, different parts see different states

```objectscript
// WITHOUT Identity Map - Problems
Set patient1 = ##class(PatientMapper).Load("123")
Set patient2 = ##class(PatientMapper).Load("123")  // Loads again!

// These are DIFFERENT objects with DIFFERENT identities
Write patient1 = patient2  // Writes 0 (different objects)

// Update one instance
Set patient1.FirstName = "John"
// patient2 still has old value!
Write patient2.FirstName  // Writes old value
```

### The Solution
The Identity Map maintains a cache of all loaded objects indexed by their identifier. When an object is requested:

1. **Check the map first** - Is the object already loaded?
2. **Return cached instance** - If yes, return the existing object
3. **Load and cache** - If no, load from database and add to map

This guarantees that within a scope (transaction, request, session), there is only **one instance** per unique identifier.

```objectscript
// WITH Identity Map - Single Instance
Set map = ##class(IdentityMap).%New()

Set patient1 = map.GetOrLoad("123", "PatientMapper")
Set patient2 = map.GetOrLoad("123", "PatientMapper")  // Returns cached!

// These are the SAME object with SAME identity
Write patient1 = patient2  // Writes 1 (identical)

// Update is reflected everywhere
Set patient1.FirstName = "John"
Write patient2.FirstName  // Writes "John"
```

## Applicability

### Use Identity Map When:
- ✅ You need to ensure a single in-memory representation per database row
- ✅ Multiple parts of your code access the same domain objects
- ✅ You want reference equality for domain objects (same ID = same instance)
- ✅ You need to reduce redundant database calls
- ✅ You're implementing Unit of Work or Data Mapper patterns
- ✅ You need consistent object state within a transaction/request

### Don't Use Identity Map When:
- ❌ Objects are read-only and never updated
- ❌ Objects are very large and caching would consume too much memory
- ❌ Object lifetime is shorter than the cache scope
- ❌ You need different views of the same data
- ❌ Distributed systems where cache coherence is complex

## Structure

### Class Diagram
```
┌─────────────────────────────┐
│     IdentityMap             │
├─────────────────────────────┤
│ - Cache: %ArrayOfObjects    │
│ - Size: %Integer            │
│ - HitCount: %Integer        │
│ - MissCount: %Integer       │
├─────────────────────────────┤
│ + Add(pId, pObject)         │
│ + Get(pId): Object          │
│ + Contains(pId): %Boolean   │
│ + Remove(pId)               │
│ + Clear()                   │
│ + GetOrLoad(pId, pLoader)   │
│ + GetStatistics()           │
└─────────────────────────────┘
         △
         │ extends
         │
┌─────────────────────────────┐
│  PatientIdentityMap         │
├─────────────────────────────┤
│ + GetOrLoadPatient(pId)     │
│ + InvalidatePatient(pId)    │
│ + WarmCache(pIds)           │
│ + ClearSession()            │
└─────────────────────────────┘
```

### Sequence Diagram - GetOrLoad Operation
```
Client          IdentityMap        DataMapper         Database
  │                  │                   │                │
  │──GetOrLoad(id)──>│                   │                │
  │                  │                   │                │
  │                  │──Check Cache──>   │                │
  │                  │   (Get)           │                │
  │                  │                   │                │
  │                  │<─Cache Miss───    │                │
  │                  │                   │                │
  │                  │──Load(id)───────>│                │
  │                  │                   │──SELECT────────>│
  │                  │                   │<───Result───────│
  │                  │<──Object──────────│                │
  │                  │                   │                │
  │                  │──Add(id,obj)──>   │                │
  │                  │                   │                │
  │<──Object─────────│                   │                │
  │                  │                   │                │
  │──GetOrLoad(id)──>│                   │                │
  │                  │──Check Cache──>   │                │
  │                  │<──Cache Hit───    │                │
  │<──Object─────────│                   │                │
  │   (same instance)│                   │                │
```

## Implementation

### Basic Identity Map (ObjectScript)

```objectscript
Class Patterns.PoEAA.ObjectRelational.IdentityMap Extends %RegisteredObject
{
    Property Cache As %ArrayOfObjects;
    Property Size As %Integer [ InitialExpression = 0 ];
    Property HitCount As %Integer [ InitialExpression = 0 ];
    Property MissCount As %Integer [ InitialExpression = 0 ];

    Method %OnNew() As %Status
    {
        Set ..Cache = ##class(%ArrayOfObjects).%New()
        Quit $$$OK
    }

    Method Add(pId As %String, pObject As %RegisteredObject) As %Status
    {
        Set tSC = $$$OK
        Try {
            If (pId = "") {
                Set tSC = $$$ERROR($$$GeneralError, "ID cannot be empty")
                Quit
            }
            
            Set tExists = ..Cache.IsDefined(pId)
            Do ..Cache.SetAt(pObject, pId)
            
            If 'tExists {
                Set ..Size = ..Size + 1
            }
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }

    Method Get(pId As %String) As %RegisteredObject
    {
        Set tObject = ""
        Try {
            If ..Cache.IsDefined(pId) {
                Set tObject = ..Cache.GetAt(pId)
                Set ..HitCount = ..HitCount + 1
            } Else {
                Set ..MissCount = ..MissCount + 1
            }
        } Catch ex {
            Set tObject = ""
        }
        Quit tObject
    }

    Method GetOrLoad(pId As %String, pLoaderClass As %String) As %RegisteredObject
    {
        Set tObject = ..Get(pId)
        
        If '$IsObject(tObject) {
            Set tObject = $CLASSMETHOD(pLoaderClass, "Load", pId)
            If $IsObject(tObject) {
                Do ..Add(pId, tObject)
            }
        }
        
        Quit tObject
    }
}
```

### Healthcare Example - Patient Identity Map

```objectscript
Class Patterns.Examples.Clinical.PatientIdentityMap 
    Extends Patterns.PoEAA.ObjectRelational.IdentityMap
{
    Parameter SCOPE = "Session";
    Parameter MAXCACHESIZE = 1000;

    Method GetOrLoadPatient(pPatientId As %String) 
        As Patterns.Examples.Clinical.PatientActiveRecord
    {
        Set tPatient = ..Get(pPatientId)
        
        If '$IsObject(tPatient) {
            // Try loading by ID
            Set tPatient = ##class(PatientActiveRecord).Load(pPatientId)
            
            // Try loading by MRN if not found
            If '$IsObject(tPatient) {
                Set tPatient = ##class(PatientActiveRecord).FindByMRN(pPatientId)
            }
            
            // Cache if loaded successfully
            If $IsObject(tPatient) {
                Do ..Add(pPatientId, tPatient)
            }
        }
        
        Quit tPatient
    }

    Method InvalidatePatient(pPatientId As %String) As %Status
    {
        Quit ..Remove(pPatientId)
    }

    Method WarmCache(pPatientIds As %List) As %Status
    {
        Set tSC = $$$OK
        Set tPtr = 0
        While $ListNext(pPatientIds, tPtr, tId) {
            Set tPatient = ..GetOrLoadPatient(tId)
        }
        Quit tSC
    }
}
```

## Participants

### IdentityMap (Base Class)
- **Responsibilities**:
  - Maintains cache of loaded objects indexed by ID
  - Provides Add/Get/Remove operations
  - Tracks cache statistics (hits, misses, size)
  - Implements GetOrLoad pattern for lazy loading
- **Collaborators**: Domain objects, Data Mappers

### Domain-Specific Identity Map (e.g., PatientIdentityMap)
- **Responsibilities**:
  - Extends base Identity Map with domain-specific operations
  - Implements cache warming for frequently accessed objects
  - Provides cache invalidation on updates
  - Manages cache scope (session, request, transaction)
- **Collaborators**: Active Records, Data Mappers, Domain Model

### Data Mapper / Active Record
- **Responsibilities**:
  - Provides Load() method to fetch objects from database
  - Called by Identity Map when object not in cache
  - May use Identity Map to prevent duplicate loading
- **Collaborators**: Identity Map, Database

## Collaborations

### Loading an Object
1. Client requests object by ID from Identity Map
2. Identity Map checks internal cache
3. If found (hit), return cached instance
4. If not found (miss), delegate to Data Mapper to load
5. Data Mapper loads from database
6. Identity Map caches loaded object
7. Return object to client

### Updating an Object
1. Client updates object properties
2. Since only one instance exists, all references see update
3. On save/commit, invalidate cache entry (optional)
4. Next load will refresh from database

## Consequences

### Benefits
1. **✅ Reference Equality**: Same ID always returns same instance
2. **✅ Reduced Database Load**: Objects loaded once per scope
3. **✅ Consistency**: All code sees same object state
4. **✅ Performance**: O(1) cache lookup vs database query
5. **✅ Simplified Debugging**: One object instance to track
6. **✅ Unit of Work Integration**: Tracks all loaded objects

### Liabilities
1. **❌ Memory Consumption**: All loaded objects held in memory
2. **❌ Cache Invalidation**: Must update/clear on changes
3. **❌ Scope Management**: Must clear at transaction/session boundaries
4. **❌ Concurrency**: Cache coherence in multi-threaded systems
5. **❌ Stale Data**: Cached objects may be out of sync with database

## Implementation Considerations

### 1. Cache Scope
Choose appropriate scope for cache lifetime:
- **Transaction Scope**: Clear on commit/rollback
- **Request Scope**: Clear after web request completes
- **Session Scope**: Clear on user logout
- **Application Scope**: Shared across all users (rare)

### 2. Cache Eviction
Prevent unbounded memory growth:
- **Size Limit**: Maximum number of cached objects
- **LRU Strategy**: Evict least recently used
- **Time-Based**: Expire after timeout
- **Manual**: Explicit invalidation on updates

### 3. ObjectScript-Specific Considerations

**Using %ArrayOfObjects**:
```objectscript
// Efficient indexed storage
Property Cache As %ArrayOfObjects;

// O(1) lookup
Set obj = ..Cache.GetAt(id)

// Reference equality maintained
Set obj1 = ..Cache.GetAt("123")
Set obj2 = ..Cache.GetAt("123")
Write obj1 = obj2  // Writes 1
```

**Cache Statistics**:
```objectscript
Method GetHitRatio() As %Numeric
{
    Set tTotal = ..HitCount + ..MissCount
    If (tTotal = 0) Quit -1
    Quit (..HitCount / tTotal) * 100
}
```

### 4. Integration with Unit of Work
```objectscript
Class UnitOfWork
{
    Property IdentityMap As IdentityMap;
    
    Method RegisterNew(pObject) As %Status
    {
        // Add to identity map
        Do ..IdentityMap.Add(pObject.%Id(), pObject)
        // Track for insert
        Do ..NewObjects.Insert(pObject)
        Quit $$$OK
    }
}
```

### 5. Cache Invalidation Strategies

**Invalidate on Update**:
```objectscript
Method Update() As %Status
{
    // Save to database
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    // Invalidate cache
    Do ##class(IdentityMap).InvalidatePatient(..%Id())
    
    Quit tSC
}
```

**Write-Through Cache**:
```objectscript
Method Save() As %Status
{
    // Update database
    Set tSC = ..%Save()
    If $$$ISERR(tSC) Quit tSC
    
    // Update cache with fresh copy
    Do map.Add(..%Id(), $this)
    
    Quit tSC
}
```

## Sample Code

### Basic Usage
```objectscript
// Create identity map
Set map = ##class(IdentityMap).%New()

// First access loads from database
Set patient1 = map.GetOrLoad("123", "PatientMapper")

// Second access returns cached instance
Set patient2 = map.GetOrLoad("123", "PatientMapper")

// Verify same instance
If (patient1 = patient2) {
    Write "Same instance - reference equality!", !
}

// Update reflected everywhere
Set patient1.LastName = "Smith"
Write patient2.LastName  // Writes "Smith"

// Check cache statistics
Set stats = map.GetStatistics()
Write "Hit ratio: ", stats.hitRatio, "%", !
```

### Healthcare Workflow Example
```objectscript
// Session-scoped patient cache
Set patientCache = ##class(PatientIdentityMap).%New()

// Pre-warm cache with frequent patients
Set frequentIds = $ListBuild("P001", "P002", "P003")
Do patientCache.WarmCache(frequentIds)

// Process admissions (multiple accesses to same patients)
For i=1:1:10 {
    Set admission = admissions.GetAt(i)
    
    // Get patient (from cache if previously accessed)
    Set patient = patientCache.GetOrLoadPatient(admission.PatientId)
    
    // Update admission
    Set admission.PatientName = patient.FirstName _ " " _ patient.LastName
    Set admission.MRN = patient.MRN
}

// Check cache effectiveness
Set stats = patientCache.GetPatientCacheStatistics()
Write "Cache hits: ", stats.hitCount, !
Write "Cache misses: ", stats.missCount, !
Write "Hit ratio: ", stats.hitRatio, "%", !

// Clear cache on session end
Do patientCache.ClearSession()
```

## Known Uses

### 1. Hibernate (Java)
- First-level cache per session
- Automatic identity mapping
- Transparent to application code

### 2. Entity Framework (.NET)
- DbContext maintains identity map
- Same entity instance per context
- Change tracking integration

### 3. IRIS Persistent Objects
- %Id() provides unique identifier
- Can integrate identity map with %OpenId()
- Natural fit for Active Record pattern

### 4. Healthcare Applications
- Patient object caching
- Encounter consolidation
- Order processing
- Medication administration

## Related Patterns

### Unit of Work
- **Relationship**: Identity Map tracks loaded objects for Unit of Work
- **Usage**: Unit of Work uses Identity Map to prevent duplicate registration
- **Benefit**: Seamless integration for change tracking

### Data Mapper
- **Relationship**: Data Mapper loads objects, Identity Map caches them
- **Usage**: Mapper checks cache before querying database
- **Benefit**: Reduced database access

### Repository
- **Relationship**: Repository pattern often includes Identity Map
- **Usage**: Repository uses map to ensure single instance per entity
- **Benefit**: Transparent caching

### Lazy Load
- **Relationship**: Identity Map enables lazy loading without duplicates
- **Usage**: Lazy-loaded objects go through Identity Map
- **Benefit**: Deferred loading with caching

### Registry
- **Relationship**: Identity Map is specialized registry for domain objects
- **Usage**: Identity Map per entity type, Registry for global services
- **Benefit**: Different concerns, complementary patterns

## References

1. Fowler, Martin. *Patterns of Enterprise Application Architecture*. Addison-Wesley, 2002.
   - Chapter: "Identity Map", p. 195-199
   
2. Evans, Eric. *Domain-Driven Design*. Addison-Wesley, 2003.
   - Context: Repository pattern with identity guarantees

3. Hibernate Documentation. "First-level Cache"
   - https://docs.jboss.org/hibernate/orm/current/userguide/html_single/

4. InterSystems IRIS Documentation. "Object Identity"
   - Understanding %Id() and object references

## See Also

- [Unit of Work Pattern](unit-of-work.md)
- [Data Mapper Pattern](data-mapper.md)
- [Repository Pattern](repository.md)
- [Lazy Load Pattern](lazy-load.md)
