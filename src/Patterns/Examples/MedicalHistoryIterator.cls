/// Healthcare Example - Medical History Iterator
/// Iterates through patient medical history with pagination support
Class Patterns.Examples.MedicalHistoryIterator Extends Patterns.GoF.Behavioral.Iterator
{

/// Patient MRN
Property PatientMRN As %String;

/// Page size for pagination
Property PageSize As %Integer [ InitialExpression = 10 ];

/// Current page number
Property CurrentPage As %Integer [ InitialExpression = 1 ];

/// Total records count
Property TotalRecords As %Integer [ Private ];

/// Current page data
Property CurrentPageData As %ListOfObjects [ Private ];

/// Current position in page
Property CurrentPosition As %Integer [ InitialExpression = 0, Private ];

/// Constructor
Method %OnNew(pPatientMRN As %String, pPageSize As %Integer = 10) As %Status
{
        Set tSC = $$$OK
        Try {
            Set ..PatientMRN = pPatientMRN
            Set ..PageSize = pPageSize
            
            // Count total records for this patient
            Set ..TotalRecords = ..GetHistoryCount(pPatientMRN)
            
            // Load first page
            Set tSC = ..LoadPage(1)
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
}

/// Load a specific page of history
Method LoadPage(pPageNumber As %Integer) As %Status [ Private ]
{
        Set tSC = $$$OK
        Try {
            Set ..CurrentPage = pPageNumber
            Set ..CurrentPosition = 0
            Set ..CurrentPageData = ##class(%ListOfObjects).%New()
            
            // Calculate offset
            Set tOffset = (pPageNumber - 1) * ..PageSize
            
            // Simulate loading medical history records
            // In real implementation, this would query a history table
            Set tStartRecord = tOffset + 1
            Set tEndRecord = tOffset + ..PageSize
            If tEndRecord > ..TotalRecords Set tEndRecord = ..TotalRecords
            
            For i=tStartRecord:1:tEndRecord {
                Set tHistory = ##class(%DynamicObject).%New()
                Set tHistory.recordId = "HIST-"_..PatientMRN_"-"_i
                Set tHistory.patientMRN = ..PatientMRN
                Set tHistory.date = $ZDATETIME($HOROLOG - (..TotalRecords - i), 3)
                Set tHistory.type = $SELECT(i#3=0:"Lab", i#3=1:"Visit", 1:"Medication")
                Set tHistory.description = "Medical history entry "_i
                Set tHistory.provider = "Dr. Provider "_((i#5) + 1)
                Set tHistory.department = $SELECT(i#4=0:"Emergency", i#4=1:"Cardiology", i#4=2:"Primary Care", 1:"Specialty")
                Set tHistory.status = "Completed"
                
                // Add lab results for lab types
                If tHistory.type = "Lab" {
                    Set tHistory.results = ##class(%DynamicObject).%New()
                    Set tHistory.results.WBC = 5.5 + ($RANDOM(40) / 10)
                    Set tHistory.results.RBC = 4.5 + ($RANDOM(10) / 10)
                    Set tHistory.results.Hemoglobin = 12 + ($RANDOM(40) / 10)
                }
                
                // Add medication details for medication types
                If tHistory.type = "Medication" {
                    Set tHistory.medication = ##class(%DynamicObject).%New()
                    Set tHistory.medication.name = "Medication "_((i#10) + 1)
                    Set tHistory.medication.dosage = (i#4+1)_"00mg"
                    Set tHistory.medication.frequency = $SELECT(i#3=0:"Daily", i#3=1:"Twice daily", 1:"As needed")
                }
                
                Do ..CurrentPageData.Insert(tHistory)
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
}

/// Get total history count for patient
ClassMethod GetHistoryCount(pPatientMRN As %String) As %Integer [ Private ]
{
        // Simulate history count - in real implementation would query database
        // For demo, return a random count between 20-100
        Quit 20 + $RANDOM(80)
}

/// Check if more history records exist
Method HasNext() As %Boolean
{
        // Check current page
        If ..CurrentPosition < ..CurrentPageData.Count() {
            Quit 1
        }
        
        // Check if there are more pages
        Set tTotalPages = (..TotalRecords + ..PageSize - 1) \ ..PageSize
        Quit (..CurrentPage < tTotalPages)
}

/// Get next history record
Method Next() As %RegisteredObject
{
        Set tResult = $$$NULLOREF
        Try {
            // Check if we need to load next page
            If ..CurrentPosition >= ..CurrentPageData.Count() {
                If ..HasNext() {
                    Do ..LoadPage(..CurrentPage + 1)
                } Else {
                    Quit
                }
            }
            
            // Get current record
            Set ..CurrentPosition = ..CurrentPosition + 1
            Set tResult = ..CurrentPageData.GetAt(..CurrentPosition)
        }
        Catch ex {
            Set tResult = $$$NULLOREF
        }
        Quit tResult
}

/// Get current record without advancing
Method Current() As %RegisteredObject
{
        If ..CurrentPosition = 0 Quit $$$NULLOREF
        If ..CurrentPosition > ..CurrentPageData.Count() Quit $$$NULLOREF
        Quit ..CurrentPageData.GetAt(..CurrentPosition)
}

/// Reset to beginning
Method Reset() As %Status
{
        Set tSC = ..LoadPage(1)
        Set ..CurrentPosition = 0
        Quit tSC
}

/// Get total number of pages
Method GetTotalPages() As %Integer
{
        Quit (..TotalRecords + ..PageSize - 1) \ ..PageSize
}

/// Jump to specific page
Method GoToPage(pPageNumber As %Integer) As %Status
{
        Set tTotalPages = ..GetTotalPages()
        If (pPageNumber < 1) || (pPageNumber > tTotalPages) {
            Quit $$$ERROR($$$GeneralError, "Invalid page number: "_pPageNumber_" (total pages: "_tTotalPages_")")
        }
        Quit ..LoadPage(pPageNumber)
}

/// Create composite iterator for all patient data
ClassMethod CreateCompositeIterator(pPatientMRN As %String) As %DynamicObject
{
        Set tComposite = ##class(%DynamicObject).%New()
        
        // Basic patient info
        Set tFilter = ##class(%DynamicObject).%New()
        Set tFilter.MRN = pPatientMRN
        Set tComposite.patient = ##class(PatientIterator).%New(tFilter)
        
        // Medical history
        Set tComposite.history = ##class(MedicalHistoryIterator).%New(pPatientMRN)
        
        // Visit records (would be another iterator in full implementation)
        Set tComposite.visits = ##class(%DynamicObject).%New()
        
        // Lab results (would be another iterator in full implementation)
        Set tComposite.labs = ##class(%DynamicObject).%New()
        
        // Medications (would be another iterator in full implementation)
        Set tComposite.medications = ##class(%DynamicObject).%New()
        
        Quit tComposite
}

/// Demonstrate lazy loading
Method LazyLoadDetails(pRecordId As %String) As %DynamicObject
{
        // Simulate loading full details only when needed
        Set tDetails = ##class(%DynamicObject).%New()
        Set tDetails.recordId = pRecordId
        Set tDetails.fullText = "Complete medical record details for "_pRecordId
        Set tDetails.attachments = ##class(%DynamicArray).%New()
        Set tDetails.signatures = ##class(%DynamicArray).%New()
        Set tDetails.auditTrail = ##class(%DynamicArray).%New()
        
        // Log HIPAA access
        Do ..LogHIPAAAccess("LazyLoad", pRecordId)
        
        Quit tDetails
}

/// Log HIPAA compliant access
Method LogHIPAAAccess(pAction As %String, pRecordId As %String) As %Status [ Private ]
{
        Set ^Patterns.HIPAA.MedicalHistory($INCREMENT(^Patterns.HIPAA.MedicalHistory)) = $LISTBUILD(
            $ZDATETIME($HOROLOG, 3),
            $USERNAME,
            pAction,
            ..PatientMRN,
            pRecordId
        )
        Quit $$$OK
}

}
