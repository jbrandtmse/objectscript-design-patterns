/// Debug helper for Template Method Pattern tests
Class Patterns.Test.Unit.GoF.Behavioral.TemplateMethodDebugHelper
{

/// Debug the specific failing tests
ClassMethod DebugFailingTests() As %String
{
    Set result = ""
    
    // Debug TestErrorHandling
    Set result = result_"=== Testing TestErrorHandling ==="_$CHAR(10)
    
    // Create report with empty patient ID (as test does)
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("")
    Set tOutput = tReport.GenerateReport("Text")
    
    Set result = result_"Output length: "_$LENGTH(tOutput)_$CHAR(10)
    Set result = result_"Contains PATIENT SUMMARY REPORT: "_(tOutput [ "PATIENT SUMMARY REPORT")_$CHAR(10)
    Set result = result_"First 500 chars: "_$EXTRACT(tOutput, 1, 500)_$CHAR(10)
    
    Set result = result_$CHAR(10)_"=== Testing TestHookMethods ==="_$CHAR(10)
    
    // Test hook methods
    Set tReport2 = ##class(Patterns.Examples.PatientSummaryReport).%New("HOOK123")
    Set tHookResult = tReport2.Hook()
    Set result = result_"Hook() returns: "_tHookResult_$CHAR(10)
    Set result = result_"Hook() = 1: "_(tHookResult = 1)_$CHAR(10)
    
    Set tOutput2 = tReport2.GenerateReport("Text")
    Set result = result_"Contains 'Additional information': "_(tOutput2 [ "Additional information")_$CHAR(10)
    Set result = result_"Contains 'Next Appointment': "_(tOutput2 [ "Next Appointment")_$CHAR(10)
    
    // Check for case sensitivity issues
    Set pos = $FIND(tOutput2, "Additional")
    If pos > 0 {
        Set context = $EXTRACT(tOutput2, pos-20, pos+30)
        Set result = result_"Context around 'Additional': "_context_$CHAR(10)
    }
    
    Quit result
}

/// Test a specific case in isolation
ClassMethod TestEmptyPatientId() As %String
{
    Set result = ""
    
    Try {
        // Test with empty patient ID
        Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("")
        
        // Check patient info initialization
        Set result = result_"PatientInfo('Id'): "_$GET(tReport.PatientInfo("Id"), "[UNDEFINED]")_$CHAR(10)
        Set result = result_"PatientInfo('Name'): "_$GET(tReport.PatientInfo("Name"), "[UNDEFINED]")_$CHAR(10)
        
        // Generate report and check for errors
        Set tOutput = tReport.GenerateReport("Text")
        
        If tOutput = "" {
            Set result = result_"ERROR: Report output is empty!"_$CHAR(10)
        } ElseIf tOutput [ "Error generating report" {
            Set result = result_"ERROR in generation: "_tOutput_$CHAR(10)
        } Else {
            Set result = result_"Report generated successfully, length: "_$LENGTH(tOutput)_$CHAR(10)
            Set result = result_"Has title: "_(tOutput [ "PATIENT SUMMARY REPORT")_$CHAR(10)
        }
        
    } Catch ex {
        Set result = result_"EXCEPTION: "_ex.DisplayString()_$CHAR(10)
    }
    
    Quit result
}

/// Check specific text patterns in reports
ClassMethod CheckTextPatterns() As %String
{
    Set result = ""
    
    // Generate a report and check patterns
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("TEST123")
    Set tOutput = tReport.GenerateReport("Text")
    
    // Check for exact case patterns
    Set patterns = $LISTBUILD(
        "Additional information:",
        "Additional information",
        "Additional Information:",
        "Additional Information"
    )
    
    Set ptr = 0
    While $LISTNEXT(patterns, ptr, pattern) {
        If tOutput [ pattern {
            Set result = result_"Found pattern: '"_pattern_"'"_$CHAR(10)
        }
    }
    
    // Check for Next Appointment
    If tOutput [ "Next Appointment" {
        Set result = result_"Found 'Next Appointment'"_$CHAR(10)
    }
    
    // Look for the supplementary section
    Set pos = $FIND(tOutput, "Additional")
    If pos > 0 {
        Set lineStart = pos - 50
        If lineStart < 1 Set lineStart = 1
        Set lineEnd = pos + 100
        If lineEnd > $LENGTH(tOutput) Set lineEnd = $LENGTH(tOutput)
        Set context = $EXTRACT(tOutput, lineStart, lineEnd)
        Set result = result_"Context: "_context_$CHAR(10)
    }
    
    Quit result
}

}
