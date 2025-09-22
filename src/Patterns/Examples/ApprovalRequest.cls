/// Chain of Responsibility Pattern - Healthcare Approval Request
/// 
/// Intent:
/// Specialized request class for healthcare approval workflows.
/// Contains approval-specific data like amount, risk level, and approval type.
/// 
/// @see Patterns.GoF.Behavioral.Request
/// @since 1.0.0
Class Patterns.Examples.ApprovalRequest Extends Patterns.GoF.Behavioral.Request
{

/// Amount requiring approval (in dollars)
Property Amount As %Decimal;

/// Risk level (1=Low, 2=Medium, 3=High, 4=Critical)
Property RiskLevel As %Integer [ InitialExpression = 1 ];

/// Approval type (Medication, Procedure, Equipment, Budget, Emergency)
Property ApprovalType As %String;

/// Patient identifier (if applicable)
Property PatientId As %String;

/// Department requesting approval
Property Department As %String;

/// Reason for the request
Property Reason As %String(MAXLEN = "");

/// Urgency flag
Property IsUrgent As %Boolean [ InitialExpression = 0 ];

/// Approval status (Pending, Approved, Rejected, Escalated)
Property ApprovalStatus As %String [ InitialExpression = "Pending" ];

/// Approved by (list of approvers)
Property ApprovedBy As list Of %String;

/// Rejected by (if applicable)
Property RejectedBy As %String;

/// Rejection reason
Property RejectionReason As %String;

/// Conditions attached to approval
Property ApprovalConditions As list Of %String;

/// SLA deadline for approval
Property DeadlineTimestamp As %TimeStamp;

/// Constructor with approval-specific parameters
/// 
/// @param pType Request type (should be "Approval")
/// @param pData JSON string with approval data
/// @return %Status
Method %OnNew(pType As %String = "Approval", pData As %String = "") As %Status
{
    Set tSC = ##super(pType, pData)
    If $$$ISERR(tSC) Quit tSC
    
    Try {
        // Parse data if provided as JSON
        If pData '= "" {
            Set tDataObj = {}.%FromJSON(pData)
            If $ISOBJECT(tDataObj) {
                If tDataObj.%IsDefined("approvalType") Set ..ApprovalType = tDataObj.approvalType
                If tDataObj.%IsDefined("amount") Set ..Amount = tDataObj.amount
                If tDataObj.%IsDefined("riskLevel") Set ..RiskLevel = tDataObj.riskLevel
            }
        }
        
        // Set priority based on risk level and amount
        Set ..Priority = ..CalculatePriority()
        
        // Set deadline based on urgency and risk
        Set ..DeadlineTimestamp = ..CalculateDeadline()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Calculate priority based on amount and risk
/// 
/// @return %Integer priority (1-4)
Method CalculatePriority() As %Integer [ Private ]
{
    Set tPriority = 2  // Default normal priority
    
    // High amounts increase priority
    If ..Amount > 100000 {
        Set tPriority = 4
    } ElseIf ..Amount > 50000 {
        Set tPriority = 3
    }
    
    // Risk level affects priority
    If ..RiskLevel >= 3 {
        Set tPriority = $SELECT(tPriority < 3: 3, 1: tPriority)
    }
    
    // Urgent requests get highest priority
    If ..IsUrgent {
        Set tPriority = 4
    }
    
    Quit tPriority
}

/// Calculate deadline based on priority and urgency
/// 
/// @return %TimeStamp
Method CalculateDeadline() As %TimeStamp [ Private ]
{
    Set tNow = $ZTimeStamp
    Set tDeadlineHours = 24  // Default 24 hours
    
    // Adjust based on priority
    If ..Priority = 4 {
        Set tDeadlineHours = 1  // 1 hour for critical
    } ElseIf ..Priority = 3 {
        Set tDeadlineHours = 4  // 4 hours for high
    } ElseIf ..Priority = 2 {
        Set tDeadlineHours = 24  // 24 hours for normal
    } Else {
        Set tDeadlineHours = 72  // 72 hours for low
    }
    
    // Calculate deadline
    Set tDeadline = tNow + (tDeadlineHours * 3600)
    Quit $ZDateTime(tDeadline, 3)
}

/// Check if approval is within limit for a role
/// 
/// @param pRole The role checking approval
/// @param pLimit The approval limit for the role
/// @return %Boolean
Method IsWithinLimit(pRole As %String, pLimit As %Decimal) As %Boolean
{
    // Check monetary limit
    If ..Amount > pLimit Quit 0
    
    // Additional checks based on role and risk
    If pRole = "Nurse" && (..RiskLevel > 2) Quit 0
    If pRole = "Doctor" && (..RiskLevel > 3) Quit 0
    
    Quit 1
}

/// Add an approver to the list
/// 
/// @param pApprover Name/ID of approver
/// @param pConditions Optional conditions
Method AddApprover(pApprover As %String, pConditions As %String = "")
{
    Do ..ApprovedBy.Insert(pApprover _ " at " _ $ZDateTime($ZTimeStamp, 3))
    
    If pConditions '= "" {
        Do ..ApprovalConditions.Insert(pConditions)
    }
    
    // Update status if not already approved
    If ..ApprovalStatus = "Pending" {
        Set ..ApprovalStatus = "Approved"
    }
}

/// Reject the request
/// 
/// @param pRejector Name/ID of person rejecting
/// @param pReason Reason for rejection
Method Reject(pRejector As %String, pReason As %String)
{
    Set ..RejectedBy = pRejector _ " at " _ $ZDateTime($ZTimeStamp, 3)
    Set ..RejectionReason = pReason
    Set ..ApprovalStatus = "Rejected"
}

/// Escalate the request
/// 
/// @param pReason Reason for escalation
Method Escalate(pReason As %String)
{
    Set ..ApprovalStatus = "Escalated"
    Do ..SetContext("escalationReason", pReason)
    Set ..Priority = 4  // Escalated requests get highest priority
}

/// Check if deadline has passed
/// 
/// @return %Boolean
Method IsOverdue() As %Boolean
{
    Set tNow = $ZTimeStamp
    Set tDeadline = $ZDateH(..DeadlineTimestamp, 3)
    Quit (tNow > tDeadline)
}

/// Get approval summary
/// 
/// @return %String
Method GetApprovalSummary() As %String
{
    Set tSummary = "ApprovalRequest["
    Set tSummary = tSummary _ "Type=" _ ..ApprovalType
    Set tSummary = tSummary _ ", Amount=$" _ $FNumber(..Amount, ",", 2)
    Set tSummary = tSummary _ ", Risk=" _ ..RiskLevel
    Set tSummary = tSummary _ ", Status=" _ ..ApprovalStatus
    
    If ..Department '= "" Set tSummary = tSummary _ ", Dept=" _ ..Department
    If ..PatientId '= "" Set tSummary = tSummary _ ", Patient=" _ ..PatientId
    If ..IsUrgent Set tSummary = tSummary _ ", URGENT"
    If ..IsOverdue() Set tSummary = tSummary _ ", OVERDUE"
    
    Set tSummary = tSummary _ "]"
    
    Quit tSummary
}

/// Validate the approval request
/// 
/// @return %Status
Method ValidateData() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate approval type
        Set tValidTypes = ",Medication,Procedure,Equipment,Budget,Emergency,"
        If tValidTypes '[ ("," _ ..ApprovalType _ ",") {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid approval type: " _ ..ApprovalType)
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Validate amount
        If ..Amount < 0 {
            Set tSC = $$$ERROR($$$GeneralError, "Amount cannot be negative")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Validate risk level
        If (..RiskLevel < 1) || (..RiskLevel > 4) {
            Set tSC = $$$ERROR($$$GeneralError, "Risk level must be between 1 and 4")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Validate required fields
        If ..Department = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Department is required")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        If ..Reason = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Reason is required")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Convert to audit log entry
/// 
/// @return %DynamicObject
Method ToAuditEntry() As %DynamicObject
{
    Set tAudit = {}
    Set tAudit.requestId = ..RequestId
    Set tAudit.timestamp = $ZDateTime($ZTimeStamp, 3)
    Set tAudit.approvalType = ..ApprovalType
    Set tAudit.amount = ..Amount
    Set tAudit.riskLevel = ..RiskLevel
    Set tAudit.department = ..Department
    Set tAudit.patientId = ..PatientId
    Set tAudit.status = ..ApprovalStatus
    Set tAudit.initiator = ..Initiator
    Set tAudit.reason = ..Reason
    Set tAudit.isUrgent = ..IsUrgent
    Set tAudit.deadline = ..DeadlineTimestamp
    
    // Add approval chain
    Set tApprovers = []
    Set tCount = ..ApprovedBy.Count()
    For i=1:1:tCount {
        Do tApprovers.%Push(..ApprovedBy.GetAt(i))
    }
    Set tAudit.approvers = tApprovers
    
    If ..RejectedBy '= "" {
        Set tAudit.rejectedBy = ..RejectedBy
        Set tAudit.rejectionReason = ..RejectionReason
    }
    
    // Add conditions
    Set tConditions = []
    Set tCount = ..ApprovalConditions.Count()
    For i=1:1:tCount {
        Do tConditions.%Push(..ApprovalConditions.GetAt(i))
    }
    Set tAudit.conditions = tConditions
    
    Quit tAudit
}

/// Create a test approval request
/// 
/// @param pType Type of approval
/// @param pAmount Amount to approve
/// @return ApprovalRequest
ClassMethod CreateTestRequest(pType As %String = "Medication", pAmount As %Decimal = 1000) As ApprovalRequest
{
    Set tData = {}
    Set tData.approvalType = pType
    Set tData.amount = pAmount
    // Set risk level based on amount - this allows proper handler selection
    If pAmount <= 500 {
        Set tData.riskLevel = 1  // Low risk for small amounts - Nurse can handle
    } ElseIf pAmount <= 10000 {
        Set tData.riskLevel = 2  // Medium risk - Doctor can handle
    } ElseIf pAmount <= 50000 {
        Set tData.riskLevel = 3  // High risk - Department Head can handle
    } Else {
        Set tData.riskLevel = 4  // Critical risk - Administrator must handle
    }
    
    Set tRequest = ##class(ApprovalRequest).%New("Approval", tData.%ToJSON())
    Set tRequest.Department = "Cardiology"
    Set tRequest.PatientId = "PAT-" _ $Random(10000)
    Set tRequest.Reason = "Test approval request for " _ pType
    Set tRequest.Initiator = "TestUser"
    
    Quit tRequest
}

}
