/// <example>
/// Abstract builder class for medical reports
/// Defines the interface for building different types of medical reports step-by-step
/// </example>
Class Patterns.Examples.MedicalReportBuilder Extends %RegisteredObject [ Abstract ]
{

/// The report being built
Property Report As MedicalReport [ Private ];

/// <summary>
/// Constructor - initializes a new report
/// </summary>
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        Do ..Reset()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// <summary>
/// Reset the builder to start a new report
/// </summary>
Method Reset() As MedicalReportBuilder
{
    Set ..Report = ##class(MedicalReport).%New()
    Quit $THIS
}

/// <summary>
/// Set the report ID and type
/// </summary>
Method SetReportIdentification(pReportId As %String, pReportType As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set ..Report.ReportId = pReportId
        Set ..Report.ReportType = pReportType
    }
    Quit $THIS
}

/// <summary>
/// Build patient information section
/// </summary>
Method BuildPatientInfo(pPatientId As %String, pName As %String, pDateOfBirth As %String, pMRN As %String = "") As MedicalReportBuilder [ Abstract ]
{
    // Abstract method - must be implemented by concrete builders
    Quit $THIS
}

/// <summary>
/// Build clinical history section
/// </summary>
Method BuildClinicalHistory(pHistory As %String) As MedicalReportBuilder [ Abstract ]
{
    // Abstract method - must be implemented by concrete builders
    Quit $THIS
}

/// <summary>
/// Build findings section
/// </summary>
Method BuildFindings(pFindings As %String) As MedicalReportBuilder [ Abstract ]
{
    // Abstract method - must be implemented by concrete builders
    Quit $THIS
}

/// <summary>
/// Build interpretation section
/// </summary>
Method BuildInterpretation(pInterpretation As %String) As MedicalReportBuilder [ Abstract ]
{
    // Abstract method - must be implemented by concrete builders
    Quit $THIS
}

/// <summary>
/// Build recommendations section
/// </summary>
Method BuildRecommendations(pRecommendations As %String) As MedicalReportBuilder [ Abstract ]
{
    // Abstract method - must be implemented by concrete builders
    Quit $THIS
}

/// <summary>
/// Add a signature to the report
/// </summary>
Method AddSignature(pProviderName As %String, pCredentials As %String, pDateTime As %String = {$ZDATETIME($HOROLOG, 3)}) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tSignature = pProviderName _ ", " _ pCredentials _ " - " _ pDateTime
        Do ..Report.AddSignature(tSignature)
    }
    Quit $THIS
}

/// <summary>
/// Set report priority
/// </summary>
Method SetPriority(pPriority As %Integer) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        If (pPriority >= 1) && (pPriority <= 3) {
            Set ..Report.Priority = pPriority
        }
    }
    Quit $THIS
}

/// <summary>
/// Set report status
/// </summary>
Method SetStatus(pStatus As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        If $ListFind($ListBuild("Draft", "Final", "Amended", "Corrected"), pStatus) {
            Set ..Report.Status = pStatus
        }
    }
    Quit $THIS
}

/// <summary>
/// Add an attachment
/// </summary>
Method AddAttachment(pAttachmentPath As %String, pDescription As %String = "") As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tAttachment = pAttachmentPath
        If (pDescription '= "") {
            Set tAttachment = tAttachment _ " (" _ pDescription _ ")"
        }
        Do ..Report.AddAttachment(tAttachment)
    }
    Quit $THIS
}

/// <summary>
/// Add metadata
/// </summary>
Method AddMetadata(pKey As %String, pValue As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Do ..Report.SetMetadata(pKey, pValue)
    }
    Quit $THIS
}

/// <summary>
/// Validate the report before returning
/// </summary>
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    If '$ISOBJECT(..Report) {
        Quit $$$ERROR($$$GeneralError, "No report object to validate")
    }
    
    If (..Report.ReportId = "") {
        Quit $$$ERROR($$$GeneralError, "Report ID is required")
    }
    
    If (..Report.ReportType = "") {
        Quit $$$ERROR($$$GeneralError, "Report type is required")
    }
    
    If '..Report.IsComplete() {
        Quit $$$ERROR($$$GeneralError, "Report is incomplete (missing patient info, findings, or signature)")
    }
    
    Quit tSC
}

/// <summary>
/// Get the built report
/// </summary>
Method GetResult() As MedicalReport
{
    Set tResult = ""
    Try {
        Set tSC = ..Validate()
        If $$$ISOK(tSC) {
            Set tResult = ..Report
            // Reset for next build
            Do ..Reset()
        }
    }
    Catch ex {
        // Return empty on error
        Set tResult = ""
    }
    Quit tResult
}

/// <summary>
/// Build a complete report with all sections (template method)
/// </summary>
Method BuildCompleteReport(pReportId As %String, pPatientId As %String, pPatientName As %String, pDOB As %String, pHistory As %String, pFindings As %String, pInterpretation As %String, pRecommendations As %String, pProviderName As %String, pCredentials As %String) As MedicalReport
{
    Do ..Reset()
    Do ..SetReportIdentification(pReportId, ..GetReportType())
    Do ..BuildPatientInfo(pPatientId, pPatientName, pDOB)
    Do ..BuildClinicalHistory(pHistory)
    Do ..BuildFindings(pFindings)
    Do ..BuildInterpretation(pInterpretation)
    Do ..BuildRecommendations(pRecommendations)
    Do ..AddSignature(pProviderName, pCredentials)
    Do ..SetStatus("Final")
    
    Quit ..GetResult()
}

/// <summary>
/// Get the report type for this builder (to be overridden)
/// </summary>
Method GetReportType() As %String [ Abstract ]
{
    Quit ""
}

}
