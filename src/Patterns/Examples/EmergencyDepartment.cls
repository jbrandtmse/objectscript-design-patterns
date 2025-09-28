/// Gang of Four Mediator Pattern - Emergency Department Colleague
/// 
/// Purpose:
/// Represents the Emergency Department in the hospital mediator system.
/// Handles emergency patients, trauma cases, and coordinates with other
/// departments for urgent care needs.
/// 
/// Features:
/// - Patient triage and admission
/// - Emergency response coordination
/// - Critical care management
/// - Inter-department communication
Class Patterns.Examples.EmergencyDepartment Extends Patterns.GoF.Behavioral.Colleague
{

/// Department name
Property DepartmentName As %String [ InitialExpression = "Emergency Department" ];

/// Current capacity
Property CurrentCapacity As %Integer [ InitialExpression = 50 ];

/// Occupied beds
Property OccupiedBeds As %Integer [ InitialExpression = 0 ];

/// Critical patients count
Property CriticalPatients As %Integer [ InitialExpression = 0 ];

/// Triage queue
Property TriageQueue As %ListOfDataTypes;

/// Active trauma cases
Property TraumaCases As %ArrayOfDataTypes;

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Set ..ColleagueId = "EMERGENCY"
    Set ..TriageQueue = ##class(%ListOfDataTypes).%New()
    Set ..TraumaCases = ##class(%ArrayOfDataTypes).%New()
    
    Quit tSC
}

/// Receive message from mediator
Method Receive(pEvent As %String, pData As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Log receipt
        Set ^EmergencyDept.Messages($INCREMENT(^EmergencyDept.Messages)) = 
            $LISTBUILD($ZDATETIME($HOROLOG, 3), pEvent, 
                       $SELECT($IsObject(pData):pData.%ToJSON(), 1:""))
        
        // Handle different message types
        If pEvent = "TRANSFER_REQUEST" {
            Set tSC = ..HandleTransferRequest(pData)
        } ElseIf pEvent = "LAB_RESULT" {
            Set tSC = ..ProcessLabResult(pData)
        } ElseIf pEvent = "RADIOLOGY_RESULT" {
            Set tSC = ..ProcessRadiologyResult(pData)
        } ElseIf pEvent = "MEDICATION_READY" {
            Set tSC = ..HandleMedicationReady(pData)
        } ElseIf pEvent = "EMERGENCY" {
            Set tSC = ..HandleEmergencyAlert(pData)
        } ElseIf pEvent = "CONSULTATION_RESPONSE" {
            Set tSC = ..ProcessConsultationResponse(pData)
        } ElseIf pEvent = "DEPARTMENT_UPDATE" {
            Set tSC = ..HandleDepartmentUpdate(pData)
        } Else {
            // Generic message handling
            Do ..LogMessage(pEvent, pData)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Admit emergency patient
Method AdmitPatient(pPatientId As %String, pTriageLevel As %Integer, pChiefComplaint As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check capacity
        If ..OccupiedBeds >= ..CurrentCapacity {
            Set tSC = $$$ERROR($$$GeneralError, "Emergency Department at capacity")
            Quit
        }
        
        // Create patient record
        Set tPatient = ##class(%DynamicObject).%New()
        Set tPatient.patientId = pPatientId
        Set tPatient.triageLevel = pTriageLevel
        Set tPatient.chiefComplaint = pChiefComplaint
        Set tPatient.admitTime = $ZDATETIME($HOROLOG, 3)
        Set tPatient.status = "ADMITTED"
        
        // Update occupancy
        Set ..OccupiedBeds = ..OccupiedBeds + 1
        If pTriageLevel <= 2 {
            Set ..CriticalPatients = ..CriticalPatients + 1
        }
        
        // Store patient info
        Set ^EmergencyDept.Patients(pPatientId) = tPatient.%ToJSON()
        
        // Add to triage queue if not critical
        If pTriageLevel > 2 {
            Do ..TriageQueue.Insert(pPatientId)
        }
        
        // Notify mediator of admission
        If $IsObject(..Mediator) {
            Set tNotification = ##class(%DynamicObject).%New()
            Set tNotification.patientId = pPatientId
            Set tNotification.department = "EMERGENCY"
            Set tNotification.action = "ADMITTED"
            Set tNotification.triageLevel = pTriageLevel
            
            Set tSC = ..Send("PATIENT_ADMITTED", tNotification)
        }
        
        // Request initial tests if critical
        If pTriageLevel <= 2 {
            Do ..RequestInitialTests(pPatientId)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle incoming transfer request
Method HandleTransferRequest(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        Set tAccepted = 0
        Set tReason = ""
        
        // Check if we can accept the transfer
        If ..OccupiedBeds < ..CurrentCapacity {
            // Check priority
            If pData.priority = "CRITICAL" {
                // Always accept critical transfers if any space
                Set tAccepted = 1
            } ElseIf pData.priority = "EMERGENCY" {
                // Accept if we have >10% capacity
                If (..CurrentCapacity - ..OccupiedBeds) > (..CurrentCapacity * 0.1) {
                    Set tAccepted = 1
                } Else {
                    Set tReason = "Limited capacity for non-critical cases"
                }
            } Else {
                // Routine transfers
                If (..CurrentCapacity - ..OccupiedBeds) > (..CurrentCapacity * 0.2) {
                    Set tAccepted = 1
                } Else {
                    Set tReason = "Department near capacity"
                }
            }
        } Else {
            Set tReason = "Department at full capacity"
        }
        
        // Send response through mediator
        If $IsObject(..Mediator) {
            Set tResponse = ##class(%DynamicObject).%New()
            Set tResponse.transferId = pData.transferId
            Set tResponse.accepted = tAccepted
            Set tResponse.reason = tReason
            Set tResponse.respondingDept = "EMERGENCY"
            
            // Call mediator's transfer response method
            If ..Mediator.%IsA("Patterns.Examples.HospitalMediator") {
                Set tSC = ..Mediator.ProcessTransferResponse(pData.transferId, 
                                                            tAccepted, tReason)
            }
        }
        
        // Prepare for incoming patient if accepted
        If tAccepted {
            Do ..PrepareForTransfer(pData.patientId, pData.priority)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process lab results
Method ProcessLabResult(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Update patient record with lab results
        If $Data(^EmergencyDept.Patients(pData.patientId)) {
            Set tPatientJSON = ^EmergencyDept.Patients(pData.patientId)
            Set tPatient = ##class(%DynamicObject).%FromJSON(tPatientJSON)
            
            // Add lab results to patient record
            If '$IsObject(tPatient.labResults) {
                Set tPatient.labResults = ##class(%DynamicArray).%New()
            }
            Do tPatient.labResults.%Push(pData)
            
            // Check for critical values
            If pData.%IsDefined("critical") && pData.critical {
                Do ..HandleCriticalLabValue(pData.patientId, pData)
            }
            
            // Update patient record
            Set ^EmergencyDept.Patients(pData.patientId) = tPatient.%ToJSON()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process radiology results
Method ProcessRadiologyResult(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Similar to lab results processing
        If $Data(^EmergencyDept.Patients(pData.patientId)) {
            Set tPatientJSON = ^EmergencyDept.Patients(pData.patientId)
            Set tPatient = ##class(%DynamicObject).%FromJSON(tPatientJSON)
            
            // Add radiology results
            If '$IsObject(tPatient.radiologyResults) {
                Set tPatient.radiologyResults = ##class(%DynamicArray).%New()
            }
            Do tPatient.radiologyResults.%Push(pData)
            
            // Check for urgent findings
            If pData.%IsDefined("urgent") && pData.urgent {
                Do ..HandleUrgentRadiologyFinding(pData.patientId, pData)
            }
            
            Set ^EmergencyDept.Patients(pData.patientId) = tPatient.%ToJSON()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle medication ready notification
Method HandleMedicationReady(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Log medication ready
        Set ^EmergencyDept.MedicationsReady(pData.orderId) = pData.%ToJSON()
        
        // Notify nursing staff (simulated)
        Do ..NotifyNursing(pData.patientId, "MEDICATION_READY", pData.medication)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle emergency alert
Method HandleEmergencyAlert(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Log emergency
        Set ^EmergencyDept.Emergencies($INCREMENT(^EmergencyDept.Emergencies)) = 
            pData.%ToJSON()
        
        // Take action based on emergency type
        If pData.type = "CODE_BLUE" {
            Do ..PrepareCodeBlueResponse()
        } ElseIf pData.type = "MASS_CASUALTY" {
            Do ..ActivateMassCasualtyProtocol()
        } ElseIf pData.type = "CODE_RED" {
            Do ..InitiateEvacuationProcedure()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Request initial tests for patient
Method RequestInitialTests(pPatientId As %String) [ Private ]
{
    Try {
        If $IsObject(..Mediator) {
            // Request standard emergency panel
            If ..Mediator.%IsA("Patterns.Examples.HospitalMediator") {
                // CBC
                Do ..Mediator.RequestLabTest("EMERGENCY", pPatientId, 
                                            "CBC", "URGENT")
                // Basic metabolic panel
                Do ..Mediator.RequestLabTest("EMERGENCY", pPatientId, 
                                            "BMP", "URGENT")
                // Chest X-ray for trauma
                Do ..Mediator.RequestRadiologyConsult("EMERGENCY", pPatientId, 
                                                     "CHEST_XRAY", 1)
            }
        }
    } Catch ex {
        // Log but don't fail
    }
}

/// Prepare for incoming transfer
Method PrepareForTransfer(pPatientId As %String, pPriority As %String) [ Private ]
{
    Try {
        // Reserve bed
        Set ^EmergencyDept.ReservedBeds(pPatientId) = $LISTBUILD(
            $ZDATETIME($HOROLOG, 3), pPriority, "INCOMING")
        
        // Alert staff
        Do ..NotifyNursing(pPatientId, "INCOMING_TRANSFER", pPriority)
        
    } Catch ex {
        // Log error
    }
}

/// Handle critical lab value
Method HandleCriticalLabValue(pPatientId As %String, pLabData As %DynamicObject) [ Private ]
{
    Try {
        // Alert medical team
        Set ^EmergencyDept.CriticalAlerts($INCREMENT(^EmergencyDept.CriticalAlerts)) = 
            $LISTBUILD($ZDATETIME($HOROLOG, 3), pPatientId, "CRITICAL_LAB", 
                      pLabData.%ToJSON())
        
        // Escalate patient priority if needed
        Do ..EscalatePatientPriority(pPatientId)
        
    } Catch ex {
        // Log error
    }
}

/// Handle urgent radiology finding
Method HandleUrgentRadiologyFinding(pPatientId As %String, pRadData As %DynamicObject) [ Private ]
{
    Try {
        // Similar to critical lab handling
        Set ^EmergencyDept.UrgentFindings($INCREMENT(^EmergencyDept.UrgentFindings)) = 
            $LISTBUILD($ZDATETIME($HOROLOG, 3), pPatientId, "URGENT_RAD", 
                      pRadData.%ToJSON())
        
        // Request consultation if needed
        If pRadData.%IsDefined("requiresConsult") && pRadData.requiresConsult {
            Do ..RequestSpecialistConsult(pPatientId, pRadData.specialty)
        }
        
    } Catch ex {
        // Log error
    }
}

/// Request transfer to another department
Method RequestTransfer(pPatientId As %String, pTargetDept As %String, pPriority As %String = "ROUTINE") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $IsObject(..Mediator) && ..Mediator.%IsA("Patterns.Examples.HospitalMediator") {
            Set tSC = ..Mediator.InitiatePatientTransfer("EMERGENCY", pTargetDept, 
                                                        pPatientId, pPriority)
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Discharge patient
Method DischargePatient(pPatientId As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $Data(^EmergencyDept.Patients(pPatientId)) {
            // Update patient status
            Set tPatientJSON = ^EmergencyDept.Patients(pPatientId)
            Set tPatient = ##class(%DynamicObject).%FromJSON(tPatientJSON)
            Set tPatient.status = "DISCHARGED"
            Set tPatient.dischargeTime = $ZDATETIME($HOROLOG, 3)
            
            // Update bed count
            Set ..OccupiedBeds = ..OccupiedBeds - 1
            If tPatient.triageLevel <= 2 {
                Set ..CriticalPatients = ..CriticalPatients - 1
            }
            
            // Archive patient record
            Set ^EmergencyDept.DischargedPatients(pPatientId) = tPatient.%ToJSON()
            Kill ^EmergencyDept.Patients(pPatientId)
            
            // Notify mediator
            If $IsObject(..Mediator) {
                Set tNotification = ##class(%DynamicObject).%New()
                Set tNotification.patientId = pPatientId
                Set tNotification.department = "EMERGENCY"
                Set tNotification.action = "DISCHARGED"
                
                Set tSC = ..Send("PATIENT_DISCHARGED", tNotification)
            }
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// Helper methods

/// Process consultation response
Method ProcessConsultationResponse(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    // Implementation for consultation responses
    Quit tSC
}

/// Handle department update
Method HandleDepartmentUpdate(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    // Track other department status changes
    Quit tSC
}

/// Notify nursing staff
Method NotifyNursing(pPatientId As %String, pType As %String, pData As %String) [ Private ]
{
    // Simulated nursing notification
    Set ^EmergencyDept.NursingAlerts($INCREMENT(^EmergencyDept.NursingAlerts)) = 
        $LISTBUILD($ZDATETIME($HOROLOG, 3), pPatientId, pType, pData)
}

/// Escalate patient priority
Method EscalatePatientPriority(pPatientId As %String) [ Private ]
{
    // Move patient up in triage queue
}

/// Request specialist consultation
Method RequestSpecialistConsult(pPatientId As %String, pSpecialty As %String) [ Private ]
{
    // Request specialist through mediator
}

/// Prepare code blue response
Method PrepareCodeBlueResponse() [ Private ]
{
    Set ^EmergencyDept.CodeBlue($INCREMENT(^EmergencyDept.CodeBlue)) = 
        $ZDATETIME($HOROLOG, 3)_" - Response activated"
}

/// Activate mass casualty protocol
Method ActivateMassCasualtyProtocol() [ Private ]
{
    // Clear non-critical patients, prepare triage area
    Set ..TriageQueue = ##class(%ListOfDataTypes).%New()
    Set ^EmergencyDept.MassCasualty = $ZDATETIME($HOROLOG, 3)_" - Protocol activated"
}

/// Initiate evacuation procedure
Method InitiateEvacuationProcedure() [ Private ]
{
    Set ^EmergencyDept.Evacuation = $ZDATETIME($HOROLOG, 3)_" - Evacuation initiated"
}

/// Log message
Method LogMessage(pEvent As %String, pData As %DynamicObject) [ Private ]
{
    Set ^EmergencyDept.GeneralMessages($INCREMENT(^EmergencyDept.GeneralMessages)) = 
        $LISTBUILD($ZDATETIME($HOROLOG, 3), pEvent, 
                   $SELECT($IsObject(pData):pData.%ToJSON(), 1:""))
}

/// Get department status
Method GetStatus() As %String
{
    Set tStatus = ##class(%DynamicObject).%New()
    Set tStatus.department = "EMERGENCY"
    Set tStatus.occupancy = ..OccupiedBeds_"/"_..CurrentCapacity
    Set tStatus.criticalPatients = ..CriticalPatients
    Set tStatus.queueLength = ..TriageQueue.Count()
    Set tStatus.status = $SELECT(..OccupiedBeds >= ..CurrentCapacity:"FULL",
                                 ..OccupiedBeds >= (..CurrentCapacity * 0.9):"NEAR_CAPACITY",
                                 1:"AVAILABLE")
    
    Quit tStatus.%ToJSON()
}

}
