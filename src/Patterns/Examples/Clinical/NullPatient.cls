/// Null Patient - Special Case Pattern for Healthcare
/// 
/// Intent:
/// Provide a null object for patient references that eliminates null checking
/// and provides safe default behaviors for missing patient data.
/// 
/// Motivation:
/// Clinical systems frequently need to handle missing patient references. Instead of
/// null checks throughout the code, a null patient object provides safe defaults and
/// allows uniform treatment of all patient references.
/// 
/// Applicability:
/// - Patient reference is missing or unavailable
/// - You want to eliminate null checks in clinical workflows
/// - Operations on null patient should be safe no-ops
/// - Client code should handle null and real patients uniformly
/// 
/// Structure:
/// <example>
/// Set patient = ##class(Patterns.Examples.Clinical.NullPatient).%New()
/// Write patient.GetDisplayName()  // Returns "Unknown Patient" - no null check
/// Do patient.Save()  // Safe no-op, returns $$$OK
/// </example>
/// 
/// @see Patterns.PoEAA.Base.NullObject
/// @see Patterns.Examples.Clinical.Patient
/// @since 1.0.0
Class Patterns.Examples.Clinical.NullPatient Extends Patterns.Examples.Clinical.Patient
{

/// Pattern version
Parameter VERSION = "1.0.0";

/// Pattern type - Null Object variant
Parameter PATTERNTYPE = "SpecialCase-NullObject";

/// Constructor - Initialize with safe defaults
Method %OnNew() As %Status
{
    Set ..FirstName = ""
    Set ..LastName = ""
    Set ..MRN = "UNKNOWN"
    Set ..Gender = "U"
    Set ..Status = ""
    Set ..Department = ""
    Quit $$$OK
}

/// Indicates this is a null patient object
/// 
/// @return %Boolean - Always returns 1
Method IsNull() As %Boolean
{
    Quit 1
}

/// Indicates this is a special case object
/// 
/// @return %Boolean - Always returns 1
Method IsSpecialCase() As %Boolean
{
    Quit 1
}

/// Get display name for null patient
/// 
/// @return %String - Returns "Unknown Patient"
Method GetDisplayName() As %String
{
    Quit "Unknown Patient"
}

/// Get medical record number for null patient
/// 
/// @return %String - Returns "UNKNOWN"
Method GetMRN() As %String
{
    Quit "UNKNOWN"
}

/// Get full name for null patient
/// 
/// @return %String - Returns "Unknown"
Method GetFullName() As %String
{
    Quit "Unknown"
}

/// Factory method to create null patient
/// 
/// @return NullPatient - A null patient instance
ClassMethod CreateNullPatient() As Patterns.Examples.Clinical.NullPatient
{
    Quit ..%New()
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
