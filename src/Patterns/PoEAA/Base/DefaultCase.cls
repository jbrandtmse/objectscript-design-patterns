/// Default Case Pattern - Special Case Variant
/// 
/// Intent:
/// Provide a polymorphic object with sensible default behaviors
/// that can be used when specific data is unavailable but processing should continue.
/// 
/// Motivation:
/// Applications often need default behaviors when data is missing. A default case object
/// provides consistent, safe defaults without requiring null checks or special handling.
/// 
/// Applicability:
/// - You need consistent default behaviors across the application
/// - Missing data should use well-defined defaults
/// - You want to eliminate conditional logic for default cases
/// - Default values are stable and well understood
/// 
/// Structure:
/// <example>
/// Set config = ##class(DefaultConfiguration).%New()
/// Set timeout = config.GetTimeout()  // Returns default timeout value
/// </example>
/// 
/// @see Patterns.PoEAA.Base.SpecialCase
/// @since 1.0.0
Class Patterns.PoEAA.Base.DefaultCase Extends Patterns.PoEAA.Base.SpecialCase
{

/// Pattern version
Parameter VERSION = "1.0.0";

/// Pattern type
Parameter PATTERNTYPE = "PoEAA-DefaultCase";

/// Default value indicator
Parameter ISDEFAULT = 1;

/// Indicates this is not a null object
/// 
/// @return %Boolean - Returns 0 for default cases
Method IsNull() As %Boolean
{
    Quit 0
}

/// Indicates this is a default case
/// 
/// @return %Boolean - Returns 1 to indicate default case
Method IsDefault() As %Boolean
{
    Quit ..#ISDEFAULT
}

/// Factory method to create a default case
/// 
/// @return DefaultCase - A default case instance
ClassMethod CreateDefaultCase() As Patterns.PoEAA.Base.DefaultCase
{
    Quit ..%New()
}

/// Get a default string value
/// Override in subclasses to provide specific defaults
/// 
/// @return %String - Empty string by default
Method GetDefaultValue() As %String
{
    Quit ""
}

/// Get a default numeric value
/// Override in subclasses to provide specific defaults
/// 
/// @return %Numeric - Zero by default
Method GetDefaultNumeric() As %Numeric
{
    Quit 0
}

/// Safe operation with default behavior
/// Override in subclasses to provide specific behaviors
/// 
/// @return %Status - Always returns $$$OK
Method Execute() As %Status
{
    // Safe default behavior
    Quit $$$OK
}

}
