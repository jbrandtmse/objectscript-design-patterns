/// <example>
/// Concrete builder for radiology/imaging reports
/// Specializes in building imaging study reports with findings and impressions
/// </example>
Class Patterns.Examples.RadiologyReportBuilder Extends MedicalReportBuilder
{

/// <summary>
/// Get the report type for radiology reports
/// </summary>
Method GetReportType() As %String
{
    Quit "Radiology Report"
}

/// <summary>
/// Build patient information section for radiology report
/// </summary>
Method BuildPatientInfo(pPatientId As %String, pName As %String, pDateOfBirth As %String, pMRN As %String = "") As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tInfo = "PATIENT INFORMATION" _ $Char(13,10)
        Set tInfo = tInfo _ "===================" _ $Char(13,10)
        Set tInfo = tInfo _ "Name: " _ pName _ $Char(13,10)
        Set tInfo = tInfo _ "Patient ID: " _ pPatientId _ $Char(13,10)
        Set tInfo = tInfo _ "DOB: " _ pDateOfBirth _ $Char(13,10)
        If (pMRN '= "") {
            Set tInfo = tInfo _ "Medical Record Number: " _ pMRN _ $Char(13,10)
        }
        Set tInfo = tInfo _ "Exam Date/Time: " _ $ZDATETIME($HOROLOG, 3) _ $Char(13,10)
        Set tInfo = tInfo _ "Study Status: FINAL"
        Set ..Report.PatientInfo = tInfo
    }
    Quit $THIS
}

/// <summary>
/// Build clinical history section for radiology report
/// </summary>
Method BuildClinicalHistory(pHistory As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tHistory = "CLINICAL HISTORY AND INDICATION:" _ $Char(13,10)
        Set tHistory = tHistory _ "=================================" _ $Char(13,10)
        Set tHistory = tHistory _ pHistory _ $Char(13,10)
        Set tHistory = tHistory _ $Char(13,10) _ "COMPARISON: Prior studies available for comparison"
        Set ..Report.ClinicalHistory = tHistory
    }
    Quit $THIS
}

/// <summary>
/// Build findings section for radiology report
/// </summary>
Method BuildFindings(pFindings As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tFindings = "FINDINGS:" _ $Char(13,10)
        Set tFindings = tFindings _ "=========" _ $Char(13,10)
        Set tFindings = tFindings _ pFindings _ $Char(13,10)
        Set tFindings = tFindings _ $Char(13,10) _ "TECHNIQUE:" _ $Char(13,10)
        Set tFindings = tFindings _ "Standard imaging protocol was performed." _ $Char(13,10)
        Set tFindings = tFindings _ "Images were acquired in multiple planes." _ $Char(13,10)
        Set tFindings = tFindings _ "Quality: Diagnostic"
        Set ..Report.Findings = tFindings
    }
    Quit $THIS
}

/// <summary>
/// Build interpretation section for radiology report (called "Impression" in radiology)
/// </summary>
Method BuildInterpretation(pInterpretation As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tInterpretation = "IMPRESSION:" _ $Char(13,10)
        Set tInterpretation = tInterpretation _ "===========" _ $Char(13,10)
        Set tInterpretation = tInterpretation _ pInterpretation _ $Char(13,10)
        Set tInterpretation = tInterpretation _ $Char(13,10) _ "BI-RADS Category: Assessment pending additional imaging"
        Set ..Report.Interpretation = tInterpretation
    }
    Quit $THIS
}

/// <summary>
/// Build recommendations section for radiology report
/// </summary>
Method BuildRecommendations(pRecommendations As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tRecommendations = "RECOMMENDATIONS:" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "===============" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ pRecommendations _ $Char(13,10)
        Set tRecommendations = tRecommendations _ $Char(13,10) _ "Please correlate with clinical findings and patient symptoms."
        Set ..Report.Recommendations = tRecommendations
        
        // Add standard radiology metadata
        Do ..Report.SetMetadata("Modality", "Digital Radiography")
        Do ..Report.SetMetadata("ACR", "Accredited")
        Do ..Report.SetMetadata("PACS", "Archived")
    }
    Quit $THIS
}

/// <summary>
/// Build a chest X-ray report
/// </summary>
Method BuildChestXRayReport(pReportId As %String, pPatientId As %String, pPatientName As %String, pIndication As %String, pLungs As %String = "Clear", pHeart As %String = "Normal size", pBones As %String = "No acute abnormality") As MedicalReport
{
    Do ..Reset()
    Do ..SetReportIdentification(pReportId, "Chest X-Ray")
    Do ..BuildPatientInfo(pPatientId, pPatientName, "01/01/1970")
    Do ..BuildClinicalHistory(pIndication)
    
    // Build chest X-ray specific findings
    Set tFindings = "CHEST, PA AND LATERAL:" _ $Char(13,10) _ $Char(13,10)
    Set tFindings = tFindings _ "Lungs: " _ pLungs _ $Char(13,10)
    Set tFindings = tFindings _ "Heart: " _ pHeart _ $Char(13,10)
    Set tFindings = tFindings _ "Mediastinum: Normal contour" _ $Char(13,10)
    Set tFindings = tFindings _ "Pleura: No effusion" _ $Char(13,10)
    Set tFindings = tFindings _ "Bones: " _ pBones _ $Char(13,10)
    Set tFindings = tFindings _ "Soft tissues: Unremarkable"
    Do ..BuildFindings(tFindings)
    
    // Build impression based on findings
    Set tImpression = ""
    If (pLungs = "Clear") && (pHeart = "Normal size") {
        Set tImpression = "No acute cardiopulmonary process"
    } Else {
        Set tImpression = "See findings above for details"
    }
    Do ..BuildInterpretation(tImpression)
    
    Do ..BuildRecommendations("No follow-up imaging recommended at this time")
    Do ..AddSignature("Radiologist", "MD")
    Do ..SetStatus("Final")
    Do ..SetPriority(3)  // Routine
    Do ..AddMetadata("StudyType", "XR")
    Do ..AddMetadata("BodyPart", "CHEST")
    Do ..AddMetadata("Views", "PA and Lateral")
    
    Quit ..GetResult()
}

/// <summary>
/// Build a CT scan report
/// </summary>
Method BuildCTScanReport(pReportId As %String, pPatientId As %String, pPatientName As %String, pBodyPart As %String, pIndication As %String, pFindings As %String, pContrast As %Boolean = 0) As MedicalReport
{
    Do ..Reset()
    Do ..SetReportIdentification(pReportId, "CT " _ pBodyPart)
    Do ..BuildPatientInfo(pPatientId, pPatientName, "01/01/1970")
    
    Set tHistory = pIndication
    If pContrast {
        Set tHistory = tHistory _ $Char(13,10) _ "Contrast: IV contrast administered"
    } Else {
        Set tHistory = tHistory _ $Char(13,10) _ "Contrast: None"
    }
    Do ..BuildClinicalHistory(tHistory)
    
    // Build CT specific findings
    Set tFindings = "CT " _ $ZCONVERT(pBodyPart, "U") _ ":" _ $Char(13,10) _ $Char(13,10)
    Set tFindings = tFindings _ pFindings _ $Char(13,10) _ $Char(13,10)
    Set tFindings = tFindings _ "Slice Thickness: 5mm" _ $Char(13,10)
    Set tFindings = tFindings _ "Reconstruction: Multiplanar" _ $Char(13,10)
    If pContrast {
        Set tFindings = tFindings _ "Contrast Enhancement: Adequate"
    }
    Do ..BuildFindings(tFindings)
    
    Do ..BuildInterpretation("See detailed findings above")
    Do ..BuildRecommendations("Clinical correlation recommended")
    Do ..AddSignature("Staff Radiologist", "MD")
    Do ..AddSignature("Resident", "MD", $ZDATETIME($HOROLOG-1, 3))  // Preliminary read
    Do ..SetStatus("Final")
    
    // CT scans often have higher priority
    Do ..SetPriority(2)  // Urgent
    Do ..AddMetadata("StudyType", "CT")
    Do ..AddMetadata("BodyPart", pBodyPart)
    If pContrast {
        Do ..AddMetadata("Contrast", "Yes")
    }
    
    Quit ..GetResult()
}

/// <summary>
/// Build an MRI report
/// </summary>
Method BuildMRIReport(pReportId As %String, pPatientId As %String, pPatientName As %String, pBodyPart As %String, pSequences As %String, pFindings As %String, pGadolinium As %Boolean = 0) As MedicalReport
{
    Do ..Reset()
    Do ..SetReportIdentification(pReportId, "MRI " _ pBodyPart)
    Do ..BuildPatientInfo(pPatientId, pPatientName, "01/01/1970")
    
    Set tHistory = "MRI examination requested" _ $Char(13,10)
    Set tHistory = tHistory _ "Sequences performed: " _ pSequences
    If pGadolinium {
        Set tHistory = tHistory _ $Char(13,10) _ "Gadolinium contrast: Administered"
    }
    Do ..BuildClinicalHistory(tHistory)
    
    // Build MRI specific findings
    Set tFindings = "MRI " _ $ZCONVERT(pBodyPart, "U") _ ":" _ $Char(13,10) _ $Char(13,10)
    Set tFindings = tFindings _ "SEQUENCES: " _ pSequences _ $Char(13,10) _ $Char(13,10)
    Set tFindings = tFindings _ "FINDINGS:" _ $Char(13,10)
    Set tFindings = tFindings _ pFindings _ $Char(13,10)
    Set tFindings = tFindings _ $Char(13,10) _ "Field Strength: 1.5 Tesla" _ $Char(13,10)
    Set tFindings = tFindings _ "Image Quality: Satisfactory"
    Do ..BuildFindings(tFindings)
    
    Do ..BuildInterpretation("MRI findings as detailed above")
    Do ..BuildRecommendations("Follow-up as clinically indicated")
    Do ..AddSignature("Neuroradiologist", "MD")
    Do ..SetStatus("Final")
    Do ..SetPriority(2)  // Urgent - MRIs are typically ordered for specific concerns
    Do ..AddMetadata("StudyType", "MRI")
    Do ..AddMetadata("BodyPart", pBodyPart)
    Do ..AddMetadata("FieldStrength", "1.5T")
    
    Quit ..GetResult()
}

}
