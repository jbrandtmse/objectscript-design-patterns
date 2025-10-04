/// PoEAA Domain Model Pattern - Rich Business Objects with Encapsulated Behavior
/// 
/// Intent:
/// Create a rich object model that contains both business data and business logic,
/// with objects that encapsulate behavior and maintain their own invariants.
/// 
/// Motivation:
/// As business logic grows more complex, procedural Transaction Scripts become harder
/// to maintain. Domain Model organizes business logic into a network of interconnected
/// objects that mirror the problem domain, making the code more maintainable and testable.
/// 
/// Applicability:
/// Use Domain Model when:
/// - You have complex business logic with many rules and interactions
/// - Business rules change frequently and need to be easily maintainable
/// - You need rich object behaviors beyond simple data holders
/// - The domain model provides clear conceptual clarity
/// - You need to unit test business logic in isolation from database
/// 
/// Structure:
/// Domain objects are rich with both data and behavior. They validate their own
/// invariants and encapsulate business rules. Objects form a network of relationships
/// that model the problem domain.
/// 
/// @see Patterns.PoEAA.DomainLogic.TransactionScript
/// @since 1.0.0
Class Patterns.PoEAA.DomainLogic.DomainModel Extends %RegisteredObject [ Abstract ]
{

/// Pattern version
Parameter VERSION = "1.0.0";

/// Pattern type classification
Parameter PATTERNTYPE = "Domain Logic";

/// Pattern category (PoEAA)
Parameter CATEGORY = "PoEAA";

/// Domain object unique identifier
Property Identity As %String;

/// Validation errors collection
Property ValidationErrors [ MultiDimensional ];

/// Indicates if object is in valid state
Property IsValid As %Boolean [ InitialExpression = 0 ];

/// Domain events raised by this object
Property DomainEvents [ MultiDimensional ];

/// Initialize domain object with identity
Method %OnNew(pIdentity As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Assign identity
        If (pIdentity = "") {
            Set ..Identity = ..GenerateIdentity()
        } Else {
            Set ..Identity = pIdentity
        }
        
        // Initialize collections
        Kill ..ValidationErrors
        Kill ..DomainEvents
        
        // Set initial state
        Set ..IsValid = 0
        
        // Perform domain-specific initialization
        Set tSC = ..Initialize()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Domain-specific initialization (override in subclasses)
Method Initialize() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Generate unique identity for domain object
Method GenerateIdentity() As %String
{
    Quit $SYSTEM.Util.CreateGUID()
}

/// Validate all business rules and invariants
Method ValidateRules() As %Status
{
    Set tSC = $$$OK
    Set tResult = ""
    Try {
        // Clear previous validation errors
        Kill ..ValidationErrors
        Set ..IsValid = 0
        
        // Check domain invariants
        Set tResult = ..CheckInvariants()
        If 'tResult {
            Set tSC = $$$ERROR($$$GeneralError, "Domain invariants violated")
            Quit
        }
        
        // Perform domain-specific validation
        Set tSC = ..PerformValidation()
        If $$$ISERR(tSC) Quit
        
        // Mark as valid if all checks passed
        Set ..IsValid = 1
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Check domain object invariants (override in subclasses)
/// @return 1 if invariants are satisfied, 0 otherwise
Method CheckInvariants() As %Boolean [ Abstract ]
{
    Quit 1
}

/// Perform domain-specific validation (override in subclasses)
Method PerformValidation() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Add validation error
/// @param pField Field name that failed validation
/// @param pMessage Error message
Method AddValidationError(pField As %String, pMessage As %String)
{
    Set tErrorCount = $GET(..ValidationErrors)
    Set tErrorCount = tErrorCount + 1
    Set ..ValidationErrors = tErrorCount
    Set ..ValidationErrors(tErrorCount, "field") = pField
    Set ..ValidationErrors(tErrorCount, "message") = pMessage
    Set ..IsValid = 0
}

/// Get all validation errors
/// @return Dynamic array of validation errors
Method GetValidationErrors() As %DynamicArray
{
    Set tErrors = []
    Set tCount = $GET(..ValidationErrors)
    For tIndex = 1:1:tCount {
        Set tError = {}
        Set tError.field = $GET(..ValidationErrors(tIndex, "field"))
        Set tError.message = $GET(..ValidationErrors(tIndex, "message"))
        Do tErrors.%Push(tError)
    }
    Quit tErrors
}

/// Check if object has validation errors
/// @return 1 if errors exist, 0 otherwise
Method HasValidationErrors() As %Boolean
{
    Set tCount = $GET(..ValidationErrors)
    Quit (tCount > 0)
}

/// Execute business logic (override in subclasses)
Method ExecuteBusinessLogic() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Raise a domain event
/// @param pEventType Type of domain event
/// @param pEventData Event data as dynamic object
Method RaiseDomainEvent(pEventType As %String, pEventData As %DynamicObject = "")
{
    Set tEventCount = $GET(..DomainEvents)
    Set tEventCount = tEventCount + 1
    Set ..DomainEvents = tEventCount
    Set ..DomainEvents(tEventCount, "type") = pEventType
    Set ..DomainEvents(tEventCount, "timestamp") = $ZDATETIME($HOROLOG, 3)
    If ($ISOBJECT(pEventData)) {
        Set ..DomainEvents(tEventCount, "data") = pEventData.%ToJSON()
    }
}

/// Get all domain events raised
/// @return Dynamic array of domain events
Method GetDomainEvents() As %DynamicArray
{
    Set tEvents = []
    Set tCount = $GET(..DomainEvents)
    For tIndex = 1:1:tCount {
        Set tEvent = {}
        Set tEvent.type = $GET(..DomainEvents(tIndex, "type"))
        Set tEvent.timestamp = $GET(..DomainEvents(tIndex, "timestamp"))
        Set tEventData = $GET(..DomainEvents(tIndex, "data"))
        If (tEventData '= "") {
            Set tEvent.data = {}.%FromJSON(tEventData)
        }
        Do tEvents.%Push(tEvent)
    }
    Quit tEvents
}

/// Clear all domain events
Method ClearDomainEvents()
{
    Kill ..DomainEvents
}

/// String representation of domain object
Method ToString() As %String
{
    Quit ..%ClassName(1) _ " [Identity: " _ ..Identity _ "]"
}

}
