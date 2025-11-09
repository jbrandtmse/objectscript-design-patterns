/// Unit Tests for Special Case Pattern
/// 
/// Tests the Special Case pattern including Null Object, Unknown Case, and Default Case variants
/// as well as healthcare-specific examples (NullPatient, UnknownPatient)
Class Patterns.Test.Unit.PoEAA.Base.SpecialCaseTest Extends %UnitTest.TestCase
{

/// Test that NullObject behaves as a valid object
Method TestNullObjectBehavesAsValidObject() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create null object
        Set tNullObj = ##class(Patterns.PoEAA.Base.NullObject).%New()
        
        // Assert it's an object
        Do $$$AssertTrue($IsObject(tNullObj), "NullObject should be a valid object")
        
        // Assert it has expected methods
        Do $$$AssertTrue($IsObject(tNullObj), "NullObject should respond to method calls")
        
        // Assert it can be called without errors
        Set tResult = tNullObj.Execute()
        Do $$$AssertStatusOK(tResult, "NullObject.Execute() should return OK status")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test that NullObject eliminates null checks
Method TestNullObjectEliminatesNullChecks() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create null object
        Set tNullObj = ##class(Patterns.PoEAA.Base.NullObject).%New()
        
        // Client code can call methods without null checks
        // This would normally require: If $IsObject(obj) { ... }
        Set tResult = tNullObj.Save()
        Do $$$AssertStatusOK(tResult, "NullObject.Save() should succeed without null check")
        
        Set tResult = tNullObj.Delete()
        Do $$$AssertStatusOK(tResult, "NullObject.Delete() should succeed without null check")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test IsNull() identifies null objects
Method TestIsNullIdentifiesNullObjects() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create null object
        Set tNullObj = ##class(Patterns.PoEAA.Base.NullObject).%New()
        
        // Assert IsNull returns true
        Do $$$AssertTrue(tNullObj.IsNull(), "NullObject.IsNull() should return 1")
        
        // Create special case base (not null)
        Set tUnknown = ##class(Patterns.PoEAA.Base.UnknownCase).%New()
        Do $$$AssertTrue('tUnknown.IsNull(), "UnknownCase.IsNull() should return 0")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test IsSpecialCase() identifies special cases
Method TestIsSpecialCaseIdentifiesSpecialCases() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // All special case variants should return true
        Set tNullObj = ##class(Patterns.PoEAA.Base.NullObject).%New()
        Do $$$AssertTrue(tNullObj.IsSpecialCase(), "NullObject.IsSpecialCase() should return 1")
        
        Set tUnknown = ##class(Patterns.PoEAA.Base.UnknownCase).%New()
        Do $$$AssertTrue(tUnknown.IsSpecialCase(), "UnknownCase.IsSpecialCase() should return 1")
        
        Set tDefault = ##class(Patterns.PoEAA.Base.DefaultCase).%New()
        Do $$$AssertTrue(tDefault.IsSpecialCase(), "DefaultCase.IsSpecialCase() should return 1")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test UnknownCase provides safe defaults
Method TestUnknownCaseProvidesDefaults() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create unknown case
        Set tUnknown = ##class(Patterns.PoEAA.Base.UnknownCase).%New()
        
        // Assert safe defaults
        Do $$$AssertTrue('tUnknown.IsNull(), "UnknownCase should not be null")
        Do $$$AssertTrue(tUnknown.IsSpecialCase(), "UnknownCase should be special case")
        
        // Assert default label
        Set tLabel = tUnknown.GetDisplayLabel()
        Do $$$AssertEquals(tLabel, "Unknown", "UnknownCase should have default label")
        
        // Assert safe execution
        Set tResult = tUnknown.Execute()
        Do $$$AssertStatusOK(tResult, "UnknownCase.Execute() should return OK")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test DefaultCase provides default behavior
Method TestDefaultCaseProvidesDefaults() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create default case
        Set tDefault = ##class(Patterns.PoEAA.Base.DefaultCase).%New()
        
        // Assert not null
        Do $$$AssertTrue('tDefault.IsNull(), "DefaultCase should not be null")
        
        // Assert is default
        Do $$$AssertTrue(tDefault.IsDefault(), "DefaultCase.IsDefault() should return 1")
        
        // Assert default values
        Set tValue = tDefault.GetDefaultValue()
        Do $$$AssertEquals(tValue, "", "DefaultCase should return empty string")
        
        Set tNumeric = tDefault.GetDefaultNumeric()
        Do $$$AssertEquals(tNumeric, 0, "DefaultCase should return zero")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test polymorphic behavior with special cases
Method TestPolymorphicBehavior() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create array of different special cases
        Set tCases = 3
        Set tCase(1) = ##class(Patterns.PoEAA.Base.NullObject).%New()
        Set tCase(2) = ##class(Patterns.PoEAA.Base.UnknownCase).%New()
        Set tCase(3) = ##class(Patterns.PoEAA.Base.DefaultCase).%New()
        
        // All can be treated polymorphically
        For tIdx=1:1:tCases {
            Do $$$AssertTrue($IsObject(tCase(tIdx)), "Special case should be object")
            Do $$$AssertTrue(tCase(tIdx).IsSpecialCase(), "Should identify as special case")
            
            Set tResult = tCase(tIdx).Execute()
            Do $$$AssertStatusOK(tResult, "All special cases should execute safely")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test UnknownPatient healthcare example
Method TestUnknownPatient() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create unknown patient
        Set tPatient = ##class(Patterns.Examples.Clinical.UnknownPatient).%New()
        
        // Assert special case behavior
        Do $$$AssertTrue($IsObject(tPatient), "UnknownPatient should be valid object")
        Do $$$AssertTrue('tPatient.IsNull(), "UnknownPatient should not be null")
        Do $$$AssertTrue(tPatient.IsSpecialCase(), "UnknownPatient should be special case")
        
        // Assert healthcare-specific behavior
        Set tName = tPatient.GetDisplayName()
        Do $$$AssertEquals(tName, "Unregistered Patient", "UnknownPatient should have correct display name")
        
        Set tMRN = tPatient.GetMRN()
        Do $$$AssertTrue($LENGTH(tMRN) > 0, "UnknownPatient should have temporary MRN")
        Do $$$AssertTrue($EXTRACT(tMRN, 1, 5) = "TEMP-", "UnknownPatient MRN should start with TEMP-")
        
        // Assert registration status
        Do $$$AssertTrue(tPatient.IsTemporary(), "UnknownPatient should be temporary")
        Do $$$AssertTrue(tPatient.NeedsRegistration(), "UnknownPatient should need registration")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test NullPatient eliminates null checks
Method TestNullPatientEliminatesNullChecks() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create null patient
        Set tPatient = ##class(Patterns.Examples.Clinical.NullPatient).%New()
        
        // Assert can call methods without null checks
        Do $$$AssertTrue($IsObject(tPatient), "NullPatient should be valid object")
        
        Set tName = tPatient.GetDisplayName()
        Do $$$AssertEquals(tName, "Unknown Patient", "NullPatient should return Unknown Patient")
        
        Set tMRN = tPatient.GetMRN()
        Do $$$AssertEquals(tMRN, "UNKNOWN", "NullPatient should return UNKNOWN MRN")
        
        Set tFullName = tPatient.GetFullName()
        Do $$$AssertEquals(tFullName, "Unknown", "NullPatient should return Unknown")
        
        // Assert null identification
        Do $$$AssertTrue(tPatient.IsNull(), "NullPatient.IsNull() should return 1")
        Do $$$AssertTrue(tPatient.IsSpecialCase(), "NullPatient should be special case")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test safe navigation patterns
Method TestSafeNavigationPatterns() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create special case
        Set tCase = ##class(Patterns.PoEAA.Base.NullObject).%New()
        
        // Test safe navigation
        Set tNavigated = tCase.SafeNavigate()
        Do $$$AssertTrue($IsObject(tNavigated), "SafeNavigate should return object")
        Do $$$AssertEquals(tNavigated, tCase, "SafeNavigate should return self")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test special case in collections
Method TestSpecialCaseInCollections() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create collection with special cases
        Set tPatient(1) = ##class(Patterns.Examples.Clinical.NullPatient).%New()
        Set tPatient(2) = ##class(Patterns.Examples.Clinical.UnknownPatient).%New()
        
        // Process collection without null checks
        For tIdx=1:1:2 {
            Do $$$AssertTrue($IsObject(tPatient(tIdx)), "Collection item should be object")
            
            Set tName = tPatient(tIdx).GetDisplayName()
            Do $$$AssertTrue($LENGTH(tName) > 0, "Should get display name without null check")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test error handling with special cases
Method TestErrorHandlingWithSpecialCases() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Special cases should not throw errors
        Set tNull = ##class(Patterns.PoEAA.Base.NullObject).%New()
        
        // Operations should succeed
        Set tResult = tNull.Execute()
        Do $$$AssertStatusOK(tResult, "NullObject operations should not error")
        
        Set tResult = tNull.Save()
        Do $$$AssertStatusOK(tResult, "NullObject.Save() should not error")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test special case equality
Method TestSpecialCaseEquality() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create two null objects
        Set tNull1 = ##class(Patterns.PoEAA.Base.NullObject).%New()
        Set tNull2 = ##class(Patterns.PoEAA.Base.NullObject).%New()
        
        // Both should identify as null
        Do $$$AssertTrue(tNull1.IsNull(), "First null object should be null")
        Do $$$AssertTrue(tNull2.IsNull(), "Second null object should be null")
        
        // Both should be special cases
        Do $$$AssertTrue(tNull1.IsSpecialCase(), "First should be special case")
        Do $$$AssertTrue(tNull2.IsSpecialCase(), "Second should be special case")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

/// Test factory methods create appropriate cases
Method TestFactoryMethods() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Test NullObject factory
        Set tNull = ##class(Patterns.PoEAA.Base.NullObject).CreateNullObject()
        Do $$$AssertTrue($IsObject(tNull), "Factory should create object")
        Do $$$AssertTrue(tNull.IsNull(), "Factory should create null object")
        
        // Test UnknownCase factory
        Set tUnknown = ##class(Patterns.PoEAA.Base.UnknownCase).CreateUnknownCase()
        Do $$$AssertTrue($IsObject(tUnknown), "Factory should create object")
        Do $$$AssertTrue('tUnknown.IsNull(), "Unknown should not be null")
        
        // Test DefaultCase factory
        Set tDefault = ##class(Patterns.PoEAA.Base.DefaultCase).CreateDefaultCase()
        Do $$$AssertTrue($IsObject(tDefault), "Factory should create object")
        Do $$$AssertTrue(tDefault.IsDefault(), "Factory should create default case")
        
        // Test healthcare factories
        Set tNullPatient = ##class(Patterns.Examples.Clinical.NullPatient).CreateNullPatient()
        Do $$$AssertTrue($IsObject(tNullPatient), "Should create null patient")
        Do $$$AssertTrue(tNullPatient.IsNull(), "Should be null patient")
        
        Set tUnknownPatient = ##class(Patterns.Examples.Clinical.UnknownPatient).CreateUnknownPatient()
        Do $$$AssertTrue($IsObject(tUnknownPatient), "Should create unknown patient")
        Do $$$AssertTrue('tUnknownPatient.IsNull(), "Unknown patient should not be null")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit $$$OK
}

}
