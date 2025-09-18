/// Unit Test for Observer Pattern Implementation
/// 
/// <p>Comprehensive test suite for the Observer pattern implementation,
/// covering both the base pattern classes and healthcare examples.</p>
/// 
/// <p><strong>Test Coverage:</strong></p>
/// <ul>
///   <li>Subject attach/detach operations</li>
///   <li>Observer notification mechanisms</li>
///   <li>Multiple observer coordination</li>
///   <li>Healthcare example integration</li>
///   <li>Error handling and edge cases</li>
/// </ul>
Class Patterns.Test.Unit.GoF.Behavioral.ObserverTest Extends %UnitTest.TestCase
{

/// Constructor - required for %UnitTest.TestCase
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter - REQUIRED
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    Quit $$$OK
}

/// Test basic Subject attach and detach operations
Method TestSubjectAttachDetach() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create subject
        Set subject = ##class(Patterns.GoF.Behavioral.Observer.Subject).%New()
        Do $$$AssertTrue($IsObject(subject), "Subject created successfully")
        
        // Create observers
        Set observerA = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserverA).%New()
        Set observerB = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserverB).%New()
        
        // Test attach
        Set tSC = subject.Attach(observerA)
        Do $$$AssertStatusOK(tSC, "Observer A attached successfully")
        
        Set tSC = subject.Attach(observerB)
        Do $$$AssertStatusOK(tSC, "Observer B attached successfully")
        
        // Verify observer count
        Do $$$AssertEquals(subject.Observers.Count(), 2, "Two observers attached")
        
        // Test detach
        Set tSC = subject.Detach(observerA)
        Do $$$AssertStatusOK(tSC, "Observer A detached successfully")
        
        Do $$$AssertEquals(subject.Observers.Count(), 1, "One observer remaining after detach")
        
        // Test detach non-existent observer
        Set observerC = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserverA).%New()
        Set tSC = subject.Detach(observerC)
        Do $$$AssertStatusOK(tSC, "Detaching non-existent observer returns OK")
        
        Do $$$AssertEquals(subject.Observers.Count(), 1, "Observer count unchanged after detaching non-existent")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Do $$$AssertStatusOK(tSC, "TestSubjectAttachDetach completed without errors")
    Quit $$$OK
}

/// Test observer notification mechanism
Method TestObserverNotification() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create subject
        Set subject = ##class(Patterns.GoF.Behavioral.Observer.Subject).%New()
        
        // Create and attach observers
        Set observerA = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserverA).%New()
        Set observerB = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserverB).%New()
        
        Do subject.Attach(observerA)
        Do subject.Attach(observerB)
        
        // Test state setting and notification
        Set subject.State = "Initial State"
        Do subject.Notify()
        
        // Verify observers received update
        Do $$$AssertEquals(observerA.ObserverState, "Initial State", "Observer A received state update")
        Do $$$AssertEquals(observerB.ObserverState, "Initial State", "Observer B received state update")
        
        // Update state and notify again
        Set subject.State = "Updated State"
        Do subject.Notify()
        
        Do $$$AssertEquals(observerA.ObserverState, "Updated State", "Observer A received updated state")
        Do $$$AssertEquals(observerB.ObserverState, "Updated State", "Observer B received updated state")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Do $$$AssertStatusOK(tSC, "TestObserverNotification completed without errors")
    Quit $$$OK
}

/// Test ConcreteObserverB selective notification
Method TestSelectiveNotification() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create subject and observer B
        Set subject = ##class(Patterns.GoF.Behavioral.Observer.Subject).%New()
        Set observerB = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserverB).%New()
        
        // Set filter
        Set observerB.Filter = "Important"
        Do subject.Attach(observerB)
        
        // Test notification without filter match
        Set subject.State = "Regular Update"
        Do subject.Notify()
        Do $$$AssertEquals(observerB.ObserverState, "", "Observer B didn't update for non-matching state")
        
        // Test notification with filter match
        Set subject.State = "Important Update"
        Do subject.Notify()
        Do $$$AssertEquals(observerB.ObserverState, "Important Update", "Observer B updated for matching state")
        
        // Test multiple updates
        Set subject.State = "Another Update"
        Do subject.Notify()
        Do $$$AssertEquals(observerB.ObserverState, "Important Update", "Observer B state unchanged for non-matching")
        
        Set subject.State = "Important Message"
        Do subject.Notify()
        Do $$$AssertEquals(observerB.ObserverState, "Important Message", "Observer B updated for new matching state")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Do $$$AssertStatusOK(tSC, "TestSelectiveNotification completed without errors")
    Quit $$$OK
}

/// Test VitalSignsMonitor as Subject
Method TestVitalSignsMonitor() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create vital signs monitor
        Set monitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("TEST-001")
        Do $$$AssertTrue($IsObject(monitor), "VitalSignsMonitor created successfully")
        Do $$$AssertEquals(monitor.PatientID, "TEST-001", "Patient ID set correctly")
        
        // Test normal vital signs
        Set monitor.HeartRate = 75
        Set monitor.BloodPressure = "120/80"
        Set monitor.Temperature = 98.6
        Set monitor.OxygenSaturation = 98
        
        Do $$$AssertEquals(monitor.GetAlertLevel(), "Normal", "Normal vital signs detected correctly")
        
        // Test warning level - high heart rate
        Set monitor.HeartRate = 95
        Do $$$AssertEquals(monitor.GetAlertLevel(), "Warning", "Warning level for elevated heart rate")
        
        // Test critical level - very high heart rate
        Set monitor.HeartRate = 125
        Do $$$AssertEquals(monitor.GetAlertLevel(), "Critical", "Critical level for very high heart rate")
        
        // Test critical level - low oxygen
        Set monitor.HeartRate = 75
        Set monitor.OxygenSaturation = 88
        Do $$$AssertEquals(monitor.GetAlertLevel(), "Critical", "Critical level for low oxygen saturation")
        
        // Test critical level - high temperature
        Set monitor.OxygenSaturation = 98
        Set monitor.Temperature = 103.5
        Do $$$AssertEquals(monitor.GetAlertLevel(), "Critical", "Critical level for high fever")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Do $$$AssertStatusOK(tSC, "TestVitalSignsMonitor completed without errors")
    Quit $$$OK
}

/// Test NurseStation observer
Method TestNurseStation() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create nurse station
        Set nurseStation = ##class(Patterns.Examples.NurseStation).%New("ICU-Station-1", "ICU")
        Do $$$AssertTrue($IsObject(nurseStation), "NurseStation created successfully")
        Do $$$AssertEquals(nurseStation.StationID, "ICU-Station-1", "Station ID set correctly")
        Do $$$AssertEquals(nurseStation.Department, "ICU", "Department set correctly")
        
        // Create and attach to monitor
        Set monitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("PATIENT-001")
        Do monitor.Attach(nurseStation)
        
        // Test normal update
        Set monitor.HeartRate = 75
        Set monitor.BloodPressure = "120/80"
        Set monitor.Temperature = 98.6
        Set monitor.OxygenSaturation = 98
        Do monitor.Notify()
        
        Do $$$AssertEquals(nurseStation.PatientsMonitored, 1, "Patient count incremented")
        Do $$$AssertEquals(nurseStation.NormalAlerts, 1, "Normal alert counted")
        
        // Test warning update
        Set monitor.HeartRate = 95
        Do monitor.Notify()
        
        Do $$$AssertEquals(nurseStation.WarningAlerts, 1, "Warning alert counted")
        Do $$$AssertEquals(nurseStation.AlertQueue.Count(), 1, "Warning added to alert queue")
        
        // Test critical update
        Set monitor.HeartRate = 125
        Do monitor.Notify()
        
        Do $$$AssertEquals(nurseStation.CriticalAlerts, 1, "Critical alert counted")
        Do $$$AssertEquals(nurseStation.AlertQueue.Count(), 2, "Critical added to alert queue")
        
        // Test priority mode
        Set nurseStation.PriorityMode = 1
        Set monitor.HeartRate = 75  // Back to normal
        Do monitor.Notify()
        
        // In priority mode, normal alerts don't update queue
        Do $$$AssertEquals(nurseStation.AlertQueue.Count(), 2, "Normal alert not added in priority mode")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Do $$$AssertStatusOK(tSC, "TestNurseStation completed without errors")
    Quit $$$OK
}

/// Test DoctorPager observer
Method TestDoctorPager() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create doctor pager
        Set pager = ##class(Patterns.Examples.DoctorPager).%New("DR-12345", "Dr. Smith")
        Do $$$AssertTrue($IsObject(pager), "DoctorPager created successfully")
        Do $$$AssertEquals(pager.DoctorID, "DR-12345", "Doctor ID set correctly")
        Do $$$AssertEquals(pager.DoctorName, "Dr. Smith", "Doctor name set correctly")
        
        // Create and attach to monitor
        Set monitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("PATIENT-002")
        Do monitor.Attach(pager)
        
        // Test normal update - should not page
        Set monitor.HeartRate = 75
        Set monitor.BloodPressure = "120/80"
        Set monitor.Temperature = 98.6
        Set monitor.OxygenSaturation = 98
        Do monitor.Notify()
        
        Do $$$AssertEquals(pager.PageCount, 0, "No page for normal vitals")
        
        // Test warning update - should not page
        Set monitor.HeartRate = 95
        Do monitor.Notify()
        
        Do $$$AssertEquals(pager.PageCount, 0, "No page for warning level")
        
        // Test critical update - should page
        Set monitor.HeartRate = 125
        Do monitor.Notify()
        
        Do $$$AssertEquals(pager.PageCount, 1, "Page sent for critical alert")
        Do $$$AssertEquals(pager.PageLog.Count(), 1, "Page logged in history")
        
        // Test escalation threshold
        For i = 1:1:4 {
            Do monitor.Notify()
        }
        
        Do $$$AssertEquals(pager.PageCount, 5, "Multiple pages sent")
        Do $$$AssertTrue(pager.PageCount >= pager.EscalationThreshold, "Escalation threshold reached")
        
        // Test quiet hours
        Set pager.QuietHoursMode = 1
        Set previousCount = pager.PageCount
        Do monitor.Notify()
        
        // In quiet hours, critical still pages but with delay
        Do $$$AssertTrue(pager.PageCount > previousCount, "Page sent even in quiet hours for critical")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Do $$$AssertStatusOK(tSC, "TestDoctorPager completed without errors")
    Quit $$$OK
}

/// Test MedicalRecord observer
Method TestMedicalRecord() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create medical record
        Set record = ##class(Patterns.Examples.MedicalRecord).%New("PATIENT-003", "Nurse Johnson")
        Do $$$AssertTrue($IsObject(record), "MedicalRecord created successfully")
        Do $$$AssertEquals(record.PatientID, "PATIENT-003", "Patient ID set correctly")
        Do $$$AssertEquals(record.AttendingUser, "Nurse Johnson", "Attending user set correctly")
        
        // Create and attach to monitor
        Set monitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("PATIENT-003")
        Do monitor.Attach(record)
        
        // Test normal recording
        Set monitor.HeartRate = 75
        Set monitor.BloodPressure = "120/80"
        Set monitor.Temperature = 98.6
        Set monitor.OxygenSaturation = 98
        Do monitor.Notify()
        
        Do $$$AssertEquals(record.TotalEntries, 1, "Entry recorded")
        Do $$$AssertEquals(record.CriticalEventCount, 0, "No critical events")
        Do $$$AssertEquals(record.WarningEventCount, 0, "No warning events")
        
        // Test warning recording
        Set monitor.HeartRate = 95
        Do monitor.Notify()
        
        Do $$$AssertEquals(record.TotalEntries, 2, "Second entry recorded")
        Do $$$AssertEquals(record.WarningEventCount, 1, "Warning event counted")
        
        // Test critical recording
        Set monitor.HeartRate = 125
        Do monitor.Notify()
        
        Do $$$AssertEquals(record.TotalEntries, 3, "Third entry recorded")
        Do $$$AssertEquals(record.CriticalEventCount, 1, "Critical event counted")
        
        // Test search functionality
        Set matches = record.SearchRecords("Critical")
        Do $$$AssertTrue(matches > 0, "Search found critical entries")
        
        // Test recording stop/resume
        Do record.StopRecording()
        Do $$$AssertEquals(record.IsRecording, 0, "Recording stopped")
        
        Set previousCount = record.TotalEntries
        Do monitor.Notify()
        Do $$$AssertEquals(record.TotalEntries, previousCount, "No new entries when recording stopped")
        
        Do record.ResumeRecording()
        Do $$$AssertEquals(record.IsRecording, 1, "Recording resumed")
        
        Do monitor.Notify()
        Do $$$AssertTrue(record.TotalEntries > previousCount, "New entries after resume")
        
        // Test report generation
        Set report = record.GenerateSummaryReport()
        Do $$$AssertTrue(report [ "PATIENT-003", "Report contains patient ID")
        Do $$$AssertTrue(report [ "Total Entries", "Report contains entry count")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Do $$$AssertStatusOK(tSC, "TestMedicalRecord completed without errors")
    Quit $$$OK
}

/// Test complete healthcare scenario with all observers
Method TestCompleteHealthcareScenario() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create vital signs monitor for patient
        Set monitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("PATIENT-COMPLETE-001")
        Do $$$AssertTrue($IsObject(monitor), "Monitor created for complete scenario")
        
        // Create all observers
        Set nurseStation = ##class(Patterns.Examples.NurseStation).%New("ER-Station", "Emergency")
        Set doctorPager = ##class(Patterns.Examples.DoctorPager).%New("DR-99999", "Dr. Emergency")
        Set medicalRecord = ##class(Patterns.Examples.MedicalRecord).%New("PATIENT-COMPLETE-001", "ER Staff")
        
        // Attach all observers
        Do monitor.Attach(nurseStation)
        Do monitor.Attach(doctorPager)
        Do monitor.Attach(medicalRecord)
        
        Do $$$AssertEquals(monitor.Observers.Count(), 3, "All three observers attached")
        
        // Simulate normal patient admission
        Set monitor.HeartRate = 72
        Set monitor.BloodPressure = "118/78"
        Set monitor.Temperature = 98.4
        Set monitor.OxygenSaturation = 99
        Do monitor.Notify()
        
        // Verify all observers responded appropriately
        Do $$$AssertEquals(nurseStation.NormalAlerts, 1, "Nurse station recorded normal")
        Do $$$AssertEquals(doctorPager.PageCount, 0, "Doctor not paged for normal")
        Do $$$AssertEquals(medicalRecord.TotalEntries, 1, "Medical record logged entry")
        
        // Simulate deteriorating condition
        Set monitor.HeartRate = 110
        Set monitor.Temperature = 101.5
        Do monitor.Notify()
        
        Do $$$AssertEquals(nurseStation.WarningAlerts, 1, "Nurse station on warning alert")
        Do $$$AssertEquals(doctorPager.PageCount, 0, "Doctor not yet paged")
        Do $$$AssertEquals(medicalRecord.WarningEventCount, 1, "Medical record logged warning")
        
        // Simulate critical condition
        Set monitor.HeartRate = 140
        Set monitor.OxygenSaturation = 85
        Do monitor.Notify()
        
        Do $$$AssertEquals(nurseStation.CriticalAlerts, 1, "Nurse station critical alert")
        Do $$$AssertEquals(doctorPager.PageCount, 1, "Doctor paged for critical")
        Do $$$AssertEquals(medicalRecord.CriticalEventCount, 1, "Medical record logged critical")
        
        // Verify coordination - all observers have consistent view
        Do $$$AssertTrue(nurseStation.AlertQueue.Count() > 0, "Nurse station has queued alerts")
        Do $$$AssertTrue(doctorPager.PageLog.Count() > 0, "Doctor has page history")
        Do $$$AssertTrue(medicalRecord.RecordEntries.Count() = 3, "Medical record has all entries")
        
        // Test removing one observer
        Do monitor.Detach(doctorPager)
        Do $$$AssertEquals(monitor.Observers.Count(), 2, "One observer detached")
        
        // Continue monitoring
        Set monitor.HeartRate = 150
        Do monitor.Notify()
        
        Set previousPageCount = doctorPager.PageCount
        Do $$$AssertEquals(doctorPager.PageCount, previousPageCount, "Detached pager not notified")
        Do $$$AssertEquals(nurseStation.CriticalAlerts, 2, "Attached nurse station still notified")
        Do $$$AssertEquals(medicalRecord.TotalEntries, 4, "Attached medical record still logging")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Do $$$AssertStatusOK(tSC, "TestCompleteHealthcareScenario completed without errors")
    Quit $$$OK
}

/// Test error handling and edge cases
Method TestErrorHandling() As %Status
{
    Set tSC = $$$OK
    Try {
        // Test null observer attachment
        Set subject = ##class(Patterns.GoF.Behavioral.Observer.Subject).%New()
        Set tSC = subject.Attach("")
        Do $$$AssertStatusNotOK(tSC, "Cannot attach null observer")
        
        // Test invalid observer type
        Set invalidObj = ##class(%Library.ListOfDataTypes).%New()
        Set tSC = subject.Attach(invalidObj)
        Do $$$AssertStatusNotOK(tSC, "Cannot attach non-observer object")
        
        // Test detaching from empty list
        Set emptySubject = ##class(Patterns.GoF.Behavioral.Observer.Subject).%New()
        Set observer = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserverA).%New()
        Set tSC = emptySubject.Detach(observer)
        Do $$$AssertStatusOK(tSC, "Detaching from empty list handled gracefully")
        
        // Test notification with no observers
        Do emptySubject.Notify()
        Do $$$AssertTrue(1, "Notify with no observers completes without error")
        
        // Test VitalSignsMonitor with invalid values
        Set monitor = ##class(Patterns.Examples.VitalSignsMonitor).%New()
        Set monitor.HeartRate = -10
        Do $$$AssertEquals(monitor.GetAlertLevel(), "Critical", "Negative heart rate triggers critical")
        
        Set monitor.HeartRate = 75
        Set monitor.OxygenSaturation = 150
        Do $$$AssertEquals(monitor.GetAlertLevel(), "Critical", "Invalid oxygen saturation triggers critical")
        
        // Test MedicalRecord export with invalid format
        Set record = ##class(Patterns.Examples.MedicalRecord).%New()
        Set tSC = record.ExportRecords("INVALID_FORMAT")
        Do $$$AssertStatusOK(tSC, "Invalid export format handled gracefully")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Do $$$AssertStatusOK(tSC, "TestErrorHandling completed without errors")
    Quit $$$OK
}

}
