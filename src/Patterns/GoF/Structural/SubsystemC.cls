/// Facade Pattern - Subsystem C
/// Complex subsystem that handles output formatting and reporting
/// Depends on both SubsystemA and SubsystemB for complete processing
Class Patterns.GoF.Structural.SubsystemC Extends %RegisteredObject
{

/// References to other subsystems
Property SubsystemARef As SubsystemA;

Property SubsystemBRef As SubsystemB;

/// Output formatting configuration
Property FormatConfig [ MultiDimensional ];

/// Report generation cache
Property ReportCache [ MultiDimensional ];

/// Output formats supported
Property SupportedFormats As %List [ InitialExpression = {$LISTBUILD("JSON", "XML", "CSV", "HTML", "TEXT")} ];

/// Current output format
Property CurrentFormat As %String [ InitialExpression = "JSON" ];

/// Statistics
Property FormattedCount As %Integer [ InitialExpression = 0 ];

Property ReportsGenerated As %Integer [ InitialExpression = 0 ];

/// Complex initialization with format configuration
Method %OnNew(pFormat As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        If pFormat '= "" {
            If $LISTFIND(..SupportedFormats, pFormat) {
                Set ..CurrentFormat = pFormat
            }
        }
        
        // Initialize format configuration
        Set ..FormatConfig("JSON", "indent") = 2
        Set ..FormatConfig("JSON", "pretty") = 1
        Set ..FormatConfig("XML", "version") = "1.0"
        Set ..FormatConfig("XML", "encoding") = "UTF-8"
        Set ..FormatConfig("CSV", "delimiter") = ","
        Set ..FormatConfig("CSV", "header") = 1
        Set ..FormatConfig("HTML", "style") = "table"
        Set ..FormatConfig("TEXT", "width") = 80
        
        // Initialize report cache
        Set ..ReportCache("initialized") = $HOROLOG
        Set ..ReportCache("maxSize") = 100
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Format output with complex formatting rules
Method FormatOutput(pData As %String) As %String
{
    Set tFormatted = ""
    
    // Validate input
    If pData = "" {
        Quit "ERROR:NO_DATA"
    }
    
    // Choose formatting based on current format
    If ..CurrentFormat = "JSON" {
        Set tFormatted = ..formatAsJSON(pData)
    } ElseIf ..CurrentFormat = "XML" {
        Set tFormatted = ..formatAsXML(pData)
    } ElseIf ..CurrentFormat = "CSV" {
        Set tFormatted = ..formatAsCSV(pData)
    } ElseIf ..CurrentFormat = "HTML" {
        Set tFormatted = ..formatAsHTML(pData)
    } Else {
        Set tFormatted = ..formatAsText(pData)
    }
    
    // Update statistics
    Set ..FormattedCount = ..FormattedCount + 1
    
    // Cache the formatted output
    Do ..cacheOutput(tFormatted)
    
    Quit tFormatted
}

/// Generate comprehensive report using all subsystems
Method GenerateReport(pRequest As %DynamicObject) As %String
{
    Set tReport = ""
    
    Try {
        // Step 1: Collect data from SubsystemA if available
        Set tDataA = ""
        If $ISOBJECT(..SubsystemARef) {
            Set tDataA = ..collectFromSubsystemA()
        }
        
        // Step 2: Collect data from SubsystemB if available
        Set tDataB = ""
        If $ISOBJECT(..SubsystemBRef) {
            Set tDataB = ..collectFromSubsystemB()
        }
        
        // Step 3: Merge and process data
        Set tMerged = ..mergeSubsystemData(tDataA, tDataB)
        
        // Step 4: Apply report template
        Set tTemplated = ..applyReportTemplate(tMerged, pRequest)
        
        // Step 5: Format final report
        Set tReport = ..FormatOutput(tTemplated)
        
        // Update statistics
        Set ..ReportsGenerated = ..ReportsGenerated + 1
        
        // Store in report cache
        Do ..storeReport(tReport)
    }
    Catch ex {
        Set tReport = "ERROR:REPORT_GENERATION_FAILED:"_ex.DisplayString()
    }
    
    Quit tReport
}

/// Process complex dynamic object from SubsystemB
Method ProcessComplexOutput(pDynamicObject As %DynamicObject) As %String
{
    Set tProcessed = ""
    
    If '$ISOBJECT(pDynamicObject) {
        Quit "ERROR:INVALID_OBJECT"
    }
    
    Try {
        // Extract and validate components
        Set tSource = pDynamicObject.source
        Set tTimestamp = pDynamicObject.timestamp
        Set tData = pDynamicObject.data
        Set tChecksum = pDynamicObject.checksum
        
        // Verify checksum
        If '..verifyChecksum(tData, tChecksum) {
            Set tProcessed = "ERROR:CHECKSUM_MISMATCH"
            Quit
        }
        
        // Build formatted output
        Set tProcessed = ..buildFormattedOutput(tSource, tTimestamp, tData)
        
        // Add metadata
        Set tProcessed = ..addOutputMetadata(tProcessed)
    }
    Catch ex {
        Set tProcessed = "ERROR:PROCESSING_FAILED"
    }
    
    Quit tProcessed
}

/// Format data as JSON
Method formatAsJSON(pData As %String) As %String [ Private ]
{
    Set tJSON = "{"
    
    // Parse input data
    Set tParts = $LISTFROMSTRING(pData, "|")
    Set tCount = $LISTLENGTH(tParts)
    
    For i=1:1:tCount {
        Set tPart = $LISTGET(tParts, i)
        If tPart [ ":" {
            Set tKey = $PIECE(tPart, ":", 1)
            Set tValue = $PIECE(tPart, ":", 2, *)
            
            If tJSON '= "{" Set tJSON = tJSON_","
            
            // Escape special characters
            Set tKey = $REPLACE(tKey, """", "\""")
            Set tValue = $REPLACE(tValue, """", "\""")
            
            Set tJSON = tJSON_$CHAR(13,10)_"  """_tKey_""": """_tValue_""""
        }
    }
    
    Set tJSON = tJSON_$CHAR(13,10)_"}"
    
    Quit tJSON
}

/// Format data as XML
Method formatAsXML(pData As %String) As %String [ Private ]
{
    Set tXML = "<?xml version="""_..FormatConfig("XML", "version")_""" encoding="""_..FormatConfig("XML", "encoding")_"""?>"
    Set tXML = tXML_$CHAR(13,10)_"<output>"
    
    // Parse input data
    Set tParts = $LISTFROMSTRING(pData, "|")
    Set tCount = $LISTLENGTH(tParts)
    
    For i=1:1:tCount {
        Set tPart = $LISTGET(tParts, i)
        If tPart [ ":" {
            Set tKey = $PIECE(tPart, ":", 1)
            Set tValue = $PIECE(tPart, ":", 2, *)
            
            // XML escape
            Set tValue = $REPLACE(tValue, "&", "&amp;")
            Set tValue = $REPLACE(tValue, "<", "&lt;")
            Set tValue = $REPLACE(tValue, ">", "&gt;")
            
            Set tXML = tXML_$CHAR(13,10)_"  <"_tKey_">"_tValue_"</"_tKey_">"
        }
    }
    
    Set tXML = tXML_$CHAR(13,10)_"</output>"
    
    Quit tXML
}

/// Format data as CSV
Method formatAsCSV(pData As %String) As %String [ Private ]
{
    Set tCSV = ""
    Set tDelimiter = ..FormatConfig("CSV", "delimiter")
    
    // Build header if configured
    If ..FormatConfig("CSV", "header") {
        Set tHeader = ""
        Set tValues = ""
        
        Set tParts = $LISTFROMSTRING(pData, "|")
        Set tCount = $LISTLENGTH(tParts)
        
        For i=1:1:tCount {
            Set tPart = $LISTGET(tParts, i)
            If tPart [ ":" {
                Set tKey = $PIECE(tPart, ":", 1)
                Set tValue = $PIECE(tPart, ":", 2, *)
                
                If tHeader '= "" {
                    Set tHeader = tHeader_tDelimiter
                    Set tValues = tValues_tDelimiter
                }
                
                Set tHeader = tHeader_tKey
                
                // Quote if contains delimiter
                If tValue [ tDelimiter {
                    Set tValue = """"_$REPLACE(tValue, """", """""")_""""
                }
                Set tValues = tValues_tValue
            }
        }
        
        Set tCSV = tHeader_$CHAR(13,10)_tValues
    } Else {
        // No header, values only
        Set tValues = ""
        Set tParts = $LISTFROMSTRING(pData, "|")
        Set tCount = $LISTLENGTH(tParts)
        
        For i=1:1:tCount {
            Set tPart = $LISTGET(tParts, i)
            If tPart [ ":" {
                Set tValue = $PIECE(tPart, ":", 2, *)
                
                If tValues '= "" Set tValues = tValues_tDelimiter
                
                // Quote if contains delimiter
                If tValue [ tDelimiter {
                    Set tValue = """"_$REPLACE(tValue, """", """""")_""""
                }
                Set tValues = tValues_tValue
            }
        }
        
        Set tCSV = tValues
    }
    
    Quit tCSV
}

/// Format data as HTML table
Method formatAsHTML(pData As %String) As %String [ Private ]
{
    Set tHTML = "<table border='1' style='border-collapse: collapse;'>"
    Set tHTML = tHTML_$CHAR(13,10)_"  <thead>"
    Set tHTML = tHTML_$CHAR(13,10)_"    <tr>"
    
    // Build table from data
    Set tParts = $LISTFROMSTRING(pData, "|")
    Set tCount = $LISTLENGTH(tParts)
    
    // Headers
    For i=1:1:tCount {
        Set tPart = $LISTGET(tParts, i)
        If tPart [ ":" {
            Set tKey = $PIECE(tPart, ":", 1)
            Set tKey = $ZCONVERT(tKey, "O", "HTML")
            Set tHTML = tHTML_$CHAR(13,10)_"      <th>"_tKey_"</th>"
        }
    }
    
    Set tHTML = tHTML_$CHAR(13,10)_"    </tr>"
    Set tHTML = tHTML_$CHAR(13,10)_"  </thead>"
    Set tHTML = tHTML_$CHAR(13,10)_"  <tbody>"
    Set tHTML = tHTML_$CHAR(13,10)_"    <tr>"
    
    // Values
    For i=1:1:tCount {
        Set tPart = $LISTGET(tParts, i)
        If tPart [ ":" {
            Set tValue = $PIECE(tPart, ":", 2, *)
            Set tValue = $ZCONVERT(tValue, "O", "HTML")
            Set tHTML = tHTML_$CHAR(13,10)_"      <td>"_tValue_"</td>"
        }
    }
    
    Set tHTML = tHTML_$CHAR(13,10)_"    </tr>"
    Set tHTML = tHTML_$CHAR(13,10)_"  </tbody>"
    Set tHTML = tHTML_$CHAR(13,10)_"</table>"
    
    Quit tHTML
}

/// Format data as plain text
Method formatAsText(pData As %String) As %String [ Private ]
{
    Set tText = ""
    Set tWidth = ..FormatConfig("TEXT", "width")
    Set tSeparator = $JUSTIFY("", tWidth, "-")
    
    Set tText = tSeparator_$CHAR(13,10)
    
    // Parse and format data
    Set tParts = $LISTFROMSTRING(pData, "|")
    Set tCount = $LISTLENGTH(tParts)
    
    For i=1:1:tCount {
        Set tPart = $LISTGET(tParts, i)
        If tPart [ ":" {
            Set tKey = $PIECE(tPart, ":", 1)
            Set tValue = $PIECE(tPart, ":", 2, *)
            
            // Format as key-value pairs
            Set tLine = $JUSTIFY(tKey, 20)_": "_tValue
            
            // Wrap long lines
            If $LENGTH(tLine) > tWidth {
                Set tLine = $EXTRACT(tLine, 1, tWidth-3)_"..."
            }
            
            Set tText = tText_tLine_$CHAR(13,10)
        }
    }
    
    Set tText = tText_tSeparator
    
    Quit tText
}

/// Collect data from SubsystemA
Method collectFromSubsystemA() As %String [ Private ]
{
    Set tData = ""
    
    Try {
        Set tStats = ..SubsystemARef.GetStatistics()
        Set tData = "SubsystemA|"_tStats
    }
    Catch ex {
        Set tData = "SubsystemA|ERROR"
    }
    
    Quit tData
}

/// Collect data from SubsystemB
Method collectFromSubsystemB() As %String [ Private ]
{
    Set tData = ""
    
    Try {
        Set tStats = ..SubsystemBRef.GetStatistics()
        Set tData = "SubsystemB|"
        Set tData = tData_"Processed:"_tStats.processed_"|"
        Set tData = tData_"Errors:"_tStats.errors_"|"
        Set tData = tData_"Queue:"_tStats.queueSize
    }
    Catch ex {
        Set tData = "SubsystemB|ERROR"
    }
    
    Quit tData
}

/// Merge data from multiple subsystems
Method mergeSubsystemData(pDataA As %String, pDataB As %String) As %String [ Private ]
{
    Set tMerged = ""
    
    If pDataA '= "" {
        Set tMerged = tMerged_pDataA
    }
    
    If pDataB '= "" {
        If tMerged '= "" Set tMerged = tMerged_"|"
        Set tMerged = tMerged_pDataB
    }
    
    // Add merge timestamp
    Set tMerged = tMerged_"|MergeTime:"_$ZTIME($PIECE($HOROLOG, ",", 2))
    
    Quit tMerged
}

/// Apply report template
Method applyReportTemplate(pData As %String, pRequest As %DynamicObject) As %String [ Private ]
{
    Set tTemplated = pData
    
    // Add report metadata
    Set tTemplated = "ReportType:COMPREHENSIVE|"_tTemplated
    
    // Add request parameters if provided
    If $ISOBJECT(pRequest) {
        If pRequest.%IsDefined("title") {
            Set tTemplated = "Title:"_pRequest.title_"|"_tTemplated
        }
        If pRequest.%IsDefined("author") {
            Set tTemplated = "Author:"_pRequest.author_"|"_tTemplated
        }
    }
    
    // Add generation timestamp
    Set tTemplated = tTemplated_"|Generated:"_$ZDATETIME($HOROLOG, 3)
    
    Quit tTemplated
}

/// Verify checksum for data integrity
Method verifyChecksum(pData As %DynamicObject, pChecksum As %String) As %Boolean [ Private ]
{
    // Simplified checksum verification
    // In real implementation would recalculate and compare
    Quit (pChecksum '= "")
}

/// Build formatted output from components
Method buildFormattedOutput(pSource As %String, pTimestamp As %String, pData As %DynamicObject) As %String [ Private ]
{
    Set tOutput = ""
    
    Set tOutput = tOutput_"Source:"_pSource_"|"
    Set tOutput = tOutput_"Timestamp:"_pTimestamp_"|"
    
    If $ISOBJECT(pData) {
        If pData.%IsDefined("primary") {
            Set tOutput = tOutput_"Primary:"_pData.primary_"|"
        }
        If pData.%IsDefined("secondary") {
            Set tOutput = tOutput_"Secondary:"_pData.secondary_"|"
        }
    }
    
    Quit tOutput
}

/// Add output metadata
Method addOutputMetadata(pOutput As %String) As %String [ Private ]
{
    Set tWithMeta = pOutput
    
    Set tWithMeta = tWithMeta_"|Format:"_..CurrentFormat
    Set tWithMeta = tWithMeta_"|FormattedCount:"_..FormattedCount
    
    Quit tWithMeta
}

/// Cache formatted output
Method cacheOutput(pOutput As %String) [ Private ]
{
    Set tKey = "OUTPUT_"_$PIECE($HOROLOG, ",", 2)_"_"_..FormattedCount
    Set ..ReportCache(tKey) = pOutput
    
    // Cleanup old cache entries if exceeding max size
    If ..FormattedCount > ..ReportCache("maxSize") {
        Do ..cleanupCache()
    }
}

/// Store generated report
Method storeReport(pReport As %String) [ Private ]
{
    Set tKey = "REPORT_"_..ReportsGenerated
    Set ..ReportCache(tKey) = pReport
    Set ..ReportCache("lastReport") = tKey
}

/// Cleanup old cache entries
Method cleanupCache() [ Private ]
{
    Set tCount = 0
    Set tKey = ""
    For {
        Set tKey = $ORDER(..ReportCache(tKey))
        Quit:tKey=""
        
        // Skip metadata entries
        Continue:((tKey="initialized")||(tKey="maxSize")||(tKey="lastReport"))
        
        Set tCount = tCount + 1
        
        // Remove oldest entries
        If tCount > (..ReportCache("maxSize") / 2) {
            Kill ..ReportCache(tKey)
        }
    }
}

/// Set subsystem references
Method SetSubsystems(pSubsystemA As SubsystemA, pSubsystemB As SubsystemB) As %Status
{
    Set tSC = $$$OK
    Try {
        If $ISOBJECT(pSubsystemA) {
            Set ..SubsystemARef = pSubsystemA
        }
        If $ISOBJECT(pSubsystemB) {
            Set ..SubsystemBRef = pSubsystemB
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get output statistics
Method GetStatistics() As %String
{
    Set tStats = ""
    
    Set tStats = tStats_"Format:"_..CurrentFormat
    Set tStats = tStats_"|Formatted:"_..FormattedCount
    Set tStats = tStats_"|Reports:"_..ReportsGenerated
    
    Set tLastReport = $GET(..ReportCache("lastReport"), "None")
    Set tStats = tStats_"|LastReport:"_tLastReport
    
    Quit tStats
}

/// Reset subsystem state
Method Reset() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..FormattedCount = 0
        Set ..ReportsGenerated = 0
        Kill ..ReportCache
        Set ..ReportCache("initialized") = $HOROLOG
        Set ..ReportCache("maxSize") = 100
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Change output format
Method SetFormat(pFormat As %String) As %Status
{
    Set tSC = $$$OK
    
    If $LISTFIND(..SupportedFormats, pFormat) {
        Set ..CurrentFormat = pFormat
    } Else {
        Set tSC = $$$ERROR($$$GeneralError, "Unsupported format: "_pFormat)
    }
    
    Quit tSC
}

}
