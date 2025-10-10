# Unit of Work Pattern

## Intent

Maintains a list of objects affected by a business transaction and coordinates the writing out of changes and the resolution of concurrency problems.

## Also Known As

- Transaction Coordinator
- Change Tracker

## Motivation

When you're pulling data in and out of a database, it's important to keep track of what you've changed. Similarly, you have to ensure that changes are properly committed or rolled back as a unit.

The Unit of Work pattern keeps track of everything you do during a business transaction that can affect the database. When you're done, it figures out everything that needs to be done to alter the database as a result of your work.

## Applicability

Use the Unit of Work pattern when:

- You need to track changes to multiple objects during a business transaction
- You want to batch database updates for performance
- You need to ensure transactional consistency across multiple operations
- You want to coordinate updates across multiple data mappers
- You need dependency ordering for inserts, updates, and deletes

## Structure

```
┌─────────────────────┐
│   Unit of Work      │
├─────────────────────┤
│ - newObjects        │
│ - dirtyObjects      │
│ - deletedObjects    │
│ - cleanObjects      │
│ - mappers           │
├─────────────────────┤
│ + RegisterNew()     │
│ + RegisterDirty()   │
│ + RegisterClean()   │
│ + RegisterDeleted() │
│ + Commit()          │
│ + Rollback()        │
│ + RegisterMapper()  │
└─────────────────────┘
```

## Participants

**Unit of Work**: Tracks objects affected by a transaction
- Maintains lists of new, modified, and deleted objects
- Coordinates commit and rollback operations
- Manages mapper registry for persistence

**Data Mapper**: Handles object persistence
- Performs actual database operations (insert, update, delete)
- Called by Unit of Work during commit

**Domain Objects**: Business objects being tracked
- Registered with Unit of Work when created, modified, or deleted

## Collaborations

1. Client creates Unit of Work instance
2. Client registers mappers for object types
3. Client creates/modifies/deletes domain objects
4. Client registers changes with Unit of Work
5. Client calls Commit() to persist all changes
6. Unit of Work executes operations in order (insert, update, delete)
7. Unit of Work clears tracking collections on success

## Implementation

### Basic Implementation

```objectscript
Class Patterns.PoEAA.DataSource.UnitOfWork Extends %RegisteredObject
{

Property NewObjects As list Of %RegisteredObject;
Property DirtyObjects As list Of %RegisteredObject;
Property DeletedObjects As list Of %RegisteredObject;
Property CleanObjects As list Of %RegisteredObject;

Method RegisterNew(pObject As %RegisteredObject) As %Status
{
    Do ..NewObjects.Insert(pObject)
    Quit $$$OK
}

Method RegisterDirty(pObject As %RegisteredObject) As %Status
{
    Do ..DirtyObjects.Insert(pObject)
    Quit $$$OK
}

Method RegisterDeleted(pObject As %RegisteredObject) As %Status
{
    Do ..DeletedObjects.Insert(pObject)
    Quit $$$OK
}

Method Commit() As %Status
{
    TSTART
    // Insert new objects
    // Update dirty objects
    // Delete removed objects
    TCOMMIT
    Do ..Clear()
    Quit $$$OK
}

Method Rollback() As %Status
{
    TROLLBACK
    Do ..Clear()
    Quit $$$OK
}

}
```

### Healthcare Example

```objectscript
// Create Unit of Work
Set uow = ##class(ClinicalDocumentationUnitOfWork).%New()

// Register mappers
Do uow.RegisterMapper("ClinicalEncounter", encounterMapper)

// Make changes
Do uow.RegisterNew(encounter)
Do uow.RegisterDirty(vitals)

// Commit all changes together
Set status = uow.Commit()
```

## Sample Code

### Creating and Using Unit of Work

```objectscript
Method UpdatePatientRecords() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create Unit of Work
        Set tUoW = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
        
        // Register mappers
        Set tMapper = ##class(ClinicalEncounterMapper).%New()
        Do tUoW.RegisterMapper("ClinicalEncounter", tMapper)
        
        // Create new encounter
        Set tEncounter = ##class(ClinicalEncounter).%New()
        Set tEncounter.PatientId = "12345"
        Do tUoW.RegisterNew(tEncounter)
        
        // Update existing record
        Set tExisting = tMapper.FindById("ENC-001")
        Set tExisting.Status = "Completed"
        Do tUoW.RegisterDirty(tExisting)
        
        // Commit all changes
        Set tSC = tUoW.Commit()
        
    } Catch ex {
        // Rollback on error
        Do tUoW.Rollback()
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}
```

### With Validation

```objectscript
Method Commit() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate before commit
        Set tSC = ..ValidateChanges()
        If $$$ISERR(tSC) {
            Do ..Rollback()
            Quit
        }
        
        // Start transaction
        TSTART
        
        // Process in order
        Do ..ProcessNewObjects()
        Do ..ProcessDirtyObjects()
        Do ..ProcessDeletedObjects()
        
        // Commit transaction
        TCOMMIT
        
        // Clear tracking
        Do ..Clear()
        
    } Catch ex {
        TROLLBACK
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}
```

## Consequences

### Benefits

1. **Batched Updates**: Reduces database round-trips by batching operations
2. **Transactional Consistency**: Ensures all-or-nothing semantics
3. **Dependency Management**: Handles insert/update/delete ordering
4. **Centralized Control**: Single point for transaction management
5. **Reduced Complexity**: Simplifies client code

### Drawbacks

1. **Memory Overhead**: Tracks all changed objects in memory
2. **Complexity**: More complex than direct database access
3. **Coupling**: Creates dependency on Unit of Work infrastructure
4. **Debugging**: Harder to trace individual operations

## Known Uses

- **Enterprise Applications**: Order processing, financial transactions
- **Healthcare Systems**: Clinical documentation, patient records
- **E-commerce**: Shopping cart checkout, order fulfillment
- **CRM Systems**: Customer data updates, activity tracking

## Related Patterns

- **Data Mapper**: Unit of Work coordinates multiple Data Mappers
- **Identity Map**: Often used together to prevent duplicate loading
- **Repository**: Can use Unit of Work for transaction management
- **Transaction Script**: Alternative for simpler scenarios

## When to Use

Use Unit of Work when you need to:
- Coordinate updates across multiple objects
- Ensure transactional consistency
- Batch database operations for performance
- Track changes during a business transaction
- Manage complex dependency ordering

## When Not to Use

Avoid Unit of Work when:
- Single object updates are sufficient
- Transactions are very simple
- Memory constraints are critical
- Immediate persistence is required
- Debugging complexity outweighs benefits

## InterSystems IRIS Specific Considerations

### Transaction Management

```objectscript
// IRIS provides native transaction support
TSTART
// ... operations ...
TCOMMIT  // or TROLLBACK on error
```

### Object Collections

```objectscript
// Use list collections for tracking
Property NewObjects As list Of %RegisteredObject;
```

### Error Handling

```objectscript
Try {
    TSTART
    // operations
    TCOMMIT
} Catch ex {
    TROLLBACK
    // handle error
}
```

## Implementation Checklist

- [ ] Create Unit of Work base class
- [ ] Implement change tracking collections
- [ ] Add RegisterNew/Dirty/Deleted/Clean methods
- [ ] Implement Commit with transaction management
- [ ] Implement Rollback functionality
- [ ] Add mapper registration
- [ ] Implement dependency ordering
- [ ] Create validation hooks
- [ ] Add audit logging (optional)
- [ ] Write comprehensive unit tests

## Performance Considerations

1. **Batch Size**: Monitor collection sizes for memory usage
2. **Transaction Scope**: Keep transactions as short as possible
3. **Validation**: Perform validation before starting transaction
4. **Dependency Ordering**: Optimize order of operations
5. **Cleanup**: Clear collections after commit

## Testing Strategy

Test scenarios:
- RegisterNew adds objects to tracking
- RegisterDirty tracks modifications
- RegisterDeleted tracks deletions
- RegisterClean removes from dirty
- Commit executes in correct order (insert, update, delete)
- Rollback discards all changes
- Transaction atomicity (all or nothing)
- Error handling during commit
- Multiple object types in single unit of work

## See Also

- [Data Mapper Pattern](data-mapper.md)
- [Identity Map Pattern](../identity-map.md)
- [Repository Pattern](../repository.md)
