/// Enhanced test runner with detailed output
Class Patterns.Test.Unit.GoF.Behavioral.CommandTestRunner2
{

/// Run all tests with detailed output
ClassMethod RunAllTests() As %Status
{
    Set tSC = $$$OK
    Set tPassedCount = 0
    Set tFailedCount = 0
    Set tOutput = ""
    
    // List of test methods
    Set tTests = $listbuild(
        "TestCommandStructure",
        "TestCommandExecution",
        "TestUndoFunctionality",
        "TestRedoFunctionality",
        "TestCommandValidation",
        "TestClinicalOrderWorkflow"
    )
    
    Set tOutput = tOutput _ "=== Running Command Pattern Tests ===" _ $char(10)
    
    // Run each test
    For i = 1:1:$listlength(tTests) {
        Set tTestName = $list(tTests, i)
        Set tOutput = tOutput _ "Running: " _ tTestName _ "... "
        
        Try {
            // Run test directly via class method
            Set tSC = ..RunSingleTest(tTestName)
            
            If $$$ISERR(tSC) {
                Set tOutput = tOutput _ "FAILED: " _ $System.Status.GetErrorText(tSC) _ $char(10)
                Set tFailedCount = tFailedCount + 1
            } Else {
                Set tOutput = tOutput _ "PASSED" _ $char(10)
                Set tPassedCount = tPassedCount + 1
            }
        }
        Catch ex {
            Set tOutput = tOutput _ "FAILED: " _ ex.DisplayString() _ $char(10)
            Set tFailedCount = tFailedCount + 1
        }
    }
    
    Set tOutput = tOutput _ $char(10) _ "=== Test Results ===" _ $char(10)
    Set tOutput = tOutput _ "Passed: " _ tPassedCount _ $char(10)
    Set tOutput = tOutput _ "Failed: " _ tFailedCount _ $char(10)
    Set tOutput = tOutput _ "Total: " _ (tPassedCount + tFailedCount) _ $char(10)
    
    If tFailedCount = 0 {
        Set tOutput = tOutput _ "SUCCESS: All tests passed!" _ $char(10)
        Set tSC = $$$OK
    } Else {
        Set tOutput = tOutput _ "FAILURE: " _ tFailedCount _ " tests failed" _ $char(10)
        Set tSC = $$$ERROR($$$GeneralError, tFailedCount _ " tests failed")
    }
    
    // Store output in global for retrieval
    Set ^ClineDebug = tOutput
    Write tOutput
    
    Quit tSC
}

/// Run a specific test without using test framework
ClassMethod RunSingleTest(pTestName As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Run the specific test based on name
        If pTestName = "TestCommandStructure" {
            Set tSC = ..TestCommandStructure()
        } ElseIf pTestName = "TestCommandExecution" {
            Set tSC = ..TestCommandExecution()
        } ElseIf pTestName = "TestUndoFunctionality" {
            Set tSC = ..TestUndoFunctionality()
        } ElseIf pTestName = "TestRedoFunctionality" {
            Set tSC = ..TestRedoFunctionality()
        } ElseIf pTestName = "TestCommandValidation" {
            Set tSC = ..TestCommandValidation()
        } ElseIf pTestName = "TestClinicalOrderWorkflow" {
            Set tSC = ..TestClinicalOrderWorkflow()
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "Unknown test: " _ pTestName)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test command structure
ClassMethod TestCommandStructure() As %Status
{
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT001", "DOC001", "Lab")
    If '$ISOBJECT(tOrder) Quit $$$ERROR($$$GeneralError, "Failed to create ClinicalOrder")
    
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    If '$ISOBJECT(tInvoker) Quit $$$ERROR($$$GeneralError, "Failed to create CommandInvoker")
    
    If tInvoker.GetUndoCount() '= 0 Quit $$$ERROR($$$GeneralError, "Initial undo stack not empty")
    If tInvoker.GetRedoCount() '= 0 Quit $$$ERROR($$$GeneralError, "Initial redo stack not empty")
    
    Quit $$$OK
}

/// Test command execution
ClassMethod TestCommandExecution() As %Status
{
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT001", "DOC001", "Lab")
    Set tOrder.PatientName = "John Doe"
    Set tOrder.ProviderName = "Dr. Smith"
    
    If tOrder.State '= "Draft" Quit $$$ERROR($$$GeneralError, "Order should start in Draft state")
    
    Set tParams = {}
    Set tParams.labTests = "CBC,BMP"
    Set tParams.specimenType = "Blood"
    
    Set tLabCommand = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams)
    If '$ISOBJECT(tLabCommand) Quit $$$ERROR($$$GeneralError, "Failed to create LabOrderCommand")
    
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    Set tSC = tInvoker.ExecuteCommand(tLabCommand)
    If $$$ISERR(tSC) Quit tSC
    
    If tOrder.State '= "Pending" Quit $$$ERROR($$$GeneralError, "Order should be in Pending state after execution")
    If tOrder.OrderItems.Count() = 0 Quit $$$ERROR($$$GeneralError, "Order should have items after execution")
    
    Quit $$$OK
}

/// Test undo functionality
ClassMethod TestUndoFunctionality() As %Status
{
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT002", "DOC002", "Medication")
    Set tOrder.PatientName = "Jane Smith"
    
    Set tInitialState = tOrder.State
    
    Set tParams = {}
    Set tParams.medicationName = "Aspirin"
    Set tParams.dosage = "81mg"
    Set tParams.frequency = "Daily"
    Set tParams.route = "PO"
    
    Set tMedCommand = ##class(Patterns.Examples.MedicationOrderCommand).%New(tOrder, tParams)
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    
    Set tSC = tInvoker.ExecuteCommand(tMedCommand)
    If $$$ISERR(tSC) Quit tSC
    
    If tInvoker.GetUndoCount() '= 1 Quit $$$ERROR($$$GeneralError, "Should have 1 command in undo stack")
    
    Set tSC = tInvoker.UndoLastCommand()
    If $$$ISERR(tSC) Quit tSC
    
    If tOrder.State '= tInitialState Quit $$$ERROR($$$GeneralError, "Order state not restored after undo")
    If tInvoker.GetUndoCount() '= 0 Quit $$$ERROR($$$GeneralError, "Undo stack should be empty after undo")
    If tInvoker.GetRedoCount() '= 1 Quit $$$ERROR($$$GeneralError, "Should have 1 command in redo stack")
    
    Quit $$$OK
}

/// Test redo functionality
ClassMethod TestRedoFunctionality() As %Status
{
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT003", "DOC003", "Lab")
    
    Set tParams = {}
    Set tParams.labTests = "Glucose"
    Set tParams.specimenType = "Serum"
    
    Set tLabCommand = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams)
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    
    Set tSC = tInvoker.ExecuteCommand(tLabCommand)
    If $$$ISERR(tSC) Quit tSC
    
    Set tSC = tInvoker.UndoLastCommand()
    If $$$ISERR(tSC) Quit tSC
    
    Set tSC = tInvoker.RedoLastCommand()
    If $$$ISERR(tSC) Quit tSC
    
    If tInvoker.GetUndoCount() '= 1 Quit $$$ERROR($$$GeneralError, "Should have 1 command in undo stack after redo")
    If tInvoker.GetRedoCount() '= 0 Quit $$$ERROR($$$GeneralError, "Redo stack should be empty after redo")
    
    Quit $$$OK
}

/// Test command validation
ClassMethod TestCommandValidation() As %Status
{
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT006", "DOC006", "Medication")
    
    Set tParams = {}
    // Intentionally leave medication name empty for validation test
    
    Set tMedCommand = ##class(Patterns.Examples.MedicationOrderCommand).%New(tOrder, tParams)
    
    // Try to execute invalid command
    Set tSC = tMedCommand.Execute()
    If $$$ISOK(tSC) Quit $$$ERROR($$$GeneralError, "Invalid command should fail validation")
    
    Quit $$$OK
}

/// Test clinical order workflow
ClassMethod TestClinicalOrderWorkflow() As %Status
{
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT009", "DOC009", "Lab")
    Set tOrder.PatientName = "Test Patient"
    Set tOrder.ProviderName = "Test Provider"
    
    If tOrder.State '= "Draft" Quit $$$ERROR($$$GeneralError, "Order should start in Draft state")
    
    Set tSC = tOrder.Submit()
    If $$$ISERR(tSC) Quit tSC
    If tOrder.State '= "Pending" Quit $$$ERROR($$$GeneralError, "Order should be in Pending state after submission")
    
    Set tSC = tOrder.Approve("SUPERVISOR001")
    If $$$ISERR(tSC) Quit tSC
    If tOrder.State '= "Active" Quit $$$ERROR($$$GeneralError, "Order should be in Active state after approval")
    If 'tOrder.IsApproved Quit $$$ERROR($$$GeneralError, "Order should be marked as approved")
    
    Set tSC = tOrder.Complete()
    If $$$ISERR(tSC) Quit tSC
    If tOrder.State '= "Completed" Quit $$$ERROR($$$GeneralError, "Order should be in Completed state")
    
    If tOrder.AuditTrail.Count() = 0 Quit $$$ERROR($$$GeneralError, "Audit trail should contain entries")
    
    Quit $$$OK
}

}
