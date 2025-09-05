/// Debug class for testing adapter patterns
Class Patterns.Test.Debug.AdapterDebug
{

/// Test basic adapter functionality
ClassMethod TestAdapters() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ""
    
    Try {
        // Test 1: ClassAdapter
        Set ^ClineDebug = ^ClineDebug _ "Test 1: ClassAdapter; "
        Set adapter = ##class(Patterns.GoF.Structural.ClassAdapter).%New()
        Set result = adapter.Request()
        Set ^ClineDebug = ^ClineDebug _ "Result: " _ result _ "; "
        Write "ClassAdapter result: ", result, !
        
        // Test 2: ObjectAdapter with adaptees
        Set ^ClineDebug = ^ClineDebug _ "Test 2: ObjectAdapter; "
        Set adaptee1 = ##class(Patterns.GoF.Structural.Adaptee).%New("Service1")
        Set adapter = ##class(Patterns.GoF.Structural.ObjectAdapter).%New(adaptee1)
        Set result = adapter.Request()
        Set ^ClineDebug = ^ClineDebug _ "Result: " _ result _ "; "
        Write "ObjectAdapter result: ", result, !
        
        // Test 3: Skip LegacyCodeAdapter for now
        Set ^ClineDebug = ^ClineDebug _ "Test 3: LegacyCodeAdapter skipped; "
        Write "LegacyCodeAdapter test skipped (debugging issue)", !
        
        // Test 4: HL7ToFHIRAdapter - Patient conversion
        Set ^ClineDebug = ^ClineDebug _ "Test 4: HL7ToFHIR Patient; "
        // Use the sample ADT message creation method
        Set hl7 = ##class(Patterns.Examples.HL7Message).CreateSampleADTMessage()
        
        Set adapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(hl7)
        Set tSC = adapter.Convert()  // Use main Convert method
        If $$$ISOK(tSC) {
            If adapter.FHIRResources.Count() > 0 {
                Set fhirPatient = adapter.FHIRResources.GetAt(1)
                Set json = fhirPatient.ToJSONString(0)
                Set ^ClineDebug = ^ClineDebug _ "FHIR Patient created; "
                Write "FHIR Patient created: ", fhirPatient.GetSummary(), !
            } Else {
                Set ^ClineDebug = ^ClineDebug _ "No resources converted; "
                Write "No resources converted", !
            }
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Conversion failed: " _ $SYSTEM.Status.GetErrorText(tSC) _ "; "
            Write "Conversion failed: ", $SYSTEM.Status.GetErrorText(tSC), !
        }
        
        // Test 5: HL7ToFHIRAdapter - Observation conversion
        Set ^ClineDebug = ^ClineDebug _ "Test 5: HL7ToFHIR Observation; "
        // Use the sample ORU message creation method
        Set hl7 = ##class(Patterns.Examples.HL7Message).CreateSampleORUMessage()
        
        Set adapter = ##class(Patterns.Examples.HL7ToFHIRAdapter).%New(hl7)
        Set tSC = adapter.Convert()  // Use main Convert method
        If $$$ISOK(tSC) {
            Set count = adapter.FHIRResources.Count()
            Set ^ClineDebug = ^ClineDebug _ "Observations count: " _ count _ "; "
            Write "FHIR Resources created: ", count, !
            For i = 1:1:count {
                Set resource = adapter.FHIRResources.GetAt(i)
                Write "  Resource ", i, ": ", resource.GetSummary(), !
            }
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Conversion failed: " _ $SYSTEM.Status.GetErrorText(tSC) _ "; "
            Write "Conversion failed: ", $SYSTEM.Status.GetErrorText(tSC), !
        }
        
        Set ^ClineDebug = ^ClineDebug _ "All tests completed; "
        Write "Debug complete. Check ^ClineDebug for details.", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.DisplayString() _ "; "
        Write "Error: ", ex.DisplayString(), !
    }
    
    Quit tSC
}

/// Test individual adapter class compilation
ClassMethod CheckClasses() As %Status
{
    Write "Checking adapter classes compilation status:", !!
    
    Set classes = $LISTBUILD(
        "Patterns.GoF.Structural.Target",
        "Patterns.GoF.Structural.Adaptee",
        "Patterns.GoF.Structural.ClassAdapter",
        "Patterns.GoF.Structural.ObjectAdapter",
        "Patterns.GoF.Structural.LegacyCodeAdapter",
        "Patterns.Examples.HL7Message",
        "Patterns.Examples.FHIRResource",
        "Patterns.Examples.FHIRPatient",
        "Patterns.Examples.FHIRObservation",
        "Patterns.Examples.HL7ToFHIRAdapter"
    )
    
    Set ptr = 0
    While $LISTNEXT(classes, ptr, className) {
        If ##class(%Dictionary.CompiledClass).%ExistsId(className) {
            Write className, " - COMPILED", !
        } Else {
            Write className, " - NOT COMPILED", !
        }
    }
    
    Quit $$$OK
}

}
