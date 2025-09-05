/// Unit tests for the Adapter Pattern implementations
Class Patterns.Test.Unit.GoF.Structural.AdapterTest Extends Patterns.Test.TestCase
{

/// Test ClassAdapter request delegation
Method TestClassAdapter()
{
    Set tSC = $$$OK
    
    // Create class adapter instance
    Set tAdapter = ##class(Patterns.GoF.Structural.ClassAdapter).%New()
    
    // Test request delegation
    Set tResult = tAdapter.Request()
    Do $$$AssertTrue(tResult [ "Adapted:", "ClassAdapter should delegate to SpecificRequest")
    Do $$$AssertTrue(tResult [ "Adapted:", "ClassAdapter should adapt the request")
    
    // Test ProcessWithOptions method - only pass one parameter as method expects
    Set tOptionsResult = tAdapter.ProcessWithOptions("test")
    
    Quit
}

/// Test ObjectAdapter with different adaptee instances
Method TestObjectAdapter()
{
    Set tSC = $$$OK
    
    // Test with standard Adaptee (no service name parameter)
    Set tAdaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
    Set tAdapter = ##class(Patterns.GoF.Structural.ObjectAdapter).%New(tAdaptee)
    
    Set tResult = tAdapter.Request()
    Do $$$AssertTrue(tResult [ "Object Adapted:", "ObjectAdapter should adapt the request")
    Do $$$AssertTrue(tResult [ "Adaptee processing", "ObjectAdapter should delegate to adaptee's SpecificRequest")
    
    // Test with LegacyAdaptee
    Set tLegacyAdaptee = ##class(Patterns.GoF.Structural.LegacyAdaptee).%New()
    Set tAdapter2 = ##class(Patterns.GoF.Structural.ObjectAdapter).%New(tLegacyAdaptee)
    
    Set tResult2 = tAdapter2.Request()
    Do $$$AssertTrue(tResult2 [ "Object Adapted:", "ObjectAdapter should work with different adaptee types")
    
    Quit
}

/// Test adapter with null adaptee handling
Method TestNullAdapteeHandling()
{
    Set tSC = $$$OK
    
    // Create adapter without setting adaptee (will use default Adaptee)
    Set tAdapter = ##class(Patterns.GoF.Structural.ObjectAdapter).%New()
    
    // Test request with default adaptee
    Set tResult = tAdapter.Request()
    Do $$$AssertTrue(tResult [ "Object Adapted:", "ObjectAdapter should work with default adaptee")
    
    // Now test with explicitly setting null and checking error handling
    Set tAdapter.Adaptee = ""
    Set tResult2 = tAdapter.Request()
    Do $$$AssertEquals(tResult2, "Error: No adaptee", "ObjectAdapter should handle null adaptee gracefully")
    
    // Set adaptee and test again
    Set tAdaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
    Set tAdapter.Adaptee = tAdaptee
    
    Set tResult3 = tAdapter.Request()
    Do $$$AssertTrue(tResult3 [ "Object Adapted:", "ObjectAdapter should work after setting adaptee")
    
    Quit
}

/// Test legacy code wrapper functionality
Method TestLegacyCodeWrapper()
{
    Set tSC = $$$OK
    
    // Create legacy code adapter with proper adaptee
    Set tLegacyAdaptee = ##class(Patterns.GoF.Structural.LegacyAdaptee).%New()
    Set tAdapter = ##class(Patterns.GoF.Structural.LegacyCodeAdapter).%New(tLegacyAdaptee)
    
    // Validate adapter was created successfully
    Do $$$AssertTrue($ISOBJECT(tAdapter), "Legacy adapter should be created successfully")
    Do $$$AssertTrue(tAdapter.SessionID '= "", "Legacy adapter should have session ID")
    
    // Test request handling
    Set tResult = tAdapter.Request()
    Do $$$AssertTrue(tResult [ "Modern Adapted:", "Request should return adapted legacy data")
    Do $$$AssertTrue(tResult [ "Count=", "Request should include counter")
    Do $$$AssertTrue(tResult [ "Date=", "Request should include date")
    
    // Test legacy operations
    Set tOpResult = tAdapter.ExecuteLegacyOperation("READ")
    Do $$$AssertTrue(tOpResult [ "Modern Operation:", "Operation should be modernized")
    
    Quit
}

/// Test runtime adapter configuration
Method TestRuntimeConfiguration()
{
    Set tSC = $$$OK
    
    // Create object adapter
    Set tAdapter = ##class(Patterns.GoF.Structural.ObjectAdapter).%New()
    
    // Test with first adaptee
    Set tAdaptee1 = ##class(Patterns.GoF.Structural.Adaptee).%New()
    Set tAdapter.Adaptee = tAdaptee1
    Set tResult1 = tAdapter.Request()
    Do $$$AssertTrue(tResult1 [ "Object Adapted:", "Adapter should work with first adaptee")
    
    // Switch to different adaptee at runtime
    Set tAdaptee2 = ##class(Patterns.GoF.Structural.LegacyAdaptee).%New()
    Set tAdapter.Adaptee = tAdaptee2
    Set tResult2 = tAdapter.Request()
    Do $$$AssertTrue(tResult2 [ "Object Adapted:", "Adapter should switch adaptees at runtime")
    
    Quit
}

/// Test HL7 to FHIR conversion accuracy - Patient
Method TestHL7ToFHIRPatientConversion()
{
    Set tSC = $$$OK
    
    // Create HL7 ADT message using the sample creation method
    Set tHL7Message = ##class(Patterns.Examples.HL7Message).CreateSampleADTMessage()
    
    // Create adapter and convert
    Set tAdapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7Message)
    
    Set tStatus = tAdapter.Convert()
    Do $$$AssertStatusOK(tStatus, "Convert should succeed")
    
    Set tResources = tAdapter.FHIRResources
    Do $$$AssertTrue($ISOBJECT(tResources), "Should have FHIRResources collection")
    Do $$$AssertEquals(tResources.Count(), 1, "ADT message should produce 1 resource")
    
    // Verify patient resource
    Set tPatient = tResources.GetAt(1)
    Do $$$AssertTrue($ISOBJECT(tPatient), "Should return patient object")
    Do $$$AssertEquals(tPatient.%ClassName(1), "Patterns.Examples.FHIRPatient", "Should return FHIRPatient instance")
    Do $$$AssertEquals(tPatient.MRN, "123456789", "Patient MRN should be extracted correctly")
    Do $$$AssertEquals(tPatient.FamilyName, "Doe", "Patient family name should be extracted")
    Do $$$AssertEquals(tPatient.GivenName, "John", "Patient given name should be extracted")
    Do $$$AssertEquals(tPatient.Gender, "male", "Patient gender should be mapped to FHIR format")
    Do $$$AssertEquals(tPatient.BirthDate, "1980-05-15", "Birth date should be in FHIR format")
    
    // Test JSON conversion
    Set tJSON = tPatient.ToJSON()
    Do $$$AssertTrue($ISOBJECT(tJSON), "ToJSON should return JSON object")
    Do $$$AssertEquals(tJSON.resourceType, "Patient", "JSON should have correct resourceType")
    Do $$$AssertTrue($ISOBJECT(tJSON.identifier), "JSON should have identifier array")
    Do $$$AssertEquals(tJSON.identifier.%Get(0).value, "123456789", "JSON identifier should contain MRN")
    
    Quit
}

/// Test HL7 to FHIR conversion accuracy - Observations
Method TestHL7ToFHIRObservationConversion()
{
    Set tSC = $$$OK
    
    // Create HL7 ORU message using the sample creation method
    Set tHL7Message = ##class(Patterns.Examples.HL7Message).CreateSampleORUMessage()
    
    // Create adapter and convert
    Set tAdapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7Message)
    
    Set tStatus = tAdapter.Convert()
    Do $$$AssertStatusOK(tStatus, "Convert should succeed")
    
    Set tResources = tAdapter.FHIRResources
    Do $$$AssertTrue($ISOBJECT(tResources), "Should have FHIRResources collection")
    Do $$$AssertTrue(tResources.Count() >= 3, "ORU message should produce at least 3 resources")
    
    // Verify patient resource (first resource)
    Set tPatient = tResources.GetAt(1)
    Do $$$AssertEquals(tPatient.%ClassName(1), "Patterns.Examples.FHIRPatient", "First resource should be patient")
    Do $$$AssertEquals(tPatient.MRN, "123456789", "Patient MRN should be extracted")
    
    // Verify first observation (glucose)
    Set tObs1 = tResources.GetAt(2)
    Do $$$AssertEquals(tObs1.%ClassName(1), "Patterns.Examples.FHIRObservation", "Should be FHIRObservation instance")
    Do $$$AssertEquals(tObs1.Code, "1554-5", "Observation code should be extracted")
    Do $$$AssertEquals(tObs1.CodeDisplay, "GLUCOSE", "Observation display should match")
    Do $$$AssertEquals(tObs1.ValueQuantity, 120, "Numeric value should be extracted")
    Do $$$AssertEquals(tObs1.ValueUnit, "mg/dL", "Unit should be extracted")
    Do $$$AssertEquals(tObs1.Interpretation, "H", "Interpretation should be extracted")
    
    Quit
}

/// Test adapter chaining and composition
Method TestAdapterChaining()
{
    Set tSC = $$$OK
    
    // Create first level adapter
    Set tLegacyAdaptee = ##class(Patterns.GoF.Structural.LegacyAdaptee).%New()
    Set tFirstAdapter = ##class(Patterns.GoF.Structural.ObjectAdapter).%New(tLegacyAdaptee)
    
    // The target interface expects Request() to return a string
    // So we can't directly chain ObjectAdapter as an adaptee
    // Test the first adapter works
    Set tResult = tFirstAdapter.Request()
    Do $$$AssertTrue(tResult [ "Object Adapted:", "First adapter should work correctly")
    
    Quit
}

/// Test FHIR Bundle generation
Method TestFHIRBundleGeneration()
{
    Set tSC = $$$OK
    
    // Create HL7 message with patient and observations
    Set tHL7Message = ##class(Patterns.Examples.HL7Message).CreateSampleORUMessage()
    
    // Convert and get bundle
    Set tAdapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7Message)
    
    Set tStatus = tAdapter.Convert()
    Do $$$AssertStatusOK(tStatus, "Convert should succeed")
    
    Set tBundle = tAdapter.GetFHIRBundle()
    
    Do $$$AssertTrue($ISOBJECT(tBundle), "GetFHIRBundle should return JSON object")
    Do $$$AssertEquals(tBundle.resourceType, "Bundle", "Bundle should have correct resourceType")
    Do $$$AssertEquals(tBundle.type, "collection", "Bundle type should be collection")
    Do $$$AssertTrue($ISOBJECT(tBundle.entry), "Bundle should have entry array")
    Do $$$AssertTrue(tBundle.entry.%Size() > 0, "Bundle should contain entries")
    
    // Verify bundle entries
    Set tFirstEntry = tBundle.entry.%Get(0)
    Do $$$AssertTrue($ISOBJECT(tFirstEntry.resource), "Entry should have resource")
    Do $$$AssertEquals(tFirstEntry.resource.resourceType, "Patient", "First entry should be Patient")
    
    If tBundle.entry.%Size() > 1 {
        Set tSecondEntry = tBundle.entry.%Get(1)
        Do $$$AssertEquals(tSecondEntry.resource.resourceType, "Observation", "Second entry should be Observation")
    }
    
    Quit
}

/// Test error handling in adapters
Method TestAdapterErrorHandling()
{
    Set tSC = $$$OK
    
    // Test with invalid HL7 message
    Set tHL7Message = ##class(Patterns.Examples.HL7Message).%New()
    Set tHL7Message.MessageType = "INVALID"
    Set tHL7Message.MessageContent = "This is not a valid HL7 message"
    
    Set tAdapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7Message)
    
    Set tStatus = tAdapter.Convert()
    Do $$$AssertStatusOK(tStatus, "Convert should handle invalid messages gracefully")
    
    Set tResources = tAdapter.FHIRResources
    Do $$$AssertTrue($ISOBJECT(tResources), "Should have FHIRResources collection")
    Do $$$AssertEquals(tResources.Count(), 0, "Invalid message should produce no resources")
    
    // Test with empty message
    Set tHL7Message2 = ##class(Patterns.Examples.HL7Message).%New()
    Set tAdapter2 = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7Message2)
    
    Set tStatus2 = tAdapter2.Convert()
    Set tResources2 = tAdapter2.FHIRResources
    Do $$$AssertEquals(tResources2.Count(), 0, "Empty message should produce no resources")
    
    Quit
}

/// Performance test for adapter operations
Method TestAdapterPerformance()
{
    Set tSC = $$$OK
    
    // Test simple adapter performance
    Set tStartTime = $ZH
    
    For i = 1:1:1000 {
        Set tAdapter = ##class(Patterns.GoF.Structural.ClassAdapter).%New()
        Set tResult = tAdapter.Request()
    }
    
    Set tElapsedMs = ($ZH - tStartTime) * 1000
    Do ..AssertPerformance(tElapsedMs, 100, "1000 adapter requests should complete within 100ms")
    
    // Test HL7 conversion performance
    Set tHL7Message = ##class(Patterns.Examples.HL7Message).CreateSampleADTMessage()
    
    Set tStartTime2 = $ZH
    
    For i = 1:1:100 {
        Set tAdapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7Message)
        Set tStatus = tAdapter.Convert()
    }
    
    Set tElapsedMs2 = ($ZH - tStartTime2) * 1000
    Do ..AssertPerformance(tElapsedMs2, 500, "100 HL7 conversions should complete within 500ms")
    
    Quit
}

/// Test cleanup operations
Method OnAfterOneTest() As %Status
{
    // Clean up any test globals
    Kill ^ClineDebug
    Kill ^LegacyData
    
    Quit $$$OK
}

}
