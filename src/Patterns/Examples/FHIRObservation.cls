/// Healthcare Example - FHIR Observation Resource
/// 
/// Concrete implementation of FHIRResource for Observation resources
/// Represents clinical observations like vital signs, lab results, etc.
/// 
/// @see Patterns.Examples.FHIRResource
/// @see Patterns.Examples.HL7ToFHIRAdapter
/// @since 1.0.0
Class Patterns.Examples.FHIRObservation Extends Patterns.Examples.FHIRResource
{

// ===== PROPERTIES =====

/// Observation status (registered, preliminary, final, amended, etc.)
Property Status As %String;

/// Observation code (LOINC, SNOMED, etc.)
Property Code As %String;

/// Code system (e.g., "http://loinc.org")
Property CodeSystem As %String;

/// Display name for the code
Property CodeDisplay As %String;

/// Subject/Patient ID reference
Property SubjectID As %String;

/// Observation date/time
Property EffectiveDateTime As %String;

/// Observation value (numeric)
Property ValueQuantity As %Numeric;

/// Value unit (e.g., "mg/dL", "mmHg")
Property ValueUnit As %String;

/// Value string (for non-numeric values)
Property ValueString As %String;

/// Reference range low
Property ReferenceRangeLow As %Numeric;

/// Reference range high
Property ReferenceRangeHigh As %Numeric;

/// Interpretation (e.g., "H" for high, "L" for low, "N" for normal)
Property Interpretation As %String;

/// Performer (who performed the observation)
Property Performer As %String;

/// Category (e.g., "vital-signs", "laboratory")
Property Category As %String;

// ===== CONSTRUCTORS =====

/// Initialize FHIR Observation resource
Method %OnNew() As %Status
{
    Set tSC = ##super("Observation")
    Set ..Status = "final"  // Default status
    Quit tSC
}

// ===== IMPLEMENTED ABSTRACT METHODS =====

/// Convert observation to FHIR JSON representation
Method ToJSON() As %DynamicObject
{
    Set tJSON = {}
    
    // Set resource type and ID
    Set tJSON.resourceType = "Observation"
    Set tJSON.id = ..ResourceID
    
    // Add metadata
    Set tJSON.meta = {}
    Set tJSON.meta.lastUpdated = ..LastUpdated
    Set tJSON.meta.versionId = ..Version
    
    // Add status
    Set tJSON.status = ..Status
    
    // Add category
    If ..Category '= "" {
        Set tJSON.category = []
        Set tCategory = {}
        Set tCategory.coding = []
        Set tCoding = {}
        
        If ..Category = "vital-signs" {
            Set tCoding.system = "http://terminology.hl7.org/CodeSystem/observation-category"
            Set tCoding.code = "vital-signs"
            Set tCoding.display = "Vital Signs"
        } ElseIf ..Category = "laboratory" {
            Set tCoding.system = "http://terminology.hl7.org/CodeSystem/observation-category"
            Set tCoding.code = "laboratory"
            Set tCoding.display = "Laboratory"
        }
        
        Do tCategory.coding.%Push(tCoding)
        Do tJSON.category.%Push(tCategory)
    }
    
    // Add code
    Set tJSON.code = {}
    Set tJSON.code.coding = []
    Set tCodeObj = {}
    If ..CodeSystem '= "" Set tCodeObj.system = ..CodeSystem
    If ..Code '= "" Set tCodeObj.code = ..Code
    If ..CodeDisplay '= "" Set tCodeObj.display = ..CodeDisplay
    Do tJSON.code.coding.%Push(tCodeObj)
    
    // Add subject reference
    If ..SubjectID '= "" {
        Set tJSON.subject = {}
        Set tJSON.subject.reference = "Patient/" _ ..SubjectID
    }
    
    // Add effective date/time
    If ..EffectiveDateTime '= "" {
        Set tJSON.effectiveDateTime = ..EffectiveDateTime
    }
    
    // Add value (either quantity or string)
    If ..ValueQuantity '= "" {
        Set tJSON.valueQuantity = {}
        Set tJSON.valueQuantity.value = ..ValueQuantity
        If ..ValueUnit '= "" {
            Set tJSON.valueQuantity.unit = ..ValueUnit
        }
    } ElseIf ..ValueString '= "" {
        Set tJSON.valueString = ..ValueString
    }
    
    // Add reference range
    If (..ReferenceRangeLow '= "") || (..ReferenceRangeHigh '= "") {
        Set tJSON.referenceRange = []
        Set tRange = {}
        If ..ReferenceRangeLow '= "" {
            Set tRange.low = {}
            Set tRange.low.value = ..ReferenceRangeLow
            If ..ValueUnit '= "" Set tRange.low.unit = ..ValueUnit
        }
        If ..ReferenceRangeHigh '= "" {
            Set tRange.high = {}
            Set tRange.high.value = ..ReferenceRangeHigh
            If ..ValueUnit '= "" Set tRange.high.unit = ..ValueUnit
        }
        Do tJSON.referenceRange.%Push(tRange)
    }
    
    // Add interpretation
    If ..Interpretation '= "" {
        Set tJSON.interpretation = []
        Set tInterp = {}
        Set tInterp.coding = []
        Set tInterpCode = {}
        Set tInterpCode.system = "http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation"
        
        Set tInterpCode.code = ..Interpretation
        Set tInterpCode.display = $CASE(..Interpretation,
            "H":"High",
            "L":"Low",
            "N":"Normal",
            "A":"Abnormal",
            "HH":"Critical high",
            "LL":"Critical low",
            :..Interpretation)
        
        Do tInterp.coding.%Push(tInterpCode)
        Do tJSON.interpretation.%Push(tInterp)
    }
    
    // Add performer
    If ..Performer '= "" {
        Set tJSON.performer = []
        Set tPerformer = {}
        Set tPerformer.display = ..Performer
        Do tJSON.performer.%Push(tPerformer)
    }
    
    Quit tJSON
}

/// Validate observation resource against FHIR specifications
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Basic validation rules
        If ..ResourceType '= "Observation" {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "Invalid resource type for Observation"))
        }
        
        // Status is required
        If ..Status = "" {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "Observation status is required"))
        }
        
        // Validate status values
        Set tValidStatuses = "registered,preliminary,final,amended,corrected,cancelled,entered-in-error,unknown"
        If '(","_tValidStatuses_",")[(","_..Status_",") {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "Invalid observation status: "_..Status))
        }
        
        // Code is required
        If ..Code = "" {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "Observation code is required"))
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get observation summary
Method GetSummary() As %String
{
    Set tSummary = "Observation: "
    
    If ..CodeDisplay '= "" {
        Set tSummary = tSummary _ ..CodeDisplay
    } Else {
        Set tSummary = tSummary _ ..Code
    }
    
    If ..ValueQuantity '= "" {
        Set tSummary = tSummary _ " = " _ ..ValueQuantity
        If ..ValueUnit '= "" {
            Set tSummary = tSummary _ " " _ ..ValueUnit
        }
    } ElseIf ..ValueString '= "" {
        Set tSummary = tSummary _ " = " _ ..ValueString
    }
    
    If ..Interpretation '= "" {
        Set tSummary = tSummary _ " (" _ ..Interpretation _ ")"
    }
    
    If ..EffectiveDateTime '= "" {
        Set tSummary = tSummary _ " @ " _ ..EffectiveDateTime
    }
    
    Quit tSummary
}

// ===== PUBLIC METHODS =====

/// Set observation data from HL7 OBX segment
Method SetFromOBXSegment(pOBXSegment As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Parse OBX segment fields (pipe-delimited)
        // OBX|1|NM|Code^Description^System|...|Value|Unit|Reference Range|Interpretation|...
        
        // Field 3: Observation Identifier
        Set tObsID = $PIECE(pOBXSegment, "|", 4)
        If tObsID '= "" {
            Set ..Code = $PIECE(tObsID, "^", 1)
            Set ..CodeDisplay = $PIECE(tObsID, "^", 2)
            Set tCodeSystem = $PIECE(tObsID, "^", 3)
            If tCodeSystem = "LN" {
                Set ..CodeSystem = "http://loinc.org"
            } ElseIf tCodeSystem '= "" {
                Set ..CodeSystem = tCodeSystem
            }
        }
        
        // Field 2: Value Type (NM=Numeric, ST=String, etc.)
        Set tValueType = $PIECE(pOBXSegment, "|", 3)
        
        // Field 5: Observation Value
        Set tValue = $PIECE(pOBXSegment, "|", 6)
        If tValue '= "" {
            If (tValueType = "NM") || (tValueType = "SN") {
                Set ..ValueQuantity = +tValue  // Convert to numeric
            } Else {
                Set ..ValueString = tValue
            }
        }
        
        // Field 6: Units
        Set ..ValueUnit = $PIECE(pOBXSegment, "|", 7)
        
        // Field 7: Reference Range
        Set tRefRange = $PIECE(pOBXSegment, "|", 8)
        If tRefRange '= "" {
            // Parse range like "70-100" or "<100" or ">70"
            If tRefRange [ "-" {
                Set ..ReferenceRangeLow = +$PIECE(tRefRange, "-", 1)
                Set ..ReferenceRangeHigh = +$PIECE(tRefRange, "-", 2)
            } ElseIf $EXTRACT(tRefRange, 1) = "<" {
                Set ..ReferenceRangeHigh = +$EXTRACT(tRefRange, 2, *)
            } ElseIf $EXTRACT(tRefRange, 1) = ">" {
                Set ..ReferenceRangeLow = +$EXTRACT(tRefRange, 2, *)
            }
        }
        
        // Field 8: Abnormal Flags
        Set tAbnormal = $PIECE(pOBXSegment, "|", 9)
        If tAbnormal '= "" {
            Set ..Interpretation = tAbnormal
        }
        
        // Field 11: Observation Result Status
        Set tStatus = $PIECE(pOBXSegment, "|", 12)
        If tStatus '= "" {
            Set ..Status = $CASE(tStatus,
                "F":"final",
                "P":"preliminary",
                "C":"corrected",
                "X":"cancelled",
                :"final")
        } Else {
            Set ..Status = "final"
        }
        
        // Field 14: Date/Time of Observation
        Set tDateTime = $PIECE(pOBXSegment, "|", 15)
        If tDateTime '= "" {
            // Convert HL7 datetime (YYYYMMDDHHMMSS) to FHIR format
            If $LENGTH(tDateTime) >= 8 {
                Set ..EffectiveDateTime = $EXTRACT(tDateTime, 1, 4) _ "-" _ 
                                         $EXTRACT(tDateTime, 5, 6) _ "-" _ 
                                         $EXTRACT(tDateTime, 7, 8)
                If $LENGTH(tDateTime) >= 14 {
                    Set ..EffectiveDateTime = ..EffectiveDateTime _ "T" _
                                             $EXTRACT(tDateTime, 9, 10) _ ":" _
                                             $EXTRACT(tDateTime, 11, 12) _ ":" _
                                             $EXTRACT(tDateTime, 13, 14)
                }
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Create sample observation for testing (glucose level)
ClassMethod CreateSampleGlucoseObservation() As Patterns.Examples.FHIRObservation
{
    Set tObs = ##class(Patterns.Examples.FHIRObservation).%New()
    
    Set tObs.Status = "final"
    Set tObs.Category = "laboratory"
    Set tObs.Code = "2339-0"
    Set tObs.CodeSystem = "http://loinc.org"
    Set tObs.CodeDisplay = "Glucose [Mass/volume] in Blood"
    Set tObs.SubjectID = "patient-123"
    Set tObs.EffectiveDateTime = "2024-01-15T08:30:00"
    Set tObs.ValueQuantity = 95
    Set tObs.ValueUnit = "mg/dL"
    Set tObs.ReferenceRangeLow = 70
    Set tObs.ReferenceRangeHigh = 100
    Set tObs.Interpretation = "N"
    Set tObs.Performer = "Lab Tech"
    
    Quit tObs
}

/// Create sample vital signs observation (blood pressure)
ClassMethod CreateSampleBloodPressureObservation() As Patterns.Examples.FHIRObservation
{
    Set tObs = ##class(Patterns.Examples.FHIRObservation).%New()
    
    Set tObs.Status = "final"
    Set tObs.Category = "vital-signs"
    Set tObs.Code = "85354-9"
    Set tObs.CodeSystem = "http://loinc.org"
    Set tObs.CodeDisplay = "Blood pressure panel"
    Set tObs.SubjectID = "patient-456"
    Set tObs.EffectiveDateTime = "2024-01-15T14:20:00"
    Set tObs.ValueString = "120/80"
    Set tObs.ValueUnit = "mmHg"
    Set tObs.Interpretation = "N"
    Set tObs.Performer = "Nurse Johnson"
    
    Quit tObs
}

}
