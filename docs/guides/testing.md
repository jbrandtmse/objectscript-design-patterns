# Testing Guide

This guide covers the testing framework and best practices for the ObjectScript Design Patterns Library.

## Table of Contents
- [Running Tests](#running-tests)
- [Writing Tests](#writing-tests)
- [Mock Framework](#mock-framework)
- [Test Data Generation](#test-data-generation)
- [Best Practices](#best-practices)
- [Coverage Requirements](#coverage-requirements)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)

## Running Tests

### Using TestRunner

The TestRunner class provides a simple interface to execute tests:

```objectscript
// Run all tests in a package
Do ##class(TestRunner).RunTests("Patterns.Test.Example")

// Run a specific test class
Do ##class(TestRunner).RunTests("Patterns.Test.Example.BasicTest")

// Run with verbose output
Do ##class(TestRunner).RunTests("Patterns.Test.Example", 1)
```

### Using %UnitTest.Manager

For more control, use the %UnitTest.Manager directly:

```objectscript
// Set test root directory
Set ^UnitTestRoot = "/path/to/tests"

// Run tests with qualifiers
Do ##class(%UnitTest.Manager).RunTest("TestSuite", "/nodelete/recursive")
```

## Writing Tests

### Basic Test Structure

All test classes should extend `Patterns.Test.TestCase`:

```objectscript
Class MyPackage.MyTest Extends Patterns.Test.TestCase
{
    /// Test methods must start with "Test" and return %Status
    Method TestSomething() As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Your test logic here
            Do ..AssertEquals(actual, expected, "Description")
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}
```

### Available Assertions

The TestCase base class provides these assertion methods:

- `AssertEquals(actual, expected, description)` - Check equality
- `AssertNotEquals(actual, expected, description)` - Check inequality
- `AssertTrue(condition, description)` - Check true condition
- `AssertFalse(condition, description)` - Check false condition
- `AssertStatusOK(status, description)` - Check %Status is OK
- `AssertStatusNotOK(status, description)` - Check %Status is error
- `AssertCondition(condition, description)` - Custom condition
- `AssertInRange(value, min, max, description)` - Check value in range
- `AssertCollectionCount(collection, count, description)` - Check collection size
- `AssertPerformance(elapsed, maxMs, description)` - Performance check
- `AssertPatternContract(object, pattern, description)` - Pattern validation

### Setup and Teardown

The TestCase class provides lifecycle methods:

```objectscript
/// Called before each test method
Method OnBeforeOneTest() As %Status
{
    // Initialize test data
    Set ^TestData = "Initial"
    Quit $$$OK
}

/// Called after each test method
Method OnAfterOneTest() As %Status
{
    // Clean up test data
    Kill ^TestData
    Quit $$$OK
}
```

## Mock Framework

### Creating Mocks

Use MockBuilder to create mock objects:

```objectscript
// Create a mock
Set mock = ##class(Patterns.Test.MockBuilder).%New()
Set mock.ClassName = "ServiceClass"

// Set expectations
Do mock.ExpectCall("GetData").Returns("MockedData")
Do mock.ExpectCall("SaveData").WithArgs("value").Returns(1).Once()

// Record calls (simulate usage)
Do mock.RecordCall("GetData", $LISTBUILD())
Do mock.RecordCall("SaveData", $LISTBUILD("value"))

// Verify expectations
Set verified = mock.Verify()
Do ..AssertTrue(verified, "Mock expectations met")
```

### Mock Expectations

Configure expectations with fluent interface:

```objectscript
// Expect specific arguments
Do mock.ExpectCall("Method").WithArgs("arg1", "arg2")

// Set return value
Do mock.ExpectCall("Method").Returns("result")

// Control call count
Do mock.ExpectCall("Method").Times(3)    // Exactly 3 times
Do mock.ExpectCall("Method").AtLeast(2)  // Minimum 2 times
Do mock.ExpectCall("Method").AtMost(5)   // Maximum 5 times
Do mock.ExpectCall("Method").Once()      // Exactly once
Do mock.ExpectCall("Method").Twice()     // Exactly twice
Do mock.ExpectCall("Method").Never()     // Should not be called
```

## Test Data Generation

### Using TestDataGenerator

Generate consistent test data with seeds:

```objectscript
// Generate persons with seed for reproducibility
Set persons = ##class(Patterns.Test.Fixtures.TestDataGenerator).GeneratePersons(5, 123)

// Generate order graph
Set orders = ##class(Patterns.Test.Fixtures.TestDataGenerator).GenerateOrderGraph(10, 456)

// Generate random data
Set randomInt = ##class(Patterns.Test.Fixtures.TestDataGenerator).GetRandomInteger(1, 100, 789)
Set randomString = ##class(Patterns.Test.Fixtures.TestDataGenerator).GetRandomString(10, 101)

// Generate documents
Set xml = ##class(Patterns.Test.Fixtures.TestDataGenerator).GenerateXMLDocument(3, 202)
Set json = ##class(Patterns.Test.Fixtures.TestDataGenerator).GenerateJSONDocument(5, 303)
```

### Using Test Constants

Access predefined test values:

```objectscript
// Timeout values
Set timeout = ##class(Patterns.Test.Fixtures.TestConstants).#TIMEOUTSHORT

// Test strings
Set testStr = ##class(Patterns.Test.Fixtures.TestConstants).#TESTSTRINGMEDIUM

// HTTP status codes
Set httpOk = ##class(Patterns.Test.Fixtures.TestConstants).#HTTPOK

// Get constant by name
Set value = ##class(Patterns.Test.Fixtures.TestConstants).GetConstant("HTTPOK")

// Get constants by prefix
Set constants = ##class(Patterns.Test.Fixtures.TestConstants).GetConstantsByPrefix("HTTP")
```

## Best Practices

### Test Organization

1. **One test class per production class** - Mirror the structure of production code
2. **Group related tests** - Use meaningful method names
3. **Test isolation** - Each test should be independent
4. **Clean up** - Always clean up test data in teardown

### Test Naming

Use descriptive test method names:

```objectscript
Method TestConstructorWithValidParameters() As %Status
Method TestMethodThrowsErrorOnNullInput() As %Status
Method TestPerformanceUnderLoad() As %Status
```

### Test Coverage

Aim for comprehensive coverage:

- **Happy path** - Normal expected behavior
- **Edge cases** - Boundary conditions
- **Error conditions** - Invalid inputs, exceptions
- **Performance** - Response times, resource usage
- **Concurrency** - Thread safety (if applicable)

### Assertion Messages

Always provide meaningful assertion messages:

```objectscript
// Good
Do ..AssertEquals(result, 42, "Calculator should return 42 for sum of 20 and 22")

// Bad
Do ..AssertEquals(result, 42, "Test failed")
```

## Coverage Requirements

### Minimum Coverage Targets

- **Overall Coverage**: 80%
- **Critical Components**: 90%
- **Pattern Implementations**: 95%
- **Utility Classes**: 70%

### Measuring Coverage

Use IRIS coverage tools:

```objectscript
// Start coverage
Do ##class(%Monitor.System.LineByLine).Start("/path/to/coverage.log", "Patterns.*")

// Run tests
Do ##class(TestRunner).RunTests("Patterns.Test")

// Stop coverage
Do ##class(%Monitor.System.LineByLine).Stop()

// Generate report
Do ##class(%Monitor.System.LineByLine).Report()
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Run ObjectScript Tests
      run: |
        iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<EOF
        Do ##class(TestRunner).RunTests("Patterns.Test")
        Halt
        EOF
    
    - name: Check Test Results
      run: |
        # Check for test failures
        grep -q "All tests passed" test-output.log
```

### Pre-commit Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Run tests before commit
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<EOF
Set result = ##class(TestRunner).RunTests("Patterns.Test", 0)
If 'result {
    Write "Tests failed. Commit aborted.", !
    Halt 1
}
Halt
EOF
```

## Troubleshooting

### Common Issues

#### Tests Not Found

```objectscript
// Check test root is set correctly
Write ^UnitTestRoot

// Verify class compilation
Do $System.OBJ.Compile("Patterns.Test.*", "ck")
```

#### Mock Verification Failures

```objectscript
// Enable strict mode for detailed errors
Set mock.StrictMode = 1

// Check call history
Set history = mock.CallHistory
Write "Recorded calls: ", history.%ToJSON()
```

#### Performance Test Failures

```objectscript
// Increase timeout for slow systems
Set timeout = ##class(Patterns.Test.Fixtures.TestConstants).#TIMEOUTLONG

// Use relative performance thresholds
Do ..AssertPerformance(elapsed, baseline * 1.5, "Should be within 150% of baseline")
```

### Debug Output

Enable debug output in tests:

```objectscript
Method TestWithDebug() As %Status
{
    Set ..Debug = 1  // Enable debug mode
    
    Do ..LogMessage("Starting test")
    // Test logic here
    Do ..LogMessage("Test completed")
    
    Quit $$$OK
}
```

### Test Isolation Issues

Ensure proper cleanup:

```objectscript
Method OnAfterOneTest() As %Status
{
    // Kill all test globals
    Kill ^TestData, ^TestTemp
    
    // Reset any modified settings
    Set ^MyApp("Setting") = "default"
    
    // Close any open transactions
    If $TLEVEL > 0 {
        While $TLEVEL > 0 { TRollback }
    }
    
    Quit $$$OK
}
```

## Example Test Suite

See `src/Patterns/Test/Example/BasicTest.cls` for a comprehensive example demonstrating:

- Basic assertions
- Mock objects
- Test data generation
- Performance testing
- Setup and teardown
- Error handling
- Collection testing
- String and date operations

## Additional Resources

- [InterSystems %UnitTest Documentation](https://docs.intersystems.com/iris/csp/docbook/DocBook.UI.Page.cls?KEY=TUNT)
- [Test-Driven Development in ObjectScript](https://community.intersystems.com/post/test-driven-development-objectscript)
- [Mock Object Pattern](https://en.wikipedia.org/wiki/Mock_object)
