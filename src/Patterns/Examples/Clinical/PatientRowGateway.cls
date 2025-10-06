/// Healthcare Row Data Gateway Example - Patient Gateway
/// 
/// <p>Demonstrates Row Data Gateway pattern with one instance per patient row.
/// Each PatientRowGateway instance represents a single patient record in the database.</p>
/// 
/// <p>This class provides:</p>
/// <ul>
/// <li>Instance per patient row design</li>
/// <li>Property accessors for all patient fields</li>
/// <li>Save() method for insert/update operations</li>
/// <li>Delete() method to remove patient</li>
/// <li>Refresh() to reload patient data</li>
/// <li>FindById() to load by patient ID</li>
/// <li>FindByMRN() to load by medical record number</li>
/// <li>FindByLastName() to find multiple patients</li>
/// </ul>
Class Patterns.Examples.Clinical.PatientRowGateway Extends Patterns.PoEAA.DataSource.RowDataGateway
{

/// Patient first name
Property FirstName As %String;

/// Patient last name
Property LastName As %String;

/// Patient date of birth
Property DateOfBirth As %Date;

/// Patient gender (M/F/Other)
Property Gender As %String;

/// Current department assignment
Property Department As %String;

/// Patient status (Active/Inactive/Discharged)
Property Status As %String;

/// Medical Record Number (unique identifier)
Property MRN As %String;

/// Override property setter to track changes
Method FirstNameSet(pValue As %String) As %Status
{
    Set i%FirstName = pValue
    Do ..MarkDirty()
    Quit $$$OK
}

/// Override property setter to track changes
Method LastNameSet(pValue As %String) As %Status
{
    Set i%LastName = pValue
    Do ..MarkDirty()
    Quit $$$OK
}

/// Override property setter to track changes
Method DateOfBirthSet(pValue As %Date) As %Status
{
    Set i%DateOfBirth = pValue
    Do ..MarkDirty()
    Quit $$$OK
}

/// Override property setter to track changes
Method GenderSet(pValue As %String) As %Status
{
    Set i%Gender = pValue
    Do ..MarkDirty()
    Quit $$$OK
}

/// Override property setter to track changes
Method DepartmentSet(pValue As %String) As %Status
{
    Set i%Department = pValue
    Do ..MarkDirty()
    Quit $$$OK
}

/// Override property setter to track changes
Method StatusSet(pValue As %String) As %Status
{
    Set i%Status = pValue
    Do ..MarkDirty()
    Quit $$$OK
}

/// Override property setter to track changes
Method MRNSet(pValue As %String) As %Status
{
    Set i%MRN = pValue
    Do ..MarkDirty()
    Quit $$$OK
}

/// Load patient data from database by ID
/// 
/// <parameter name="pId">Patient ID to load</parameter>
/// <returns>%Status - OK or error</returns>
Method LoadFromDatabase(pId As %String) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Open persistent object by ID
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%OpenId(pId)
        
        If $IsObject(tPatient) {
            // Populate properties from persistent object
            Set i%FirstName = tPatient.FirstName
            Set i%LastName = tPatient.LastName
            Set i%DateOfBirth = tPatient.DateOfBirth
            Set i%Gender = tPatient.Gender
            Set i%Department = tPatient.Department
            Set i%Status = tPatient.Status
            Set i%MRN = tPatient.MRN
        } Else {
            // Patient not found
            Set tSC = $$$ERROR($$$GeneralError, "Patient not found: " _ pId)
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Insert new patient row to database
/// 
/// <returns>%Status - OK or error</returns>
Method InsertRow() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Validate required fields
        If (..FirstName = "") || (..LastName = "") || (..MRN = "") {
            Set tSC = $$$ERROR($$$GeneralError, "FirstName, LastName, and MRN are required")
            Quit
        }
        
        // Create new persistent object
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%New()
        
        // Set properties
        Set tPatient.FirstName = ..FirstName
        Set tPatient.LastName = ..LastName
        Set tPatient.DateOfBirth = ..DateOfBirth
        Set tPatient.Gender = ..Gender
        Set tPatient.Department = ..Department
        Set tPatient.Status = ..Status
        Set tPatient.MRN = ..MRN
        
        // Save to database
        Set tSC = tPatient.%Save()
        
        If $$$ISOK(tSC) {
            // Get the generated ID
            Set ..Id = tPatient.%Id()
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Update existing patient row in database
/// 
/// <returns>%Status - OK or error</returns>
Method UpdateRow() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Validate required fields
        If (..FirstName = "") || (..LastName = "") || (..MRN = "") {
            Set tSC = $$$ERROR($$$GeneralError, "FirstName, LastName, and MRN are required")
            Quit
        }
        
        // Open existing persistent object
        Set tPatient = ##class(Patterns.Examples.Clinical.Patient).%OpenId(..Id)
        
        If $IsObject(tPatient) {
            // Update properties
            Set tPatient.FirstName = ..FirstName
            Set tPatient.LastName = ..LastName
            Set tPatient.DateOfBirth = ..DateOfBirth
            Set tPatient.Gender = ..Gender
            Set tPatient.Department = ..Department
            Set tPatient.Status = ..Status
            Set tPatient.MRN = ..MRN
            
            // Save changes
            Set tSC = tPatient.%Save()
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "Patient not found for update: " _ ..Id)
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Delete patient row from database
/// 
/// <returns>%Status - OK or error</returns>
Method DeleteRow() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Delete by ID
        Set tSC = ##class(Patterns.Examples.Clinical.Patient).%DeleteId(..Id)
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Find patient by ID (returns gateway instance or empty string)
/// 
/// <parameter name="pId">Patient ID</parameter>
/// <returns>PatientRowGateway instance or empty string if not found</returns>
ClassMethod FindById(pId As %String) As Patterns.Examples.Clinical.PatientRowGateway
{
    Set tGateway = ""
    
    Try {
        Set tGateway = ..%New(pId)
        If tGateway.IsNew() {
            // Patient not found
            Set tGateway = ""
        }
    } Catch ex {
        // Error occurred, return empty
        Set tGateway = ""
    }
    
    Quit tGateway
}

/// Find patient by Medical Record Number
/// 
/// <parameter name="pMRN">Medical Record Number</parameter>
/// <returns>PatientRowGateway instance or empty string if not found</returns>
ClassMethod FindByMRN(pMRN As %String) As Patterns.Examples.Clinical.PatientRowGateway
{
    Set tGateway = ""
    
    Try {
        // Use SQL to find patient by MRN (indexed)
        Set tRS = ##class(%SQL.Statement).%ExecDirect(, "SELECT ID FROM Patterns_Examples_Clinical.Patient WHERE MRN = ?", pMRN)
        
        If tRS.%Next() {
            Set tId = tRS.%Get("ID")
            // Found patient, create gateway
            Set tGateway = ..%New(tId)
        }
    } Catch ex {
        // Error occurred, return empty
        Set tGateway = ""
    }
    
    Quit tGateway
}

/// Find patients by last name (returns list of gateway instances)
/// 
/// <parameter name="pLastName">Last name to search for</parameter>
/// <returns>%ListOfObjects containing PatientRowGateway instances</returns>
ClassMethod FindByLastName(pLastName As %String) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Use SQL to find patients by last name (indexed)
        Set tRS = ##class(%SQL.Statement).%ExecDirect(, "SELECT ID FROM Patterns_Examples_Clinical.Patient WHERE LastName = ? ORDER BY FirstName", pLastName)
        
        While tRS.%Next() {
            Set tId = tRS.%Get("ID")
            
            // Create gateway for each patient
            Set tGateway = ..%New(tId)
            If 'tGateway.IsNew() {
                Do tList.Insert(tGateway)
            }
        }
    } Catch ex {
        // Error occurred, return empty list
    }
    
    Quit tList
}

/// Find all patients (returns list of gateway instances)
/// 
/// <returns>%ListOfObjects containing all PatientRowGateway instances</returns>
ClassMethod FindAll() As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Iterate through all patients using %OpenId with extent
        Set tRS = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM Patterns_Examples_Clinical.Patient ORDER BY LastName, FirstName")
        
        While tRS.%Next() {
            Set tId = tRS.%Get("ID")
            
            // Create gateway for each patient
            Set tGateway = ..%New(tId)
            If 'tGateway.IsNew() {
                Do tList.Insert(tGateway)
            }
        }
    } Catch ex {
        // Error occurred, return empty list
    }
    
    Quit tList
}

}
