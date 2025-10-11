/// Specification Pattern Interface
/// 
/// Intent:
/// Encapsulates query criteria in reusable, composable objects that can be
/// combined to build complex queries while maintaining domain logic separation.
/// 
/// Motivation:
/// When using the Repository pattern, you need a flexible way to specify query
/// criteria without coupling the repository to specific query implementations.
/// The Specification pattern provides a way to encapsulate query logic in
/// objects that can be combined and reused.
/// 
/// Structure:
/// Specifications translate domain criteria into SQL queries or other query
/// mechanisms. They can be combined using AND, OR, and NOT operations.
/// 
/// Applicability:
/// - You need flexible query criteria that can be combined
/// - Query logic should be reusable across multiple repositories
/// - Domain queries should be expressed in business terms
/// - You want to avoid repository method explosion
/// 
/// <example>
/// Set spec = ##class(PatientByDepartmentSpec).%New()
/// Set spec.Department = "Cardiology"
/// Set patients = repository.FindBySpecification(spec)
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.Repository
/// @since 1.0.0
Class Patterns.PoEAA.ObjectRelational.Specification Extends %RegisteredObject [ Abstract ]
{

/// Version of the Specification pattern implementation
Parameter VERSION = "1.0.0";

/// Pattern type classification
Parameter PATTERNTYPE = "Object-Relational Behavioral";

// ===== ABSTRACT METHODS =====

/// Convert this specification to SQL WHERE clause
/// 
/// @return SQL WHERE clause as string (without the WHERE keyword)
/// 
/// Subclasses must implement this to provide specific query logic
/// 
/// Example:
/// <example>
/// Method ToSQL() As %String
/// {
///     Quit "Department = '" _ ..Department _ "'"
/// }
/// </example>
Method ToSQL() As %String [ Abstract ]
{
    Quit ""
}

/// Determine if this specification is satisfied by the given object
/// 
/// @param pObject Object to test against specification
/// @return 1 if object satisfies specification, 0 otherwise
/// 
/// Allows in-memory filtering without database queries
/// 
/// Example:
/// <example>
/// Method IsSatisfiedBy(pPatient) As %Boolean
/// {
///     Quit (pPatient.Department = ..Department)
/// }
/// </example>
Method IsSatisfiedBy(pObject As %RegisteredObject) As %Boolean [ Abstract ]
{
    Quit 0
}

// ===== COMPOSITE SPECIFICATION METHODS =====

/// Combine this specification with another using AND logic
/// 
/// @param pOtherSpec Specification to combine with
/// @return New specification representing AND combination
/// 
/// Example:
/// <example>
/// Set combinedSpec = deptSpec.And(statusSpec)
/// </example>
Method And(pOtherSpec As Specification) As Specification
{
    Set tAndSpec = ""
    
    Try {
        Set tAndSpec = ##class(AndSpecification).%New()
        Set tAndSpec.LeftSpec = $THIS
        Set tAndSpec.RightSpec = pOtherSpec
        
    } Catch ex {
        Set tAndSpec = ""
    }
    
    Quit tAndSpec
}

/// Combine this specification with another using OR logic
/// 
/// @param pOtherSpec Specification to combine with
/// @return New specification representing OR combination
/// 
/// Example:
/// <example>
/// Set combinedSpec = deptSpec.Or(otherDeptSpec)
/// </example>
Method Or(pOtherSpec As Specification) As Specification
{
    Set tOrSpec = ""
    
    Try {
        Set tOrSpec = ##class(OrSpecification).%New()
        Set tOrSpec.LeftSpec = $THIS
        Set tOrSpec.RightSpec = pOtherSpec
        
    } Catch ex {
        Set tOrSpec = ""
    }
    
    Quit tOrSpec
}

/// Negate this specification using NOT logic
/// 
/// @return New specification representing negation
/// 
/// Example:
/// <example>
/// Set notSpec = activeSpec.Not()
/// </example>
Method Not() As Specification
{
    Set tNotSpec = ""
    
    Try {
        Set tNotSpec = ##class(NotSpecification).%New()
        Set tNotSpec.Spec = $THIS
        
    } Catch ex {
        Set tNotSpec = ""
    }
    
    Quit tNotSpec
}

}
