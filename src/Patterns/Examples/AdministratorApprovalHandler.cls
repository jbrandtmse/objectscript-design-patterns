/// Chain of Responsibility Pattern - Administrator Approval Handler
/// 
/// Intent:
/// Handles highest level approval requests requiring administrator authority.
/// Final level of healthcare approval workflow with no limit restrictions.
/// 
/// @see Patterns.GoF.Behavioral.ConcreteHandler
/// @see Patterns.Examples.ApprovalRequest
/// @since 1.0.0
Class Patterns.Examples.AdministratorApprovalHandler Extends Patterns.GoF.Behavioral.ConcreteHandler
{

/// Administrators have no hard limit but use soft limit for alerts
Parameter SOFTLIMIT = 100000;

/// Maximum risk level (no limit for administrators)
Parameter MAXRISK = 999;

/// Constructor
/// 
/// @return %Status
Method %OnNew() As %Status
{
    Set tSC = ##super("Administrator", 40)  // Priority 40 (last in chain)
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        // Configure handler
        Do ..SetConfig("role", "Administrator")
        Do ..SetConfig("maxAmount", 999999999)  // Effectively unlimited
        Do ..SetConfig("maxRisk", ..#MAXRISK)
        Do ..SetConfig("department", "Executive")
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
    
    // Administrators can handle all requests as last resort
    // They are the final authority in the chain
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
        
        // Check how many approvers have already reviewed
        Set tApproverCount = tApprovalRequest.ApprovedBy.Count()
        Set tRequiresBoard = 0
        
        // Check if this requires board approval
        If tApprovalRequest.Amount > 200000 {
            Set tRequiresBoard = 1
        }
        
        // Check for special cases
        If tApprovalRequest.ApprovalType = "Emergency" {
            // Emergency always approved by administrator
            Do tApprovalRequest.AddApprover(..HandlerName, "Emergency administrator approval")
            Do tApprovalRequest.ApprovalConditions.Insert("Emergency review board meeting required within 7 days")
            
            Set tResponse = ##class(Response).Success(
                "Emergency approved by " _ ..HandlerName,
                "Emergency request approved for $" _ $FNumber(tApprovalRequest.Amount, ",", 2)
            )
            Do tResponse.SetMetadata("approvalType", "Emergency-Executive")
            Do tResponse.SetMetadata("boardReview", "Required")
            
            // Log high-value emergency approval
            Do ..LogExecutiveApproval(tApprovalRequest)
            Quit
        }
        
        // Check if this is an escalation
        If tApproverCount >= 3 {
            // This went through the full chain
            Do ..ReviewEscalation(tApprovalRequest)
        }
        
        // Make executive decision
        Set tApprovalDecision = ..MakeExecutiveDecision(tApprovalRequest)
        
        If tApprovalDecision {
            // Approve the request
            Do tApprovalRequest.AddApprover(..HandlerName, "Executive approval granted")
            
            // Add conditions based on amount and review requirements
            If tRequiresBoard {
                Do tApprovalRequest.ApprovalConditions.Insert("Requires board ratification within 30 days")
                Do tApprovalRequest.ApprovalConditions.Insert("Submit executive summary to board")
            }
            If tApprovalRequest.Amount > ..#SOFTLIMIT {
                Do tApprovalRequest.ApprovalConditions.Insert("Requires annual audit review")
                Do tApprovalRequest.ApprovalConditions.Insert("Submit ROI analysis within 90 days")
            }
            If tApprovalRequest.RiskLevel = 4 {
                Do tApprovalRequest.ApprovalConditions.Insert("Requires comprehensive risk assessment")
                Do tApprovalRequest.ApprovalConditions.Insert("Monthly progress reports to executive committee")
            }
            
            Set tResponse = ##class(Response).Success(
                "Approved by " _ ..HandlerName,
                "Executive approval for $" _ $FNumber(tApprovalRequest.Amount, ",", 2)
            )
            Do tResponse.SetMetadata("approvalLevel", "Administrator")
            Do tResponse.SetMetadata("executiveReview", "Complete")
            
            // Note if this requires board notification
            If tRequiresBoard {
                Do tResponse.SetMetadata("boardNotification", "Required")
            }
            
            // Log executive approval
            Do ..LogExecutiveApproval(tApprovalRequest)
        } Else {
            // Reject the request
            Set tReason = ..GetConfig("rejectionReason", "Does not meet executive criteria")
            Do tApprovalRequest.Reject(..HandlerName, tReason)
            
            Set tResponse = ##class(Response).Failure("Executive rejection: " _ tReason)
            Do tResponse.SetMetadata("finalDecision", "Rejected")
            
            // Log executive rejection
            Do ..LogExecutiveRejection(tApprovalRequest, tReason)
        }
    }
    Catch ex {
        Set tResponse = ##class(Response).Failure("Processing error: " _ ex.Name, 500)
        Do tResponse.AddError(ex.Name _ " at " _ ex.Location)
    }
    
    Quit tResponse
}

/// Make executive decision on approval
/// 
/// @param pRequest The approval request
/// @return %Boolean approval decision
Method MakeExecutiveDecision(pRequest As ApprovalRequest) As %Boolean [ Private ]
{
    // Complex decision logic would go here
    // For demo, approve if:
    // 1. Has gone through proper channels (at least 2 approvers)
    // 2. Not a repeated rejected request
    // 3. Risk/reward ratio is acceptable
    
    If pRequest.ApprovedBy.Count() < 1 {
        // Hasn't gone through proper channels
        Do ..SetConfig("rejectionReason", "Requires lower-level review first")
        Quit 0
    }
    
    // Check risk/reward
    Set tRiskScore = pRequest.RiskLevel * 25  // Convert to percentage
    Set tAmountScore = $Select(
        pRequest.Amount < 10000: 10,
        pRequest.Amount < 50000: 30,
        pRequest.Amount < 100000: 50,
        pRequest.Amount < 500000: 75,
        1: 90
    )
    
    // Decision based on combined score
    Set tTotalScore = 100 - ((tRiskScore + tAmountScore) / 2)
    
    If tTotalScore < 25 {
        Do ..SetConfig("rejectionReason", "Risk/cost ratio too high")
        Quit 0
    }
    
    Quit 1
}

/// Review escalation path
/// 
/// @param pRequest The approval request
Method ReviewEscalation(pRequest As ApprovalRequest) [ Private ]
{
    // Log escalation review
    Set ^Patterns.Chain.Escalations($Increment(^Patterns.Chain.Escalations)) = {
        "requestId": (pRequest.RequestId),
        "amount": (pRequest.Amount),
        "type": (pRequest.ApprovalType),
        "approvers": (pRequest.ApprovedBy.Count()),
        "timestamp": ($ZDateTime($ZTimeStamp, 3))
    }.%ToJSON()
}

/// Log executive approval
/// 
/// @param pRequest The approval request
Method LogExecutiveApproval(pRequest As ApprovalRequest) [ Private ]
{
    Set tLogId = $Increment(^Patterns.Chain.ExecutiveLog)
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "action") = "APPROVED"
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "requestId") = pRequest.RequestId
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "amount") = pRequest.Amount
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "type") = pRequest.ApprovalType
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "timestamp") = $ZDateTime($ZTimeStamp, 3)
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "approver") = ..HandlerName
}

/// Log executive rejection
/// 
/// @param pRequest The approval request
/// @param pReason Rejection reason
Method LogExecutiveRejection(pRequest As ApprovalRequest, pReason As %String) [ Private ]
{
    Set tLogId = $Increment(^Patterns.Chain.ExecutiveLog)
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "action") = "REJECTED"
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "requestId") = pRequest.RequestId
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "amount") = pRequest.Amount
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "type") = pRequest.ApprovalType
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "reason") = pReason
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "timestamp") = $ZDateTime($ZTimeStamp, 3)
    Set ^Patterns.Chain.ExecutiveLog(tLogId, "approver") = ..HandlerName
}

/// Get handler description
/// 
/// @return %String
Method GetDescription() As %String
{
    Quit "Administrator Approval Handler (No limit, final authority)"
}

/// Get executive approval statistics
/// 
/// @return %DynamicObject
ClassMethod GetApprovalStatistics() As %DynamicObject
{
    Set tStats = {}
    
    Set tApproved = 0
    Set tRejected = 0
    Set tTotalAmount = 0
    
    Set tLogId = ""
    For {
        Set tLogId = $Order(^Patterns.Chain.ExecutiveLog(tLogId))
        Quit:tLogId=""
        
        Set tAction = $Get(^Patterns.Chain.ExecutiveLog(tLogId, "action"))
        If tAction = "APPROVED" {
            Set tApproved = tApproved + 1
            Set tTotalAmount = tTotalAmount + $Get(^Patterns.Chain.ExecutiveLog(tLogId, "amount"), 0)
        } ElseIf tAction = "REJECTED" {
            Set tRejected = tRejected + 1
        }
    }
    
    Set tStats.totalDecisions = tApproved + tRejected
    Set tStats.approved = tApproved
    Set tStats.rejected = tRejected
    Set tStats.approvalRate = $Select(
        tStats.totalDecisions > 0: $FNumber((tApproved / tStats.totalDecisions) * 100, "", 2) _ "%",
        1: "N/A"
    )
    Set tStats.totalApprovedAmount = tTotalAmount
    Set tStats.averageApprovedAmount = $Select(
        tApproved > 0: $FNumber(tTotalAmount / tApproved, ",", 2),
        1: 0
    )
    
    Quit tStats
}

}
