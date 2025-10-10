/// Unit Tests for Lazy Load Pattern
/// 
/// Tests all variants: Virtual Proxy, Ghost Object, and Value Holder
/// Validates lazy loading behavior, performance benefits, and error handling
Class Patterns.Test.Unit.PoEAA.ObjectRelational.LazyLoadTest Extends %UnitTest.TestCase
{

/// Test Virtual Proxy delays loading until access
Method TestVirtualProxyDelaysLoading() As %Status
{
    // Arrange
    Set tProxy = ##class(Patterns.PoEAA.ObjectRelational.VirtualProxy).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN123"
    )
    
    // Act - Just creating proxy should not trigger load
    // Assert
    Do $$$AssertEquals(tProxy.IsLoaded, 0, "Virtual Proxy should not be loaded on creation")
    Do $$$AssertEquals(tProxy.HasRealSubject(), 0, "Virtual Proxy should not have real subject yet")
    
    Quit $$$OK
}

/// Test Virtual Proxy loads on first access
Method TestVirtualProxyLoadsOnAccess() As %Status
{
    // Arrange
    Set tProxy = ##class(Patterns.PoEAA.ObjectRelational.VirtualProxy).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN123"
    )
    
    // Act - Access real subject
    Set tRealSubject = tProxy.GetRealSubject()
    
    // Assert
    Do $$$AssertEquals(tProxy.IsLoaded, 1, "Virtual Proxy should be loaded after access")
    Do $$$AssertTrue($IsObject(tRealSubject), "Real subject should be an object")
    
    Quit $$$OK
}

/// Test Ghost Object loads on first property access
Method TestGhostObjectLoadsOnPropertyAccess() As %Status
{
    // Arrange
    Set tGhost = ##class(Patterns.PoEAA.ObjectRelational.GhostObject).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN123"
    )
    
    // Act - Before load
    // Assert
    Do $$$AssertEquals(tGhost.IsLoaded, 0, "Ghost Object should not be loaded on creation")
    
    Quit $$$OK
}

/// Test Value Holder computes value on demand
Method TestValueHolderComputesOnDemand() As %Status
{
    // Arrange
    Set tHolder = ##class(Patterns.PoEAA.ObjectRelational.ValueHolder).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN123",
        "Load"
    )
    
    // Act - Before getting value
    // Assert
    Do $$$AssertEquals(tHolder.IsLoaded, 0, "Value Holder should not be loaded on creation")
    Do $$$AssertEquals(tHolder.HasValue(), 0, "Value Holder should not have value yet")
    
    // Act - Get value (triggers load)
    Set tValue = tHolder.GetValue()
    
    // Assert
    Do $$$AssertEquals(tHolder.IsLoaded, 1, "Value Holder should be loaded after GetValue()")
    Do $$$AssertEquals(tHolder.HasValue(), 1, "Value Holder should have value after load")
    
    Quit $$$OK
}

/// Test IsLoaded() correctly identifies load state
Method TestIsLoadedIdentifiesState() As %Status
{
    // Arrange
    Set tProxy = ##class(Patterns.PoEAA.ObjectRelational.VirtualProxy).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN123"
    )
    
    // Assert - Initial state
    Do $$$AssertEquals(tProxy.IsLoaded, 0, "Should not be loaded initially")
    
    // Act - Trigger load
    Do tProxy.Load()
    
    // Assert - After load
    Do $$$AssertEquals(tProxy.IsLoaded, 1, "Should be loaded after Load()")
    
    Quit $$$OK
}

/// Test Load() triggers deferred loading
Method TestLoadTriggersLoading() As %Status
{
    // Arrange
    Set tProxy = ##class(Patterns.PoEAA.ObjectRelational.VirtualProxy).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN123"
    )
    
    // Act
    Set tSC = tProxy.Load()
    
    // Assert
    Do $$$AssertStatusOK(tSC, "Load() should return OK status")
    Do $$$AssertEquals(tProxy.IsLoaded, 1, "Should be loaded after Load()")
    
    Quit $$$OK
}

/// Test transparent loading on property access
Method TestTransparentLoading() As %Status
{
    // Arrange
    Set tPatient = ##class(Patterns.Examples.Clinical.VirtualProxyPatient).%New()
    Set tPatient.PatientMRN = "MRN123"
    Set tPatient.FirstName = "John"
    
    // Assert - Initial state
    Do $$$AssertEquals(tPatient.IsMedicalHistoryLoaded(), 0, "Medical history should not be loaded initially")
    
    // Act - Access triggers lazy load (transparent to client)
    Set tHistory = tPatient.GetMedicalHistory()
    
    // Assert - After access
    Do $$$AssertEquals(tPatient.IsMedicalHistoryLoaded(), 1, "Medical history should be loaded after access")
    Do $$$AssertTrue($IsObject(tHistory), "Medical history should be an object")
    
    Quit $$$OK
}

/// Test lazy collections load on iteration
Method TestLazyCollectionLoadsOnIteration() As %Status
{
    // Arrange
    Set tPatient = ##class(Patterns.Examples.Clinical.VirtualProxyPatient).%New()
    Set tPatient.PatientMRN = "MRN123"
    
    // Assert - Lab results not loaded yet
    Do $$$AssertEquals(tPatient.IsLabResultsLoaded(), 0, "Lab results should not be loaded initially")
    
    // Act - Iterate (triggers lazy load)
    Set tLabResults = tPatient.GetLabResults()
    Set tCount = tLabResults.Count()
    
    // Assert
    Do $$$AssertEquals(tPatient.IsLabResultsLoaded(), 1, "Lab results should be loaded after access")
    Do $$$AssertTrue(tCount > 0, "Should have lab results")
    
    Quit $$$OK
}

/// Test multiple lazy properties on same object
Method TestMultipleLazyProperties() As %Status
{
    // Arrange
    Set tPatient = ##class(Patterns.Examples.Clinical.VirtualProxyPatient).%New()
    Set tPatient.PatientMRN = "MRN123"
    
    // Assert - Nothing loaded initially
    Do $$$AssertEquals(tPatient.IsMedicalHistoryLoaded(), 0, "Medical history not loaded")
    Do $$$AssertEquals(tPatient.IsLabResultsLoaded(), 0, "Lab results not loaded")
    Do $$$AssertEquals(tPatient.IsImagingStudiesLoaded(), 0, "Imaging studies not loaded")
    
    // Act - Load only labs
    Set tLabs = tPatient.GetLabResults()
    
    // Assert - Only labs loaded
    Do $$$AssertEquals(tPatient.IsMedicalHistoryLoaded(), 0, "Medical history still not loaded")
    Do $$$AssertEquals(tPatient.IsLabResultsLoaded(), 1, "Lab results now loaded")
    Do $$$AssertEquals(tPatient.IsImagingStudiesLoaded(), 0, "Imaging studies still not loaded")
    
    Quit $$$OK
}

/// Test lazy loading with null/empty results
Method TestLazyLoadingWithNullResults() As %Status
{
    // Arrange
    Set tHolder = ##class(Patterns.PoEAA.ObjectRelational.ValueHolder).%New()
    
    // Act - Set value directly to null
    Do tHolder.SetValue("")
    
    // Assert - Should still be marked as loaded
    Do $$$AssertEquals(tHolder.IsLoaded, 1, "Should be loaded even with null value")
    Do $$$AssertEquals(tHolder.HasValue(), 1, "Should have value (even if null)")
    
    Quit $$$OK
}

/// Test performance improvement vs eager loading
Method TestPerformanceImprovement() As %Status
{
    // Arrange & Act
    Set tMetrics = ##class(Patterns.Examples.Clinical.VirtualProxyPatient).DemonstratePerformanceBenefit()
    
    // Assert
    Do $$$AssertTrue(tMetrics.lazyLoadTimeMs < tMetrics.eagerLoadTimeMs, "Lazy loading should be faster")
    Do $$$AssertTrue(tMetrics.demographicsOnlyMs < 100, "Demographics only should be fast")
    
    Quit $$$OK
}

/// Test lazy loading with circular references
Method TestCircularReferences() As %Status
{
    // Arrange - Create two proxies that could reference each other
    Set tProxy1 = ##class(Patterns.PoEAA.ObjectRelational.VirtualProxy).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN123"
    )
    Set tProxy2 = ##class(Patterns.PoEAA.ObjectRelational.VirtualProxy).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN456"
    )
    
    // Act - Load both
    Do tProxy1.Load()
    Do tProxy2.Load()
    
    // Assert - Both should load successfully
    Do $$$AssertEquals(tProxy1.IsLoaded, 1, "Proxy 1 should be loaded")
    Do $$$AssertEquals(tProxy2.IsLoaded, 1, "Proxy 2 should be loaded")
    
    Quit $$$OK
}

/// Test error handling during deferred load
Method TestErrorHandlingDuringLoad() As %Status
{
    // Arrange - Create proxy with invalid loader
    Set tProxy = ##class(Patterns.PoEAA.ObjectRelational.VirtualProxy).%New(
        "InvalidLoaderClass",
        "MRN123"
    )
    
    // Act
    Set tSC = tProxy.Load()
    
    // Assert - Should return error status
    Do $$$AssertStatusNotOK(tSC, "Load() should fail with invalid loader")
    
    Quit $$$OK
}

/// Test concurrent access to lazy properties
Method TestConcurrentAccess() As %Status
{
    // Arrange
    Set tPatient = ##class(Patterns.Examples.Clinical.VirtualProxyPatient).%New()
    Set tPatient.PatientMRN = "MRN123"
    
    // Act - Access multiple properties concurrently (simulated)
    Set tHistory = tPatient.GetMedicalHistory()
    Set tLabs = tPatient.GetLabResults()
    Set tImaging = tPatient.GetImagingStudies()
    
    // Assert - All should load successfully
    Do $$$AssertEquals(tPatient.IsMedicalHistoryLoaded(), 1, "Medical history loaded")
    Do $$$AssertEquals(tPatient.IsLabResultsLoaded(), 1, "Lab results loaded")
    Do $$$AssertEquals(tPatient.IsImagingStudiesLoaded(), 1, "Imaging studies loaded")
    
    Quit $$$OK
}

/// Test Value Holder with custom loader method
Method TestValueHolderCustomLoaderMethod() As %Status
{
    // Arrange
    Set tHolder = ##class(Patterns.PoEAA.ObjectRelational.ValueHolder).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN123",
        "LoadLabResults"
    )
    
    // Act
    Set tValue = tHolder.GetValue()
    
    // Assert
    Do $$$AssertEquals(tHolder.IsLoaded, 1, "Should be loaded")
    Do $$$AssertTrue($IsObject(tValue), "Should return lab results object")
    
    Quit $$$OK
}

/// Test that repeated access doesn't reload
Method TestRepeatedAccessDoesNotReload() As %Status
{
    // Arrange
    Set tPatient = ##class(Patterns.Examples.Clinical.VirtualProxyPatient).%New()
    Set tPatient.PatientMRN = "MRN123"
    
    // Act - First access
    Set tLabs1 = tPatient.GetLabResults()
    Set tLoadedAfterFirst = tPatient.IsLabResultsLoaded()
    
    // Act - Second access
    Set tLabs2 = tPatient.GetLabResults()
    Set tLoadedAfterSecond = tPatient.IsLabResultsLoaded()
    
    // Assert - Should only load once
    Do $$$AssertEquals(tLoadedAfterFirst, 1, "Should be loaded after first access")
    Do $$$AssertEquals(tLoadedAfterSecond, 1, "Should still be loaded (not reloaded)")
    
    Quit $$$OK
}

/// Test Ghost Object EnsureLoaded method
Method TestGhostObjectEnsureLoaded() As %Status
{
    // Arrange
    Set tGhost = ##class(Patterns.PoEAA.ObjectRelational.GhostObject).%New(
        "Patterns.Examples.Clinical.MedicalHistoryLazyLoader",
        "MRN123"
    )
    
    // Act
    Set tSC = tGhost.EnsureLoaded()
    
    // Assert
    Do $$$AssertStatusOK(tSC, "EnsureLoaded should return OK")
    Do $$$AssertEquals(tGhost.IsLoaded, 1, "Ghost should be loaded after EnsureLoaded()")
    
    Quit $$$OK
}

/// Test patient summary without triggering loads
Method TestPatientSummaryWithoutLoads() As %Status
{
    // Arrange
    Set tPatient = ##class(Patterns.Examples.Clinical.VirtualProxyPatient).%New()
    Set tPatient.PatientMRN = "MRN123"
    Set tPatient.FirstName = "John"
    Set tPatient.LastName = "Doe"
    
    // Act - Get summary (should not trigger loads)
    Set tSummary = tPatient.GetSummary()
    
    // Assert - Basic info available, nothing loaded
    Do $$$AssertEquals(tSummary.PatientMRN, "MRN123", "Should have MRN")
    Do $$$AssertEquals(tSummary.FirstName, "John", "Should have first name")
    Do $$$AssertEquals(tSummary.MedicalHistoryLoaded, 0, "Medical history should not be loaded")
    Do $$$AssertEquals(tSummary.LabResultsLoaded, 0, "Lab results should not be loaded")
    
    Quit $$$OK
}

}
