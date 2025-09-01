Include %outUnitTest

/// Base test case class for all pattern tests
/// Extends %UnitTest.TestCase with additional pattern-specific testing capabilities
/// 
/// @since 1.0.0
Class Patterns.Test.TestCase Extends %UnitTest.TestCase
{

// ===== CONSTRUCTOR =====

/// Constructor - properly handles initvalue parameter from parent class
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    // Don't initialize properties here - do it in OnBeforeOneTest
    // to avoid INVALID OREF issues during test framework initialization
    
    Quit $$$OK
}

// ===== PROPERTIES =====

/// Instance of the pattern being tested
Property PatternInstance As %RegisteredObject;

/// Data used during test execution - renamed to avoid "Test" prefix
Property DataForTesting As %DynamicObject;

/// Performance metrics collected during testing
Property Metrics As %DynamicObject;

/// Start time for performance measurements - MultiDimensional properties don't have types
Property StartTime [ MultiDimensional, Private ];

// ===== SETUP AND TEARDOWN =====

/// Called before each test method execution
/// Initializes test data and metrics
Method OnBeforeOneTest() As %Status
{
    Set sc = $$$OK
    
    Try {
        // Initialize test data container
        Set ..DataForTesting = {}
        
        // Initialize metrics container
        Set ..Metrics = {}
        Set ..Metrics.startTime = $ZHOROLOG
        // Store test name from the test context
        Set ..Metrics.testName = "test"
        
        // Record test start time for performance measurements
        Set ..StartTime = $ZHOROLOG
        
        // Create test data global for tests to use
        Set ^TestData = $HOROLOG
        Set ^TestData("Initialized") = 1
        
        // Call custom setup if implemented
        Set sc = ..CustomSetup()
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Do ..LogMessage("Setup error: "_$SYSTEM.Status.GetErrorText(sc))
    }
    
    Return sc
}

/// Called after each test method execution
/// Cleans up resources and records metrics
Method OnAfterOneTest() As %Status
{
    Set sc = $$$OK
    
    Try {
        // Record test execution time
        If $DATA(..StartTime) {
            Set ..Metrics.executionTime = $ZHOROLOG - ..StartTime
            Do ..LogMessage("Test execution time: "_..Metrics.executionTime_" seconds")
        }
        
        // Clean up pattern instance if exists
        If $ISOBJECT(..PatternInstance) {
            Do ..PatternInstance.%Close()
            Set ..PatternInstance = ""
        }
        
        // Clean up test globals
        Kill ^TestData
        Kill ^TestTemp
        
        // Call custom cleanup if implemented
        Set sc = ..CustomCleanup()
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Do ..LogMessage("Cleanup error: "_$SYSTEM.Status.GetErrorText(sc))
    }
    
    Return sc
}

/// Custom setup method for subclasses to override
/// Called during OnBeforeOneTest
Method CustomSetup() As %Status
{
    Return $$$OK
}

/// Custom cleanup method for subclasses to override
/// Called during OnAfterOneTest
Method CustomCleanup() As %Status
{
    Return $$$OK
}

// ===== CUSTOM ASSERTIONS =====

/// Assert that a pattern implements the expected contract
/// Verifies that required methods and properties exist
/// 
/// @param pPattern The pattern instance to validate
/// @param pContract Comma-separated list of required methods/properties
/// @return Boolean indicating if assertion passed
Method AssertPatternContract(pPattern As %RegisteredObject, pContract As %String) As %Boolean
{
    Set passed = 1
    Set failureReasons = ""
    
    If '$ISOBJECT(pPattern) {
        Do $$$AssertTrue(0, "Pattern instance is not an object")
        Return 0
    }
    
    // Parse contract requirements
    Set contractList = $LISTFROMSTRING(pContract, ",")
    Set ptr = 0
    
    While $LISTNEXT(contractList, ptr, requirement) {
        Set requirement = $ZSTRIP(requirement, "<>W")
        
        // Check if requirement is a method (ends with ())
        If $EXTRACT(requirement, *-1, *) = "()" {
            Set methodName = $EXTRACT(requirement, 1, *-2)
            If '##class(%Dictionary.CompiledMethod).%ExistsId(pPattern.%ClassName(1)_"||"_methodName) {
                Set passed = 0
                Set failureReasons = failureReasons_$SELECT(failureReasons'="": ", ", 1: "")_"Missing method: "_methodName
            }
        }
        // Otherwise it's a property
        Else {
            If '##class(%Dictionary.CompiledProperty).%ExistsId(pPattern.%ClassName(1)_"||"_requirement) {
                Set passed = 0
                Set failureReasons = failureReasons_$SELECT(failureReasons'="": ", ", 1: "")_"Missing property: "_requirement
            }
        }
    }
    
    If passed {
        Do $$$AssertTrue(1, "Pattern implements required contract")
    } Else {
        Do $$$AssertTrue(0, "Pattern contract violation: "_failureReasons)
    }
    
    Return passed
}

/// Assert that an elapsed time is within specified limit
/// 
/// @param pElapsedTime The elapsed time in milliseconds
/// @param pMaxTime Maximum allowed time in milliseconds
/// @param pDescription Description of the assertion
Method AssertPerformance(pElapsedTime As %Decimal, pMaxTime As %Decimal, pDescription As %String = "")
{
    Set passed = (pElapsedTime <= pMaxTime)
    
    Set message = $SELECT(
        pDescription '= "": pDescription_": ",
        1: "Performance check: "
    )_"Elapsed "_pElapsedTime_"ms"_$SELECT(passed: " <= ", 1: " > ")_pMaxTime_"ms"
    
    Do $$$AssertTrue(passed, message)
}

/// Assert that a value is within expected range
/// 
/// @param pValue The value to check
/// @param pMin Minimum allowed value
/// @param pMax Maximum allowed value
/// @param pDescription Description of the assertion
Method AssertInRange(pValue As %Numeric, pMin As %Numeric, pMax As %Numeric, pDescription As %String = "")
{
    Set inRange = (pValue >= pMin) && (pValue <= pMax)
    Set message = $SELECT(
        pDescription '= "": pDescription_": ",
        1: ""
    )_pValue_" should be between "_pMin_" and "_pMax
    
    Do $$$AssertTrue(inRange, message)
}

/// Assert that a collection contains expected number of items
/// Handles both $LISTBUILD lists and object collections
/// 
/// @param pCollection Collection (can be $LISTBUILD or object)
/// @param pExpectedCount Expected number of items
/// @param pDescription Description of the assertion
Method AssertCollectionCount(pCollection, pExpectedCount As %Integer, pDescription As %String = "")
{
    Set actualCount = 0
    
    // Check if it's a $LISTBUILD
    If $LISTVALID(pCollection) {
        Set actualCount = $LISTLENGTH(pCollection)
    }
    // Check if it's an object collection
    ElseIf $ISOBJECT(pCollection) {
        // Dynamic array
        If pCollection.%IsA("%Library.DynamicArray") {
            Set actualCount = pCollection.%Size()
        }
        // Dynamic object (count properties)
        ElseIf pCollection.%IsA("%Library.DynamicObject") {
            Set iter = pCollection.%GetIterator()
            While iter.%GetNext() {
                Set actualCount = actualCount + 1
            }
        }
        // Traditional collection classes
        ElseIf pCollection.%IsA("%Collection.AbstractList") {
            Set actualCount = pCollection.Count()
        } ElseIf pCollection.%IsA("%Collection.AbstractArray") {
            Set actualCount = pCollection.Count()
        }
    }
    
    Set message = $SELECT(
        pDescription '= "": pDescription_": ",
        1: "Collection count: "
    )_"Expected "_pExpectedCount_", got "_actualCount
    
    Do $$$AssertEquals(actualCount, pExpectedCount, message)
}

/// Assert that an exception is thrown when executing code
/// 
/// @param pCode Code to execute that should throw exception
/// @param pExpectedError Expected error code (optional)
/// @param pDescription Description of the assertion
Method AssertException(pCode As %String, pExpectedError As %String = "", pDescription As %String = "")
{
    Set exceptionThrown = 0
    Set actualError = ""
    
    Try {
        XECUTE pCode
    } Catch ex {
        Set exceptionThrown = 1
        Set actualError = ex.Name
    }
    
    If 'exceptionThrown {
        Do $$$AssertTrue(0, $SELECT(pDescription'="": pDescription_": ", 1: "")_"Expected exception was not thrown")
        Return
    }
    
    If pExpectedError '= "" {
        Do $$$AssertEquals(actualError, pExpectedError, $SELECT(pDescription'="": pDescription_": ", 1: "")_"Exception type mismatch")
    } Else {
        Do $$$AssertTrue(1, $SELECT(pDescription'="": pDescription_": ", 1: "")_"Exception thrown as expected")
    }
}

// ===== HELPER METHODS =====

/// Generate test data for a specific type
/// 
/// @param pType Type of data to generate (Person, Order, etc.)
/// @param pCount Number of items to generate
/// @return Generated test data
Method GenerateTestData(pType As %String, pCount As %Integer = 1) As %DynamicObject
{
    Set data = []
    
    For i = 1:1:pCount {
        If pType = "Person" {
            Set person = {}
            Set person.id = "TEST-"_$RANDOM(99999)
            Set person.firstName = "Test"_i
            Set person.lastName = "User"_i
            Set person.email = "test"_i_"@example.com"
            Set person.age = 20 + $RANDOM(50)
            Do data.%Push(person)
        }
        ElseIf pType = "Order" {
            Set order = {}
            Set order.id = "ORD-"_$RANDOM(99999)
            Set order.customerId = "CUST-"_$RANDOM(999)
            Set order.orderDate = $HOROLOG
            Set order.total = $RANDOM(1000) + ($RANDOM(100) / 100)
            Set order.status = $LISTGET($LISTBUILD("pending", "processing", "shipped", "delivered"), $RANDOM(4) + 1)
            Do data.%Push(order)
        }
    }
    
    Return $SELECT(pCount = 1: data.%Get(0), 1: data)
}

/// Create a mock object for testing
/// 
/// @param pClassName Class name to mock
/// @return Mock object instance
Method CreateMock(pClassName As %String) As %RegisteredObject
{
    // This will be enhanced when MockBuilder is implemented
    // For now, return a simple dynamic object
    Set mock = {}
    Set mock.%ClassName = pClassName
    Set mock.%IsMock = 1
    Return mock
}

/// Log a message with timestamp
/// 
/// @param pMessage Message to log
Method LogTestMessage(pMessage As %String)
{
    Do ..LogMessage("["_$ZDATETIME($HOROLOG, 3, 1)_"] "_pMessage)
}

/// Measure execution time of a code block
/// 
/// @param pLabel Label for the measurement
/// @return Start time (use with EndMeasure)
Method StartMeasure(pLabel As %String = "") As %Decimal
{
    Set startTime = $ZHOROLOG
    If pLabel '= "" {
        Do ..LogTestMessage("Starting measurement: "_pLabel)
    }
    Return startTime
}

/// End measurement and log execution time
/// 
/// @param pStartTime Start time from StartMeasure
/// @param pLabel Label for the measurement
/// @return Execution time in seconds
Method EndMeasure(pStartTime As %Decimal, pLabel As %String = "") As %Decimal
{
    Set executionTime = $ZHOROLOG - pStartTime
    Set message = "Execution time"_$SELECT(pLabel'="": " for "_pLabel, 1: "")_": "_executionTime_" seconds"
    Do ..LogTestMessage(message)
    Return executionTime
}

// ===== Additional Assertion Methods =====

// These methods wrap the parent class assertions for convenience

/// Assert condition is true
Method AssertCondition(pCondition As %Boolean, pDescription As %String = "") As %Boolean
{
    Do $$$AssertTrue(pCondition, pDescription)
    Return pCondition
}

}
