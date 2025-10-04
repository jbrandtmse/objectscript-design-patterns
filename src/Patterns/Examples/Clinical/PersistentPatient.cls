/// Healthcare Patient - Persistent Class for Table Module Pattern
/// 
/// Simple persistent patient class for demonstrating Table Module pattern.
/// Stores basic patient demographic and clinical data.
/// 
/// @see Patterns.Examples.Clinical.PatientTableModule
/// @since 1.0.0
Class Patterns.Examples.Clinical.PersistentPatient Extends %Persistent
{

/// Shorter table name to avoid global name length issues
Parameter SQLTABLENAME = "PersPatient";

/// Patient medical record number (8 digits)
Property MedicalRecordNumber As %String;

/// Patient full name
Property FullName As %String;

/// Date of birth
Property DateOfBirth As %Date;

/// Patient weight in kilograms
Property WeightKg As %Numeric;

/// Patient height in centimeters
Property HeightCm As %Numeric;

Storage Default
{
<Data name="PersistentPatientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MedicalRecordNumber</Value>
</Value>
<Value name="3">
<Value>FullName</Value>
</Value>
<Value name="4">
<Value>DateOfBirth</Value>
</Value>
<Value name="5">
<Value>WeightKg</Value>
</Value>
<Value name="6">
<Value>HeightCm</Value>
</Value>
</Data>
<DataLocation>^Patterns.E65F7.PersistentPBF09D</DataLocation>
<DefaultData>PersistentPatientDefaultData</DefaultData>
<IdLocation>^Patterns.E65F7.PersistentPBF09D</IdLocation>
<IndexLocation>^Patterns.E65F7.PersistentPBF09I</IndexLocation>
<StreamLocation>^Patterns.E65F7.PersistentPBF09S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
