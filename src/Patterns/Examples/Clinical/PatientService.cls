/// Patient Service - Healthcare Service Example
/// 
/// A service class for managing patient operations.
/// Used to demonstrate the Registry pattern for service location.
Class Patterns.Examples.Clinical.PatientService Extends %RegisteredObject
{

/// Get patient by ID
Method GetPatientById(pPatientId As %String) As %String
{
    // Stub implementation for demonstration
    Quit "Patient[" _ pPatientId _ "]"
}

/// Search patients by criteria
Method SearchPatients(pCriteria As %String) As %List
{
    // Stub implementation for demonstration
    Quit $ListBuild("Patient1", "Patient2", "Patient3")
}

/// Register new patient
Method RegisterPatient(pPatientData As %String) As %Status
{
    // Stub implementation for demonstration
    Quit $$$OK
}

}
