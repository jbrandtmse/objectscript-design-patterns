/// Unknown Case Pattern - Special Case Variant
/// 
/// Intent:
/// Provide a polymorphic object representing unknown or missing data
/// with safe default behaviors that prevent errors in client code.
/// 
/// Motivation:
/// Systems often encounter unknown or missing data. Instead of null or exceptions,
/// an unknown case object provides meaningful defaults and allows processing to continue.
/// 
/// Applicability:
/// - Data is temporarily unavailable but processing should continue
/// - You want to provide default values for missing information
/// - Unknown status needs to be distinguishable from null
/// - Clients need to detect and handle unknown cases specially
/// 
/// Structure:
/// <example>
/// Set patient = ##class(UnknownPatient).%New()
/// Write patient.GetDisplayName()  // Returns "Unknown Patient"
/// If 'patient.IsNull() && patient.IsSpecialCase() {
///     Write "This is an unknown case"
/// }
/// </example>
/// 
/// @see Patterns.PoEAA.Base.SpecialCase
/// @since 1.0.0
Class Patterns.PoEAA.Base.UnknownCase Extends Patterns.PoEAA.Base.SpecialCase
{

/// Pattern version
Parameter VERSION = "1.0.0";

/// Pattern type
Parameter PATTERNTYPE = "PoEAA-UnknownCase";

/// Default display value for unknown cases
Parameter UNKNOWNLABEL = "Unknown";

/// Indicates this is not a null object (but is a special case)
/// 
/// @return %Boolean - Returns 0 for unknown cases
Method IsNull() As %Boolean
{
    Quit 0
}

/// Factory method to create an unknown case
/// 
/// @return UnknownCase - An unknown case instance
ClassMethod CreateUnknownCase() As Patterns.PoEAA.Base.UnknownCase
{
    Quit ..%New()
}

/// Get the default display label for unknown cases
/// 
/// @return %String - The unknown label
Method GetDisplayLabel() As %String
{
    Quit ..#UNKNOWNLABEL
}

/// Safe operation that acknowledges unknown status
/// Override in subclasses to provide specific behaviors
/// 
/// @return %Status - Always returns $$$OK
Method Execute() As %Status
{
    // Safe default behavior for unknown case
    Quit $$$OK
}

}
