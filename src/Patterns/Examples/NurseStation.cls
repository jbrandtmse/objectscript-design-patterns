/// Healthcare Example - Nurse Station Observer
/// 
/// Purpose:
/// Represents a nurse station monitoring system that receives notifications
/// from vital signs monitors and displays alerts for nursing staff.
/// 
/// Real-World Behavior:
/// - Displays all patient vital sign changes on nursing station monitors
/// - Highlights warnings in yellow and critical alerts in red
/// - Maintains a queue of alerts that need acknowledgment
/// - Can sound audible alarms for critical conditions
/// 
/// @see Patterns.GoF.Behavioral.Observer.Observer
/// @see Patterns.Examples.VitalSignsMonitor
/// @since 1.0.0
Class Patterns.Examples.NurseStation Extends Patterns.GoF.Behavioral.Observer.Observer
{

// ===== PROPERTIES =====

/// Station identifier (e.g., "ICU-North", "ER-1")
Property StationID As %String;

/// Department name
Property Department As %String;

/// Queue of unacknowledged alerts
Property AlertQueue As %ListOfDataTypes;

/// Count of patients being monitored
Property PatientsMonitored As %Integer [ InitialExpression = 0 ];

/// Count of normal alerts
Property NormalAlerts As %Integer [ InitialExpression = 0 ];

/// Count of warning alerts
Property WarningAlerts As %Integer [ InitialExpression = 0 ];

/// Count of critical alerts
Property CriticalAlerts As %Integer [ InitialExpression = 0 ];

/// Priority mode flag
Property PriorityMode As %Boolean [ InitialExpression = 0 ];

/// Last alert timestamp
Property LastAlertTime As %TimeStamp;

// ===== CONSTRUCTORS =====

/// Initialize nurse station with ID and department
Method %OnNew(pStationID As %String = "NurseStation-1", pDepartment As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..StationID = pStationID
        Set ..Department = pDepartment
        Set ..AlertQueue = ##class(%ListOfDataTypes).%New()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Handle vital signs update notifications
Method Update(pSubject As Patterns.GoF.Behavioral.Observer.Subject) As %Status
{
    Set tSC = $$$OK
    Try {
        // Check if subject is VitalSignsMonitor
        If pSubject.%IsA("Patterns.Examples.VitalSignsMonitor") {
            Set monitor = pSubject
            Set alertLevel = monitor.GetAlertLevel()
            
            // Increment patient count on first alert
            If ..PatientsMonitored = 0 {
                Set ..PatientsMonitored = ..PatientsMonitored + 1
            }
            
            // Process based on alert level
            If alertLevel = "Critical" {
                Set ..CriticalAlerts = ..CriticalAlerts + 1
                Do ..AlertQueue.Insert($ZDateTime($H, 3) _ " - CRITICAL: Patient " _ monitor.PatientID)
                Write "[NurseStation][" _ ..StationID _ "] CRITICAL ALERT for patient " _ monitor.PatientID, !
                Write "  Immediate response required!", !
            }
            ElseIf alertLevel = "Warning" {
                Set ..WarningAlerts = ..WarningAlerts + 1
                If '..PriorityMode {
                    Do ..AlertQueue.Insert($ZDateTime($H, 3) _ " - WARNING: Patient " _ monitor.PatientID)
                }
                Write "[NurseStation][" _ ..StationID _ "] Warning alert for patient " _ monitor.PatientID, !
            }
            Else {
                Set ..NormalAlerts = ..NormalAlerts + 1
                If '..PriorityMode {
                    Write "[NurseStation][" _ ..StationID _ "] Normal vitals for patient " _ monitor.PatientID, !
                }
            }
            
            // Display current vital signs
            Write "  Heart Rate: " _ monitor.HeartRate _ " bpm", !
            Write "  Temperature: " _ monitor.Temperature _ " F", !
            Write "  Oxygen Saturation: " _ monitor.OxygenSaturation _ "%", !
            Write "  Alert Queue Size: " _ ..AlertQueue.Count(), !, !
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Clear all alerts from queue
Method ClearAlertQueue() As %Status
{
    Set tSC = $$$OK
    Try {
        Do ..AlertQueue.Clear()
        Write "[NurseStation][" _ ..StationID _ "] Alert queue cleared", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get alert statistics
Method GetStatistics() As %String
{
    Set stats = "Station: " _ ..StationID _ " (" _ ..Department _ ")" _ $Char(13,10)
    Set stats = stats _ "Patients Monitored: " _ ..PatientsMonitored _ $Char(13,10)
    Set stats = stats _ "Normal Alerts: " _ ..NormalAlerts _ $Char(13,10)
    Set stats = stats _ "Warning Alerts: " _ ..WarningAlerts _ $Char(13,10)
    Set stats = stats _ "Critical Alerts: " _ ..CriticalAlerts _ $Char(13,10)
    Set stats = stats _ "Current Queue Size: " _ ..AlertQueue.Count()
    Quit stats
}

/// Simulate sounding an alarm
Method SoundAlarm(pSeverity As %String) [ Private ]
{
    If pSeverity = "CRITICAL" {
        Write "    🔴🔔 ALARM: BEEP-BEEP-BEEP-BEEP! 🔔🔴", !
    } ElseIf pSeverity = "WARNING" {
        Write "    🟡🔔 Alert: Beep-Beep! 🔔🟡", !
    }
}

}
