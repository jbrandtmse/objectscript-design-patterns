Class Patterns.Test.Debug.RowGatewayDebug
{

ClassMethod TestSaveAndFind() As %String
{
    Set ^ClineDebug = ""
    
    Try {
        // Clear any existing data
        Do ##class(Patterns.Examples.Clinical.Patient).%DeleteExtent()
        Set ^ClineDebug = ^ClineDebug _ "1. Cleared extent; "
        
        // Create and save a patient
        Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
        Set ^ClineDebug = ^ClineDebug _ "2. Created gateway, IsNew=" _ tGateway.IsNew() _ "; "
        
        Set tGateway.FirstName = "Test"
        Set tGateway.LastName = "Patient"
        Set tGateway.MRN = "TEST001"
        Set tGateway.Status = "Active"
        Set ^ClineDebug = ^ClineDebug _ "3. Set properties; "
        
        Set tSC = tGateway.Save()
        Set ^ClineDebug = ^ClineDebug _ "4. Save SC=" _ $System.Status.GetErrorText(tSC) _ "; "
        Set ^ClineDebug = ^ClineDebug _ "5. After save: ID=" _ tGateway.Id _ ", IsNew=" _ tGateway.IsNew() _ "; "
        
        Set tId = tGateway.Id
        
        // Try to find it
        Set ^ClineDebug = ^ClineDebug _ "6. Calling FindById(" _ tId _ "); "
        Set tFound = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindById(tId)
        
        Set ^ClineDebug = ^ClineDebug _ "7. FindById returned, checking if object; "
        
        If $IsObject(tFound) {
            Set ^ClineDebug = ^ClineDebug _ "8. Is object! FirstName=" _ tFound.FirstName _ "; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "8. NOT an object, value='" _ tFound _ "'; "
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.DisplayString() _ "; "
    }
    
    Quit ^ClineDebug
}

ClassMethod TestFindAll() As %String
{
    Set ^ClineDebug = ""
    
    Try {
        // Clear any existing data
        &sql(DELETE FROM Patterns_Examples_Clinical.Patient)
        Set ^ClineDebug = ^ClineDebug _ "1. Cleared data; "
        
        // Create and save 3 patients
        Set tGateway1 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
        Set tGateway1.FirstName = "Karen"
        Set tGateway1.LastName = "Thomas"
        Set tGateway1.MRN = "MRN013"
        Do tGateway1.Save()
        Set ^ClineDebug = ^ClineDebug _ "2. Saved patient 1 (ID=" _ tGateway1.Id _ "); "
        
        Set tGateway2 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
        Set tGateway2.FirstName = "Larry"
        Set tGateway2.LastName = "Jackson"
        Set tGateway2.MRN = "MRN014"
        Do tGateway2.Save()
        Set ^ClineDebug = ^ClineDebug _ "3. Saved patient 2 (ID=" _ tGateway2.Id _ "); "
        
        Set tGateway3 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
        Set tGateway3.FirstName = "Mary"
        Set tGateway3.LastName = "White"
        Set tGateway3.MRN = "MRN015"
        Do tGateway3.Save()
        Set ^ClineDebug = ^ClineDebug _ "4. Saved patient 3 (ID=" _ tGateway3.Id _ "); "
        
        // Find all
        Set ^ClineDebug = ^ClineDebug _ "5. Calling FindAll(); "
        Set tList = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindAll()
        
        Set ^ClineDebug = ^ClineDebug _ "6. FindAll returned; "
        
        If $IsObject(tList) {
            Set ^ClineDebug = ^ClineDebug _ "7. Is object! Count=" _ tList.Count() _ "; "
            
            For i=1:1:tList.Count() {
                Set tItem = tList.GetAt(i)
                If $IsObject(tItem) {
                    Set ^ClineDebug = ^ClineDebug _ "Item " _ i _ ": " _ tItem.FirstName _ " " _ tItem.LastName _ "; "
                } Else {
                    Set ^ClineDebug = ^ClineDebug _ "Item " _ i _ ": NOT AN OBJECT; "
                }
            }
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "7. NOT an object, value='" _ tList _ "'; "
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.DisplayString() _ "; "
    }
    
    Quit ^ClineDebug
}

ClassMethod TestFindAllWithAssertions() As %String
{
    Set ^ClineDebug = ""
    
    Try {
        // Clear any existing data
        &sql(DELETE FROM Patterns_Examples_Clinical.Patient)
        Set ^ClineDebug = ^ClineDebug _ "1. Cleared data; "
        
        // Create patient 1
        Set tGateway1 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
        Set tGateway1.FirstName = "Karen"
        Set tGateway1.LastName = "Thomas"
        Set tGateway1.MRN = "MRN013"
        
        // Save patient 1 and check status
        Set tSC1 = tGateway1.Save()
        If $$$ISERR(tSC1) {
            Set ^ClineDebug = ^ClineDebug _ "FAIL: Save patient 1 failed: " _ $System.Status.GetErrorText(tSC1) _ "; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "PASS: Save patient 1 (ID=" _ tGateway1.Id _ "); "
        }
        
        // Create patient 2
        Set tGateway2 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
        Set tGateway2.FirstName = "Larry"
        Set tGateway2.LastName = "Jackson"
        Set tGateway2.MRN = "MRN014"
        
        // Save patient 2 and check status
        Set tSC2 = tGateway2.Save()
        If $$$ISERR(tSC2) {
            Set ^ClineDebug = ^ClineDebug _ "FAIL: Save patient 2 failed: " _ $System.Status.GetErrorText(tSC2) _ "; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "PASS: Save patient 2 (ID=" _ tGateway2.Id _ "); "
        }
        
        // Create patient 3
        Set tGateway3 = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New()
        Set tGateway3.FirstName = "Mary"
        Set tGateway3.LastName = "White"
        Set tGateway3.MRN = "MRN015"
        
        // Save patient 3 and check status
        Set tSC3 = tGateway3.Save()
        If $$$ISERR(tSC3) {
            Set ^ClineDebug = ^ClineDebug _ "FAIL: Save patient 3 failed: " _ $System.Status.GetErrorText(tSC3) _ "; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "PASS: Save patient 3 (ID=" _ tGateway3.Id _ "); "
        }
        
        // Find all
        Set ^ClineDebug = ^ClineDebug _ "Calling FindAll(); "
        Set tList = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindAll()
        
        // Check if list is object
        If '$IsObject(tList) {
            Set ^ClineDebug = ^ClineDebug _ "FAIL: List object NOT returned (value='" _ tList _ "'); "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "PASS: List object returned; "
            
            // Check count
            Set tCount = tList.Count()
            If tCount '= 3 {
                Set ^ClineDebug = ^ClineDebug _ "FAIL: Expected 3 patients, got " _ tCount _ "; "
            } Else {
                Set ^ClineDebug = ^ClineDebug _ "PASS: All three patients found (count=" _ tCount _ "); "
            }
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.DisplayString() _ "; "
    }
    
    Quit ^ClineDebug
}

}
