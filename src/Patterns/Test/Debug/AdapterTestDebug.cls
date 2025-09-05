/// Debug helper for Adapter pattern test failures
Class Patterns.Test.Debug.AdapterTestDebug
{

/// Debug test failures
ClassMethod DebugTestFailures() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ""
    
    Write !, "=== Debugging Adapter Test Failures ==="
    
    // Test 1: Check ObjectAdapter behavior
    Write !, "1. Testing ObjectAdapter with LegacyAdaptee..."
    Set ^ClineDebug = ^ClineDebug _ "Test 1: ObjectAdapter with LegacyAdaptee; "
    
    Set tLegacyAdaptee = ##class(Patterns.GoF.Structural.LegacyAdaptee).%New()
    Set tAdapter = ##class(Patterns.GoF.Structural.ObjectAdapter).%New(tLegacyAdaptee)
    Set tResult = tAdapter.Request()
    Write !, "   Result: ", tResult
    Set ^ClineDebug = ^ClineDebug _ "Result: " _ tResult _ "; "
    
    // Test 2: Check null adaptee handling
    Write !, "2. Testing null adaptee handling..."
    Set ^ClineDebug = ^ClineDebug _ "Test 2: Null adaptee; "
    
    Set tAdapter2 = ##class(Patterns.GoF.Structural.ObjectAdapter).%New()
    Set tResult2 = tAdapter2.Request()
    Write !, "   Result: ", tResult2
    Set ^ClineDebug = ^ClineDebug _ "Result: " _ tResult2 _ "; "
    
    // Test 3: Check MRN extraction from HL7
    Write !, "3. Testing MRN extraction from HL7 ADT message..."
    Set ^ClineDebug = ^ClineDebug _ "Test 3: HL7 ADT MRN extraction; "
    
    Set tHL7Message = ##class(Patterns.Examples.HL7Message).CreateSampleADTMessage()
    Set tAdapter3 = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7Message)
    Set tStatus = tAdapter3.Convert()
    
    If $$$ISOK(tStatus) {
        Set tResources = tAdapter3.FHIRResources
        If $ISOBJECT(tResources) && (tResources.Count() > 0) {
            Set tPatient = tResources.GetAt(1)
            If $ISOBJECT(tPatient) {
                Write !, "   Patient MRN: ", tPatient.MRN
                Set ^ClineDebug = ^ClineDebug _ "Patient MRN: " _ tPatient.MRN _ "; "
                
                // Check JSON representation
                Set tJSON = tPatient.ToJSON()
                If $ISOBJECT(tJSON) && $ISOBJECT(tJSON.identifier) {
                    Write !, "   JSON MRN: ", tJSON.identifier.%Get(0).value
                    Set ^ClineDebug = ^ClineDebug _ "JSON MRN: " _ tJSON.identifier.%Get(0).value _ "; "
                }
            }
        }
    }
    
    // Test 4: Check MRN extraction from HL7 ORU message
    Write !, "4. Testing MRN extraction from HL7 ORU message..."
    Set ^ClineDebug = ^ClineDebug _ "Test 4: HL7 ORU MRN extraction; "
    
    Set tHL7Message2 = ##class(Patterns.Examples.HL7Message).CreateSampleORUMessage()
    Set tAdapter4 = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(tHL7Message2)
    Set tStatus2 = tAdapter4.Convert()
    
    If $$$ISOK(tStatus2) {
        Set tResources2 = tAdapter4.FHIRResources
        If $ISOBJECT(tResources2) && (tResources2.Count() > 0) {
            Set tPatient2 = tResources2.GetAt(1)
            If $ISOBJECT(tPatient2) {
                Write !, "   Patient MRN: ", tPatient2.MRN
                Set ^ClineDebug = ^ClineDebug _ "ORU Patient MRN: " _ tPatient2.MRN _ "; "
            }
        }
    }
    
    Write !, "=== Debug Complete ==="
    Write !, "Debug info stored in ^ClineDebug"
    
    Quit tSC
}

/// Check actual HL7 message content
ClassMethod CheckHL7Content() As %Status
{
    Set tSC = $$$OK
    
    Write !, "=== Checking HL7 Message Content ==="
    
    // Check ADT message
    Set tADT = ##class(Patterns.Examples.HL7Message).CreateSampleADTMessage()
    Write !, "ADT Message Content:"
    Write !, tADT.MessageContent, !
    
    // Check ORU message  
    Set tORU = ##class(Patterns.Examples.HL7Message).CreateSampleORUMessage()
    Write !, "ORU Message Content:"
    Write !, tORU.MessageContent, !
    
    Quit tSC
}

}
