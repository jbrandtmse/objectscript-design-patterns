/// <example>
/// Medical Report product class for Builder pattern healthcare example
/// This represents a complex medical report with multiple sections that can be built step-by-step
/// </example>
Class Patterns.Examples.MedicalReport Extends %RegisteredObject
{

/// Report type (Lab, Radiology, Discharge, etc.)
Property ReportType As %String;

/// Report ID for tracking
Property ReportId As %String;

/// Report generation timestamp
Property GeneratedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG, 3)} ];

/// Patient information section
Property PatientInfo As %String(MAXLEN = 2000);

/// Clinical history section
Property ClinicalHistory As %String(MAXLEN = 5000);

/// Findings section (lab results, imaging findings, etc.)
Property Findings As %String(MAXLEN = 10000);

/// Interpretation/Analysis section
Property Interpretation As %String(MAXLEN = 5000);

/// Recommendations section
Property Recommendations As %String(MAXLEN = 3000);

/// Physician/Provider signatures
Property Signatures As list Of %String;

/// Report priority level (1=Stat, 2=Urgent, 3=Routine)
Property Priority As %Integer [ InitialExpression = 3 ];

/// Report status (Draft, Final, Amended, Corrected)
Property Status As %String [ InitialExpression = "Draft" ];

/// Additional metadata as key-value pairs
Property Metadata [ MultiDimensional ];

/// Attachments (image references, supporting documents)
Property Attachments As list Of %String;

/// <summary>
/// Check if report has minimum required sections
/// </summary>
Method IsComplete() As %Boolean
{
    // A complete report needs at least patient info, findings, and a signature
    If (..PatientInfo = "") {
        Quit 0
    }
    If (..Findings = "") {
        Quit 0
    }
    If (..Signatures.Count() = 0) {
        Quit 0
    }
    Quit 1
}

/// <summary>
/// Add a signature to the report
/// </summary>
Method AddSignature(pSignature As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        If (pSignature '= "") {
            Do ..Signatures.Insert(pSignature)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <summary>
/// Add an attachment reference
/// </summary>
Method AddAttachment(pAttachment As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        If (pAttachment '= "") {
            Do ..Attachments.Insert(pAttachment)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <summary>
/// Set metadata value
/// </summary>
Method SetMetadata(pKey As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        If (pKey '= "") {
            Set ..Metadata(pKey) = pValue
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <summary>
/// Get metadata value
/// </summary>
Method GetMetadata(pKey As %String) As %String
{
    Set result = ""
    Try {
        If (pKey '= "") && $Data(..Metadata(pKey)) {
            Set result = ..Metadata(pKey)
        }
    }
    Catch ex {
        // Return empty string on error
    }
    Quit result
}

/// <summary>
/// Display report summary
/// </summary>
Method Display()
{
    Write "========================================",!
    Write "Medical Report: ", ..ReportType,!
    Write "Report ID: ", ..ReportId,!
    Write "Generated: ", ..GeneratedAt,!
    Write "Priority: ", $Case(..Priority, 1:"STAT", 2:"Urgent", 3:"Routine", :"Unknown"),!
    Write "Status: ", ..Status,!
    Write "----------------------------------------",!
    
    If (..PatientInfo '= "") {
        Write "Patient Information:",!
        Write "  ", ..PatientInfo,!
    }
    
    If (..ClinicalHistory '= "") {
        Write "Clinical History:",!
        Write "  ", ..ClinicalHistory,!
    }
    
    If (..Findings '= "") {
        Write "Findings:",!
        Write "  ", ..Findings,!
    }
    
    If (..Interpretation '= "") {
        Write "Interpretation:",!
        Write "  ", ..Interpretation,!
    }
    
    If (..Recommendations '= "") {
        Write "Recommendations:",!
        Write "  ", ..Recommendations,!
    }
    
    If (..Signatures.Count() > 0) {
        Write "Signatures:",!
        For i=1:1:..Signatures.Count() {
            Write "  ", ..Signatures.GetAt(i),!
        }
    }
    
    If (..Attachments.Count() > 0) {
        Write "Attachments: ", ..Attachments.Count(), " file(s)",!
    }
    
    Write "========================================",!
}

/// <summary>
/// Convert report to string representation
/// </summary>
Method ToString() As %String
{
    Set str = "MedicalReport[Type=" _ ..ReportType
    Set str = str _ ", ID=" _ ..ReportId
    Set str = str _ ", Status=" _ ..Status
    Set str = str _ ", Complete=" _ ..IsComplete()
    Set str = str _ "]"
    Quit str
}

}
