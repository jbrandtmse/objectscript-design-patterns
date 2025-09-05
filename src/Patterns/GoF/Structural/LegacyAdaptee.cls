/// Gang of Four Adapter Pattern - Legacy Adaptee Class
/// 
/// Intent:
/// Simulates legacy ObjectScript code that uses global variables and
/// non-object-oriented programming patterns. This demonstrates how the
/// Adapter pattern can wrap legacy code to make it work with modern
/// object-oriented interfaces.
/// 
/// Motivation:
/// Many existing ObjectScript applications use global variables and
/// procedural programming. This class simulates such legacy code to
/// show how adapters can bridge old and new coding paradigms.
/// 
/// Structure:
/// This class contains methods that simulate legacy coding patterns,
/// including direct global access, label-based routines, and
/// non-standard parameter passing.
/// 
/// <example>
/// Set legacy = ##class(Patterns.GoF.Structural.LegacyAdaptee).%New()
/// Do legacy.InitializeLegacySystem()
/// Set result = legacy.ProcessLegacyRequest("DATA123")
/// </example>
/// 
/// @see Patterns.GoF.Structural.LegacyCodeAdapter
/// @since 1.0.0
Class Patterns.GoF.Structural.LegacyAdaptee Extends %RegisteredObject
{

// ===== PARAMETERS =====

/// Version identifier
Parameter VERSION = "1.0.0";

/// Legacy system identifier
Parameter LEGACYSYSTEM = "LEGACY_ADAPTEE";

// ===== PROPERTIES =====

/// Legacy system namespace for globals
Property GlobalNamespace As %String [ InitialExpression = "^LegacyAdaptee" ];

/// Session ID for this instance
Property SessionID As %String;

// ===== CONSTRUCTOR/DESTRUCTOR =====

Method %OnNew() As %Status
{
        Set tSC = $$$OK
        
        // Generate unique session ID
        Set ..SessionID = $ZCONVERT($SYSTEM.Util.CreateGUID(), "L")
        
        // Initialize legacy globals
        Do ..InitializeLegacySystem()
        
        Quit tSC
}

Method %OnClose() As %Status
{
        // Clean up session-specific globals
        Do ..CleanupLegacySession()
        Quit $$$OK
}

// ===== PUBLIC METHODS =====

/// Initialize the legacy system globals
Method InitializeLegacySystem()
{
        // Simulate legacy initialization using globals
        Set ^LegacyAdaptee("SYSTEM", "STATUS") = "INITIALIZED"
        Set ^LegacyAdaptee("SYSTEM", "VERSION") = ..#VERSION
        Set ^LegacyAdaptee("SYSTEM", "TIMESTAMP") = $HOROLOG
        
        // Initialize session
        Set ^LegacyAdaptee("SESSION", ..SessionID, "CREATED") = $HOROLOG
        Set ^LegacyAdaptee("SESSION", ..SessionID, "COUNTER") = 0
}

/// Process request using legacy style with globals
/// 
/// @param pInput Input data string
/// @return Legacy-formatted response
Method ProcessLegacyRequest(pInput As %String) As %String
{
        // Simulate legacy processing using globals
        Set tCounter = $INCREMENT(^LegacyAdaptee("SESSION", ..SessionID, "COUNTER"))
        
        // Store request in global
        Set ^LegacyAdaptee("REQUESTS", ..SessionID, tCounter, "INPUT") = pInput
        Set ^LegacyAdaptee("REQUESTS", ..SessionID, tCounter, "TIMESTAMP") = $HOROLOG
        
        // Process using legacy logic
        Set tProcessed = ..LegacyTransform(pInput)
        
        // Store result
        Set ^LegacyAdaptee("REQUESTS", ..SessionID, tCounter, "OUTPUT") = tProcessed
        
        // Build legacy-style response
        Set tResponse = "LEGACY|"_tCounter_"|"_$PIECE($HOROLOG, ",", 1)_"|"_tProcessed
        
        Quit tResponse
}

/// Execute legacy operation with multiple parameters
/// 
/// @param pCode Operation code
/// @param pData Data to process
/// @param pOptions Pipe-delimited options string
/// @return Legacy response string
Method ExecuteLegacyOperation(pCode As %String, pData As %String, pOptions As %String = "") As %String
{
        // Parse options (legacy style)
        Set tOption1 = $PIECE(pOptions, "|", 1)
        Set tOption2 = $PIECE(pOptions, "|", 2)
        Set tOption3 = $PIECE(pOptions, "|", 3)
        
        // Store in globals
        Set ^LegacyAdaptee("OPERATION", "LAST", "CODE") = pCode
        Set ^LegacyAdaptee("OPERATION", "LAST", "DATA") = pData
        Set ^LegacyAdaptee("OPERATION", "LAST", "OPTIONS") = pOptions
        
        // Process based on code (legacy switch style)
        If pCode = "TRANSFORM" {
            Set tResult = ..LegacyTransform(pData)
        } ElseIf pCode = "VALIDATE" {
            Set tResult = ..LegacyValidate(pData)
        } ElseIf pCode = "FORMAT" {
            Set tResult = ..LegacyFormat(pData, tOption1)
        } Else {
            Set tResult = "ERROR:UNKNOWN_CODE:"_pCode
        }
        
        // Return legacy formatted result
        Quit "RESULT:"_pCode_":"_tResult
}

/// Get legacy system information using globals
/// 
/// @return Pipe-delimited status string
Method GetLegacyInfo() As %String
{
        Set tStatus = $GET(^LegacyAdaptee("SYSTEM", "STATUS"), "UNKNOWN")
        Set tVersion = $GET(^LegacyAdaptee("SYSTEM", "VERSION"), "0.0.0")
        Set tCounter = $GET(^LegacyAdaptee("SESSION", ..SessionID, "COUNTER"), 0)
        
        // Return pipe-delimited format (legacy style)
        Quit tStatus_"|"_tVersion_"|"_tCounter_"|"_..SessionID
}

/// Legacy method for adapter compatibility
/// This method provides the interface expected by ObjectAdapter
Method OldMethod() As %String
{
        // Increment legacy counter
        Set tCounter = $INCREMENT(^LegacyAdaptee("SESSION", ..SessionID, "COUNTER"))
        
        // Return legacy-style response
        Quit "LegacyOperation: Processing via legacy system (Count="_tCounter_")"
}

// ===== PRIVATE METHODS =====

/// Legacy transformation logic
Method LegacyTransform(pData As %String) As %String [ Private ]
{
        // Simulate legacy transformation
        Set tResult = ""
        For i=1:1:$LENGTH(pData) {
            Set tChar = $EXTRACT(pData, i)
            Set tAscii = $ASCII(tChar)
            Set tResult = tResult_$CHAR(tAscii + 1)
        }
        Quit tResult
}

/// Legacy validation logic
Method LegacyValidate(pData As %String) As %String [ Private ]
{
        // Simple legacy validation
        If pData = "" Quit "INVALID:EMPTY"
        If $LENGTH(pData) > 100 Quit "INVALID:TOO_LONG"
        If pData [ "ERROR" Quit "INVALID:CONTAINS_ERROR"
        Quit "VALID"
}

/// Legacy formatting logic
Method LegacyFormat(pData As %String, pFormat As %String) As %String [ Private ]
{
        If pFormat = "UPPER" {
            Quit $ZCONVERT(pData, "U")
        } ElseIf pFormat = "LOWER" {
            Quit $ZCONVERT(pData, "L")
        } ElseIf pFormat = "TITLE" {
            Quit $ZCONVERT(pData, "W")
        }
        Quit pData
}

/// Clean up session-specific globals
Method CleanupLegacySession() [ Private ]
{
        // Clean up session data
        Kill ^LegacyAdaptee("SESSION", ..SessionID)
        Kill ^LegacyAdaptee("REQUESTS", ..SessionID)
}

/// Class method to clean all legacy data (for testing)
ClassMethod CleanAllLegacyData()
{
        Kill ^LegacyAdaptee
}

}
