Class Patterns.Test.DebugHelper
{

ClassMethod TestPersistentPatient() As %String
{
    Set ^ClineDebug = ""
    Try {
        // Create patient
        Set tPatient = ##class(Patterns.Examples.Clinical.PersistentPatient).%New()
        Set tPatient.MedicalRecordNumber = "12345678"
        Set tPatient.FullName = "Debug Test"
        Set tPatient.DateOfBirth = 60000
        Set tSC = tPatient.%Save()
        Set ^ClineDebug = ^ClineDebug_"Save Status: "_$SYSTEM.Status.GetOneStatusText(tSC)_"; "
        Set ^ClineDebug = ^ClineDebug_"Patient ID: "_tPatient.%Id()_"; "
        
        // Try to find via SQL
        &sql(SELECT COUNT(*) INTO :tCount FROM SQLUser.PersPatient)
        Set ^ClineDebug = ^ClineDebug_"SQL Count: "_tCount_"; SQLCODE: "_SQLCODE_"; "
        
        // Try FindById
        Set tFound = ##class(Patterns.Examples.Clinical.PatientTableModule).FindById(tPatient.%Id())
        Set ^ClineDebug = ^ClineDebug_"FindById Result: "_$IsObject(tFound)_"; "
        
        // Cleanup
        Do ##class(Patterns.Examples.Clinical.PersistentPatient).%DeleteId(tPatient.%Id())
        
    } Catch ex {
        Set ^ClineDebug = ^ClineDebug_"ERROR: "_ex.DisplayString()
    }
    
    Quit ^ClineDebug
}

ClassMethod FindPatientTables() As %String
{
    Set tResult = ""
    Try {
        // Query for tables containing "Patient" in any schema
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSQL = "SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%Patient%'"
        Set tSC = tStatement.%Prepare(tSQL)
        If $$$ISERR(tSC) {
            Set tResult = "Prepare failed: "_$SYSTEM.Status.GetOneStatusText(tSC)
            Quit
        }
        
        Set tRS = tStatement.%Execute()
        While tRS.%Next() {
            Set tResult = tResult_tRS.%Get("TABLE_SCHEMA")_"."_tRS.%Get("TABLE_NAME")_", "
        }
        
        If tResult = "" {
            Set tResult = "No Patient tables found in any schema"
        }
        
    } Catch ex {
        Set tResult = "ERROR: "_ex.DisplayString()
    }
    
    Quit tResult
}

}
