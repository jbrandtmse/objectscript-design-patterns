/// Clinical Example - Patient persistent class for Table Data Gateway demonstration
Class Patterns.Examples.Clinical.Patient Extends %Persistent
{

/// Patient's first name
Property FirstName As %String(MAXLEN = 50);

/// Patient's last name
Property LastName As %String(MAXLEN = 50);

/// Patient's date of birth
Property DateOfBirth As %Date;

/// Patient's gender
Property Gender As %String(VALUELIST = ",M,F,O,U");

/// Department where patient is assigned
Property Department As %String(MAXLEN = 50);

/// Patient's current status
Property Status As %String(VALUELIST = ",Active,Discharged,Deceased,Transferred");

/// Patient's medical record number
Property MRN As %String(MAXLEN = 20);

/// Index on last name for searching
Index LastNameIdx On LastName;

/// Index on department for filtering
Index DepartmentIdx On Department;

/// Index on MRN (unique)
Index MRNIdx On MRN [ Unique ];

Storage Default
{
<Data name="PatientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FirstName</Value>
</Value>
<Value name="3">
<Value>LastName</Value>
</Value>
<Value name="4">
<Value>DateOfBirth</Value>
</Value>
<Value name="5">
<Value>Gender</Value>
</Value>
<Value name="6">
<Value>Department</Value>
</Value>
<Value name="7">
<Value>Status</Value>
</Value>
<Value name="8">
<Value>MRN</Value>
</Value>
</Data>
<DataLocation>^Patterns.Examples65F7.PatientD</DataLocation>
<DefaultData>PatientDefaultData</DefaultData>
<IdLocation>^Patterns.Examples65F7.PatientD</IdLocation>
<IndexLocation>^Patterns.Examples65F7.PatientI</IndexLocation>
<StreamLocation>^Patterns.Examples65F7.PatientS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
