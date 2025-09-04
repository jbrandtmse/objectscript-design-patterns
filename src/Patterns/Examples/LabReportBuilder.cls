/// <example>
/// Concrete builder for laboratory reports
/// Specializes in building lab test results with specific formatting
/// </example>
Class Patterns.Examples.LabReportBuilder Extends MedicalReportBuilder
{

/// <summary>
/// Get the report type for lab reports
/// </summary>
Method GetReportType() As %String
{
    Quit "Laboratory Report"
}

/// <summary>
/// Build patient information section for lab report
/// </summary>
Method BuildPatientInfo(pPatientId As %String, pName As %String, pDateOfBirth As %String, pMRN As %String = "") As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tInfo = "Patient Name: " _ pName _ $Char(13,10)
        Set tInfo = tInfo _ "Patient ID: " _ pPatientId _ $Char(13,10)
        Set tInfo = tInfo _ "Date of Birth: " _ pDateOfBirth _ $Char(13,10)
        If (pMRN '= "") {
            Set tInfo = tInfo _ "MRN: " _ pMRN _ $Char(13,10)
        }
        Set tInfo = tInfo _ "Specimen Collection Date: " _ $ZDATETIME($HOROLOG, 3)
        Set ..Report.PatientInfo = tInfo
    }
    Quit $THIS
}

/// <summary>
/// Build clinical history section for lab report
/// </summary>
Method BuildClinicalHistory(pHistory As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tHistory = "CLINICAL INFORMATION:" _ $Char(13,10)
        Set tHistory = tHistory _ pHistory _ $Char(13,10)
        Set tHistory = tHistory _ "Indication for Testing: Laboratory workup requested"
        Set ..Report.ClinicalHistory = tHistory
    }
    Quit $THIS
}

/// <summary>
/// Build findings section for lab report
/// </summary>
Method BuildFindings(pFindings As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tFindings = "LABORATORY RESULTS:" _ $Char(13,10)
        Set tFindings = tFindings _ "================================" _ $Char(13,10)
        Set tFindings = tFindings _ pFindings _ $Char(13,10)
        Set tFindings = tFindings _ "================================" _ $Char(13,10)
        Set tFindings = tFindings _ "Reference ranges provided where applicable" _ $Char(13,10)
        Set tFindings = tFindings _ "* = Abnormal value"
        Set ..Report.Findings = tFindings
    }
    Quit $THIS
}

/// <summary>
/// Build interpretation section for lab report
/// </summary>
Method BuildInterpretation(pInterpretation As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tInterpretation = "CLINICAL INTERPRETATION:" _ $Char(13,10)
        Set tInterpretation = tInterpretation _ pInterpretation _ $Char(13,10)
        Set tInterpretation = tInterpretation _ "Note: Results must be interpreted in clinical context"
        Set ..Report.Interpretation = tInterpretation
    }
    Quit $THIS
}

/// <summary>
/// Build recommendations section for lab report
/// </summary>
Method BuildRecommendations(pRecommendations As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tRecommendations = "RECOMMENDATIONS:" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ pRecommendations _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "Please correlate with clinical findings and other diagnostic results"
        Set ..Report.Recommendations = tRecommendations
        
        // Add standard lab metadata
        Do ..Report.SetMetadata("ReportFormat", "Laboratory")
        Do ..Report.SetMetadata("CLIA", "12D4567890")
        Do ..Report.SetMetadata("CAP", "123456")
    }
    Quit $THIS
}

/// <summary>
/// Build a standard CBC report
/// </summary>
Method BuildCBCReport(pReportId As %String, pPatientId As %String, pPatientName As %String, pWBC As %Numeric, pRBC As %Numeric, pHemoglobin As %Numeric, pHematocrit As %Numeric, pPlatelet As %Numeric) As MedicalReport
{
    Do ..Reset()
    Do ..SetReportIdentification(pReportId, ..GetReportType())
    Do ..BuildPatientInfo(pPatientId, pPatientName, "01/01/1980")
    Do ..BuildClinicalHistory("Routine health screening")
    
    // Build CBC findings
    Set tFindings = "Complete Blood Count (CBC):" _ $Char(13,10)
    Set tFindings = tFindings _ "  WBC: " _ pWBC _ " K/uL (4.5-11.0)" _ $Char(13,10)
    Set tFindings = tFindings _ "  RBC: " _ pRBC _ " M/uL (4.5-5.9)" _ $Char(13,10)
    Set tFindings = tFindings _ "  Hemoglobin: " _ pHemoglobin _ " g/dL (13.5-17.5)" _ $Char(13,10)
    Set tFindings = tFindings _ "  Hematocrit: " _ pHematocrit _ " % (41-53)" _ $Char(13,10)
    Set tFindings = tFindings _ "  Platelet: " _ pPlatelet _ " K/uL (150-400)"
    Do ..BuildFindings(tFindings)
    
    // Add interpretation
    Set tInterpretation = ""
    If (pWBC < 4.5) || (pWBC > 11) {
        Set tInterpretation = tInterpretation _ "WBC count abnormal. "
    }
    If (pHemoglobin < 13.5) {
        Set tInterpretation = tInterpretation _ "Low hemoglobin suggests anemia. "
    }
    If (tInterpretation = "") {
        Set tInterpretation = "All values within normal limits"
    }
    Do ..BuildInterpretation(tInterpretation)
    
    Do ..BuildRecommendations("Follow up as clinically indicated")
    Do ..AddSignature("Lab Director", "MD, PhD")
    Do ..SetStatus("Final")
    Do ..SetPriority(3)  // Routine
    
    Quit ..GetResult()
}

/// <summary>
/// Build a metabolic panel report
/// </summary>
Method BuildMetabolicPanelReport(pReportId As %String, pPatientId As %String, pPatientName As %String, pGlucose As %Numeric, pBUN As %Numeric, pCreatinine As %Numeric, pSodium As %Numeric, pPotassium As %Numeric) As MedicalReport
{
    Do ..Reset()
    Do ..SetReportIdentification(pReportId, ..GetReportType())
    Do ..BuildPatientInfo(pPatientId, pPatientName, "01/01/1980")
    Do ..BuildClinicalHistory("Metabolic evaluation")
    
    // Build metabolic panel findings
    Set tFindings = "Basic Metabolic Panel:" _ $Char(13,10)
    Set tFindings = tFindings _ "  Glucose: " _ pGlucose _ " mg/dL (70-110)" _ $Char(13,10)
    Set tFindings = tFindings _ "  BUN: " _ pBUN _ " mg/dL (7-20)" _ $Char(13,10)
    Set tFindings = tFindings _ "  Creatinine: " _ pCreatinine _ " mg/dL (0.6-1.2)" _ $Char(13,10)
    Set tFindings = tFindings _ "  Sodium: " _ pSodium _ " mEq/L (136-145)" _ $Char(13,10)
    Set tFindings = tFindings _ "  Potassium: " _ pPotassium _ " mEq/L (3.5-5.0)"
    Do ..BuildFindings(tFindings)
    
    // Add interpretation based on values
    Set tInterpretation = ""
    If (pGlucose > 110) {
        Set tInterpretation = tInterpretation _ "Elevated glucose. Consider diabetes screening. "
    }
    If (pCreatinine > 1.2) {
        Set tInterpretation = tInterpretation _ "Elevated creatinine may indicate renal impairment. "
    }
    If (tInterpretation = "") {
        Set tInterpretation = "All electrolytes and renal markers within normal range"
    }
    Do ..BuildInterpretation(tInterpretation)
    
    Do ..BuildRecommendations("Monitor and repeat if clinically indicated")
    Do ..AddSignature("Clinical Chemist", "PhD, DABCC")
    Do ..SetStatus("Final")
    
    // High glucose might warrant urgent priority
    If (pGlucose > 200) {
        Do ..SetPriority(2)  // Urgent
    } Else {
        Do ..SetPriority(3)  // Routine
    }
    
    Quit ..GetResult()
}

}
