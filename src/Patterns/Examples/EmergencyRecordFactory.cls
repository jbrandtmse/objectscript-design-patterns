/// Concrete Factory for creating Emergency Department Records
/// Implements the Factory Method pattern for emergency visit records
Class Patterns.Examples.EmergencyRecordFactory Extends Patterns.Examples.PatientRecordFactory
{

/// Factory identification
Parameter FACTORYTYPE = "EMERGENCY";

Parameter DEFAULTDEPARTMENT = "Emergency Department";

/// Create an EmergencyRecord instance
/// This is the factory method implementation that creates the specific product type
Method CreateRecord() As Patterns.Examples.PatientRecord
{
        // Create a new emergency record
        Set record = ##class(Patterns.Examples.EmergencyRecord).%New()
        
        // Generate unique RecordID with timestamp and random component
        Set record.RecordID = "ER-" _ $ZDT($H, 8) _ "-" _ $Random(10000)
        
        // Set emergency-specific defaults
        Set record.RecordType = "EMERGENCY"
        Set record.Department = ..#DEFAULTDEPARTMENT
        
        // Initialize emergency-specific fields
        Set record.TriageLevel = ..AssignTriageLevel()
        Set record.ChiefComplaint = ..GenerateChiefComplaint()
        Set record.ArrivalTime = $ZTime($H, 1)
        Set record.ArrivalMode = ..DetermineArrivalMode()
        Set record.VitalSigns = ..RecordVitalSigns()
        Set record.SeverityIndex = ..CalculateSeverityIndex(record.TriageLevel)
        
        // Set Severity property based on triage level
        If record.TriageLevel <= 2 {
            Set record.Severity = "Critical"
        } ElseIf record.TriageLevel = 3 {
            Set record.Severity = "Urgent"
        } ElseIf record.TriageLevel = 4 {
            Set record.Severity = "Less Urgent"
        } Else {
            Set record.Severity = "Non-Urgent"
        }
        
        Set record.TraumaAlert = ..CheckTraumaAlert(record.TriageLevel, record.ChiefComplaint)
        Set record.WaitTimeMinutes = ..EstimateWaitTime(record.TriageLevel)
        Set record.Disposition = "Pending Evaluation"
        
        // Set priority based on triage level (higher priority for more severe cases)
        Set record.Priority = 11 - (record.TriageLevel * 2)  // Level 1 = Priority 9, Level 5 = Priority 1
        
        // Register the record in the global registry
        If record.RecordID '= "" {
            Set ^PatientRecordRegistry(record.RecordID, "Type") = record.RecordType
            Set ^PatientRecordRegistry(record.RecordID, "Created") = $ZDT($H, 3)
        }
        
        Quit record
}

/// Assign triage level (1-5, with 1 being most critical)
Method AssignTriageLevel() As %Integer [ Private ]
{
        // Simulate realistic distribution of triage levels
        // Level 1: 2%, Level 2: 10%, Level 3: 35%, Level 4: 40%, Level 5: 13%
        Set rand = $Random(100)
        
        If rand < 2 Quit 1        // Critical
        If rand < 12 Quit 2       // Emergent
        If rand < 47 Quit 3       // Urgent
        If rand < 87 Quit 4       // Less Urgent
        Quit 5                    // Non-Urgent
}

/// Generate chief complaint
Method GenerateChiefComplaint() As %String [ Private ]
{
        Set complaints = $ListBuild(
            "Chest Pain", "Shortness of Breath", "Abdominal Pain",
            "Headache", "Trauma/Injury", "Fever", "Back Pain",
            "Laceration", "Allergic Reaction", "Dizziness",
            "Nausea/Vomiting", "Motor Vehicle Accident"
        )
        Set index = $Random($ListLength(complaints)) + 1
        Quit $List(complaints, index)
}

/// Determine arrival mode
Method DetermineArrivalMode() As %String [ Private ]
{
        Set modes = $ListBuild("Walk-in", "Ambulance", "Private Vehicle", 
                               "Police", "Air Transport", "Transfer")
        Set weights = $ListBuild(40, 25, 20, 5, 3, 7)  // Percentage weights
        
        Set rand = $Random(100)
        Set cumulative = 0
        Set result = "Walk-in"  // Default
        
        For i=1:1:$ListLength(modes) {
            Set cumulative = cumulative + $List(weights, i)
            If rand < cumulative {
                Set result = $List(modes, i)
                Quit  // Exit the loop
            }
        }
        
        Quit result
}

/// Record vital signs as JSON string
Method RecordVitalSigns() As %String [ Private ]
{
        Set vitals = {}
        Set vitals."bloodPressure" = (90 + $Random(60)) _ "/" _ (60 + $Random(40))
        Set vitals."heartRate" = 60 + $Random(80)
        Set vitals."temperature" = $Justify(97.0 + ($Random(40) / 10), 0, 1)
        Set vitals."respiratoryRate" = 12 + $Random(16)
        Set vitals."oxygenSaturation" = 90 + $Random(11)
        Set vitals."painScale" = $Random(11)  // 0-10 scale
        
        Quit vitals.%ToJSON()
}

/// Calculate severity index based on triage level
Method CalculateSeverityIndex(pTriageLevel As %Integer) As %Decimal [ Private ]
{
        // Severity index from 0.0 to 1.0 (1.0 being most severe)
        Quit $Justify(1.0 - ((pTriageLevel - 1) * 0.25), 0, 2)
}

/// Check if trauma alert should be activated
Method CheckTraumaAlert(pTriageLevel As %Integer, pChiefComplaint As %String) As %Boolean [ Private ]
{
        // Trauma alert for level 1-2 with trauma-related complaints
        If pTriageLevel <= 2 {
            If (pChiefComplaint [ "Trauma") || (pChiefComplaint [ "Accident") {
                Quit 1
            }
        }
        Quit 0
}

/// Estimate wait time based on triage level
Method EstimateWaitTime(pTriageLevel As %Integer) As %Integer [ Private ]
{
        // Wait time in minutes based on triage level
        If pTriageLevel = 1 Quit 0      // Immediate
        If pTriageLevel = 2 Quit $Random(15)  // 0-15 minutes
        If pTriageLevel = 3 Quit 15 + $Random(45)  // 15-60 minutes
        If pTriageLevel = 4 Quit 60 + $Random(120)  // 1-3 hours
        If pTriageLevel = 5 Quit 120 + $Random(180)  // 2-5 hours
        
        Quit 30  // Default
}

/// Override to provide factory-specific description
Method GetFactoryDescription() As %String
{
        Quit "Emergency Record Factory - Creates records for emergency department visits with triage prioritization"
}

/// Get statistics specific to emergency records
Method GetFactoryStatistics() As %String
{
        Set stats = ##super()
        
        // Add emergency-specific stats
        Set lwbs = ..CalculateLWBSRate()  // Left Without Being Seen
        Set avgBoardingTime = ..CalculateAverageBoardingTime()
        
        Set stats = stats _ " | LWBS: " _ $Justify(lwbs, 0, 1) _ "%"
        Set stats = stats _ " | Avg Boarding: " _ avgBoardingTime _ " hrs"
        
        Quit stats
}

/// Calculate Left Without Being Seen rate
Method CalculateLWBSRate() As %Decimal [ Private ]
{
        // Simulate LWBS rate between 2-8%
        Quit 2 + ($Random(7))
}

/// Calculate average boarding time in hours
Method CalculateAverageBoardingTime() As %Decimal [ Private ]
{
        // Simulate boarding time between 2-8 hours
        Quit $Justify(2 + ($Random(61) / 10), 0, 1)
}

}
