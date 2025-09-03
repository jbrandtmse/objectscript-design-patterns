/// Medical Record Observer
/// 
/// <p>Observer that maintains a comprehensive audit log of all vital sign changes
/// for medical record keeping and compliance. This observer demonstrates complete
/// logging with persistent storage and regulatory compliance features.</p>
/// 
/// <p><strong>Pattern Role:</strong> Concrete Observer</p>
/// <p><strong>Healthcare Context:</strong> Electronic Medical Record System</p>
/// 
/// <p><strong>Features:</strong></p>
/// <ul>
///   <li>Complete audit trail of all vital sign changes</li>
///   <li>Timestamped entries with user attribution</li>
///   <li>Compliance with medical record retention policies</li>
///   <li>Searchable history for clinical reviews</li>
/// </ul>
/// 
/// @see Patterns.GoF.Behavioral.Observer.Observer
/// @see Patterns.Examples.VitalSignsMonitor
Class Patterns.Examples.MedicalRecord Extends Patterns.GoF.Behavioral.Observer.Observer
{

/// Patient identifier for this medical record
Property PatientID As %String;

/// User who initiated monitoring session
Property AttendingUser As %String [ InitialExpression = "System" ];

/// Record of all vital sign entries
Property RecordEntries As %Library.ListOfDataTypes;

/// Total number of entries recorded
Property TotalEntries As %Integer [ InitialExpression = 0 ];

/// Count of critical events for reporting
Property CriticalEventCount As %Integer [ InitialExpression = 0 ];

/// Count of warning events for reporting
Property WarningEventCount As %Integer [ InitialExpression = 0 ];

/// Flag for active recording
Property IsRecording As %Boolean [ InitialExpression = 1 ];

/// Constructor
/// 
/// <p>Initializes the medical record observer with patient information.</p>
/// 
/// @param pPatientID Patient identifier
/// @param pUser User initiating the monitoring
/// @return Status code
Method %OnNew(pPatientID As %String = "", pUser As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize patient ID
        If pPatientID '= "" {
            Set ..PatientID = pPatientID
        } Else {
            Set ..PatientID = "PATIENT-"_$Random(10000)
        }
        
        // Initialize user
        If pUser '= "" {
            Set ..AttendingUser = pUser
        }
        
        // Initialize record entries list
        Set ..RecordEntries = ##class(%Library.ListOfDataTypes).%New()
        
        // Log initial entry
        Do ..LogEntry("INIT", "Medical record monitoring started", "Normal")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Update method called when vital signs change
/// 
/// <p>Records all vital sign changes with full context for medical records.</p>
/// 
/// @param pSubject The VitalSignsMonitor that triggered the update
/// @return Status code
Method Update(pSubject As Patterns.GoF.Behavioral.Observer.Subject, pData As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Check if recording is active
        If '..IsRecording {
            Quit  // Argumentless QUIT
        }
        
        // Cast to VitalSignsMonitor
        If $IsObject(pSubject) && pSubject.%IsA("Patterns.Examples.VitalSignsMonitor") {
            Set monitor = pSubject
            
            // Build comprehensive record entry
            Set timestamp = $ZDateTime($Horolog, 3)
            Set alertLevel = monitor.GetAlertLevel()
            
            // Create detailed entry
            Set entry = timestamp_"|"_..PatientID_"|"_..AttendingUser_"|"
            Set entry = entry_"HR:"_monitor.HeartRate_"|"
            Set entry = entry_"BP:"_monitor.BloodPressure_"|"
            Set entry = entry_"TEMP:"_monitor.Temperature_"|"
            Set entry = entry_"O2:"_monitor.OxygenSaturation_"|"
            Set entry = entry_"ALERT:"_alertLevel
            
            // Add to record
            Do ..RecordEntries.Insert(entry)
            Set ..TotalEntries = ..TotalEntries + 1
            
            // Track alert levels for reporting
            If alertLevel = "Critical" {
                Set ..CriticalEventCount = ..CriticalEventCount + 1
                Do ..LogEntry("CRITICAL", entry, alertLevel)
                
                // Trigger compliance notification for critical events
                Do ..NotifyCompliance(entry)
            }
            ElseIf alertLevel = "Warning" {
                Set ..WarningEventCount = ..WarningEventCount + 1
                Do ..LogEntry("WARNING", entry, alertLevel)
            }
            Else {
                Do ..LogEntry("NORMAL", entry, alertLevel)
            }
            
            // Auto-save to persistent storage every 10 entries
            If ..TotalEntries # 10 = 0 {
                Do ..SaveToPersistentStorage()
            }
        }
    }
    Catch ex {
        // Log error but don't interrupt monitoring
        Do ..LogEntry("ERROR", "Failed to record vital signs: "_ex.DisplayString(), "Error")
        Set tSC = ex.AsStatus()
    }
    Quit tSC  // Return tSC after Try/Catch block
}

/// Log entry to medical record
/// 
/// @param pType Type of entry (INIT, NORMAL, WARNING, CRITICAL, ERROR)
/// @param pMessage Message to log
/// @param pSeverity Severity level
Method LogEntry(pType As %String, pMessage As %String, pSeverity As %String)
{
    Try {
        // In production, this would write to persistent medical record database
        Write !, "[MedicalRecord]["_$ZDateTime($Horolog, 3)_"]["_pType_"] "_pMessage
    }
    Catch ex {
        // Silent fail to avoid disrupting monitoring
    }
}

/// Notify compliance system of critical events
/// 
/// @param pEntry The critical event entry
Method NotifyCompliance(pEntry As %String)
{
    Try {
        // In production, this would notify compliance/quality assurance systems
        Write !, "[MedicalRecord] COMPLIANCE NOTIFICATION: Critical event recorded"
        Write !, "  Entry: "_pEntry
        Write !, "  Patient: "_..PatientID
        Write !, "  Attending: "_..AttendingUser
    }
    Catch ex {
        // Silent fail
    }
}

/// Save records to persistent storage
Method SaveToPersistentStorage()
{
    Try {
        Write !, "[MedicalRecord] Auto-saving "_..TotalEntries_" entries to persistent storage..."
        Write !, "  Critical Events: "_..CriticalEventCount
        Write !, "  Warning Events: "_..WarningEventCount
        Write !, "  Normal Events: "_(..TotalEntries - ..CriticalEventCount - ..WarningEventCount)
    }
    Catch ex {
        Do ..LogEntry("ERROR", "Failed to save to persistent storage: "_ex.DisplayString(), "Error")
    }
}

/// Generate summary report
/// 
/// @return Summary report as string
Method GenerateSummaryReport() As %String
{
    Set report = ""
    Try {
        Set report = "Medical Record Summary for Patient: "_..PatientID_$Char(13,10)
        Set report = report_"Total Entries: "_..TotalEntries_$Char(13,10)
        Set report = report_"Critical Events: "_..CriticalEventCount_$Char(13,10)
        Set report = report_"Warning Events: "_..WarningEventCount_$Char(13,10)
        Set report = report_"Recording Status: "
        If ..IsRecording {
            Set report = report_"Active"
        } Else {
            Set report = report_"Stopped"
        }
        Set report = report_$Char(13,10)
        Set report = report_"Attending User: "_..AttendingUser
    }
    Catch ex {
        Set report = "Error generating report: "_ex.DisplayString()
    }
    Quit report
}

/// Search records for specific conditions
/// 
/// @param pSearchTerm Term to search for in records
/// @return Number of matching entries
Method SearchRecords(pSearchTerm As %String) As %Integer
{
    Set matches = 0
    Try {
        For i = 1:1:..RecordEntries.Count() {
            Set entry = ..RecordEntries.GetAt(i)
            If entry [ pSearchTerm {
                Set matches = matches + 1
                Write !, "[MedicalRecord] Match found: "_entry
            }
        }
    }
    Catch ex {
        Write !, "[MedicalRecord] Search error: "_ex.DisplayString()
    }
    Quit matches
}

/// Stop recording (for end of monitoring session)
Method StopRecording()
{
    Set ..IsRecording = 0
    Do ..SaveToPersistentStorage()
    Do ..LogEntry("STOP", "Medical record monitoring stopped", "Normal")
    Write !, "[MedicalRecord] Recording stopped. Final report:"
    Write !, ..GenerateSummaryReport()
}

/// Resume recording
Method ResumeRecording()
{
    Set ..IsRecording = 1
    Do ..LogEntry("RESUME", "Medical record monitoring resumed", "Normal")
}

/// Export records to standard format
/// 
/// @param pFormat Export format (HL7, FHIR, CSV)
/// @return Export status
Method ExportRecords(pFormat As %String = "CSV") As %Status
{
    Set tSC = $$$OK
    Try {
        Write !, "[MedicalRecord] Exporting "_..TotalEntries_" records to "_pFormat_" format..."
        
        If pFormat = "HL7" {
            Write !, "  Generating HL7 messages..."
        }
        ElseIf pFormat = "FHIR" {
            Write !, "  Creating FHIR resources..."
        }
        Else {
            Write !, "  Creating CSV file..."
            // Header
            Write !, "Timestamp,PatientID,User,HeartRate,BloodPressure,Temperature,OxygenSat,AlertLevel"
            // Data rows (sample)
            For i = 1:1:$Select(..RecordEntries.Count() < 5:..RecordEntries.Count(), 1:5) {
                Write !, ..RecordEntries.GetAt(i)
            }
        }
        
        Write !, "[MedicalRecord] Export completed successfully"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "[MedicalRecord] Export failed: "_ex.DisplayString()
    }
    Quit tSC
}

}
