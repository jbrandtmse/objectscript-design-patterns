/// <example>
/// Concrete builder for hospital discharge summary reports
/// Specializes in building comprehensive discharge summaries
/// </example>
Class Patterns.Examples.DischargeReportBuilder Extends MedicalReportBuilder
{

/// <summary>
/// Get the report type for discharge summaries
/// </summary>
Method GetReportType() As %String
{
    Quit "Discharge Summary"
}

/// <summary>
/// Build patient information section for discharge summary
/// </summary>
Method BuildPatientInfo(pPatientId As %String, pName As %String, pDateOfBirth As %String, pMRN As %String = "") As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tInfo = "DISCHARGE SUMMARY" _ $Char(13,10)
        Set tInfo = tInfo _ "=================" _ $Char(13,10) _ $Char(13,10)
        Set tInfo = tInfo _ "Patient: " _ pName _ $Char(13,10)
        Set tInfo = tInfo _ "MRN: " _ $Select(pMRN'="":pMRN, 1:pPatientId) _ $Char(13,10)
        Set tInfo = tInfo _ "Date of Birth: " _ pDateOfBirth _ $Char(13,10)
        Set tInfo = tInfo _ "Admission Date: " _ $ZDATETIME($HOROLOG-7, 3) _ $Char(13,10)
        Set tInfo = tInfo _ "Discharge Date: " _ $ZDATETIME($HOROLOG, 3) _ $Char(13,10)
        Set tInfo = tInfo _ "Length of Stay: 7 days"
        Set ..Report.PatientInfo = tInfo
    }
    Quit $THIS
}

/// <summary>
/// Build clinical history section for discharge summary
/// </summary>
Method BuildClinicalHistory(pHistory As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tHistory = "ADMISSION DIAGNOSIS:" _ $Char(13,10)
        Set tHistory = tHistory _ "===================" _ $Char(13,10)
        Set tHistory = tHistory _ pHistory _ $Char(13,10) _ $Char(13,10)
        Set tHistory = tHistory _ "CHIEF COMPLAINT:" _ $Char(13,10)
        Set tHistory = tHistory _ "Patient presented with symptoms requiring hospitalization" _ $Char(13,10) _ $Char(13,10)
        Set tHistory = tHistory _ "HISTORY OF PRESENT ILLNESS:" _ $Char(13,10)
        Set tHistory = tHistory _ "See admission note for detailed history"
        Set ..Report.ClinicalHistory = tHistory
    }
    Quit $THIS
}

/// <summary>
/// Build findings section for discharge summary (hospital course)
/// </summary>
Method BuildFindings(pFindings As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tFindings = "HOSPITAL COURSE:" _ $Char(13,10)
        Set tFindings = tFindings _ "===============" _ $Char(13,10)
        Set tFindings = tFindings _ pFindings _ $Char(13,10) _ $Char(13,10)
        Set tFindings = tFindings _ "PROCEDURES PERFORMED:" _ $Char(13,10)
        Set tFindings = tFindings _ "See procedure notes for details" _ $Char(13,10) _ $Char(13,10)
        Set tFindings = tFindings _ "CONSULTATIONS:" _ $Char(13,10)
        Set tFindings = tFindings _ "Relevant specialty consultations obtained as indicated"
        Set ..Report.Findings = tFindings
    }
    Quit $THIS
}

/// <summary>
/// Build interpretation section for discharge summary (discharge diagnosis)
/// </summary>
Method BuildInterpretation(pInterpretation As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tInterpretation = "DISCHARGE DIAGNOSIS:" _ $Char(13,10)
        Set tInterpretation = tInterpretation _ "===================" _ $Char(13,10)
        Set tInterpretation = tInterpretation _ "Primary: " _ pInterpretation _ $Char(13,10)
        Set tInterpretation = tInterpretation _ "Secondary: See problem list" _ $Char(13,10) _ $Char(13,10)
        Set tInterpretation = tInterpretation _ "DISCHARGE CONDITION:" _ $Char(13,10)
        Set tInterpretation = tInterpretation _ "Stable, improved from admission"
        Set ..Report.Interpretation = tInterpretation
    }
    Quit $THIS
}

/// <summary>
/// Build recommendations section for discharge summary (discharge instructions)
/// </summary>
Method BuildRecommendations(pRecommendations As %String) As MedicalReportBuilder
{
    If $ISOBJECT(..Report) {
        Set tRecommendations = "DISCHARGE INSTRUCTIONS:" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "======================" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ pRecommendations _ $Char(13,10) _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "DISCHARGE MEDICATIONS:" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "See medication reconciliation form" _ $Char(13,10) _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "FOLLOW-UP APPOINTMENTS:" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "Primary care physician in 1-2 weeks" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "Specialist follow-up as arranged" _ $Char(13,10) _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "ACTIVITY:" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "As tolerated" _ $Char(13,10) _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "DIET:" _ $Char(13,10)
        Set tRecommendations = tRecommendations _ "Regular diet unless otherwise specified"
        Set ..Report.Recommendations = tRecommendations
        
        // Add discharge-specific metadata
        Do ..Report.SetMetadata("DischargeDisposition", "Home")
        Do ..Report.SetMetadata("DischargeType", "Regular")
        Do ..Report.SetMetadata("Reconciliation", "Complete")
    }
    Quit $THIS
}

/// <summary>
/// Build a standard medical discharge summary
/// </summary>
Method BuildMedicalDischarge(pReportId As %String, pPatientId As %String, pPatientName As %String, pAdmissionDx As %String, pDischargeDx As %String, pHospitalCourse As %String) As MedicalReport
{
    Do ..Reset()
    Do ..SetReportIdentification(pReportId, ..GetReportType())
    Do ..BuildPatientInfo(pPatientId, pPatientName, "01/01/1960")
    Do ..BuildClinicalHistory(pAdmissionDx)
    Do ..BuildFindings(pHospitalCourse)
    Do ..BuildInterpretation(pDischargeDx)
    Do ..BuildRecommendations("Continue current medications. Follow up with PCP in 1 week.")
    Do ..AddSignature("Attending Physician", "MD")
    Do ..AddSignature("Resident", "MD")
    Do ..SetStatus("Final")
    Do ..SetPriority(2)  // Discharge summaries are important
    Do ..AddMetadata("LengthOfStay", "7")
    Do ..AddMetadata("DischargeUnit", "Medical Floor")
    
    Quit ..GetResult()
}

/// <summary>
/// Build a surgical discharge summary
/// </summary>
Method BuildSurgicalDischarge(pReportId As %String, pPatientId As %String, pPatientName As %String, pProcedure As %String, pPostOpCourse As %String, pComplications As %String = "None") As MedicalReport
{
    Do ..Reset()
    Do ..SetReportIdentification(pReportId, "Surgical " _ ..GetReportType())
    Do ..BuildPatientInfo(pPatientId, pPatientName, "01/01/1960")
    
    // Surgical-specific history
    Set tHistory = "PROCEDURE: " _ pProcedure _ $Char(13,10)
    Set tHistory = tHistory _ "INDICATION: Surgical intervention required"
    Do ..BuildClinicalHistory(tHistory)
    
    // Post-operative course
    Set tCourse = "POST-OPERATIVE COURSE:" _ $Char(13,10)
    Set tCourse = tCourse _ pPostOpCourse _ $Char(13,10) _ $Char(13,10)
    Set tCourse = tCourse _ "COMPLICATIONS: " _ pComplications
    Do ..BuildFindings(tCourse)
    
    Do ..BuildInterpretation("Post-operative recovery, stable for discharge")
    
    // Surgical-specific recommendations
    Set tRec = "SURGICAL FOLLOW-UP:" _ $Char(13,10)
    Set tRec = tRec _ "- Wound check in 1 week" _ $Char(13,10)
    Set tRec = tRec _ "- Suture removal in 10-14 days" _ $Char(13,10)
    Set tRec = tRec _ "- Activity restrictions for 4-6 weeks" _ $Char(13,10)
    Set tRec = tRec _ "- Pain management as prescribed"
    Do ..BuildRecommendations(tRec)
    
    Do ..AddSignature("Attending Surgeon", "MD, FACS")
    Do ..AddSignature("Surgical Resident", "MD")
    Do ..SetStatus("Final")
    Do ..SetPriority(1)  // Surgical discharges often STAT priority
    Do ..AddMetadata("ServiceLine", "Surgery")
    Do ..AddMetadata("PostOpDay", "3")
    
    Quit ..GetResult()
}

/// <summary>
/// Build an ICU discharge/transfer summary
/// </summary>
Method BuildICUDischarge(pReportId As %String, pPatientId As %String, pPatientName As %String, pAdmissionReason As %String, pICUCourse As %String, pTransferTo As %String = "Medical Floor") As MedicalReport
{
    Do ..Reset()
    Do ..SetReportIdentification(pReportId, "ICU Transfer Summary")
    Do ..BuildPatientInfo(pPatientId, pPatientName, "01/01/1955")
    
    // ICU-specific history
    Set tHistory = "ICU ADMISSION REASON: " _ pAdmissionReason _ $Char(13,10)
    Set tHistory = tHistory _ "SEVERITY: Critical but now stabilized"
    Do ..BuildClinicalHistory(tHistory)
    
    // ICU course with detailed monitoring
    Set tCourse = "ICU COURSE:" _ $Char(13,10)
    Set tCourse = tCourse _ pICUCourse _ $Char(13,10) _ $Char(13,10)
    Set tCourse = tCourse _ "VENTILATOR STATUS: Weaned and extubated" _ $Char(13,10)
    Set tCourse = tCourse _ "HEMODYNAMIC STATUS: Stable off pressors" _ $Char(13,10)
    Set tCourse = tCourse _ "NEUROLOGIC STATUS: Alert and oriented"
    Do ..BuildFindings(tCourse)
    
    Do ..BuildInterpretation("Improved, stable for floor transfer")
    
    // ICU transfer recommendations
    Set tRec = "TRANSFER TO: " _ pTransferTo _ $Char(13,10) _ $Char(13,10)
    Set tRec = tRec _ "MONITORING REQUIREMENTS:" _ $Char(13,10)
    Set tRec = tRec _ "- Telemetry for 24 hours" _ $Char(13,10)
    Set tRec = tRec _ "- Q4H vital signs" _ $Char(13,10)
    Set tRec = tRec _ "- Daily labs" _ $Char(13,10)
    Set tRec = tRec _ "- Continue current medications"
    Do ..BuildRecommendations(tRec)
    
    Do ..AddSignature("ICU Attending", "MD, FCCM")
    Do ..AddSignature("ICU Fellow", "MD")
    Do ..SetStatus("Final")
    Do ..SetPriority(1)  // ICU transfers are STAT
    Do ..AddMetadata("ICUDays", "3")
    Do ..AddMetadata("TransferLevel", pTransferTo)
    
    Quit ..GetResult()
}

}
