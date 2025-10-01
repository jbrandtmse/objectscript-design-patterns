/// Unit Tests for Visitor Pattern Implementation
/// 
/// This test class validates the Visitor pattern implementation including:
/// - Basic visitor acceptance and double dispatch
/// - Healthcare medical record analysis example
/// - Visitor state accumulation and result aggregation
/// - Error handling and edge cases
/// 
/// @see Patterns.GoF.Behavioral.Visitor
/// @see Patterns.Examples.AuditVisitor
/// @since 1.0.0
Class Patterns.Test.Unit.GoF.Behavioral.VisitorTest Extends %UnitTest.TestCase
{

/// Test basic visitor acceptance by elements
Method TestBasicVisitorAcceptance() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting TestBasicVisitorAcceptance; "
    
    Set tSC = $$$OK
    Try {
        // Arrange
        Set tVisitor = ##class(Patterns.GoF.Behavioral.ConcreteVisitor).%New()
        Set tElementA = ##class(Patterns.GoF.Behavioral.ConcreteElementA).%New()
        Set tElementB = ##class(Patterns.GoF.Behavioral.ConcreteElementB).%New()
        Set tElementC = ##class(Patterns.GoF.Behavioral.ConcreteElementC).%New()
        
        Do tElementA.SetOperationData("Test Data A")
        Do tElementB.SetValue(42)
        Do tElementB.SetStatus("Active")
        Do tElementC.SetName("Test Container")
        
        Set ^ClineDebug = ^ClineDebug_"Elements created and configured; "
        
        // Act
        Do tVisitor.Initialize()
        Set tSC1 = tElementA.Accept(tVisitor)
        Set tSC2 = tElementB.Accept(tVisitor) 
        Set tSC3 = tElementC.Accept(tVisitor)
        Do tVisitor.Finalize()
        
        Set ^ClineDebug = ^ClineDebug_"Visitor operations completed; "
        
        // Assert
        Do $$$AssertStatusOK(tSC1, "ElementA should accept visitor successfully")
        Do $$$AssertStatusOK(tSC2, "ElementB should accept visitor successfully")
        Do $$$AssertStatusOK(tSC3, "ElementC should accept visitor successfully")
        Do $$$AssertEquals(tVisitor.GetVisitCount(), 3, "Visitor should have visited 3 elements")
        Do $$$AssertTrue(tVisitor.HasResults(), "Visitor should have accumulated results")
        
        Set tResult = tVisitor.GetResult()
        Do $$$AssertTrue(tResult '= "", "Visitor result should not be empty")
        Do $$$AssertTrue($FIND(tResult, "Test Data A") > 0, "Result should contain ElementA data")
        Do $$$AssertTrue($FIND(tResult, "42") > 0, "Result should contain ElementB value")
        Do $$$AssertTrue($FIND(tResult, "Test Container") > 0, "Result should contain ElementC name")
        
        Set ^ClineDebug = ^ClineDebug_"All assertions passed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit tSC
}

/// Test double dispatch mechanism
Method TestDoubleDispatchMechanism() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting TestDoubleDispatchMechanism; "
    
    Set tSC = $$$OK
    Try {
        // Arrange
        Set tVisitor = ##class(Patterns.GoF.Behavioral.ConcreteVisitor).%New()
        Set tElementA = ##class(Patterns.GoF.Behavioral.ConcreteElementA).%New()
        Set tElementB = ##class(Patterns.GoF.Behavioral.ConcreteElementB).%New()
        
        Do tElementA.SetOperationData("DoubleDispatch Test")
        Do tElementB.SetValue(123)
        Do tElementB.SetStatus("Testing")
        
        // Act
        Do tVisitor.ClearResults()
        Set tSC1 = tElementA.Accept(tVisitor)
        Set tSC2 = tElementB.Accept(tVisitor)
        
        // Assert - verify that appropriate visitor methods were called
        Set tResult = tVisitor.GetResult()
        Do $$$AssertStatusOK(tSC1, "ElementA acceptance should succeed")
        Do $$$AssertStatusOK(tSC2, "ElementB acceptance should succeed")
        
        // Verify that different element types triggered different visitor methods
        Do $$$AssertTrue($FIND(tResult, "Processing ElementA") > 0, "Should show ElementA processing")
        Do $$$AssertTrue($FIND(tResult, "Processing ElementB") > 0, "Should show ElementB processing")
        Do $$$AssertTrue($FIND(tResult, "Value=123") > 0, "Should show ElementB-specific data")
        
        Set ^ClineDebug = ^ClineDebug_"Double dispatch verification completed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit tSC
}

/// Test healthcare medical record audit visitor
Method TestHealthcareAuditVisitor() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting TestHealthcareAuditVisitor; "
    
    Set tSC = $$$OK
    Try {
        // Arrange
        Set tAuditVisitor = ##class(Patterns.Examples.AuditVisitor).%New()
        Do tAuditVisitor.SetAuditor("TEST_AUDITOR_123")
        
        Set tPatient = ##class(Patterns.Examples.OutpatientRecord).%New()
        Do tPatient.SetPatientInfo("PAT123", "John", "Doe", "1980-01-15")
        Set tPatient.Gender = "M"
        Set tPatient.InsuranceId = "INS456"
        Set tPatient.CreatedBy = "DR_SMITH"
        Do tPatient.AddDiagnosisCode("Z00.00")
        Do tPatient.AddMedication("Aspirin 81mg daily")
        Do tPatient.AddAllergy("Penicillin")
        
        Set ^ClineDebug = ^ClineDebug_"Patient record created and populated; "
        
        // Act
        Do tAuditVisitor.Initialize()
        Set tSC = tPatient.Accept(tAuditVisitor)
        Do tAuditVisitor.Finalize()
        
        // Assert
        Do $$$AssertStatusOK(tSC, "Patient record should accept audit visitor")
        Do $$$AssertEquals(tAuditVisitor.GetViolationCount(), 0, "Complete patient record should have no violations")
        Do $$$AssertTrue(tAuditVisitor.IsAuditPassed(), "Audit should pass for complete record")
        
        Set tReport = tAuditVisitor.GetAuditReport()
        Do $$$AssertTrue(tReport '= "", "Audit report should not be empty")
        Do $$$AssertTrue($FIND(tReport, "PAT123") > 0, "Report should contain patient ID")
        Do $$$AssertTrue($FIND(tReport, "COMPLIANT") > 0, "Report should show compliance")
        
        Set ^ClineDebug = ^ClineDebug_"Healthcare audit test completed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit tSC
}

/// Test audit visitor with violations
Method TestAuditVisitorWithViolations() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting TestAuditVisitorWithViolations; "
    
    Set tSC = $$$OK
    Try {
        // Arrange - create incomplete patient record
        Set tAuditVisitor = ##class(Patterns.Examples.AuditVisitor).%New()
        Do tAuditVisitor.SetAuditor("TEST_AUDITOR_456")
        
        Set tPatient = ##class(Patterns.Examples.OutpatientRecord).%New()
        // Deliberately leave out required information to trigger violations
        Set tPatient.PatientId = "PAT456"
        // Missing FirstName, LastName, DateOfBirth
        
        // Act
        Do tAuditVisitor.Initialize()
        Set tSC = tPatient.Accept(tAuditVisitor)
        Do tAuditVisitor.Finalize()
        
        // Assert
        Do $$$AssertStatusOK(tSC, "Audit should complete even with violations")
        Do $$$AssertTrue(tAuditVisitor.GetViolationCount() > 0, "Should find violations in incomplete record")
        Do $$$AssertTrue('tAuditVisitor.IsAuditPassed(), "Audit should fail for incomplete record")
        
        Set tReport = tAuditVisitor.GetAuditReport()
        Do $$$AssertTrue($FIND(tReport, "VIOLATION") > 0, "Report should contain violation notices")
        
        Set ^ClineDebug = ^ClineDebug_"Violation testing completed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit tSC
}

/// Test composite element structure traversal
Method TestCompositeElementTraversal() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting TestCompositeElementTraversal; "
    
    Set tSC = $$$OK
    Try {
        // Arrange - create composite structure
        Set tVisitor = ##class(Patterns.GoF.Behavioral.ConcreteVisitor).%New()
        Set tComposite = ##class(Patterns.GoF.Behavioral.ConcreteElementC).%New()
        Set tChildA = ##class(Patterns.GoF.Behavioral.ConcreteElementA).%New()
        Set tChildB = ##class(Patterns.GoF.Behavioral.ConcreteElementB).%New()
        
        Do tComposite.SetName("Parent Container")
        Do tChildA.SetOperationData("Child A Data")
        Do tChildB.SetValue(999)
        Do tChildB.SetStatus("Child")
        
        Do tComposite.AddChild(tChildA)
        Do tComposite.AddChild(tChildB)
        
        Set ^ClineDebug = ^ClineDebug_"Composite structure created; "
        
        // Act
        Do tVisitor.Initialize()
        Set tSC = tComposite.Accept(tVisitor)  // Should visit composite and all children
        Do tVisitor.Finalize()
        
        // Assert
        Do $$$AssertStatusOK(tSC, "Composite traversal should succeed")
        Do $$$AssertEquals(tVisitor.GetVisitCount(), 3, "Should visit composite + 2 children = 3 elements")
        
        Set tResult = tVisitor.GetResult()
        Do $$$AssertTrue($FIND(tResult, "Parent Container") > 0, "Should visit the composite")
        Do $$$AssertTrue($FIND(tResult, "Child A Data") > 0, "Should visit child A")
        Do $$$AssertTrue($FIND(tResult, "999") > 0, "Should visit child B")
        
        Set ^ClineDebug = ^ClineDebug_"Composite traversal test completed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit tSC
}

/// Test visitor state accumulation
Method TestVisitorStateAccumulation() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting TestVisitorStateAccumulation; "
    
    Set tSC = $$$OK
    Try {
        // Arrange
        Set tVisitor = ##class(Patterns.GoF.Behavioral.ConcreteVisitor).%New()
        Set tElementA1 = ##class(Patterns.GoF.Behavioral.ConcreteElementA).%New()
        Set tElementA2 = ##class(Patterns.GoF.Behavioral.ConcreteElementA).%New()
        Set tElementB1 = ##class(Patterns.GoF.Behavioral.ConcreteElementB).%New()
        
        Do tElementA1.SetOperationData("First A")
        Do tElementA2.SetOperationData("Second A")
        Do tElementB1.SetValue(100)
        
        // Act - visit multiple elements and accumulate state
        Do tVisitor.Initialize()
        Do tElementA1.Accept(tVisitor)
        Do tElementA2.Accept(tVisitor)
        Do tElementB1.Accept(tVisitor)
        Do tVisitor.Finalize()
        
        // Assert
        Do $$$AssertEquals(tVisitor.GetVisitCount(), 3, "Should accumulate visit count correctly")
        
        Set tResult = tVisitor.GetResult()
        Do $$$AssertTrue($FIND(tResult, "First A") > 0, "Should contain first element data")
        Do $$$AssertTrue($FIND(tResult, "Second A") > 0, "Should contain second element data")
        Do $$$AssertTrue($FIND(tResult, "100") > 0, "Should contain third element data")
        
        Set ^ClineDebug = ^ClineDebug_"State accumulation test completed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit tSC
}

/// Test error handling in visitor operations
Method TestVisitorErrorHandling() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting TestVisitorErrorHandling; "
    
    Set tSC = $$$OK
    Try {
        // Arrange
        Set tVisitor = ##class(Patterns.GoF.Behavioral.ConcreteVisitor).%New()
        Set tElement = ##class(Patterns.GoF.Behavioral.ConcreteElementA).%New()
        
        // Act & Assert - test that visitor handles normal operations
        Set tSC = tElement.Accept(tVisitor)
        Do $$$AssertStatusOK(tSC, "Normal visitor operation should succeed")
        
        // Test visitor initialization and finalization
        Set tSC1 = tVisitor.Initialize()
        Set tSC2 = tVisitor.Finalize()
        Do $$$AssertStatusOK(tSC1, "Visitor initialization should succeed")
        Do $$$AssertStatusOK(tSC2, "Visitor finalization should succeed")
        
        Set ^ClineDebug = ^ClineDebug_"Error handling test completed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit tSC
}

/// Test visitor pattern with patient demographics
Method TestPatientDemographics() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting TestPatientDemographics; "
    
    Set tSC = $$$OK
    Try {
        // Arrange
        Set tPatient = ##class(Patterns.Examples.OutpatientRecord).%New()
        Do tPatient.SetPatientInfo("PAT789", "Jane", "Smith", "1995-06-20")
        Set tPatient.Gender = "F"
        
        // Act & Assert
        Do $$$AssertEquals(tPatient.GetFullName(), "Jane Smith", "Should return correct full name")
        Do $$$AssertTrue(tPatient.GetAge() >= 28, "Should calculate age correctly")  // As of 2025
        Do $$$AssertTrue('tPatient.IsMinor(), "Patient born in 1995 should not be a minor")
        
        Set tDemo = tPatient.GetDemographics()
        Do $$$AssertTrue($IsObject(tDemo), "Should return demographics object")
        Do $$$AssertEquals(tDemo.%Get("patientId"), "PAT789", "Demographics should contain patient ID")
        Do $$$AssertEquals(tDemo.%Get("fullName"), "Jane Smith", "Demographics should contain full name")
        
        Set ^ClineDebug = ^ClineDebug_"Patient demographics test completed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit tSC
}

/// Test record validation
Method TestRecordValidation() As %Status
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting TestRecordValidation; "
    
    Set tSC = $$$OK
    Try {
        // Test valid patient record
        Set tPatient = ##class(Patterns.Examples.OutpatientRecord).%New()
        Do tPatient.SetPatientInfo("PAT999", "Bob", "Johnson", "1975-12-25")
        Set tPatient.Gender = "M"
        // Set required OutpatientRecord fields
        Set tPatient.VisitType = "Follow-up"
        Set tPatient.Department = "Primary Care"
        Set tPatient.AttendingProvider = "Dr. Smith"
        Set tPatient.VisitReason = "Routine checkup"
        Set tPatient.AppointmentTime = $ZTime($Horolog, 1)  // Set appointment time for scheduled visit
        
        Set tSC = tPatient.ValidateRecord()
        Do $$$AssertStatusOK(tSC, "Valid patient record should pass validation")
        
        // Test invalid patient record
        Set tInvalidPatient = ##class(Patterns.Examples.OutpatientRecord).%New()
        // Missing required fields
        
        Set tSC2 = tInvalidPatient.ValidateRecord()
        Do $$$AssertStatusNotOK(tSC2, "Invalid patient record should fail validation")
        
        Set ^ClineDebug = ^ClineDebug_"Record validation test completed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
    }
    
    Quit tSC
}

/// Clean up after each test
Method OnAfterOneTest() As %Status
{
    // Clean up any test artifacts
    Kill ^ClineDebug
    Quit $$$OK
}

}
