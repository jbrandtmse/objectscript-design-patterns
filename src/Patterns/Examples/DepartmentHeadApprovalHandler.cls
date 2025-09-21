/// Chain of Responsibility Pattern - Department Head Approval Handler
/// 
/// Intent:
/// Handles approval requests at department head level.
/// Third level of healthcare approval workflow.
/// 
/// @see Patterns.GoF.Behavioral.ConcreteHandler
/// @see Patterns.Examples.ApprovalRequest
/// @since 1.0.0
Class Patterns.Examples.DepartmentHeadApprovalHandler Extends Patterns.GoF.Behavioral.ConcreteHandler
{

/// Maximum amount a department head can approve
Parameter MAXAMOUNT = 50000;

/// Maximum risk level a department head can approve
Parameter MAXRISK = 4;

/// Constructor
/// 
/// @return %Status
Method %OnNew() As %Status
{
    Set tSC = ##super("DepartmentHead", 30)  // Priority 30 (third in chain)
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        // Configure handler
        Do ..SetConfig("role", "DepartmentHead")
        Do ..SetConfig("maxAmount", ..#MAXAMOUNT)
        Do ..SetConfig("maxRisk", ..#MAXRISK)
        Do ..SetConfig("department", "Management")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check if this handler can process the request
/// 
/// @param pRequest The request to check
/// @return %Boolean
Method CanHandleSpecific(pRequest As Request) As %Boolean
{
    // Must be an approval request
    If 'pRequest.%IsA("Patterns.Examples.ApprovalRequest") Quit 0
    
    // Cast to ApprovalRequest
    Set tApprovalRequest = pRequest
    
    // Check if within department head approval limits
    If tApprovalRequest.Amount > ..#MAXAMOUNT Quit 0
    
    // Department heads can approve all types except Emergency without Administrator review
    If tApprovalRequest.ApprovalType = "Emergency" {
        If tApprovalRequest.Amount > 25000 Quit 0  // Reduced limit for emergency
    }
    
    // Check if not already rejected at management level
    If tApprovalRequest.ApprovalStatus = "Rejected" {
        If (tApprovalRequest.RejectedBy [ "DepartmentHead") || (tApprovalRequest.RejectedBy [ "Administrator") {
            Quit 0
        }
    }
    
    Quit 1
}

/// Process the approval request
/// 
/// @param pRequest The request to process
/// @return Response object
Method ProcessSpecific(pRequest As Request) As Response
{
    Set tApprovalRequest = pRequest
    Set tResponse = ##class(Response).%New()
    
    Try {
        // Validate request
        Set tSC = tApprovalRequest.Validate()
        If $$$ISERR(tSC) {
            Set tResponse = ##class(Response).Failure("Validation failed: " _ $System.Status.GetErrorText(tSC))
            Quit
        }
        
        // Check escalation path
        Set tApproverCount = tApprovalRequest.ApprovedBy.Count()
        Set tRequiresReview = 0
        
        // Department head must review budget requests over 20K
        If tApprovalRequest.ApprovalType = "Budget" {
            If tApprovalRequest.Amount > 20000 {
                Set tRequiresReview = 1
            }
        }
        
        // Emergency requests need special handling
        If tApprovalRequest.ApprovalType = "Emergency" {
            If 'tApprovalRequest.IsUrgent {
                Set tResponse = ##class(Response).Failure("Emergency requests must be marked as urgent")
                Do tApprovalRequest.Reject(..HandlerName, "Emergency request not marked urgent")
                Quit
            }
            
            // Fast-track emergency approvals
            Do tApprovalRequest.AddApprover(..HandlerName, "Emergency approval granted")
            Do tApprovalRequest.ApprovalConditions.Insert("Post-emergency review required")
            Do tApprovalRequest.ApprovalConditions.Insert("Full documentation within 72 hours")
            
            Set tResponse = ##class(Response).Success(
                "Emergency approved by " _ ..HandlerName,
                "Emergency request approved for $" _ $FNumber(tApprovalRequest.Amount, ",", 2)
            )
            Do tResponse.SetMetadata("approvalType", "Emergency")
            Do tResponse.SetMetadata("fastTrack", "true")
            Quit
        }
        
        // Regular approval process
        If tApprovalRequest.Amount <= ..#MAXAMOUNT {
            // Check if review is required
            If tRequiresReview {
                // Perform department budget review
                Set tBudgetAvailable = ..CheckDepartmentBudget(tApprovalRequest.Department, tApprovalRequest.Amount)
                If 'tBudgetAvailable {
                    Set tResponse = ##class(Response).Failure("Department budget exceeded")
                    Do tApprovalRequest.Reject(..HandlerName, "Insufficient department budget")
                    Quit
                }
            }
            
            // Approve the request
            Do tApprovalRequest.AddApprover(..HandlerName, "Approved at department head level")
            
            // Add conditions based on amount and type
            If tApprovalRequest.Amount > 40000 {
                Do tApprovalRequest.ApprovalConditions.Insert("Requires board notification")
            }
            If tApprovalRequest.Amount > 30000 {
                Do tApprovalRequest.ApprovalConditions.Insert("Requires quarterly budget review")
                Do tApprovalRequest.ApprovalConditions.Insert("Submit impact analysis within 30 days")
            }
            If tApprovalRequest.RiskLevel >= 3 {
                Do tApprovalRequest.ApprovalConditions.Insert("Requires risk mitigation plan")
            }
            
            Set tResponse = ##class(Response).Success(
                "Approved by " _ ..HandlerName,
                "Request approved for $" _ $FNumber(tApprovalRequest.Amount, ",", 2)
            )
            Do tResponse.SetMetadata("approvalLevel", "DepartmentHead")
            Do tResponse.SetMetadata("approvalLimit", ..#MAXAMOUNT)
            
            // Note if this went through full chain
            If tApproverCount >= 2 {
                Do tResponse.SetMetadata("fullChainApproval", "true")
            }
        } Else {
            // Cannot approve - will pass to next handler
            Set tResponse = ##class(Response).%New(0, "Amount exceeds department head approval limit")
        }
    }
    Catch ex {
        Set tResponse = ##class(Response).Failure("Processing error: " _ ex.Name, 500)
        Do tResponse.AddError(ex.Name _ " at " _ ex.Location)
    }
    
    Quit tResponse
}

/// Check department budget availability
/// 
/// @param pDepartment Department name
/// @param pAmount Amount to check
/// @return %Boolean
Method CheckDepartmentBudget(pDepartment As %String, pAmount As %Decimal) As %Boolean [ Private ]
{
    // Simulated budget check - in real system would check actual budget data
    Set tBudgetLimit = 100000  // Default department budget
    
    // Get current month's spending
    Set tCurrentSpending = $GET(^Patterns.Chain.DepartmentBudget(pDepartment, $Piece($ZDate($Horolog, 3), "-", 1, 2)), 0)
    
    // Check if amount would exceed budget
    If (tCurrentSpending + pAmount) > tBudgetLimit {
        Quit 0
    }
    
    // Update spending (in real system would be done after approval)
    Set ^Patterns.Chain.DepartmentBudget(pDepartment, $Piece($ZDate($Horolog, 3), "-", 1, 2)) = tCurrentSpending + pAmount
    
    Quit 1
}

/// Get handler description
/// 
/// @return %String
Method GetDescription() As %String
{
    Quit "Department Head Approval Handler (Max: $" _ ..#MAXAMOUNT _ ", Risk: " _ ..#MAXRISK _ ")"
}

/// Review pending approvals for department
/// 
/// @param pDepartment Department to review
/// @return %Integer count of pending
Method ReviewPendingApprovals(pDepartment As %String) As %Integer
{
    // In real system would query pending approvals
    Set tPendingCount = $Random(10)
    Do ..SetConfig("lastReview", $ZDateTime($ZTimeStamp, 3))
    Do ..SetConfig("pendingCount", tPendingCount)
    
    Quit tPendingCount
}

}
