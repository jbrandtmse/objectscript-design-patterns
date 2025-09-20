/// Healthcare Lab System - Result Formatter Subsystem
/// Complex subsystem for formatting and distributing lab results
/// Handles report generation, distribution, and archiving
Class Patterns.Examples.LabResultFormatter Extends %RegisteredObject
{

/// References to other subsystems
Property TestOrdererRef As LabTestOrderer;

Property TestProcessorRef As LabTestProcessor;

/// Report formatting configuration
Property FormatConfig [ MultiDimensional ];

/// Report archive
Property ReportArchive [ MultiDimensional ];

/// Distribution lists
Property DistributionLists [ MultiDimensional ];

/// Supported report formats
Property SupportedFormats As %List [ InitialExpression = {$LISTBUILD("PDF", "HL7", "FHIR", "TEXT", "HTML")} ];

/// Current default format
Property DefaultFormat As %String [ InitialExpression = "PDF" ];

/// Report counter
Property ReportCounter As %Integer [ InitialExpression = 10000 ];

/// Initialize formatter with configuration
Method %OnNew(pFormat As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        If pFormat '= "" {
            If $LISTFIND(..SupportedFormats, pFormat) {
                Set ..DefaultFormat = pFormat
            }
        }
        
        // Initialize format configuration
        Set ..FormatConfig("PDF", "template") = "standard"
        Set ..FormatConfig("PDF", "logo") = 1
        Set ..FormatConfig("PDF", "pageSize") = "Letter"
        
        Set ..FormatConfig("HL7", "version") = "2.5.1"
        Set ..FormatConfig("HL7", "encoding") = "ER7"
        
        Set ..FormatConfig("FHIR", "version") = "R4"
        Set ..FormatConfig("FHIR", "format") = "JSON"
        
        Set ..FormatConfig("HTML", "template") = "responsive"
        Set ..FormatConfig("TEXT", "width") = 80
        
        // Initialize distribution lists
        Set ..DistributionLists("CRITICAL", "methods") = "EMAIL,SMS,SYSTEM"
        Set ..DistributionLists("ABNORMAL", "methods") = "EMAIL,SYSTEM"
        Set ..DistributionLists("NORMAL", "methods") = "SYSTEM"
        
        // Initialize report archive
        Set ..ReportArchive("initialized") = $HOROLOG
        Set ..ReportArchive("maxSize") = 1000
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Format lab results with complex formatting rules
Method FormatLabResults(pResultData As %String, pFormat As %String = "") As %String
{
    Set tFormatted = ""
    
    // Validate input
    If pResultData = "" {
        Quit "ERROR:NO_RESULTS_TO_FORMAT"
    }
    
    // Determine format
    Set tFormat = $SELECT(pFormat'="":pFormat, 1:..DefaultFormat)
    
    If '$LISTFIND(..SupportedFormats, tFormat) {
        Quit "ERROR:UNSUPPORTED_FORMAT:"_tFormat
    }
    
    // Apply formatting based on type
    If tFormat = "PDF" {
        Set tFormatted = ..formatAsPDF(pResultData)
    } ElseIf tFormat = "HL7" {
        Set tFormatted = ..formatAsHL7(pResultData)
    } ElseIf tFormat = "FHIR" {
        Set tFormatted = ..formatAsFHIR(pResultData)
    } ElseIf tFormat = "HTML" {
        Set tFormatted = ..formatAsHTML(pResultData)
    } Else {
        Set tFormatted = ..formatAsText(pResultData)
    }
    
    // Generate report ID and archive
    Set ..ReportCounter = ..ReportCounter + 1
    Set tReportId = "RPT-"_..ReportCounter
    Do ..archiveReport(tReportId, tFormatted, tFormat)
    
    // Add report metadata
    Set tFormatted = "REPORT_ID:"_tReportId_"|"_tFormatted
    
    Quit tFormatted
}

/// Generate comprehensive lab report
Method GenerateLabReport(pRequest As %DynamicObject) As %String
{
    Set tReport = ""
    
    Try {
        // Collect data from all subsystems
        Set tOrderData = ""
        Set tProcessData = ""
        
        If $ISOBJECT(..TestOrdererRef) {
            Set tPatientId = $GET(pRequest.patientId, "P001")
            Set tOrderData = ..TestOrdererRef.GetPatientInfo(tPatientId)
        }
        
        If $ISOBJECT(..TestProcessorRef) {
            Set tSpecimenId = $GET(pRequest.specimenId, "")
            If tSpecimenId '= "" {
                Set tProcessData = ..TestProcessorRef.GetTestResults(tSpecimenId)
            }
        }
        
        // Merge data
        Set tMergedData = ..mergeLabData(tOrderData, tProcessData)
        
        // Apply clinical interpretation
        Set tInterpretedData = ..applyClinicalInterpretation(tMergedData)
        
        // Format report
        Set tFormat = $GET(pRequest.format, ..DefaultFormat)
        Set tReport = ..FormatLabResults(tInterpretedData, tFormat)
        
        // Determine distribution
        Set tDistribution = ..determineDistribution(tInterpretedData)
        Do ..distributeReport(tReport, tDistribution)
    }
    Catch ex {
        Set tReport = "ERROR:REPORT_GENERATION_FAILED:"_ex.DisplayString()
    }
    
    Quit tReport
}

/// Process complex output from test processor
Method ProcessComplexResults(pDynamicObject As %DynamicObject) As %String
{
    Set tProcessed = ""
    
    If '$ISOBJECT(pDynamicObject) {
        Quit "ERROR:INVALID_RESULTS_OBJECT"
    }
    
    Try {
        // Extract components
        Set tSource = pDynamicObject.source
        Set tTimestamp = pDynamicObject.timestamp
        Set tData = pDynamicObject.data
        Set tMetadata = pDynamicObject.metadata
        
        // Build formatted report
        Set tProcessed = "SOURCE:"_tSource_"|"
        Set tProcessed = tProcessed_"TIMESTAMP:"_tTimestamp_"|"
        
        If $ISOBJECT(tData) {
            If tData.%IsDefined("resultId") {
                Set tProcessed = tProcessed_"RESULT_ID:"_tData.resultId_"|"
            }
            If tData.%IsDefined("specimenId") {
                Set tProcessed = tProcessed_"SPECIMEN_ID:"_tData.specimenId_"|"
            }
            If tData.%IsDefined("testValues") {
                Set tProcessed = tProcessed_"VALUES:"_tData.testValues_"|"
            }
        }
        
        // Add interpretation
        Set tInterpretation = ..interpretResults(tData)
        Set tProcessed = tProcessed_"INTERPRETATION:"_tInterpretation
    }
    Catch ex {
        Set tProcessed = "ERROR:PROCESSING_FAILED"
    }
    
    Quit tProcessed
}

/// Format as PDF (simulated)
Method formatAsPDF(pData As %String) As %String [ Private ]
{
    Set tPDF = "PDF_REPORT{"
    Set tPDF = tPDF_"template:"_..FormatConfig("PDF", "template")_","
    Set tPDF = tPDF_"pageSize:"_..FormatConfig("PDF", "pageSize")_","
    Set tPDF = tPDF_"content:["
    
    // Parse data and format
    Set tParts = $LISTFROMSTRING(pData, "|")
    For i=1:1:$LISTLENGTH(tParts) {
        Set tPart = $LISTGET(tParts, i)
        If tPart [ ":" {
            Set tKey = $PIECE(tPart, ":", 1)
            Set tValue = $PIECE(tPart, ":", 2, *)
            Set tPDF = tPDF_"{"_tKey_":"_tValue_"}"
            If i < $LISTLENGTH(tParts) Set tPDF = tPDF_","
        }
    }
    
    Set tPDF = tPDF_"]}"
    Quit tPDF
}

/// Format as HL7 message
Method formatAsHL7(pData As %String) As %String [ Private ]
{
    Set tHL7 = "MSH|^~\&|LAB|HOSPITAL|EHR|CLINIC|"_$ZDATE($HOROLOG, 8)_$ZTIME($PIECE($HOROLOG, ",", 2), 8)_"||ORU^R01|"_..ReportCounter_"|P|"_..FormatConfig("HL7", "version")_$CHAR(13)
    
    // Add PID segment (patient)
    Set tPatientId = $PIECE($PIECE(pData, "PATIENT:", 2), "|", 1)
    Set tHL7 = tHL7_"PID|1||"_tPatientId_"|||||||||||||||"_$CHAR(13)
    
    // Add OBR segment (order)
    Set tOrderId = $PIECE($PIECE(pData, "ORDER:", 2), "|", 1)
    Set tTestCode = $PIECE($PIECE(pData, "TEST:", 2), "|", 1)
    Set tHL7 = tHL7_"OBR|1||"_tOrderId_"|"_tTestCode_"|||"_$ZDATETIME($HOROLOG, 3)_"||||||||||||||||||||F"_$CHAR(13)
    
    // Add OBX segments (results)
    If pData [ "VALUES:" {
        Set tValues = $PIECE($PIECE(pData, "VALUES:", 2), "|", 1)
        Set tHL7 = tHL7_"OBX|1|ST|"_tTestCode_"||"_tValues_"||||||F"_$CHAR(13)
    }
    
    Quit tHL7
}

/// Format as FHIR resource
Method formatAsFHIR(pData As %String) As %String [ Private ]
{
    Set tFHIR = "{"
    Set tFHIR = tFHIR_"""resourceType"":""DiagnosticReport"","
    Set tFHIR = tFHIR_"""id"":"""_..ReportCounter_""","
    
    // Extract and format data
    Set tPatientId = $PIECE($PIECE(pData, "PATIENT:", 2), "|", 1)
    Set tFHIR = tFHIR_"""subject"":{""reference"":""Patient/"_tPatientId_"""},"
    
    Set tTestCode = $PIECE($PIECE(pData, "TEST:", 2), "|", 1)
    Set tFHIR = tFHIR_"""code"":{""text"":"""_tTestCode_"""},"
    
    Set tFHIR = tFHIR_"""status"":""final"","
    Set tFHIR = tFHIR_"""issued"":"""_$ZDATETIME($HOROLOG, 3, 7)_""""
    
    // Add results if present
    If pData [ "VALUES:" {
        Set tValues = $PIECE($PIECE(pData, "VALUES:", 2), "|", 1)
        Set tFHIR = tFHIR_",""result"":[{""display"":"""_tValues_"""}]"
    }
    
    Set tFHIR = tFHIR_"}"
    Quit tFHIR
}

/// Format as HTML
Method formatAsHTML(pData As %String) As %String [ Private ]
{
    Set tHTML = "<div class='lab-report'>"
    Set tHTML = tHTML_"<h1>Laboratory Report</h1>"
    Set tHTML = tHTML_"<table class='results-table'>"
    
    // Parse and format data
    Set tParts = $LISTFROMSTRING(pData, "|")
    For i=1:1:$LISTLENGTH(tParts) {
        Set tPart = $LISTGET(tParts, i)
        If tPart [ ":" {
            Set tKey = $PIECE(tPart, ":", 1)
            Set tValue = $PIECE(tPart, ":", 2, *)
            Set tHTML = tHTML_"<tr><td><strong>"_tKey_"</strong></td><td>"_tValue_"</td></tr>"
        }
    }
    
    Set tHTML = tHTML_"</table>"
    Set tHTML = tHTML_"<p class='timestamp'>Generated: "_$ZDATETIME($HOROLOG, 3)_"</p>"
    Set tHTML = tHTML_"</div>"
    
    Quit tHTML
}

/// Format as plain text
Method formatAsText(pData As %String) As %String [ Private ]
{
    Set tText = $JUSTIFY("", ..FormatConfig("TEXT", "width"), "=")_$CHAR(13, 10)
    Set tText = tText_"LABORATORY REPORT"_$CHAR(13, 10)
    Set tText = tText_$JUSTIFY("", ..FormatConfig("TEXT", "width"), "=")_$CHAR(13, 10)
    
    // Parse and format data
    Set tParts = $LISTFROMSTRING(pData, "|")
    For i=1:1:$LISTLENGTH(tParts) {
        Set tPart = $LISTGET(tParts, i)
        If tPart [ ":" {
            Set tKey = $PIECE(tPart, ":", 1)
            Set tValue = $PIECE(tPart, ":", 2, *)
            Set tText = tText_$JUSTIFY(tKey, 20)_": "_tValue_$CHAR(13, 10)
        }
    }
    
    Set tText = tText_$JUSTIFY("", ..FormatConfig("TEXT", "width"), "-")_$CHAR(13, 10)
    Set tText = tText_"Generated: "_$ZDATETIME($HOROLOG, 3)_$CHAR(13, 10)
    Set tText = tText_$JUSTIFY("", ..FormatConfig("TEXT", "width"), "=")
    
    Quit tText
}

/// Merge lab data from multiple sources
Method mergeLabData(pOrderData As %String, pProcessData As %String) As %String [ Private ]
{
    Set tMerged = ""
    
    If pOrderData '= "" {
        If pOrderData '[ "ERROR" {
            Set tMerged = pOrderData
        }
    }
    
    If pProcessData '= "" {
        If pProcessData '[ "ERROR" {
            If tMerged '= "" Set tMerged = tMerged_"|"
            Set tMerged = tMerged_pProcessData
        }
    }
    
    Quit tMerged
}

/// Apply clinical interpretation to results
Method applyClinicalInterpretation(pData As %String) As %String [ Private ]
{
    Set tInterpreted = pData
    Set tInterpretation = ""
    
    // Check for critical values
    If pData [ "VALUES:" {
        Set tValues = $PIECE($PIECE(pData, "VALUES:", 2), "|", 1)
        
        // Simple interpretation logic
        If tValues [ "Glucose=" {
            Set tGlucose = +$PIECE($PIECE(tValues, "Glucose=", 2), ";", 1)
            If tGlucose > 200 {
                Set tInterpretation = "CRITICAL:HIGH_GLUCOSE"
            } ElseIf tGlucose < 50 {
                Set tInterpretation = "CRITICAL:LOW_GLUCOSE"
            } Else {
                Set tInterpretation = "NORMAL"
            }
        } Else {
            Set tInterpretation = "NORMAL"
        }
    }
    
    If tInterpretation '= "" {
        Set tInterpreted = tInterpreted_"|CLINICAL_INTERPRETATION:"_tInterpretation
    }
    
    Quit tInterpreted
}

/// Interpret results for clinical significance
Method interpretResults(pData As %DynamicObject) As %String [ Private ]
{
    Set tInterpretation = "NORMAL"
    
    If $ISOBJECT(pData) {
        If pData.%IsDefined("testValues") {
            // Simple interpretation based on values
            Set tValues = pData.testValues
            If tValues [ "HIGH" Set tInterpretation = "ABNORMAL:HIGH"
            If tValues [ "LOW" Set tInterpretation = "ABNORMAL:LOW"
            If tValues [ "CRITICAL" Set tInterpretation = "CRITICAL"
        }
    }
    
    Quit tInterpretation
}

/// Determine distribution based on results
Method determineDistribution(pData As %String) As %String [ Private ]
{
    Set tDistribution = "NORMAL"
    
    If pData [ "CRITICAL" {
        Set tDistribution = "CRITICAL"
    } ElseIf pData [ "ABNORMAL" {
        Set tDistribution = "ABNORMAL"
    }
    
    Quit tDistribution
}

/// Distribute report based on priority
Method distributeReport(pReport As %String, pDistribution As %String) [ Private ]
{
    Set tMethods = ..DistributionLists(pDistribution, "methods")
    
    // Simulate distribution
    If tMethods [ "EMAIL" {
        // Would send email
    }
    If tMethods [ "SMS" {
        // Would send SMS for critical results
    }
    If tMethods [ "SYSTEM" {
        // System notification always happens
    }
}

/// Archive report for retention
Method archiveReport(pReportId As %String, pReport As %String, pFormat As %String) [ Private ]
{
    Set tKey = pReportId_":"_$HOROLOG
    Set ..ReportArchive(tKey, "report") = pReport
    Set ..ReportArchive(tKey, "format") = pFormat
    Set ..ReportArchive(tKey, "archived") = $ZDATETIME($HOROLOG, 3)
    
    // Cleanup if exceeding max size
    Do ..cleanupArchive()
}

/// Cleanup old archived reports
Method cleanupArchive() [ Private ]
{
    Set tCount = 0
    Set tKey = ""
    
    For {
        Set tKey = $ORDER(..ReportArchive(tKey))
        Quit:tKey=""
        Continue:((tKey="initialized")||(tKey="maxSize"))
        Set tCount = tCount + 1
    }
    
    // Remove oldest if over limit
    If tCount > ..ReportArchive("maxSize") {
        Set tRemoveCount = tCount - (..ReportArchive("maxSize") * 0.9)
        Set tKey = ""
        For i=1:1:tRemoveCount {
            Set tKey = $ORDER(..ReportArchive(tKey))
            Continue:((tKey="initialized")||(tKey="maxSize"))
            Kill ..ReportArchive(tKey)
        }
    }
}

/// Set subsystem references
Method SetSubsystems(pTestOrderer As LabTestOrderer, pTestProcessor As LabTestProcessor) As %Status
{
    Set tSC = $$$OK
    Try {
        If $ISOBJECT(pTestOrderer) {
            Set ..TestOrdererRef = pTestOrderer
        }
        If $ISOBJECT(pTestProcessor) {
            Set ..TestProcessorRef = pTestProcessor
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get formatting statistics
Method GetStatistics() As %String
{
    Set tStats = "ReportsGenerated:"_..ReportCounter
    Set tStats = tStats_"|DefaultFormat:"_..DefaultFormat
    Set tStats = tStats_"|ArchivedReports:"_..countArchived()
    
    Quit tStats
}

/// Count archived reports
Method countArchived() As %Integer [ Private ]
{
    Set tCount = 0
    Set tKey = ""
    
    For {
        Set tKey = $ORDER(..ReportArchive(tKey))
        Quit:tKey=""
        Continue:((tKey="initialized")||(tKey="maxSize"))
        Set tCount = tCount + 1
    }
    
    Quit tCount
}

}
