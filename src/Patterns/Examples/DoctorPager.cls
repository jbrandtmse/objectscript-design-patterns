/// Doctor Pager Observer Implementation
/// 
/// <p>Concrete observer representing a doctor's pager system.
/// Only responds to critical patient conditions requiring immediate attention.</p>
/// 
/// <p><strong>Features:</strong></p>
/// <ul>
///   <li>Critical-only alerts</li>
///   <li>Page history logging</li>
///   <li>Escalation tracking</li>
///   <li>Quiet hours mode</li>
/// </ul>
Class Patterns.Examples.DoctorPager Extends Patterns.GoF.Behavioral.Observer.Observer
{

/// Doctor identifier
Property DoctorID As %String;

/// Doctor name
Property DoctorName As %String;

/// Page count
Property PageCount As %Integer [ InitialExpression = 0 ];

/// Page history log
Property PageLog As %ListOfDataTypes;

/// Escalation threshold
Property EscalationThreshold As %Integer [ InitialExpression = 3 ];

/// Quiet hours mode
Property QuietHoursMode As %Boolean [ InitialExpression = 0 ];

/// Constructor
Method %OnNew(pDoctorID As %String = "", pDoctorName As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..DoctorID = pDoctorID
        Set ..DoctorName = pDoctorName
        Set ..PageLog = ##class(%ListOfDataTypes).%New()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Update method to receive notifications
Method Update(pSubject As Patterns.GoF.Behavioral.Observer.Subject) As %Status
{
    Set tSC = $$$OK
    Try {
        // Check if subject is VitalSignsMonitor
        If pSubject.%IsA("Patterns.Examples.VitalSignsMonitor") {
            Set monitor = pSubject
            Set alertLevel = monitor.GetAlertLevel()
            
            // Only page for critical alerts
            If alertLevel = "Critical" {
                Set ..PageCount = ..PageCount + 1
                
                Set pageMsg = $ZDateTime($H, 3) _ " - CRITICAL: Patient " _ monitor.PatientID
                Do ..PageLog.Insert(pageMsg)
                
                If ..QuietHoursMode {
                    Write "[DoctorPager] DELAYED PAGE to Dr. " _ ..DoctorName _ " (" _ ..DoctorID _ ")", !
                    Write "  (Quiet hours - will send in 5 minutes)", !
                }
                Else {
                    Write "[DoctorPager] *** URGENT PAGE *** to Dr. " _ ..DoctorName _ " (" _ ..DoctorID _ ")", !
                }
                
                Write "  Patient: " _ monitor.PatientID, !
                Write "  Alert Level: CRITICAL", !
                Write "  Heart Rate: " _ monitor.HeartRate _ " bpm", !
                Write "  Temperature: " _ monitor.Temperature _ " F", !
                Write "  Oxygen Saturation: " _ monitor.OxygenSaturation _ "%", !
                
                // Check for escalation
                If ..PageCount >= ..EscalationThreshold {
                    Write "  *** ESCALATION THRESHOLD REACHED ***", !
                    Write "  Total pages: " _ ..PageCount, !
                }
                Write !
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Clear page history
Method ClearPageHistory() As %Status
{
    Set tSC = $$$OK
    Try {
        Do ..PageLog.Clear()
        Set ..PageCount = 0
        Write "[DoctorPager] Page history cleared for Dr. " _ ..DoctorName _ " (" _ ..DoctorID _ ")", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get page summary
Method GetPageSummary() As %String
{
    Set summary = "Doctor: " _ ..DoctorName _ " (ID: " _ ..DoctorID _ ")" _ $Char(13,10)
    Set summary = summary _ "Total Pages: " _ ..PageCount _ $Char(13,10)
    Set summary = summary _ "Escalation Status: "
    If ..PageCount >= ..EscalationThreshold {
        Set summary = summary _ "ESCALATED"
    } Else {
        Set summary = summary _ "Normal"
    }
    Quit summary
}

}
