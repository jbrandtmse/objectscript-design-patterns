/// Healthcare Report Generator - Template Method Pattern Example
/// <p>Abstract base class for healthcare report generation using Template Method pattern.
/// Defines the common workflow for generating medical reports with customizable steps.</p>
Class Patterns.Examples.ReportGenerator Extends Patterns.GoF.Behavioral.TemplateMethod
{

/// Patient information for the report
Property PatientInfo As %String [ MultiDimensional ];

/// Report content storage
Property ReportContent As %String [ MultiDimensional ];

/// Report format (Text, HTML, PDF)
Property OutputFormat As %String [ InitialExpression = "Text" ];

/// Report title
Property ReportTitle As %String;

/// Report generation timestamp
Property GeneratedAt As %String;

/// Hospital/Facility name for branding
Property FacilityName As %String [ InitialExpression = "General Hospital" ];

/// Initialize the report generator
Method %OnNew(pPatientId As %String = "") As %Status
{
    Set tSC = $$$OK
    
    // Initialize patient info - always set defaults to avoid UNDEFINED errors
    If pPatientId '= "" {
        Set ..PatientInfo("Id") = pPatientId
        Set ..PatientInfo("Name") = "John Doe"  // Would fetch from database
        Set ..PatientInfo("DOB") = "1980-01-01"
        Set ..PatientInfo("MRN") = "MRN-" _ pPatientId
    } Else {
        // Set minimal defaults for empty patient ID
        Set ..PatientInfo("Id") = ""
        Set ..PatientInfo("Name") = "Unknown Patient"
        Set ..PatientInfo("DOB") = ""
        Set ..PatientInfo("MRN") = ""
    }
    
    Quit tSC
}

/// Generate the complete report using template method pattern
Method GenerateReport(pFormat As %String = "Text") As %String
{
    Set ..OutputFormat = pFormat
    Set ..GeneratedAt = $ZDATETIME($HOROLOG, 3)
    
    // Execute the template method
    Set tSC = ..Execute()
    
    If $$$ISOK(tSC) {
        Quit ..%FormatReport()
    } Else {
        Quit "Error generating report: " _ $SYSTEM.Status.GetErrorText(tSC)
    }
}

/// Template Method Pattern - PrimitiveOperation1
/// Gather report-specific data (must be implemented by subclasses)
Method PrimitiveOperation1() As %Status
{
    Quit ..GatherReportData()
}

/// Template Method Pattern - PrimitiveOperation2  
/// Process and validate the report content
Method PrimitiveOperation2() As %Status
{
    Quit ..ProcessReportContent()
}

/// Hook method - Initialize report generation
Method Initialize()
{
    // Clear previous content
    Kill ..ReportContent
    
    // Set report metadata
    Set ..ReportContent("Metadata", "GeneratedAt") = ..GeneratedAt
    Set ..ReportContent("Metadata", "Facility") = ..FacilityName
    Set ..ReportContent("Metadata", "Format") = ..OutputFormat
}

/// Hook method - Finalize report generation
Method Finalize()
{
    // Add footer information
    Set ..ReportContent("Footer", "Generated") = "Report generated on " _ ..GeneratedAt
    Set ..ReportContent("Footer", "Confidential") = "CONFIDENTIAL - Protected Health Information"
    
    // Log report generation for audit trail
    Do ..%LogReportGeneration()
}

/// Hook method - Determine if optional sections should be included
Method Hook() As %Boolean
{
    // Check if we should include optional sections
    // Can be overridden by subclasses for specific logic
    Quit 1
}

/// Optional operation - Add supplementary sections
Method OptionalOperation()
{
    // Add optional report sections
    Do ..AddSupplementaryInfo()
}

/// Abstract method - Gather report-specific data
Method GatherReportData() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Abstract method - Process report content
Method ProcessReportContent() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Abstract method - Get report-specific title
Method GetReportTitle() As %String [ Abstract ]
{
    Quit ""
}

/// Add report header with patient information
Method AddReportHeader()
{
    Set ..ReportContent("Header", "Title") = ..GetReportTitle()
    Set ..ReportContent("Header", "Facility") = ..FacilityName
    Set ..ReportContent("Header", "PatientName") = ..PatientInfo("Name")
    Set ..ReportContent("Header", "PatientId") = ..PatientInfo("Id")
    Set ..ReportContent("Header", "MRN") = ..PatientInfo("MRN")
    Set ..ReportContent("Header", "DOB") = ..PatientInfo("DOB")
    Set ..ReportContent("Header", "GeneratedAt") = ..GeneratedAt
}

/// Add supplementary information (hook for optional content)
Method AddSupplementaryInfo()
{
    // Default implementation - can be overridden
    Set ..ReportContent("Supplementary", "Note") = "Additional information may be available upon request"
}

/// Format the report based on output format
Method %FormatReport() As %String [ Private ]
{
    Set tOutput = ""
    
    If ..OutputFormat = "HTML" {
        Set tOutput = ..%FormatAsHTML()
    } ElseIf ..OutputFormat = "PDF" {
        Set tOutput = ..%FormatAsPDF()
    } Else {
        Set tOutput = ..%FormatAsText()
    }
    
    Quit tOutput
}

/// Format report as plain text
Method %FormatAsText() As %String [ Private ]
{
    Set tOutput = ""
    // Create a line of 70 equals signs
    Set tLine = ""
    For i=1:1:70 { Set tLine = tLine _ "=" }
    Set tSeparator = $CHAR(10) _ tLine _ $CHAR(10)
    
    // Header
    Set tOutput = tOutput _ tSeparator
    Set tOutput = tOutput _ $Get(..ReportContent("Header", "Title"), "REPORT") _ $CHAR(10)
    Set tOutput = tOutput _ $Get(..ReportContent("Header", "Facility")) _ $CHAR(10)
    Set tOutput = tOutput _ tSeparator
    
    // Patient Info
    Set tOutput = tOutput _ "Patient: " _ $Get(..ReportContent("Header", "PatientName")) _ $CHAR(10)
    Set tOutput = tOutput _ "MRN: " _ $Get(..ReportContent("Header", "MRN")) _ $CHAR(10)
    Set tOutput = tOutput _ "DOB: " _ $Get(..ReportContent("Header", "DOB")) _ $CHAR(10)
    Set tOutput = tOutput _ tSeparator
    
    // Body content (iterate through sections)
    Set tSection = $ORDER(..ReportContent("Body", ""))
    While tSection '= "" {
        Set tOutput = tOutput _ $CHAR(10) _ tSection _ ":" _ $CHAR(10)
        Set tKey = $ORDER(..ReportContent("Body", tSection, ""))
        While tKey '= "" {
            Set tOutput = tOutput _ "  " _ tKey _ ": " _ $Get(..ReportContent("Body", tSection, tKey)) _ $CHAR(10)
            Set tKey = $ORDER(..ReportContent("Body", tSection, tKey))
        }
        Set tSection = $ORDER(..ReportContent("Body", tSection))
    }
    
    // Supplementary info if present
    If $DATA(..ReportContent("Supplementary")) {
        Set tOutput = tOutput _ $CHAR(10) _ "Additional information:" _ $CHAR(10)
        Set tKey = $ORDER(..ReportContent("Supplementary", ""))
        While tKey '= "" {
            Set tOutput = tOutput _ tKey _ ": " _ $Get(..ReportContent("Supplementary", tKey)) _ $CHAR(10)
            Set tKey = $ORDER(..ReportContent("Supplementary", tKey))
        }
    }
    
    // Footer
    Set tOutput = tOutput _ tSeparator
    Set tOutput = tOutput _ $Get(..ReportContent("Footer", "Generated")) _ $CHAR(10)
    Set tOutput = tOutput _ $Get(..ReportContent("Footer", "Confidential")) _ $CHAR(10)
    Set tOutput = tOutput _ tSeparator
    
    Quit tOutput
}

/// Format report as HTML
Method %FormatAsHTML() As %String [ Private ]
{
    Set tHTML = "<html><head><title>" _ $Get(..ReportContent("Header", "Title")) _ "</title>"
    Set tHTML = tHTML _ "<style>body{font-family:Arial;} .header{background:#f0f0f0;padding:10px;}"
    Set tHTML = tHTML _ ".section{margin:10px;} .footer{background:#f0f0f0;padding:10px;margin-top:20px;}</style></head><body>"
    
    // Header
    Set tHTML = tHTML _ "<div class='header'>"
    Set tHTML = tHTML _ "<h1>" _ $Get(..ReportContent("Header", "Title")) _ "</h1>"
    Set tHTML = tHTML _ "<p>" _ $Get(..ReportContent("Header", "Facility")) _ "</p>"
    Set tHTML = tHTML _ "<p>Patient: " _ $Get(..ReportContent("Header", "PatientName")) _ " (MRN: " _ $Get(..ReportContent("Header", "MRN")) _ ")</p>"
    Set tHTML = tHTML _ "<p>DOB: " _ $Get(..ReportContent("Header", "DOB")) _ "</p>"
    Set tHTML = tHTML _ "</div>"
    
    // Body content
    Set tHTML = tHTML _ "<div class='content'>"
    Set tSection = $ORDER(..ReportContent("Body", ""))
    While tSection '= "" {
        Set tHTML = tHTML _ "<div class='section'><h2>" _ tSection _ "</h2><ul>"
        Set tKey = $ORDER(..ReportContent("Body", tSection, ""))
        While tKey '= "" {
            Set tHTML = tHTML _ "<li><strong>" _ tKey _ ":</strong> " _ $Get(..ReportContent("Body", tSection, tKey)) _ "</li>"
            Set tKey = $ORDER(..ReportContent("Body", tSection, tKey))
        }
        Set tHTML = tHTML _ "</ul></div>"
        Set tSection = $ORDER(..ReportContent("Body", tSection))
    }
    Set tHTML = tHTML _ "</div>"
    
    // Footer
    Set tHTML = tHTML _ "<div class='footer'>"
    Set tHTML = tHTML _ "<p>" _ $Get(..ReportContent("Footer", "Generated")) _ "</p>"
    Set tHTML = tHTML _ "<p><em>" _ $Get(..ReportContent("Footer", "Confidential")) _ "</em></p>"
    Set tHTML = tHTML _ "</div></body></html>"
    
    Quit tHTML
}

/// Simulate PDF format (returns text with PDF markers)
Method %FormatAsPDF() As %String [ Private ]
{
    Set tPDF = "%PDF-1.4 (Simulated)" _ $CHAR(10)
    Set tPDF = tPDF _ "<<Report: " _ $Get(..ReportContent("Header", "Title")) _ ">>" _ $CHAR(10)
    Set tPDF = tPDF _ ..%FormatAsText()  // Use text format as base
    Set tPDF = tPDF _ "%%EOF" _ $CHAR(10)
    Quit tPDF
}

/// Log report generation for audit trail
Method %LogReportGeneration() [ Private ]
{
    // In production, this would write to audit log
    Set ^Patterns.Reports.AuditLog($INCREMENT(^Patterns.Reports.AuditLog)) = $LISTBUILD(
        ..GetReportTitle(),
        ..PatientInfo("Id"),
        ..GeneratedAt,
        ..OutputFormat
    )
}

/// Validate report completeness
Method ValidateReport() As %Status
{
    Set tSC = $$$OK
    
    // Check required sections
    If '$DATA(..ReportContent("Header")) {
        Set tSC = $$$ERROR($$$GeneralError, "Report header missing")
    }
    
    If '$DATA(..ReportContent("Body")) && $$$ISOK(tSC) {
        Set tSC = $$$ERROR($$$GeneralError, "Report body missing")
    }
    
    Quit tSC
}

}
