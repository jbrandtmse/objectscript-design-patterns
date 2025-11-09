/// Unknown Patient - Special Case Pattern for Healthcare
/// 
/// Intent:
/// Provide a special case object for unregistered or walk-in patients
/// with safe default behaviors that allow processing to continue.
/// 
/// Motivation:
/// Emergency departments often encounter walk-in patients without registration.
/// An unknown patient object provides meaningful defaults and allows clinical
/// workflows to proceed while patient information is being gathered.
/// 
/// Applicability:
/// - Walk-in emergency patients without registration
/// - Patient data is being collected but not yet complete
/// - You want to allow clinical processing before full registration
/// - Temporary patient tracking is needed
/// 
/// Structure:
/// <example>
/// Set patient = ##class(Patterns.Examples.Clinical.UnknownPatient).%New()
/// Write patient.GetDisplayName()  // Returns "Unregistered Patient"
/// Write patient.GetMRN()  // Returns temporary MRN like "TEMP-12345"
/// </example>
/// 
/// @see Patterns.PoEAA.Base.UnknownCase
/// @see Patterns.Examples.Clinical.Patient
/// @since 1.0.0
Class Patterns.Examples.Clinical.UnknownPatient Extends Patterns.Examples.Clinical.Patient
{

/// Pattern version
Parameter VERSION = "1.0.0";

/// Pattern type - Unknown Case variant
Parameter PATTERNTYPE = "SpecialCase-UnknownCase";

/// Temporary MRN prefix
Parameter TEMPMRNPREFIX = "TEMP-";

/// Constructor - Initialize with unknown patient defaults
Method %OnNew() As %Status
{
    Set ..FirstName = "Unregistered"
    Set ..LastName = "Patient"
    Set ..MRN = ..GenerateTemporaryMRN()
    Set ..Gender = "U"
    Set ..Status = "Active"
    Set ..Department = "Emergency"
    Quit $$$OK
}

/// Indicates this is not a null object
/// 
/// @return %Boolean - Returns 0
Method IsNull() As %Boolean
{
    Quit 0
}

/// Indicates this is a special case object
/// 
/// @return %Boolean - Always returns 1
Method IsSpecialCase() As %Boolean
{
    Quit 1
}

/// Get display name for unknown patient
/// 
/// @return %String - Returns "Unregistered Patient"
Method GetDisplayName() As %String
{
    Quit "Unregistered Patient"
}

/// Get medical record number for unknown patient
/// Returns the temporary MRN assigned in constructor
/// 
/// @return %String - Temporary MRN
Method GetMRN() As %String
{
    Quit ..MRN
}

/// Get full name for unknown patient
/// 
/// @return %String - Returns "Unregistered Patient"
Method GetFullName() As %String
{
    Quit "Unregistered Patient"
}

/// Generate a temporary medical record number
/// Uses timestamp-based unique identifier
/// 
/// @return %String - Temporary MRN like "TEMP-12345"
ClassMethod GenerateTemporaryMRN() As %String
{
    // Use $ZUTIL(68,40,1) to get unique sequential number
    Set tSequence = $INCREMENT(^Patterns.TempMRNSequence)
    Quit ..#TEMPMRNPREFIX _ tSequence
}

/// Factory method to create unknown patient
/// 
/// @return UnknownPatient - An unknown patient instance
ClassMethod CreateUnknownPatient() As Patterns.Examples.Clinical.UnknownPatient
{
    Quit ..%New()
}

/// Indicates this is a temporary/unregistered patient
/// 
/// @return %Boolean - Always returns 1
Method IsTemporary() As %Boolean
{
    Quit 1
}

/// Check if patient needs registration
/// 
/// @return %Boolean - Always returns 1 for unknown patients
Method NeedsRegistration() As %Boolean
{
    Quit 1
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
