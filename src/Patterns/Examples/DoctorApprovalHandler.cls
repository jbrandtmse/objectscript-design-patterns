/// Chain of Responsibility Pattern - Doctor Approval Handler
/// 
/// Intent:
/// Handles approval requests within doctor authority limits.
/// Second level of healthcare approval workflow.
/// 
/// @see Patterns.GoF.Behavioral.ConcreteHandler
/// @see Patterns.Examples.ApprovalRequest
/// @since 1.0.0
Class Patterns.Examples.DoctorApprovalHandler Extends Patterns.GoF.Behavioral.ConcreteHandler
{

/// Maximum amount a doctor can approve
Parameter MAXAMOUNT = 10000;

/// Maximum risk level a doctor can approve
Parameter MAXRISK = 3;

/// Constructor
/// 
/// @return %Status
Method %OnNew() As %Status
{
    Set tSC = ##super("Doctor", 20)  // Priority 20 (second in chain)
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        // Configure handler
        Do ..SetConfig("role", "Doctor")
        Do ..SetConfig("maxAmount", ..#MAXAMOUNT)
        Do ..SetConfig("maxRisk", ..#MAXRISK)
        Do ..SetConfig("department", "Medical")
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
Method CanHandleSpecific(pRequest As Patterns.GoF.Behavioral.Request) As %Boolean
{
    // Must be an approval request
    If 'pRequest.%IsA("Patterns.Examples.ApprovalRequest") Quit 0
    
    // Cast to ApprovalRequest
    Set tApprovalRequest = pRequest
    
    // Check if within doctor approval limits
    If tApprovalRequest.Amount > ..#MAXAMOUNT Quit 0
    If tApprovalRequest.RiskLevel > ..#MAXRISK Quit 0
    
    // Doctors can approve medication, procedures, and equipment
    Set tValidTypes = ",Medication,Procedure,Equipment,"
    If tValidTypes '[ ("," _ tApprovalRequest.ApprovalType _ ",") Quit 0
    
    // Check if not already rejected by another doctor
    If tApprovalRequest.ApprovalStatus = "Rejected" {
        If tApprovalRequest.RejectedBy [ "Doctor" Quit 0
    }
    
    Quit 1
}

/// Process the approval request
/// 
/// @param pRequest The request to process
/// @return Response object
Method ProcessSpecific(pRequest As Patterns.GoF.Behavioral.Request) As Patterns.GoF.Behavioral.Response
{
    Set tApprovalRequest = pRequest
    Set tResponse = ##class(Patterns.GoF.Behavioral.Response).%New()
    
    Try {
        // Validate request
        Set tSC = tApprovalRequest.Validate()
        If $$$ISERR(tSC) {
            Set tResponse = ##class(Patterns.GoF.Behavioral.Response).Failure("Validation failed: " _ $System.Status.GetErrorText(tSC))
            Quit
        }
        
        // Check if escalated from nurse
        Set tEscalated = (tApprovalRequest.ApprovedBy.Count() > 0)
        
        // Additional validation for doctor level
        If tApprovalRequest.ApprovalType = "Procedure" {
            // Procedures require patient ID
            If tApprovalRequest.PatientId = "" {
                Set tResponse = ##class(Patterns.GoF.Behavioral.Response).Failure("Procedure approvals require patient ID")
                Do tApprovalRequest.Reject(..HandlerName, "Missing patient information")
                Quit
            }
            
            // High-risk procedures need additional review
            If tApprovalRequest.RiskLevel >= 3 && (tApprovalRequest.Amount > 5000) {
                // Conditionally approve with requirements
                Do tApprovalRequest.AddApprover(..HandlerName, "Conditional approval")
                Do tApprovalRequest.ApprovalConditions.Insert("Requires pre-authorization review")
                Do tApprovalRequest.ApprovalConditions.Insert("Patient consent form required")
                
                Set tResponse = ##class(Patterns.GoF.Behavioral.Response).Success(
                    "Conditionally approved by " _ ..HandlerName,
                    "Request conditionally approved for $" _ $FNumber(tApprovalRequest.Amount, ",", 2)
                )
                Do tResponse.SetMetadata("approvalType", "Conditional")
                Quit
            }
        }
        
        // Check if within approval limit
        If tApprovalRequest.Amount <= ..#MAXAMOUNT {
            // Approve the request
            Do tApprovalRequest.AddApprover(..HandlerName, "Approved within doctor authority")
            
            // Add conditions based on amount
            If tApprovalRequest.Amount > 7500 {
                Do tApprovalRequest.ApprovalConditions.Insert("Requires quarterly review")
            }
            If tApprovalRequest.Amount > 5000 {
                Do tApprovalRequest.ApprovalConditions.Insert("Requires medical justification documentation")
            }
            
            Set tResponse = ##class(Patterns.GoF.Behavioral.Response).Success(
                "Approved by " _ ..HandlerName,
                "Request approved for $" _ $FNumber(tApprovalRequest.Amount, ",", 2)
            )
            Do tResponse.SetMetadata("approvalLevel", "Doctor")
            Do tResponse.SetMetadata("approvalLimit", ..#MAXAMOUNT)
            
            // Add escalation note if applicable
            If tEscalated {
                Do tResponse.SetMetadata("escalatedApproval", "true")
            }
        } Else {
            // Cannot approve - will pass to next handler
            Set tResponse = ##class(Patterns.GoF.Behavioral.Response).%New(0, "Amount exceeds doctor approval limit")
        }
    }
    Catch ex {
        Set tResponse = ##class(Patterns.GoF.Behavioral.Response).Failure("Processing error: " _ ex.Name, 500)
        Do tResponse.AddError(ex.Name _ " at " _ ex.Location)
    }
    
    Quit tResponse
}

/// Get handler description
/// 
/// @return %String
Method GetDescription() As %String
{
    Quit "Doctor Approval Handler (Max: $" _ ..#MAXAMOUNT _ ", Risk: " _ ..#MAXRISK _ ")"
}

/// Can delegate approval to another doctor
/// 
/// @param pDoctorId ID of doctor to delegate to
/// @return %Status
Method DelegateApproval(pDoctorId As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Do ..SetConfig("delegatedTo", pDoctorId)
        Do ..SetConfig("delegatedAt", $ZDateTime($ZTimeStamp, 3))
        Set ..Enabled = 0  // Disable while delegated
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
