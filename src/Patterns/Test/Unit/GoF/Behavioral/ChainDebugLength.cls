/// Debug helper for Chain of Responsibility GetChainLength issue
Class Patterns.Test.Unit.GoF.Behavioral.ChainDebugLength Extends %RegisteredObject
{

/// Debug the GetChainLength issue
ClassMethod DebugLength() As %Status
{
    Set tSC = $$$OK
    
    // Clear debug global
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug _ "=== Starting GetChainLength Debug ===; "
    
    Try {
        // Create handlers
        Set tNurse = ##class(Patterns.Examples.NurseApprovalHandler).%New()
        Set tDoctor = ##class(Patterns.Examples.DoctorApprovalHandler).%New()
        Set tDeptHead = ##class(Patterns.Examples.DepartmentHeadApprovalHandler).%New()
        Set tAdmin = ##class(Patterns.Examples.AdministratorApprovalHandler).%New()
        
        Set ^ClineDebug = ^ClineDebug _ "Created all handlers; "
        
        // Verify each handler
        Set ^ClineDebug = ^ClineDebug _ "Nurse IsObject: " _ $IsObject(tNurse) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Doctor IsObject: " _ $IsObject(tDoctor) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "DeptHead IsObject: " _ $IsObject(tDeptHead) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "Admin IsObject: " _ $IsObject(tAdmin) _ "; "
        
        // Build chain manually
        Set ^ClineDebug = ^ClineDebug _ "Building chain...; "
        
        // Set Nurse -> Doctor
        Do tNurse.SetNext(tDoctor)
        Set ^ClineDebug = ^ClineDebug _ "Set Nurse->Doctor; "
        Set ^ClineDebug = ^ClineDebug _ "Nurse.NextHandler is object: " _ $IsObject(tNurse.NextHandler) _ "; "
        If $IsObject(tNurse.NextHandler) {
            Set ^ClineDebug = ^ClineDebug _ "Nurse.NextHandler.HandlerName: " _ tNurse.NextHandler.HandlerName _ "; "
        }
        
        // Set Doctor -> DeptHead
        Do tDoctor.SetNext(tDeptHead)
        Set ^ClineDebug = ^ClineDebug _ "Set Doctor->DeptHead; "
        Set ^ClineDebug = ^ClineDebug _ "Doctor.NextHandler is object: " _ $IsObject(tDoctor.NextHandler) _ "; "
        If $IsObject(tDoctor.NextHandler) {
            Set ^ClineDebug = ^ClineDebug _ "Doctor.NextHandler.HandlerName: " _ tDoctor.NextHandler.HandlerName _ "; "
        }
        
        // Set DeptHead -> Admin
        Do tDeptHead.SetNext(tAdmin)
        Set ^ClineDebug = ^ClineDebug _ "Set DeptHead->Admin; "
        Set ^ClineDebug = ^ClineDebug _ "DeptHead.NextHandler is object: " _ $IsObject(tDeptHead.NextHandler) _ "; "
        If $IsObject(tDeptHead.NextHandler) {
            Set ^ClineDebug = ^ClineDebug _ "DeptHead.NextHandler.HandlerName: " _ tDeptHead.NextHandler.HandlerName _ "; "
        }
        
        // Debug GetChainLength step by step
        Set ^ClineDebug = ^ClineDebug _ "=== Calling GetChainLength ===; "
        
        // Manually trace through the method
        Set ^ClineDebug = ^ClineDebug _ "Starting from Nurse handler; "
        Set tCount = 1
        Set tNext = tNurse.NextHandler
        Set ^ClineDebug = ^ClineDebug _ "Initial count=1, tNext is object: " _ $IsObject(tNext) _ "; "
        
        Set iteration = 0
        While $IsObject(tNext) {
            Set iteration = iteration + 1
            Set tCount = tCount + 1
            Set ^ClineDebug = ^ClineDebug _ "Iteration " _ iteration _ ": count=" _ tCount
            If $IsObject(tNext) {
                Set ^ClineDebug = ^ClineDebug _ ", current handler: " _ tNext.HandlerName
            }
            Set ^ClineDebug = ^ClineDebug _ "; "
            
            // Check next pointer before assignment
            Set ^ClineDebug = ^ClineDebug _ "tNext.NextHandler is object: " _ $IsObject(tNext.NextHandler) _ "; "
            Set tNext = tNext.NextHandler
            
            // Safety check
            If iteration > 10 {
                Set ^ClineDebug = ^ClineDebug _ "ERROR: Too many iterations, breaking loop; "
                Quit
            }
        }
        
        Set ^ClineDebug = ^ClineDebug _ "Manual count result: " _ tCount _ "; "
        
        // Now call the actual method
        Set actualLength = tNurse.GetChainLength()
        Set ^ClineDebug = ^ClineDebug _ "Actual GetChainLength result: " _ actualLength _ "; "
        
        // Get chain info
        Set chainInfo = tNurse.GetChainInfo()
        Set ^ClineDebug = ^ClineDebug _ "GetChainInfo result: " _ chainInfo _ "; "
        
        // Check each handler's NextHandler individually
        Set ^ClineDebug = ^ClineDebug _ "=== Checking each handler's NextHandler ===; "
        Set ^ClineDebug = ^ClineDebug _ "Nurse.NextHandler exists: " _ $IsObject(tNurse.NextHandler) _ "; "
        If $IsObject(tNurse.NextHandler) {
            Set ^ClineDebug = ^ClineDebug _ "  -> " _ tNurse.NextHandler.HandlerName _ "; "
            Set ^ClineDebug = ^ClineDebug _ "  Nurse.NextHandler.NextHandler exists: " _ $IsObject(tNurse.NextHandler.NextHandler) _ "; "
            If $IsObject(tNurse.NextHandler.NextHandler) {
                Set ^ClineDebug = ^ClineDebug _ "    -> " _ tNurse.NextHandler.NextHandler.HandlerName _ "; "
                Set ^ClineDebug = ^ClineDebug _ "    Nurse.NextHandler.NextHandler.NextHandler exists: " _ $IsObject(tNurse.NextHandler.NextHandler.NextHandler) _ "; "
                If $IsObject(tNurse.NextHandler.NextHandler.NextHandler) {
                    Set ^ClineDebug = ^ClineDebug _ "      -> " _ tNurse.NextHandler.NextHandler.NextHandler.HandlerName _ "; "
                }
            }
        }
        
        Set ^ClineDebug = ^ClineDebug _ "=== Debug Complete ===; "
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.Name _ " at " _ ex.Location _ "; "
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
