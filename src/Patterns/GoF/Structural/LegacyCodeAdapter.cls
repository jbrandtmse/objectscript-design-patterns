/// Patterns.GoF.Structural.LegacyCodeAdapter
/// Adapter for wrapping legacy ObjectScript code that uses global variables
/// Demonstrates how the Adapter pattern can modernize legacy interfaces
/// Part of Gang of Four Adapter pattern implementation
Class Patterns.GoF.Structural.LegacyCodeAdapter Extends Patterns.GoF.Structural.Target
{

/// Class parameters for pattern metadata
Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Structural";

Parameter PATTERNNAME = "Adapter";

Parameter ADAPTERTYPE = "Legacy";

/// The legacy adaptee instance we're adapting
Property LegacyAdaptee As Patterns.GoF.Structural.LegacyAdaptee;

/// Session ID for tracking legacy interactions
Property SessionID As %String;

/// Constructor - initializes legacy adaptee with session management
/// @param pAdaptee Optional legacy adaptee instance to use (will create one if not provided)
Method %OnNew(pAdaptee As Patterns.GoF.Structural.LegacyAdaptee = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Use provided adaptee or create new one
        If $IsObject(pAdaptee) {
            Set ..LegacyAdaptee = pAdaptee
        }
        Else {
            // Create the legacy adaptee instance
            Set ..LegacyAdaptee = ##class(Patterns.GoF.Structural.LegacyAdaptee).%New()
            If '$IsObject(..LegacyAdaptee) {
                Set tSC = $$$ERROR($$$GeneralError, "Failed to create LegacyAdaptee instance")
                Quit
            }
        }
        
        // Get the session ID from the legacy adaptee
        Set ..SessionID = ..LegacyAdaptee.SessionID
        If ..SessionID = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to get legacy session ID")
            Quit
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Request method implementation - adapts legacy global-based interface
/// Converts the pipe-delimited legacy format to standard Target format
Method Request() As %String
{
    Set result = ""
    Try {
        // Delegate to the legacy adaptee's processing
        If $IsObject(..LegacyAdaptee) {
            // Call ProcessLegacyRequest with the session ID as input
            Set legacyResponse = ..LegacyAdaptee.ProcessLegacyRequest(..SessionID)
            
            // Parse the legacy pipe-delimited format
            // Format: "LEGACY|{count}|{date}|{processed}"
            Set responseType = $Piece(legacyResponse, "|", 1)
            Set countPart = $Piece(legacyResponse, "|", 2)
            Set datePart = $Piece(legacyResponse, "|", 3)
            Set processedPart = $Piece(legacyResponse, "|", 4)
            
            // Convert to modern format
            If responseType = "LEGACY" {
                Set result = "Modern Adapted: Count=" _ countPart _ 
                            " Date=" _ datePart _ 
                            " Data=" _ processedPart
            }
            Else {
                // Fallback for unexpected format
                Set result = "Modern Adapted: " _ legacyResponse
            }
        }
        Else {
            Set result = "Error: Legacy system not initialized"
        }
    }
    Catch ex {
        Set result = "Error: " _ ex.DisplayString()
    }
    Quit result
}

/// Execute a specific legacy operation
Method ExecuteLegacyOperation(operationCode As %String = "READ") As %String
{
    Set result = ""
    Try {
        If $IsObject(..LegacyAdaptee) {
            // Call the legacy operation with proper parameters
            Set legacyResult = ..LegacyAdaptee.ExecuteLegacyOperation(operationCode, ..SessionID, "")
            
            // Parse and modernize the result
            // Format: "RESULT:{code}:{result}"
            Set resultType = $Piece(legacyResult, ":", 1)
            Set opCode = $Piece(legacyResult, ":", 2)
            Set opResult = $Piece(legacyResult, ":", 3)
            
            If resultType = "RESULT" {
                Set result = "Modern Operation: " _ opCode _ " -> " _ opResult
            }
            Else {
                Set result = "Modern Operation: " _ legacyResult
            }
        }
        Else {
            Set result = "Error: Legacy system not available"
        }
    }
    Catch ex {
        Set result = "Error: " _ ex.DisplayString()
    }
    Quit result
}

/// Get current legacy state from global
Method GetLegacyState() As %String
{
    If $IsObject(..LegacyAdaptee) {
        // Get info from the legacy adaptee
        Set info = ..LegacyAdaptee.GetLegacyInfo()
        Set state = $Piece(info, "|", 1)  // First part is status
        Quit state
    }
    Quit "No Legacy System"
}

/// Get legacy request count from global
Method GetLegacyRequestCount() As %Integer
{
    If $IsObject(..LegacyAdaptee) {
        // Get info from the legacy adaptee
        Set info = ..LegacyAdaptee.GetLegacyInfo()
        Set count = $Piece(info, "|", 3)  // Third part is counter
        Quit +count  // Convert to integer
    }
    Quit 0
}

/// Get adapter information including legacy system state
Method GetAdapterInfo() As %DynamicObject
{
    // Get base info from parent class
    Set info = ##super()
    
    // Add adapter-specific information
    Set info.adapterType = ..#ADAPTERTYPE
    Set info.isAbstract = 0
    Set info.sessionID = ..SessionID
    
    If $IsObject(..LegacyAdaptee) {
        Set info.legacyState = ..GetLegacyState()
        Set info.legacyRequestCount = ..GetLegacyRequestCount()
        Set info.hasLegacySystem = 1
    }
    Else {
        Set info.legacyState = "Not Connected"
        Set info.legacyRequestCount = 0
        Set info.hasLegacySystem = 0
    }
    
    Quit info
}

/// Validate adapter configuration including legacy system
Method ValidateAdapter() As %Status
{
    Set tSC = ##super()
    If $$$ISOK(tSC) {
        // Additional validation for legacy adapter
        If '$IsObject(..LegacyAdaptee) {
            Set tSC = $$$ERROR($$$GeneralError, "Legacy system not initialized")
        }
        ElseIf ..SessionID = "" {
            Set tSC = $$$ERROR($$$GeneralError, "No legacy session established")
        }
    }
    Quit tSC
}

/// Clean up legacy resources on destruction
Method %OnClose() As %Status
{
    Set tSC = $$$OK
    Try {
        // LegacyAdaptee will clean up in its own %OnClose method
        // We don't need to do anything special here
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Migrate legacy data to modern format
Method MigrateLegacyData() As %DynamicObject
{
    Set migrationResult = {}
    Try {
        If $IsObject(..LegacyAdaptee) {
            // Get all legacy data
            Set state = ..GetLegacyState()
            Set count = ..GetLegacyRequestCount()
            
            // Create modern data structure
            Set migrationResult.originalFormat = "Legacy Global Variables"
            Set migrationResult.modernFormat = "Object Properties"
            Set migrationResult.data = {}
            Set migrationResult.data.sessionId = ..SessionID
            Set migrationResult.data.state = state
            Set migrationResult.data.requestCount = count
            Set migrationResult.data.migrationTimestamp = $ZDateTime($Horolog, 3)
            Set migrationResult.success = 1
        }
        Else {
            Set migrationResult.success = 0
            Set migrationResult.error = "No legacy system to migrate"
        }
    }
    Catch ex {
        Set migrationResult.success = 0
        Set migrationResult.error = ex.DisplayString()
    }
    Quit migrationResult
}

/// Class method to demonstrate legacy adapter usage
ClassMethod DemonstrateUsage() As %Status
{
    Set tSC = $$$OK
    Try {
        Write "=== Legacy Code Adapter Demonstration ===", !
        
        // Create legacy adapter
        Write !, "1. Creating Legacy Adapter:", !
        Set adapter = ##class(Patterns.GoF.Structural.LegacyCodeAdapter).%New()
        If '$IsObject(adapter) {
            Write "Failed to create LegacyCodeAdapter", !
            Quit
        }
        Write "Session established: ", adapter.SessionID, !
        
        // Use the adapted legacy interface
        Write !, "2. Using Legacy System through Modern Interface:", !
        Write "Standard Request: ", adapter.Request(), !
        Write "Legacy State: ", adapter.GetLegacyState(), !
        Write "Request Count: ", adapter.GetLegacyRequestCount(), !
        
        // Execute legacy operations
        Write !, "3. Executing Legacy Operations:", !
        Write "TRANSFORM Operation: ", adapter.ExecuteLegacyOperation("TRANSFORM"), !
        Write "VALIDATE Operation: ", adapter.ExecuteLegacyOperation("VALIDATE"), !
        Write "FORMAT Operation: ", adapter.ExecuteLegacyOperation("FORMAT"), !
        
        // Show migration capabilities
        Write !, "4. Data Migration Capability:", !
        Set migrationData = adapter.MigrateLegacyData()
        Write "Migration Success: ", migrationData.success, !
        If migrationData.success {
            Write "Original Format: ", migrationData.originalFormat, !
            Write "Modern Format: ", migrationData.modernFormat, !
            Write "Migrated Data: Session=", migrationData.data.sessionId,
                  " State=", migrationData.data.state,
                  " Count=", migrationData.data.requestCount, !
        }
        
        // Show adapter info
        Write !, "5. Adapter Information:", !
        Set info = adapter.GetAdapterInfo()
        Write "Adapter Type: ", info.adapterType, !
        Write "Session ID: ", info.sessionID, !
        Write "Legacy State: ", info.legacyState, !
        Write "Request Count: ", info.legacyRequestCount, !
        
        // Clean up (will be called automatically on object destruction)
        Write !, "6. Cleanup:", !
        Kill adapter
        Write "Legacy session cleaned up", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write "Error in demonstration: ", ex.DisplayString(), !
    }
    Quit tSC
}

/// Class method to clean up all legacy sessions
ClassMethod CleanupAllLegacySessions() As %Status
{
    Set tSC = $$$OK
    Try {
        // Call the actual cleanup method that exists
        Do ##class(Patterns.GoF.Structural.LegacyAdaptee).CleanAllLegacyData()
        Write "All legacy sessions cleaned up successfully", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write "Error cleaning up legacy sessions: ", ex.DisplayString(), !
    }
    Quit tSC
}

}
