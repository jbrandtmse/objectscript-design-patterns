/// Concrete Factory for creating Inpatient Records
/// Implements the Factory Method pattern for admitted patient records
Class Patterns.Examples.InpatientRecordFactory Extends Patterns.Examples.PatientRecordFactory
{

Parameter FACTORYTYPE = "INPATIENT";

Parameter DEFAULTDEPARTMENT = "Medical/Surgical";

/// Factory identification
/// Create an InpatientRecord instance
/// This is the factory method implementation that creates the specific product type
Method CreateRecord() As Patterns.Examples.PatientRecord
{
        // Create a new inpatient record
        Set record = ##class(Patterns.Examples.InpatientRecord).%New()
        
        // Generate unique RecordId with timestamp and random component
        Set record.RecordId = "IP-" _ $ZDT($H, 8) _ "-" _ $Random(10000)
        
        // Set inpatient-specific defaults
        Set record.RecordType = "INPATIENT"
        Set record.Department = ..#DEFAULTDEPARTMENT
        Set record.Priority = 5  // Medium priority by default
        
        // Initialize admission-specific fields
        Set record.RoomNumber = ..AssignRoom()
        Set record.BedNumber = ..AssignBed(record.RoomNumber)
        Set record.AdmissionDiagnosis = "Pending Evaluation"
        Set record.ExpectedLengthOfStay = 3  // Default 3 days
        Set record.AuthorizationCode = ..GenerateAuthCode()
        
        // Register in global for tracking
        If record.RecordId '= "" {
            Set ^PatientRecordRegistry(record.RecordId, "Type") = record.RecordType
            Set ^PatientRecordRegistry(record.RecordId, "Created") = $ZDT($H, 3)
        }
        
        Quit record
}

/// Assign a room number (simulation)
Method AssignRoom() As %String [ Private ]
{
        // Simulate room assignment logic
        Set floor = $Random(5) + 1  // Floors 1-5
        Set roomNum = $Random(30) + 1  // Rooms 1-30 per floor
        
        Quit floor _ "-" _ $Justify(roomNum, 2, 0)  // e.g., "3-01" for floor 3, room 01
}

/// Assign a bed within a room
Method AssignBed(pRoomNumber As %String) As %String [ Private ]
{
        // Most rooms have 2 beds (A and B)
        Set bedLetter = $Select($Random(2)=0:"A", 1:"B")
        Quit bedLetter
}

/// Generate authorization code for insurance
Method GenerateAuthCode() As %String [ Private ]
{
        Set prefix = "AUTH"
        Set timestamp = $Piece($ZDateTime($H, 3), ":", 1, 2)
        Set random = $Random(10000)
        
        Quit prefix _ "-" _ $Replace(timestamp, ":", "") _ "-" _ $Justify(random, 4, 0)
}

/// Override to provide factory-specific description
Method GetFactoryDescription() As %String
{
        Quit "Inpatient Record Factory - Creates records for admitted patients requiring overnight care"
}

/// Get statistics specific to inpatient records
Method GetFactoryStatistics() As %String
{
        Set stats = ##super()
        
        // Add inpatient-specific stats
        Set occupancyRate = ..CalculateOccupancyRate()
        Set avgLOS = ..CalculateAverageLengthOfStay()
        
        Set stats = stats _ " | Occupancy: " _ $Justify(occupancyRate, 0, 1) _ "%"
        Set stats = stats _ " | Avg LOS: " _ $Justify(avgLOS, 0, 1) _ " days"
        
        Quit stats
}

/// Calculate simulated occupancy rate
Method CalculateOccupancyRate() As %Decimal [ Private ]
{
        // Simulate occupancy between 70-95%
        Quit 70 + ($Random(26))
}

/// Calculate average length of stay
Method CalculateAverageLengthOfStay() As %Decimal [ Private ]
{
        // Simulate average LOS between 2.5 and 5.5 days
        Quit 2.5 + ($Random(31) / 10)
}

}
