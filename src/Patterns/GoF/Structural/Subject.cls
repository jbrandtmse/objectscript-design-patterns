/// Gang of Four Proxy Pattern - Subject Interface
/// 
/// Intent:
/// Define the common interface for RealSubject and Proxy so that
/// Proxy can be used anywhere RealSubject is expected.
/// 
/// This abstract class establishes the contract that both the real
/// subject and its proxies must implement, ensuring transparency.
/// 
/// Structure:
/// <example>
/// Set subject = ##class(Patterns.GoF.Structural.RealSubject).%New()
/// Do subject.Request()
/// 
/// Set proxy = ##class(Patterns.GoF.Structural.VirtualProxy).%New()
/// Do proxy.Request()  // Same interface as RealSubject
/// </example>
Class Patterns.GoF.Structural.Subject Extends %RegisteredObject [ Abstract ]
{

/// Parameter PATTERNTYPE - Type of pattern
Parameter PATTERNTYPE = "Structural";

/// Parameter PATTERNNAME - Name of the pattern
Parameter PATTERNNAME = "Proxy";

/// Abstract method that defines the operation interface
/// Both RealSubject and Proxy must implement this method
/// 
/// @return Result of the request operation
Method Request() As %String [ Abstract ]
{
    Quit ""
}

/// Abstract method for operations that require parameters
/// Demonstrates proxy can handle complex operations
/// 
/// @param pOperation The operation to perform
/// @param pData The data to process
/// @return Status of the operation
Method DoOperation(pOperation As %String, pData As %String = "") As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Get resource information (for virtual proxy lazy loading)
/// 
/// @return Information about the resource
Method GetInfo() As %String [ Abstract ]
{
    Quit ""
}

}
