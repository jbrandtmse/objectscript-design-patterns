/// Concrete Factory for creating Outpatient Records
/// Implements the Factory Method pattern for clinic visit records
Class Patterns.Examples.OutpatientRecordFactory Extends Patterns.Examples.PatientRecordFactory
{

/// Factory identification
Parameter FACTORYTYPE = "OUTPATIENT";

Parameter DEFAULTDEPARTMENT = "Outpatient Clinic";

/// Create an OutpatientRecord instance
/// This is the factory method implementation that creates the specific product type
Method CreateRecord() As Patterns.Examples.PatientRecord
{
        // Create a new outpatient record
        Set record = ##class(Patterns.Examples.OutpatientRecord).%New()
        
        // Generate unique RecordId with timestamp and random component
        Set record.RecordId = "OP-" _ $ZDT($H, 8) _ "-" _ $Random(10000)
        
        // Set outpatient-specific defaults
        Set record.RecordType = "OUTPATIENT"
        Set record.Department = ..#DEFAULTDEPARTMENT
        Set record.Priority = 3  // Lower priority for routine visits
        
        // Initialize outpatient-specific fields
        Set record.VisitType = ..DetermineVisitType()
        Set record.AppointmentTime = ..ScheduleAppointment()
        Set record.VisitReason = "Routine Follow-up"
        Set record.ReferralSource = ..GetReferralSource()
        Set record.FollowUpRequired = $Random(2)  // 50% chance of follow-up
        Set record.CopayAmount = ..CalculateCopay(record.VisitType)
        
        // Schedule next appointment if follow-up required
        If record.FollowUpRequired {
            Set record.NextAppointmentDate = ..ScheduleFollowUp()
        }
        
        // Register in global for tracking
        If record.RecordId '= "" {
            Set ^PatientRecordRegistry(record.RecordId, "Type") = record.RecordType
            Set ^PatientRecordRegistry(record.RecordId, "Created") = $ZDT($H, 3)
        }
        
        Quit record
}

/// Determine type of outpatient visit
Method DetermineVisitType() As %String [ Private ]
{
        Set types = $ListBuild("Routine Check", "Follow-up", "Consultation", 
                               "Specialist Referral", "Preventive Care", "Urgent Care")
        Set index = $Random($ListLength(types)) + 1
        Quit $List(types, index)
}

/// Schedule appointment time
Method ScheduleAppointment() As %String [ Private ]
{
        // Generate appointment times between 8 AM and 5 PM
        Set hour = 8 + $Random(10)  // 8 AM to 5 PM
        Set minute = $Select($Random(4)=0:"00", $Random(4)=1:"15", 
                            $Random(4)=2:"30", 1:"45")
        
        Quit hour _ ":" _ minute
}

/// Get referral source
Method GetReferralSource() As %String [ Private ]
{
        Set sources = $ListBuild("Primary Care", "Specialist", "Emergency Department",
                                "Self-Referral", "Insurance", "Walk-in")
        Set index = $Random($ListLength(sources)) + 1
        Quit $List(sources, index)
}

/// Calculate copay based on visit type
Method CalculateCopay(pVisitType As %String) As %Decimal [ Private ]
{
        // Simulate copay amounts based on visit type
        If pVisitType = "Routine Check" Quit 25.00
        If pVisitType = "Consultation" Quit 50.00
        If pVisitType = "Urgent Care" Quit 75.00
        If pVisitType = "Preventive Care" Quit 0.00
        If pVisitType = "Specialist Referral" Quit 60.00
        
        // Default copay
        Quit 35.00
}

/// Schedule follow-up appointment
Method ScheduleFollowUp() As %Date [ Private ]
{
        // Schedule follow-up between 1 week and 3 months from now
        Set daysAhead = 7 + $Random(84)  // 7 to 90 days
        Quit $H + daysAhead
}

/// Override to provide factory-specific description
Method GetFactoryDescription() As %String
{
        Quit "Outpatient Record Factory - Creates records for ambulatory clinic visits and consultations"
}

/// Get statistics specific to outpatient records
Method GetFactoryStatistics() As %String
{
        Set stats = ##super()
        
        // Add outpatient-specific stats
        Set noShowRate = ..CalculateNoShowRate()
        Set avgWaitTime = ..CalculateAverageWaitTime()
        
        Set stats = stats _ " | No-Show Rate: " _ $Justify(noShowRate, 0, 1) _ "%"
        Set stats = stats _ " | Avg Wait: " _ avgWaitTime _ " min"
        
        Quit stats
}

/// Calculate simulated no-show rate
Method CalculateNoShowRate() As %Decimal [ Private ]
{
        // Simulate no-show rate between 5-15%
        Quit 5 + ($Random(11))
}

/// Calculate average wait time in minutes
Method CalculateAverageWaitTime() As %Integer [ Private ]
{
        // Simulate wait time between 10-45 minutes
        Quit 10 + $Random(36)
}

}
