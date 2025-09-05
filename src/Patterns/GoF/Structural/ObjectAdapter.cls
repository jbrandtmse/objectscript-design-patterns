/// Patterns.GoF.Structural.ObjectAdapter
/// Object Adapter implementation - uses composition to adapt Adaptee interface to Target
/// This approach is more flexible than Class Adapter as it can work with any Adaptee subclass
/// Part of Gang of Four Adapter pattern implementation
Class Patterns.GoF.Structural.ObjectAdapter Extends Patterns.GoF.Structural.Target
{

/// Class parameters for pattern metadata
Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Structural";

Parameter PATTERNNAME = "Adapter";

Parameter ADAPTERTYPE = "Object";

/// The adaptee instance we're adapting (composition)
Property Adaptee As Patterns.GoF.Structural.Adaptee;

/// Constructor - accepts an existing adaptee instance
Method %OnNew(pAdaptee As Patterns.GoF.Structural.Adaptee = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // If no adaptee provided, create a default one
        If pAdaptee = "" {
            Set ..Adaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
        }
        ElseIf $IsObject(pAdaptee) {
            Set ..Adaptee = pAdaptee
        }
        Else {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid Adaptee parameter")
            Quit
        }
        
        If '$IsObject(..Adaptee) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to initialize Adaptee")
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
        If $IsObject(..Adaptee) {
            // Check the type of adaptee and call appropriate method
            Set adapteeClass = ..Adaptee.%ClassName(1)
            
            // Handle LegacyAdaptee differently
            If adapteeClass = "Patterns.GoF.Structural.LegacyAdaptee" {
                // LegacyAdaptee has OldMethod instead of SpecificRequest
                Set adapteeResponse = ..Adaptee.OldMethod()
                
                // Adapt legacy response format
                If adapteeResponse [ "LegacyOperation:" {
                    Set legacyPart = $Piece(adapteeResponse, "LegacyOperation:", 2)
                    Set legacyPart = $ZSTRIP(legacyPart, "<>W")
                    Set result = "Object Adapted: " _ legacyPart
                }
                Else {
                    Set result = "Object Adapted: " _ adapteeResponse
                }
            }
            Else {
                // Standard Adaptee with SpecificRequest method
                Set adapteeResponse = ..Adaptee.SpecificRequest()
                
                // Adapt the response to match Target interface expectations
                // Parse the specific format and convert to standard format
                If adapteeResponse [ "SpecificRequest:" {
                    // Extract the meaningful part after "SpecificRequest:"
                    Set specificPart = $Piece(adapteeResponse, "SpecificRequest:", 2)
                    Set specificPart = $ZSTRIP(specificPart, "<>W")
                    
                    // Convert to standard Target format (different prefix for Object Adapter)
                    Set result = "Object Adapted: " _ specificPart
                }
                Else {
                    // Fallback for unexpected format
                    Set result = "Object Adapted: " _ adapteeResponse
                }
            }
        }
        Else {
            Set result = "Error: No adaptee"
        }
    }
    Catch ex {
        Set result = "Error: " _ ex.DisplayString()
    }
    Quit result
}

/// Set a new adaptee instance at runtime
/// Demonstrates flexibility of Object Adapter pattern
Method SetAdaptee(pNewAdaptee As Patterns.GoF.Structural.Adaptee) As %Status
{
    Set tSC = $$$OK
    Try {
        If $IsObject(pNewAdaptee) {
            Set ..Adaptee = pNewAdaptee
        }
        Else {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid Adaptee object")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Extended operation using adaptee's specific functionality
/// Demonstrates adapter can expose additional adaptee capabilities
Method ProcessWithOptions(pOptions As %String = "default") As %String
{
    Set result = ""
    Try {
        If $IsObject(..Adaptee) {
            // Use adaptee's specific operation with options - needs 2 parameters
            Set adapteeResult = ..Adaptee.SpecificOperation(pOptions, "DEFAULT")
            
            // Adapt the response
            If adapteeResult [ "SpecificOperation:" {
                Set processedPart = $Piece(adapteeResult, "=> Result:", 2)
                If processedPart '= "" {
                    Set result = "Object Adapted Operation: " _ $ZSTRIP(processedPart, "<>W")
                }
                Else {
                    Set result = "Object Adapted Operation: " _ adapteeResult
                }
            }
            Else {
                Set result = "Object Adapted Operation: " _ adapteeResult
            }
        }
        Else {
            Set result = "Error: No adaptee"
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
    Set info.adapterType = ..#ADAPTERTYPE
    Set info.isAbstract = 0
    
    If $IsObject(..Adaptee) {
        Set info.adapteeClass = ..Adaptee.%ClassName(1)
        Set info.adapteeState = ..Adaptee.State
        Set info.requestCount = ..Adaptee.RequestCount
    }
    Else {
        Set info.adapteeClass = "Not Initialized"
        Set info.adapteeState = "N/A"
        Set info.requestCount = 0
    }
    
    Quit info
}

/// Validate adapter configuration
Method ValidateAdapter() As %Status
{
    Set tSC = ##super()
    If $$$ISOK(tSC) {
        // Additional validation for object adapter
        If '$IsObject(..Adaptee) {
            Set tSC = $$$ERROR($$$GeneralError, "Adaptee not initialized")
        }
    }
    Quit tSC
}

/// Get current adaptee state
Method GetAdapteeState() As %String
{
    If $IsObject(..Adaptee) {
        Quit ..Adaptee.State
    }
    Quit "No Adaptee"
}

/// Get current adaptee request count
Method GetAdapteeRequestCount() As %Integer
{
    If $IsObject(..Adaptee) {
        Quit ..Adaptee.RequestCount
    }
    Quit 0
}

/// Reset adaptee state
Method ResetAdaptee() As %Status
{
    Set tSC = $$$OK
    Try {
        If $IsObject(..Adaptee) {
            Set ..Adaptee.State = "RESET"
            Set ..Adaptee.RequestCount = 0
        }
        Else {
            Set tSC = $$$ERROR($$$GeneralError, "No Adaptee to reset")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Class method to demonstrate object adapter usage with different adaptees
ClassMethod DemonstrateUsage() As %Status
{
    Set tSC = $$$OK
    Try {
        Write "=== Object Adapter Demonstration ===", !
        
        // Create object adapter with default adaptee
        Write !, "1. Using default Adaptee:", !
        Set adapter1 = ##class(Patterns.GoF.Structural.ObjectAdapter).%New()
        If '$IsObject(adapter1) {
            Write "Failed to create ObjectAdapter", !
            Quit
        }
        
        Write "Standard Request: ", adapter1.Request(), !
        Write "Request with options: ", adapter1.ProcessWithOptions("XML"), !
        
        // Create a custom adaptee and use it with another adapter
        Write !, "2. Using custom Adaptee:", !
        Set customAdaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
        Set customAdaptee.State = "CUSTOM"
        
        Set adapter2 = ##class(Patterns.GoF.Structural.ObjectAdapter).%New(customAdaptee)
        Write "Standard Request: ", adapter2.Request(), !
        Write "Adaptee State: ", adapter2.GetAdapteeState(), !
        
        // Demonstrate changing adaptees at runtime
        Write !, "3. Changing Adaptee at runtime:", !
        Set newAdaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
        Set newAdaptee.State = "REPLACEMENT"
        
        Set tSC = adapter1.SetAdaptee(newAdaptee)
        If $$$ISOK(tSC) {
            Write "After replacement - Request: ", adapter1.Request(), !
            Write "New Adaptee State: ", adapter1.GetAdapteeState(), !
        }
        
        // Show adapter info
        Write !, "4. Adapter Information:", !
        Set info = adapter1.GetAdapterInfo()
        Write "Adapter Type: ", info.adapterType, !
        Write "Adaptee Class: ", info.adapteeClass, !
        Write "Request Count: ", info.requestCount, !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write "Error in demonstration: ", ex.DisplayString(), !
    }
    Quit tSC
}

}
