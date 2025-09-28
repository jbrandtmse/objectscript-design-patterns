/// Abstract factory class for creating patient records
/// <p>This abstract class demonstrates the Factory Method pattern for creating
/// different types of patient records in a healthcare system.</p>
Class Patterns.Examples.PatientRecordFactory Extends %RegisteredObject [ Abstract ]
{

/// Registry to track created patient records
Property RecordRegistry As list Of Patterns.Examples.PatientRecord;

/// Counter for tracking number of records created
Property RecordsCreated As %Integer [ InitialExpression = 0 ];

/// Factory name identifier
Property FactoryName As %String;

/// Default department for this factory
Property DefaultDepartment As %String;

/// Abstract method to create a specific type of patient record
/// <p>Concrete factories must implement this method to create their specific record types.</p>
/// <returns>A new instance of a PatientRecord subclass</returns>
Method CreateRecord() As Patterns.Examples.PatientRecord [ Abstract ]
{
    // Abstract method - must be implemented by subclasses
    // Return null object - concrete subclasses will override
    Quit $$$NULLOREF
}

/// Factory method that uses the abstract CreateRecord to produce patient records
/// <p>This method orchestrates the record creation process, including initialization
/// and registration.</p>
/// <param name="pPatientName">Name of the patient</param>
/// <param name="pPatientMRN">Medical Record Number for the patient</param>
/// <param name="pProvider">Name of the attending provider</param>
/// <returns>A fully initialized patient record</returns>
Method FactoryMethod(pPatientName As %String = "", pPatientMRN As %String = "", pProvider As %String = "") As Patterns.Examples.PatientRecord
{
    Set record = ""
    
    Try {
        // Create the record using the abstract method
        Set record = ..CreateRecord()
        
        // Set common properties
        If pPatientName '= "" {
            Set record.PatientName = pPatientName
        } Else {
            Set record.PatientName = "Patient-" _ $Random(10000)
        }
        
        If pPatientMRN '= "" {
            Set record.PatientMRN = pPatientMRN
        }
        
        If pProvider '= "" {
            Set record.AttendingProvider = pProvider
        } Else {
            Set record.AttendingProvider = "Dr. " _ $Piece("Smith,Johnson,Williams,Brown,Jones,Garcia,Miller,Davis", ",", $Random(8) + 1)
        }
        
        // Set department from factory default if not already set
        If (record.Department = "") && (..DefaultDepartment '= "") {
            Set record.Department = ..DefaultDepartment
        }
        
        // Initialize the record
        Set tSC = record.Initialize()
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Register the created record
        Do ..RegisterRecord(record)
        
        // Log creation
        Write "Factory '", ..FactoryName, "' created ", record.RecordType, " record for ", record.PatientName, !
    }
    Catch ex {
        Write "Error creating patient record: ", ex.DisplayString(), !
        Set record = ""
    }
    
    Quit record
}

/// Register a created record in the factory's registry
/// <param name="pRecord">The patient record to register</param>
Method RegisterRecord(pRecord As Patterns.Examples.PatientRecord)
{
    Do ..RecordRegistry.Insert(pRecord)
    Set ..RecordsCreated = ..RecordsCreated + 1
}

/// Get statistics about records created by this factory
/// <returns>String with factory statistics</returns>
Method GetFactoryStatistics() As %String
{
    Set stats = "=== Factory Statistics ===" _ $Char(13,10)
    Set stats = stats _ "Factory: " _ ..FactoryName _ $Char(13,10)
    Set stats = stats _ "Records Created: " _ ..RecordsCreated _ $Char(13,10)
    Set stats = stats _ "Default Department: " _ ..DefaultDepartment _ $Char(13,10)
    
    // Count by record type
    Set inpatientCount = 0
    Set outpatientCount = 0
    Set emergencyCount = 0
    
    For i=1:1:..RecordRegistry.Count() {
        Set record = ..RecordRegistry.GetAt(i)
        If $IsObject(record) {
            If record.RecordType = "Inpatient" {
                Set inpatientCount = inpatientCount + 1
            } ElseIf record.RecordType = "Outpatient" {
                Set outpatientCount = outpatientCount + 1
            } ElseIf record.RecordType = "Emergency" {
                Set emergencyCount = emergencyCount + 1
            }
        }
    }
    
    Set stats = stats _ "  - Inpatient Records: " _ inpatientCount _ $Char(13,10)
    Set stats = stats _ "  - Outpatient Records: " _ outpatientCount _ $Char(13,10)
    Set stats = stats _ "  - Emergency Records: " _ emergencyCount _ $Char(13,10)
    Set stats = stats _ "=========================="
    
    Quit stats
}

/// Process all records in the registry
/// <returns>String with processing results</returns>
Method ProcessAllRecords() As %String
{
    Set results = "Processing " _ ..RecordsCreated _ " records..." _ $Char(13,10)
    
    For i=1:1:..RecordRegistry.Count() {
        Set record = ..RecordRegistry.GetAt(i)
        If $IsObject(record) {
            Set results = results _ "Record " _ i _ ": " _ record.ProcessRecord() _ $Char(13,10)
        }
    }
    
    Quit results
}

/// Validate all records in the registry
/// <returns>%Status indicating if all records are valid</returns>
Method ValidateAllRecords() As %Status
{
    Set tSC = $$$OK
    
    For i=1:1:..RecordRegistry.Count() {
        Set record = ..RecordRegistry.GetAt(i)
        If $IsObject(record) {
            Set recordStatus = record.ValidateRecord()
            If $$$ISERR(recordStatus) {
                Set tSC = $$$ADDSC(tSC, recordStatus)
            }
        }
    }
    
    Quit tSC
}

/// Clear the record registry
Method ClearRegistry()
{
    Do ..RecordRegistry.Clear()
    Write "Registry cleared for factory '", ..FactoryName, "'", !
}

}
