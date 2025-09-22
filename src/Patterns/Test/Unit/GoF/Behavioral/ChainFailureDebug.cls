/// Debug helper for Chain of Responsibility failing tests
Class Patterns.Test.Unit.GoF.Behavioral.ChainFailureDebug Extends %RegisteredObject
{

/// Debug TestChainFormation issue
ClassMethod DebugChainFormation() As %Status
{
    Set tSC = $$$OK
    
    // Clear debug global
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "=== TestChainFormation Debug ===; "
    
    Try {
        // Replicate test code
        Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
        Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
        Set tDeptHead = ##class(Patterns.Examples.DepartmentHeadApprovalHandler).%New()
        Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()
        
        Do tNurse.SetNext(tDoctor)
        Do tDoctor.SetNext(tDeptHead)
        Do tDeptHead.SetNext(tAdmin)
        
        // Test assertions
        Set ^ClineDebug = ^ClineDebug _ "tNurse.NextHandler is object: " _ $IsObject(tNurse.NextHandler) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "tNurse.NextHandler.HandlerName: " _ tNurse.NextHandler.HandlerName _ "; "
        Set chainLength = tNurse.GetChainLength()
        Set ^ClineDebug = ^ClineDebug _ "GetChainLength result: " _ chainLength _ "; "
        Set chainInfo = tNurse.GetChainInfo()
        Set ^ClineDebug = ^ClineDebug _ "GetChainInfo result: " _ chainInfo _ "; "
        
        // Test validation
        Set tSC = tNurse.ValidateChain()
        Set ^ClineDebug = ^ClineDebug _ "ValidateChain status: " _ $Select($$$ISOK(tSC):"OK", 1:"ERROR: " _ $System.Status.GetErrorText(tSC)) _ "; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.Name _ " at " _ ex.Location _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Debug TestHealthcareApprovalScenarios issue
ClassMethod DebugHealthcareScenarios() As %Status
{
    Set tSC = $$$OK
    
    // Append to debug global
    Set ^ClineDebug = ^ClineDebug _ "=== TestHealthcareApprovalScenarios Debug ===; "
    
    Try {
        // Build full chain using helper
        Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
        Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
        Set tDeptHead = ##class(Patterns.Examples.DepartmentHeadApprovalHandler).%New()
        Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()
        
        Do tNurse.SetNext(tDoctor)
        Do tDoctor.SetNext(tDeptHead)
        Do tDeptHead.SetNext(tAdmin)
        
        Set tChain = tNurse
        
        // Test 1: Small amount - Nurse approval (400)
        Set tRequest1 = ##class(Patterns.Examples.ApprovalRequest).CreateTestRequest("Medication", 400)
        Set ^ClineDebug = ^ClineDebug _ "Test1: Created request for $400; "
        Set tResponse1 = tChain.HandleRequest(tRequest1)
        Set ^ClineDebug = ^ClineDebug _ "Response1 HandledBy: " _ tResponse1.HandledBy _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Expected: Nurse; "
        
        // Test 2: Medium amount - Doctor approval (8000)
        Set tRequest2 = ##class(Patterns.Examples.ApprovalRequest).CreateTestRequest("Equipment", 8000)
        Set ^ClineDebug = ^ClineDebug _ "Test2: Created request for $8000; "
        Set tResponse2 = tChain.HandleRequest(tRequest2)
        Set ^ClineDebug = ^ClineDebug _ "Response2 HandledBy: " _ tResponse2.HandledBy _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Expected: Doctor; "
        
        // Test 3: Large amount - Department Head approval (40000)
        Set tRequest3 = ##class(Patterns.Examples.ApprovalRequest).CreateTestRequest("Budget", 40000)
        Set ^ClineDebug = ^ClineDebug _ "Test3: Created request for $40000; "
        Set tResponse3 = tChain.HandleRequest(tRequest3)
        Set ^ClineDebug = ^ClineDebug _ "Response3 HandledBy: " _ tResponse3.HandledBy _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Expected: DepartmentHead; "
        
        // Test 4: Very large amount - Administrator approval (150000)
        Set tRequest4 = ##class(Patterns.Examples.ApprovalRequest).CreateTestRequest("Budget", 150000)
        Do tRequest4.ApprovedBy.Insert("PreApproval")
        Set ^ClineDebug = ^ClineDebug _ "Test4: Created request for $150000; "
        Set tResponse4 = tChain.HandleRequest(tRequest4)
        Set ^ClineDebug = ^ClineDebug _ "Response4 HandledBy: " _ tResponse4.HandledBy _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Expected: Administrator; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.Name _ " at " _ ex.Location _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Debug TestEmergencyApproval issue
ClassMethod DebugEmergencyApproval() As %Status
{
    Set tSC = $$$OK
    
    // Append to debug global
    Set ^ClineDebug = ^ClineDebug _ "=== TestEmergencyApproval Debug ===; "
    
    Try {
        // Build full chain
        Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
        Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
        Set tDeptHead = ##class(Patterns.Examples.DepartmentHeadApprovalHandler).%New()
        Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()
        
        Do tNurse.SetNext(tDoctor)
        Do tDoctor.SetNext(tDeptHead)
        Do tDeptHead.SetNext(tAdmin)
        
        Set tChain = tNurse
        
        // Create emergency request
        Set tRequest = ##class(Patterns.Examples.ApprovalRequest).%New()
        Set tRequest.ApprovalType = "Emergency"
        Set tRequest.Amount = 75000
        Set tRequest.Priority = 4
        Set tRequest.Department = "Emergency"
        Set tRequest.Reason = "Critical emergency procedure"
        Set tRequest.IsUrgent = 1
        Set tRequest.Initiator = "EmergencyDoctor"
        
        Set ^ClineDebug = ^ClineDebug _ "Created emergency request for $75000; "
        
        // Process emergency
        Set tResponse = tChain.HandleRequest(tRequest)
        
        Set ^ClineDebug = ^ClineDebug _ "Response IsSuccess: " _ tResponse.IsSuccess() _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Response HandledBy: " _ tResponse.HandledBy _ "; "
        
        // Check metadata
        If $IsObject(tResponse) {
            Set fastTrack = tResponse.GetMetadata("fastTrack")
            Set ^ClineDebug = ^ClineDebug _ "FastTrack metadata: '" _ fastTrack _ "'; "
        }
        
        Set ^ClineDebug = ^ClineDebug _ "ApprovalConditions count: " _ tRequest.ApprovalConditions.Count() _ "; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.Name _ " at " _ ex.Location _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Debug TestCircularChainPrevention issue
ClassMethod DebugCircularPrevention() As %Status
{
    Set tSC = $$$OK
    
    // Append to debug global
    Set ^ClineDebug = ^ClineDebug _ "=== TestCircularChainPrevention Debug ===; "
    
    Try {
        // Create handlers
        Set tHandler1 = ##class(Patterns.GoF.Behavioral.ConcreteHandler).%New("Handler1", 10)
        Set tHandler2 = ##class(Patterns.GoF.Behavioral.ConcreteHandler).%New("Handler2", 20)
        Set tHandler3 = ##class(Patterns.GoF.Behavioral.ConcreteHandler).%New("Handler3", 30)
        
        // Create valid chain
        Do tHandler1.SetNext(tHandler2)
        Do tHandler2.SetNext(tHandler3)
        
        Set ^ClineDebug = ^ClineDebug _ "Created chain: H1->H2->H3; "
        
        // Try to create circular reference
        Do tHandler3.SetNext(tHandler1)
        
        Set ^ClineDebug = ^ClineDebug _ "Added circular: H3->H1; "
        
        // Validate chain (should detect circular reference)
        Set tSC = tHandler1.ValidateChain()
        
        Set ^ClineDebug = ^ClineDebug _ "ValidateChain status: " _ $Select($$$ISOK(tSC):"OK (PROBLEM!)", 1:"ERROR") _ "; "
        If $$$ISERR(tSC) {
            Set errorText = $System.Status.GetErrorText(tSC)
            Set ^ClineDebug = ^ClineDebug _ "Error text: " _ errorText _ "; "
            Set hasCircular = errorText [ "Circular"
            Set ^ClineDebug = ^ClineDebug _ "Contains 'Circular': " _ hasCircular _ "; "
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.Name _ " at " _ ex.Location _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Run all debugs
ClassMethod DebugAll() As %Status
{
    Set tSC = $$$OK
    
    Set ^ClineDebug = ""
    
    Do ..DebugChainFormation()
    Do ..DebugHealthcareScenarios()
    Do ..DebugEmergencyApproval()
    Do ..DebugCircularPrevention()
    
    Set ^ClineDebug = ^ClineDebug _ "=== Debug Complete ===; "
    
    Quit tSC
}

}
