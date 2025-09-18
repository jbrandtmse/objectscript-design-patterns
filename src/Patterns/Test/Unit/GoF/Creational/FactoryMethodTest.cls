/// Unit tests for Factory Method pattern implementation
/// Tests both abstract factory behavior and concrete implementations
Class Patterns.Test.Unit.GoF.Creational.FactoryMethodTest Extends Patterns.Test.TestCase
{

/// Description: Test abstract factory class cannot be instantiated
Method TestAbstractFactoryInstantiation() As %Status
{
    Set tSC = $$$OK
    
    // Try to create abstract factory (should fail)
    Try {
        Set factory = ##class(Patterns.GoF.Creational.FactoryMethod).%New()
        Do ..LogMessage("ERROR: Should not be able to instantiate abstract factory")
        Do $$$AssertTrue(0, "Abstract factory should not be instantiable")
    } Catch ex {
        Do ..LogMessage("Expected error: " _ ex.DisplayString())
        Do $$$AssertTrue(1, "Abstract factory correctly prevented instantiation")
    }
    
    Quit $$$OK
}

/// Description: Test ConcreteFactoryA creates ProductA
Method TestConcreteFactoryACreatesProductA() As %Status
{
    Set factory = ##class(Patterns.GoF.Creational.ConcreteFactoryA).%New()
    Do $$$AssertTrue($ISOBJECT(factory), "ConcreteFactoryA created")
    
    Set product = factory.FactoryMethod()
    Do $$$AssertTrue($ISOBJECT(product), "Product created by ConcreteFactoryA")
    Do $$$AssertTrue(product.%IsA("Patterns.GoF.Creational.ConcreteProductA"), "Product is ConcreteProductA")
    
    Set operation = product.Operation()
    Do $$$AssertEquals(operation, "ConcreteProductA Operation", "Correct operation result")
    
    Quit $$$OK
}

/// Description: Test ConcreteFactoryB creates ProductB
Method TestConcreteFactoryBCreatesProductB() As %Status
{
    Set factory = ##class(Patterns.GoF.Creational.ConcreteFactoryB).%New()
    Do $$$AssertTrue($ISOBJECT(factory), "ConcreteFactoryB created")
    
    Set product = factory.FactoryMethod()
    Do $$$AssertTrue($ISOBJECT(product), "Product created by ConcreteFactoryB")
    Do $$$AssertTrue(product.%IsA("Patterns.GoF.Creational.ConcreteProductB"), "Product is ConcreteProductB")
    
    Set operation = product.Operation()
    Do $$$AssertEquals(operation, "ConcreteProductB Operation", "Correct operation result")
    
    Quit $$$OK
}

/// Description: Test factory method delegation
Method TestFactoryMethodDelegation() As %Status
{
    // Test with ConcreteFactoryA
    Set factoryA = ##class(Patterns.GoF.Creational.ConcreteFactoryA).%New()
    Set productA = factoryA.FactoryMethod()
    Do $$$AssertTrue($ISOBJECT(productA), "FactoryMethod returns product from ConcreteFactoryA")
    
    // Test with ConcreteFactoryB
    Set factoryB = ##class(Patterns.GoF.Creational.ConcreteFactoryB).%New()
    Set productB = factoryB.FactoryMethod()
    Do $$$AssertTrue($ISOBJECT(productB), "FactoryMethod returns product from ConcreteFactoryB")
    
    // Verify different products
    Do $$$AssertNotEquals(productA.%ClassName(1), productB.%ClassName(1), "Different factories create different products")
    
    Quit $$$OK
}

/// Description: Test polymorphic behavior of products
Method TestProductPolymorphism() As %Status
{
    Set factoryA = ##class(Patterns.GoF.Creational.ConcreteFactoryA).%New()
    Set factoryB = ##class(Patterns.GoF.Creational.ConcreteFactoryB).%New()
    
    Set productA = factoryA.FactoryMethod()
    Set productB = factoryB.FactoryMethod()
    
    // Both should be Products
    Do $$$AssertTrue(productA.%IsA("Patterns.GoF.Creational.Product"), "ProductA implements Product interface")
    Do $$$AssertTrue(productB.%IsA("Patterns.GoF.Creational.Product"), "ProductB implements Product interface")
    
    // But with different implementations
    Set opA = productA.Operation()
    Set opB = productB.Operation()
    Do $$$AssertNotEquals(opA, opB, "Different products have different operations")
    
    Quit $$$OK
}

/// Description: Test that abstract PatientRecordFactory cannot be instantiated
Method TestAbstractPatientRecordFactory() As %Status
{
    Try {
        Set factory = ##class(Patterns.Examples.PatientRecordFactory).%New()
        Do $$$AssertTrue(0, "Should not instantiate abstract PatientRecordFactory")
    } Catch ex {
        Do ..LogMessage("Expected: " _ ex.DisplayString())
        Do $$$AssertTrue(1, "Abstract PatientRecordFactory correctly prevented instantiation")
    }
    
    Quit $$$OK
}

/// Description: Test InpatientRecordFactory creates correct record type
Method TestInpatientRecordFactory() As %Status
{
    Set factory = ##class(Patterns.Examples.InpatientRecordFactory).%New()
    Do $$$AssertTrue($ISOBJECT(factory), "InpatientRecordFactory created")
    
    Set record = factory.CreateRecord()
    Do $$$AssertTrue($ISOBJECT(record), "InpatientRecord created")
    Do $$$AssertTrue(record.%IsA("Patterns.Examples.InpatientRecord"), "Record is InpatientRecord")
    Do $$$AssertEquals(record.RecordType, "INPATIENT", "Correct record type")
    
    // Check inpatient-specific properties
    Do $$$AssertNotEquals(record.RoomNumber, "", "Room number assigned")
    Do $$$AssertNotEquals(record.BedNumber, "", "Bed number assigned")
    Do $$$AssertNotEquals(record.AuthorizationCode, "", "Authorization code generated")
    
    Quit $$$OK
}

/// Description: Test OutpatientRecordFactory creates correct record type
Method TestOutpatientRecordFactory() As %Status
{
    Set factory = ##class(Patterns.Examples.OutpatientRecordFactory).%New()
    Do $$$AssertTrue($ISOBJECT(factory), "OutpatientRecordFactory created")
    
    Set record = factory.CreateRecord()
    Do $$$AssertTrue($ISOBJECT(record), "OutpatientRecord created")
    Do $$$AssertTrue(record.%IsA("Patterns.Examples.OutpatientRecord"), "Record is OutpatientRecord")
    Do $$$AssertEquals(record.RecordType, "OUTPATIENT", "Correct record type")
    
    // Check outpatient-specific properties
    Do $$$AssertNotEquals(record.AppointmentTime, "", "Appointment time set")
    Do $$$AssertNotEquals(record.Copay, "", "Copay calculated")
    Do $$$AssertNotEquals(record.VisitType, "", "Visit type determined")
    
    Quit $$$OK
}

/// Description: Test EmergencyRecordFactory creates correct record type
Method TestEmergencyRecordFactory() As %Status
{
    Set factory = ##class(Patterns.Examples.EmergencyRecordFactory).%New()
    Do $$$AssertTrue($ISOBJECT(factory), "EmergencyRecordFactory created")
    
    Set record = factory.CreateRecord()
    Do $$$AssertTrue($ISOBJECT(record), "EmergencyRecord created")
    Do $$$AssertTrue(record.%IsA("Patterns.Examples.EmergencyRecord"), "Record is EmergencyRecord")
    Do $$$AssertEquals(record.RecordType, "EMERGENCY", "Correct record type")
    
    // Check emergency-specific properties
    Do $$$AssertTrue((record.TriageLevel >= 1) && (record.TriageLevel <= 5), "Valid triage level")
    Do $$$AssertNotEquals(record.ArrivalMode, "", "Arrival mode set")
    Do $$$AssertNotEquals(record.VitalSigns, "", "Vitals recorded")
    
    Quit $$$OK
}

/// Description: Test polymorphic behavior of patient records
Method TestPatientRecordPolymorphism() As %Status
{
    Set inpatientFactory = ##class(Patterns.Examples.InpatientRecordFactory).%New()
    Set outpatientFactory = ##class(Patterns.Examples.OutpatientRecordFactory).%New()
    Set emergencyFactory = ##class(Patterns.Examples.EmergencyRecordFactory).%New()
    
    Set inpatientRecord = inpatientFactory.CreateRecord()
    Set outpatientRecord = outpatientFactory.CreateRecord()
    Set emergencyRecord = emergencyFactory.CreateRecord()
    
    // All should be PatientRecords
    Do $$$AssertTrue(inpatientRecord.%IsA("Patterns.Examples.PatientRecord"), "Inpatient is PatientRecord")
    Do $$$AssertTrue(outpatientRecord.%IsA("Patterns.Examples.PatientRecord"), "Outpatient is PatientRecord")
    Do $$$AssertTrue(emergencyRecord.%IsA("Patterns.Examples.PatientRecord"), "Emergency is PatientRecord")
    
    // But with different types
    Do $$$AssertEquals(inpatientRecord.RecordType, "INPATIENT", "Inpatient type")
    Do $$$AssertEquals(outpatientRecord.RecordType, "OUTPATIENT", "Outpatient type")
    Do $$$AssertEquals(emergencyRecord.RecordType, "EMERGENCY", "Emergency type")
    
    Quit $$$OK
}

/// Description: Test factory creates multiple unique records
Method TestFactoryCreatesUniqueRecords() As %Status
{
    Set factory = ##class(Patterns.Examples.InpatientRecordFactory).%New()
    
    Set record1 = factory.CreateRecord()
    Set record2 = factory.CreateRecord()
    Set record3 = factory.CreateRecord()
    
    // Each record should be unique (different object references)
    Do $$$AssertTrue(record1 '= record2, "Record 1 and 2 are different objects")
    Do $$$AssertTrue(record2 '= record3, "Record 2 and 3 are different objects")
    Do $$$AssertTrue(record1 '= record3, "Record 1 and 3 are different objects")
    
    // Each should have unique IDs
    Do $$$AssertNotEquals(record1.RecordID, record2.RecordID, "Unique record IDs 1-2")
    Do $$$AssertNotEquals(record2.RecordID, record3.RecordID, "Unique record IDs 2-3")
    
    Quit $$$OK
}

/// Description: Test factory registry functionality
Method TestFactoryRegistry() As %Status
{
    // Clear registry first
    Kill ^PatientRecordRegistry
    
    Set inpatientFactory = ##class(Patterns.Examples.InpatientRecordFactory).%New()
    Set outpatientFactory = ##class(Patterns.Examples.OutpatientRecordFactory).%New()
    
    // Create some records
    Set record1 = inpatientFactory.CreateRecord()
    Set record2 = outpatientFactory.CreateRecord()
    Set record3 = inpatientFactory.CreateRecord()
    
    // Check registry
    Do $$$AssertTrue($Data(^PatientRecordRegistry(record1.RecordID)), "Record 1 in registry")
    Do $$$AssertTrue($Data(^PatientRecordRegistry(record2.RecordID)), "Record 2 in registry")
    Do $$$AssertTrue($Data(^PatientRecordRegistry(record3.RecordID)), "Record 3 in registry")
    
    // Verify registry data
    Do $$$AssertEquals(^PatientRecordRegistry(record1.RecordID, "Type"), "INPATIENT", "Record 1 type in registry")
    Do $$$AssertEquals(^PatientRecordRegistry(record2.RecordID, "Type"), "OUTPATIENT", "Record 2 type in registry")
    
    // Clean up
    Kill ^PatientRecordRegistry
    
    Quit $$$OK
}

/// Description: Test emergency record severity calculation
Method TestEmergencyRecordSeverity() As %Status
{
    Set factory = ##class(Patterns.Examples.EmergencyRecordFactory).%New()
    
    // Create multiple records and check severity
    For i=1:1:5 {
        Set record = factory.CreateRecord()
        Do $$$AssertTrue(record.Severity '= "", "Severity calculated for record " _ i)
        Do $$$AssertTrue($ListFind($ListBuild("Critical", "Urgent", "Less Urgent", "Non-Urgent"), record.Severity), "Valid severity level: " _ record.Severity)
    }
    
    Quit $$$OK
}

/// Description: Test inpatient room and bed assignment
Method TestInpatientRoomAssignment() As %Status
{
    Set factory = ##class(Patterns.Examples.InpatientRecordFactory).%New()
    
    // Create multiple records and verify room/bed assignments
    For i=1:1:3 {
        Set record = factory.CreateRecord()
        
        // Verify room format (e.g., "ICU-301", "MED-205")
        Do $$$AssertTrue(record.RoomNumber [ "-", "Room number has correct format: " _ record.RoomNumber)
        
        // Verify bed format (e.g., "A", "B")
        Do $$$AssertTrue($Length(record.BedNumber) = 1, "Bed is single character: " _ record.BedNumber)
        Do $$$AssertTrue((($Ascii(record.BedNumber) >= 65) && ($Ascii(record.BedNumber) <= 68)), "Bed is A-D: " _ record.BedNumber)
    }
    
    Quit $$$OK
}

/// Description: Test outpatient appointment scheduling
Method TestOutpatientAppointmentScheduling() As %Status
{
    Set factory = ##class(Patterns.Examples.OutpatientRecordFactory).%New()
    
    Set record = factory.CreateRecord()
    
    // Verify appointment time format
    Do $$$AssertNotEquals(record.AppointmentTime, "", "Appointment time set")
    Do $$$AssertTrue(record.AppointmentTime [ ":", "Time has colon separator")
    
    // Verify copay is numeric
    Do $$$AssertTrue((+record.Copay) = record.Copay, "Copay is numeric: " _ record.Copay)
    Do $$$AssertTrue(record.Copay >= 0, "Copay is non-negative")
    
    // Verify visit type
    Do $$$AssertTrue($ListFind($ListBuild("Routine Check", "Follow-up", "Consultation", "Specialist Referral", "Preventive Care", "Urgent Care"), record.VisitType), "Valid visit type: " _ record.VisitType)
    
    Quit $$$OK
}

/// Description: Test factory error handling
Method TestFactoryErrorHandling() As %Status
{
    // Test with null factory reference
    Try {
        Set factory = ""
        Set record = factory.CreateRecord()
        Do $$$AssertTrue(0, "Should have thrown error with null factory")
    } Catch ex {
        Do $$$AssertTrue(1, "Correctly handled null factory error")
    }
    
    Quit $$$OK
}

/// Description: Test product abstract class behavior
Method TestProductAbstractClass() As %Status
{
    // Try to instantiate abstract Product (should fail)
    Try {
        Set product = ##class(Patterns.GoF.Creational.Product).%New()
        Do $$$AssertTrue(0, "Should not instantiate abstract Product")
    } Catch ex {
        Do $$$AssertTrue(1, "Abstract Product correctly prevented instantiation")
    }
    
    Quit $$$OK
}

/// Description: Test patient record abstract class behavior
Method TestPatientRecordAbstractClass() As %Status
{
    // Try to instantiate abstract PatientRecord (should fail)
    Try {
        Set record = ##class(Patterns.Examples.PatientRecord).%New()
        Do $$$AssertTrue(0, "Should not instantiate abstract PatientRecord")
    } Catch ex {
        Do $$$AssertTrue(1, "Abstract PatientRecord correctly prevented instantiation")
    }
    
    Quit $$$OK
}

}
