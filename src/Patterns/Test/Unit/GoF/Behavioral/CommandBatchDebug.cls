/// Debug class for Command Pattern Batching Test
Class Patterns.Test.Unit.GoF.Behavioral.CommandBatchDebug Extends %RegisteredObject
{

ClassMethod DebugBatching() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ^ClineDebug _ "Starting batch debug; "
    
    Try {
        // Create clinical order
        Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT004", "DOC004", "")
        Set tOrder.PatientName = "Bob Johnson"
        Set ^ClineDebug = ^ClineDebug _ "Order created; "
        
        // Create invoker
        Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
        Set ^ClineDebug = ^ClineDebug _ "Invoker created; "
        
        // Begin batch
        Set tSC = tInvoker.BeginBatch("Complete Patient Workup")
        Set ^ClineDebug = ^ClineDebug _ "Batch started: " _ $System.Status.GetErrorText(tSC) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "InBatchMode=" _ tInvoker.InBatchMode _ "; "
        
        // Create lab command parameters
        Set tLabParams = {}
        Set tLabParams.labTests = "CBC"
        Set tLabParams.specimenType = "Blood"
        
        // Execute lab command in batch
        Set tLabCommand = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tLabParams)
        Set ^ClineDebug = ^ClineDebug _ "Lab command created; "
        
        Set tSC = tInvoker.ExecuteCommand(tLabCommand)
        Set ^ClineDebug = ^ClineDebug _ "Lab command executed: " _ $System.Status.GetErrorText(tSC) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "CurrentBatch count=" _ tInvoker.CurrentBatch.Count() _ "; "
        
        // Create medication command parameters
        Set tMedParams = {}
        Set tMedParams.medicationName = "Lisinopril"
        Set tMedParams.dosage = "10mg"
        Set tMedParams.frequency = "Daily"
        Set tMedParams.route = "PO"
        
        // Execute medication command in batch
        Set tMedCommand = ##class(Patterns.Examples.MedicationOrderCommand).%New(tOrder, tMedParams)
        Set ^ClineDebug = ^ClineDebug _ "Med command created; "
        
        Set tSC = tInvoker.ExecuteCommand(tMedCommand)
        Set ^ClineDebug = ^ClineDebug _ "Med command executed: " _ $System.Status.GetErrorText(tSC) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "CurrentBatch count=" _ tInvoker.CurrentBatch.Count() _ "; "
        
        // End batch
        Set tSC = tInvoker.EndBatch()
        Set ^ClineDebug = ^ClineDebug _ "Batch ended: " _ $System.Status.GetErrorText(tSC) _ "; "
        
        // Check what's in undo stack
        Set ^ClineDebug = ^ClineDebug _ "UndoStack count=" _ tInvoker.GetUndoCount() _ "; "
        
        // Try to undo
        Set tSC = tInvoker.UndoLastCommand()
        Set ^ClineDebug = ^ClineDebug _ "Undo result: " _ $System.Status.GetErrorText(tSC) _ "; "
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.Name _ " at " _ ex.Location _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

ClassMethod DebugQueue() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ^ClineDebug _ "Starting queue debug; "
    
    Try {
        // Create clinical order
        Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT005", "DOC005", "")
        Set ^ClineDebug = ^ClineDebug _ "Order created; "
        
        // Create invoker
        Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
        Set ^ClineDebug = ^ClineDebug _ "Invoker created; "
        
        // Create parameters for first command
        Set tParams1 = {}
        Set tParams1.labTests = "CBC"
        Set tParams1.specimenType = "Blood"
        
        // Queue first command
        Set tCmd1 = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams1)
        Set tSC = tInvoker.QueueCommand(tCmd1)
        Set ^ClineDebug = ^ClineDebug _ "First command queued: " _ $System.Status.GetErrorText(tSC) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "CommandQueue count=" _ tInvoker.CommandQueue.Count() _ "; "
        
        // Create parameters for second command
        Set tParams2 = {}
        Set tParams2.labTests = "BMP"
        Set tParams2.specimenType = "Serum"
        
        // Queue second command
        Set tCmd2 = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams2)
        Set tSC = tInvoker.QueueCommand(tCmd2)
        Set ^ClineDebug = ^ClineDebug _ "Second command queued: " _ $System.Status.GetErrorText(tSC) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "CommandQueue count=" _ tInvoker.CommandQueue.Count() _ "; "
        
        // Execute all queued commands
        Set tSC = tInvoker.ExecuteQueuedCommands()
        Set ^ClineDebug = ^ClineDebug _ "Queued commands executed: " _ $System.Status.GetErrorText(tSC) _ "; "
        
        // Check undo stack
        Set ^ClineDebug = ^ClineDebug _ "UndoStack count=" _ tInvoker.GetUndoCount() _ "; "
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.Name _ " at " _ ex.Location _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
