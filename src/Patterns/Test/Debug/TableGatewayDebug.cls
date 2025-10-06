/// Debug helper for Table Data Gateway testing
Class Patterns.Test.Debug.TableGatewayDebug
{

/// Test Insert and FindById operations
ClassMethod TestInsertAndFind() As %String
{
    Set ^ClineDebug = ""
    
    Try {
        // Clear test data
        &sql(DELETE FROM Patterns_Examples_Clinical.Patient)
        Set ^ClineDebug = ^ClineDebug _ "Cleared test data; "
        
        // Create test patient data
        Set tPatient = {
            "FirstName": "Debug",
            "LastName": "Test",
            "MRN": "DEBUG001",
            "Status": "Active",
            "Department": "Test"
        }
        Set ^ClineDebug = ^ClineDebug _ "Created patient object; "
        
        // Insert patient
        Set tId = ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient)
        Set ^ClineDebug = ^ClineDebug _ "Insert returned ID: " _ tId _ "; "
        
        // Find by ID
        Set tFound = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindPatientById(tId)
        Set ^ClineDebug = ^ClineDebug _ "FindById returned; "
        
        // Check if object
        Set tIsObj = $IsObject(tFound)
        Set ^ClineDebug = ^ClineDebug _ "IsObject: " _ tIsObj _ "; "
        
        If tIsObj {
            // Try to access properties
            Set tFirstName = tFound.FirstName
            Set ^ClineDebug = ^ClineDebug _ "FirstName: " _ tFirstName _ "; "
            
            Set tLastName = tFound.LastName
            Set ^ClineDebug = ^ClineDebug _ "LastName: " _ tLastName _ "; "
            
            Set tMRN = tFound.MRN
            Set ^ClineDebug = ^ClineDebug _ "MRN: " _ tMRN _ "; "
        } Else {
            Set ^ClineDebug = ^ClineDebug _ "Returned value is not an object; Value: " _ tFound _ "; "
        }
        
        Set ^ClineDebug = ^ClineDebug _ "Test completed successfully; "
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.Name _ " - " _ ex.DisplayString() _ "; "
    }
    
    Quit ^ClineDebug
}

/// Test FindAll operation
ClassMethod TestFindAll() As %String
{
    Set ^ClineDebug = ""
    
    Try {
        // Clear and insert test data
        &sql(DELETE FROM Patterns_Examples_Clinical.Patient)
        
        Set tPatient1 = {"FirstName": "Test1", "LastName": "Patient1", "MRN": "MRN001", "Status": "Active", "Department": "D1"}
        Set tPatient2 = {"FirstName": "Test2", "LastName": "Patient2", "MRN": "MRN002", "Status": "Active", "Department": "D2"}
        
        Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient1)
        Do ##class(Patterns.Examples.Clinical.PatientDataGateway).InsertPatient(tPatient2)
        
        Set ^ClineDebug = ^ClineDebug _ "Inserted 2 patients; "
        
        // Find all
        Set tResults = ##class(Patterns.Examples.Clinical.PatientDataGateway).FindAllPatients()
        Set ^ClineDebug = ^ClineDebug _ "FindAll returned; "
        
        Set tIsObj = $IsObject(tResults)
        Set ^ClineDebug = ^ClineDebug _ "IsObject: " _ tIsObj _ "; "
        
        If tIsObj {
            Set tCount = tResults.Count()
            Set ^ClineDebug = ^ClineDebug _ "Count: " _ tCount _ "; "
            
            If tCount > 0 {
                Set tFirst = tResults.GetAt(1)
                Set ^ClineDebug = ^ClineDebug _ "First item IsObject: " _ $IsObject(tFirst) _ "; "
                
                If $IsObject(tFirst) {
                    Set tFirstName = tFirst.FirstName
                    Set ^ClineDebug = ^ClineDebug _ "First item FirstName: " _ tFirstName _ "; "
                }
            }
        }
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug _ "ERROR: " _ ex.Name _ " - " _ ex.DisplayString() _ "; "
    }
    
    Quit ^ClineDebug
}

}
