/// Healthcare Clinical Services - Patient Admission Service
/// 
/// Intent:
/// Demonstrate the Service Layer pattern in a healthcare context by coordinating
/// patient admission, discharge, and transfer workflows. Shows how Service Layer
/// defines application boundary and manages transaction boundaries while coordinating
/// Domain Model (Patient) and Table Module (PatientTableModule) operations.
/// 
/// Structure:
/// Extends base ServiceLayer to provide coarse-grained clinical operations.
/// Each service operation represents a complete clinical workflow with transaction
/// boundaries. Coordinates multiple domain objects and table modules.
/// 
/// Example:
/// <example>
/// Set service = ##class(PatientAdmissionService).%New()
/// Set patientData = {"name": "John Doe", "dateOfBirth": "1980-01-15", "admissionType": "Emergency"}
/// Set status = service.AdmitPatient(patientData)
/// If $$$ISOK(status) {
///     Write "Patient admitted successfully"
/// }
/// </example>
Class Patterns.Examples.Clinical.PatientAdmissionService Extends Patterns.PoEAA.DomainLogic.ServiceLayer
{

/// Service name for logging and identification
Parameter SERVICENAME = "PatientAdmissionService";

/// Admit patient with full transaction management
/// 
/// Coordinates:
/// - Patient domain model creation/update
/// - Bed assignment via Table Module
/// - Admission record creation
/// - Clinical validation
/// 
/// @param pPatientData Dynamic object with patient information
/// @return %Status indicating success or failure
Method AdmitPatient(pPatientData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    Set tPatientId = ""
    
    Try {
        // Begin transaction
        TSTART
        
        // 1. Validate admission request
        Set tSC = ..ValidateAdmissionRequest(pPatientData)
        If $$$ISERR(tSC) {
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 2. Create or update patient using Domain Model
        Set tPatient = ##class(Patterns.Examples.Healthcare.Patient).%New()
        Set tPatient.Name = pPatientData.%Get("name")
        Set tPatient.DateOfBirth = pPatientData.%Get("dateOfBirth")
        
        Set tSC = tPatient.%Save()
        If $$$ISERR(tSC) {
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        Set tPatientId = tPatient.%Id()
        
        // 3. Assign bed via Table Module
        Set tBedAssignment = ##class(Patterns.Examples.Healthcare.PatientTableModule).AssignBed(tPatientId)
        If tBedAssignment = "" {
            Set tSC = $$$ERROR($$$GeneralError, "No beds available for assignment")
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 4. Create admission record
        Set tAdmissionType = pPatientData.%Get("admissionType")
        Set tSC = ..CreateAdmissionRecord(tPatientId, tAdmissionType)
        If $$$ISERR(tSC) {
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 5. Update service result
        Do ..LastOperationResult.SetSuccess("Patient admitted successfully", tPatientId)
        
        // Commit transaction
        TCOMMIT
        
        // 6. Log operation for audit trail
        Do ..LogOperation("AdmitPatient", tSC, "PatientId: " _ tPatientId)
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
        Do ..LastOperationResult.SetFailure("Patient admission failed", $SYSTEM.Status.GetErrorText(tSC))
    }
    
    Quit tSC
}

/// Discharge patient with full transaction management
/// 
/// Coordinates:
/// - Patient record updates
/// - Bed release via Table Module
/// - Discharge record creation
/// 
/// @param pPatientId Patient ID to discharge
/// @param pDischargeData Dynamic object with discharge information
/// @return %Status
Method DischargePatient(pPatientId As %String, pDischargeData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Begin transaction
        TSTART
        
        // 1. Validate patient exists
        Set tPatient = ##class(Patterns.Examples.Healthcare.Patient).%OpenId(pPatientId)
        If '$IsObject(tPatient) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient not found: " _ pPatientId)
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 2. Release bed via Table Module
        Set tSC = ##class(Patterns.Examples.Healthcare.PatientTableModule).ReleaseBed(pPatientId)
        If $$$ISERR(tSC) {
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 3. Create discharge record
        Set tDischargeReason = pDischargeData.%Get("reason")
        Set tSC = ..CreateDischargeRecord(pPatientId, tDischargeReason)
        If $$$ISERR(tSC) {
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 4. Update service result
        Do ..LastOperationResult.SetSuccess("Patient discharged successfully", pPatientId)
        
        // Commit transaction
        TCOMMIT
        
        // 5. Log operation
        Do ..LogOperation("DischargePatient", tSC, "PatientId: " _ pPatientId)
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
        Do ..LastOperationResult.SetFailure("Patient discharge failed", $SYSTEM.Status.GetErrorText(tSC))
    }
    
    Quit tSC
}

/// Transfer patient between departments or facilities
/// 
/// Coordinates:
/// - Source department bed release
/// - Destination department bed assignment
/// - Transfer record creation
/// 
/// @param pPatientId Patient ID to transfer
/// @param pTransferData Dynamic object with transfer information
/// @return %Status
Method TransferPatient(pPatientId As %String, pTransferData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Begin transaction
        TSTART
        
        // 1. Validate patient exists
        Set tPatient = ##class(Patterns.Examples.Healthcare.Patient).%OpenId(pPatientId)
        If '$IsObject(tPatient) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient not found: " _ pPatientId)
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 2. Release bed in source department
        Set tSC = ##class(Patterns.Examples.Healthcare.PatientTableModule).ReleaseBed(pPatientId)
        If $$$ISERR(tSC) {
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 3. Assign bed in destination department
        Set tNewBed = ##class(Patterns.Examples.Healthcare.PatientTableModule).AssignBed(pPatientId)
        If tNewBed = "" {
            Set tSC = $$$ERROR($$$GeneralError, "No beds available in destination department")
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 4. Create transfer record
        Set tDestination = pTransferData.%Get("destination")
        Set tSC = ..CreateTransferRecord(pPatientId, tDestination)
        If $$$ISERR(tSC) {
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 5. Update service result
        Do ..LastOperationResult.SetSuccess("Patient transferred successfully", pPatientId)
        
        // Commit transaction
        TCOMMIT
        
        // 6. Log operation
        Do ..LogOperation("TransferPatient", tSC, "PatientId: " _ pPatientId)
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
        Do ..LastOperationResult.SetFailure("Patient transfer failed", $SYSTEM.Status.GetErrorText(tSC))
    }
    
    Quit tSC
}

/// Update patient records
/// 
/// @param pPatientId Patient ID
/// @param pUpdateData Dynamic object with update information
/// @return %Status
Method UpdatePatientRecords(pPatientId As %String, pUpdateData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Begin transaction
        TSTART
        
        // 1. Load patient
        Set tPatient = ##class(Patterns.Examples.Healthcare.Patient).%OpenId(pPatientId)
        If '$IsObject(tPatient) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient not found: " _ pPatientId)
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 2. Update patient properties
        If pUpdateData.%Get("name") '= "" {
            Set tPatient.Name = pUpdateData.%Get("name")
        }
        
        // 3. Save updates
        Set tSC = tPatient.%Save()
        If $$$ISERR(tSC) {
            If $TLEVEL > 0 TROLLBACK
            Quit
        }
        
        // 4. Update service result
        Do ..LastOperationResult.SetSuccess("Patient records updated successfully", pPatientId)
        
        // Commit transaction
        TCOMMIT
        
        // 5. Log operation
        Do ..LogOperation("UpdatePatientRecords", tSC, "PatientId: " _ pPatientId)
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
        Do ..LastOperationResult.SetFailure("Patient update failed", $SYSTEM.Status.GetErrorText(tSC))
    }
    
    Quit tSC
}

/// Validate admission request
/// 
/// @param pPatientData Patient data to validate
/// @return %Status
Method ValidateAdmissionRequest(pPatientData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check required fields
        If '$IsObject(pPatientData) {
            Set tSC = $$$ERROR($$$GeneralError, "Patient data is required")
            Quit
        }
        
        If pPatientData.%Get("name") = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Patient name is required")
            Quit
        }
        
        If pPatientData.%Get("dateOfBirth") = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Patient date of birth is required")
            Quit
        }
        
        If pPatientData.%Get("admissionType") = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Admission type is required")
            Quit
        }
        
        // Validate admission type
        Set tAdmissionType = pPatientData.%Get("admissionType")
        If ",Emergency,Elective,Urgent," '[ (","_tAdmissionType_",") {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid admission type: " _ tAdmissionType)
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Create admission record in global
/// 
/// @param pPatientId Patient ID
/// @param pAdmissionType Admission type
/// @return %Status
Method CreateAdmissionRecord(pPatientId As %String, pAdmissionType As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tAdmissionId = $INCREMENT(^Patterns.Clinical.Admission)
        Set ^Patterns.Clinical.Admission(tAdmissionId, "PatientId") = pPatientId
        Set ^Patterns.Clinical.Admission(tAdmissionId, "Type") = pAdmissionType
        Set ^Patterns.Clinical.Admission(tAdmissionId, "Timestamp") = $ZDATETIME($HOROLOG, 3)
        Set ^Patterns.Clinical.Admission(tAdmissionId, "Status") = "Active"
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Create discharge record in global
/// 
/// @param pPatientId Patient ID
/// @param pReason Discharge reason
/// @return %Status
Method CreateDischargeRecord(pPatientId As %String, pReason As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tDischargeId = $INCREMENT(^Patterns.Clinical.Discharge)
        Set ^Patterns.Clinical.Discharge(tDischargeId, "PatientId") = pPatientId
        Set ^Patterns.Clinical.Discharge(tDischargeId, "Reason") = pReason
        Set ^Patterns.Clinical.Discharge(tDischargeId, "Timestamp") = $ZDATETIME($HOROLOG, 3)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Create transfer record in global
/// 
/// @param pPatientId Patient ID
/// @param pDestination Transfer destination
/// @return %Status
Method CreateTransferRecord(pPatientId As %String, pDestination As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tTransferId = $INCREMENT(^Patterns.Clinical.Transfer)
        Set ^Patterns.Clinical.Transfer(tTransferId, "PatientId") = pPatientId
        Set ^Patterns.Clinical.Transfer(tTransferId, "Destination") = pDestination
        Set ^Patterns.Clinical.Transfer(tTransferId, "Timestamp") = $ZDATETIME($HOROLOG, 3)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
