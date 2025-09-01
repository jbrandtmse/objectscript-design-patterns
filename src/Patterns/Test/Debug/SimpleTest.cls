Include %outUnitTest

/// Simple test to diagnose testing framework issues
Class Patterns.Test.Debug.SimpleTest Extends %UnitTest.TestCase
{

/// Constructor - handle initvalue parameter from parent class
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    Quit $$$OK
}

/// Simple test with just one assertion
Method TestBasicAssertion()
{
    // Simple test with direct assertion, no Try/Catch or Status return
    Do $$$AssertEquals(1, 1, "One equals one")
    Quit
}

/// Test with multiple assertions
Method TestMultipleAssertions()
{
    Do $$$AssertTrue(1=1, "True condition")
    Do $$$AssertEquals(2+2, 4, "Basic math")
    Do $$$AssertNotEquals("a", "b", "Different values")
    Quit
}

/// Test with status return (might be the issue)
Method TestWithStatusReturn() As %Status
{
    Do $$$AssertEquals(1, 1, "Test with status return")
    Quit $$$OK
}

}
