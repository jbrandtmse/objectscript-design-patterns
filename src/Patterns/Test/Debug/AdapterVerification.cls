Class Patterns.Test.Debug.AdapterVerification
{

/// Verify ClassAdapter implementation
ClassMethod VerifyClassAdapter() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ^ClineDebug _ "ClassAdapter test started; "
    
    Try {
        // Create ClassAdapter
        Set tAdapter = ##class(Patterns.GoF.Structural.ClassAdapter).%New()
        Set ^ClineDebug = ^ClineDebug _ "ClassAdapter created successfully; "
        
        // Test Request method
        Set tResult = tAdapter.Request()
        Set ^ClineDebug = ^ClineDebug _ "ClassAdapter.Request() called successfully; "
        Set ^ClineDebug = ^ClineDebug _ "ClassAdapter result: '" _ tResult _ "'; "
        
        // Verify result contains expected adaptation
        If (tResult '[ "Adapted:") {
            Set tSC = $$$ERROR($$$GeneralError, "ClassAdapter.Request() did not return adapted result")
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "ClassAdapter test passed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug _ "ClassAdapter test error: " _ $System.Status.GetErrorText(tSC) _ "; "
    }
    
    Quit tSC
}

/// Verify ObjectAdapter implementation
ClassMethod VerifyObjectAdapter() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ^ClineDebug _ "ObjectAdapter test started; "
    
    Try {
        // Test with explicit adaptee
        Set tAdaptee = ##class(Patterns.GoF.Structural.Adaptee).%New()
        Set tAdapter1 = ##class(Patterns.GoF.Structural.ObjectAdapter).%New(tAdaptee)
        Set ^ClineDebug = ^ClineDebug _ "ObjectAdapter created with explicit adaptee; "
        
        Set tResult1 = tAdapter1.Request()
        Set ^ClineDebug = ^ClineDebug _ "Result1: '" _ tResult1 _ "'; "
        
        // Verify result contains expected adaptation
        If (tResult1 '[ "Adapted:") && (tResult1 '[ "Object Adapted:") {
            Set tSC = $$$ERROR($$$GeneralError, "ObjectAdapter.Request() did not return adapted result with explicit adaptee")
            Quit
        }
        
        // Test with default adaptee (created automatically)
        Set tAdapter2 = ##class(Patterns.GoF.Structural.ObjectAdapter).%New()
        Set ^ClineDebug = ^ClineDebug _ "ObjectAdapter created with default adaptee; "
        
        Set tResult2 = tAdapter2.Request()
        Set ^ClineDebug = ^ClineDebug _ "Result2: '" _ tResult2 _ "'; "
        
        // Should have created a default adaptee and return adapted result
        If (tResult2 '[ "Adapted:") && (tResult2 '[ "Object Adapted:") {
            Set tSC = $$$ERROR($$$GeneralError, "ObjectAdapter did not create default adaptee correctly")
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "ObjectAdapter test passed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug _ "ObjectAdapter test error: " _ $System.Status.GetErrorText(tSC) _ "; "
    }
    
    Quit tSC
}

/// Verify LegacyCodeAdapter implementation
ClassMethod VerifyLegacyCodeAdapter() As %Status
{
    Set tSC = $$$OK
    Set ^ClineDebug = ^ClineDebug _ "LegacyCodeAdapter test started; "
    
    Try {
        // First check if the class exists and is compiled
        Set ^ClineDebug = ^ClineDebug _ "Checking class existence; "
        If '##class(%Dictionary.CompiledClass).%ExistsId("Patterns.GoF.Structural.LegacyCodeAdapter") {
            Set tSC = $$$ERROR($$$GeneralError, "LegacyCodeAdapter class not compiled")
            Set ^ClineDebug = ^ClineDebug _ "Class not compiled; "
            Quit
        }
        
        // Test with default LegacyAdaptee
        Set ^ClineDebug = ^ClineDebug _ "Creating LegacyCodeAdapter with default; "
        Set tAdapter1 = ##class(Patterns.GoF.Structural.LegacyCodeAdapter).%New()
        If '$IsObject(tAdapter1) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to create LegacyCodeAdapter")
            Set ^ClineDebug = ^ClineDebug _ "Failed to create adapter; "
            Quit
        }
        Set ^ClineDebug = ^ClineDebug _ "LegacyCodeAdapter created with default LegacyAdaptee; "
        
        Set tResult1 = tAdapter1.Request()
        Set ^ClineDebug = ^ClineDebug _ "Result1: '" _ tResult1 _ "'; "
        
        // Verify result contains expected adaptation
        If (tResult1 '[ "Modern Adapted:") && (tResult1 '[ "Adapted:") {
            Set tSC = $$$ERROR($$$GeneralError, "LegacyCodeAdapter did not adapt legacy result correctly")
            Quit
        }
        
        // Test with explicit LegacyAdaptee
        Set tLegacy = ##class(Patterns.GoF.Structural.LegacyAdaptee).%New()
        Set tAdapter2 = ##class(Patterns.GoF.Structural.LegacyCodeAdapter).%New(tLegacy)
        Set ^ClineDebug = ^ClineDebug _ "LegacyCodeAdapter created with explicit LegacyAdaptee; "
        
        Set tResult2 = tAdapter2.Request()
        Set ^ClineDebug = ^ClineDebug _ "Result2: '" _ tResult2 _ "'; "
        
        // Verify result contains expected adaptation
        If (tResult2 '[ "Modern Adapted:") && (tResult2 '[ "Adapted:") {
            Set tSC = $$$ERROR($$$GeneralError, "LegacyCodeAdapter did not adapt explicit legacy result correctly")
            Quit
        }
        
        Set ^ClineDebug = ^ClineDebug _ "LegacyCodeAdapter test passed; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Set ^ClineDebug = ^ClineDebug _ "LegacyCodeAdapter test error: " _ $System.Status.GetErrorText(tSC) _ "; "
    }
    
    Quit tSC
}

/// Verify all adapters at once
ClassMethod VerifyAllAdapters() As %Status
{
    Set ^ClineDebug = ""  // Clear debug log
    Set ^ClineDebug = ^ClineDebug _ "=== Verifying All Adapter Patterns ===; "
    
    Write "=== Verifying All Adapter Patterns ===", !
    Write !
    
    Set tOverallStatus = $$$OK
    Set tPassedCount = 0
    Set tFailedCount = 0
    
    // Verify ClassAdapter
    Write "Verifying ClassAdapter...", !
    Set tSC = ..VerifyClassAdapter()
    If $$$ISOK(tSC) {
        Write "ClassAdapter verification: SUCCESS", !
        Set tPassedCount = tPassedCount + 1
    } Else {
        Write "ClassAdapter verification: FAILED", !
        Write "Error: ", $System.Status.GetErrorText(tSC), !
        Set tFailedCount = tFailedCount + 1
        Set tOverallStatus = tSC
    }
    Write !
    
    // Verify ObjectAdapter
    Write "Verifying ObjectAdapter...", !
    Set tSC = ..VerifyObjectAdapter()
    If $$$ISOK(tSC) {
        Write "ObjectAdapter verification: SUCCESS", !
        Set tPassedCount = tPassedCount + 1
    } Else {
        Write "ObjectAdapter verification: FAILED", !
        Write "Error: ", $System.Status.GetErrorText(tSC), !
        Set tFailedCount = tFailedCount + 1
        Set tOverallStatus = tSC
    }
    Write !
    
    // Verify LegacyCodeAdapter
    Write "Verifying LegacyCodeAdapter...", !
    Set tSC = ..VerifyLegacyCodeAdapter()
    If $$$ISOK(tSC) {
        Write "LegacyCodeAdapter verification: SUCCESS", !
        Set tPassedCount = tPassedCount + 1
    } Else {
        Write "LegacyCodeAdapter verification: FAILED", !
        Write "LegacyCodeAdapter test error: ", $System.Status.GetErrorText(tSC), !
        Set tFailedCount = tFailedCount + 1
        Set tOverallStatus = tSC
    }
    Write !
    
    Write "=== Verification Summary ===", !
    Write "Total tests: ", (tPassedCount + tFailedCount), !
    Write "Passed: ", tPassedCount, !
    Write "Failed: ", tFailedCount, !
    
    Quit tOverallStatus
}

}
