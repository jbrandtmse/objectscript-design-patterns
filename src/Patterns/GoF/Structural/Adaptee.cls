/// Gang of Four Adapter Pattern - Adaptee Class
/// 
/// Intent:
/// Defines an existing interface that needs adapting. This is the class
/// that has useful functionality but an incompatible interface that
/// doesn't match what the client expects.
/// 
/// Motivation:
/// The Adaptee contains the functionality that we want to use, but its
/// interface is incompatible with the rest of our code. An Adapter will
/// wrap this class and expose its functionality through the Target interface.
/// 
/// Structure:
/// The Adaptee is an existing class with some useful behavior that we want
/// to incorporate into our system, but its interface doesn't match our needs.
/// 
/// <example>
/// Set adaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
/// Set result = adaptee.SpecificRequest()
/// </example>
/// 
/// @see Patterns.GoF.Structural.Target
/// @see Patterns.GoF.Structural.ClassAdapter
/// @see Patterns.GoF.Structural.ObjectAdapter
/// @since 1.0.0
Class Patterns.GoF.Structural.Adaptee Extends %RegisteredObject
{

// ===== PARAMETERS =====

/// Version of the Adaptee
Parameter VERSION = "1.0.0";

/// Pattern component type
Parameter COMPONENTTYPE = "Adaptee";

// ===== PROPERTIES =====

/// Internal state of the adaptee
Property State As %String [ InitialExpression = "Ready" ];

/// Counter for tracking requests
Property RequestCount As %Integer [ InitialExpression = 0 ];

// ===== PUBLIC METHODS =====

/// Specific request method with incompatible interface
/// 
/// This method provides useful functionality but has a different
/// signature than what the Target interface expects.
/// 
/// @return Formatted response from the adaptee
/// 
/// <example>
/// Set adaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
/// Set response = adaptee.SpecificRequest()
/// Write "Adaptee response: ", response, !
/// </example>
Method SpecificRequest() As %String
{
        Set ..RequestCount = ..RequestCount + 1
        Set tTimestamp = $ZDATETIME($HOROLOG, 3, 1, 3)
        Set tResponse = "SpecificRequest: Adaptee processing request #"_..RequestCount_" at "_tTimestamp_" [State: "_..State_"]"
        Quit tResponse
}

/// Another specific method demonstrating incompatible interface
/// 
/// @param pData Data to process
/// @param pFormat Format specification
/// @return Processed result
Method SpecificOperation(pData As %String, pFormat As %String = "DEFAULT") As %String
{
        Set tResult = "SpecificOperation: Processing '"_pData_"' with format '"_pFormat_"'"
        Set ..State = "Processing"
        
        // Simulate some processing
        Set tProcessed = $ZCONVERT(pData, "U")
        If pFormat = "REVERSE" {
            Set tProcessed = $REVERSE(tProcessed)
        } ElseIf pFormat = "LOWER" {
            Set tProcessed = $ZCONVERT(pData, "L")
        }
        
        Set ..State = "Ready"
        Set tResult = tResult_" => Result: "_tProcessed
        Quit tResult
}

/// Get current adaptee status
/// 
/// @return JSON object with status information
Method GetAdapteeStatus() As %DynamicObject
{
        Set tStatus = {}
        Set tStatus.state = ..State
        Set tStatus.requestCount = ..RequestCount
        Set tStatus.className = ..%ClassName(1)
        Set tStatus.version = ..#VERSION
        
        Quit tStatus
}

/// Reset the adaptee to initial state
Method Reset()
{
        Set ..State = "Ready"
        Set ..RequestCount = 0
}

}
