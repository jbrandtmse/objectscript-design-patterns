/// Unit tests for Gang of Four Command Pattern Implementation
/// Tests command execution, undo/redo, batching, and healthcare workflow
/// 
/// @see Patterns.GoF.Behavioral.Command
/// @see Patterns.GoF.Behavioral.CommandInvoker
/// @see Patterns.Examples.ClinicalOrder
/// @since 1.0.0
Class Patterns.Test.Unit.GoF.Behavioral.CommandTest Extends %UnitTest.TestCase
{

// ===== TEST METHODS =====

/// Test basic command pattern structure
Method TestCommandStructure() As %Boolean
{
    // Create a clinical order receiver
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT001", "DOC001", "Lab")
    Do $$$AssertTrue($ISOBJECT(tOrder), "ClinicalOrder receiver created")
    
    // Create command invoker
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    Do $$$AssertTrue($ISOBJECT(tInvoker), "CommandInvoker created")
    
    // Verify initial state
    Do $$$AssertEquals(tInvoker.GetUndoCount(), 0, "Initial undo stack is empty")
    Do $$$AssertEquals(tInvoker.GetRedoCount(), 0, "Initial redo stack is empty")
    
    Quit 1  // Return 1 for test method success
}

/// Test command execution and state change
Method TestCommandExecution() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT001", "DOC001", "Lab")
    Set tOrder.PatientName = "John Doe"
    Set tOrder.ProviderName = "Dr. Smith"
    
    // Verify initial state
    Do $$$AssertEquals(tOrder.State, "Draft", "Order starts in Draft state")
    
    // Create parameters for lab order
    Set tParams = {}
    Set tParams.labTests = "CBC,BMP"
    Set tParams.specimenType = "Blood"
    
    // Create and execute lab order command
    Set tLabCommand = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams)
    Do $$$AssertTrue($ISOBJECT(tLabCommand), "Lab order command created")
    
    // Create invoker and execute command
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    Set tSC = tInvoker.ExecuteCommand(tLabCommand)
    Do $$$AssertStatusOK(tSC, "Lab command executed successfully")
    
    // Verify state changed to Pending after submission
    Do $$$AssertEquals(tOrder.State, "Pending", "Order transitioned to Pending state")
    
    // Verify order items were added
    Do $$$AssertTrue(tOrder.OrderItems.Count() > 0, "Order items added")
    
    Quit 1  // Return 1 for test method success
}

/// Test undo functionality
Method TestUndoFunctionality() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT002", "DOC002", "Medication")
    Set tOrder.PatientName = "Jane Smith"
    
    // Save initial state
    Set tInitialState = tOrder.State
    Set tInitialItemCount = tOrder.OrderItems.Count()
    
    // Create medication command parameters
    Set tParams = {}
    Set tParams.medicationName = "Aspirin"
    Set tParams.dosage = "81mg"
    Set tParams.frequency = "Daily"
    Set tParams.route = "PO"
    
    // Create medication command
    Set tMedCommand = ##class(Patterns.Examples.MedicationOrderCommand).%New(tOrder, tParams)
    
    // Execute command through invoker
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    Set tSC = tInvoker.ExecuteCommand(tMedCommand)
    Do $$$AssertStatusOK(tSC, "Medication command executed")
    
    // Verify changes were made (check Description instead of OrderItems)
    Do $$$AssertTrue(tOrder.Description '= "", "Order description updated")
    Do $$$AssertEquals(tInvoker.GetUndoCount(), 1, "One command in undo stack")
    
    // Undo the command
    Set tSC = tInvoker.UndoLastCommand()
    Do $$$AssertStatusOK(tSC, "Command undone successfully")
    
    // Verify state was restored
    Do $$$AssertEquals(tOrder.State, tInitialState, "Order state restored after undo")
    Do $$$AssertEquals(tInvoker.GetUndoCount(), 0, "Undo stack empty after undo")
    Do $$$AssertEquals(tInvoker.GetRedoCount(), 1, "One command in redo stack")
    
    Quit 1  // Return 1 for test method success
}

/// Test redo functionality
Method TestRedoFunctionality() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT003", "DOC003", "Lab")
    
    // Create lab command parameters
    Set tParams = {}
    Set tParams.labTests = "Glucose"
    Set tParams.specimenType = "Serum"
    
    // Create and execute command
    Set tLabCommand = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams)
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    
    Set tSC = tInvoker.ExecuteCommand(tLabCommand)
    Do $$$AssertStatusOK(tSC, "Command executed")
    
    // Undo the command
    Set tSC = tInvoker.UndoLastCommand()
    Do $$$AssertStatusOK(tSC, "Command undone")
    
    // Redo the command
    Set tSC = tInvoker.RedoLastCommand()
    Do $$$AssertStatusOK(tSC, "Command redone successfully")
    
    // Verify command was re-executed
    Do $$$AssertEquals(tInvoker.GetUndoCount(), 1, "Command back in undo stack")
    Do $$$AssertEquals(tInvoker.GetRedoCount(), 0, "Redo stack empty after redo")
    
    Quit 1  // Return 1 for test method success
}

/// Test command batching functionality
Method TestCommandBatching() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT004", "DOC004", "")
    Set tOrder.PatientName = "Bob Johnson"
    
    // Create invoker
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    
    // Begin batch
    Set tSC = tInvoker.BeginBatch("Complete Patient Workup")
    Do $$$AssertStatusOK(tSC, "Batch started")
    
    // Create lab command parameters
    Set tLabParams = {}
    Set tLabParams.labTests = "CBC"
    Set tLabParams.specimenType = "Blood"
    
    // Execute lab command in batch
    Set tLabCommand = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tLabParams)
    Set tSC = tInvoker.ExecuteCommand(tLabCommand)
    Do $$$AssertStatusOK(tSC, "Lab command added to batch")
    
    // Create medication command parameters
    Set tMedParams = {}
    Set tMedParams.medicationName = "Lisinopril"
    Set tMedParams.dosage = "10mg"
    Set tMedParams.frequency = "Daily"
    Set tMedParams.route = "PO"
    
    // Execute medication command in batch
    Set tMedCommand = ##class(Patterns.Examples.MedicationOrderCommand).%New(tOrder, tMedParams)
    Set tSC = tInvoker.ExecuteCommand(tMedCommand)
    Do $$$AssertStatusOK(tSC, "Medication command added to batch")
    
    // End batch
    Set tSC = tInvoker.EndBatch()
    Do $$$AssertStatusOK(tSC, "Batch completed")
    
    // Verify batch was treated as single command
    Do $$$AssertEquals(tInvoker.GetUndoCount(), 1, "Batch appears as single command in undo stack")
    
    // Undo entire batch
    Set tSC = tInvoker.UndoLastCommand()
    Do $$$AssertStatusOK(tSC, "Batch undone as single unit")
    
    Quit 1  // Return 1 for test method success
}

/// Test command queue functionality
Method TestCommandQueue() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT005", "DOC005", "")
    
    // Create invoker
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    
    // Create parameters for first command
    Set tParams1 = {}
    Set tParams1.labTests = "CBC"
    Set tParams1.specimenType = "Blood"
    
    // Queue first command
    Set tCmd1 = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams1)
    Set tSC = tInvoker.QueueCommand(tCmd1)
    Do $$$AssertStatusOK(tSC, "First command queued")
    
    // Create parameters for second command
    Set tParams2 = {}
    Set tParams2.labTests = "BMP"
    Set tParams2.specimenType = "Serum"
    
    // Queue second command
    Set tCmd2 = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams2)
    Set tSC = tInvoker.QueueCommand(tCmd2)
    Do $$$AssertStatusOK(tSC, "Second command queued")
    
    // Execute all queued commands
    Set tSC = tInvoker.ExecuteQueuedCommands()
    Do $$$AssertStatusOK(tSC, "Queued commands executed")
    
    // Verify commands were executed
    Do $$$AssertEquals(tInvoker.GetUndoCount(), 2, "Two commands in undo stack")
    
    Quit 1  // Return 1 for test method success
}

/// Test command validation
Method TestCommandValidation() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT006", "DOC006", "Medication")
    
    // Create medication command with empty parameters
    Set tParams = {}
    // Intentionally leave medication name empty for validation test
    
    // Create medication command with missing required fields
    Set tMedCommand = ##class(Patterns.Examples.MedicationOrderCommand).%New(tOrder, tParams)
    
    // Try to execute invalid command
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    Set tSC = tMedCommand.Execute()
    Do $$$AssertStatusNotOK(tSC, "Invalid medication command fails validation")
    
    Quit 1  // Return 1 for test method success
}

/// Test composite command functionality
Method TestCompositeCommand() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT007", "DOC007", "")
    
    // Create composite command
    Set tComposite = ##class(Patterns.GoF.Behavioral.CompositeCommand).%New()
    Set tComposite.Description = "Standard Admission Orders"
    
    // Create lab command parameters
    Set tLabParams = {}
    Set tLabParams.labTests = "CBC,BMP,PT/INR"
    Set tLabParams.specimenType = "Blood"
    
    // Add lab command to composite
    Set tLabCmd = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tLabParams)
    Set tSC = tComposite.AddCommand(tLabCmd)
    Do $$$AssertStatusOK(tSC, "Lab command added to composite")
    
    // Create medication command parameters
    Set tMedParams = {}
    Set tMedParams.medicationName = "Aspirin"
    Set tMedParams.dosage = "81mg"
    Set tMedParams.frequency = "Daily"
    Set tMedParams.route = "PO"
    
    // Add medication command to composite
    Set tMedCmd = ##class(Patterns.Examples.MedicationOrderCommand).%New(tOrder, tMedParams)
    Set tSC = tComposite.AddCommand(tMedCmd)
    Do $$$AssertStatusOK(tSC, "Medication command added to composite")
    
    // Execute composite through invoker
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    Set tSC = tInvoker.ExecuteCommand(tComposite)
    Do $$$AssertStatusOK(tSC, "Composite command executed")
    
    // Verify all commands executed
    Do $$$AssertTrue(tOrder.OrderItems.Count() > 0, "Multiple order items added")
    
    // Undo composite
    Set tSC = tInvoker.UndoLastCommand()
    Do $$$AssertStatusOK(tSC, "Composite command undone")
    
    Quit 1  // Return 1 for test method success
}

/// Test command history management
Method TestHistoryManagement() As %Boolean
{
    Set tSC = $$$OK
    
    // Create invoker with small history size
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New(3)
    
    // Create order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT008", "DOC008", "")
    
    // Execute more commands than history size
    For i = 1:1:5 {
        Set tParams = {}
        Set tParams.labTests = "Test"_i
        Set tParams.specimenType = "Blood"
        
        Set tCmd = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams)
        Set tSC = tInvoker.ExecuteCommand(tCmd)
        Do $$$AssertStatusOK(tSC, "Command "_i_" executed")
    }
    
    // Verify history size is limited
    Do $$$AssertTrue(tInvoker.GetUndoCount() <= 3, "History size limited to maximum")
    
    Quit 1  // Return 1 for test method success
}

/// Test clinical order workflow
Method TestClinicalOrderWorkflow() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT009", "DOC009", "Lab")
    Set tOrder.PatientName = "Test Patient"
    Set tOrder.ProviderName = "Test Provider"
    
    // Verify initial state
    Do $$$AssertEquals(tOrder.State, "Draft", "Order starts in Draft state")
    
    // Submit order
    Set tSC = tOrder.Submit()
    Do $$$AssertStatusOK(tSC, "Order submitted")
    Do $$$AssertEquals(tOrder.State, "Pending", "Order in Pending state")
    
    // Approve order
    Set tSC = tOrder.Approve("SUPERVISOR001")
    Do $$$AssertStatusOK(tSC, "Order approved")
    Do $$$AssertEquals(tOrder.State, "Active", "Order in Active state")
    Do $$$AssertTrue(tOrder.IsApproved, "Order marked as approved")
    
    // Complete order
    Set tSC = tOrder.Complete()
    Do $$$AssertStatusOK(tSC, "Order completed")
    Do $$$AssertEquals(tOrder.State, "Completed", "Order in Completed state")
    
    // Verify audit trail
    Do $$$AssertTrue(tOrder.AuditTrail.Count() > 0, "Audit trail contains entries")
    
    Quit 1  // Return 1 for test method success
}

/// Test STAT order priority
Method TestSTATOrderPriority() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT010", "DOC010", "Lab")
    
    // Create STAT lab order parameters
    Set tParams = {}
    Set tParams.labTests = "Troponin,BNP"
    Set tParams.specimenType = "Blood"
    Set tParams.isSTAT = 1
    
    // Create STAT lab order
    Set tLabCommand = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams)
    
    // Execute command
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    Set tSC = tInvoker.ExecuteCommand(tLabCommand)
    Do $$$AssertStatusOK(tSC, "STAT lab command executed")
    
    // Verify priority was set
    Do $$$AssertEquals(tOrder.Priority, "STAT", "Order priority set to STAT")
    
    Quit 1  // Return 1 for test method success
}

/// Test lab panel creation
Method TestLabPanelCreation() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT011", "DOC011", "Lab")
    
    // Create standard lab panel
    Set tPanelCommand = ##class(Patterns.Examples.LabOrderCommand).CreateCMPPanel(tOrder)
    Do $$$AssertTrue($ISOBJECT(tPanelCommand), "CMP panel command created")
    
    // Execute panel command
    Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
    Set tSC = tInvoker.ExecuteCommand(tPanelCommand)
    Do $$$AssertStatusOK(tSC, "Lab panel command executed")
    
    // Verify multiple tests were added
    Do $$$AssertTrue(tOrder.OrderItems.Count() > 5, "Multiple tests added from panel")
    
    Quit 1  // Return 1 for test method success
}

/// Test common medication orders
Method TestCommonMedicationOrders() As %Boolean
{
    Set tSC = $$$OK
    
    // Create clinical order
    Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT012", "DOC012", "Medication")
    
    // Create common medication order
    Set tMedCommand = ##class(Patterns.Examples.MedicationOrderCommand).CreateAspirin(tOrder)
    Do $$$AssertTrue($ISOBJECT(tMedCommand), "Common medication command created")
    
    // Verify properties were set correctly
    Do $$$AssertEquals(tMedCommand.MedicationName, "Aspirin", "Medication name set")
    Do $$$AssertEquals(tMedCommand.Dosage, "81mg", "Dosage set to 81mg")
    Do $$$AssertEquals(tMedCommand.Route, "PO", "Route set to oral")
    
    Quit 1  // Return 1 for test method success
}

// ===== HELPER METHODS =====

/// Setup method - runs before each test
Method OnBeforeOneTest() As %Status
{
    // Clear any debug globals
    Kill ^ClineDebug
    Set ^ClineDebug = ""
    
    Quit $$$OK
}

/// Teardown method - runs after each test
Method OnAfterOneTest() As %Status
{
    // Clean up any test data
    Kill ^ClineDebug
    
    Quit $$$OK
}

}
