/// Healthcare Example - Patient Record Persistent Class
/// Demonstrates Iterator Pattern with patient data
/// Also serves as base class for Factory Method pattern examples
Class Patterns.Examples.PatientRecord Extends %Persistent [ Abstract ]
{

/// Unique identifier for this record
Property RecordID As %String;

/// Record type (Inpatient, Outpatient, Emergency)
Property RecordType As %String;

/// Record priority level
Property Priority As %String;

/// Patient full name (for Factory Method pattern compatibility)
Property PatientName As %String(MAXLEN = 100);

/// Patient Medical Record Number (alternative property name)
Property PatientMRN As %String(MAXLEN = 20);

/// Patient Medical Record Number (original property for Iterator pattern)
Property MRN As %String(MAXLEN = 20) [ Required ];

/// Patient First Name
Property FirstName As %String(MAXLEN = 50) [ Required ];

/// Patient Last Name
Property LastName As %String(MAXLEN = 50) [ Required ];

/// Date of Birth
Property DateOfBirth As %Date;

/// Gender
Property Gender As %String(VALUELIST = ",M,F,O,U");

/// Primary Department
Property Department As %String(MAXLEN = 50);

/// Primary Diagnosis Code
Property DiagnosisCode As %String(MAXLEN = 10);

/// Admission Date
Property AdmissionDate As %TimeStamp;

/// Discharge Date
Property DischargeDate As %TimeStamp;

/// Patient Status
Property Status As %String(VALUELIST = ",Active,Discharged,Transferred,Deceased");

/// Last Visit Date
Property LastVisitDate As %TimeStamp;

/// Attending Physician
Property AttendingPhysician As %String(MAXLEN = 100);

/// Attending Provider (alternative name for Factory Method pattern)
Property AttendingProvider As %String(MAXLEN = 100);

/// Insurance Provider
Property InsuranceProvider As %String(MAXLEN = 100);

/// Emergency Contact
Property EmergencyContact As %String(MAXLEN = 200);

/// HIPAA Consent
Property HIPAAConsent As %Boolean [ InitialExpression = 0 ];

/// Unique index on MRN
Index MRNIndex On MRN [ Unique ];

/// Index on Department for filtering
Index DepartmentIndex On Department;

/// Index on Diagnosis Code for filtering
Index DiagnosisIndex On DiagnosisCode;

/// Index on Admission Date for date range queries
Index AdmissionDateIndex On AdmissionDate;

/// Index on Status
Index StatusIndex On Status;

/// Create sample patient records for testing
ClassMethod CreateSampleData() As %Status
{
        Set tSC = $$$OK
        Try {
            // Clear existing data
            Do ..%KillExtent()
            
            // Sample departments
            Set tDepts = $LISTBUILD("Emergency", "Cardiology", "Oncology", "Pediatrics", "Orthopedics")
            
            // Sample diagnosis codes (ICD-10)
            Set tDiagnoses = $LISTBUILD("I21.9", "J44.0", "E11.9", "N18.9", "M79.3")
            
            // Sample physicians
            Set tPhysicians = $LISTBUILD("Dr. Smith", "Dr. Johnson", "Dr. Williams", "Dr. Brown", "Dr. Davis")
            
            // Create 50 sample patients
            For i=1:1:50 {
                Set tPatient = ..%New()
                Set tPatient.MRN = "MRN"_$JUSTIFY(i, 5, 0)
                Set tPatient.FirstName = "Patient"_i
                Set tPatient.LastName = "Test"_i
                Set tPatient.DateOfBirth = $HOROLOG - (365 * (20 + $RANDOM(60)))
                Set tPatient.Gender = $SELECT($RANDOM(2):"M", 1:"F")
                Set tPatient.Department = $LIST(tDepts, ($RANDOM(5) + 1))
                Set tPatient.DiagnosisCode = $LIST(tDiagnoses, ($RANDOM(5) + 1))
                Set tPatient.AdmissionDate = $ZDATETIME($HOROLOG - $RANDOM(30), 3)
                
                // 70% discharged
                If $RANDOM(10) < 7 {
                    Set tPatient.Status = "Discharged"
                    Set tPatient.DischargeDate = $ZDATETIME($HOROLOG - $RANDOM(7), 3)
                } Else {
                    Set tPatient.Status = "Active"
                }
                
                Set tPatient.LastVisitDate = $ZDATETIME($HOROLOG - $RANDOM(7), 3)
                Set tPatient.AttendingPhysician = $LIST(tPhysicians, ($RANDOM(5) + 1))
                Set tPatient.InsuranceProvider = "Insurance Co "_($RANDOM(5) + 1)
                Set tPatient.EmergencyContact = "Contact "_i_" - 555-"_$JUSTIFY($RANDOM(9999), 4, 0)
                Set tPatient.HIPAAConsent = 1
                
                Set tSC = tPatient.%Save()
                If $$$ISERR(tSC) Quit
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
}

/// Get patient count by department
ClassMethod GetCountByDepartment(pDepartment As %String) As %Integer
{
        Set tCount = 0
        &SQL(SELECT COUNT(*) INTO :tCount FROM PatientRecord WHERE Department = :pDepartment)
        Quit tCount
}

/// Get active patient count
ClassMethod GetActiveCount() As %Integer
{
        Set tCount = 0
        &SQL(SELECT COUNT(*) INTO :tCount FROM PatientRecord WHERE Status = 'Active')
        Quit tCount
}

/// Initialize the patient record (abstract method for Factory Method pattern)
Method Initialize() As %Status
{
        Set tSC = $$$OK
        
        // Set default values
        If ..PatientMRN = "" {
            Set ..PatientMRN = "MRN" _ $RANDOM(99999)
        }
        
        If ..PatientName = "" {
            Set ..PatientName = "Unnamed Patient"
        }
        
        // Sync MRN and PatientMRN for compatibility
        If ..MRN = "" Set ..MRN = ..PatientMRN
        If ..PatientMRN = "" Set ..PatientMRN = ..MRN
        
        Quit tSC
}

/// Process the patient record (abstract method for Factory Method pattern)
Method ProcessRecord() As %String [ Abstract ]
{
        // Abstract method - must be implemented by subclasses
        Quit ""
}

/// Validate the patient record (abstract method for Factory Method pattern)
Method ValidateRecord() As %Status [ Abstract ]
{
        // Abstract method - must be implemented by subclasses
        Quit $$$OK
}

/// Get detailed record summary
/// <p>Base implementation that provides common patient information.</p>
/// <returns>Formatted string with patient record details</returns>
Method GetRecordSummary() As %String
{
    Set summary = "================================" _ $Char(13,10)
    Set summary = summary _ "Patient Record Summary" _ $Char(13,10)
    Set summary = summary _ "================================" _ $Char(13,10)
    Set summary = summary _ "Record Type: " _ ..RecordType _ $Char(13,10)
    Set summary = summary _ "Priority: " _ ..Priority _ $Char(13,10)
    Set summary = summary _ "Patient: " _ ..PatientName _ $Char(13,10)
    Set summary = summary _ "MRN: " _ ..PatientMRN _ $Char(13,10)
    Set summary = summary _ "Department: " _ ..Department _ $Char(13,10)
    Set summary = summary _ "Provider: " _ ..AttendingProvider _ $Char(13,10)
    
    Quit summary
}

Storage Default
{
<Data name="PatientRecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MRN</Value>
</Value>
<Value name="3">
<Value>FirstName</Value>
</Value>
<Value name="4">
<Value>LastName</Value>
</Value>
<Value name="5">
<Value>DateOfBirth</Value>
</Value>
<Value name="6">
<Value>Gender</Value>
</Value>
<Value name="7">
<Value>Department</Value>
</Value>
<Value name="8">
<Value>DiagnosisCode</Value>
</Value>
<Value name="9">
<Value>AdmissionDate</Value>
</Value>
<Value name="10">
<Value>DischargeDate</Value>
</Value>
<Value name="11">
<Value>Status</Value>
</Value>
<Value name="12">
<Value>LastVisitDate</Value>
</Value>
<Value name="13">
<Value>AttendingPhysician</Value>
</Value>
<Value name="14">
<Value>InsuranceProvider</Value>
</Value>
<Value name="15">
<Value>EmergencyContact</Value>
</Value>
<Value name="16">
<Value>HIPAAConsent</Value>
</Value>
<Value name="17">
<Value>RecordType</Value>
</Value>
<Value name="18">
<Value>Priority</Value>
</Value>
<Value name="19">
<Value>PatientName</Value>
</Value>
<Value name="20">
<Value>PatientMRN</Value>
</Value>
<Value name="21">
<Value>AttendingProvider</Value>
</Value>
<Value name="22">
<Value>RecordID</Value>
</Value>
</Data>
<DataLocation>^Patterns.Exa5324.PatientRecordD</DataLocation>
<DefaultData>PatientRecordDefaultData</DefaultData>
<IdLocation>^Patterns.Exa5324.PatientRecordD</IdLocation>
<IndexLocation>^Patterns.Exa5324.PatientRecordI</IndexLocation>
<StreamLocation>^Patterns.Exa5324.PatientRecordS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
