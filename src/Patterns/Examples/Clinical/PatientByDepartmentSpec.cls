/// Patient By Department Specification
/// 
/// Specification for finding patients in a specific department
/// 
/// Example:
/// <example>
/// Set spec = ##class(Patterns.Examples.Clinical.PatientByDepartmentSpec).%New()
/// Set spec.Department = "Cardiology"
/// Set cardiologyPatients = repository.FindBySpecification(spec)
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.Specification
/// @see Patterns.Examples.Clinical.PatientRepository
/// @since 1.0.0
Class Patterns.Examples.Clinical.PatientByDepartmentSpec Extends Patterns.PoEAA.ObjectRelational.Specification
{

/// Department name to filter by
Property Department As %String;

/// Convert specification to SQL WHERE clause
/// 
/// @return SQL WHERE clause for department filter
Method ToSQL() As %String
{
    Set tSQL = ""
    
    Try {
        If (..Department '= "") {
            Set tSQL = "Department = '" _ ..Department _ "'"
        }
        
    } Catch ex {
        Set tSQL = ""
    }
    
    Quit tSQL
}

/// Check if patient satisfies this specification
/// 
/// @param pPatient Patient object to test
/// @return 1 if patient is in the specified department, 0 otherwise
Method IsSatisfiedBy(pObject As %RegisteredObject) As %Boolean
{
    Set tSatisfied = 0
    
    Try {
        If $IsObject(pObject) && pObject.%IsA("Patterns.Examples.Clinical.Patient") {
            Set tSatisfied = (pObject.Department = ..Department)
        }
        
    } Catch ex {
        Set tSatisfied = 0
    }
    
    Quit tSatisfied
}

}
