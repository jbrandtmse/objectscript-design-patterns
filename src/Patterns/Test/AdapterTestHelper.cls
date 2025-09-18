/// Helper class for testing Adapter pattern implementations
Class Patterns.Test.AdapterTestHelper
{

/// Test ClassAdapter functionality
ClassMethod TestClassAdapter() As %String
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Testing ClassAdapter; "
    Set tReturnValue = ""
    
    Try {
        // Create class adapter instance
        Set tAdapter = ##class(Patterns.GoF.Structural.ClassAdapter).%New()
        Set ^ClineDebug = ^ClineDebug_"ClassAdapter created; "
        
        // Test request delegation
        Set tResult = tAdapter.Request()
        Set ^ClineDebug = ^ClineDebug_"Request result: "_tResult_"; "
        
        If (tResult [ "Adapted:") {
            Set tReturnValue = "ClassAdapter test PASSED"
        } Else {
            Set tReturnValue = "ClassAdapter test FAILED: Expected 'Adapted:' in result"
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set tReturnValue = "ClassAdapter test ERROR: "_ex.DisplayString()
    }
    
    Quit tReturnValue
}

/// Test ObjectAdapter functionality
ClassMethod TestObjectAdapter() As %String
{
    Set ^ClineDebug = ^ClineDebug_"Testing ObjectAdapter; "
    Set tReturnValue = ""
    
    Try {
        // Test with standard Adaptee
        Set tAdaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
        Set ^ClineDebug = ^ClineDebug_"Adaptee created; "
        
        Set tAdapter = ##class(Patterns.GoF.Structural.ObjectAdapter).%New(tAdaptee)
        Set ^ClineDebug = ^ClineDebug_"ObjectAdapter created; "
        
        Set tResult = tAdapter.Request()
        Set ^ClineDebug = ^ClineDebug_"Request result: "_tResult_"; "
        
        If (tResult [ "Object Adapted:") {
            Set tReturnValue = "ObjectAdapter test PASSED"
        } Else {
            Set tReturnValue = "ObjectAdapter test FAILED: Expected 'Object Adapted:' in result"
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set tReturnValue = "ObjectAdapter test ERROR: "_ex.DisplayString()
    }
    
    Quit tReturnValue
}

/// Test HL7ToFHIRAdapter functionality
ClassMethod TestHL7ToFHIRAdapter() As %String
{
    Set ^ClineDebug = ^ClineDebug_"Testing HL7ToFHIRAdapter; "
    Set tReturnValue = ""
    
    Try {
        // Create HL7 ADT message
        Set tHL7Message = ##class(Patterns.Examples.HL7Message).CreateSampleADTMessage()
        Set ^ClineDebug = ^ClineDebug_"HL7 message created; "
        
        // Create adapter and convert
        Set tAdapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7Message)
        Set ^ClineDebug = ^ClineDebug_"HL7ToFHIRAdapter created; "
        
        Set tStatus = tAdapter.Convert()
        If $$$ISERR(tStatus) {
            Set ^ClineDebug = ^ClineDebug_"Conversion failed: "_$System.Status.GetErrorText(tStatus)_"; "
            Set tReturnValue = "HL7ToFHIRAdapter test FAILED: "_$System.Status.GetErrorText(tStatus)
        } Else {
            Set ^ClineDebug = ^ClineDebug_"Conversion successful; "
            
            Set tResources = tAdapter.FHIRResources
            If '$ISOBJECT(tResources) {
                Set tReturnValue = "HL7ToFHIRAdapter test FAILED: No FHIRResources collection"
            } Else {
                Set tCount = tResources.Count()
                Set ^ClineDebug = ^ClineDebug_"Resources count: "_tCount_"; "
                
                If tCount = 1 {
                    Set tPatient = tResources.GetAt(1)
                    If $ISOBJECT(tPatient) {
                        Set ^ClineDebug = ^ClineDebug_"Patient MRN: "_tPatient.MRN_"; "
                        Set tReturnValue = "HL7ToFHIRAdapter test PASSED with "_tCount_" resource(s)"
                    } Else {
                        Set tReturnValue = "HL7ToFHIRAdapter test FAILED: Patient resource not an object"
                    }
                } Else {
                    Set tReturnValue = "HL7ToFHIRAdapter test FAILED: Expected 1 resource, got "_tCount
                }
            }
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set tReturnValue = "HL7ToFHIRAdapter test ERROR: "_ex.DisplayString()
    }
    
    Quit tReturnValue
}

/// Test LegacyCodeAdapter functionality
ClassMethod TestLegacyCodeAdapter() As %String
{
    Set ^ClineDebug = ^ClineDebug_"Testing LegacyCodeAdapter; "
    Set tReturnValue = ""
    
    Try {
        // Create legacy adaptee
        Set tLegacyAdaptee = ##class(Patterns.GoF.Structural.LegacyAdaptee).%New()
        Set ^ClineDebug = ^ClineDebug_"LegacyAdaptee created; "
        
        Set tAdapter = ##class(Patterns.GoF.Structural.LegacyCodeAdapter).%New(tLegacyAdaptee)
        Set ^ClineDebug = ^ClineDebug_"LegacyCodeAdapter created; "
        
        // Test request handling
        Set tResult = tAdapter.Request()
        Set ^ClineDebug = ^ClineDebug_"Request result: "_tResult_"; "
        
        If (tResult [ "Modern Adapted:") {
            // Test legacy operation
            Set tOpResult = tAdapter.ExecuteLegacyOperation("READ")
            Set ^ClineDebug = ^ClineDebug_"Operation result: "_tOpResult_"; "
            
            If (tOpResult [ "Modern Operation:") {
                Set tReturnValue = "LegacyCodeAdapter test PASSED"
            } Else {
                Set tReturnValue = "LegacyCodeAdapter test FAILED: ExecuteLegacyOperation didn't return expected result"
            }
        } Else {
            Set tReturnValue = "LegacyCodeAdapter test FAILED: Request didn't return expected result"
        }
    }
    Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()_"; "
        Set tReturnValue = "LegacyCodeAdapter test ERROR: "_ex.DisplayString()
    }
    
    Quit tReturnValue
}

/// Run all tests
ClassMethod RunAllTests() As %String
{
    Set ^ClineDebug = ""
    Set ^ClineDebug = ^ClineDebug_"Starting Adapter pattern tests; "
    
    Set tResults = ""
    
    // Test ClassAdapter
    Set tResult1 = ..TestClassAdapter()
    Set tResults = tResults_"ClassAdapter: "_tResult1_$C(13,10)
    
    // Test ObjectAdapter
    Set tResult2 = ..TestObjectAdapter()
    Set tResults = tResults_"ObjectAdapter: "_tResult2_$C(13,10)
    
    // Test HL7ToFHIRAdapter
    Set tResult3 = ..TestHL7ToFHIRAdapter()
    Set tResults = tResults_"HL7ToFHIRAdapter: "_tResult3_$C(13,10)
    
    // Test LegacyCodeAdapter
    Set tResult4 = ..TestLegacyCodeAdapter()
    Set tResults = tResults_"LegacyCodeAdapter: "_tResult4_$C(13,10)
    
    Set ^ClineDebug = ^ClineDebug_"All tests complete; "
    Quit tResults
}

}
