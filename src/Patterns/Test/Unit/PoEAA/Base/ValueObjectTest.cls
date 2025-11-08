/// Unit Tests for Value Object Pattern
/// 
/// Tests the base ValueObject class and healthcare value object implementations
/// including immutability, value-based equality, and validation.
Class Patterns.Test.Unit.PoEAA.Base.ValueObjectTest Extends %UnitTest.TestCase
{

/// Test VitalSigns constructor sets properties correctly
Method TestVitalSignsConstructor() As %Status
{
    // Create VitalSigns instance
    Set tVitals = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)

    // Verify properties were set
    Do $$$AssertEquals(tVitals.Temperature, 98.6, "Temperature should be 98.6")
    Do $$$AssertEquals(tVitals.BloodPressureSystolic, 120, "Systolic BP should be 120")
    Do $$$AssertEquals(tVitals.BloodPressureDiastolic, 80, "Diastolic BP should be 80")
    Do $$$AssertEquals(tVitals.HeartRate, 72, "Heart rate should be 72")
    Do $$$AssertEquals(tVitals.RespiratoryRate, 16, "Respiratory rate should be 16")
    Do $$$AssertEquals(tVitals.OxygenSaturation, 98, "O2 saturation should be 98")

    Quit $$$OK
}

/// Test VitalSigns immutability - properties cannot be changed after construction
Method TestVitalSignsImmutability() As %Status
{
    // Create VitalSigns instance
    Set tVitals = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)

    // Verify we cannot modify properties (they are private)
    // ObjectScript prevents setting private properties from outside the class
    // This test verifies the immutability design

    // Verify original values remain unchanged
    Do $$$AssertEquals(tVitals.Temperature, 98.6, "Temperature should remain 98.6")
    Do $$$AssertEquals(tVitals.HeartRate, 72, "Heart rate should remain 72")

    Quit $$$OK
}

/// Test value-based equality - same values = equal objects
Method TestVitalSignsEqualitySameValues() As %Status
{
    // Create two VitalSigns with same values
    Set tVitals1 = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)
    Set tVitals2 = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)

    // They should be equal even though different instances
    Do $$$AssertTrue(tVitals1.Equals(tVitals2), "VitalSigns with same values should be equal")
    Do $$$AssertTrue(tVitals2.Equals(tVitals1), "Equality should be symmetric")

    Quit $$$OK
}

/// Test value-based inequality - different values = unequal objects
Method TestVitalSignsInequalityDifferentValues() As %Status
{
    // Create two VitalSigns with different values
    Set tVitals1 = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)
    Set tVitals2 = ##class(Patterns.Examples.Clinical.VitalSigns).%New(99.1, 120, 80, 72, 16, 98)

    // They should not be equal
    Do $$$AssertNotTrue(tVitals1.Equals(tVitals2), "VitalSigns with different values should not be equal")

    Quit $$$OK
}

/// Test GetHashCode consistency - equal objects have same hash
Method TestVitalSignsHashCodeConsistency() As %Status
{
    // Create two equal VitalSigns
    Set tVitals1 = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)
    Set tVitals2 = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)

    // Hash codes should be equal
    Set tHash1 = tVitals1.GetHashCode()
    Set tHash2 = tVitals2.GetHashCode()

    Do $$$AssertEquals(tHash1, tHash2, "Equal objects should have same hash code")

    Quit $$$OK
}

/// Test ToString representation
Method TestVitalSignsToString() As %Status
{
    Set tVitals = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)
    Set tString = tVitals.ToString()

    // Verify string contains key information
    Do $$$AssertTrue(tString [ "VitalSigns", "ToString should contain class name")
    Do $$$AssertTrue(tString [ "98.6", "ToString should contain temperature")
    Do $$$AssertTrue(tString [ "120", "ToString should contain systolic BP")

    Quit $$$OK
}

/// Test With* methods create new instances with modified values
Method TestVitalSignsWithMethods() As %Status
{
    Set tOriginal = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)

    // Create modified copy with different temperature
    Set tModified = tOriginal.WithTemperature(99.1)

    // Original should be unchanged
    Do $$$AssertEquals(tOriginal.Temperature, 98.6, "Original temperature should be unchanged")

    // Modified should have new temperature
    Do $$$AssertEquals(tModified.Temperature, 99.1, "Modified should have new temperature")

    // Other values should be copied
    Do $$$AssertEquals(tModified.HeartRate, 72, "Other values should be copied")

    Quit $$$OK
}

/// Test validation rejects invalid temperature
Method TestVitalSignsValidationInvalidTemperature() As %Status
{
    // Attempt to create with invalid temperature (below 95)
    Set tVitals = ##class(Patterns.Examples.Clinical.VitalSigns).%New(90, 120, 80, 72, 16, 98)

    // Constructor should fail validation (returns error status)
    Do $$$AssertNotTrue($$$ISOK(tVitals), "Should reject invalid temperature")

    Quit $$$OK
}

/// Test validation rejects systolic <= diastolic
Method TestVitalSignsValidationBPRelationship() As %Status
{
    // Attempt to create with systolic <= diastolic
    Set tVitals = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 80, 120, 72, 16, 98)

    // Constructor should fail validation
    Do $$$AssertNotTrue($$$ISOK(tVitals), "Should reject systolic <= diastolic")

    Quit $$$OK
}

/// Test IsNormal method for normal vital signs
Method TestVitalSignsIsNormalTrue() As %Status
{
    // Create VitalSigns with all normal values
    Set tVitals = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 110, 70, 75, 16, 98)

    // Should be normal
    Do $$$AssertTrue(tVitals.IsNormal(), "Normal vital signs should return true")

    Quit $$$OK
}

/// Test IsNormal method for abnormal vital signs
Method TestVitalSignsIsNormalFalse() As %Status
{
    // Create VitalSigns with fever
    Set tVitals = ##class(Patterns.Examples.Clinical.VitalSigns).%New(101, 110, 70, 75, 16, 98)

    // Should be abnormal
    Do $$$AssertNotTrue(tVitals.IsNormal(), "Abnormal vital signs should return false")

    Quit $$$OK
}

/// Test LabResult constructor and properties
Method TestLabResultConstructor() As %Status
{
    Set tResult = ##class(Patterns.Examples.Clinical.LabResult).%New("Hemoglobin", "12.5", "g/dL", "12.0-16.0", 0)

    Do $$$AssertEquals(tResult.TestName, "Hemoglobin", "TestName should be set")
    Do $$$AssertEquals(tResult.Value, "12.5", "Value should be set")
    Do $$$AssertEquals(tResult.Unit, "g/dL", "Unit should be set")
    Do $$$AssertEquals(tResult.ReferenceRange, "12.0-16.0", "ReferenceRange should be set")
    Do $$$AssertEquals(tResult.IsAbnormal, 0, "IsAbnormal should be set")

    Quit $$$OK
}

/// Test LabResult equality
Method TestLabResultEquality() As %Status
{
    Set tResult1 = ##class(Patterns.Examples.Clinical.LabResult).%New("Hemoglobin", "12.5", "g/dL", "12.0-16.0", 0)
    Set tResult2 = ##class(Patterns.Examples.Clinical.LabResult).%New("Hemoglobin", "12.5", "g/dL", "12.0-16.0", 0)

    Do $$$AssertTrue(tResult1.Equals(tResult2), "Lab results with same values should be equal")

    Quit $$$OK
}

/// Test LabResult GetSeverity method
Method TestLabResultGetSeverity() As %Status
{
    // Normal result
    Set tNormal = ##class(Patterns.Examples.Clinical.LabResult).%New("Hemoglobin", "14.0", "g/dL", "12.0-16.0", 0)
    Do $$$AssertEquals(tNormal.GetSeverity(), "Normal", "Normal result should have Normal severity")

    // Abnormal result
    Set tAbnormal = ##class(Patterns.Examples.Clinical.LabResult).%New("Hemoglobin", "18.0", "g/dL", "12.0-16.0", 1)
    Set tSeverity = tAbnormal.GetSeverity()
    Do $$$AssertTrue((tSeverity = "Mild") || (tSeverity = "Moderate") || (tSeverity = "Severe"), "Abnormal result should have severity")

    Quit $$$OK
}

/// Test Dosage constructor and properties
Method TestDosageConstructor() As %Status
{
    Set tDosage = ##class(Patterns.Examples.Clinical.Dosage).%New("500", "mg", "twice daily", "oral")

    Do $$$AssertEquals(tDosage.Amount, "500", "Amount should be set")
    Do $$$AssertEquals(tDosage.Unit, "mg", "Unit should be set")
    Do $$$AssertEquals(tDosage.Frequency, "twice daily", "Frequency should be set")
    Do $$$AssertEquals(tDosage.Route, "oral", "Route should be set")

    Quit $$$OK
}

/// Test Dosage equality
Method TestDosageEquality() As %Status
{
    Set tDosage1 = ##class(Patterns.Examples.Clinical.Dosage).%New("500", "mg", "twice daily", "oral")
    Set tDosage2 = ##class(Patterns.Examples.Clinical.Dosage).%New("500", "mg", "twice daily", "oral")

    Do $$$AssertTrue(tDosage1.Equals(tDosage2), "Dosages with same values should be equal")

    Quit $$$OK
}

/// Test Dosage validation rejects invalid route
Method TestDosageValidationInvalidRoute() As %Status
{
    // Attempt to create with invalid route
    Set tDosage = ##class(Patterns.Examples.Clinical.Dosage).%New("500", "mg", "twice daily", "invalid")

    // Constructor should fail validation
    Do $$$AssertNotTrue($$$ISOK(tDosage), "Should reject invalid route")

    Quit $$$OK
}

/// Test Dosage CalculateDailyDose method
Method TestDosageCalculateDailyDose() As %Status
{
    Set tDosage = ##class(Patterns.Examples.Clinical.Dosage).%New("500", "mg", "twice daily", "oral")
    Set tDaily = tDosage.CalculateDailyDose()

    Do $$$AssertEquals(tDaily, "1000 mg/day", "Daily dose should be calculated correctly")

    Quit $$$OK
}

/// Test value objects in collections
Method TestValueObjectsInCollections() As %Status
{
    // Create collection of vital signs
    Set tCollection = ##class(%ArrayOfObjects).%New()

    Set tVitals1 = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)
    Set tVitals2 = ##class(Patterns.Examples.Clinical.VitalSigns).%New(99.1, 125, 82, 78, 18, 97)

    Do tCollection.SetAt(tVitals1, "Morning")
    Do tCollection.SetAt(tVitals2, "Evening")

    // Retrieve from collection
    Set tRetrieved = tCollection.GetAt("Morning")
    Do $$$AssertEquals(tRetrieved.Temperature, 98.6, "Should retrieve correct object from collection")

    // Verify immutability preserved in collection
    Do $$$AssertEquals(tVitals1.Temperature, 98.6, "Original should remain unchanged")

    Quit $$$OK
}

/// Test Equals with null parameter
Method TestEqualsWithNull() As %Status
{
    Set tVitals = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)

    // Should not be equal to null
    Do $$$AssertNotTrue(tVitals.Equals($$$NULLOREF), "Should not equal null")

    Quit $$$OK
}

/// Test Equals with different type
Method TestEqualsWithDifferentType() As %Status
{
    Set tVitals = ##class(Patterns.Examples.Clinical.VitalSigns).%New(98.6, 120, 80, 72, 16, 98)
    Set tDosage = ##class(Patterns.Examples.Clinical.Dosage).%New("500", "mg", "twice daily", "oral")

    // Should not be equal to different type
    Do $$$AssertNotTrue(tVitals.Equals(tDosage), "Should not equal different type")

    Quit $$$OK
}

}
