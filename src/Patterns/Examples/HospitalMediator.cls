/// Gang of Four Mediator Pattern - Hospital Department Coordinator
/// 
/// Purpose:
/// Central coordinator for hospital department communication,
/// managing patient transfers, test requests, consultations,
/// and emergency broadcasts between different departments.
/// 
/// Features:
/// - Department registration and discovery
/// - Patient transfer workflows
/// - Test/consultation request routing
/// - Emergency broadcast system
/// - Audit trail for all communications
Class Patterns.Examples.HospitalMediator Extends Patterns.GoF.Behavioral.ConcreteMediator
{

/// Department registry
Property Departments As %ArrayOfObjects [ Private ];

/// Active patient transfers
Property ActiveTransfers As %ArrayOfDataTypes [ Private ];

/// Pending consultation requests
Property PendingConsultations As %ListOfObjects [ Private ];

/// SLA tracking for critical messages
Property SLATracking As %ArrayOfDataTypes [ Private ];

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    Set ..Departments = ##class(%ArrayOfObjects).%New()
    Set ..ActiveTransfers = ##class(%ArrayOfDataTypes).%New()
    Set ..PendingConsultations = ##class(%ListOfObjects).%New()
    Set ..SLATracking = ##class(%ArrayOfDataTypes).%New()
    
    // Initialize routing rules for healthcare workflows
    Do ..InitializeHealthcareRouting()
    
    Quit $$$OK
}

/// Initialize healthcare-specific routing rules
Method InitializeHealthcareRouting() [ Private ]
{
    // Emergency broadcasts go to all departments
    Do ..AddRoutingRule("ALL", "EMERGENCY")
    
    // Lab results go to requesting department
    Do ..AddRoutingRule("REQUESTER", "LAB_RESULT")
    
    // Radiology results go to emergency and requester
    Do ..AddRoutingRule("EMERGENCY", "RADIOLOGY_RESULT")
    Do ..AddRoutingRule("REQUESTER", "RADIOLOGY_RESULT")
    
    // Pharmacy alerts go to all clinical departments
    Do ..AddRoutingRule("CLINICAL", "PHARMACY_ALERT")
    
    // Patient transfers need acknowledgment
    Do ..AddRoutingRule("TARGET", "TRANSFER_REQUEST")
}

/// Register a department
Method RegisterDepartment(pDepartment As Patterns.GoF.Behavioral.Colleague, pDepartmentType As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Register with base mediator
        Set tSC = ..RegisterColleague(pDepartment)
        If $$$ISERR(tSC) Quit
        
        // Store department info
        Set tDeptInfo = ##class(%DynamicObject).%New()
        Set tDeptInfo.type = pDepartmentType
        Set tDeptInfo.registeredAt = $ZDATETIME($HOROLOG, 3)
        Set tDeptInfo.status = "ACTIVE"
        
        Do ..Departments.SetAt(tDeptInfo, pDepartment.ColleagueId)
        
        // Notify other departments of new registration
        Set tNotification = ##class(%DynamicObject).%New()
        Set tNotification.departmentId = pDepartment.ColleagueId
        Set tNotification.departmentType = pDepartmentType
        Set tNotification.action = "REGISTERED"
        
        Do ..BroadcastMessage(pDepartment, "DEPARTMENT_UPDATE", tNotification)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Initiate patient transfer
Method InitiatePatientTransfer(pFromDept As %String, pToDept As %String, pPatientId As %String, pPriority As %String = "ROUTINE") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create transfer request
        Set tTransferRequest = ##class(%DynamicObject).%New()
        Set tTransferRequest.transferId = $System.Util.CreateGUID()
        Set tTransferRequest.patientId = pPatientId
        Set tTransferRequest.fromDepartment = pFromDept
        Set tTransferRequest.toDepartment = pToDept
        Set tTransferRequest.priority = pPriority
        Set tTransferRequest.requestTime = $ZDATETIME($HOROLOG, 3)
        Set tTransferRequest.status = "PENDING"
        
        // Store active transfer
        Do ..ActiveTransfers.SetAt(tTransferRequest.%ToJSON(), tTransferRequest.transferId)
        
        // Set SLA based on priority
        Set tSLA = $CASE(pPriority,
                        "CRITICAL":60,      // 1 minute
                        "EMERGENCY":300,    // 5 minutes
                        "URGENT":900,       // 15 minutes
                        :1800)              // 30 minutes default
        
        Do ..SLATracking.SetAt($HOROLOG_"^"_tSLA, tTransferRequest.transferId)
        
        // Send transfer request to target department
        Set tSC = ..SendTargetedMessage(pFromDept, pToDept, "TRANSFER_REQUEST", tTransferRequest)
        
        // Log transfer initiation
        Set ^Hospital.Transfers(tTransferRequest.transferId) = tTransferRequest.%ToJSON()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process transfer response
Method ProcessTransferResponse(pTransferId As %String, pAccepted As %Boolean, pReason As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..ActiveTransfers.IsDefined(pTransferId) {
            Set tTransferJSON = ..ActiveTransfers.GetAt(pTransferId)
            Set tTransfer = ##class(%DynamicObject).%FromJSON(tTransferJSON)
            
            If pAccepted {
                Set tTransfer.status = "ACCEPTED"
                Set tTransfer.acceptedTime = $ZDATETIME($HOROLOG, 3)
            } Else {
                Set tTransfer.status = "REJECTED"
                Set tTransfer.rejectionReason = pReason
            }
            
            // Update transfer record
            Do ..ActiveTransfers.SetAt(tTransfer.%ToJSON(), pTransferId)
            
            // Notify originating department
            Set tNotification = ##class(%DynamicObject).%New()
            Set tNotification.transferId = pTransferId
            Set tNotification.accepted = pAccepted
            Set tNotification.reason = pReason
            
            Set tSC = ..SendTargetedMessage("HOSPITAL", tTransfer.fromDepartment, 
                                           "TRANSFER_RESPONSE", tNotification)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Request laboratory test - accepts dynamic object for flexible test requests
Method RequestLabTest(pRequestingDept As %String, pLabData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create lab request from provided data
        Set tLabRequest = ##class(%DynamicObject).%New()
        Set tLabRequest.requestId = $System.Util.CreateGUID()
        
        // Extract data from the dynamic object
        If $ISOBJECT(pLabData) {
            Set tLabRequest.patientId = pLabData.patientId
            Set tLabRequest.tests = pLabData.tests
            Set tLabRequest.priority = pLabData.priority
        } Else {
            // Handle legacy string format
            Set tLabRequest.patientId = pLabData
            Set tLabRequest.tests = ["Default Test"]
            Set tLabRequest.priority = "ROUTINE"
        }
        
        Set tLabRequest.requestingDepartment = pRequestingDept
        Set tLabRequest.requestTime = $ZDATETIME($HOROLOG, 3)
        
        // Route to laboratory
        Set tSC = ..SendTargetedMessage(pRequestingDept, "LABORATORY", "LAB_REQUEST", tLabRequest)
        
        // Track for results routing
        Set ^Hospital.LabRequests(tLabRequest.requestId) = tLabRequest.%ToJSON()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Request radiology consultation
Method RequestRadiologyConsult(pRequestingDept As %String, pPatientId As %String, pStudyType As %String, pUrgent As %Boolean = 0) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tRadRequest = ##class(%DynamicObject).%New()
        Set tRadRequest.consultId = $System.Util.CreateGUID()
        Set tRadRequest.patientId = pPatientId
        Set tRadRequest.studyType = pStudyType
        Set tRadRequest.requestingDepartment = pRequestingDept
        Set tRadRequest.urgent = pUrgent
        Set tRadRequest.requestTime = $ZDATETIME($HOROLOG, 3)
        
        // Add to pending consultations
        Do ..PendingConsultations.Insert(tRadRequest)
        
        // Route to radiology
        Set tPriority = $SELECT(pUrgent:"URGENT", 1:"ROUTINE")
        Set tSC = ..SendTargetedMessage(pRequestingDept, "RADIOLOGY", 
                                       "RADIOLOGY_CONSULT", tRadRequest)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Order medication from pharmacy
Method OrderMedication(pOrderingDept As %String, pPatientId As %String, pMedication As %String, pDosage As %String, pUrgent As %Boolean = 0) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tMedOrder = ##class(%DynamicObject).%New()
        Set tMedOrder.orderId = $System.Util.CreateGUID()
        Set tMedOrder.patientId = pPatientId
        Set tMedOrder.medication = pMedication
        Set tMedOrder.dosage = pDosage
        Set tMedOrder.orderingDepartment = pOrderingDept
        Set tMedOrder.urgent = pUrgent
        Set tMedOrder.orderTime = $ZDATETIME($HOROLOG, 3)
        
        // Route to pharmacy
        Set tSC = ..SendTargetedMessage(pOrderingDept, "PHARMACY", 
                                       "MEDICATION_ORDER", tMedOrder)
        
        // Track order
        Set ^Hospital.MedOrders(tMedOrder.orderId) = tMedOrder.%ToJSON()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Broadcast emergency alert
Method BroadcastEmergency(pSendingDept As %String, pEmergencyType As %String, pDetails As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tEmergency = ##class(%DynamicObject).%New()
        Set tEmergency.alertId = $System.Util.CreateGUID()
        Set tEmergency.type = pEmergencyType
        Set tEmergency.details = pDetails
        Set tEmergency.originDepartment = pSendingDept
        Set tEmergency.alertTime = $ZDATETIME($HOROLOG, 3)
        Set tEmergency.priority = "CRITICAL"
        
        // Log emergency
        Set ^Hospital.Emergencies($INCREMENT(^Hospital.Emergencies)) = tEmergency.%ToJSON()
        
        // Broadcast to all departments
        For i=1:1:..Colleagues.Count() {
            Set tColleague = ..Colleagues.GetAt(i)
            Set tSC = tColleague.Receive("EMERGENCY", tEmergency)
        }
        
        // Trigger emergency protocols
        Do ..TriggerEmergencyProtocols(pEmergencyType)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Trigger emergency protocols
Method TriggerEmergencyProtocols(pEmergencyType As %String) [ Private ]
{
    Try {
        // Log protocol activation
        Set ^Hospital.EmergencyProtocols($INCREMENT(^Hospital.EmergencyProtocols)) = 
            $LISTBUILD($ZDATETIME($HOROLOG, 3), pEmergencyType, "ACTIVATED")
        
        // Emergency-specific protocols
        If pEmergencyType = "CODE_BLUE" {
            // Cardiac arrest protocol
            Do ..NotifyDepartment("EMERGENCY", "PREPARE_CRASH_CART", "")
            Do ..NotifyDepartment("CARDIOLOGY", "STANDBY", "")
        } ElseIf pEmergencyType = "CODE_RED" {
            // Fire protocol
            Do ..NotifyDepartment("ALL", "EVACUATION_STANDBY", "")
        } ElseIf pEmergencyType = "MASS_CASUALTY" {
            // Mass casualty protocol
            Do ..NotifyDepartment("EMERGENCY", "TRIAGE_MODE", "")
            Do ..NotifyDepartment("SURGERY", "PREPARE_OR", "")
            Do ..NotifyDepartment("BLOOD_BANK", "PREPARE_SUPPLIES", "")
        }
    } Catch ex {
        // Log but don't fail
    }
}

/// Send targeted message to specific department
Method SendTargetedMessage(pFromDept As %String, pToDept As %String, pMessageType As %String, pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Find target department colleague
        For i=1:1:..Colleagues.Count() {
            Set tColleague = ..Colleagues.GetAt(i)
            If tColleague.ColleagueId = pToDept {
                Set pData.messageType = pMessageType
                Set pData.fromDepartment = pFromDept
                Set tSC = tColleague.Receive(pMessageType, pData)
                Quit
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Notify specific department
Method NotifyDepartment(pDeptId As %String, pAction As %String, pData As %String) [ Private ]
{
    Try {
        Set tNotification = ##class(%DynamicObject).%New()
        Set tNotification.action = pAction
        Set tNotification.data = pData
        Set tNotification.timestamp = $ZDATETIME($HOROLOG, 3)
        
        If pDeptId = "ALL" {
            // Broadcast to all
            Do ..BroadcastMessage($THIS, "NOTIFICATION", tNotification)
        } Else {
            // Target specific department
            Do ..SendTargetedMessage("HOSPITAL", pDeptId, "NOTIFICATION", tNotification)
        }
    } Catch ex {
        // Silent fail for notifications
    }
}

/// Check SLA compliance
Method CheckSLACompliance() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tKey = ""
        For {
            Set tKey = ..SLATracking.Next(tKey)
            Quit:tKey=""
            
            Set tSLAData = ..SLATracking.GetAt(tKey)
            Set tStartTime = $PIECE(tSLAData, "^", 1)
            Set tSLASeconds = $PIECE(tSLAData, "^", 2)
            
            Set tElapsed = $SYSTEM.SQL.DATEDIFF("ss", tStartTime, $HOROLOG)
            
            If tElapsed > tSLASeconds {
                // SLA breach
                Set ^Hospital.SLABreaches($INCREMENT(^Hospital.SLABreaches)) = 
                    $LISTBUILD($ZDATETIME($HOROLOG, 3), tKey, tElapsed, tSLASeconds)
                
                // Remove from tracking
                Do ..SLATracking.RemoveAt(tKey)
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get department status
Method GetDepartmentStatus(pDeptId As %String) As %String
{
    Set tStatus = "UNKNOWN"
    
    Try {
        If ..Departments.IsDefined(pDeptId) {
            Set tDeptInfo = ..Departments.GetAt(pDeptId)
            Set tStatus = tDeptInfo.status
        }
    } Catch ex {
        Set tStatus = "ERROR"
    }
    
    Quit tStatus
}

/// Generate audit report
Method GenerateAuditReport() As %String
{
    Set tReport = ""
    
    Try {
        Set tReport = "Hospital Communication Audit Report"_$CHAR(13,10)
        Set tReport = tReport_"Generated: "_$ZDATETIME($HOROLOG, 3)_$CHAR(13,10)
        Set tReport = tReport_"="_$TRANSLATE($JUSTIFY("", 50), " ", "=")_$CHAR(13,10)
        
        // Department count
        Set tReport = tReport_"Active Departments: "_..Colleagues.Count()_$CHAR(13,10)
        
        // Active transfers
        Set tActiveCount = 0
        Set tKey = ""
        For {
            Set tKey = ..ActiveTransfers.Next(tKey)
            Quit:tKey=""
            Set tActiveCount = tActiveCount + 1
        }
        Set tReport = tReport_"Active Transfers: "_tActiveCount_$CHAR(13,10)
        
        // Pending consultations
        Set tReport = tReport_"Pending Consultations: "_..PendingConsultations.Count()_$CHAR(13,10)
        
    } Catch ex {
        Set tReport = "Error generating audit report: "_ex.DisplayString()
    }
    
    Quit tReport
}

}
