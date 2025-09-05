/// Healthcare Example - HL7 to FHIR Adapter
/// 
/// Adapter class that converts HL7 v2 messages to FHIR resources
/// This implements the Adapter pattern to bridge between legacy HL7 format
/// and modern FHIR standard
/// 
/// @see Patterns.Examples.HL7Message
/// @see Patterns.Examples.FHIRResource
/// @see Patterns.Examples.FHIRPatient
/// @see Patterns.Examples.FHIRObservation
/// @since 1.0.0
Class Patterns.Examples.HL7ToFHIRAdapter Extends %RegisteredObject
{

// ===== PROPERTIES =====

/// HL7 Message being adapted
Property HL7Message As Patterns.Examples.HL7Message;

/// Collection of converted FHIR resources
Property FHIRResources As list Of Patterns.Examples.FHIRResource;

/// Conversion errors log
Property ConversionErrors As list Of %String;

/// Conversion statistics
Property ConversionStats As %DynamicObject;

// ===== CONSTRUCTORS =====

/// Initialize adapter with optional HL7 message
Method %OnNew(pHL7Message As Patterns.Examples.HL7Message = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $ISOBJECT(pHL7Message) {
            Set ..HL7Message = pHL7Message
        }
        
        // Initialize conversion statistics
        Set ..ConversionStats = {}
        Set ..ConversionStats."total_segments" = 0
        Set ..ConversionStats."converted_resources" = 0
        Set ..ConversionStats."errors" = 0
        Set ..ConversionStats."start_time" = $ZDATETIME($HOROLOG, 3)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC ADAPTER METHODS =====

/// Main adapter method - Convert HL7 message to FHIR resources
Method Convert(pHL7Message As Patterns.Examples.HL7Message = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Use provided message or stored message
        If $ISOBJECT(pHL7Message) {
            Set ..HL7Message = pHL7Message
        }
        
        If '$ISOBJECT(..HL7Message) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "No HL7 message to convert"))
        }
        
        // Parse the HL7 message first
        Set tSC = ..HL7Message.ParseMessage()
        If $$$ISERR(tSC) Quit
        
        // Clear previous resources
        Do ..FHIRResources.Clear()
        Do ..ConversionErrors.Clear()
        
        // Update statistics
        Set ..ConversionStats."total_segments" = ..HL7Message.GetSegmentCount()
        
        // Convert based on message type
        Set tMSH = ..HL7Message.GetSegment("MSH", 1)
        If tMSH '= "" {
            Set tMessageType = $PIECE($PIECE(tMSH, "|", 9), "^", 1)
            Set tEventType = $PIECE($PIECE(tMSH, "|", 9), "^", 2)
            
            // Route to appropriate conversion method
            If tMessageType = "ADT" {
                Set tSC = ..ConvertADTMessage()
            } ElseIf tMessageType = "ORU" {
                Set tSC = ..ConvertORUMessage()
            } ElseIf tMessageType = "ORM" {
                Set tSC = ..ConvertORMMessage()
            } Else {
                Do ..ConversionErrors.Insert("Unsupported message type: "_tMessageType)
                Set ..ConversionStats.errors = ..ConversionStats.errors + 1
            }
        }
        
        // Update final statistics
        Set ..ConversionStats."converted_resources" = ..FHIRResources.Count()
        Set ..ConversionStats."end_time" = $ZDATETIME($HOROLOG, 3)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Do ..ConversionErrors.Insert("Conversion error: "_ex.DisplayString())
        Set ..ConversionStats.errors = ..ConversionStats.errors + 1
    }
    
    Quit tSC
}

/// Convert ADT (Admit/Discharge/Transfer) message
Method ConvertADTMessage() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Convert PID segment to FHIR Patient
        Set tSC = ..ConvertPatient()
        If $$$ISERR(tSC) {
            Do ..ConversionErrors.Insert("Failed to convert patient: "_$SYSTEM.Status.GetErrorText(tSC))
            Set ..ConversionStats.errors = ..ConversionStats.errors + 1
        }
        
        // Convert PV1 segment to FHIR Encounter (if needed)
        // This could be extended to create Encounter resources
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Convert ORU (Observation Result) message
Method ConvertORUMessage() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Convert PID segment to FHIR Patient
        Set tSC = ..ConvertPatient()
        If $$$ISERR(tSC) {
            Do ..ConversionErrors.Insert("Failed to convert patient: "_$SYSTEM.Status.GetErrorText(tSC))
            Set ..ConversionStats.errors = ..ConversionStats.errors + 1
        }
        
        // Convert all OBX segments to FHIR Observations
        Set tOBXCount = ..HL7Message.GetSegmentCount("OBX")
        For i = 1:1:tOBXCount {
            Set tSC = ..ConvertObservation(i)
            If $$$ISERR(tSC) {
                Do ..ConversionErrors.Insert("Failed to convert observation "_i_": "_$SYSTEM.Status.GetErrorText(tSC))
                Set ..ConversionStats.errors = ..ConversionStats.errors + 1
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Convert ORM (Order Message) message
Method ConvertORMMessage() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Convert PID to Patient
        Set tSC = ..ConvertPatient()
        
        // Could be extended to convert ORC/OBR to ServiceRequest resources
        Do ..ConversionErrors.Insert("ORM message conversion not fully implemented")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Convert PID segment to FHIR Patient resource
Method ConvertPatient() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Get PID segment
        Set tPID = ..HL7Message.GetSegment("PID", 1)
        If tPID = "" {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "No PID segment found"))
        }
        
        // Create FHIR Patient resource
        Set tPatient = ##class(Patterns.Examples.FHIRPatient).%New()
        
        // Use helper method to parse PID
        Set tSC = tPatient.SetFromPIDSegment(tPID)
        If $$$ISERR(tSC) Quit
        
        // Validate the patient resource
        Set tSC = tPatient.Validate()
        If $$$ISERR(tSC) Quit
        
        // Add to collection
        Do ..FHIRResources.Insert(tPatient)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Convert OBX segment to FHIR Observation resource
Method ConvertObservation(pIndex As %Integer = 1) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Get OBX segment
        Set tOBX = ..HL7Message.GetSegment("OBX", pIndex)
        If tOBX = "" {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "No OBX segment found at index "_pIndex))
        }
        
        // Create FHIR Observation resource
        Set tObservation = ##class(Patterns.Examples.FHIRObservation).%New()
        
        // Use helper method to parse OBX
        Set tSC = tObservation.SetFromOBXSegment(tOBX)
        If $$$ISERR(tSC) Quit
        
        // Link to patient if available
        If ..FHIRResources.Count() > 0 {
            Set tFirstResource = ..FHIRResources.GetAt(1)
            If tFirstResource.%ClassName(1) = "Patterns.Examples.FHIRPatient" {
                Set tObservation.SubjectID = tFirstResource.ResourceID
            }
        }
        
        // Validate the observation resource
        Set tSC = tObservation.Validate()
        If $$$ISERR(tSC) Quit
        
        // Add to collection
        Do ..FHIRResources.Insert(tObservation)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== UTILITY METHODS =====

/// Get all converted FHIR resources as JSON bundle
Method GetFHIRBundle() As %DynamicObject
{
    Set tBundle = {}
    Set tBundle.resourceType = "Bundle"
    Set tBundle.type = "collection"
    Set tBundle.total = ..FHIRResources.Count()
    Set tBundle.entry = []
    
    For i = 1:1:..FHIRResources.Count() {
        Set tResource = ..FHIRResources.GetAt(i)
        If $ISOBJECT(tResource) {
            Set tEntry = {}
            Set tEntry.resource = tResource.ToJSON()
            Do tBundle.entry.%Push(tEntry)
        }
    }
    
    Quit tBundle
}

/// Display conversion results
Method DisplayResults()
{
    Write "HL7 to FHIR Conversion Results", !, !
    
    Write "Statistics:", !
    Write "  Total Segments: ", ..ConversionStats."total_segments", !
    Write "  Converted Resources: ", ..ConversionStats."converted_resources", !
    Write "  Errors: ", ..ConversionStats.errors, !
    Write "  Start Time: ", ..ConversionStats."start_time", !
    Write "  End Time: ", ..ConversionStats."end_time", !, !
    
    If ..ConversionErrors.Count() > 0 {
        Write "Conversion Errors:", !
        For i = 1:1:..ConversionErrors.Count() {
            Write "  ", i, ". ", ..ConversionErrors.GetAt(i), !
        }
        Write !
    }
    
    Write "Converted FHIR Resources:", !
    For i = 1:1:..FHIRResources.Count() {
        Set tResource = ..FHIRResources.GetAt(i)
        Write "  ", i, ". ", tResource.GetSummary(), !
    }
}

// ===== CLASS METHODS FOR DEMONSTRATION =====

/// Demonstrate HL7 to FHIR conversion with ADT message
ClassMethod DemonstrateADTConversion() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "=== HL7 to FHIR Adapter Pattern Demo (ADT) ===", !, !
        
        // Create sample HL7 ADT message
        Set tHL7 = ##class(Patterns.Examples.HL7Message).CreateSampleADTMessage()
        Write "Original HL7 ADT Message:", !
        Do tHL7.Display()
        Write !
        
        // Create adapter and convert
        Set tAdapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7)
        Set tSC = tAdapter.Convert()
        If $$$ISERR(tSC) {
            Write "Conversion failed: ", $SYSTEM.Status.GetErrorText(tSC), !
            Quit
        }
        
        // Display results
        Do tAdapter.DisplayResults()
        Write !
        
        // Display FHIR Bundle
        Write "FHIR Bundle JSON:", !
        Set tBundle = tAdapter.GetFHIRBundle()
        Write tBundle.%ToJSON(), !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write "Error: ", ex.DisplayString(), !
    }
    
    Quit tSC
}

/// Demonstrate HL7 to FHIR conversion with ORU message
ClassMethod DemonstrateORUConversion() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "=== HL7 to FHIR Adapter Pattern Demo (ORU) ===", !, !
        
        // Create sample HL7 ORU message
        Set tHL7 = ##class(Patterns.Examples.HL7Message).CreateSampleORUMessage()
        Write "Original HL7 ORU Message:", !
        Do tHL7.Display()
        Write !
        
        // Create adapter and convert
        Set tAdapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7)
        Set tSC = tAdapter.Convert()
        If $$$ISERR(tSC) {
            Write "Conversion failed: ", $SYSTEM.Status.GetErrorText(tSC), !
            Quit
        }
        
        // Display results
        Do tAdapter.DisplayResults()
        Write !
        
        // Display individual FHIR resources
        Write "Individual FHIR Resources:", !, !
        For i = 1:1:tAdapter.FHIRResources.Count() {
            Set tResource = tAdapter.FHIRResources.GetAt(i)
            Write "Resource ", i, " (", tResource.ResourceType, "):", !
            Write tResource.ToJSONString(1), !, !
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write "Error: ", ex.DisplayString(), !
    }
    
    Quit tSC
}

}
