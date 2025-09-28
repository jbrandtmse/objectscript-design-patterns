/// Debug test for Mediator pattern failures
Class Patterns.Test.MediatorDebugTest Extends %RegisteredObject
{

/// Debug TestColleagueRegistry
ClassMethod DebugColleagueRegistry() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "=== TestColleagueRegistry Debug ===; "
    
    Try {
        // Create registry
        Set registry = ##class(Patterns.GoF.Behavioral.ColleagueRegistry).%New()
        Set ^ClineDebug = ^ClineDebug _ "Registry created: " _ $ISOBJECT(registry) _ "; "
        
        // Create test colleagues
        Set colleague1 = ##class(Patterns.Examples.EmergencyDepartment).%New()
        Set colleague2 = ##class(Patterns.Examples.RadiologyDepartment).%New()
        Set ^ClineDebug = ^ClineDebug _ "Colleagues created: " _ $ISOBJECT(colleague1) _ "," _ $ISOBJECT(colleague2) _ "; "
        
        // Register colleagues
        Set metadata1 = {"department": "Emergency", "priority": "high"}
        Set tSC = registry.RegisterColleague("ED001", colleague1, "Emergency", metadata1)
        Set ^ClineDebug = ^ClineDebug _ "Register ED001: " _ $$$ISOK(tSC) _ "; "
        
        Set metadata2 = {"department": "Radiology", "priority": "normal"}
        Set tSC = registry.RegisterColleague("RAD001", colleague2, "Radiology", metadata2)
        Set ^ClineDebug = ^ClineDebug _ "Register RAD001: " _ $$$ISOK(tSC) _ "; "
        
        // Get colleague
        Set retrievedColleague = registry.GetColleague("ED001")
        Set ^ClineDebug = ^ClineDebug _ "Retrieved ED001: " _ $ISOBJECT(retrievedColleague) _ "; "
        
        // Check active status
        Set isActive = registry.IsActive("ED001")
        Set ^ClineDebug = ^ClineDebug _ "ED001 is active: " _ isActive _ "; "
        
        // Set inactive
        Set tSC = registry.SetActive("ED001", 0)
        Set ^ClineDebug = ^ClineDebug _ "Set ED001 inactive: " _ $$$ISOK(tSC) _ "; "
        
        Set isActive = registry.IsActive("ED001")
        Set ^ClineDebug = ^ClineDebug _ "ED001 is active after set: " _ isActive _ " (should be 0); "
        
        // Check HasColleague
        Set hasColleague = registry.HasColleague("RAD001")
        Set ^ClineDebug = ^ClineDebug _ "Has RAD001: " _ hasColleague _ "; "
        
        // Deregister
        Set tSC = registry.DeregisterColleague("ED001")
        Set ^ClineDebug = ^ClineDebug _ "Deregister ED001: " _ $$$ISOK(tSC) _ "; "
        
        Set retrievedColleague = registry.GetColleague("ED001")
        Set ^ClineDebug = ^ClineDebug _ "Retrieved ED001 after deregister: '" _ retrievedColleague _ "' (should be empty); "
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.DisplayString() _ "; "
    }
    
    Quit $$$OK
}

/// Debug TestHospitalMediator
ClassMethod DebugHospitalMediator() As %Status
{
    Set ^ClineDebug = ^ClineDebug _ "=== TestHospitalMediator Debug ===; "
    
    Try {
        // Create hospital mediator
        Set mediator = ##class(Patterns.Examples.HospitalMediator).%New()
        Set ^ClineDebug = ^ClineDebug _ "Hospital mediator created: " _ $ISOBJECT(mediator) _ "; "
        
        // Create departments
        Set emergency = ##class(Patterns.Examples.EmergencyDepartment).%New()
        Set radiology = ##class(Patterns.Examples.RadiologyDepartment).%New()
        Set laboratory = ##class(Patterns.Examples.LaboratoryDepartment).%New()
        Set ^ClineDebug = ^ClineDebug _ "Departments created: " _ $ISOBJECT(emergency) _ "," _ $ISOBJECT(radiology) _ "," _ $ISOBJECT(laboratory) _ "; "
        
        // Register departments
        Set tSC = mediator.RegisterDepartment(emergency, "EMERGENCY")
        Set ^ClineDebug = ^ClineDebug _ "Register emergency: " _ $$$ISOK(tSC) _ "; "
        
        Set tSC = mediator.RegisterDepartment(radiology, "RADIOLOGY")
        Set ^ClineDebug = ^ClineDebug _ "Register radiology: " _ $$$ISOK(tSC) _ "; "
        
        Set tSC = mediator.RegisterDepartment(laboratory, "LABORATORY")
        Set ^ClineDebug = ^ClineDebug _ "Register laboratory: " _ $$$ISOK(tSC) _ "; "
        
        // Test patient transfer
        Set tSC = mediator.InitiatePatientTransfer("EMERGENCY", "RADIOLOGY", "PT12345", "URGENT")
        Set ^ClineDebug = ^ClineDebug _ "Patient transfer: " _ $$$ISOK(tSC) _ "; "
        
        // Test lab test request
        Set labData = {
            "patientId": "PT12345",
            "tests": ["CBC", "Chemistry Panel"],
            "priority": "STAT"
        }
        Set tSC = mediator.RequestLabTest("EMERGENCY", labData)
        Set ^ClineDebug = ^ClineDebug _ "Lab test request: " _ $$$ISOK(tSC) _ "; "
        
        // Test emergency broadcast
        Set tSC = mediator.BroadcastEmergency("EMERGENCY", "CODE_BLUE", "Room 123")
        Set ^ClineDebug = ^ClineDebug _ "Emergency broadcast: " _ $$$ISOK(tSC) _ " (expected 1); "
        
        // Check if error occurred
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "Error details: " _ $SYSTEM.Status.GetErrorText(tSC) _ "; "
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.DisplayString() _ "; "
    }
    
    Quit $$$OK
}

/// Run both debug tests
ClassMethod RunDebug() As %Status
{
    Do ..DebugColleagueRegistry()
    Do ..DebugHospitalMediator()
    Write !, "Debug info saved to ^ClineDebug", !
    Quit $$$OK
}

}
