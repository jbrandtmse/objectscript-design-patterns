/// Unit tests for Chain of Responsibility Pattern Implementation
/// 
/// Tests cover:
/// - Basic chain formation and traversal
/// - Request handling with different configurations
/// - Dynamic chain modification
/// - Error handling and recovery
/// - Healthcare approval workflow scenarios
/// 
/// @see Patterns.GoF.Behavioral.Handler
/// @see Patterns.GoF.Behavioral.ChainBuilder
/// @see Patterns.Examples.ApprovalRequest
/// @since 1.0.0
Class Patterns.Test.Unit.GoF.Behavioral.ChainOfResponsibilityTest Extends %UnitTest.TestCase
{

/// Test basic chain formation
Method TestChainFormation()
{
    // Create handlers
    Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
    Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
    Set tDeptHead = ##class(Patterns.Examples.DepartmentHeadApprovalHandler).%New()
    Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()
    
    // Build chain manually
    Do tNurse.SetNext(tDoctor)
    Do tDoctor.SetNext(tDeptHead)
    Do tDeptHead.SetNext(tAdmin)
    
    // Verify chain formation
    Do $$$AssertTrue($IsObject(tNurse.NextHandler), "Nurse has next handler")
    Do $$$AssertEquals(tNurse.NextHandler.HandlerName, "Doctor", "Nurse next is Doctor")
    Do $$$AssertEquals(tNurse.GetChainLength(), 4, "Chain has 4 handlers")
    Do $$$AssertTrue(tNurse.GetChainInfo() [ "Administrator", "Chain contains Administrator")
    
    // Test chain validation
    Set tSC = tNurse.ValidateChain()
    Do $$$AssertStatusOK(tSC, "Chain validation succeeds")
}

/// Test request handling with simple chain
Method TestSimpleRequestHandling()
{
    // Create simple chain: Nurse -> Doctor
    Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
    Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
    Do tNurse.SetNext(tDoctor)
    
    // Create request within nurse limit
    Set tRequest = ##class(Patterns.Examples.ApprovalRequest).%New("Medication", 300, 1)
    Set tRequest.Department = "Cardiology"
    Set tRequest.Reason = "Standard medication approval"
    Set tRequest.Initiator = "TestUser"
    
    // Process request
    Set tResponse = tNurse.HandleRequest(tRequest)
    
    // Verify response
    Do $$$AssertTrue($IsObject(tResponse), "Response object created")
    Do $$$AssertTrue(tResponse.IsSuccess(), "Request approved")
    Do $$$AssertEquals(tResponse.HandledBy, "Nurse", "Handled by Nurse")
    Do $$$AssertEquals(tRequest.ApprovalStatus, "Approved", "Request status is Approved")
}

/// Test request escalation through chain
Method TestRequestEscalation()
{
    // Build full chain
    Set tChain = ..BuildFullChain()
    
    // Create request beyond nurse but within doctor limit
    Set tRequest = ##class(Patterns.Examples.ApprovalRequest).%New("Procedure", 5000, 2)
    Set tRequest.Department = "Surgery"
    Set tRequest.PatientId = "PAT-12345"
    Set tRequest.Reason = "Minor surgical procedure"
    Set tRequest.Initiator = "TestDoctor"
    
    // Process request
    Set tResponse = tChain.HandleRequest(tRequest)
    
    // Verify escalation
    Do $$$AssertTrue(tResponse.IsSuccess(), "Request approved after escalation")
    Do $$$AssertEquals(tResponse.HandledBy, "Doctor", "Handled by Doctor")
    Do $$$AssertTrue(tRequest.ApprovedBy.Count() > 0, "Has approvers")
}

/// Test dynamic chain modification with ChainBuilder
Method TestDynamicChainBuilder()
{
    // Use ChainBuilder
    Set tBuilder = ##class(Patterns.GoF.Behavioral.ChainBuilder).%New()
    
    // Register handler classes
    Do tBuilder.RegisterHandlerClass("Nurse", "Patterns.Examples.NurseApprovalHandler")
    Do tBuilder.RegisterHandlerClass("Doctor", "Patterns.Examples.DoctorApprovalHandler")
    Do tBuilder.RegisterHandlerClass("Admin", "Patterns.Examples.AdministratorApprovalHandler")
    
    // Add handlers by name with configuration
    Set tConfig1 = ##class(%DynamicObject).%New()
    Set tConfig1.priority = 10
    Set tConfig1.enabled = 1
    Do tBuilder.AddHandlerByName("Nurse", tConfig1)
    
    Set tConfig2 = ##class(%DynamicObject).%New()
    Set tConfig2.priority = 20
    Set tConfig2.enabled = 1
    Do tBuilder.AddHandlerByName("Doctor", tConfig2)
    
    Set tConfig3 = ##class(%DynamicObject).%New()
    Set tConfig3.priority = 30
    Set tConfig3.enabled = 1
    Do tBuilder.AddHandlerByName("Admin", tConfig3)
    
    // Build chain
    Set tChain = tBuilder.Build()
    
    // Verify chain
    Do $$$AssertTrue($IsObject(tChain), "Chain built successfully")
    Do $$$AssertEquals(tChain.HandlerName, "Nurse", "First handler is Nurse (sorted by priority)")
    Do $$$AssertEquals(tChain.GetChainLength(), 3, "Chain has 3 handlers")
}

/// Test error handler with circuit breaker
Method TestErrorHandler()
{
    // Create error handler with retry strategy
    Set tErrorHandler = ##class(Patterns.GoF.Behavioral.ErrorHandler).%New("", "RETRY")
    Set tErrorHandler.RetryAttempts = 2
    Set tErrorHandler.RetryDelay = 0  // No delay for testing
    
    // Create request with error context
    Set tRequest = ##class(Patterns.GoF.Behavioral.Request).%New("Error", "Test error")
    Do tRequest.SetContext("error", "Simulated error")
    Do tRequest.SetContext("errorType", "TestError")
    Do tRequest.SetContext("originalHandler", "Patterns.Examples.NurseApprovalHandler")
    
    // Process error
    Set tResponse = tErrorHandler.HandleRequest(tRequest)
    
    // Verify error handling
    Do $$$AssertTrue($IsObject(tResponse), "Error response created")
    Do $$$AssertEquals(tErrorHandler.CircuitState, "CLOSED", "Circuit still closed")
}

/// Test circular chain prevention
Method TestCircularChainPrevention()
{
    // Create handlers
    Set tHandler1 = ##class(Patterns.GoF.Behavioral.ConcreteHandler).%New("Handler1", 10)
    Set tHandler2 = ##class(Patterns.GoF.Behavioral.ConcreteHandler).%New("Handler2", 20)
    Set tHandler3 = ##class(Patterns.GoF.Behavioral.ConcreteHandler).%New("Handler3", 30)
    
    // Create valid chain
    Do tHandler1.SetNext(tHandler2)
    Do tHandler2.SetNext(tHandler3)
    
    // Try to create circular reference
    Do tHandler3.SetNext(tHandler1)
    
    // Validate chain (should detect circular reference)
    Set tSC = tHandler1.ValidateChain()
    Do $$$AssertStatusNotOK(tSC, "Circular chain detected")
    Do $$$AssertTrue($System.Status.GetErrorText(tSC) [ "Circular", "Error mentions circular reference")
}

/// Test handler priority and ordering
Method TestHandlerPriorityOrdering()
{
    Set tBuilder = ##class(Patterns.GoF.Behavioral.ChainBuilder).%New()
    
    // Add handlers in random order
    Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()
    Do tBuilder.AddHandler(tAdmin)  // Priority 40
    
    Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
    Do tBuilder.AddHandler(tNurse)  // Priority 10
    
    Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
    Do tBuilder.AddHandler(tDoctor)  // Priority 20
    
    // Build with sorting
    Set tBuilder.SortByPriority = 1
    Set tChain = tBuilder.Build()
    
    // Verify ordering
    Do $$$AssertEquals(tChain.HandlerName, "Nurse", "First is Nurse (priority 10)")
    Do $$$AssertEquals(tChain.NextHandler.HandlerName, "Doctor", "Second is Doctor (priority 20)")
    Do $$$AssertEquals(tChain.NextHandler.NextHandler.HandlerName, "Administrator", "Third is Administrator (priority 40)")
}

/// Test healthcare approval with different amounts
Method TestHealthcareApprovalScenarios()
{
    Set tChain = ..BuildFullChain()
    
    // Test 1: Small amount - Nurse approval
    Set tRequest1 = ##class(Patterns.Examples.ApprovalRequest).CreateTestRequest("Medication", 400)
    Set tResponse1 = tChain.HandleRequest(tRequest1)
    Do $$$AssertEquals(tResponse1.HandledBy, "Nurse", "Small amount handled by Nurse")
    
    // Test 2: Medium amount - Doctor approval
    Set tRequest2 = ##class(Patterns.Examples.ApprovalRequest).CreateTestRequest("Equipment", 8000)
    Set tResponse2 = tChain.HandleRequest(tRequest2)
    Do $$$AssertEquals(tResponse2.HandledBy, "Doctor", "Medium amount handled by Doctor")
    
    // Test 3: Large amount - Department Head approval
    Set tRequest3 = ##class(Patterns.Examples.ApprovalRequest).CreateTestRequest("Budget", 40000)
    Set tResponse3 = tChain.HandleRequest(tRequest3)
    Do $$$AssertEquals(tResponse3.HandledBy, "DepartmentHead", "Large amount handled by Department Head")
    
    // Test 4: Very large amount - Administrator approval
    Set tRequest4 = ##class(Patterns.Examples.ApprovalRequest).CreateTestRequest("Budget", 150000)
    Set tRequest4.ApprovedBy.Insert("PreApproval")  // Simulate pre-approval
    Set tResponse4 = tChain.HandleRequest(tRequest4)
    Do $$$AssertEquals(tResponse4.HandledBy, "Administrator", "Very large amount handled by Administrator")
}

/// Test approval delegation and conditions
Method TestApprovalDelegation()
{
    // Create doctor handler with delegation
    Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
    
    // Delegate to another doctor
    Set tSC = tDoctor.DelegateApproval("DR-9999")
    Do $$$AssertStatusOK(tSC, "Delegation successful")
    Do $$$AssertEquals(tDoctor.Enabled, 0, "Handler disabled after delegation")
    Do $$$AssertEquals(tDoctor.GetConfig("delegatedTo"), "DR-9999", "Delegation recorded")
}

/// Test request validation and rejection
Method TestRequestValidationAndRejection()
{
    Set tChain = ..BuildFullChain()
    
    // Create invalid request (missing required fields)
    Set tRequest = ##class(Patterns.Examples.ApprovalRequest).%New("Medication", 500, 1)
    // Missing Department and Reason - required fields
    
    Set tResponse = tChain.HandleRequest(tRequest)
    Do $$$AssertTrue(tResponse.IsFailure(), "Invalid request rejected")
    Do $$$AssertTrue((tResponse.Message [ "Validation failed"), "Validation error in message")
}

/// Test emergency approval fast-track
Method TestEmergencyApproval()
{
    Set tChain = ..BuildFullChain()
    
    // Create emergency request
    Set tRequest = ##class(Patterns.Examples.ApprovalRequest).%New("Emergency", 75000, 4)
    Set tRequest.Department = "Emergency"
    Set tRequest.Reason = "Critical emergency procedure"
    Set tRequest.IsUrgent = 1
    Set tRequest.Initiator = "EmergencyDoctor"
    
    // Process emergency
    Set tResponse = tChain.HandleRequest(tRequest)
    
    // Verify fast-track approval
    Do $$$AssertTrue(tResponse.IsSuccess(), "Emergency approved")
    Do $$$AssertTrue(tResponse.GetMetadata("fastTrack") '= "", "Fast-track metadata present")
    Do $$$AssertTrue(tRequest.ApprovalConditions.Count() > 0, "Conditions attached to emergency approval")
}

/// Test chain removal and modification
Method TestChainModification()
{
    // Build chain
    Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
    Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
    Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()
    
    Do tNurse.SetNext(tDoctor)
    Do tDoctor.SetNext(tAdmin)
    
    // Remove doctor from chain
    Set tRemoved = tNurse.RemoveFromChain("Patterns.Examples.DoctorApprovalHandler")
    Do $$$AssertTrue(tRemoved, "Handler removed successfully")
    Do $$$AssertEquals(tNurse.NextHandler.HandlerName, "Administrator", "Chain updated correctly")
    
    // Insert new handler
    Set tDeptHead = ##class(Patterns.Examples.DepartmentHeadApprovalHandler).%New()
    Do tNurse.InsertAfter(tDeptHead)
    Do $$$AssertEquals(tNurse.NextHandler.HandlerName, "DepartmentHead", "Handler inserted successfully")
}

/// Test JSON configuration loading
Method TestJSONConfiguration()
{
    // Create JSON configuration using dynamic objects
    Set tConfig = ##class(%DynamicObject).%New()
    Set tConfig.sortByPriority = 1
    
    // Create registry object
    Set tRegistry = ##class(%DynamicObject).%New()
    Set tRegistry.Nurse = "Patterns.Examples.NurseApprovalHandler"
    Set tRegistry.Doctor = "Patterns.Examples.DoctorApprovalHandler"
    Set tConfig.registry = tRegistry
    
    // Create handlers array
    Set tHandlers = ##class(%DynamicArray).%New()
    
    // First handler
    Set tHandler1 = ##class(%DynamicObject).%New()
    Set tHandler1.type = "Nurse"
    Set tHandler1.priority = 10
    Set tHandler1.enabled = 1
    Set tHandler1.maxRequests = 100
    Do tHandlers.%Push(tHandler1)
    
    // Second handler
    Set tHandler2 = ##class(%DynamicObject).%New()
    Set tHandler2.type = "Doctor"
    Set tHandler2.priority = 20
    Set tHandler2.enabled = 1
    Set tHandler2.maxRequests = 50
    Do tHandlers.%Push(tHandler2)
    
    Set tConfig.handlers = tHandlers
    
    // Build from JSON
    Set tChain = ##class(Patterns.GoF.Behavioral.ChainBuilder).BuildFromJSON(tConfig)
    
    // Verify chain
    Do $$$AssertTrue($IsObject(tChain), "Chain built from JSON")
    Do $$$AssertEquals(tChain.HandlerName, "Nurse", "First handler correct")
    Do $$$AssertTrue($IsObject(tChain.NextHandler), "Has next handler")
}

/// Test approval statistics
Method TestApprovalStatistics()
{
    // Clear previous logs
    Kill ^Patterns.Chain.ExecutiveLog
    
    // Create some test approvals
    Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()
    
    // Simulate approvals and rejections
    For i=1:1:5 {
        Set tRequest = ##class(Patterns.Examples.ApprovalRequest).CreateTestRequest("Budget", 50000 * i)
        Set tRequest.ApprovedBy.Insert("PreApproval")  // Ensure it goes to admin
        
        If i # 2 = 0 {
            Do tAdmin.LogExecutiveApproval(tRequest)
        } Else {
            Do tAdmin.LogExecutiveRejection(tRequest, "Test rejection")
        }
    }
    
    // Get statistics
    Set tStats = ##class(Patterns.Examples.AdministratorApprovalHandler).GetApprovalStatistics()
    
    // Verify statistics
    Do $$$AssertEquals(tStats."totalDecisions", 5, "Total decisions tracked")
    Do $$$AssertEquals(tStats.approved, 2, "Approved count correct")
    Do $$$AssertEquals(tStats.rejected, 3, "Rejected count correct")
}

/// Helper method to build full approval chain
Method BuildFullChain() As Patterns.GoF.Behavioral.Handler [ Private ]
{
    Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
    Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
    Set tDeptHead = ##class(Patterns.Examples.DepartmentHeadApprovalHandler).%New()
    Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()
    
    Do tNurse.SetNext(tDoctor)
    Do tDoctor.SetNext(tDeptHead)
    Do tDeptHead.SetNext(tAdmin)
    
    Quit tNurse
}

/// Clean up after tests
Method OnAfterOneTest() As %Status
{
    // Clean up test data
    Kill ^Patterns.Chain.ErrorLog
    Kill ^Patterns.Chain.ExecutiveLog
    Kill ^Patterns.Chain.DepartmentBudget
    Kill ^Patterns.Chain.Escalations
    
    Quit $$$OK
}

}
