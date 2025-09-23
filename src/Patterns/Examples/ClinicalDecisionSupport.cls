/// Gang of Four Interpreter Pattern - Clinical Decision Support Engine
/// <p>Engine for evaluating clinical rules and generating recommendations.</p>
Class Patterns.Examples.ClinicalDecisionSupport Extends %RegisteredObject
{

/// Collection of clinical rules
Property Rules As list Of Patterns.Examples.ClinicalRuleExpression;

/// Clinical context for evaluation
Property Context As Patterns.Examples.ClinicalContext;

/// Evaluation results
Property Results As %DynamicArray;

/// Constructor
Method %OnNew(pContext As Patterns.Examples.ClinicalContext = "") As %Status
{
    If $IsObject(pContext) {
        Set ..Context = pContext
    } Else {
        Set ..Context = ##class(Patterns.Examples.ClinicalContext).%New()
    }
    Set ..Results = []
    Quit $$$OK
}

/// Add a rule to the engine
Method AddRule(pRule As Patterns.Examples.ClinicalRuleExpression) As %Status
{
    Do ..Rules.Insert(pRule)
    Quit $$$OK
}

/// Evaluate all rules
Method EvaluateRules() As %Status
{
    Set tSC = $$$OK
    Set ..Results = []
    
    Try {
        // Sort rules by priority
        Set tSortedRules = ..SortRulesByPriority()
        
        // Evaluate each rule
        Set tKey = ""
        For {
            Set tRule = tSortedRules.GetNext(.tKey)
            If tKey = "" Quit
            
            Set tResult = {}
            Set tResult.rule = tRule.Description
            Set tResult.severity = tRule.Severity
            Set tResult.priority = tRule.GetPriority()
            
            // Evaluate the rule
            Set tEvalResult = tRule.Interpret(..Context)
            Set tResult.triggered = tEvalResult
            
            If tEvalResult {
                Set tResult.alert = tRule.GenerateAlert()
            }
            
            Do ..Results.%Push(tResult)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Sort rules by priority
Method SortRulesByPriority() As %ListOfObjects [ Private ]
{
    Set tSorted = ##class(%ListOfObjects).%New()
    
    // Create array indexed by priority
    Set tPriorityArray = ##class(%ArrayOfObjects).%New()
    
    Set tKey = ""
    For {
        Set tRule = ..Rules.GetNext(.tKey)
        If tKey = "" Quit
        
        Set tPriority = tRule.GetPriority()
        
        // Get list for this priority level
        If 'tPriorityArray.IsDefined(tPriority) {
            Set tList = ##class(%ListOfObjects).%New()
            Do tPriorityArray.SetAt(tList, tPriority)
        } Else {
            Set tList = tPriorityArray.GetAt(tPriority)
        }
        
        Do tList.Insert(tRule)
    }
    
    // Add to sorted list in priority order (highest first)
    For tPriority=3:-1:1 {
        If tPriorityArray.IsDefined(tPriority) {
            Set tList = tPriorityArray.GetAt(tPriority)
            Set tSubKey = ""
            For {
                Set tRule = tList.GetNext(.tSubKey)
                If tSubKey = "" Quit
                Do tSorted.Insert(tRule)
            }
        }
    }
    
    Quit tSorted
}

/// Get recommendations based on evaluation
Method GetRecommendations() As %DynamicArray
{
    Set tRecommendations = []
    
    For i=0:1:..Results.%Size()-1 {
        Set tResult = ..Results.%Get(i)
        If tResult.triggered {
            Set tRecommendation = {}
            Set tRecommendation.severity = tResult.severity
            Set tRecommendation.alert = tResult.alert
            
            // Add specific recommendations based on severity
            If tResult.severity = "CRITICAL" {
                Set tRecommendation.action = "Immediate medical attention required"
                Set tRecommendation.urgency = "STAT"
            } ElseIf tResult.severity = "WARNING" {
                Set tRecommendation.action = "Medical review recommended"
                Set tRecommendation.urgency = "URGENT"
            } Else {
                Set tRecommendation.action = "Monitor and document"
                Set tRecommendation.urgency = "ROUTINE"
            }
            
            Do tRecommendations.%Push(tRecommendation)
        }
    }
    
    Quit tRecommendations
}

/// Get summary report
Method GetSummaryReport() As %String
{
    Set tReport = ""
    Set tCritical = 0
    Set tWarning = 0
    Set tInfo = 0
    
    For i=0:1:..Results.%Size()-1 {
        Set tResult = ..Results.%Get(i)
        If tResult.triggered {
            If tResult.severity = "CRITICAL" {
                Set tCritical = tCritical + 1
            } ElseIf tResult.severity = "WARNING" {
                Set tWarning = tWarning + 1
            } Else {
                Set tInfo = tInfo + 1
            }
        }
    }
    
    Set tReport = "Clinical Decision Support Summary:"_$Char(13,10)
    Set tReport = tReport_"  Critical Alerts: "_tCritical_$Char(13,10)
    Set tReport = tReport_"  Warnings: "_tWarning_$Char(13,10)
    Set tReport = tReport_"  Information: "_tInfo_$Char(13,10)
    Set tReport = tReport_"  Total Rules Evaluated: "_..Rules.Count()_$Char(13,10)
    
    Quit tReport
}

/// Create standard rule set for patient evaluation
ClassMethod CreateStandardRuleSet() As ClinicalDecisionSupport
{
    Set tCDS = ##class(ClinicalDecisionSupport).%New()
    
    // Add lab value rules
    Do tCDS.AddRule(##class(Patterns.Examples.LabValueExpression).CreateGlucoseHighRule())
    Do tCDS.AddRule(##class(Patterns.Examples.LabValueExpression).CreateCreatinineHighRule())
    Do tCDS.AddRule(##class(Patterns.Examples.LabValueExpression).CreateHemoglobinLowRule())
    
    // Add medication rules
    Do tCDS.AddRule(##class(Patterns.Examples.MedicationRuleExpression).CreateInteractionRule("Warfarin", "Aspirin"))
    Do tCDS.AddRule(##class(Patterns.Examples.MedicationRuleExpression).CreateDosageRule("Morphine", 30, "mg"))
    
    Quit tCDS
}

/// Run full patient evaluation
Method RunPatientEvaluation(pPatientID As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Load patient data into context
        Set tSC = ..Context.LoadPatientData(pPatientID)
        If $$$ISERR(tSC) Quit
        
        // Evaluate all rules
        Set tSC = ..EvaluateRules()
        If $$$ISERR(tSC) Quit
        
        // Generate recommendations
        Set tRecommendations = ..GetRecommendations()
        
        // Log results
        If ..Context.DebugMode {
            Do ..Context.AddDebugInfo(..GetSummaryReport())
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
