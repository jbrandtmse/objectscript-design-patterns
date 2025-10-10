/// Healthcare Example - Medical History Lazy Loader
/// 
/// Intent:
/// Provides lazy loading capabilities for patient medical history data.
/// Demonstrates performance optimization by deferring expensive data loads.
/// 
/// Applicability:
/// - Medical history data is large and expensive to load
/// - Not all patient interactions require full medical history
/// - Need to optimize performance for common workflows
/// - Want transparent loading without affecting client code
/// 
/// Structure:
/// <example>
/// Set loader = ##class(MedicalHistoryLazyLoader).%New()
/// Set history = loader.LoadMedicalHistory("MRN123")
/// Set labResults = loader.LoadLabResults("MRN123")
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.LazyLoad
/// @see Patterns.Examples.Clinical.VirtualProxyPatient
/// @since 1.0.0
Class Patterns.Examples.Clinical.MedicalHistoryLazyLoader Extends %RegisteredObject
{

/// Load complete medical history for a patient
/// 
/// @param pPatientMRN Patient medical record number
/// @return List of medical history records
ClassMethod LoadMedicalHistory(pPatientMRN As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    // Simulate loading expensive medical history data
    // In real implementation, this would query database
    For i=1:1:10 {
        Set tRecord = {}
        Set tRecord.RecordId = "HIST-"_pPatientMRN_"-"_i
        Set tRecord.RecordType = "History"
        Set tRecord.Date = $HOROLOG - (i * 30)
        Set tRecord.Details = "Medical history record "_i_" for patient "_pPatientMRN
        Do tList.Insert(tRecord)
    }
    
    Quit tList
}

/// Load lab results for a patient
/// 
/// @param pPatientMRN Patient medical record number
/// @return List of lab result records
ClassMethod LoadLabResults(pPatientMRN As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    // Simulate loading expensive lab results
    // Could be thousands of results over patient lifetime
    For i=1:1:50 {
        Set tResult = {}
        Set tResult.ResultId = "LAB-"_pPatientMRN_"-"_i
        Set tResult.TestName = "Test "_i
        Set tResult.Value = 100 + i
        Set tResult.Date = $HOROLOG - (i * 7)
        Do tList.Insert(tResult)
    }
    
    Quit tList
}

/// Load imaging studies for a patient
/// 
/// @param pPatientMRN Patient medical record number
/// @return List of imaging study records
ClassMethod LoadImagingStudies(pPatientMRN As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    // Simulate loading large imaging study metadata
    // Actual images would be even larger
    For i=1:1:20 {
        Set tStudy = {}
        Set tStudy.StudyId = "IMG-"_pPatientMRN_"-"_i
        Set tStudy.Modality = $CASE(i#4, 0:"CT", 1:"MRI", 2:"X-RAY", :"US")
        Set tStudy.Date = $HOROLOG - (i * 60)
        Set tStudy.ImageCount = 50 + (i * 10)
        Do tList.Insert(tStudy)
    }
    
    Quit tList
}

/// Load medication history for a patient
/// 
/// @param pPatientMRN Patient medical record number
/// @return List of medication records
ClassMethod LoadMedicationHistory(pPatientMRN As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    // Simulate loading medication history
    For i=1:1:30 {
        Set tMed = {}
        Set tMed.MedicationId = "MED-"_pPatientMRN_"-"_i
        Set tMed.DrugName = "Medication "_i
        Set tMed.Dosage = (i * 10)_" mg"
        Set tMed.StartDate = $HOROLOG - (i * 90)
        Do tList.Insert(tMed)
    }
    
    Quit tList
}

/// Load a patient object by MRN
/// 
/// @param pPatientMRN Patient medical record number
/// @return Patient object (for Virtual Proxy use)
ClassMethod Load(pPatientMRN As %String) As Patterns.Examples.Clinical.VirtualProxyPatient
{
    Set tPatient = ##class(Patterns.Examples.Clinical.VirtualProxyPatient).%New()
    Set tPatient.PatientMRN = pPatientMRN
    Set tPatient.FirstName = "John"
    Set tPatient.LastName = "Doe"
    
    Quit tPatient
}

/// Simulate performance metrics for lazy vs eager loading
/// 
/// @return Dynamic object with performance comparison
ClassMethod GetPerformanceComparison() As %DynamicObject
{
    Set tComparison = {}
    
    // Eager loading: Load everything upfront
    Set tEagerStart = $HOROLOG
    Set tHistory = ..LoadMedicalHistory("MRN123")
    Set tLabs = ..LoadLabResults("MRN123")
    Set tImaging = ..LoadImagingStudies("MRN123")
    Set tMeds = ..LoadMedicationHistory("MRN123")
    Set tEagerEnd = $HOROLOG
    Set tComparison.eagerLoadTimeMs = 450  // Simulated time
    Set tComparison.eagerRecordsLoaded = 110
    
    // Lazy loading: Only load what's needed
    Set tLazyStart = $HOROLOG
    // Only load basic patient info initially
    Set tComparison.lazyLoadTimeMs = 50  // Simulated time
    Set tComparison.lazyRecordsLoaded = 10
    
    // Performance improvement
    Set tComparison.timeReduction = tComparison.eagerLoadTimeMs - tComparison.lazyLoadTimeMs
    Set tComparison.percentFaster = ((tComparison.timeReduction / tComparison.eagerLoadTimeMs) * 100)
    Set tComparison.conclusion = "Lazy loading is "_tComparison.percentFaster_"% faster for common use cases"
    
    Quit tComparison
}

}
