Class Patterns.Test.Debug.GatewayDebug
{

ClassMethod TestGatewayLoad() As %Status
{
    Set ^ClineDebug = ""
    
    Try {
        // Clean up
        Do ##class(Patterns.Examples.Clinical.Patient).%DeleteExtent()
        Set ^ClineDebug = ^ClineDebug _ "Cleaned up patients; "
        
        // Create patient
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tPatient.FirstName = "Debug"
        Set tPatient.LastName = "Test"
        Set tPatient.MRN = "DEBUG001"
        Set tPatient.Gender = "M"
        Set tPatient.Status = "Active"
        Set tSC = tPatient.%Save()
        Set ^ClineDebug = ^ClineDebug _ "Patient saved with ID: " _ tPatient.%Id() _ "; "
        
        Set tId = tPatient.%Id()
        
        // Test gateway creation
        Set tGateway = ##class(Patterns.Examples.Clinical.PatientRowGateway).%New(tId)
        Set ^ClineDebug = ^ClineDebug _ "Gateway created; IsObject: " _ $IsObject(tGateway) _ "; "
        
        If $IsObject(tGateway) {
            Set ^ClineDebug = ^ClineDebug _ "IsNew: " _ tGateway.IsNew() _ "; "
            Set ^ClineDebug = ^ClineDebug _ "FirstName: " _ tGateway.FirstName _ "; "
            Set ^ClineDebug = ^ClineDebug _ "LastName: " _ tGateway.LastName _ "; "
            Set ^ClineDebug = ^ClineDebug _ "MRN: " _ tGateway.MRN _ "; "
        }
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.DisplayString() _ "; "
    }
    
    Quit $$$OK
}

ClassMethod TestFindAll() As %Status
{
    Set ^ClineDebug = ""
    
    Try {
        // Clean up
        Do ##class(Patterns.Examples.Clinical.Patient).%DeleteExtent()
        Set ^ClineDebug = ^ClineDebug _ "Cleaned up patients; "
        
        // Create 3 patients
        Set tP1 = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tP1.FirstName = "Karen"
        Set tP1.LastName = "Thomas"
        Set tP1.MRN = "MRN013"
        Do tP1.%Save()
        Set ^ClineDebug = ^ClineDebug _ "Patient 1 saved; "
        
        Set tP2 = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tP2.FirstName = "Larry"
        Set tP2.LastName = "Jackson"
        Set tP2.MRN = "MRN014"
        Do tP2.%Save()
        Set ^ClineDebug = ^ClineDebug _ "Patient 2 saved; "
        
        Set tP3 = ##class(Patterns.Examples.Clinical.Patient).%New()
        Set tP3.FirstName = "Mary"
        Set tP3.LastName = "White"
        Set tP3.MRN = "MRN015"
        Do tP3.%Save()
        Set ^ClineDebug = ^ClineDebug _ "Patient 3 saved; "
        
        // Test FindAll
        Set tList = ##class(Patterns.Examples.Clinical.PatientRowGateway).FindAll()
        Set ^ClineDebug = ^ClineDebug _ "FindAll returned; IsObject: " _ $IsObject(tList) _ "; "
        
        If $IsObject(tList) {
            Set ^ClineDebug = ^ClineDebug _ "Count: " _ tList.Count() _ "; "
            
            For i=1:1:tList.Count() {
                Set tGW = tList.GetAt(i)
                If $IsObject(tGW) {
                    Set ^ClineDebug = ^ClineDebug _ "Item " _ i _ ": " _ tGW.FirstName _ " " _ tGW.LastName _ "; "
                } Else {
                    Set ^ClineDebug = ^ClineDebug _ "Item " _ i _ " is not an object; "
                }
            }
        }
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.DisplayString() _ "; "
    }
    
    Quit $$$OK
}

}
