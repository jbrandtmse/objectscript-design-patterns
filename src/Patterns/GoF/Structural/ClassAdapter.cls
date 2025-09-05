/// Patterns.GoF.Structural.ClassAdapter
/// Class Adapter implementation - adapts Adaptee interface to Target
/// Since ObjectScript doesn't support multiple inheritance, this adapter
/// extends Target and maintains an internal Adaptee instance
/// Part of Gang of Four Adapter pattern implementation
Class Patterns.GoF.Structural.ClassAdapter Extends Patterns.GoF.Structural.Target
{

/// Class parameters for pattern metadata
Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Structural";

Parameter PATTERNNAME = "Adapter";

Parameter ADAPTERTYPE = "Class";

/// Internal adaptee instance (composition due to single inheritance limitation)
Property InternalAdaptee As Patterns.GoF.Structural.Adaptee [ Private ];

/// Constructor - initializes internal adaptee
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize the internal adaptee instance
        Set ..InternalAdaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
        If '$IsObject(..InternalAdaptee) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to create Adaptee instance")
            Quit
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Request method implementation - adapts Adaptee's SpecificRequest
/// Converts the incompatible interface to the expected Target interface
Method Request() As %String
{
    Set result = ""
    Try {
        // Delegate to the adaptee's specific request
        If $IsObject(..InternalAdaptee) {
            Set adapteeResponse = ..InternalAdaptee.SpecificRequest()
            
            // Adapt the response to match Target interface expectations
            // Parse the specific format and convert to standard format
            If adapteeResponse [ "SpecificRequest:" {
                // Extract the meaningful part after "SpecificRequest:"
                Set specificPart = $Piece(adapteeResponse, "SpecificRequest:", 2)
                Set specificPart = $ZSTRIP(specificPart, "<>W")
                
                // Convert to standard Target format
                Set result = "Adapted: " _ specificPart
            }
            Else {
                // Fallback for unexpected format
                Set result = "Adapted: " _ adapteeResponse
            }
        }
        Else {
            Set result = "Error: Adaptee not initialized"
        }
    }
    Catch ex {
        Set result = "Error: " _ ex.DisplayString()
    }
    Quit result
}

/// Extended operation using adaptee's specific functionality
/// Demonstrates adapter can expose additional adaptee capabilities
Method ProcessWithOptions(pOptions As %String = "default") As %String
{
    Set result = ""
    Try {
        If $IsObject(..InternalAdaptee) {
            // Use adaptee's specific operation with options - note it takes 2 parameters
            Set adapteeResult = ..InternalAdaptee.SpecificOperation(pOptions, "DEFAULT")
            
            // Adapt the response
            If adapteeResult [ "SpecificOperation:" {
                Set processedPart = $Piece(adapteeResult, "=> Result:", 2)
                If processedPart '= "" {
                    Set result = "Adapted Operation: " _ $ZSTRIP(processedPart, "<>W")
                }
                Else {
                    Set result = "Adapted Operation: " _ adapteeResult
                }
            }
            Else {
                Set result = "Adapted Operation: " _ adapteeResult
            }
        }
        Else {
            Set result = "Error: Adaptee not initialized"
        }
    }
    Catch ex {
        Set result = "Error: " _ ex.DisplayString()
    }
    Quit result
}

/// Get adapter information including adaptee state
Method GetAdapterInfo() As %DynamicObject
{
    // Get base info from parent class
    Set info = ##super()
    
    // Add adapter-specific information
    If $IsObject(..InternalAdaptee) {
        Set info.adapterType = ..#ADAPTERTYPE
        Set info.adapteeState = ..InternalAdaptee.State
        Set info.requestCount = ..InternalAdaptee.RequestCount
        Set info.isAbstract = 0
    }
    Quit info
}

/// Validate adapter configuration
Method ValidateAdapter() As %Status
{
    Set tSC = ##super()
    If $$$ISOK(tSC) {
        // Additional validation for class adapter
        If '$IsObject(..InternalAdaptee) {
            Set tSC = $$$ERROR($$$GeneralError, "Internal Adaptee not initialized")
        }
    }
    Quit tSC
}

/// Reset adaptee state
Method ResetAdaptee() As %Status
{
    Set tSC = $$$OK
    Try {
        If $IsObject(..InternalAdaptee) {
            Set ..InternalAdaptee.State = "RESET"
            Set ..InternalAdaptee.RequestCount = 0
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Class method to demonstrate class adapter usage
ClassMethod DemonstrateUsage() As %Status
{
    Set tSC = $$$OK
    Try {
        Write "=== Class Adapter Demonstration ===", !
        
        // Create class adapter
        Set adapter = ##class(Patterns.GoF.Structural.ClassAdapter).%New()
        If '$IsObject(adapter) {
            Write "Failed to create ClassAdapter", !
            Quit
        }
        
        // Use the adapted interface
        Write "Standard Request: ", adapter.Request(), !
        Write "Request with options: ", adapter.ProcessWithOptions("JSON"), !
        Set adapterInfo = adapter.GetAdapterInfo()
        Write "Adapter Info: Type=", adapterInfo.adapterType, 
              " State=", adapterInfo.adapteeState, 
              " Requests=", adapterInfo.requestCount, !
        
        // Reset and try again
        Set tSC = adapter.ResetAdaptee()
        Write "After reset - Request: ", adapter.Request(), !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write "Error in demonstration: ", ex.DisplayString(), !
    }
    Quit tSC
}

}
