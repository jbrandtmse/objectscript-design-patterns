/// Active Patient Specification
/// 
/// Specification for finding patients with Active status
/// 
/// Example:
/// <example>
/// Set spec = ##class(Patterns.Examples.Clinical.ActivePatientSpec).%New()
/// Set activePatients = repository.FindBySpecification(spec)
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.Specification
/// @see Patterns.Examples.Clinical.PatientRepository
/// @since 1.0.0
Class Patterns.Examples.Clinical.ActivePatientSpec Extends Patterns.PoEAA.ObjectRelational.Specification
{

/// Convert specification to SQL WHERE clause
/// 
/// @return SQL WHERE clause for active patients
Method ToSQL() As %String
{
    Set tSQL = "Status = 'Active'"
    Quit tSQL
}

/// Check if patient satisfies this specification
/// 
/// @param pPatient Patient object to test
/// @return 1 if patient is active, 0 otherwise
Method IsSatisfiedBy(pObject As %RegisteredObject) As %Boolean
{
    Set tSatisfied = 0
    
    Try {
        If $IsObject(pObject) && pObject.%IsA("Patterns.Examples.Clinical.Patient") {
            Set tSatisfied = (pObject.Status = "Active")
        }
        
    } Catch ex {
        Set tSatisfied = 0
    }
    
    Quit tSatisfied
}

}
