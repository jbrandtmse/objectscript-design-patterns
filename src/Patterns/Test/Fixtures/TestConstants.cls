/// Test constants for unit and integration tests
/// Provides consistent values for test scenarios
Class Patterns.Test.Fixtures.TestConstants
{

/// Test timeout values in seconds
Parameter TIMEOUTSHORT = 1;

Parameter TIMEOUTMEDIUM = 5;

Parameter TIMEOUTLONG = 30;

Parameter TIMEOUTVERYLONG = 60;

/// Performance thresholds in milliseconds
Parameter PERFFAST = 100;

Parameter PERFNORMAL = 500;

Parameter PERFSLOW = 2000;

Parameter PERFVERYSLOW = 5000;

/// Test data sizes
Parameter SIZETINY = 10;

Parameter SIZESMALL = 100;

Parameter SIZEMEDIUM = 1000;

Parameter SIZELARGE = 10000;

Parameter SIZEHUGE = 100000;

/// Common test strings
Parameter TESTSTRINGEMPTY;

Parameter TESTSTRINGSINGLE = "A";

Parameter TESTSTRINGSHORT = "Test";

Parameter TESTSTRINGMEDIUM = "The quick brown fox jumps over the lazy dog";

Parameter TESTSTRINGLONG = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

Parameter TESTSTRINGSPECIAL = "!@#$%^&*()_+-=[]{}|;':,./<>?`~";

Parameter TESTSTRINGUNICODE = "Hello 世界 مرحبا мир 🌍";

/// Common test numbers
Parameter TESTNUMBERZERO = 0;

Parameter TESTNUMBERONE = 1;

Parameter TESTNUMBERNEGATIVE = -1;

Parameter TESTNUMBERMININT = -2147483648;

Parameter TESTNUMBERMAXINT = 2147483647;

Parameter TESTNUMBERPI = 3.14159265359;

Parameter TESTNUMBERE = 2.71828182846;

/// Test file paths
Parameter TESTFILETEMP = "/tmp/test_temp.txt";

Parameter TESTFILEINPUT = "/tmp/test_input.txt";

Parameter TESTFILEOUTPUT = "/tmp/test_output.txt";

Parameter TESTFILELOG = "/tmp/test_log.txt";

/// Test namespaces
Parameter TESTNAMESPACEDEFAULT = "PATTERNS-TEST";

Parameter TESTNAMESPACEUNIT = "PATTERNS-TEST-UNIT";

Parameter TESTNAMESPACEINTEGRATION = "PATTERNS-TEST-INT";

Parameter TESTNAMESPACEPERFORMANCE = "PATTERNS-TEST-PERF";

/// Error codes for testing
Parameter ERRORNONE = 0;

Parameter ERRORGENERAL = 5001;

Parameter ERRORINVALIDPARAM = 5002;

Parameter ERRORNOTFOUND = 5003;

Parameter ERRORTIMEOUT = 5004;

Parameter ERRORPERMISSION = 5005;

/// Test user credentials
Parameter TESTUSERADMIN = "testadmin";

Parameter TESTUSERREGULAR = "testuser";

Parameter TESTUSERREADONLY = "testreadonly";

Parameter TESTPASSWORDDEFAULT = "Test@123";

/// Database connection strings
Parameter TESTDBMEMORY = "jdbc:IRIS://localhost:1972/PATTERNS-TEST";

Parameter TESTDBFILE = "jdbc:IRIS://localhost:1972/PATTERNS-TEST-FILE";

/// Common test dates (in $HOROLOG format)
Parameter TESTDATEPAST = 65000;

// Approximate date in past

Parameter TESTDATETODAY = 66000;

// Approximate current date

Parameter TESTDATEFUTURE = 67000;

// Approximate future date

/// Test pattern names
Parameter PATTERNSINGLETON = "Singleton";

Parameter PATTERNFACTORY = "Factory";

Parameter PATTERNOBSERVER = "Observer";

Parameter PATTERNSTRATEGY = "Strategy";

Parameter PATTERNDECORATOR = "Decorator";

/// Test status values
Parameter STATUSSUCCESS = "SUCCESS";

Parameter STATUSFAILURE = "FAILURE";

Parameter STATUSPENDING = "PENDING";

Parameter STATUSSKIPPED = "SKIPPED";

Parameter STATUSERROR = "ERROR";

/// Mock object defaults
Parameter MOCKDEFAULTRETURN = "MOCK_RETURN_VALUE";

Parameter MOCKDEFAULTEXCEPTION = "MOCK_EXCEPTION";

Parameter MOCKDEFAULTTIMEOUT = 1000;

/// Collection test values
Parameter COLLECTIONEMPTYSIZE = 0;

Parameter COLLECTIONSINGLESIZE = 1;

Parameter COLLECTIONSMALLSIZE = 10;

Parameter COLLECTIONMEDIUMSIZE = 100;

Parameter COLLECTIONLARGESIZE = 1000;

/// Regular expressions for validation
Parameter REGEXEMAIL = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";

Parameter REGEXPHONE = "^\+?1?\d{9,15}$";

Parameter REGEXURL = "^https?://[^\s/$.?#].[^\s]*$";

Parameter REGEXIPV4 = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";

/// Test configuration flags
Parameter CONFIGVERBOSE = 1;

Parameter CONFIGSILENT = 0;

Parameter CONFIGDEBUG = 1;

Parameter CONFIGPRODUCTION = 0;

/// Test resource limits
Parameter LIMITMAXITERATIONS = 10000;

Parameter LIMITMAXRECURSION = 100;

Parameter LIMITMAXTHREADS = 10;

Parameter LIMITMAXMEMORYMB = 1024;

/// Test message templates
Parameter MSGTESTSTARTED = "Test started: {0}";

Parameter MSGTESTPASSED = "Test passed: {0}";

Parameter MSGTESTFAILED = "Test failed: {0} - {1}";

Parameter MSGTESTSKIPPED = "Test skipped: {0}";

Parameter MSGASSERTIONFAILED = "Assertion failed: Expected {0}, but got {1}";

/// HTTP status codes for API testing
Parameter HTTPOK = 200;

Parameter HTTPCREATED = 201;

Parameter HTTPBADREQUEST = 400;

Parameter HTTPUNAUTHORIZED = 401;

Parameter HTTPFORBIDDEN = 403;

Parameter HTTPNOTFOUND = 404;

Parameter HTTPSERVERERROR = 500;

/// Common MIME types
Parameter MIMEJSON = "application/json";

Parameter MIMEXML = "application/xml";

Parameter MIMETEXT = "text/plain";

Parameter MIMEHTML = "text/html";

Parameter MIMEPDF = "application/pdf";

/// Cache TTL values in seconds
Parameter CACHETTLSHORT = 60;

// 1 minute

Parameter CACHETTLMEDIUM = 3600;

// 1 hour

Parameter CACHETTLLONG = 86400;

// 1 day

Parameter CACHETTLPERMANENT = -1;

// Never expires

/// Get a constant value by name
/// pName: Name of the constant
/// Returns: Value of the constant or empty string if not found
ClassMethod GetConstant(pName As %String) As %String
{
    Try {
        // Use $PARAMETER to get the value dynamically
        Return $PARAMETER($CLASSNAME(), pName)
    } Catch ex {
        Return ""
    }
}

/// Get all constants matching a prefix
/// pPrefix: Prefix to match (e.g., "TESTSTRING")
/// Returns: %DynamicObject with matching constants
ClassMethod GetConstantsByPrefix(pPrefix As %String) As %DynamicObject
{
    Set result = {}
    
    // List of all constants (would need to be maintained)
    Set constants = $LISTBUILD(
        "TIMEOUTSHORT", "TIMEOUTMEDIUM", "TIMEOUTLONG", "TIMEOUTVERYLONG",
        "PERFFAST", "PERFNORMAL", "PERFSLOW", "PERFVERYSLOW",
        "SIZETINY", "SIZESMALL", "SIZEMEDIUM", "SIZELARGE", "SIZEHUGE",
        "TESTSTRINGEMPTY", "TESTSTRINGSINGLE", "TESTSTRINGSHORT", 
        "TESTSTRINGMEDIUM", "TESTSTRINGLONG", "TESTSTRINGSPECIAL", "TESTSTRINGUNICODE",
        "TESTNUMBERZERO", "TESTNUMBERONE", "TESTNUMBERNEGATIVE",
        "TESTNUMBERMININT", "TESTNUMBERMAXINT", "TESTNUMBERPI", "TESTNUMBERE"
    )
    
    Set ptr = 0
    While $LISTNEXT(constants, ptr, constant) {
        If $FIND(constant, pPrefix) = ($LENGTH(pPrefix) + 1) {
            Set $PROPERTY(result, constant) = ..GetConstant(constant)
        }
    }
    
    Return result
}

}
