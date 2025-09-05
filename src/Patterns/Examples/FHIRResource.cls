/// Healthcare Example - FHIR Resource Base Class
/// 
/// Abstract base class representing FHIR (Fast Healthcare Interoperability Resources) resources
/// This is the target interface that HL7 messages will be adapted to
/// 
/// @see Patterns.Examples.HL7Message
/// @see Patterns.Examples.HL7ToFHIRAdapter
/// @since 1.0.0
Class Patterns.Examples.FHIRResource Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// FHIR version
Parameter FHIRVERSION = "R4";

// ===== PROPERTIES =====

/// Resource type (e.g., "Patient", "Observation", "Encounter")
Property ResourceType As %String;

/// Resource ID
Property ResourceID As %String;

/// Resource metadata
Property Meta As %DynamicObject;

/// Resource content as JSON
Property ResourceContent As %DynamicObject;

/// Last updated timestamp
Property LastUpdated As %TimeStamp;

/// Resource version
Property Version As %String;

// ===== ABSTRACT METHODS =====

/// Convert resource to JSON representation
Method ToJSON() As %DynamicObject [ Abstract ]
{
    Quit ""
}

/// Validate resource against FHIR specifications
Method Validate() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Get resource summary
Method GetSummary() As %String [ Abstract ]
{
    Quit ""
}

// ===== PUBLIC METHODS =====

/// Initialize base FHIR resource properties
Method %OnNew(pResourceType As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pResourceType '= "" {
            Set ..ResourceType = pResourceType
        }
        
        // Initialize metadata
        Set ..Meta = {}
        Set ..ResourceContent = {}
        
        // Generate resource ID if not provided
        If ..ResourceID = "" {
            Set ..ResourceID = $SYSTEM.Util.CreateGUID()
        }
        
        // Set timestamp
        Set ..LastUpdated = $ZDATETIME($HOROLOG, 3)
        Set ..Version = "1"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Set resource content from JSON string
Method SetContentFromJSON(pJSONString As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..ResourceContent = {}.%FromJSON(pJSONString)
        
        // Update metadata
        If ..ResourceContent.%IsDefined("id") {
            Set ..ResourceID = ..ResourceContent.id
        }
        If ..ResourceContent.%IsDefined("resourceType") {
            Set ..ResourceType = ..ResourceContent.resourceType
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get resource as formatted JSON string
Method ToJSONString(pFormat As %Boolean = 1) As %String
{
    Set tJSON = ..ToJSON()
    If $ISOBJECT(tJSON) {
        // %ToJSON() on a %DynamicObject returns a string representation
        // The pFormat parameter is ignored as %DynamicObject always returns compact JSON
        Quit tJSON.%ToJSON()
    }
    Quit "{}"
}

/// Display resource information
Method Display()
{
    Write "FHIR Resource Information:", !
    Write "  Type: ", ..ResourceType, !
    Write "  ID: ", ..ResourceID, !
    Write "  Version: ", ..Version, !
    Write "  Last Updated: ", ..LastUpdated, !
    Write "  Content: ", !
    Write ..ToJSONString(1), !
}

}
