/// Notification Service - Healthcare Service Example
/// 
/// A service class for managing notifications and alerts.
/// Used to demonstrate the Registry pattern for service location.
Class Patterns.Examples.Clinical.NotificationService Extends %RegisteredObject
{

/// Send notification to patient
Method SendNotification(pPatientId As %String, pMessage As %String) As %Status
{
    // Stub implementation for demonstration
    Quit $$$OK
}

/// Send alert to healthcare provider
Method SendAlert(pProviderId As %String, pAlertType As %String) As %Status
{
    // Stub implementation for demonstration
    Quit $$$OK
}

/// Get notification history
Method GetNotificationHistory(pPatientId As %String) As %List
{
    // Stub implementation for demonstration
    Quit $ListBuild("Notification1", "Notification2")
}

}
