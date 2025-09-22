/// Temporary debug class for Command Pattern testing
Class Patterns.Test.Unit.GoF.Behavioral.CommandDebug
{

/// Debug test for Command Pattern
ClassMethod DebugTest() As %Status
{
    Set tResult = $$$OK
    Set ^ClineDebug = ""
    
    Try {
        Set ^ClineDebug = ^ClineDebug _ "1. Creating ClinicalOrder; "
        Set tOrder = ##class(Patterns.Examples.ClinicalOrder).%New("PAT001", "DOC001", "Lab")
        If '$ISOBJECT(tOrder) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Failed to create order; "
            Set tResult = $$$ERROR($$$GeneralError, "Failed to create ClinicalOrder")
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "2. Order created, state=" _ tOrder.State _ "; "
        
        // Create parameters
        Set ^ClineDebug = ^ClineDebug _ "3. Creating parameters; "
        Set tParams = {}
        Set tParams.labTests = "CBC"
        Set tParams.specimenType = "Blood"
        
        Set ^ClineDebug = ^ClineDebug _ "4. Creating LabOrderCommand; "
        Set tLabCommand = ##class(Patterns.Examples.LabOrderCommand).%New(tOrder, tParams)
        If '$ISOBJECT(tLabCommand) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Failed to create LabOrderCommand; "
            Set tResult = $$$ERROR($$$GeneralError, "Failed to create LabOrderCommand")
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "5. Command created; "
        
        // Create invoker
        Set ^ClineDebug = ^ClineDebug _ "6. Creating CommandInvoker; "
        Set tInvoker = ##class(Patterns.GoF.Behavioral.CommandInvoker).%New()
        If '$ISOBJECT(tInvoker) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Failed to create CommandInvoker; "
            Set tResult = $$$ERROR($$$GeneralError, "Failed to create CommandInvoker")
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "7. Invoker created; "
        
        // Execute command
        Set ^ClineDebug = ^ClineDebug _ "8. Executing command; "
        Set tSC = tInvoker.ExecuteCommand(tLabCommand)
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Command execution failed: " _ $System.Status.GetErrorText(tSC) _ "; "
            Set tResult = tSC
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "9. Command executed, order state=" _ tOrder.State _ "; "
        
        // Test undo
        Set ^ClineDebug = ^ClineDebug _ "10. Testing undo; "
        Set tSC = tInvoker.UndoLastCommand()
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Undo failed: " _ $System.Status.GetErrorText(tSC) _ "; "
            Set tResult = tSC
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "11. Undo completed, order state=" _ tOrder.State _ "; "
        
        // Test redo
        Set ^ClineDebug = ^ClineDebug _ "12. Testing redo; "
        Set tSC = tInvoker.RedoLastCommand()
        If $$$ISERR(tSC) {
            Set ^ClineDebug = ^ClineDebug _ "ERROR: Redo failed: " _ $System.Status.GetErrorText(tSC) _ "; "
            Set tResult = tSC
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "13. Redo completed, order state=" _ tOrder.State _ "; "
        
        Set ^ClineDebug = ^ClineDebug _ "SUCCESS: All tests passed!; "
        
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "EXCEPTION: " _ ex.DisplayString() _ "; "
        Set tResult = ex.AsStatus()
    }
    
    Quit tResult
}

}
