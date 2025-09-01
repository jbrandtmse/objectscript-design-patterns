Include %outUnitTest

/// Minimal test class to work around INVALID OREF issues
Class Patterns.Test.Debug.MinimalTest Extends %UnitTest.TestCase
{

/// Constructor must handle initvalue parameter from parent class
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter - REQUIRED
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    Quit $$$OK
}

/// Override problematic GetSourceLocation method
Method GetSourceLocation() As %String
{
    // Return empty string to avoid INVALID OREF errors
    Quit ""
}

/// Simple test that should pass
Method TestMinimal()
{
    Do $$$AssertTrue(1, "Minimal test should pass")
}

/// Test with multiple assertions
Method TestMultipleAssertions()
{
    Do $$$AssertEquals(1, 1, "One equals one")
    Do $$$AssertTrue(2=2, "Two equals two")
    Do $$$AssertStatusOK($$$OK, "Status should be OK")
}

}
