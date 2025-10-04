# Service Layer Pattern

**Category:** Patterns of Enterprise Application Architecture (PoEAA) - Domain Logic Patterns  
**Type:** Architectural Pattern  
**Scope:** Application Boundary Definition

## Intent

Define an application's boundary with a set of available operations from the perspective of interfacing client layers. Encapsulate the application's business logic, controlling transactions and coordinating responses in the implementation of its operations.

## Also Known As

- Application Service Layer
- Service Facade
- Application Boundary

## Motivation

In multi-layered enterprise applications, it's important to clearly define the boundary between the presentation layer and the domain/data access layers. Without a well-defined boundary:

- **Presentation logic bleeds into domain layer**: UI concerns mix with business rules
- **Transaction boundaries unclear**: Difficult to know where transactions start and end
- **Duplicate logic**: Similar workflows implemented multiple times across controllers
- **Poor remote access**: Fine-grained domain objects don't work well over network calls
- **Testing complexity**: Hard to test business workflows without UI dependencies

The Service Layer pattern addresses these issues by providing:

1. **Clear Application Boundary**: Defines what the application can do
2. **Coarse-Grained Operations**: Service methods represent complete use cases
3. **Transaction Management**: Each service operation defines transaction scope
4. **Domain Coordination**: Orchestrates multiple domain objects and table modules
5. **Remote-Ready API**: Service operations work well for remote clients

### Real-World Example

Consider a hospital patient admission system:

**Without Service Layer:**
```
Controller -> Patient.Create()
           -> BedTable.AssignBed()
           -> AdmissionRecord.Create()
           (Transaction management unclear, logic duplicated)
```

**With Service Layer:**
```
Controller -> PatientAdmissionService.AdmitPatient()
                -> Transaction starts
                -> Validates admission request
                -> Creates/updates Patient domain object
                -> Assigns bed via Table Module
                -> Creates admission record
                -> Transaction commits
                (Clear boundary, complete workflow, transaction managed)
```

## Applicability

Use Service Layer when:

- Building multi-layered applications with presentation, business, and data layers
- Need to provide remote access to business logic (web services, APIs)
- Require clear transaction boundaries for business operations
- Have complex workflows that coordinate multiple domain objects
- Want to separate presentation concerns from business logic
- Need consistent API for both local and remote clients
- Testing business logic without UI dependencies is important

**Don't use Service Layer when:**

- Building simple CRUD applications with minimal business logic
- Single-layer applications where separation isn't beneficial
- Domain logic is truly simple and doesn't require coordination
- Transaction boundaries naturally align with single domain operations
- Overhead of additional layer outweighs benefits

## Structure

```
┌─────────────────────────────────────────┐
│     Presentation Layer (UI/API)         │
│  Controllers, Views, API Endpoints      │
└─────────────────┬───────────────────────┘
                  │ Uses
                  ↓
┌─────────────────────────────────────────┐
│         Service Layer                    │
│  ┌─────────────────────────────────┐   │
│  │  Service Operations              │   │
│  │  - AdmitPatient()                │   │
│  │  - DischargePatient()            │   │
│  │  - TransferPatient()             │   │
│  │  Each operation:                 │   │
│  │  • Defines transaction boundary  │   │
│  │  • Validates request             │   │
│  │  • Coordinates domain objects    │   │
│  │  • Returns consistent results    │   │
│  └─────────────────────────────────┘   │
└─────────────────┬───────────────────────┘
                  │ Coordinates
                  ↓
┌─────────────────────────────────────────┐
│    Domain Model + Table Module          │
│  Patient, Diagnosis, Treatment          │
│  PatientTableModule, BedManagement      │
└─────────────────┬───────────────────────┘
                  │ Persists
                  ↓
┌─────────────────────────────────────────┐
│          Database (IRIS)                 │
└─────────────────────────────────────────┘
```

### Key Components

1. **ServiceLayer**: Base class providing transaction management and common operations
2. **ServiceContext**: Request metadata (user, session, trace ID)
3. **ServiceOperationResult**: Consistent response structure
4. **TransactionManager**: Handles transaction lifecycle
5. **Concrete Services**: Domain-specific services (PatientAdmissionService)

## Participants

- **ServiceLayer (Abstract)**
  - Defines service interface and transaction management
  - Provides common operations (logging, validation)
  - Manages ServiceContext and TransactionManager
  
- **ConcreteService (PatientAdmissionService)**
  - Implements specific business operations
  - Coordinates domain objects and table modules
  - Defines transaction boundaries for each operation
  
- **ServiceContext**
  - Encapsulates request metadata
  - Provides tracing and auditing information
  
- **ServiceOperationResult**
  - Standardized response structure
  - Contains success/failure, messages, data, errors
  
- **TransactionManager**
  - Manages IRIS transaction lifecycle
  - Handles TSTART/TCOMMIT/TROLLBACK
  - Supports nested transactions and isolation levels
  
- **Domain Model & Table Module**
  - Contains business rules and data access logic
  - Coordinated by Service Layer

## Collaborations

1. **Client initiates operation**: Presentation layer calls service method
2. **Service validates request**: ServiceLayer validates input data
3. **Transaction begins**: Service starts transaction (TSTART)
4. **Domain coordination**: Service orchestrates domain objects and table modules
5. **Business rules executed**: Domain objects apply business logic
6. **Data persistence**: Changes saved to database
7. **Transaction commits**: Service commits transaction (TCOMMIT)
8. **Result returned**: ServiceOperationResult returned to client
9. **Rollback on error**: Any error triggers TROLLBACK

### Sequence Diagram

```
Client → Service: AdmitPatient(patientData)
Service → Service: ValidateRequest(patientData)
Service → Transaction: TSTART
Service → Patient: Create(patientData)
Service → BedModule: AssignBed(patientId)
Service → Service: CreateAdmissionRecord()
Service → Transaction: TCOMMIT
Service → Client: ServiceOperationResult(success, patientId)
```

## Implementation

### 1. Base Service Layer Class

```objectscript
Class Patterns.PoEAA.DomainLogic.ServiceLayer Extends %RegisteredObject
{
    Property ServiceContext As ServiceContext;
    Property TransactionManager As TransactionManager;
    Property LastOperationResult As ServiceOperationResult;
    
    Method ExecuteOperation(pOperation, pArgs...) As %Status
    {
        Try {
            TSTART
            Set tSC = $METHOD($THIS, pOperation, pArgs...)
            If $$$ISOK(tSC) {
                TCOMMIT
            } Else {
                TROLLBACK
            }
        } Catch ex {
            If $TLEVEL > 0 TROLLBACK
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
}
```

### 2. Healthcare Clinical Service Example

```objectscript
Class PatientAdmissionService Extends ServiceLayer
{
    Method AdmitPatient(pPatientData) As %Status
    {
        Try {
            TSTART
            
            // 1. Validate admission request
            Set tSC = ..ValidateAdmissionRequest(pPatientData)
            If $$$ISERR(tSC) Quit
            
            // 2. Create patient (Domain Model)
            Set tPatient = ##class(Patient).%New()
            Set tPatient.Name = pPatientData.%Get("name")
            Set tSC = tPatient.%Save()
            If $$$ISERR(tSC) Quit
            
            // 3. Assign bed (Table Module)
            Set tBed = ##class(PatientTableModule).AssignBed(tPatient.%Id())
            If tBed = "" Set tSC = $$$ERROR(...) Quit
            
            // 4. Create admission record
            Set tSC = ..CreateAdmissionRecord(tPatient.%Id())
            If $$$ISERR(tSC) Quit
            
            TCOMMIT
            
        } Catch ex {
            If $TLEVEL > 0 TROLLBACK
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}
```

### 3. Transaction Management

```objectscript
Class TransactionManager Extends %RegisteredObject
{
    Method BeginTransaction() As %Status
    {
        TSTART
        Set ..CurrentLevel = $TLEVEL
        Quit $$$OK
    }
    
    Method CommitTransaction() As %Status
    {
        If $TLEVEL > 0 TCOMMIT
        Quit $$$OK
    }
    
    Method RollbackTransaction() As %Status
    {
        If $TLEVEL > 0 TROLLBACK
        Quit $$$OK
    }
}
```

### 4. IRIS-Specific Transaction Features

**Nested Transactions:**
```objectscript
TSTART              // Level 1
// ... operations ...
TSTART              // Level 2 (nested)
// ... operations ...
TCOMMIT             // Back to Level 1
TCOMMIT             // Level 0 (fully committed)
```

**Checking Transaction Level:**
```objectscript
If $TLEVEL > 0 {
    // Currently in transaction
}
```

**Transaction Isolation Levels:**
- READ UNCOMMITTED: Dirty reads allowed
- READ COMMITTED: Default, no dirty reads
- REPEATABLE READ: No phantom reads
- SERIALIZABLE: Full isolation

## Sample Code

See full implementation in:
- `src/Patterns/PoEAA/DomainLogic/ServiceLayer.cls`
- `src/Patterns/PoEAA/DomainLogic/TransactionManager.cls`
- `src/Patterns/PoEAA/DomainLogic/ServiceContext.cls`
- `src/Patterns/PoEAA/DomainLogic/ServiceOperationResult.cls`
- `src/Patterns/Examples/Clinical/PatientAdmissionService.cls`

## Known Uses

1. **Healthcare Systems**: Patient admission, discharge, transfer services
2. **E-Commerce**: Order processing, payment processing, inventory management
3. **Banking**: Account transfers, loan processing, transaction history
4. **CRM Systems**: Customer onboarding, case management, campaign execution
5. **Booking Systems**: Reservation creation, cancellation, modification workflows

## Consequences

### Benefits

1. **Clear Application Boundary**: Defines what the application can do
2. **Transaction Control**: Explicit transaction boundaries for each operation
3. **Reusability**: Same service layer for web, API, batch processing
4. **Testability**: Easy to test business workflows without UI
5. **Remote Access**: Coarse-grained operations suitable for remote calls
6. **Consistency**: Standardized error handling and response structure
7. **Security**: Centralized authorization and validation
8. **Auditing**: Single point for logging all business operations

### Drawbacks

1. **Additional Layer**: Extra layer of indirection
2. **Potential for Anemic Domain**: Risk of moving logic from domain to services
3. **Complexity**: May be overkill for simple CRUD applications
4. **Performance**: Additional method calls and object creation
5. **Learning Curve**: Developers must understand layering principles

### Best Practices

1. **Coarse-Grained Operations**: Service methods should represent complete use cases
2. **Transaction Per Operation**: Each service method is one transaction
3. **Stateless Services**: Don't store state in service layer objects
4. **Domain Logic in Domain**: Keep business rules in domain objects, not services
5. **Consistent Returns**: Use ServiceOperationResult for all operations
6. **Proper Validation**: Validate at service boundary before domain operations
7. **Error Translation**: Convert domain exceptions to service-level errors
8. **Logging & Auditing**: Log all service operations for compliance

## Related Patterns

### Comparison with Other Patterns

**Service Layer vs. Transaction Script:**
- Service Layer: Coordinates domain objects; thin service layer, rich domain model
- Transaction Script: Contains all logic; thick procedural scripts

**Service Layer vs. Domain Model:**
- Service Layer: Orchestration and transaction boundaries
- Domain Model: Business rules and domain logic
- They complement each other

**Service Layer vs. Table Module:**
- Service Layer: Application boundary and workflow coordination
- Table Module: Data access and table-specific operations
- Service Layer coordinates multiple Table Modules

**Service Layer vs. Facade:**
- Service Layer: Defines application operations with transaction management
- Facade: Simplifies existing complex subsystem
- Service Layer is broader in scope

**Service Layer vs. Application Controller:**
- Service Layer: Business operation execution
- Application Controller: Screen navigation and flow
- They can work together

### Patterns to Use With

- **Domain Model**: Service Layer coordinates domain objects
- **Table Module**: Service Layer coordinates table modules
- **Unit of Work**: Transaction management within service operations
- **Data Mapper**: Service Layer uses mappers for persistence
- **DTO (Data Transfer Object)**: For remote service calls
- **Repository**: Service Layer uses repositories for data access

## IRIS-Specific Considerations

### Transaction Management

IRIS provides robust transaction support:
- **TSTART**: Begin transaction
- **TCOMMIT**: Commit transaction
- **TROLLBACK**: Rollback transaction
- **$TLEVEL**: Current transaction nesting level
- Automatic deadlock detection
- Named savepoints for partial rollbacks

### Globals for Metadata

Use globals for audit logging:
```objectscript
Set tAuditId = $INCREMENT(^Patterns.ServiceLayer.Audit)
Set ^Patterns.ServiceLayer.Audit(tAuditId) = auditData
```

### Performance Optimization

- Keep transactions short to minimize lock contention
- Use SQL for set-based operations via Table Module
- Cache frequently accessed data
- Profile transaction execution times
- Monitor deadlock frequency

### Error Handling

```objectscript
Try {
    TSTART
    // ... operations ...
    TCOMMIT
} Catch ex {
    If $TLEVEL > 0 TROLLBACK
    Set tSC = ex.AsStatus()
    Do ..LogError(ex)
}
```

## When to Use vs. When Not to Use

### Use Service Layer When:

✅ Building multi-layered enterprise applications  
✅ Need remote access (web services, APIs)  
✅ Complex workflows coordinating multiple domain objects  
✅ Clear transaction boundaries required  
✅ Separating presentation from business logic  
✅ Need consistent API for multiple client types  
✅ Testing business logic independently is important  

### Don't Use Service Layer When:

❌ Simple CRUD applications  
❌ Single-layer applications  
❌ Minimal business logic  
❌ Transaction boundaries align with single operations  
❌ Overhead isn't justified by complexity  
❌ Team lacks understanding of layered architecture  

## Testing Strategy

### Unit Testing Service Layer

```objectscript
Class ServiceLayerTest Extends %UnitTest.TestCase
{
    Method TestAdmitPatient()
    {
        Set service = ##class(PatientAdmissionService).%New()
        Set data = {"name": "John Doe", "dob": "1980-01-15"}
        
        Set tSC = service.AdmitPatient(data)
        Do $$$AssertStatusOK(tSC, "Admission should succeed")
        Do $$$AssertTrue(service.LastOperationResult.Success)
    }
    
    Method TestAdmissionRollback()
    {
        // Test that failure triggers rollback
        Set service = ##class(PatientAdmissionService).%New()
        Set invalidData = {}  // Missing required fields
        
        Set tSC = service.AdmitPatient(invalidData)
        Do $$$AssertStatusNotOK(tSC, "Should fail validation")
        Do $$$AssertEquals($TLEVEL, 0, "Transaction should be rolled back")
    }
}
```

### Integration Testing

- Test transaction commit and rollback
- Verify data persistence after commit
- Verify data not persisted after rollback
- Test concurrent service operations
- Test transaction isolation levels

## Summary

The Service Layer pattern defines an application's boundary with coarse-grained operations that manage transaction boundaries and coordinate domain logic. It provides a clear separation between presentation and business layers while offering a consistent API for both local and remote clients.

In IRIS ObjectScript, Service Layer leverages TSTART/TCOMMIT/TROLLBACK for transaction management, coordinates Domain Model and Table Module patterns, and provides a robust foundation for enterprise applications.

Key characteristics:
- **Coarse-grained operations** representing complete use cases
- **Transaction boundaries** at service operation level
- **Domain coordination** orchestrating multiple objects
- **Consistent API** for all client types
- **Clear separation** between layers

The pattern is essential for complex enterprise applications but may be overkill for simple CRUD scenarios. When used appropriately, it provides excellent separation of concerns, testability, and maintainability.

## References

- Fowler, Martin. *Patterns of Enterprise Application Architecture*. Addison-Wesley, 2002.
- Evans, Eric. *Domain-Driven Design*. Addison-Wesley, 2003.
- InterSystems IRIS Documentation: Transaction Processing
- Story 5.1: Transaction Script Pattern Implementation
- Story 5.2: Domain Model Pattern Implementation
- Story 5.3: Table Module Pattern Implementation

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2025-10-04 | Development Team | Initial implementation of Service Layer pattern |
