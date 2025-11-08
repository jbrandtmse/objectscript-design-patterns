/// Healthcare Service Registry - Registry Pattern Example
/// 
/// Intent:
/// Provide a centralized registry for healthcare services with convenient
/// access methods for well-known services.
/// 
/// Motivation:
/// In a healthcare application, multiple services need to be accessed from
/// various parts of the system. Rather than passing service references through
/// multiple layers or creating tight coupling, the HealthcareServiceRegistry
/// provides a single point of access for all healthcare services.
/// 
/// Structure:
/// Extends the base Registry pattern with healthcare-specific initialization
/// and convenience methods for common services.
/// 
/// @see Patterns.PoEAA.Base.Registry
/// @since 1.0.0
Class Patterns.Examples.Clinical.HealthcareServiceRegistry Extends Patterns.PoEAA.Base.Registry
{

// ===== PARAMETERS =====

Parameter VERSION = "1.0.0";

// ===== CLASS METHODS =====

/// Get the singleton instance of the Healthcare Service Registry
/// Returns THE SAME instance stored in database
/// 
/// @return HealthcareServiceRegistry The global healthcare service registry
ClassMethod GetInstance() As Patterns.Examples.Clinical.HealthcareServiceRegistry
{
    // Get base Registry singleton
    Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).GetInstance()
    
    // Auto-initialize services if not already done
    If 'tRegistry.Contains("PatientService") {
        Do ..InitializeServices()
    }
    
    // Return the registry (typed as HealthcareServiceRegistry for convenience methods)
    Quit tRegistry
}

/// Initialize the registry with well-known healthcare services
/// Uses base Registry singleton to store services
/// 
/// @return %Status Success or error status
ClassMethod InitializeServices() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Get base Registry singleton and register services
        Set tRegistry = ##class(Patterns.PoEAA.Base.Registry).GetInstance()
        
        Set tSC = tRegistry.Set("PatientService", ##class(Patterns.Examples.Clinical.PatientService).%New())
        If $$$ISERR(tSC) Quit
        
        Set tSC = tRegistry.Set("EncounterService", ##class(Patterns.Examples.Clinical.EncounterService).%New())
        If $$$ISERR(tSC) Quit
        
        Set tSC = tRegistry.Set("BillingService", ##class(Patterns.Examples.Clinical.BillingService).%New())
        If $$$ISERR(tSC) Quit
        
        Set tSC = tRegistry.Set("NotificationService", ##class(Patterns.Examples.Clinical.NotificationService).%New())
        If $$$ISERR(tSC) Quit
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Reinitialize the registry with fresh service instances
/// Useful for testing or when services need to be reset
/// 
/// @return %Status Success or error status
ClassMethod Reinitialize() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear the singleton from database
        Do ##class(Patterns.PoEAA.Base.Registry).ClearSingletons()
        
        // Reinitialize services (will auto-create new singleton)
        Set tSC = ..InitializeServices()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the PatientService from the registry
/// 
/// @return PatientService The patient service instance
ClassMethod GetPatientService() As Patterns.Examples.Clinical.PatientService
{
    Set tRegistry = ..GetInstance()
    Quit tRegistry.Get("PatientService")
}

/// Get the EncounterService from the registry
/// 
/// @return EncounterService The encounter service instance
ClassMethod GetEncounterService() As Patterns.Examples.Clinical.EncounterService
{
    Set tRegistry = ..GetInstance()
    Quit tRegistry.Get("EncounterService")
}

/// Get the BillingService from the registry
/// 
/// @return BillingService The billing service instance
ClassMethod GetBillingService() As Patterns.Examples.Clinical.BillingService
{
    Set tRegistry = ..GetInstance()
    Quit tRegistry.Get("BillingService")
}

/// Get the NotificationService from the registry
/// 
/// @return NotificationService The notification service instance
ClassMethod GetNotificationService() As Patterns.Examples.Clinical.NotificationService
{
    Set tRegistry = ..GetInstance()
    Quit tRegistry.Get("NotificationService")
}

/// Check if all required healthcare services are registered
/// 
/// @return %Boolean True if all services are registered, false otherwise
ClassMethod ValidateServices() As %Boolean
{
    Set tRegistry = ..GetInstance()
    
    // Check for required services
    If 'tRegistry.Contains("PatientService") Quit 0
    If 'tRegistry.Contains("EncounterService") Quit 0
    If 'tRegistry.Contains("BillingService") Quit 0
    If 'tRegistry.Contains("NotificationService") Quit 0
    
    Quit 1
}

/// Get a list of all registered healthcare services
/// 
/// @return %List List of service names
ClassMethod GetRegisteredServices() As %List
{
    Set tRegistry = ..GetInstance()
    Quit tRegistry.GetKeys()
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
