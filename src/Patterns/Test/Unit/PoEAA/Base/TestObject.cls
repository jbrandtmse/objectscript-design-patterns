/// Simple test object for Registry testing
/// 
/// A concrete class used for testing Registry pattern functionality.
/// Provides a simple object that can be instantiated and stored in registries.
Class Patterns.Test.Unit.PoEAA.Base.TestObject Extends %RegisteredObject
{

/// Test property to distinguish instances
Property TestValue As %String;

/// Simple constructor
Method %OnNew(pTestValue As %String = "") As %Status
{
    Set ..TestValue = pTestValue
    Quit $$$OK
}

}
