/// Gang of Four Mediator Pattern - Radiology Department Colleague
/// 
/// Purpose:
/// Represents the Radiology Department in the hospital mediator system.
/// Handles imaging requests, processes scans, and provides results to
/// other departments.
/// 
/// Features:
/// - Imaging request processing
/// - Scan scheduling and prioritization
/// - Result reporting
/// - Emergency imaging support
Class Patterns.Examples.RadiologyDepartment Extends Patterns.GoF.Behavioral.Colleague
{

/// Department name
Property DepartmentName As %String [ InitialExpression = "Radiology Department" ];

/// Available scanners
Property AvailableScanners As %Integer [ InitialExpression = 5 ];

/// Active scans in progress
Property ActiveScans As %Integer [ InitialExpression = 0 ];

/// Pending scan queue
Property PendingScanQueue As %ListOfObjects;

/// Completed scans awaiting interpretation
Property CompletedScans As %ListOfObjects;

/// Emergency scan slots
Property EmergencySlots As %Integer [ InitialExpression = 2 ];

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Set ..ColleagueId = "RADIOLOGY"
    Set ..PendingScanQueue = ##class(%ListOfObjects).%New()
    Set ..CompletedScans = ##class(%ListOfObjects).%New()
    
    Quit tSC
}

/// Receive message from mediator
Method Receive(pEvent As %String, pData As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Log receipt
        Set ^RadiologyDept.Messages($INCREMENT(^RadiologyDept.Messages)) = 
            $LISTBUILD($ZDATETIME($HOROLOG, 3), pEvent, 
                       $SELECT($IsObject(pData):pData.%ToJSON(), 1:""))
        
        // Handle different message types
        If pEvent = "RADIOLOGY_CONSULT" {
            Set tSC = ..HandleRadiologyRequest(pData)
        } ElseIf pEvent = "EMERGENCY" {
            Set tSC = ..HandleEmergencyAlert(pData)
        } ElseIf pEvent = "TRANSFER_REQUEST" {
            Set tSC = ..HandleTransferRequest(pData)
        } ElseIf pEvent = "DEPARTMENT_UPDATE" {
            Set tSC = ..HandleDepartmentUpdate(pData)
        } ElseIf pEvent = "CANCEL_SCAN" {
            Set tSC = ..CancelScan(pData)
        } Else {
            // Generic message handling
            Do ..LogMessage(pEvent, pData)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle radiology request
Method HandleRadiologyRequest(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Create scan request
        Set tScanRequest = ##class(%DynamicObject).%New()
        Set tScanRequest.scanId = $System.Util.CreateGUID()
        Set tScanRequest.patientId = pData.patientId
        Set tScanRequest.studyType = pData.studyType
        Set tScanRequest.requestingDept = pData.requestingDepartment
        Set tScanRequest.urgent = $GET(pData.urgent, 0)
        Set tScanRequest.requestTime = $ZDATETIME($HOROLOG, 3)
        Set tScanRequest.status = "PENDING"
        
        // Store scan request
        Set ^RadiologyDept.ScanRequests(tScanRequest.scanId) = tScanRequest.%ToJSON()
        
        // Check if emergency scan
        If tScanRequest.urgent {
            Set tSC = ..ScheduleEmergencyScan(tScanRequest)
        } Else {
            // Add to regular queue
            Do ..PendingScanQueue.Insert(tScanRequest)
            
            // Try to schedule if scanner available
            If ..ActiveScans < ..AvailableScanners {
                Do ..ProcessNextScan()
            }
        }
        
        // Send acknowledgment
        Do ..SendScanScheduledNotification(tScanRequest)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Schedule emergency scan
Method ScheduleEmergencyScan(pScanRequest As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Check emergency slots
        If ..EmergencySlots > 0 {
            // Use emergency slot
            Set ..EmergencySlots = ..EmergencySlots - 1
            Set ..ActiveScans = ..ActiveScans + 1
            
            // Update status
            Set pScanRequest.status = "IN_PROGRESS"
            Set pScanRequest.startTime = $ZDATETIME($HOROLOG, 3)
            
            // Store update
            Set ^RadiologyDept.ActiveScans(pScanRequest.scanId) = pScanRequest.%ToJSON()
            
            // Simulate scan processing
            Job ..ProcessScan(pScanRequest.scanId)::5
            
        } Else {
            // Add to front of queue
            Do ..PendingScanQueue.InsertAt(pScanRequest, 1)
            
            // Try to preempt non-urgent scan if possible
            Do ..PreemptNonUrgentScan()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process next scan in queue
Method ProcessNextScan() [ Private ]
{
    Try {
        If ..PendingScanQueue.Count() > 0 {
            Set tScanRequest = ..PendingScanQueue.GetAt(1)
            Do ..PendingScanQueue.RemoveAt(1)
            
            // Start scan
            Set ..ActiveScans = ..ActiveScans + 1
            Set tScanRequest.status = "IN_PROGRESS"
            Set tScanRequest.startTime = $ZDATETIME($HOROLOG, 3)
            
            // Store active scan
            Set ^RadiologyDept.ActiveScans(tScanRequest.scanId) = tScanRequest.%ToJSON()
            
            // Simulate scan processing
            Job ..ProcessScan(tScanRequest.scanId)::5
        }
    } Catch ex {
        // Log error
    }
}

/// Process scan (simulated)
ClassMethod ProcessScan(pScanId As %String) [ Private ]
{
    Try {
        // Simulate scan duration (30-180 seconds)
        Hang $RANDOM(150) + 30
        
        // Complete scan
        If $Data(^RadiologyDept.ActiveScans(pScanId)) {
            Set tScanJSON = ^RadiologyDept.ActiveScans(pScanId)
            Set tScan = ##class(%DynamicObject).%FromJSON(tScanJSON)
            
            // Update status
            Set tScan.status = "COMPLETED"
            Set tScan.completionTime = $ZDATETIME($HOROLOG, 3)
            
            // Generate results
            Set tResults = ##class(%DynamicObject).%New()
            Set tResults.scanId = pScanId
            Set tResults.patientId = tScan.patientId
            Set tResults.studyType = tScan.studyType
            Set tResults.findings = ..GenerateMockFindings(tScan.studyType)
            Set tResults.urgent = tScan.urgent
            Set tResults.interpretationTime = $ZDATETIME($HOROLOG, 3)
            
            // Store completed scan
            Set ^RadiologyDept.CompletedScans(pScanId) = tScan.%ToJSON()
            Set ^RadiologyDept.Results(pScanId) = tResults.%ToJSON()
            Kill ^RadiologyDept.ActiveScans(pScanId)
            
            // Send results through mediator
            Do ##class(RadiologyDepartment).SendResults(pScanId, tResults)
        }
        
    } Catch ex {
        // Log error
    }
}

/// Generate mock findings
ClassMethod GenerateMockFindings(pStudyType As %String) As %String [ Private ]
{
    Set tFindings = "Study Type: "_pStudyType_". "
    
    Set tRandom = $RANDOM(10)
    If tRandom < 3 {
        Set tFindings = tFindings_"No significant abnormalities detected."
    } ElseIf tRandom < 6 {
        Set tFindings = tFindings_"Minor findings, no acute process."
    } ElseIf tRandom < 9 {
        Set tFindings = tFindings_"Findings requiring clinical correlation."
    } Else {
        Set tFindings = tFindings_"Significant findings requiring immediate attention."
    }
    
    Quit tFindings
}

/// Send scan results
ClassMethod SendResults(pScanId As %String, pResults As %DynamicObject)
{
    Try {
        // Get department instance
        // In real scenario, would maintain singleton instance
        Set tDept = ##class(RadiologyDepartment).%New()
        
        If $IsObject(tDept.Mediator) {
            // Send results to requesting department
            Set tNotification = ##class(%DynamicObject).%New()
            Set tNotification = pResults
            
            Set tSC = tDept.Send("RADIOLOGY_RESULT", tNotification)
            
            // If urgent, also send alert
            If pResults.urgent && (pResults.findings [ "immediate attention") {
                Set tAlert = ##class(%DynamicObject).%New()
                Set tAlert.patientId = pResults.patientId
                Set tAlert.department = "RADIOLOGY"
                Set tAlert.alertType = "URGENT_FINDING"
                Set tAlert.details = pResults.findings
                
                Set tSC = tDept.Send("URGENT_ALERT", tAlert)
            }
        }
        
    } Catch ex {
        // Log error
    }
}

/// Cancel scan request
Method CancelScan(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        Set tScanId = pData.scanId
        
        // Check if scan is in queue
        For i=..PendingScanQueue.Count():-1:1 {
            Set tScan = ..PendingScanQueue.GetAt(i)
            If tScan.scanId = tScanId {
                Do ..PendingScanQueue.RemoveAt(i)
                Set ^RadiologyDept.CancelledScans(tScanId) = tScan.%ToJSON()
                Quit
            }
        }
        
        // Check if scan is active
        If $Data(^RadiologyDept.ActiveScans(tScanId)) {
            // Can't cancel active scan
            Set tSC = $$$ERROR($$$GeneralError, "Cannot cancel scan in progress")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Send scan scheduled notification
Method SendScanScheduledNotification(pScanRequest As %DynamicObject) [ Private ]
{
    Try {
        If $IsObject(..Mediator) {
            Set tNotification = ##class(%DynamicObject).%New()
            Set tNotification.scanId = pScanRequest.scanId
            Set tNotification.patientId = pScanRequest.patientId
            Set tNotification.studyType = pScanRequest.studyType
            Set tNotification.status = pScanRequest.status
            Set tNotification.estimatedTime = ..GetEstimatedScanTime()
            
            // Send to requesting department
            Set tSC = ..Send("SCAN_SCHEDULED", tNotification)
        }
    } Catch ex {
        // Log error
    }
}

/// Get estimated scan time
Method GetEstimatedScanTime() As %String [ Private ]
{
    Set tWaitTime = ..PendingScanQueue.Count() * 45  // Average 45 min per scan
    Set tHours = tWaitTime \ 60
    Set tMinutes = tWaitTime # 60
    
    Quit tHours_" hours "_tMinutes_" minutes"
}

/// Handle emergency alert
Method HandleEmergencyAlert(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Log emergency
        Set ^RadiologyDept.Emergencies($INCREMENT(^RadiologyDept.Emergencies)) = 
            pData.%ToJSON()
        
        // Take action based on emergency type
        If pData.type = "MASS_CASUALTY" {
            // Prepare for mass casualty imaging
            Do ..PrepareMassCasualtyProtocol()
        } ElseIf pData.type = "CODE_RED" {
            // Fire emergency - prepare for evacuation
            Do ..PrepareEvacuation()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle transfer request
Method HandleTransferRequest(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Radiology typically doesn't accept patient transfers directly
        // But may need to expedite pending scans
        If pData.%IsDefined("patientId") {
            Do ..ExpeditePatientScans(pData.patientId)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Expedite scans for transferred patient
Method ExpeditePatientScans(pPatientId As %String) [ Private ]
{
    Try {
        // Check if patient has pending scans
        For i=1:1:..PendingScanQueue.Count() {
            Set tScan = ..PendingScanQueue.GetAt(i)
            If tScan.patientId = pPatientId {
                // Move to front of queue
                Do ..PendingScanQueue.RemoveAt(i)
                Do ..PendingScanQueue.InsertAt(tScan, 1)
                Quit
            }
        }
    } Catch ex {
        // Log error
    }
}

/// Preempt non-urgent scan for emergency
Method PreemptNonUrgentScan() [ Private ]
{
    // Implementation for preempting non-urgent scans
}

/// Prepare mass casualty protocol
Method PrepareMassCasualtyProtocol() [ Private ]
{
    // Clear all non-urgent scans
    Set tNewQueue = ##class(%ListOfObjects).%New()
    
    For i=1:1:..PendingScanQueue.Count() {
        Set tScan = ..PendingScanQueue.GetAt(i)
        If tScan.urgent {
            Do tNewQueue.Insert(tScan)
        }
    }
    
    Set ..PendingScanQueue = tNewQueue
    Set ..EmergencySlots = ..AvailableScanners  // All slots for emergency
    
    Set ^RadiologyDept.MassCasualty = $ZDATETIME($HOROLOG, 3)_" - Protocol activated"
}

/// Prepare evacuation
Method PrepareEvacuation() [ Private ]
{
    Set ^RadiologyDept.Evacuation = $ZDATETIME($HOROLOG, 3)_" - Evacuation prepared"
}

/// Handle department update
Method HandleDepartmentUpdate(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    // Track other department status changes
    Quit tSC
}

/// Log message
Method LogMessage(pEvent As %String, pData As %DynamicObject) [ Private ]
{
    Set ^RadiologyDept.GeneralMessages($INCREMENT(^RadiologyDept.GeneralMessages)) = 
        $LISTBUILD($ZDATETIME($HOROLOG, 3), pEvent, 
                   $SELECT($IsObject(pData):pData.%ToJSON(), 1:""))
}

/// Get department status
Method GetStatus() As %String
{
    Set tStatus = ##class(%DynamicObject).%New()
    Set tStatus.department = "RADIOLOGY"
    Set tStatus.activeScanners = ..ActiveScans_"/"_..AvailableScanners
    Set tStatus.queueLength = ..PendingScanQueue.Count()
    Set tStatus.completedScans = ..CompletedScans.Count()
    Set tStatus.emergencySlots = ..EmergencySlots
    Set tStatus.status = $SELECT(..ActiveScans >= ..AvailableScanners:"BUSY",
                                 ..PendingScanQueue.Count() > 10:"BACKLOG",
                                 1:"AVAILABLE")
    
    Quit tStatus.%ToJSON()
}

}
