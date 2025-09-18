/// <test>
/// Unit tests for the Builder Pattern implementation
/// Tests builder interface, director, fluent interface, and healthcare examples
/// </test>
Class Patterns.Test.Unit.GoF.Creational.BuilderTest Extends Patterns.Test.TestCase
{

/// Test basic builder functionality with Product1
Method TestConcreteBuilder1BasicConstruction() As %Status
{
    Set tBuilder = ##class(Patterns.GoF.Creational.ConcreteBuilder1).%New()
    Do $$$AssertTrue($ISOBJECT(tBuilder), "ConcreteBuilder1 created successfully")
    
    // Build a product with basic parts
    Do tBuilder.Reset()
    Do tBuilder.BuildPartA()
    Do tBuilder.BuildPartB()
    
    Set tProduct = tBuilder.GetResult()
    Do $$$AssertTrue($ISOBJECT(tProduct), "Product1 created successfully")
    Do $$$AssertEquals(tProduct.%ClassName(1), "Patterns.GoF.Creational.Product1", "Correct product type")
    Do $$$AssertEquals(tProduct.PartA, "Part A from ConcreteBuilder1", "PartA built correctly")
    Do $$$AssertEquals(tProduct.PartB, "Part B from ConcreteBuilder1", "PartB built correctly")
    
    Quit $$$OK
}

/// Test fluent interface with ConcreteBuilder1
Method TestFluentInterface() As %Status
{
    Set tBuilder = ##class(Patterns.GoF.Creational.ConcreteBuilder1).%New()
    
    // Test fluent chaining
    Do tBuilder.Reset()
    Do tBuilder.BuildPartA()
    Do tBuilder.BuildPartB()
    Do tBuilder.BuildPartC()
    Do tBuilder.SetProperty("Name", "Fluent Product")
    Do tBuilder.SetProperty("Version", "2.0")
    
    Set tProduct = tBuilder.GetResult()
    Do $$$AssertTrue($ISOBJECT(tProduct), "Product created with fluent interface")
    Do $$$AssertEquals(tProduct.Name, "Fluent Product", "Name set via fluent interface")
    Do $$$AssertEquals(tProduct.Version, "2.0", "Version set via fluent interface")
    Do $$$AssertTrue(tProduct.IsComplete(), "Product is complete")
    
    Quit $$$OK
}

/// Test ConcreteBuilder2 with Product2
Method TestConcreteBuilder2Construction() As %Status
{
    Set tBuilder = ##class(Patterns.GoF.Creational.ConcreteBuilder2).%New()
    Do $$$AssertTrue($ISOBJECT(tBuilder), "ConcreteBuilder2 created successfully")
    
    // Build a Product2
    Do tBuilder.Reset()
    Do tBuilder.BuildPartA()
    Do tBuilder.BuildPartB()
    Do tBuilder.SetProductId("PROD-002")
    Do tBuilder.SetCategory("Test Category")
    
    Set tProduct = tBuilder.GetResult()
    Do $$$AssertTrue($ISOBJECT(tProduct), "Product2 created successfully")
    Do $$$AssertEquals(tProduct.%ClassName(1), "Patterns.GoF.Creational.Product2", "Correct product type")
    Do $$$AssertEquals(tProduct.ProductId, "PROD-002", "ProductId set correctly")
    Do $$$AssertEquals(tProduct.Category, "Test Category", "Category set correctly")
    Do $$$AssertTrue(tProduct.HasComponent("Component A from ConcreteBuilder2"), "Has Component A")
    Do $$$AssertTrue(tProduct.HasComponent("Component B from ConcreteBuilder2"), "Has Component B")
    
    Quit $$$OK
}

/// Test Director with different builders
Method TestDirectorWithBuilders() As %Status
{
    Set tDirector = ##class(Patterns.GoF.Creational.Director).%New()
    Do $$$AssertTrue($ISOBJECT(tDirector), "Director created successfully")
    
    // Test with ConcreteBuilder1
    Set tBuilder1 = ##class(Patterns.GoF.Creational.ConcreteBuilder1).%New()
    Set tProduct1 = tDirector.Construct(tBuilder1, "minimal")
    Do $$$AssertTrue($ISOBJECT(tProduct1), "Minimal product created via Director")
    Do $$$AssertEquals(tProduct1.PartA, "Part A from ConcreteBuilder1", "Minimal build has PartA")
    
    // Test with ConcreteBuilder2
    Set tBuilder2 = ##class(Patterns.GoF.Creational.ConcreteBuilder2).%New()
    Set tProduct2 = tDirector.Construct(tBuilder2, "full")
    Do $$$AssertTrue($ISOBJECT(tProduct2), "Full product created via Director")
    Do $$$AssertTrue(tProduct2.HasComponent("Component A from ConcreteBuilder2"), "Full build has Component A")
    Do $$$AssertTrue(tProduct2.HasComponent("Component B from ConcreteBuilder2"), "Full build has Component B")
    Do $$$AssertTrue(tProduct2.HasComponent("Component C from ConcreteBuilder2"), "Full build has Component C")
    
    Quit $$$OK
}

/// Test builder reset and reuse
Method TestBuilderResetAndReuse() As %Status
{
    Set tBuilder = ##class(Patterns.GoF.Creational.ConcreteBuilder1).%New()
    
    // Build first product
    Do tBuilder.Reset()
    Do tBuilder.BuildPartA()
    Do tBuilder.SetProperty("Name", "Product 1")
    Set tProduct1 = tBuilder.GetResult()
    Do $$$AssertEquals(tProduct1.Name, "Product 1", "First product name correct")
    
    // Builder should be reset after GetResult
    Do tBuilder.BuildPartB()
    Do tBuilder.SetProperty("Name", "Product 2")
    Set tProduct2 = tBuilder.GetResult()
    Do $$$AssertEquals(tProduct2.Name, "Product 2", "Second product name correct")
    Do $$$AssertEquals(tProduct2.PartA, "", "Second product PartA empty (builder was reset)")
    
    Quit $$$OK
}

/// Test healthcare LabReportBuilder
Method TestLabReportBuilder() As %Status
{
    Set tBuilder = ##class(Patterns.Examples.LabReportBuilder).%New()
    Do $$$AssertTrue($ISOBJECT(tBuilder), "LabReportBuilder created successfully")
    
    // Build a CBC report
    Set tReport = tBuilder.BuildCBCReport("LAB-001", "PT-123", "John Doe", 
                                          7.5, 5.2, 14.5, 43, 250)
    Do $$$AssertTrue($ISOBJECT(tReport), "CBC Report created successfully")
    Do $$$AssertEquals(tReport.ReportType, "Laboratory Report", "Correct report type")
    Do $$$AssertEquals(tReport.ReportId, "LAB-001", "Report ID set correctly")
    Do $$$AssertTrue(tReport.PatientInfo [ "John Doe", "Patient name in report")
    Do $$$AssertTrue(tReport.Findings [ "WBC: 7.5", "WBC value in findings")
    Do $$$AssertTrue(tReport.IsComplete(), "Lab report is complete")
    Do $$$AssertEquals(tReport.Priority, 3, "Routine priority set")
    
    Quit $$$OK
}

/// Test healthcare RadiologyReportBuilder
Method TestRadiologyReportBuilder() As %Status
{
    Set tBuilder = ##class(Patterns.Examples.RadiologyReportBuilder).%New()
    Do $$$AssertTrue($ISOBJECT(tBuilder), "RadiologyReportBuilder created successfully")
    
    // Build a chest X-ray report
    Set tReport = tBuilder.BuildChestXRayReport("RAD-001", "PT-456", "Jane Smith",
                                                "Chest pain", "Clear", "Normal size", "No acute abnormality")
    Do $$$AssertTrue($ISOBJECT(tReport), "Chest X-ray report created successfully")
    Do $$$AssertEquals(tReport.ReportType, "Chest X-Ray", "Correct report type")
    Do $$$AssertTrue(tReport.PatientInfo [ "Jane Smith", "Patient name in report")
    Do $$$AssertTrue(tReport.ClinicalHistory [ "Chest pain", "Indication in history")
    Do $$$AssertTrue(tReport.Interpretation [ "No acute cardiopulmonary process", "Normal impression")
    Do $$$AssertTrue(tReport.IsComplete(), "Radiology report is complete")
    
    Quit $$$OK
}

/// Test healthcare DischargeReportBuilder
Method TestDischargeReportBuilder() As %Status
{
    Set tBuilder = ##class(Patterns.Examples.DischargeReportBuilder).%New()
    Do $$$AssertTrue($ISOBJECT(tBuilder), "DischargeReportBuilder created successfully")
    
    // Build a medical discharge summary
    Set tReport = tBuilder.BuildMedicalDischarge("DC-001", "PT-789", "Bob Johnson",
                                                 "Pneumonia", "Resolved pneumonia", 
                                                 "Patient responded well to antibiotic therapy")
    Do $$$AssertTrue($ISOBJECT(tReport), "Discharge summary created successfully")
    Do $$$AssertEquals(tReport.ReportType, "Discharge Summary", "Correct report type")
    Do $$$AssertTrue(tReport.PatientInfo [ "Bob Johnson", "Patient name in report")
    Do $$$AssertTrue(tReport.ClinicalHistory [ "Pneumonia", "Admission diagnosis in history")
    Do $$$AssertTrue(tReport.Findings [ "antibiotic therapy", "Hospital course in findings")
    Do $$$AssertTrue(tReport.Interpretation [ "Resolved pneumonia", "Discharge diagnosis")
    Do $$$AssertTrue(tReport.IsComplete(), "Discharge summary is complete")
    Do $$$AssertEquals(tReport.Priority, 2, "Discharge summaries have urgent priority")
    
    Quit $$$OK
}

/// Test fluent interface with medical report builders
Method TestMedicalReportFluentInterface() As %Status
{
    Set tBuilder = ##class(Patterns.Examples.LabReportBuilder).%New()
    
    // Test fluent method chaining
    Do tBuilder.Reset()
    Do tBuilder.SetReportIdentification("LAB-002", "Laboratory Report")
    Do tBuilder.BuildPatientInfo("PT-999", "Test Patient", "01/01/1980", "MRN-12345")
    Do tBuilder.BuildClinicalHistory("Routine screening")
    Do tBuilder.BuildFindings("All values within normal limits")
    Do tBuilder.BuildInterpretation("No abnormalities detected")
    Do tBuilder.BuildRecommendations("Annual follow-up")
    Do tBuilder.AddSignature("Dr. Test", "MD")
    Do tBuilder.SetPriority(3)
    Do tBuilder.SetStatus("Final")
    
    Set tReport = tBuilder.GetResult()
    Do $$$AssertTrue($ISOBJECT(tReport), "Report created via fluent interface")
    Do $$$AssertEquals(tReport.ReportId, "LAB-002", "Report ID correct")
    Do $$$AssertEquals(tReport.Status, "Final", "Report status correct")
    Do $$$AssertTrue(tReport.IsComplete(), "Report is complete")
    
    Quit $$$OK
}

/// Test building complex reports with metadata and attachments
Method TestComplexReportBuilding() As %Status
{
    Set tBuilder = ##class(Patterns.Examples.RadiologyReportBuilder).%New()
    
    // Build a CT scan report with metadata
    Set tReport = tBuilder.BuildCTScanReport("CT-001", "PT-555", "Alice Brown",
                                            "Abdomen", "Abdominal pain", 
                                            "No acute findings. Liver and spleen normal size.", 1)
    Do $$$AssertTrue($ISOBJECT(tReport), "CT report created successfully")
    
    // Check metadata
    Do $$$AssertEquals(tReport.GetMetadata("StudyType"), "CT", "Study type metadata correct")
    Do $$$AssertEquals(tReport.GetMetadata("BodyPart"), "Abdomen", "Body part metadata correct")
    Do $$$AssertEquals(tReport.GetMetadata("Contrast"), "Yes", "Contrast metadata correct")
    
    // Check signatures (should have resident and attending)
    Do $$$AssertTrue(tReport.Signatures.Count() >= 2, "Multiple signatures present")
    
    Quit $$$OK
}

/// Test Director with custom construction sequence
Method TestDirectorCustomConstruction() As %Status
{
    Set tDirector = ##class(Patterns.GoF.Creational.Director).%New()
    Set tBuilder = ##class(Patterns.GoF.Creational.ConcreteBuilder2).%New()
    
    // Define custom steps
    Set tSteps = $ListBuild("A", "C", "A", "B")
    Set tProduct = tDirector.ConstructWithSteps(tBuilder, tSteps)
    
    Do $$$AssertTrue($ISOBJECT(tProduct), "Custom construction successful")
    Do $$$AssertTrue(tProduct.HasComponent("Component A from ConcreteBuilder2"), "Has Component A")
    Do $$$AssertTrue(tProduct.HasComponent("Component B from ConcreteBuilder2"), "Has Component B")
    Do $$$AssertTrue(tProduct.HasComponent("Component C from ConcreteBuilder2"), "Has Component C")
    
    Quit $$$OK
}

/// Test error handling in builders
Method TestBuilderErrorHandling() As %Status
{
    // Test with LabReportBuilder (concrete class)
    Set tLabBuilder = ##class(Patterns.Examples.LabReportBuilder).%New()
    
    // Try to get result without building required fields
    Do tLabBuilder.Reset()
    Set tReport = tLabBuilder.GetResult()
    Do $$$AssertEquals(tReport, "", "GetResult returns empty when validation fails")
    
    // Build with minimal required fields
    Do tLabBuilder.Reset()
    Do tLabBuilder.SetReportIdentification("LAB-003", "Lab Report")
    Do tLabBuilder.BuildPatientInfo("PT-111", "Test", "01/01/2000")
    Do tLabBuilder.BuildFindings("Test findings")
    Do tLabBuilder.AddSignature("Dr. Test", "MD")
    
    Set tReport = tLabBuilder.GetResult()
    Do $$$AssertTrue($ISOBJECT(tReport), "Report created with minimum required fields")
    Do $$$AssertTrue(tReport.IsComplete(), "Minimum report is complete")
    
    Quit $$$OK
}

/// Test specialized builder methods
Method TestSpecializedBuilderMethods() As %Status
{
    // Test ConcreteBuilder2's BuildSpecialized method
    Set tBuilder = ##class(Patterns.GoF.Creational.ConcreteBuilder2).%New()
    
    // Build Advanced product
    Set tAdvanced = tBuilder.BuildSpecialized("Advanced")
    Do $$$AssertTrue($ISOBJECT(tAdvanced), "Advanced product created")
    Do $$$AssertEquals(tAdvanced.ProductId, "SPEC-Advanced", "Advanced product ID set")
    Do $$$AssertTrue(tAdvanced.HasComponent("Advanced Processing"), "Has advanced component")
    
    // Test DischargeReportBuilder's surgical discharge
    Set tDischargeBuilder = ##class(Patterns.Examples.DischargeReportBuilder).%New()
    Set tSurgicalReport = tDischargeBuilder.BuildSurgicalDischarge(
        "SURG-001", "PT-222", "Surgery Patient",
        "Appendectomy", "Uncomplicated recovery", "None")
    
    Do $$$AssertTrue($ISOBJECT(tSurgicalReport), "Surgical discharge created")
    Do $$$AssertEquals(tSurgicalReport.ReportType, "Surgical Discharge Summary", "Correct surgical report type")
    Do $$$AssertEquals(tSurgicalReport.Priority, 1, "Surgical discharges have STAT priority")
    
    Quit $$$OK
}

}
