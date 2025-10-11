/// NOT Composite Specification
/// 
/// Intent:
/// Negates a specification using NOT logic, inverting the satisfaction result.
/// 
/// Structure:
/// Contains reference to a specification and returns the opposite result.
/// 
/// <example>
/// Set notSpec = activeSpec.Not()
/// Set inactivePatients = repository.FindBySpecification(notSpec)
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.Specification
/// @since 1.0.0
Class Patterns.PoEAA.ObjectRelational.NotSpecification Extends Patterns.PoEAA.ObjectRelational.Specification
{

// ===== PROPERTIES =====

/// The specification to negate
Property Spec As Patterns.PoEAA.ObjectRelational.Specification;

// ===== IMPLEMENTED METHODS =====

/// Convert to SQL WHERE clause negating the specification with NOT
/// 
/// @return Negated SQL WHERE clause
Method ToSQL() As %String
{
    Set tSQL = ""
    
    Try {
        If $IsObject(..Spec) {
            Set tSpecSQL = ..Spec.ToSQL()
            
            If (tSpecSQL '= "") {
                Set tSQL = "NOT (" _ tSpecSQL _ ")"
            }
        }
        
    } Catch ex {
        Set tSQL = ""
    }
    
    Quit tSQL
}

/// Check if object does NOT satisfy the specification
/// 
/// @param pObject Object to test
/// @return 1 if object does NOT satisfy the specification
Method IsSatisfiedBy(pObject As %RegisteredObject) As %Boolean
{
    Set tSatisfied = 0
    
    Try {
        If $IsObject(..Spec) {
            Set tSatisfied = '..Spec.IsSatisfiedBy(pObject)
        }
        
    } Catch ex {
        Set tSatisfied = 0
    }
    
    Quit tSatisfied
}

}
