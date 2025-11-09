/// Special Case Pattern - Base Class
/// 
/// Intent:
/// Provide a polymorphic alternative to null checking by creating special case objects
/// that implement the same interface as real objects but provide default behaviors.
/// 
/// Motivation:
/// Null checking clutters code and is error-prone. Special Case objects eliminate null
/// checks by providing safe default behaviors that clients can call without conditionals.
/// 
/// Applicability:
/// - Many clients check for null and execute the same default behavior
/// - Null objects need to behave polymorphically with real objects
/// - You want to eliminate conditional logic for missing data
/// - Default behaviors are well-defined and stable
/// 
/// Structure:
/// <example>
/// Set patient = ##class(NullPatient).%New()
/// Write patient.GetDisplayName()  // Returns "Unknown Patient" - no null check needed
/// </example>
/// 
/// @see Patterns.PoEAA.Base.ValueObject
/// @since 1.0.0
Class Patterns.PoEAA.Base.SpecialCase Extends %RegisteredObject [ Abstract ]
{

/// Pattern version
Parameter VERSION = "1.0.0";

/// Pattern type
Parameter PATTERNTYPE = "PoEAA-Base";

/// Indicates if this is a null object
/// Override in subclasses to return 1 for null objects
/// 
/// @return %Boolean - 1 if this is a null object, 0 otherwise
Method IsNull() As %Boolean
{
    Quit 0
}

/// Indicates if this is a special case object
/// All special cases return 1 to identify themselves
/// 
/// @return %Boolean - Always returns 1 for special case objects
Method IsSpecialCase() As %Boolean
{
    Quit 1
}

/// Factory method to create a null object variant
/// Override in subclasses to provide specific null object types
/// 
/// @return SpecialCase - A null object instance
ClassMethod CreateNullObject() As SpecialCase
{
    // Abstract method - subclasses must implement
    Quit $$$NULLOREF
}

/// Factory method to create an unknown case variant
/// Override in subclasses to provide specific unknown case types
/// 
/// @return SpecialCase - An unknown case instance
ClassMethod CreateUnknownCase() As SpecialCase
{
    // Abstract method - subclasses must implement
    Quit $$$NULLOREF
}

/// Factory method to create a default case variant
/// Override in subclasses to provide specific default case types
/// 
/// @return SpecialCase - A default case instance
ClassMethod CreateDefaultCase() As SpecialCase
{
    // Abstract method - subclasses must implement
    Quit $$$NULLOREF
}

/// Provides safe navigation by returning this object
/// Allows chaining without null checks
/// 
/// @return SpecialCase - Returns self for safe navigation
Method SafeNavigate() As SpecialCase
{
    Quit $this
}

}
