/// Unit tests for the Prototype Pattern implementation
/// Tests both shallow and deep cloning mechanisms, registry patterns,
/// and healthcare-specific implementations
Class Patterns.Test.Unit.GoF.Creational.PrototypeTest Extends %UnitTest.TestCase
{

/// Constructor to handle initvalue parameter from parent class
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter - REQUIRED
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    Quit $$$OK
}

/// Test basic shallow cloning functionality
Method TestShallowClone()
{
    // Create and configure original prototype
    Set original = ##class(Patterns.GoF.Creational.ConcretePrototype1).%New()
    Set original.SimpleProperty = "Original"
    Set original.IntegerValue = 42
    
    // Create shallow clone
    Set clone = original.Clone()
    
    // Verify clone is a different instance
    Do $$$AssertTrue($IsObject(clone), "Clone should be valid object")
    Do $$$AssertTrue(clone '= original, "Clone should be different instance")
    
    // Verify properties are copied
    Do $$$AssertEquals(clone.SimpleProperty, "Original", "SimpleProperty should be copied")
    Do $$$AssertEquals(clone.IntegerValue, 42, "IntegerValue should be copied")
    
    // Modify clone and verify original unchanged
    Set clone.SimpleProperty = "Modified Clone"
    Set clone.IntegerValue = 100
    Do $$$AssertEquals(original.SimpleProperty, "Original", "Original SimpleProperty should be unchanged")
    Do $$$AssertEquals(original.IntegerValue, 42, "Original IntegerValue should be unchanged")
    
    Quit
}

/// Test deep cloning with complex nested objects
Method TestDeepClone()
{
    // Create prototype with nested object
    Set prototype2 = ##class(Patterns.GoF.Creational.ConcretePrototype2).%New()
    
    // Add items to list property
    Do prototype2.ListProperty.Insert("Item1")
    Do prototype2.ListProperty.Insert("Item2")
    Do prototype2.ListProperty.Insert("Item3")
    
    // Add metadata
    Do prototype2.Metadata.SetAt("Value1", "Key1")
    Do prototype2.Metadata.SetAt("Value2", "Key2")
    
    // Create nested prototype1 object
    Set nestedObj = ##class(Patterns.GoF.Creational.ConcretePrototype1).%New()
    Set nestedObj.SimpleProperty = "Nested Data"
    Set nestedObj.IntegerValue = 999
    Set prototype2.NestedObject = nestedObj
    
    // Perform deep clone
    Set deepClone = prototype2.DeepClone()
    
    // Verify clone is valid and different
    Do $$$AssertTrue($IsObject(deepClone), "Deep clone should be valid object")
    Do $$$AssertTrue(deepClone '= prototype2, "Deep clone should be different instance")
    
    // Verify list is independently copied
    Do $$$AssertEquals(deepClone.ListProperty.Count(), 3, "List should have same count")
    Do $$$AssertEquals(deepClone.ListProperty.GetAt(1), "Item1", "First item should match")
    
    // Modify clone's list and verify original unchanged
    Do deepClone.ListProperty.Insert("Item4")
    Do $$$AssertEquals(prototype2.ListProperty.Count(), 3, "Original list should be unchanged")
    Do $$$AssertEquals(deepClone.ListProperty.Count(), 4, "Clone list should be modified")
    
    // Verify nested object is independently cloned
    Do $$$AssertTrue($IsObject(deepClone.NestedObject), "Nested object should be cloned")
    Do $$$AssertTrue(deepClone.NestedObject '= prototype2.NestedObject, "Nested object should be different instance")
    Do $$$AssertEquals(deepClone.NestedObject.SimpleProperty, "Nested Data", "Nested object content should match")
    
    // Modify nested object in clone
    Set deepClone.NestedObject.SimpleProperty = "Modified Nested Data"
    Do $$$AssertEquals(prototype2.NestedObject.SimpleProperty, "Nested Data", "Original nested object should be unchanged")
    
    Quit
}

/// Test the Prototype Registry functionality
Method TestPrototypeRegistry()
{
    // Create registry
    Set registry = ##class(Patterns.GoF.Creational.PrototypeRegistry).%New()
    
    // Create prototypes to register
    Set proto1 = ##class(Patterns.GoF.Creational.ConcretePrototype1).%New()
    Set proto1.SimpleProperty = "Template1"
    Set proto1.IntegerValue = 100
    
    Set proto2 = ##class(Patterns.GoF.Creational.ConcretePrototype2).%New()
    Do proto2.ListProperty.Insert("Default1")
    Do proto2.ListProperty.Insert("Default2")
    
    // Register prototypes
    Set tSC = registry.Register("Type1", proto1)
    Do $$$AssertStatusOK(tSC, "Should register Type1 prototype")
    
    Set tSC = registry.Register("Type2", proto2)
    Do $$$AssertStatusOK(tSC, "Should register Type2 prototype")
    
    // Create instances from registry
    Set instance1 = registry.Create("Type1")
    Do $$$AssertTrue($IsObject(instance1), "Should create instance from Type1")
    Do $$$AssertTrue(instance1 '= proto1, "Instance should be clone, not original")
    Do $$$AssertEquals(instance1.SimpleProperty, "Template1", "Instance should have template values")
    
    Set instance2 = registry.Create("Type2")
    Do $$$AssertTrue($IsObject(instance2), "Should create instance from Type2")
    Do $$$AssertEquals(instance2.ListProperty.Count(), 2, "Instance should have template items")
    
    // Test creating multiple instances
    Set instance1b = registry.Create("Type1")
    Do $$$AssertTrue(instance1b '= instance1, "Each create should return new clone")
    
    // Test unregistering
    Set tSC = registry.Unregister("Type1")
    Do $$$AssertStatusOK(tSC, "Should unregister Type1")
    
    Set instanceNull = registry.Create("Type1")
    Do $$$AssertTrue('$IsObject(instanceNull), "Should return null for unregistered type")
    
    // Test non-existent key
    Set instanceNull = registry.Create("NonExistent")
    Do $$$AssertTrue('$IsObject(instanceNull), "Should return null for non-existent key")
    
    Quit
}

/// Test healthcare patient record template cloning
Method TestPatientRecordTemplateCloning()
{
    // Create standard patient record template
    Set standardTemplate = ##class(Patterns.Examples.StandardPatientRecord).%New()
    
    // Verify template has expected defaults
    Do $$$AssertEquals(standardTemplate.AdmissionType, "Scheduled", "Should have scheduled admission type")
    Do $$$AssertTrue(standardTemplate.RequiredTests.Count() > 0, "Should have required tests")
    Do $$$AssertTrue(standardTemplate.DefaultMedications.Count() > 0, "Should have default medications")
    
    // Use CustomizeForPatient method
    Set patientRecord = standardTemplate.CustomizeForPatient("P123456", "Dr. Smith", "BlueCross")
    Do $$$AssertTrue($IsObject(patientRecord), "Should create patient record from template")
    Do $$$AssertTrue(patientRecord '= standardTemplate, "Should be new instance")
    
    // Verify customizations
    Do $$$AssertEquals(patientRecord.PatientID, "P123456", "Should have patient ID")
    Do $$$AssertEquals(patientRecord.AttendingPhysician, "Dr. Smith", "Should have physician")
    Do $$$AssertEquals(patientRecord.InsuranceProvider, "BlueCross", "Should have insurance")
    
    // Verify template is unchanged
    Do $$$AssertEquals(standardTemplate.PatientID, "", "Template PatientID should remain empty")
    Do $$$AssertEquals(standardTemplate.AttendingPhysician, "", "Template physician should remain empty")
    
    Quit
}

/// Test emergency patient record cloning with triage
Method TestEmergencyPatientRecordCloning()
{
    // Create emergency template
    Set emergencyTemplate = ##class(Patterns.Examples.EmergencyPatientRecord).%New()
    
    // Verify emergency-specific properties
    Do $$$AssertEquals(emergencyTemplate.AdmissionType, "Emergency", "Should be emergency admission")
    Do $$$AssertTrue(emergencyTemplate.RequiredTests.Count() > 0, "Should have emergency tests")
    
    // Use CustomizeForEmergency method
    Set emergencyPatient = emergencyTemplate.CustomizeForEmergency("E789012", "Red", "Chest pain")
    Do $$$AssertTrue($IsObject(emergencyPatient), "Should create emergency record")
    
    // Verify customizations
    Do $$$AssertEquals(emergencyPatient.TriageCategory, "Red", "Should have triage category")
    Do $$$AssertEquals(emergencyPatient.ChiefComplaint, "Chest pain", "Should have chief complaint")
    
    // Verify template unchanged
    Do $$$AssertEquals(emergencyTemplate.TriageCategory, "Yellow", "Template triage should be default")
    Do $$$AssertEquals(emergencyTemplate.ChiefComplaint, "", "Template complaint should be empty")
    
    Quit
}

/// Test pediatric patient record with special considerations
Method TestPediatricPatientRecordCloning()
{
    // Create pediatric template
    Set pediatricTemplate = ##class(Patterns.Examples.PediatricPatientRecord).%New()
    
    // Verify pediatric-specific setup
    Do $$$AssertEquals(pediatricTemplate.AdmissionType, "Pediatric", "Should be pediatric admission")
    Do $$$AssertTrue(pediatricTemplate.DefaultMedications.Count() > 0, "Should have weight-based medications")
    
    // Use CustomizeForChild method
    Set pediatricPatient = pediatricTemplate.CustomizeForChild("P456789", 8, 25, "Jane Doe")
    Do $$$AssertTrue($IsObject(pediatricPatient), "Should create pediatric record")
    
    // Verify customizations
    Do $$$AssertEquals(pediatricPatient.AgeInYears, 8, "Should have age in years")
    Do $$$AssertEquals(pediatricPatient.WeightKg, 25, "Should have weight")
    Do $$$AssertEquals(pediatricPatient.GuardianName, "Jane Doe", "Should have guardian")
    
    // Verify medication dosages calculated
    Do $$$AssertTrue(pediatricPatient.DefaultMedications.Count() > 0, "Should have calculated medications")
    
    Quit
}

/// Test CopyFrom method functionality
Method TestCopyFromMethod()
{
    // Create source prototype
    Set source = ##class(Patterns.GoF.Creational.ConcretePrototype1).%New()
    Set source.SimpleProperty = "Source"
    Set source.IntegerValue = 999
    
    // Create target and copy from source
    Set target = ##class(Patterns.GoF.Creational.ConcretePrototype1).%New()
    Set tSC = target.CopyFrom(source)
    Do $$$AssertStatusOK(tSC, "CopyFrom should succeed")
    
    // Verify properties copied
    Do $$$AssertEquals(target.SimpleProperty, "Source", "SimpleProperty should be copied")
    Do $$$AssertEquals(target.IntegerValue, 999, "IntegerValue should be copied")
    
    // Verify objects are different
    Do $$$AssertTrue(target '= source, "Should be different objects")
    
    Quit
}

/// Test handling of null/invalid prototypes
Method TestErrorHandling()
{
    // Test registry with null prototype
    Set registry = ##class(Patterns.GoF.Creational.PrototypeRegistry).%New()
    Set tSC = registry.Register("NullTest", "")
    Do $$$AssertStatusNotOK(tSC, "Should fail to register null prototype")
    
    // Test creating from non-existent key
    Set instance = registry.Create("DoesNotExist")
    Do $$$AssertTrue('$IsObject(instance), "Should return null for missing key")
    
    // Test CopyFrom with null source
    Set target = ##class(Patterns.GoF.Creational.ConcretePrototype1).%New()
    Set tSC = target.CopyFrom("")
    Do $$$AssertStatusNotOK(tSC, "CopyFrom should fail with null source")
    
    Quit
}

/// Test performance comparison between shallow and deep cloning
Method TestCloningPerformance()
{
    // Create complex prototype with lots of data
    Set complexProto = ##class(Patterns.GoF.Creational.ConcretePrototype2).%New()
    
    // Add many items
    For i = 1:1:100 {
        Do complexProto.ListProperty.Insert("Item-"_i)
    }
    
    // Add metadata
    For i = 1:1:50 {
        Do complexProto.Metadata.SetAt("Value-"_i, "Key-"_i)
    }
    
    // Add nested object
    Set nestedObj = ##class(Patterns.GoF.Creational.ConcretePrototype1).%New()
    Set nestedObj.SimpleProperty = "Performance Test Data"
    Set nestedObj.IntegerValue = 999
    Set complexProto.NestedObject = nestedObj
    
    // Time shallow clone
    Set startShallow = $ZH
    For i = 1:1:10 {
        Set shallowClone = complexProto.Clone()
    }
    Set timeShallow = $ZH - startShallow
    
    // Time deep clone
    Set startDeep = $ZH
    For i = 1:1:10 {
        Set deepClone = complexProto.DeepClone()
    }
    Set timeDeep = $ZH - startDeep
    
    // Just verify both methods work - actual performance will vary
    Do $$$AssertTrue($IsObject(shallowClone), "Shallow clone should work")
    Do $$$AssertTrue($IsObject(deepClone), "Deep clone should work")
    
    // Note: In practice, shallow clone should be faster than deep clone
    // but we don't assert timing as it can vary by system
    
    Quit
}

/// Test registry with healthcare templates
Method TestHealthcareTemplateRegistry()
{
    // Create registry for patient templates
    Set templateRegistry = ##class(Patterns.GoF.Creational.PrototypeRegistry).%New()
    
    // Register different template types
    Set standardTemplate = ##class(Patterns.Examples.StandardPatientRecord).%New()
    Set emergencyTemplate = ##class(Patterns.Examples.EmergencyPatientRecord).%New()
    Set pediatricTemplate = ##class(Patterns.Examples.PediatricPatientRecord).%New()
    
    Set tSC = templateRegistry.Register("STANDARD", standardTemplate)
    Do $$$AssertStatusOK(tSC, "Should register standard template")
    
    Set tSC = templateRegistry.Register("EMERGENCY", emergencyTemplate)
    Do $$$AssertStatusOK(tSC, "Should register emergency template")
    
    Set tSC = templateRegistry.Register("PEDIATRIC", pediatricTemplate)
    Do $$$AssertStatusOK(tSC, "Should register pediatric template")
    
    // Create patients from templates
    Set patient1 = templateRegistry.Create("STANDARD")
    Do $$$AssertTrue($IsObject(patient1), "Should create standard patient")
    Do $$$AssertEquals(patient1.AdmissionType, "Scheduled", "Should be scheduled admission")
    
    Set patient2 = templateRegistry.Create("EMERGENCY")
    Do $$$AssertTrue($IsObject(patient2), "Should create emergency patient")
    Do $$$AssertEquals(patient2.AdmissionType, "Emergency", "Should be emergency admission")
    
    Set patient3 = templateRegistry.Create("PEDIATRIC")
    Do $$$AssertTrue($IsObject(patient3), "Should create pediatric patient")
    Do $$$AssertEquals(patient3.AdmissionType, "Pediatric", "Should be pediatric admission")
    
    // Verify each is unique instance
    Set patient1b = templateRegistry.Create("STANDARD")
    Do $$$AssertTrue(patient1b '= patient1, "Each create should return new instance")
    
    Quit
}

}
