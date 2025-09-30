/// Lab Results Report - Concrete Template Method Implementation
/// <p>Generates laboratory test results reports including test values,
/// reference ranges, and abnormal flags.</p>
Class Patterns.Examples.LabResultsReport Extends Patterns.Examples.ReportGenerator
{

/// Get the report title
Method GetReportTitle() As %String
{
    Quit "LABORATORY RESULTS REPORT"
}

/// Gather lab-specific data for the results report
Method GatherReportData() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Add report header
        Do ..AddReportHeader()
        
        // Test Order Information
        Set ..ReportContent("Body", "Test Information", "Order Date") = "2025-09-28"
        Set ..ReportContent("Body", "Test Information", "Collection Date") = "2025-09-29 08:30 AM"
        Set ..ReportContent("Body", "Test Information", "Specimen Type") = "Blood (Venous)"
        Set ..ReportContent("Body", "Test Information", "Ordering Provider") = "Dr. Smith, MD"
        Set ..ReportContent("Body", "Test Information", "Lab ID") = "LAB-2025-092901"
        
        // Complete Blood Count (CBC)
        Set ..ReportContent("Body", "Complete Blood Count", "WBC") = "7.2 K/uL (4.5-11.0) Normal"
        Set ..ReportContent("Body", "Complete Blood Count", "RBC") = "4.8 M/uL (4.5-5.9) Normal"
        Set ..ReportContent("Body", "Complete Blood Count", "Hemoglobin") = "14.5 g/dL (13.5-17.5) Normal"
        Set ..ReportContent("Body", "Complete Blood Count", "Hematocrit") = "42.3% (39-49) Normal"
        Set ..ReportContent("Body", "Complete Blood Count", "Platelets") = "250 K/uL (150-400) Normal"
        Set ..ReportContent("Body", "Complete Blood Count", "MCV") = "88 fL (80-100) Normal"
        
        // Comprehensive Metabolic Panel
        Set ..ReportContent("Body", "Metabolic Panel", "Glucose") = "165 mg/dL (70-100) HIGH ***"
        Set ..ReportContent("Body", "Metabolic Panel", "BUN") = "18 mg/dL (7-20) Normal"
        Set ..ReportContent("Body", "Metabolic Panel", "Creatinine") = "0.9 mg/dL (0.6-1.2) Normal"
        Set ..ReportContent("Body", "Metabolic Panel", "Sodium") = "140 mEq/L (136-145) Normal"
        Set ..ReportContent("Body", "Metabolic Panel", "Potassium") = "4.2 mEq/L (3.5-5.0) Normal"
        Set ..ReportContent("Body", "Metabolic Panel", "Chloride") = "102 mEq/L (98-107) Normal"
        Set ..ReportContent("Body", "Metabolic Panel", "CO2") = "24 mEq/L (22-28) Normal"
        
        // Lipid Panel
        Set ..ReportContent("Body", "Lipid Panel", "Total Cholesterol") = "210 mg/dL (<200) BORDERLINE"
        Set ..ReportContent("Body", "Lipid Panel", "Triglycerides") = "175 mg/dL (<150) HIGH *"
        Set ..ReportContent("Body", "Lipid Panel", "HDL Cholesterol") = "45 mg/dL (>40) Normal"
        Set ..ReportContent("Body", "Lipid Panel", "LDL Cholesterol") = "130 mg/dL (<100) HIGH *"
        Set ..ReportContent("Body", "Lipid Panel", "Non-HDL Cholesterol") = "165 mg/dL (<130) HIGH *"
        
        // Hemoglobin A1c
        Set ..ReportContent("Body", "Diabetes Markers", "Hemoglobin A1c") = "7.8% (<5.7) HIGH **"
        Set ..ReportContent("Body", "Diabetes Markers", "eAG") = "177 mg/dL"
        Set ..ReportContent("Body", "Diabetes Markers", "Interpretation") = "Diabetes - Above target"
        
        // Thyroid Function
        Set ..ReportContent("Body", "Thyroid Function", "TSH") = "2.1 mIU/L (0.4-4.0) Normal"
        Set ..ReportContent("Body", "Thyroid Function", "Free T4") = "1.2 ng/dL (0.8-1.8) Normal"
        
        // Critical Values
        Set ..ReportContent("Body", "Critical Values", "Alert") = "Glucose level significantly elevated"
        Set ..ReportContent("Body", "Critical Values", "Action") = "Provider notified at 10:45 AM"
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process and validate the report content
Method ProcessReportContent() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Add trending information
        Set ..ReportContent("Body", "Trending", "Glucose Trend") = "Increasing (145->155->165 mg/dL)"
        Set ..ReportContent("Body", "Trending", "A1c Trend") = "Improving (8.2->7.9->7.8%)"
        Set ..ReportContent("Body", "Trending", "Lipids Trend") = "Stable"
        
        // Add summary flags
        Set ..ReportContent("Body", "Summary", "Total Tests") = "25"
        Set ..ReportContent("Body", "Summary", "Abnormal Results") = "6"
        Set ..ReportContent("Body", "Summary", "Critical Results") = "1"
        Set ..ReportContent("Body", "Summary", "Results Status") = "Final"
        Set ..ReportContent("Body", "Summary", "Verified By") = "Lab Tech Johnson"
        Set ..ReportContent("Body", "Summary", "Verification Time") = ..GeneratedAt
        
        // Validate required sections exist
        Set tSC = ..ValidateReport()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Hook to determine if optional sections should be included
Method Hook() As %Boolean
{
    // Include optional sections for lab results
    Quit 1
}

/// Add supplementary information specific to lab results
Method AddSupplementaryInfo()
{
    Set ..ReportContent("Supplementary", "Note") = "*** = Critical value, ** = Significantly abnormal, * = Abnormal"
    Set ..ReportContent("Supplementary", "Reference Lab") = "General Hospital Laboratory - CLIA #12345678"
    Set ..ReportContent("Supplementary", "Next Labs Due") = "2025-12-29 - Repeat A1c and Lipids"
    Set ..ReportContent("Supplementary", "Comments") = "Fasting specimen. Patient compliant with 12-hour fast."
}

/// Class method to generate a sample report
ClassMethod GenerateSampleReport() As %String
{
    Set tReport = ##class(Patterns.Examples.LabResultsReport).%New("12345")
    Quit tReport.GenerateReport("Text")
}

}
