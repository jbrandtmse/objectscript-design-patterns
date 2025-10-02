# Transaction Script Pattern

## Pattern Type
**Domain Logic Pattern** (Patterns of Enterprise Application Architecture)

## Intent
Organize business logic by procedures where each procedure handles a single request from the presentation layer. Each transaction script contains all the logic needed to handle a specific business operation.

## Also Known As
- Procedural Business Logic
- Transaction Handler
- Script-Based Logic

## Motivation
Many business applications have relatively simple domain logic that doesn't justify the complexity of a rich domain model. In these cases, organizing the business logic as a set of procedures (transaction scripts) provides a straightforward, easy-to-understand approach.

Each script handles a single transaction from start to finish, including all necessary database operations, validations, and business rule enforcement. This makes it easy to understand what happens during a business operation and ensures that all related logic is in one place.

## Applicability
Use Transaction Script when:
- Domain logic is relatively simple with few business rules
- Application is primarily data-centric with CRUD operations
- Rapid development is a priority
- Team is more familiar with procedural programming
- Business operations are naturally organized as discrete transactions
- Little code reuse between different operations is expected

Don't use Transaction Script when:
- Domain logic is complex with many interrelated business rules
- Significant code duplication occurs between scripts
- Business rules change frequently
- Rich object behaviors are needed
- Domain objects need to maintain complex state

## Structure

```
┌─────────────────────────────────┐
│   TransactionScript             │
├─────────────────────────────────┤
│ + StartTransaction()            │
│ + CommitTransaction()           │
│ + RollbackTransaction()         │
│ + Execute(procedure, data)      │
├─────────────────────────────────┤
│ # ExecuteProcedure()            │
│   (override in subclasses)      │
└─────────────────────────────────┘
           △
           │ extends
           │
┌──────────────────────────────────┐
│  PatientAdmissionScript          │
├──────────────────────────────────┤
│ + ProcessAdmission(data)         │
│ - RegisterPatient(data)          │
│ - VerifyInsurance(data)          │
│ - AssignBed(data)                │
│ - CollectMedicalHistory(data)    │
│ - FinalizeAdmission()            │
└──────────────────────────────────┘
```

### Participants

**TransactionScript (Base Class)**
- Provides transaction management infrastructure
- Manages transaction boundaries (START, COMMIT, ROLLBACK)
- Tracks transaction state and nesting levels
- Provides logging capabilities
- Defines template for procedure execution

**Concrete Transaction Scripts (Subclasses)**
- Implement specific business operations as procedures
- Each method handles one step of the business transaction
- Manage all database operations for their procedures
- Enforce business rules and validations
- Handle error conditions and rollback logic

## Implementation

### IRIS-Specific Considerations

**Transaction Management:**
```objectscript
// Start transaction
TSTART

// Commit transaction
TCOMMIT

// Rollback transaction
TROLLBACK

// Check transaction level
If $TLEVEL > 0 {
    // Inside a transaction
}
```

**Transaction Features in IRIS:**
- Nested transactions supported via $TLEVEL
- Automatic rollback on unhandled errors
- Lock management integrated with transactions
- Global transactions for distributed operations

### Basic Implementation

```objectscript
Class Patterns.PoEAA.DomainLogic.TransactionScript Extends %RegisteredObject
{
    Property TransactionState As %String [ InitialExpression = "INACTIVE" ];
    Property TransactionLevel As %Integer [ InitialExpression = 0 ];
    Property LastError As %String;
    
    Method StartTransaction() As %Status
    {
        Set tSC = $$$OK
        Try {
            TSTART
            Set ..TransactionState = "ACTIVE"
            Set ..TransactionLevel = $TLEVEL
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    Method CommitTransaction() As %Status
    {
        Set tSC = $$$OK
        Try {
            TCOMMIT
            Set ..TransactionState = "COMMITTED"
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    Method RollbackTransaction() As %Status
    {
        Set tSC = $$$OK
        Try {
            TROLLBACK
            Set ..TransactionState = "ROLLEDBACK"
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
}
```

### Healthcare Example: Patient Admission

```objectscript
Class Patterns.Examples.PatientAdmissionScript Extends Patterns.PoEAA.DomainLogic.TransactionScript
{
    Method ProcessAdmission(pPatientData As %DynamicObject) As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Start transaction
            Set tSC = ..StartTransaction()
            If $$$ISERR(tSC) Quit
            
            // Execute admission steps
            Set tSC = ..RegisterPatient(pPatientData)
            If $$$ISERR(tSC) Quit
            
            Set tSC = ..VerifyInsurance(pPatientData)
            If $$$ISERR(tSC) Quit
            
            Set tSC = ..AssignBed(pPatientData)
            If $$$ISERR(tSC) Quit
            
            Set tSC = ..CollectMedicalHistory(pPatientData)
            If $$$ISERR(tSC) Quit
            
            Set tSC = ..FinalizeAdmission()
            If $$$ISERR(tSC) Quit
            
            // Commit if all steps successful
            Set tSC = ..CommitTransaction()
            
        } Catch ex {
            // Rollback on error
            Do ..RollbackTransaction()
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}
```

## Sample Code

### Complete Patient Admission Example

```objectscript
// Create admission script
Set admission = ##class(Patterns.Examples.PatientAdmissionScript).%New()

// Prepare patient data
Set patientData = {
    "firstName": "John",
    "lastName": "Doe",
    "dob": "1980-01-01",
    "insurance": {
        "provider": "Blue Cross",
        "policyNumber": "BC123456"
    },
    "bedPreference": "private",
    "medicalHistory": {
        "allergies": ["Penicillin"],
        "medications": ["Aspirin"]
    }
}

// Process admission
Set status = admission.ProcessAdmission(patientData)

If $$$ISOK(status) {
    Write "Admission completed successfully", !
    Write "Patient ID: ", admission.PatientID, !
    Write "Assigned Bed: ", admission.AssignedBed, !
} Else {
    Write "Admission failed: ", $SYSTEM.Status.GetErrorText(status), !
}
```

## Known Uses

### In Healthcare Systems
- **Patient Registration**: Handle complete patient registration process
- **Order Entry**: Process medical orders with validations
- **Billing Transactions**: Calculate and record charges
- **Insurance Claims**: Submit and track insurance claims

### In Financial Systems
- **Payment Processing**: Handle payment transactions end-to-end
- **Account Transfers**: Move funds between accounts
- **Transaction Posting**: Record financial transactions

### In E-Commerce
- **Order Placement**: Process complete order workflow
- **Inventory Updates**: Manage inventory changes
- **Shipping Fulfillment**: Handle shipping processes

## Consequences

### Benefits
1. **Simple to Understand**: Procedural logic is straightforward
2. **Easy to Implement**: Minimal overhead compared to rich domain models
3. **Transaction Clarity**: Clear transaction boundaries
4. **Rapid Development**: Faster initial development
5. **Familiar Paradigm**: Comfortable for procedural programmers
6. **Debugging Ease**: Easy to trace execution flow
7. **Testable**: Each procedure can be tested independently

### Liabilities
1. **Code Duplication**: Common logic may be duplicated across scripts
2. **Limited Reusability**: Hard to reuse logic between different operations
3. **Scalability Issues**: Doesn't scale well with complex business rules
4. **Maintenance Burden**: Changes to common logic require multiple updates
5. **No Object Benefits**: Misses polymorphism and encapsulation benefits
6. **Procedural Coupling**: Tight coupling to database structure
7. **Testing Complexity**: Integration testing required for complex scenarios

## Related Patterns

**Domain Model**: Alternative for complex domain logic with rich behavior
- Use Transaction Script for simple domains
- Use Domain Model for complex, behavior-rich domains

**Table Module**: Organizes logic around database tables
- Transaction Script: One class per use case/transaction
- Table Module: One class per table with multiple operations

**Service Layer**: Coordinates domain objects
- Transaction Script IS the service layer
- Service Layer coordinates rich domain objects

**Data Mapper**: Separates domain objects from database
- Transaction Script often includes data access
- Data Mapper separates persistence concerns

**Active Record**: Combines data and behavior
- Transaction Script separates business logic from data
- Active Record combines them in domain objects

## Implementation Checklist

- [ ] Identify discrete business transactions
- [ ] Create transaction script class for each operation
- [ ] Implement transaction management methods
- [ ] Add procedure methods for business steps
- [ ] Include proper error handling and rollback logic
- [ ] Add validation for input data
- [ ] Implement logging for debugging
- [ ] Write unit tests for each procedure
- [ ] Test transaction rollback scenarios
- [ ] Document business rules and validations

## IRIS Transaction Management

### Transaction Levels
```objectscript
// Check current transaction level
Write "Transaction Level: ", $TLEVEL, !

// Nested transactions
TSTART  // Level 1
  TSTART  // Level 2
  TCOMMIT  // Back to Level 1
TCOMMIT  // Level 0
```

### Transaction States
- **INACTIVE**: No active transaction ($TLEVEL = 0)
- **ACTIVE**: Transaction in progress ($TLEVEL > 0)
- **COMMITTED**: Transaction successfully completed
- **ROLLEDBACK**: Transaction rolled back due to error or explicit rollback

### Best Practices
1. Keep transactions short to minimize lock contention
2. Always handle errors with try/catch
3. Ensure cleanup in finally blocks or %OnClose
4. Log transaction operations for debugging
5. Test both success and failure scenarios
6. Use appropriate isolation levels
7. Monitor transaction duration
8. Avoid nested transactions when possible

## Performance Considerations

### Transaction Duration
- Minimize time spent in transactions
- Perform validations before starting transaction
- Batch similar operations when possible
- Profile transaction execution times

### Lock Management
- IRIS manages locks automatically within transactions
- Be aware of lock escalation
- Consider lock timeout scenarios
- Minimize data touched in transactions

### Optimization Strategies
1. Pre-validate data before transaction
2. Use batch operations for multiple records
3. Minimize global accesses in loops
4. Cache frequently accessed reference data
5. Use embedded SQL for set operations
6. Profile and identify bottlenecks
7. Consider connection pooling for high volume

## Testing Strategy

### Unit Testing
- Test each procedure method independently
- Mock database operations where appropriate
- Test validation logic separately
- Verify error conditions

### Integration Testing
- Test complete transaction workflows
- Verify transaction commit scenarios
- Test transaction rollback scenarios
- Validate data consistency
- Test concurrent transactions

### Performance Testing
- Measure transaction execution times
- Test under load conditions
- Identify lock contention issues
- Validate scalability

## Migration Path

### From Transaction Script to Domain Model
When complexity increases:
1. Identify common behavior across scripts
2. Extract value objects for data structures
3. Create entity classes for key concepts
4. Move business rules into domain objects
5. Introduce repositories for persistence
6. Refactor scripts to use domain objects

### Indicators for Migration
- Significant code duplication
- Complex business rule interactions
- Frequent changes to business rules
- Need for polymorphic behavior
- Growing maintenance burden

## References

- Fowler, Martin. *Patterns of Enterprise Application Architecture*. Addison-Wesley, 2002.
- InterSystems IRIS Documentation: Transaction Processing
- InterSystems ObjectScript Language Reference

## See Also

- [Domain Model Pattern](domain-model.md)
- [Table Module Pattern](table-module.md)
- [Service Layer Pattern](service-layer.md)
- [Unit of Work Pattern](unit-of-work.md)

---

*Pattern implemented in ObjectScript for InterSystems IRIS*  
*Last Updated: 2025-10-01*  
*Version: 1.0.0*
