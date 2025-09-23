/// Gang of Four Interpreter Pattern - Clinical Context for Healthcare Rules
/// 
/// Intent:
/// Extends Context to include patient-specific medical data for rule evaluation.
/// Stores lab values, medications, diagnoses, and vital signs.
/// 
/// Structure:
/// <example>
/// Set context = ##class(ClinicalContext).%New()
/// Set context.PatientId = "12345"
/// Do context.SetLabValue("glucose", 250, "mg/dL")
/// Do context.AddMedication("Metformin", "500mg", "BID")
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Context
/// @since 1.0.0
Class Patterns.Examples.ClinicalContext Extends Patterns.GoF.Behavioral.Context
{

/// ===== PROPERTIES =====
/// Patient identifier
Property PatientId As %String;

/// Patient age
Property Age As %Integer;

/// Patient gender
Property Gender As %String;

/// Lab values storage
Property LabValues As %DynamicObject;

/// Medications list
Property Medications As %DynamicObject;

/// Diagnoses list
Property Diagnoses As %DynamicObject;

/// Vital signs
Property Vitals As %DynamicObject;

/// Clinical alerts collection
Property Alerts As list Of %String;

/// ===== LAB VALUE METHODS =====
/// Set lab value
/// 
/// @param pName Lab test name
/// @param pValue Lab value
/// @param pUnit Unit of measurement
Method SetLabValue(pName As %String, pValue As %Numeric, pUnit As %String = "")
{
    Set tLab = ##class(%DynamicObject).%New()
    Set tLab.value = pValue
    Set tLab.unit = pUnit
    Set tLab.timestamp = $HOROLOG
    Do ..LabValues.%Set(pName, tLab)
}

/// Get lab value
/// 
/// @param pName Lab test name
/// @return Lab value or empty
Method GetLabValue(pName As %String) As %Numeric
{
    If ..LabValues.%IsDefined(pName) {
        Set tLab = ..LabValues.%Get(pName)
        Quit tLab.value
    }
    Quit ""
}

/// ===== MEDICATION METHODS =====
/// Add medication
/// 
/// @param pName Medication name
/// @param pDose Dose amount
/// @param pFrequency Frequency
Method AddMedication(pName As %String, pDose As %String, pFrequency As %String)
{
    Set tMed = ##class(%DynamicObject).%New()
    Set tMed.dose = pDose
    Set tMed.frequency = pFrequency
    Set tMed.startDate = $HOROLOG
    Do ..Medications.%Set(pName, tMed)
}

/// Check if patient is on medication
/// 
/// @param pName Medication name
/// @return %Boolean
Method HasMedication(pName As %String) As %Boolean
{
    Quit ..Medications.%IsDefined(pName)
}

/// Get medication dosage
/// 
/// @param pName Medication name
/// @return Dosage value
Method GetMedicationDosage(pName As %String) As %Numeric
{
    // Simplified - in real system would query medication orders
    If pName = "Morphine" Quit 15
    If pName = "Warfarin" Quit 5
    Quit 0
}

/// ===== DIAGNOSIS METHODS =====
/// Add diagnosis
/// 
/// @param pCode Diagnosis code (ICD-10)
/// @param pDescription Description
Method AddDiagnosis(pCode As %String, pDescription As %String)
{
    Set tDiag = ##class(%DynamicObject).%New()
    Set tDiag.description = pDescription
    Set tDiag.dateRecorded = $HOROLOG
    Do ..Diagnoses.%Set(pCode, tDiag)
}

/// Check if patient has diagnosis
/// 
/// @param pCode Diagnosis code
/// @return %Boolean
Method HasDiagnosis(pCode As %String) As %Boolean
{
    Quit ..Diagnoses.%IsDefined(pCode)
}

/// Get diagnosis
/// 
/// @param pCode Diagnosis code
/// @return Diagnosis string
Method GetDiagnosis(pCode As %String) As %String
{
    If ..Diagnoses.%IsDefined(pCode) {
        Set tDiag = ..Diagnoses.%Get(pCode)
        Quit tDiag.description
    }
    Quit ""
}

/// ===== VITAL SIGNS METHODS =====
/// Set vital sign
/// 
/// @param pName Vital sign name
/// @param pValue Value
Method SetVital(pName As %String, pValue As %Numeric)
{
    Do ..Vitals.%Set(pName, pValue)
}

/// Get vital sign
/// 
/// @param pName Vital sign name
/// @return Value or empty
Method GetVital(pName As %String) As %Numeric
{
    If ..Vitals.%IsDefined(pName) {
        Quit ..Vitals.%Get(pName)
    }
    Quit ""
}

/// ===== CLINICAL SUPPORT METHODS =====
/// Add clinical alert
/// 
/// @param pAlert Alert text
/// @return %Status
Method AddAlert(pAlert As %String) As %Status
{
    Do ..Alerts.Insert(pAlert)
    Quit $$$OK
}

/// Load patient data (simplified)
/// 
/// @param pPatientID Patient identifier
/// @return %Status
Method LoadPatientData(pPatientID As %String) As %Status
{
    // Simplified patient data loading
    Set ..PatientId = pPatientID
    
    // Set sample lab values
    Do ..SetLabValue("Glucose", 250, "mg/dL")
    Do ..SetLabValue("Creatinine", 1.8, "mg/dL")
    Do ..SetLabValue("Hemoglobin", 7.5, "g/dL")
    
    // Set sample medications
    Do ..AddMedication("Warfarin", "5mg", "Daily")
    Do ..AddMedication("Aspirin", "81mg", "Daily")
    Do ..AddMedication("Metformin", "500mg", "BID")
    
    // Set sample diagnoses
    Do ..AddDiagnosis("E11.9", "Diabetes")
    Do ..AddDiagnosis("I10", "Hypertension")
    Do ..AddDiagnosis("N18.3", "Renal_Insufficiency")
    
    // Set sample vitals
    Do ..SetVital("HR", 95)
    Do ..SetVital("BP_Systolic", 145)
    Do ..SetVital("BP_Diastolic", 90)
    Do ..SetVital("Temperature", 98.6)
    Do ..SetVital("SpO2", 95)
    
    Quit $$$OK
}

/// ===== CONSTRUCTORS =====
/// Initialize clinical context
Method %OnNew() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    Set ..LabValues = ##class(%DynamicObject).%New()
    Set ..Medications = ##class(%DynamicObject).%New()
    Set ..Diagnoses = ##class(%DynamicObject).%New()
    Set ..Vitals = ##class(%DynamicObject).%New()
    
    Quit $$$OK
}

}
