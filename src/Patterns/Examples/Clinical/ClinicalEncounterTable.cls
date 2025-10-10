/// Clinical Encounter Database Table Definition
/// 
/// Persistent class that defines the ClinicalEncounters table schema
/// Used by ClinicalEncounterMapper for SQL operations
/// 
/// NOTE: This is NOT a domain object - it's purely for table definition
/// The actual domain object is ClinicalEncounter (non-persistent)
/// 
/// @see Patterns.Examples.Clinical.ClinicalEncounter (domain object)
/// @see Patterns.Examples.Clinical.ClinicalEncounterMapper (mapper)
/// @since 1.0.0
Class Patterns.Examples.Clinical.ClinicalEncounterTable Extends %Persistent
{

/// Patient Medical Record Number
Property PatientMRN As %String(MAXLEN = 50);

/// Provider name responsible for encounter
Property ProviderName As %String(MAXLEN = 100);

/// Date and time of the encounter
Property EncounterDate As %TimeStamp;

/// Type of encounter
Property EncounterType As %String(MAXLEN = 50);

/// Chief complaint reported by patient
Property ChiefComplaint As %String(MAXLEN = 500);

/// Diagnosis determined during encounter
Property Diagnosis As %String(MAXLEN = 500);

/// Treatment plan for the patient
Property TreatmentPlan As %String(MAXLEN = 1000);

/// Index on PatientMRN for efficient queries
Index PatientMRNIndex On PatientMRN;

/// Index on EncounterDate for date range queries
Index EncounterDateIndex On EncounterDate;

Storage Default
{
<Data name="ClinicalEncounterTableDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientMRN</Value>
</Value>
<Value name="3">
<Value>ProviderName</Value>
</Value>
<Value name="4">
<Value>EncounterDate</Value>
</Value>
<Value name="5">
<Value>EncounterType</Value>
</Value>
<Value name="6">
<Value>ChiefComplaint</Value>
</Value>
<Value name="7">
<Value>Diagnosis</Value>
</Value>
<Value name="8">
<Value>TreatmentPlan</Value>
</Value>
</Data>
<DataLocation>^Patterns.ClinicalEncD</DataLocation>
<DefaultData>ClinicalEncounterTableDefaultData</DefaultData>
<IdLocation>^Patterns.ClinicalEncD</IdLocation>
<IndexLocation>^Patterns.ClinicalEncI</IndexLocation>
<StreamLocation>^Patterns.ClinicalEncS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
