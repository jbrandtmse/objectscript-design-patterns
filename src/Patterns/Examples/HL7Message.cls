/// Healthcare Example - HL7 v2 Message Representation
/// 
/// Represents HL7 v2.x messages using pipe-delimited format
/// This is the adaptee class that needs to be adapted to FHIR format
/// 
/// @see Patterns.Examples.FHIRResource
/// @see Patterns.Examples.HL7ToFHIRAdapter
/// @since 1.0.0
Class Patterns.Examples.HL7Message Extends %RegisteredObject
{

// ===== PROPERTIES =====

/// Raw HL7 message content
Property MessageContent As %String(MAXLEN = 32000);

/// Message type (e.g., "ADT^A01", "ORU^R01")
Property MessageType As %String;

/// Message control ID for tracking
Property MessageControlID As %String;

/// Parsed segments stored as multidimensional array
Property Segments [ MultiDimensional ];

/// Sending application
Property SendingApplication As %String;

/// Sending facility
Property SendingFacility As %String;

/// Message timestamp
Property MessageDateTime As %TimeStamp;

// ===== CONSTRUCTORS =====

/// Initialize HL7 message with content
Method %OnNew(pMessageContent As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pMessageContent '= "" {
            Set ..MessageContent = pMessageContent
            Set tSC = ..ParseMessage()
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Parse HL7 message into segments
Method ParseMessage() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear existing segments
        Kill ..Segments
        
        // Split message into segments (CR is segment separator)
        Set tSegmentCount = $LENGTH(..MessageContent, $CHAR(13))
        
        For i = 1:1:tSegmentCount {
            Set tSegment = $PIECE(..MessageContent, $CHAR(13), i)
            Continue:tSegment=""
            
            // Get segment type (first 3 characters)
            Set tSegType = $EXTRACT(tSegment, 1, 3)
            
            // Store segment
            Set ..Segments(tSegType, $INCREMENT(..Segments(tSegType))) = tSegment
            
            // Parse MSH segment for header info
            If tSegType = "MSH" {
                Set tSC = ..ParseMSHSegment(tSegment)
                If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Parse MSH segment for header information
Method ParseMSHSegment(pSegment As %String) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // MSH uses | as field separator (after MSH|)
        Set tFieldSep = $EXTRACT(pSegment, 4)
        
        // Parse sending application (field 3)
        Set ..SendingApplication = $PIECE(pSegment, tFieldSep, 3)
        
        // Parse sending facility (field 4)
        Set ..SendingFacility = $PIECE(pSegment, tFieldSep, 4)
        
        // Parse message timestamp (field 7)
        Set tTimestamp = $PIECE(pSegment, tFieldSep, 7)
        If tTimestamp '= "" {
            // Convert HL7 timestamp format (YYYYMMDDHHMMSS) to TimeStamp
            // Extract date (YYYYMMDD) and time (HHMMSS) parts
            Set tDate = $EXTRACT(tTimestamp, 1, 8)
            Set tTime = $EXTRACT(tTimestamp, 9, 14)
            
            // Convert date part
            If tDate '= "" {
                // Build a formatted string that $ZDATETIMEH can handle
                Set tYear = $EXTRACT(tDate, 1, 4)
                Set tMonth = $EXTRACT(tDate, 5, 6)
                Set tDay = $EXTRACT(tDate, 7, 8)
                
                // Initialize time components
                Set tHours = "00", tMins = "00", tSecs = "00"
                
                // Extract time if present
                If tTime '= "" {
                    If $LENGTH(tTime) >= 2 Set tHours = $EXTRACT(tTime, 1, 2)
                    If $LENGTH(tTime) >= 4 Set tMins = $EXTRACT(tTime, 3, 4)
                    If $LENGTH(tTime) >= 6 Set tSecs = $EXTRACT(tTime, 5, 6)
                }
                
                // Build ISO format string: YYYY-MM-DD HH:MM:SS
                Set tISODateTime = tYear _ "-" _ tMonth _ "-" _ tDay _ " " _ tHours _ ":" _ tMins _ ":" _ tSecs
                
                // Convert to internal format and then to display format
                Set tInternalDT = $ZDATETIMEH(tISODateTime, 3)
                Set ..MessageDateTime = $ZDATETIME(tInternalDT, 3)
            }
        }
        
        // Parse message type (field 9)
        Set ..MessageType = $PIECE(pSegment, tFieldSep, 9)
        
        // Parse message control ID (field 10)
        Set ..MessageControlID = $PIECE(pSegment, tFieldSep, 10)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get specific segment by type and occurrence
Method GetSegment(pSegmentType As %String, pOccurrence As %Integer = 1) As %String
{
    Set tSegment = ""
    
    If $DATA(..Segments(pSegmentType, pOccurrence)) {
        Set tSegment = ..Segments(pSegmentType, pOccurrence)
    }
    
    Quit tSegment
}

/// Get field value from segment
Method GetFieldValue(pSegmentType As %String, pFieldNumber As %Integer, pOccurrence As %Integer = 1) As %String
{
    Set tValue = ""
    
    Set tSegment = ..GetSegment(pSegmentType, pOccurrence)
    If tSegment '= "" {
        // Use | as field separator
        Set tValue = $PIECE(tSegment, "|", pFieldNumber)
    }
    
    Quit tValue
}

/// Get count of segments by type (or total if no type specified)
Method GetSegmentCount(pSegmentType As %String = "") As %Integer
{
    Set tCount = 0
    
    If pSegmentType = "" {
        // Count all segments
        Set tSegType = ""
        For {
            Set tSegType = $ORDER(..Segments(tSegType))
            Quit:tSegType=""
            
            Set tOcc = ""
            For {
                Set tOcc = $ORDER(..Segments(tSegType, tOcc))
                Quit:tOcc=""
                Set tCount = tCount + 1
            }
        }
    } Else {
        // Count specific segment type
        If $DATA(..Segments(pSegmentType)) {
            Set tOcc = ""
            For {
                Set tOcc = $ORDER(..Segments(pSegmentType, tOcc))
                Quit:tOcc=""
                Set tCount = tCount + 1
            }
        }
    }
    
    Quit tCount
}

/// Create sample ADT (Admit/Discharge/Transfer) message
ClassMethod CreateSampleADTMessage() As HL7Message
{
    Set tMessage = ##class(HL7Message).%New()
    
    // Build sample HL7 ADT^A01 (Patient Admission) message
    Set tContent = "MSH|^~\&|HIS|RoyalHospital|ADT|RoyalHospital|20250904120000||ADT^A01|MSG00001|P|2.5|||AL|NE" _ $CHAR(13)
    Set tContent = tContent _ "EVN|A01|20250904120000" _ $CHAR(13)
    Set tContent = tContent _ "PID|1||123456789^^^Hospital^MR||Doe^John^A||19800515|M|||123 Main St^^Boston^MA^02101^USA||(617)555-0123|||M|CAT|987654321" _ $CHAR(13)
    Set tContent = tContent _ "PV1|1|I|ICU^001^01^RoyalHospital|E|||^Smith^Robert^J^^Dr.|||CAR||||7|A0|||||||||||||||||||||||||20250904120000" _ $CHAR(13)
    Set tContent = tContent _ "DG1|1|ICD10|I21.0|Acute myocardial infarction|20250904120000|A" _ $CHAR(13)
    
    Set tMessage.MessageContent = tContent
    Do tMessage.ParseMessage()
    
    Quit tMessage
}

/// Create sample ORU (Observation Result) message
ClassMethod CreateSampleORUMessage() As HL7Message
{
    Set tMessage = ##class(HL7Message).%New()
    
    // Build sample HL7 ORU^R01 (Observation Result) message
    Set tContent = "MSH|^~\&|LAB|RoyalHospital|LIS|RoyalHospital|20250904140000||ORU^R01|MSG00002|P|2.5|||AL|NE" _ $CHAR(13)
    Set tContent = tContent _ "PID|1||123456789^^^Hospital^MR||Doe^John^A||19800515|M" _ $CHAR(13)
    Set tContent = tContent _ "OBR|1|845439^LAB|845439^LAB|1554-5^GLUCOSE^LN|||20250904130000" _ $CHAR(13)
    Set tContent = tContent _ "OBX|1|NM|1554-5^GLUCOSE^LN||120|mg/dL|70-110|H|||F|||20250904135500|||^Johnson^Mary^^Dr." _ $CHAR(13)
    Set tContent = tContent _ "OBX|2|NM|2160-0^CREATININE^LN||1.2|mg/dL|0.7-1.3|N|||F|||20250904135500|||^Johnson^Mary^^Dr." _ $CHAR(13)
    
    Set tMessage.MessageContent = tContent
    Do tMessage.ParseMessage()
    
    Quit tMessage
}

/// Display message information
Method Display()
{
    Write "HL7 Message Information:", !
    Write "  Type: ", ..MessageType, !
    Write "  Control ID: ", ..MessageControlID, !
    Write "  Sending App: ", ..SendingApplication, !
    Write "  Sending Facility: ", ..SendingFacility, !
    Write "  Timestamp: ", ..MessageDateTime, !
    Write "  Segments: ", !
    
    Set tSegType = ""
    For {
        Set tSegType = $ORDER(..Segments(tSegType))
        Quit:tSegType=""
        
        Set tCount = 0
        Set tOcc = ""
        For {
            Set tOcc = $ORDER(..Segments(tSegType, tOcc))
            Quit:tOcc=""
            Set tCount = tCount + 1
        }
        Write "    ", tSegType, ": ", tCount, " occurrence(s)", !
    }
}

}
