/// Patient Summary Report - Concrete Template Method Implementation
/// <p>Generates comprehensive patient summary reports including demographics,
/// diagnoses, medications, and allergies.</p>
Class Patterns.Examples.PatientSummaryReport Extends Patterns.Examples.ReportGenerator
{

/// Get the report title
Method GetReportTitle() As %String
{
    Quit "PATIENT SUMMARY REPORT"
}

/// Gather patient-specific data for the summary report
Method GatherReportData() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Add report header
        Do ..AddReportHeader()
        
        // Demographics Section
        Set ..ReportContent("Body", "Demographics", "Age") = "45 years"
        Set ..ReportContent("Body", "Demographics", "Gender") = "Male"
        Set ..ReportContent("Body", "Demographics", "Blood Type") = "O+"
        Set ..ReportContent("Body", "Demographics", "Primary Language") = "English"
        Set ..ReportContent("Body", "Demographics", "Emergency Contact") = "Jane Doe (555-0123)"
        
        // Active Diagnoses
        Set ..ReportContent("Body", "Active Diagnoses", "Primary") = "Type 2 Diabetes Mellitus (E11.9)"
        Set ..ReportContent("Body", "Active Diagnoses", "Secondary 1") = "Essential Hypertension (I10)"
        Set ..ReportContent("Body", "Active Diagnoses", "Secondary 2") = "Hyperlipidemia (E78.5)"
        Set ..ReportContent("Body", "Active Diagnoses", "Date of Onset") = "2018-03-15"
        
        // Current Medications
        Set ..ReportContent("Body", "Current Medications", "Medication 1") = "Metformin 500mg - Twice daily"
        Set ..ReportContent("Body", "Current Medications", "Medication 2") = "Lisinopril 10mg - Once daily"
        Set ..ReportContent("Body", "Current Medications", "Medication 3") = "Atorvastatin 20mg - Once daily at bedtime"
        Set ..ReportContent("Body", "Current Medications", "Last Review") = "2025-09-01"
        
        // Allergies and Adverse Reactions
        Set ..ReportContent("Body", "Allergies", "Drug Allergy 1") = "Penicillin - Rash"
        Set ..ReportContent("Body", "Allergies", "Drug Allergy 2") = "Sulfa drugs - Hives"
        Set ..ReportContent("Body", "Allergies", "Food Allergy") = "Shellfish - Anaphylaxis"
        Set ..ReportContent("Body", "Allergies", "Environmental") = "Pollen - Seasonal rhinitis"
        
        // Recent Vital Signs
        Set ..ReportContent("Body", "Recent Vital Signs", "Blood Pressure") = "130/80 mmHg"
        Set ..ReportContent("Body", "Recent Vital Signs", "Heart Rate") = "72 bpm"
        Set ..ReportContent("Body", "Recent Vital Signs", "Temperature") = "98.6°F"
        Set ..ReportContent("Body", "Recent Vital Signs", "Weight") = "185 lbs"
        Set ..ReportContent("Body", "Recent Vital Signs", "BMI") = "26.5"
        Set ..ReportContent("Body", "Recent Vital Signs", "Last Recorded") = $ZDATETIME($HOROLOG-1, 3)
        
        // Immunizations
        Set ..ReportContent("Body", "Immunizations", "COVID-19") = "Fully vaccinated (2025-01-15)"
        Set ..ReportContent("Body", "Immunizations", "Influenza") = "Current (2024-10-01)"
        Set ..ReportContent("Body", "Immunizations", "Tetanus") = "Current (2020-06-15)"
        Set ..ReportContent("Body", "Immunizations", "Pneumococcal") = "Completed (2023-04-20)"
        
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
        // Add summary statistics
        Set ..ReportContent("Body", "Summary Statistics", "Total Diagnoses") = "3"
        Set ..ReportContent("Body", "Summary Statistics", "Active Medications") = "3"
        Set ..ReportContent("Body", "Summary Statistics", "Known Allergies") = "4"
        Set ..ReportContent("Body", "Summary Statistics", "Report Generated") = ..GeneratedAt
        
        // Add care team information
        Set ..ReportContent("Body", "Care Team", "Primary Care Provider") = "Dr. Smith, MD"
        Set ..ReportContent("Body", "Care Team", "Endocrinologist") = "Dr. Johnson, MD"
        Set ..ReportContent("Body", "Care Team", "Care Coordinator") = "Mary Wilson, RN"
        Set ..ReportContent("Body", "Care Team", "Pharmacy") = "General Hospital Pharmacy"
        
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
    // Include optional sections for patient summary
    Quit 1
}

/// Add supplementary information specific to patient summary
Method AddSupplementaryInfo()
{
    Set ..ReportContent("Supplementary", "Note") = "This is a comprehensive patient summary. For detailed medical history, please refer to the complete medical record."
    Set ..ReportContent("Supplementary", "Next Appointment") = "2025-10-15 at 2:00 PM with Dr. Smith"
    Set ..ReportContent("Supplementary", "Last Updated") = ..GeneratedAt
}

/// Class method to generate a sample report
ClassMethod GenerateSampleReport() As %String
{
    Set tReport = ##class(Patterns.Examples.PatientSummaryReport).%New("12345")
    Quit tReport.GenerateReport("Text")
}

}
