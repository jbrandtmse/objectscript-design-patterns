/// Null Object Pattern - Special Case Variant
/// 
/// Intent:
/// Provide a polymorphic null object that eliminates the need for null checking
/// by implementing the same interface as real objects with safe default behaviors.
/// 
/// Motivation:
/// Clients constantly checking for null clutter code and are error-prone. A null object
/// provides safe default behaviors, allowing clients to treat null and real objects uniformly.
/// 
/// Applicability:
/// - Many clients check for null and execute the same default behavior
/// - You want to eliminate null checks throughout the codebase
/// - Safe default behaviors are well-defined
/// - Operations on null should be no-ops that don't fail
/// 
/// Structure:
/// <example>
/// Set patient = ##class(NullPatient).%New()
/// If patient.IsNull() {
///     Write "This is a null object"
/// }
/// </example>
/// 
/// @see Patterns.PoEAA.Base.SpecialCase
/// @since 1.0.0
Class Patterns.PoEAA.Base.NullObject Extends Patterns.PoEAA.Base.SpecialCase
{

/// Pattern version
Parameter VERSION = "1.0.0";

/// Pattern type
Parameter PATTERNTYPE = "PoEAA-NullObject";

/// Indicates this is a null object
/// 
/// @return %Boolean - Always returns 1 for null objects
Method IsNull() As %Boolean
{
    Quit 1
}

/// Factory method to create a null object
/// 
/// @return NullObject - A null object instance
ClassMethod CreateNullObject() As Patterns.PoEAA.Base.NullObject
{
    Quit ..%New()
}

/// Safe no-op operation for null objects
/// Override in subclasses to provide specific no-op behaviors
/// 
/// @return %Status - Always returns $$$OK
Method Execute() As %Status
{
    // No-op for null object
    Quit $$$OK
}

/// Safe no-op save operation
/// 
/// @return %Status - Always returns $$$OK without persisting
Method Save() As %Status
{
    // No-op for null object
    Quit $$$OK
}

/// Safe no-op delete operation
/// 
/// @return %Status - Always returns $$$OK without deleting
Method Delete() As %Status
{
    // No-op for null object
    Quit $$$OK
}

}
