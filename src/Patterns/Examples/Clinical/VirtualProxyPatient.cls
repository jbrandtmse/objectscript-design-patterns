/// Healthcare Example - Virtual Proxy Patient with Lazy Loading
/// 
/// Intent:
/// Demonstrates Virtual Proxy pattern for lazy loading patient medical history.
/// Patient object starts with basic demographics, medical data loads on demand.
/// 
/// Motivation:
/// Loading complete patient medical history upfront is expensive and often unnecessary.
/// Virtual Proxy delays loading expensive collections until they are actually accessed.
/// This provides significant performance improvement for common workflows.
/// 
/// Applicability:
/// - Patient has large medical history (labs, imaging, medications)
/// - Most workflows only need basic patient demographics
/// - Want transparent lazy loading without client code changes
/// - Performance optimization is critical
/// 
/// Structure:
/// <example>
/// Set patient = ##class(VirtualProxyPatient).%New()
/// Set patient.PatientMRN = "MRN123"
/// // No medical history loaded yet
/// Set history = patient.GetMedicalHistory()  // Triggers lazy load
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.VirtualProxy
/// @see Patterns.Examples.Clinical.MedicalHistoryLazyLoader
/// @since 1.0.0
Class Patterns.Examples.Clinical.VirtualProxyPatient Extends %RegisteredObject
{

/// Patient medical record number
Property PatientMRN As %String;

/// Patient first name
Property FirstName As %String;

/// Patient last name
Property LastName As %String;

/// Date of birth
Property DateOfBirth As %Date;

/// Lazy-loaded medical history (private storage)
Property MedicalHistory As %ListOfObjects [ Private ];

/// Flag indicating if medical history has been loaded
Property MedicalHistoryLoaded As %Boolean [ InitialExpression = 0, Private ];

/// Lazy-loaded lab results (private storage)
Property LabResults As %ListOfObjects [ Private ];

/// Flag indicating if lab results have been loaded
Property LabResultsLoaded As %Boolean [ InitialExpression = 0, Private ];

/// Lazy-loaded imaging studies (private storage)
Property ImagingStudies As %ListOfObjects [ Private ];

/// Flag indicating if imaging studies have been loaded
Property ImagingStudiesLoaded As %Boolean [ InitialExpression = 0, Private ];

/// Lazy-loaded medication history (private storage)
Property MedicationHistory As %ListOfObjects [ Private ];

/// Flag indicating if medication history has been loaded
Property MedicationHistoryLoaded As %Boolean [ InitialExpression = 0, Private ];

/// Get medical history, loading if necessary (transparent lazy loading)
/// 
/// @return List of medical history records
Method GetMedicalHistory() As %ListOfObjects
{
    // Lazy load on first access
    If '..MedicalHistoryLoaded {
        Set ..MedicalHistory = ##class(MedicalHistoryLazyLoader).LoadMedicalHistory(..PatientMRN)
        Set ..MedicalHistoryLoaded = 1
    }
    
    Quit ..MedicalHistory
}

/// Get lab results, loading if necessary (transparent lazy loading)
/// 
/// @return List of lab result records
Method GetLabResults() As %ListOfObjects
{
    // Lazy load on first access
    If '..LabResultsLoaded {
        Set ..LabResults = ##class(MedicalHistoryLazyLoader).LoadLabResults(..PatientMRN)
        Set ..LabResultsLoaded = 1
    }
    
    Quit ..LabResults
}

/// Get imaging studies, loading if necessary (transparent lazy loading)
/// 
/// @return List of imaging study records
Method GetImagingStudies() As %ListOfObjects
{
    // Lazy load on first access
    If '..ImagingStudiesLoaded {
        Set ..ImagingStudies = ##class(MedicalHistoryLazyLoader).LoadImagingStudies(..PatientMRN)
        Set ..ImagingStudiesLoaded = 1
    }
    
    Quit ..ImagingStudies
}

/// Get medication history, loading if necessary (transparent lazy loading)
/// 
/// @return List of medication records
Method GetMedicationHistory() As %ListOfObjects
{
    // Lazy load on first access
    If '..MedicationHistoryLoaded {
        Set ..MedicationHistory = ##class(MedicalHistoryLazyLoader).LoadMedicationHistory(..PatientMRN)
        Set ..MedicationHistoryLoaded = 1
    }
    
    Quit ..MedicationHistory
}

/// Check if medical history has been loaded
/// 
/// @return %Boolean - 1 if loaded, 0 if not
Method IsMedicalHistoryLoaded() As %Boolean
{
    Quit ..MedicalHistoryLoaded
}

/// Check if lab results have been loaded
/// 
/// @return %Boolean - 1 if loaded, 0 if not
Method IsLabResultsLoaded() As %Boolean
{
    Quit ..LabResultsLoaded
}

/// Check if imaging studies have been loaded
/// 
/// @return %Boolean - 1 if loaded, 0 if not
Method IsImagingStudiesLoaded() As %Boolean
{
    Quit ..ImagingStudiesLoaded
}

/// Check if medication history has been loaded
/// 
/// @return %Boolean - 1 if loaded, 0 if not
Method IsMedicationHistoryLoaded() As %Boolean
{
    Quit ..MedicationHistoryLoaded
}

/// Get patient summary (basic info without expensive loads)
/// 
/// @return Dynamic object with patient summary
Method GetSummary() As %DynamicObject
{
    Set tSummary = {}
    Set tSummary.PatientMRN = ..PatientMRN
    Set tSummary.FirstName = ..FirstName
    Set tSummary.LastName = ..LastName
    Set tSummary.DateOfBirth = ..DateOfBirth
    Set tSummary.MedicalHistoryLoaded = ..MedicalHistoryLoaded
    Set tSummary.LabResultsLoaded = ..LabResultsLoaded
    Set tSummary.ImagingStudiesLoaded = ..ImagingStudiesLoaded
    Set tSummary.MedicationHistoryLoaded = ..MedicationHistoryLoaded
    
    Quit tSummary
}

/// Demonstrate performance benefit of lazy loading
/// 
/// @return Dynamic object with performance metrics
ClassMethod DemonstratePerformanceBenefit() As %DynamicObject
{
    Set tMetrics = {}
    
    // Scenario 1: Only need patient demographics (common case)
    Set tStart = $HOROLOG
    Set tPatient = ##class(VirtualProxyPatient).%New()
    Set tPatient.PatientMRN = "MRN123"
    Set tPatient.FirstName = "John"
    Set tPatient.LastName = "Doe"
    // No medical history accessed
    Set tEnd = $HOROLOG
    Set tMetrics.demographicsOnlyMs = 10  // Simulated
    Set tMetrics.lazyLoadingBenefit = "No expensive loads triggered"
    
    // Scenario 2: Need demographics + lab results only
    Set tStart = $HOROLOG
    Set tPatient2 = ##class(VirtualProxyPatient).%New()
    Set tPatient2.PatientMRN = "MRN456"
    Set tLabs = tPatient2.GetLabResults()  // Only labs loaded
    Set tEnd = $HOROLOG
    Set tMetrics.demographicsAndLabsMs = 60  // Simulated
    Set tMetrics.partialLoadBenefit = "Only loaded what was needed (labs), not full history"
    
    // Scenario 3: Eager loading (load everything upfront)
    Set tComparison = ##class(MedicalHistoryLazyLoader).GetPerformanceComparison()
    Set tMetrics.eagerLoadTimeMs = tComparison.eagerLoadTimeMs
    Set tMetrics.lazyLoadTimeMs = tComparison.lazyLoadTimeMs
    Set tMetrics.performanceImprovement = tComparison.percentFaster_"% faster"
    
    Quit tMetrics
}

}
