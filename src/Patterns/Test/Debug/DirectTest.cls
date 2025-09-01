Include %outUnitTest

/// Direct test extending %UnitTest.TestCase without custom base class
/// Used to diagnose INVALID OREF issues
Class Patterns.Test.Debug.DirectTest Extends %UnitTest.TestCase
{

/// Constructor must handle initvalue parameter from parent class
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter - REQUIRED
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    Quit $$$OK
}

/// Simple test with minimal complexity
Method TestDirect()
{
    Do $$$AssertTrue(1, "Direct test should pass")
}

/// Test with multiple assertions
Method TestMultiple()
{
    Do $$$AssertEquals(1, 1, "One equals one")
    Do $$$AssertTrue(1=1, "One equals one condition")
    Do $$$AssertStatusOK($$$OK, "Status should be OK")
}

}
