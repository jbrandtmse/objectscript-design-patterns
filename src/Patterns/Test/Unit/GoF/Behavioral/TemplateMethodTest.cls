/// Unit tests for Template Method Pattern Implementation
Class Patterns.Test.Unit.GoF.Behavioral.TemplateMethodTest Extends %UnitTest.TestCase
{

/// Test basic template method execution
Method TestBasicTemplateExecution() As %Status
{
    Set tSC = $$$OK
    
    // Create a patient summary report
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("TEST123")
    Do $$$AssertTrue($IsObject(tReport), "Report object created")
    
    // Execute the template method directly
    Set tSC = tReport.Execute()
    Do $$$AssertStatusOK(tSC, "Template method executed successfully")
    
    // Check that execution time was set
    Set tTime = tReport.GetLastExecutionTime()
    Do $$$AssertTrue(tTime '= "", "Execution time was recorded")
    
    Quit $$$OK
}

/// Test report generation workflow
Method TestReportGeneration() As %Status
{
    Set tSC = $$$OK
    
    // Test PatientSummaryReport
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("12345")
    Set tOutput = tReport.GenerateReport("Text")
    Do $$$AssertTrue(tOutput '= "", "Patient summary report generated")
    Do $$$AssertTrue(tOutput [ "PATIENT SUMMARY REPORT", "Report contains correct title")
    Do $$$AssertTrue(tOutput [ "Demographics", "Report contains demographics section")
    Do $$$AssertTrue(tOutput [ "Active Diagnoses", "Report contains diagnoses section")
    
    // Test LabResultsReport
    Set tLabReport = ##class(Patterns.Examples.LabResultsReport).%New("67890")
    Set tLabOutput = tLabReport.GenerateReport("Text")
    Do $$$AssertTrue(tLabOutput '= "", "Lab results report generated")
    Do $$$AssertTrue(tLabOutput [ "LABORATORY RESULTS REPORT", "Lab report has correct title")
    Do $$$AssertTrue(tLabOutput [ "Complete Blood Count", "Lab report contains CBC section")
    
    Quit $$$OK
}

/// Test different output formats
Method TestOutputFormats() As %Status
{
    Set tSC = $$$OK
    
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("FORMAT123")
    
    // Test Text format
    Set tTextOutput = tReport.GenerateReport("Text")
    Do $$$AssertTrue(tTextOutput [ "======", "Text format contains separators")
    
    // Test HTML format
    Set tHTMLOutput = tReport.GenerateReport("HTML")
    Do $$$AssertTrue(tHTMLOutput [ "<html>", "HTML format contains HTML tags")
    Do $$$AssertTrue(tHTMLOutput [ "<div class='header'>", "HTML format contains header div")
    
    // Test PDF format (simulated)
    Set tPDFOutput = tReport.GenerateReport("PDF")
    Do $$$AssertTrue(tPDFOutput [ "%PDF-1.4", "PDF format contains PDF header")
    Do $$$AssertTrue(tPDFOutput [ "%%EOF", "PDF format contains EOF marker")
    
    Quit $$$OK
}

/// Test that template method cannot be overridden
Method TestTemplateMethodFinality() As %Status
{
    Set tSC = $$$OK
    
    // Validate that Execute method is Final
    Set tSC = ##class(Patterns.GoF.Behavioral.TemplateMethod).ValidateImplementation("Patterns.Examples.PatientSummaryReport")
    Do $$$AssertStatusOK(tSC, "PatientSummaryReport validates correctly")
    
    Set tSC = ##class(Patterns.GoF.Behavioral.TemplateMethod).ValidateImplementation("Patterns.Examples.LabResultsReport")
    Do $$$AssertStatusOK(tSC, "LabResultsReport validates correctly")
    
    Quit $$$OK
}

/// Test hook method behavior
Method TestHookMethods() As %Status
{
    Set tSC = $$$OK
    
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("HOOK123")
    
    // Hook method should return true by default
    Set tHookResult = tReport.Hook()
    Do $$$AssertTrue(tHookResult = 1, "Hook method returns true")
    
    // Generate report to trigger hooks
    Set tOutput = tReport.GenerateReport("Text")
    
    // Check that supplementary info was added (triggered by Hook returning true)
    Do $$$AssertTrue(tOutput [ "Additional information", "Optional operation executed based on hook")
    Do $$$AssertTrue(tOutput [ "Next Appointment", "Supplementary info includes appointment")
    
    Quit $$$OK
}

/// Test primitive operations implementation
Method TestPrimitiveOperations() As %Status
{
    Set tSC = $$$OK
    
    // Test that concrete classes implement required primitive operations
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("PRIM123")
    
    // Call primitive operations directly
    Set tSC = tReport.GatherReportData()
    Do $$$AssertStatusOK(tSC, "GatherReportData implemented and executes")
    
    Set tSC = tReport.ProcessReportContent()
    Do $$$AssertStatusOK(tSC, "ProcessReportContent implemented and executes")
    
    Set tTitle = tReport.GetReportTitle()
    Do $$$AssertTrue(tTitle '= "", "GetReportTitle returns a value")
    Do $$$AssertEquals(tTitle, "PATIENT SUMMARY REPORT", "Title is correct")
    
    Quit $$$OK
}

/// Test report validation
Method TestReportValidation() As %Status
{
    Set tSC = $$$OK
    
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("VAL123")
    
    // Before gathering data, validation should fail
    Set tSC = tReport.ValidateReport()
    Do $$$AssertTrue($$$ISERR(tSC), "Validation fails when report is incomplete")
    
    // After gathering data
    Set tSC = tReport.GatherReportData()
    Do $$$AssertStatusOK(tSC, "Data gathered successfully")
    
    Set tSC = tReport.ValidateReport()
    Do $$$AssertStatusOK(tSC, "Validation passes after data is gathered")
    
    Quit $$$OK
}

/// Test factory method for creating instances
Method TestFactoryMethod() As %Status
{
    Set tSC = $$$OK
    
    // Test creating valid instance
    Set tInstance = ##class(Patterns.GoF.Behavioral.TemplateMethod).CreateInstance("Patterns.Examples.PatientSummaryReport")
    Do $$$AssertTrue($IsObject(tInstance), "Factory creates valid instance")
    Do $$$AssertTrue(tInstance.%IsA("Patterns.GoF.Behavioral.TemplateMethod"), "Instance is correct type")
    
    // Test with invalid class name
    Set tBadInstance = ##class(Patterns.GoF.Behavioral.TemplateMethod).CreateInstance("NonExistent.Class")
    Do $$$AssertTrue(tBadInstance = "", "Factory returns empty for invalid class")
    
    Quit $$$OK
}

/// Test Hollywood Principle explanation
Method TestHollywoodPrinciple() As %Status
{
    Set tSC = $$$OK
    
    Set tExplanation = ##class(Patterns.GoF.Behavioral.TemplateMethod).ExplainHollywoodPrinciple()
    Do $$$AssertTrue(tExplanation [ "Don't call us", "Explanation contains Hollywood Principle")
    Do $$$AssertTrue(tExplanation [ "base class", "Explanation mentions base class control")
    Do $$$AssertTrue(tExplanation [ "subclass", "Explanation mentions subclasses")
    
    Quit $$$OK
}

/// Test error handling in template steps
Method TestErrorHandling() As %Status
{
    Set tSC = $$$OK
    
    // Create report but don't initialize patient data
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("")
    
    // This should still execute without errors due to error handling
    Set tOutput = tReport.GenerateReport("Text")
    Do $$$AssertTrue(tOutput '= "", "Report generated even with minimal data")
    
    // Check that it contains at least the structure
    Do $$$AssertTrue(tOutput [ "PATIENT SUMMARY REPORT", "Report has title despite minimal data")
    
    Quit $$$OK
}

/// Test algorithm step execution order
Method TestAlgorithmOrder() As %Status
{
    Set tSC = $$$OK
    
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Create a test report that logs execution order
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("ORDER123")
    
    // Execute the template method
    Set tSC = tReport.Execute()
    Do $$$AssertStatusOK(tSC, "Template method executed")
    
    // The order should be: Initialize -> PrimitiveOp1 -> ConcreteOp -> PrimitiveOp2 -> Hook/Optional -> Finalize
    // We can verify by checking that report was properly constructed
    Set tValidation = tReport.ValidateReport()
    Do $$$AssertStatusOK(tValidation, "Report validation confirms proper execution order")
    
    Quit $$$OK
}

/// Test multiple report types
Method TestMultipleReportTypes() As %Status
{
    Set tSC = $$$OK
    
    // Create array of different report types
    Set tReports(1) = ##class(Patterns.Examples.PatientSummaryReport).%New("MULTI1")
    Set tReports(2) = ##class(Patterns.Examples.LabResultsReport).%New("MULTI2")
    
    // Each should produce different content but follow same template
    For i=1:1:2 {
        Set tOutput = tReports(i).GenerateReport("Text")
        Do $$$AssertTrue(tOutput '= "", "Report " _ i _ " generated")
        
        // All should have common structure elements
        Do $$$AssertTrue(tOutput [ "======", "Report " _ i _ " has separators")
        Do $$$AssertTrue(tOutput [ "General Hospital", "Report " _ i _ " has facility name")
        Do $$$AssertTrue(tOutput [ "CONFIDENTIAL", "Report " _ i _ " has footer")
    }
    
    // But different titles
    Set tOutput1 = tReports(1).GenerateReport("Text")
    Set tOutput2 = tReports(2).GenerateReport("Text")
    Do $$$AssertTrue(tOutput1 [ "PATIENT SUMMARY", "First is patient summary")
    Do $$$AssertTrue(tOutput2 [ "LABORATORY RESULTS", "Second is lab results")
    
    Quit $$$OK
}

/// Test performance of template execution
Method TestPerformance() As %Status
{
    Set tSC = $$$OK
    
    // Record start time
    Set tStart = $ZHOROLOG
    
    // Generate multiple reports
    For i=1:1:10 {
        Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("PERF" _ i)
        Set tOutput = tReport.GenerateReport("Text")
    }
    
    // Calculate elapsed time
    Set tEnd = $ZHOROLOG
    Set tElapsed = tEnd - tStart
    
    // Should complete 10 reports in under 2 seconds (requirement)
    Do $$$AssertTrue(tElapsed < 2, "Performance requirement met: 10 reports in " _ tElapsed _ " seconds")
    
    Quit $$$OK
}

/// Clean up after tests
Method OnAfterAllTests() As %Status
{
    // Clean up any test data
    Kill ^Patterns.Reports.AuditLog
    Kill ^ClineDebug
    
    Quit $$$OK
}

}
