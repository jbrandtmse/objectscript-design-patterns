/// OR Composite Specification
/// 
/// Intent:
/// Combines two specifications using OR logic, satisfied if either is satisfied.
/// 
/// Structure:
/// Contains references to two specifications and evaluates both,
/// returning true if either one is satisfied.
/// 
/// <example>
/// Set combinedSpec = deptSpec.Or(otherDeptSpec)
/// Set patients = repository.FindBySpecification(combinedSpec)
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.Specification
/// @since 1.0.0
Class Patterns.PoEAA.ObjectRelational.OrSpecification Extends Patterns.PoEAA.ObjectRelational.Specification
{

// ===== PROPERTIES =====

/// Left side specification
Property LeftSpec As Patterns.PoEAA.ObjectRelational.Specification;

/// Right side specification
Property RightSpec As Patterns.PoEAA.ObjectRelational.Specification;

// ===== IMPLEMENTED METHODS =====

/// Convert to SQL WHERE clause combining both specifications with OR
/// 
/// @return Combined SQL WHERE clause
Method ToSQL() As %String
{
    Set tSQL = ""
    
    Try {
        If $IsObject(..LeftSpec) && $IsObject(..RightSpec) {
            Set tLeftSQL = ..LeftSpec.ToSQL()
            Set tRightSQL = ..RightSpec.ToSQL()
            
            If (tLeftSQL '= "") && (tRightSQL '= "") {
                Set tSQL = "(" _ tLeftSQL _ ") OR (" _ tRightSQL _ ")"
            } ElseIf (tLeftSQL '= "") {
                Set tSQL = tLeftSQL
            } ElseIf (tRightSQL '= "") {
                Set tSQL = tRightSQL
            }
        }
        
    } Catch ex {
        Set tSQL = ""
    }
    
    Quit tSQL
}

/// Check if object satisfies either specification
/// 
/// @param pObject Object to test
/// @return 1 if object satisfies either specification
Method IsSatisfiedBy(pObject As %RegisteredObject) As %Boolean
{
    Set tSatisfied = 0
    
    Try {
        If $IsObject(..LeftSpec) && $IsObject(..RightSpec) {
            Set tSatisfied = ..LeftSpec.IsSatisfiedBy(pObject) || ..RightSpec.IsSatisfiedBy(pObject)
        }
        
    } Catch ex {
        Set tSatisfied = 0
    }
    
    Quit tSatisfied
}

}
