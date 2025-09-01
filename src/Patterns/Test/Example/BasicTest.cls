Include %outUnitTest

/// Example test class demonstrating the testing framework
/// Shows various testing patterns and best practices
Class Patterns.Test.Example.BasicTest Extends Patterns.Test.TestCase
{

/// Constructor - handle initvalue parameter from parent class
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    Quit $$$OK
}

/// Test simple assertion
Method TestSimpleAssertion() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Basic assertions
        Do $$$AssertEquals(2 + 2, 4, "Basic math should work")
        Do $$$AssertTrue(1 = 1, "True condition")
        Do $$$AssertTrue('(0 = 1), "False condition")
        Do $$$AssertNotEquals("apple", "orange", "Different values")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test with setup and teardown
Method TestWithSetupAndTeardown() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Setup is handled by OnBeforeOneTest
        // Teardown is handled by OnAfterOneTest
        
        // Test that TestData global was created
        Do $$$AssertTrue($DATA(^TestData), "Test data should exist")
        
        // Add test-specific data
        Set ^TestData("TestSpecific") = "Value"
        Do $$$AssertEquals(^TestData("TestSpecific"), "Value", "Test-specific data")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test error handling
Method TestErrorHandling() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test that errors are properly caught
        Set errorOccurred = 0
        Try {
            // This should cause an error
            Set x = 1 / 0
        } Catch divEx {
            Set errorOccurred = 1
        }
        
        Do $$$AssertTrue(errorOccurred, "Division by zero should cause error")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test with mock objects
Method TestWithMockObject() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create a mock builder
        Set mockBuilder = ##class(Patterns.Test.MockBuilder).%New()
        Set mockBuilder.ClassName = "TestService"
        
        // Set up expectations
        Do mockBuilder.ExpectCall("GetData").Returns("MockedData")
        Do mockBuilder.ExpectCall("SaveData").WithArgs("TestValue").Returns(1)
        
        // Simulate calls
        Do mockBuilder.RecordCall("GetData", $LISTBUILD())
        Do mockBuilder.RecordCall("SaveData", $LISTBUILD("TestValue"))
        
        // Verify expectations
        Set verifyResult = mockBuilder.Verify()
        Do $$$AssertTrue(verifyResult, "Mock expectations should be met")
        
        // Get return values
        Set getData = mockBuilder.GetReturnValue("GetData", $LISTBUILD())
        Do $$$AssertEquals(getData, "MockedData", "Mock should return expected value")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test with generated test data
Method TestWithGeneratedData() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Generate test persons
        Set persons = ##class(Patterns.Test.Fixtures.TestDataGenerator).GeneratePersons(5, 123)
        Do $$$AssertEquals(persons.%Size(), 5, "Should generate 5 persons")
        
        // Check first person
        Set person = persons.%Get(0)
        Do $$$AssertTrue(person.firstName '= "", "Person should have first name")
        Do $$$AssertTrue(person.lastName '= "", "Person should have last name")
        Do $$$AssertTrue(person.email '= "", "Person should have email")
        
        // Generate random data
        Set randomInt = ##class(Patterns.Test.Fixtures.TestDataGenerator).GetRandomInteger(1, 100, 456)
        Do $$$AssertTrue(randomInt >= 1, "Random int should be >= 1")
        Do $$$AssertTrue(randomInt <= 100, "Random int should be <= 100")
        
        Set randomString = ##class(Patterns.Test.Fixtures.TestDataGenerator).GetRandomString(10, 789)
        Do $$$AssertEquals($LENGTH(randomString), 10, "Random string should have correct length")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test custom assertions
Method TestCustomAssertions() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test AssertInRange
        Do ..AssertInRange(50, 1, 100, "Value should be in range")
        
        // Test AssertCollectionCount
        Set list = $LISTBUILD("a", "b", "c")
        Do ..AssertCollectionCount(list, 3, "List should have 3 items")
        
        // Test performance assertion (this should pass as it's fast)
        Set startTime = $ZHOROLOG
        Set x = 1 + 1
        Set endTime = $ZHOROLOG
        Set elapsed = (endTime - startTime) * 1000
        Do ..AssertPerformance(elapsed, 100, "Simple operation should be fast")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test with constants
Method TestWithConstants() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Use test constants
        Set timeout = ##class(Patterns.Test.Fixtures.TestConstants).#TIMEOUTSHORT
        Do $$$AssertEquals(timeout, 1, "Short timeout should be 1 second")
        
        Set testString = ##class(Patterns.Test.Fixtures.TestConstants).#TESTSTRINGSHORT
        Do $$$AssertEquals(testString, "Test", "Test string should match")
        
        Set httpOk = ##class(Patterns.Test.Fixtures.TestConstants).#HTTPOK
        Do $$$AssertEquals(httpOk, 200, "HTTP OK should be 200")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test status codes
Method TestStatusCodes() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test OK status
        Set status = $$$OK
        Do $$$AssertStatusOK(status, "Status should be OK")
        
        // Test error status
        Set errorStatus = $$$ERROR($$$GeneralError, "Test error")
        Do $$$AssertStatusNotOK(errorStatus, "Status should be error")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test collections
Method TestCollections() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test with lists
        Set list = $LISTBUILD("apple", "banana", "cherry")
        Do $$$AssertTrue($LISTLENGTH(list) = 3, "List should have 3 items")
        Do $$$AssertEquals($LIST(list, 2), "banana", "Second item should be banana")
        
        // Test with dynamic objects
        Set obj = {}
        Set obj.name = "Test"
        Set obj.value = 42
        Do $$$AssertEquals(obj.name, "Test", "Object property should match")
        Do $$$AssertEquals(obj.value, 42, "Object value should match")
        
        // Test with dynamic arrays
        Set arr = []
        Do arr.%Push("first")
        Do arr.%Push("second")
        Do $$$AssertEquals(arr.%Size(), 2, "Array should have 2 items")
        Do $$$AssertEquals(arr.%Get(0), "first", "First array item should match")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test string operations
Method TestStringOperations() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test string concatenation
        Set str1 = "Hello"
        Set str2 = "World"
        Set combined = str1 _ " " _ str2
        Do $$$AssertEquals(combined, "Hello World", "String concatenation")
        
        // Test string functions
        Set upper = $ZCONVERT("hello", "U")
        Do $$$AssertEquals(upper, "HELLO", "Uppercase conversion")
        
        Set lower = $ZCONVERT("HELLO", "L")
        Do $$$AssertEquals(lower, "hello", "Lowercase conversion")
        
        Set length = $LENGTH("test")
        Do $$$AssertEquals(length, 4, "String length")
        
        Set piece = $PIECE("a,b,c", ",", 2)
        Do $$$AssertEquals(piece, "b", "String piece extraction")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test date operations
Method TestDateOperations() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test current date
        Set today = +$HOROLOG
        Do $$$AssertTrue(today > 0, "Today should be positive number")
        
        // Test date comparison
        Set yesterday = today - 1
        Do $$$AssertTrue(today > yesterday, "Today should be after yesterday")
        
        // Test date from constants
        Set testDate = ##class(Patterns.Test.Fixtures.TestConstants).#TESTDATETODAY
        Do $$$AssertTrue(testDate > 0, "Test date should be valid")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test numeric operations
Method TestNumericOperations() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Basic math
        Do $$$AssertEquals(10 + 5, 15, "Addition")
        Do $$$AssertEquals(10 - 5, 5, "Subtraction")
        Do $$$AssertEquals(10 * 5, 50, "Multiplication")
        Do $$$AssertEquals(10 / 5, 2, "Division")
        Do $$$AssertEquals(10 # 3, 1, "Modulo")
        
        // Comparisons
        Do $$$AssertTrue(10 > 5, "Greater than")
        Do $$$AssertTrue(5 < 10, "Less than")
        Do $$$AssertTrue(10 >= 10, "Greater or equal")
        Do $$$AssertTrue(10 <= 10, "Less or equal")
        
        // Test with constants
        Set pi = ##class(Patterns.Test.Fixtures.TestConstants).#TESTNUMBERPI
        Do ..AssertInRange(pi, 3.14, 3.15, "Pi should be in expected range")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test pattern contract validation (placeholder)
Method TestPatternContract() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // This would test actual pattern implementations
        // For now, just test the assertion method exists
        
        // Create a simple test object
        Set testObj = ##class(%Library.DynamicObject).%New()
        Set testObj.type = "TestPattern"
        Set testObj.name = "Example"
        
        // Would normally validate against a pattern contract
        Do $$$AssertTrue(testObj.type '= "", "Object should have type")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Test cleanup in teardown
Method TestCleanup() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create some test data
        Set ^TestTemp("CleanupTest") = "TempValue"
        Do $$$AssertTrue($DATA(^TestTemp("CleanupTest")), "Temp data should exist")
        
        // Note: Cleanup would happen in OnAfterOneTest
        // This is just to verify we can create and check data
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
