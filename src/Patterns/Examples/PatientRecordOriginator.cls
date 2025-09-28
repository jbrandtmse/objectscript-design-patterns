/// Healthcare Example - Patient Record with Versioning Support
/// 
/// Purpose:
/// Demonstrates Memento pattern for patient record versioning
/// 
/// Features:
/// - Complete audit trail
/// - HIPAA-compliant versioning
/// - Rollback capability
/// - Change attribution
Class Patterns.Examples.PatientRecordOriginator Extends Patterns.GoF.Behavioral.Originator
{

/// Patient identifier (MRN)
Property PatientMRN As %String;

/// Patient name
Property PatientName As %String;

/// Current diagnosis
Property Diagnosis As %String;

/// Medications list
Property Medications As %ListOfDataTypes;

/// Allergies
Property Allergies As %ListOfDataTypes;

/// Vital signs
Property VitalSigns As %DynamicObject;

/// Lab results
Property LabResults As %DynamicObject;

/// Treatment plan
Property TreatmentPlan As %String;

/// Last modified timestamp
Property LastModified As %TimeStamp;

/// Last modified by user
Property ModifiedBy As %String;

/// Change reason/note
Property ChangeReason As %String;

/// Constructor
Method %OnNew(pMRN As %String = "") As %Status
{
    Set ..PatientMRN = pMRN
    Set ..Medications = ##class(%ListOfDataTypes).%New()
    Set ..Allergies = ##class(%ListOfDataTypes).%New()
    Set ..VitalSigns = {}
    Set ..LabResults = {}
    Set ..LastModified = $ZDATETIME($HOROLOG, 3)
    Quit $$$OK
}

/// Create memento of current patient record state
Method CreateMemento(pCheckpointName As %String = "") As Patterns.GoF.Behavioral.Memento
{
    // Serialize current state
    Set tState = ..GetStateString()
    Set tStateData = ..GetStateData()
    
    If pCheckpointName = "" {
        Set pCheckpointName = "Patient_" _ ..PatientMRN _ "_" _ $REPLACE($ZDATETIME($HOROLOG, 3), " ", "_")
    }
    
    // Create metadata
    Set tMetadata = {}
    Set tMetadata.patientMRN = ..PatientMRN
    Set tMetadata.patientName = ..PatientName
    Set tMetadata.user = ..ModifiedBy
    Set tMetadata.reason = ..ChangeReason
    
    // Create memento using the factory method
    Set tMemento = ##class(Patterns.Examples.PatientRecordMemento).CreateWithMetadata(
        tState, tStateData, pCheckpointName, tMetadata)
    
    Quit tMemento
}

/// Restore patient record from memento
Method RestoreFromMemento(pMemento As Patterns.GoF.Behavioral.Memento) As %Status
{
    Set tSC = ..ValidateMemento(pMemento)
    If $$$ISERR(tSC) Quit tSC
    
    Set tState = pMemento.GetState()
    Set tStateData = pMemento.GetStateData()
    
    Set tSC = ..SetStateString(tState)
    If $$$ISOK(tSC) {
        Set tSC = ..SetStateData(tStateData)
    }
    
    // Update modification info
    Set ..LastModified = $ZDATETIME($HOROLOG, 3)
    Set ..ModifiedBy = $USERNAME _ " (RESTORED)"
    Set ..ChangeReason = "Restored from checkpoint: " _ pMemento.CheckpointName
    
    Quit tSC
}

/// Get current state as string
Method GetStateString() As %String
{
    Set tState = ""
    Set tState = tState _ "MRN:" _ ..PatientMRN _ "|"
    Set tState = tState _ "Name:" _ ..PatientName _ "|"
    Set tState = tState _ "Diagnosis:" _ ..Diagnosis _ "|"
    Set tState = tState _ "TreatmentPlan:" _ ..TreatmentPlan _ "|"
    Set tState = tState _ "ModifiedBy:" _ ..ModifiedBy _ "|"
    Set tState = tState _ "ChangeReason:" _ ..ChangeReason
    Quit tState
}

/// Get complex state as dynamic object
Method GetStateData() As %DynamicObject
{
    Set tData = {}
    
    // Store medications
    Set tMeds = []
    For i=1:1:..Medications.Count() {
        Do tMeds.%Push(..Medications.GetAt(i))
    }
    Set tData.medications = tMeds
    
    // Store allergies
    Set tAllergies = []
    For i=1:1:..Allergies.Count() {
        Do tAllergies.%Push(..Allergies.GetAt(i))
    }
    Set tData.allergies = tAllergies
    
    // Store vital signs and lab results
    Set tData.vitalSigns = ..VitalSigns
    Set tData.labResults = ..LabResults
    Set tData.timestamp = ..LastModified
    
    Quit tData
}

/// Set state from string
Method SetStateString(pState As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        For i=1:1:$LENGTH(pState, "|") {
            Set tPiece = $PIECE(pState, "|", i)
            Set tKey = $PIECE(tPiece, ":", 1)
            Set tValue = $PIECE(tPiece, ":", 2, *)
            
            If tKey = "MRN" {
                Set ..PatientMRN = tValue
            } ElseIf tKey = "Name" {
                Set ..PatientName = tValue
            } ElseIf tKey = "Diagnosis" {
                Set ..Diagnosis = tValue
            } ElseIf tKey = "TreatmentPlan" {
                Set ..TreatmentPlan = tValue
            } ElseIf tKey = "ModifiedBy" {
                Set ..ModifiedBy = tValue
            } ElseIf tKey = "ChangeReason" {
                Set ..ChangeReason = tValue
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Set state from dynamic object
Method SetStateData(pStateData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Restore medications
        Do ..Medications.Clear()
        If pStateData.%IsDefined("medications") {
            Set tIterator = pStateData.medications.%GetIterator()
            While tIterator.%GetNext(.tIndex, .tMed) {
                Do ..Medications.Insert(tMed)
            }
        }
        
        // Restore allergies
        Do ..Allergies.Clear()
        If pStateData.%IsDefined("allergies") {
            Set tIterator = pStateData.allergies.%GetIterator()
            While tIterator.%GetNext(.tIndex, .tAllergy) {
                Do ..Allergies.Insert(tAllergy)
            }
        }
        
        // Restore vital signs and lab results
        If pStateData.%IsDefined("vitalSigns") {
            Set ..VitalSigns = pStateData.vitalSigns
        }
        If pStateData.%IsDefined("labResults") {
            Set ..LabResults = pStateData.labResults
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Add medication
Method AddMedication(pMedication As %String, pUser As %String = "") As %Status
{
    Do ..Medications.Insert(pMedication)
    Set ..LastModified = $ZDATETIME($HOROLOG, 3)
    Set ..ModifiedBy = $SELECT(pUser="":$USERNAME, 1:pUser)
    Set ..ChangeReason = "Added medication: " _ pMedication
    Quit $$$OK
}

/// Add allergy
Method AddAllergy(pAllergy As %String, pUser As %String = "") As %Status
{
    Do ..Allergies.Insert(pAllergy)
    Set ..LastModified = $ZDATETIME($HOROLOG, 3)
    Set ..ModifiedBy = $SELECT(pUser="":$USERNAME, 1:pUser)
    Set ..ChangeReason = "Added allergy: " _ pAllergy
    Quit $$$OK
}

/// Update vital signs
Method UpdateVitalSigns(pBP As %String, pHR As %Integer, pTemp As %Decimal, pUser As %String = "") As %Status
{
    Set ..VitalSigns.bloodPressure = pBP
    Set ..VitalSigns.heartRate = pHR
    Set ..VitalSigns.temperature = pTemp
    Set ..VitalSigns.timestamp = $ZDATETIME($HOROLOG, 3)
    
    Set ..LastModified = $ZDATETIME($HOROLOG, 3)
    Set ..ModifiedBy = $SELECT(pUser="":$USERNAME, 1:pUser)
    Set ..ChangeReason = "Updated vital signs"
    Quit $$$OK
}

/// Add lab result
Method AddLabResult(pTestName As %String, pResult As %String, pUser As %String = "") As %Status
{
    If '$IsObject(..LabResults) {
        Set ..LabResults = {}
    }
    Set $PROPERTY(..LabResults, pTestName) = pResult
    
    Set ..LastModified = $ZDATETIME($HOROLOG, 3)
    Set ..ModifiedBy = $SELECT(pUser="":$USERNAME, 1:pUser)
    Set ..ChangeReason = "Added lab result: " _ pTestName
    Quit $$$OK
}

/// Calculate change summary between current state and memento
Method GetChangeSummary(pMemento As Patterns.GoF.Behavioral.Memento) As %String
{
    Set tSummary = ""
    
    // Compare basic fields
    Set tOldState = pMemento.GetState()
    Set tCurrentState = ..GetStateString()
    
    If tOldState '= tCurrentState {
        Set tSummary = "Changes detected in: "
        
        // Parse and compare
        For tField = "Name", "Diagnosis", "TreatmentPlan" {
            Set tOld = $PIECE($PIECE(tOldState, tField _ ":", 2), "|", 1)
            Set tNew = $PIECE($PIECE(tCurrentState, tField _ ":", 2), "|", 1)
            If tOld '= tNew {
                Set tSummary = tSummary _ tField _ ", "
            }
        }
    }
    
    Quit tSummary
}

/// Display patient record
Method Display()
{
    Write !, "=== Patient Record ==="
    Write !, "MRN: ", ..PatientMRN
    Write !, "Name: ", ..PatientName
    Write !, "Diagnosis: ", ..Diagnosis
    Write !, "Medications: "
    For i=1:1:..Medications.Count() {
        Write $SELECT(i=1:"", 1:", "), ..Medications.GetAt(i)
    }
    Write !, "Allergies: "
    For i=1:1:..Allergies.Count() {
        Write $SELECT(i=1:"", 1:", "), ..Allergies.GetAt(i)
    }
    If $IsObject(..VitalSigns) && ..VitalSigns.%IsDefined("bloodPressure") {
        Write !, "Vital Signs: BP=", ..VitalSigns.bloodPressure, 
              " HR=", ..VitalSigns.heartRate,
              " Temp=", ..VitalSigns.temperature
    }
    Write !, "Treatment Plan: ", ..TreatmentPlan
    Write !, "Last Modified: ", ..LastModified
    Write !, "Modified By: ", ..ModifiedBy
    Write !, "Change Reason: ", ..ChangeReason
    Write !, "===================="
}

}
