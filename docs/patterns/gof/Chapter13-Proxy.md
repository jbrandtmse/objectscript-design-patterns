# Chapter 13: Proxy Pattern

## Intent
**Provide a surrogate or placeholder for another object to control access to it.**

The Proxy pattern introduces a level of indirection when accessing an object. This indirection can serve various purposes: lazy initialization, access control, logging, caching, or remote object access.

## Also Known As
- Surrogate

## Motivation
There are several situations where we want to control access to an object:

1. **Virtual Proxy**: Defer the creation of expensive objects until they're actually needed
2. **Protection Proxy**: Control access based on permissions
3. **Remote Proxy**: Provide a local representative for an object in a different address space
4. **Smart Reference**: Perform additional actions when an object is accessed

Consider a healthcare system where patient records contain sensitive information. We need to:
- Control who can access different parts of the data
- Log all access attempts for HIPAA compliance
- Defer loading of large medical images until needed
- Mask sensitive fields based on user roles

## Applicability
Use the Proxy pattern when:

- You need a more versatile or sophisticated reference to an object than a simple pointer
- You want to defer object creation (virtual proxy)
- You need to control access based on permissions (protection proxy)
- You have objects in different address spaces (remote proxy)
- You want to perform housekeeping tasks transparently
- You need to add functionality to object access without changing the object

## Structure
```
     Subject
        ^
        |
    +---+---+
    |       |
 Proxy   RealSubject
```

## Participants

### Subject (Subject)
- Defines the common interface for RealSubject and Proxy
- Allows Proxy to be used anywhere RealSubject is expected

### RealSubject (RealSubject, PatientDataService)
- Defines the real object that the proxy represents
- Contains the actual functionality and data

### Proxy (Proxy, VirtualProxy, ProtectionProxy, RemoteProxy, PatientDataProxy)
- Maintains a reference to the real subject
- Provides an interface identical to Subject
- Controls access to the real subject and may be responsible for creating and deleting it
- Additional responsibilities depend on proxy type:
  - **Virtual proxies** cache information to defer access
  - **Protection proxies** check access permissions
  - **Remote proxies** encode requests and send to remote objects

## Collaborations
- Proxy forwards requests to RealSubject when appropriate, depending on the kind of proxy
- Virtual proxy may create RealSubject on first access
- Protection proxy checks permissions before forwarding
- Remote proxy marshals parameters and handles network communication

## Consequences

### Benefits:
1. **Controlled access**: Proxies can restrict access based on various criteria
2. **Lazy initialization**: Virtual proxies defer expensive object creation
3. **Security**: Protection proxies enforce access control policies
4. **Distribution transparency**: Remote proxies hide network complexity
5. **Smart references**: Can perform additional actions (logging, reference counting)
6. **Performance optimization**: Through caching and lazy loading

### Liabilities:
1. **Increased complexity**: Adds another layer of abstraction
2. **Potential performance overhead**: Additional indirection
3. **Maintenance**: Must keep proxy interface synchronized with subject

## Implementation

### Basic Proxy Structure in ObjectScript:

```objectscript
/// Abstract Subject interface
Class Patterns.GoF.Structural.Subject Extends %RegisteredObject [ Abstract ]
{
    Method Request() As %String [ Abstract ]
    {
        Quit ""
    }
}

/// Real Subject with actual functionality
Class Patterns.GoF.Structural.RealSubject Extends Subject
{
    Property Data As %String;
    
    Method Request() As %String
    {
        Quit "RealSubject: Handling request with data [" _ ..Data _ "]"
    }
}

/// Abstract Proxy base class
Class Patterns.GoF.Structural.Proxy Extends Subject [ Abstract ]
{
    Property RealSubject As RealSubject;
    Property IsLoaded As %Boolean [ InitialExpression = 0 ];
    
    Method CheckAccess() As %Boolean [ Abstract ]
    {
        Quit 1
    }
    
    Method LoadRealSubject() As %Status
    {
        If '..IsLoaded {
            Set ..RealSubject = ##class(RealSubject).%New()
            Set ..IsLoaded = 1
        }
        Quit $$$OK
    }
}
```

### Virtual Proxy Implementation:

```objectscript
Class Patterns.GoF.Structural.VirtualProxy Extends Proxy
{
    Property PlaceholderInfo As %String;
    
    Method %OnNew(pPlaceholderInfo As %String = "") As %Status
    {
        Set tSC = ##super()
        Set ..PlaceholderInfo = pPlaceholderInfo
        // Don't load real subject yet
        Quit tSC
    }
    
    Method Request() As %String
    {
        // Load real subject on first access
        If '..IsLoaded {
            Do ..LoadRealSubject()
        }
        Quit ..RealSubject.Request()
    }
    
    Method CheckAccess() As %Boolean
    {
        // Virtual proxy always allows access
        Quit 1
    }
}
```

### Protection Proxy with IRIS Security Integration:

```objectscript
Class Patterns.GoF.Structural.ProtectionProxy Extends Proxy
{
    Property RequiredRole As %String;
    Property AuditEnabled As %Boolean [ InitialExpression = 1 ];
    
    Method CheckAccess() As %Boolean
    {
        // Check current user's roles
        Set tUsername = $USERNAME
        Set tRoles = $ROLES
        
        // Check if user has required role
        If '$Find("," _ tRoles _ ",", "," _ ..RequiredRole _ ",") {
            Do ..LogSecurityEvent("ACCESS_DENIED", tUsername)
            Quit 0
        }
        
        Do ..LogSecurityEvent("ACCESS_GRANTED", tUsername)
        Quit 1
    }
    
    Method LogSecurityEvent(pEventType As %String, pUser As %String)
    {
        If ..AuditEnabled {
            Set ^Patterns.ProxyAudit($I(^Patterns.ProxyAudit)) = 
                $ZDT($H,3) _ "|" _ pEventType _ "|" _ pUser
        }
    }
}
```

## IRIS Security Integration

### Using IRIS Security Features

ObjectScript provides several built-in security features that integrate well with the Proxy pattern:

#### System Variables:
- **$USERNAME**: Current logged-in user
- **$ROLES**: Comma-separated list of user's roles
- **$NAMESPACE**: Current namespace

#### Security Classes:
```objectscript
// Check resource permissions
Set hasAccess = $SYSTEM.Security.Check("%Development", "USE")

// Check if user has specific role
Set hasRole = $SYSTEM.Security.CheckUserRole($USERNAME, "PatternAdmin")

// Audit security events
Do $SYSTEM.Security.Audit("Application", "DataAccess", 
    "User " _ $USERNAME _ " accessed patient record")
```

#### Resource and Role Creation:
```objectscript
// Create a resource
Set sc = ##class(Security.Resources).Create("PatientData", 
    "Protected patient data resource", "")

// Create a role with permissions
Set sc = ##class(Security.Roles).Create("PatternDoctor", 
    "Doctor role with full patient access", 
    "%DB_USER:RW,PatientData:RWU")

// Grant role to user
Set sc = ##class(Security.Users).AddRoles($USERNAME, "PatternDoctor")
```

#### Dynamic Permission Checking:
```objectscript
Method CheckDynamicPermission(pResource As %String, pPermission As %String) As %Boolean
{
    // Check specific permission on resource
    If pPermission = "READ" {
        Quit $SYSTEM.Security.Check(pResource, "R")
    } ElseIf pPermission = "WRITE" {
        Quit $SYSTEM.Security.Check(pResource, "W")
    } ElseIf pPermission = "DELETE" {
        Quit $SYSTEM.Security.Check(pResource, "D")
    }
    Quit 0
}
```

#### Audit Logging with %SYS.Audit:
```objectscript
Method LogToSystemAudit(pEvent As %String, pDetails As %String)
{
    // Enable audit events
    Do ##class(Security.Events).Enable("UserChange")
    
    // Log custom event
    Set tEvent = ##class(%SYS.Audit).%New()
    Set tEvent.EventType = "PatientAccess"
    Set tEvent.EventData = pDetails
    Set tEvent.Username = $USERNAME
    Set tEvent.UTCTimeStamp = $ZDT($ZTS, 3, 1)
    Do tEvent.%Save()
}
```

### Healthcare Security Best Practices:

1. **HIPAA Compliance**:
   - Log all access attempts
   - Track who accessed what data and when
   - Implement minimum necessary access principle

2. **Role-Based Access Control (RBAC)**:
   ```objectscript
   Parameter ACCESSMATRIX = {
       "Doctor": {"medical": true, "billing": true, "ssn": true},
       "Nurse": {"medical": true, "billing": false, "ssn": false},
       "Billing": {"medical": false, "billing": true, "ssn": "masked"},
       "Admin": {"medical": false, "billing": true, "ssn": false, "delete": true}
   }
   ```

3. **Data Masking**:
   ```objectscript
   Method MaskSSN(pSSN As %String) As %String
   {
       If $L(pSSN) '= 11 Quit "XXX-XX-XXXX"
       Quit "XXX-XX-" _ $E(pSSN, 8, 11)
   }
   ```

4. **Audit Trail Requirements**:
   - User identification
   - Date and time of access
   - Type of action performed
   - Patient identifier
   - Success or failure of access attempt

## Sample Code

### Complete Healthcare Proxy Example:

```objectscript
/// Healthcare proxy with protection and virtual proxy features
Class Patterns.Examples.PatientDataProxy Extends %RegisteredObject
{
    Property RealService As PatientDataService;
    Property UserRole As %String;
    Property IsServiceLoaded As %Boolean [ InitialExpression = 0 ];
    Property CachedData As %ArrayOfDataTypes;
    
    Method GetPatientRecord(pPatientId As %String) As %DynamicObject
    {
        // Check permission based on role
        If '..CheckPermission("fullRecord") {
            If ..UserRole = "Nurse" {
                Quit ..GetPatientMedicalInfo(pPatientId)
            } ElseIf ..UserRole = "Billing" {
                Quit ..GetPatientBillingInfo(pPatientId)
            }
            Quit ""  // Access denied
        }
        
        // Lazy load service
        If '..IsServiceLoaded {
            Set ..RealService = ##class(PatientDataService).%New()
            Set ..IsServiceLoaded = 1
        }
        
        // Check cache first (virtual proxy behavior)
        If ..CachedData.IsDefined(pPatientId) {
            Quit ..CachedData.GetAt(pPatientId)
        }
        
        // Get and cache data
        Set tPatient = ..RealService.GetPatientRecord(pPatientId)
        
        // Apply data masking if needed
        If ..UserRole '= "Doctor" {
            Set tPatient = ..MaskSensitiveData(tPatient)
        }
        
        // Cache for future use
        Do ..CachedData.SetAt(tPatient, pPatientId)
        
        // Log access for HIPAA compliance
        Do ..LogAccess("PATIENT_ACCESS", pPatientId, $USERNAME)
        
        Quit tPatient
    }
    
    Method CheckPermission(pOperation As %String) As %Boolean
    {
        // Role-based permission check
        Set tMatrix = {}.%FromJSON(..#ACCESSMATRIX)
        Set tRolePerms = tMatrix.%Get(..UserRole)
        
        If 'tRolePerms.%IsDefined(pOperation) Quit 0
        Quit tRolePerms.%Get(pOperation)
    }
}
```

### Using the Proxy:

```objectscript
// Doctor accessing patient data
Set doctorProxy = ##class(PatientDataProxy).%New("Doctor", "Dr. Smith")
Set patientData = doctorProxy.GetPatientRecord("PAT001")
// Full access, including SSN and medical history

// Nurse accessing same patient
Set nurseProxy = ##class(PatientDataProxy).%New("Nurse", "Nurse Johnson")  
Set patientData = nurseProxy.GetPatientRecord("PAT001")
// Limited to medical information only

// Billing department
Set billingProxy = ##class(PatientDataProxy).%New("Billing", "Bill Clerk")
Set patientData = billingProxy.GetPatientRecord("PAT001")
// SSN is masked, no medical details

// Virtual proxy benefit - second access is cached
Set patientData2 = doctorProxy.GetPatientRecord("PAT001")
// Returns immediately from cache, no service call
```

## Known Uses

### In IRIS/ObjectScript:
- **%SQL.Statement**: Acts as a proxy for SQL queries
- **%Stream classes**: Virtual proxies for large data
- **EnsLib.HL7.Message**: Proxy for HL7 message segments
- **%CSP.Session**: Proxy for session data

### In Healthcare Systems:
- **Electronic Health Records (EHR)**: Access control for patient data
- **PACS Systems**: Virtual proxies for medical images
- **HIE (Health Information Exchange)**: Remote proxies for distributed data
- **Billing Systems**: Protection proxies for financial data

## Related Patterns

### Decorator
- Both add functionality, but Decorator focuses on adding responsibilities while Proxy focuses on controlling access
- Decorator is recursive, Proxy typically isn't

### Adapter
- Adapter changes interface, Proxy provides the same interface
- Adapter is about interface compatibility, Proxy is about access control

### Facade
- Facade simplifies interface to subsystem, Proxy controls access to single object
- Facade is "many-to-one", Proxy is "one-to-one"

## Summary

The Proxy pattern is essential for controlling object access in ObjectScript applications. Its three main variants address different concerns:

1. **Virtual Proxy**: Optimizes performance through lazy loading
2. **Protection Proxy**: Enforces security policies
3. **Remote Proxy**: Enables distributed computing

In healthcare applications, proxies are particularly valuable for:
- Implementing HIPAA-compliant access controls
- Optimizing access to large medical images
- Providing role-based data filtering
- Creating comprehensive audit trails

The pattern integrates seamlessly with IRIS security features, making it ideal for enterprise healthcare applications where data protection and performance are critical.
