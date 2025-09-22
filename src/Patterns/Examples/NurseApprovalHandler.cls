/// Chain of Responsibility Pattern - Nurse Approval Handler
/// 
/// Intent:
/// Handles approval requests within nurse authority limits.
/// First level of healthcare approval workflow.
/// 
/// @see Patterns.GoF.Behavioral.ConcreteHandler
/// @see Patterns.Examples.ApprovalRequest
/// @since 1.0.0
Class Patterns.Examples.NurseApprovalHandler Extends Patterns.GoF.Behavioral.ConcreteHandler
{

/// Maximum amount a nurse can approve
Parameter MAXAMOUNT = 500;

/// Maximum risk level a nurse can approve
Parameter MAXRISK = 1;

/// Constructor
/// 
/// @return %Status
Method %OnNew() As %Status
{
    Set tSC = ##super("Nurse", 10)  // Priority 10 (highest - first in chain)
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        // Configure handler
        Do ..SetConfig("role", "Nurse")
        Do ..SetConfig("maxAmount", ..#MAXAMOUNT)
        Do ..SetConfig("maxRisk", ..#MAXRISK)
        Do ..SetConfig("department", "Nursing")
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
    
    // Check if within nurse approval limits
    If tApprovalRequest.Amount > ..#MAXAMOUNT Quit 0
    If tApprovalRequest.RiskLevel > ..#MAXRISK Quit 0
    
    // Nurses can only approve medication and basic equipment
    Set tValidTypes = ",Medication,Equipment,"
    If tValidTypes '[ ("," _ tApprovalRequest.ApprovalType _ ",") Quit 0
    
    // Check if not already rejected
    If tApprovalRequest.ApprovalStatus = "Rejected" Quit 0
    
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
        
        // Additional validation for nurse level
        If tApprovalRequest.Department = "Emergency" && 'tApprovalRequest.IsUrgent {
            // Emergency department requests must be marked urgent
            Set tResponse = ##class(Patterns.GoF.Behavioral.Response).Failure("Emergency department requests must be marked as urgent")
            Do tApprovalRequest.Reject(..HandlerName, "Non-urgent emergency request")
            Quit
        }
        
        // Check delegation (nurses can have temporary higher authority)
        Set tDelegatedLimit = ..GetConfig("delegatedLimit", ..#MAXAMOUNT)
        If tApprovalRequest.Amount <= tDelegatedLimit {
            // Approve the request
            Do tApprovalRequest.AddApprover(..HandlerName, "Approved within nurse authority")
            
            // Add any conditions
            If tApprovalRequest.Amount > (..#MAXAMOUNT * 0.8) {
                Do tApprovalRequest.ApprovalConditions.Insert("Requires documentation within 24 hours")
            }
            
            Set tResponse = ##class(Patterns.GoF.Behavioral.Response).Success(
                "Approved by " _ ..HandlerName,
                "Request approved for $" _ $FNumber(tApprovalRequest.Amount, ",", 2)
            )
            Do tResponse.SetMetadata("approvalLevel", "Nurse")
            Do tResponse.SetMetadata("approvalLimit", ..#MAXAMOUNT)
        } Else {
            // Cannot approve - will pass to next handler
            Set tResponse = ##class(Patterns.GoF.Behavioral.Response).%New(0, "Amount exceeds nurse approval limit")
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
    Quit "Nurse Approval Handler (Max: $" _ ..#MAXAMOUNT _ ", Risk: " _ ..#MAXRISK _ ")"
}

}
