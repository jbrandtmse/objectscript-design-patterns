/// Gang of Four Interpreter Pattern - Healthcare Alert Expression
/// <p>Expression for generating and managing clinical alerts based on conditions.</p>
Class Patterns.Examples.AlertExpression Extends Patterns.Examples.ClinicalRuleExpression
{

/// Alert type (LAB_CRITICAL, DRUG_INTERACTION, ALLERGY, VITAL_SIGN, PROTOCOL)
Property AlertType As %String;

/// Condition expression to evaluate
Property Condition As Patterns.GoF.Behavioral.Expression;

/// Alert message template
Property MessageTemplate As %String;

/// Actions to take when alert triggers
Property Actions As list Of %String;

/// Constructor
Method %OnNew(pAlertType As %String = "", pCondition As Patterns.GoF.Behavioral.Expression = "") As %Status
{
    Set ..AlertType = pAlertType
    Set ..Condition = pCondition
    Set ..MessageTemplate = "Clinical alert: {type} - {details}"
    Quit $$$OK
}

/// Interpret the alert expression
Method Interpret(pContext As Patterns.GoF.Behavioral.Context) As %String
{
    Set tResult = 0
    
    Try {
        // Evaluate the condition
        If $IsObject(..Condition) {
            Set tConditionResult = ..Condition.Interpret(pContext)
            
            // Convert to boolean
            If tConditionResult '= "" && tConditionResult '= 0 {
                Set tResult = 1
                
                // Generate and add alert
                Set tAlert = ..FormatAlert(pContext)
                
                // Cast to ClinicalContext if possible
                If pContext.%ClassName(1) = "ClinicalContext" {
                    Do pContext.AddAlert(tAlert)
                    
                    // Execute actions
                    Do ..ExecuteActions(pContext)
                }
            }
        }
        
        // Add debug info
        If $IsObject(pContext) && pContext.DebugMode {
            Do pContext.AddDebugInfo("Alert "_..AlertType_" triggered: "_tResult)
        }
        
    } Catch ex {
        Set tResult = 0
        If $IsObject(pContext) && pContext.DebugMode {
            Do pContext.AddDebugInfo("Alert expression error: "_ex.DisplayString())
        }
    }
    
    Quit tResult
}

/// Format the alert message
Method FormatAlert(pContext As Patterns.GoF.Behavioral.Context) As %String [ Private ]
{
    Set tMessage = ..MessageTemplate
    Set tMessage = $Replace(tMessage, "{type}", ..AlertType)
    Set tMessage = $Replace(tMessage, "{severity}", ..Severity)
    Set tMessage = $Replace(tMessage, "{description}", ..Description)
    
    // Add timestamp
    Set tTimestamp = $ZDateTime($Horolog, 3)
    Set tMessage = "["_tTimestamp_"] "_tMessage
    
    Quit tMessage
}

/// Execute alert actions
Method ExecuteActions(pContext As Patterns.Examples.ClinicalContext) [ Private ]
{
    Set tKey = ""
    For {
        Set tAction = ..Actions.GetNext(.tKey)
        If tKey = "" Quit
        
        // Execute action based on type
        If tAction = "PAGE_DOCTOR" {
            Do ..PageDoctor(pContext)
        } ElseIf tAction = "LOG_CRITICAL" {
            Do ..LogCritical(pContext)
        } ElseIf tAction = "NOTIFY_NURSE" {
            Do ..NotifyNurse(pContext)
        } ElseIf tAction = "ESCALATE" {
            Do ..Escalate(pContext)
        }
    }
}

/// Page the attending doctor
Method PageDoctor(pContext As Patterns.Examples.ClinicalContext) [ Private ]
{
    If pContext.DebugMode {
        Do pContext.AddDebugInfo("ACTION: Paging attending doctor")
    }
}

/// Log critical event
Method LogCritical(pContext As Patterns.Examples.ClinicalContext) [ Private ]
{
    If pContext.DebugMode {
        Do pContext.AddDebugInfo("ACTION: Logging critical event")
    }
}

/// Notify nurse station
Method NotifyNurse(pContext As Patterns.Examples.ClinicalContext) [ Private ]
{
    If pContext.DebugMode {
        Do pContext.AddDebugInfo("ACTION: Notifying nurse station")
    }
}

/// Escalate to supervisor
Method Escalate(pContext As Patterns.Examples.ClinicalContext) [ Private ]
{
    If pContext.DebugMode {
        Do pContext.AddDebugInfo("ACTION: Escalating to supervisor")
    }
}

/// Generate clinical alert (overrides base class)
Method GenerateAlert(pContext As Patterns.Examples.ClinicalContext) As %DynamicObject
{
    Set tAlert = ##class(%DynamicObject).%New()
    Set tAlert.rule = ..AlertType
    Set tAlert.severity = ..Severity
    Set tAlert.message = ..FormatAlert(pContext)
    Set tAlert.timestamp = $ZDATETIME($HOROLOG,3)
    If $IsObject(pContext) {
        Set tAlert.patientId = pContext.PatientId
    }
    Quit tAlert
}

/// Get string representation
Method ToString() As %String
{
    Quit "Alert["_..AlertType_"]: "_..Description
}

/// Factory method for creating alert expressions
ClassMethod Create(pAlertType As %String, pCondition As Patterns.GoF.Behavioral.Expression, pSeverity As %String = "WARNING") As AlertExpression
{
    Set tAlert = ##class(AlertExpression).%New(pAlertType, pCondition)
    Set tAlert.Severity = pSeverity
    Quit tAlert
}

/// Create critical lab value alert
ClassMethod CreateLabCriticalAlert(pLabExpression As Patterns.Examples.LabValueExpression) As AlertExpression
{
    Set tAlert = ..Create("LAB_CRITICAL", pLabExpression, "CRITICAL")
    Do tAlert.Actions.Insert("PAGE_DOCTOR")
    Do tAlert.Actions.Insert("LOG_CRITICAL")
    Set tAlert.MessageTemplate = "CRITICAL LAB VALUE: {details}"
    Quit tAlert
}

/// Create drug interaction alert
ClassMethod CreateDrugInteractionAlert(pMedExpression As Patterns.Examples.MedicationRuleExpression) As AlertExpression
{
    Set tAlert = ..Create("DRUG_INTERACTION", pMedExpression, "CRITICAL")
    Do tAlert.Actions.Insert("NOTIFY_NURSE")
    Do tAlert.Actions.Insert("LOG_CRITICAL")
    Set tAlert.MessageTemplate = "DRUG INTERACTION DETECTED: {details}"
    Quit tAlert
}

/// Create vital sign alert
ClassMethod CreateVitalSignAlert(pCondition As Patterns.GoF.Behavioral.Expression) As AlertExpression
{
    Set tAlert = ..Create("VITAL_SIGN", pCondition, "WARNING")
    Do tAlert.Actions.Insert("NOTIFY_NURSE")
    Set tAlert.MessageTemplate = "VITAL SIGN ALERT: {details}"
    Quit tAlert
}

}
