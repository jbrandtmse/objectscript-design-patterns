/// Gang of Four Adapter Pattern - Target Interface
/// 
/// Intent:
/// Define the domain-specific interface that Client uses. This is the interface
/// that the client expects to work with, and the Adapter will make the Adaptee
/// conform to this interface.
/// 
/// Motivation:
/// Sometimes a toolkit class that's designed for reuse isn't reusable only because
/// its interface doesn't match the domain-specific interface an application requires.
/// The Target defines the expected interface that clients will use.
/// 
/// Structure:
/// The Target class defines the domain-specific interface that clients use.
/// Concrete adapters will inherit from this class and adapt various adaptees
/// to conform to this interface.
/// 
/// <example>
/// Set adapter = ##class(Patterns.GoF.Structural.ObjectAdapter).%New()
/// Set result = adapter.Request()
/// </example>
/// 
/// @see Patterns.GoF.Structural.ClassAdapter
/// @see Patterns.GoF.Structural.ObjectAdapter
/// @since 1.0.0
Class Patterns.GoF.Structural.Target Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// Version of the Target interface
Parameter VERSION = "1.0.0";

/// Pattern type identifier
Parameter PATTERNTYPE = "Structural";

/// Pattern name  
Parameter PATTERNNAME = "Adapter-Target";

// ===== PUBLIC METHODS =====

/// Standard request method that all adapters must implement
/// 
/// This method defines the interface that clients expect to use.
/// Concrete adapters will implement this method to delegate to
/// their adaptee's specific interface.
/// 
/// @return Response string from the adapted request
/// 
/// <example>
/// Set target = ##class(ConcreteAdapter).%New()
/// Set response = target.Request()
/// Write "Response: ", response, !
/// </example>
Method Request() As %String [ Abstract ]
{
        // Abstract methods in ObjectScript require a body with return value
        Quit ""
}

/// Optional method to get adapter information
/// 
/// Provides metadata about the adapter implementation.
/// Subclasses can override to provide specific details.
/// 
/// @return JSON object with adapter information
Method GetAdapterInfo() As %DynamicObject
{
        Set tInfo = {}
        Set tInfo.patternType = ..#PATTERNTYPE
        Set tInfo.patternName = ..#PATTERNNAME
        Set tInfo.version = ..#VERSION
        Set tInfo.className = ..%ClassName(1)
        Set tInfo.isAbstract = 1
        
        Quit tInfo
}

/// Validate that the adapter is properly configured
/// 
/// @return %Status indicating if adapter is valid
Method ValidateAdapter() As %Status
{
        // Default implementation - subclasses should override
        Quit $$$OK
}

}
