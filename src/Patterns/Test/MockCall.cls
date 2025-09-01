/// Mock call record
/// Records details of method calls made on mock objects
/// 
/// @since 1.0.0
Class Patterns.Test.MockCall Extends %RegisteredObject
{

/// Name of the method called
Property MethodName As %String;

/// Arguments passed to the method
Property Arguments As %DynamicObject;

/// Timestamp of the call
Property Timestamp As %Decimal;

}
