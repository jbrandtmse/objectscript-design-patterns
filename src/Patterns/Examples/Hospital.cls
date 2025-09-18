/// Hospital - Root composite in healthcare organizational hierarchy
/// <p>
/// Represents a hospital as the root of an organizational hierarchy.
/// A hospital can contain multiple departments, which in turn can
/// contain medical units or other sub-departments.
/// </p>
/// <example>
/// Set hospital = ##class(Patterns.Examples.Hospital).%New()
/// Set hospital.Name = "City General Hospital"
/// Set hospital.UnitCode = "CGH001"
/// Set hospital.Budget = 50000000
/// Set hospital.StaffCount = 100
/// 
/// Set cardiology = ##class(Patterns.Examples.Department).%New()
/// Set cardiology.Name = "Cardiology Department"
/// Do hospital.Add(cardiology)
/// 
/// Write "Total Budget: $", hospital.CalculateBudget()
/// Write "Total Staff: ", hospital.GetTotalStaffCount()
/// </example>
Class Patterns.Examples.Hospital Extends Patterns.Examples.OrganizationalUnit
{

/// Collection of departments within this hospital
Property Departments As %ListOfObjects [ Private ];

/// Hospital location/address
Property Location As %String;

/// Number of beds in the hospital
Property BedCount As %Integer;

/// Hospital accreditation status
Property AccreditationStatus As %String;

/// <p>
/// Constructor - Initialize the hospital
/// </p>
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..Departments = ##class(%ListOfObjects).%New()
        Set ..UnitType = "Hospital"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Add a department to this hospital
/// </p>
/// <param name="pComponent">Department to add</param>
/// <returns>%Status</returns>
Method Add(pComponent As Patterns.GoF.Structural.Component) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate it's a department or compatible unit
        If '$IsObject(pComponent) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid component")
            Quit
        }
        
        // Check for circular reference
        If pComponent = $this {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot add hospital to itself")
            Quit
        }
        
        // Add to departments collection
        Do ..Departments.Insert(pComponent)
        
        // Set parent reference if Component supports it
        Try {
            Set pComponent.Parent = $this
        }
        Catch {
            // Component may not have Parent property
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Remove a department from this hospital
/// </p>
/// <param name="pComponent">Department to remove</param>
/// <returns>%Status</returns>
Method Remove(pComponent As Patterns.GoF.Structural.Component) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tIndex = ""
        For i = 1:1:..Departments.Count() {
            If ..Departments.GetAt(i) = pComponent {
                Set tIndex = i
                Quit
            }
        }
        
        If tIndex '= "" {
            Do ..Departments.RemoveAt(tIndex)
            
            // Clear parent reference if Component supports it
            Try {
                Set pComponent.Parent = ""
            }
            Catch {
                // Component may not have Parent property
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Get a child department by index
/// </p>
/// <param name="pIndex">Index of the department</param>
/// <returns>Component at the specified index or empty string</returns>
Method GetChild(pIndex As %Integer) As Patterns.GoF.Structural.Component
{
    If (pIndex > 0) && (pIndex <= ..Departments.Count()) {
        Quit ..Departments.GetAt(pIndex)
    }
    Quit ""
}

/// <p>
/// Calculate total budget for hospital and all departments
/// </p>
/// <returns>Total budget amount</returns>
Method CalculateBudget() As %Numeric
{
    Set tTotal = ..Budget
    
    For i = 1:1:..Departments.Count() {
        Set tDept = ..Departments.GetAt(i)
        If $IsObject(tDept) {
            Set tTotal = tTotal + tDept.CalculateBudget()
        }
    }
    
    Quit tTotal
}

/// <p>
/// Get total staff count for hospital and all departments
/// </p>
/// <returns>Total staff count</returns>
Method GetTotalStaffCount() As %Integer
{
    Set tTotal = ..StaffCount
    
    For i = 1:1:..Departments.Count() {
        Set tDept = ..Departments.GetAt(i)
        If $IsObject(tDept) {
            Set tTotal = tTotal + tDept.GetTotalStaffCount()
        }
    }
    
    Quit tTotal
}

/// <p>
/// Get department by name
/// </p>
/// <param name="pName">Department name</param>
/// <returns>Department or empty string</returns>
Method GetDepartmentByName(pName As %String) As Patterns.Examples.OrganizationalUnit
{
    Set tResult = ""
    For i = 1:1:..Departments.Count() {
        Set tDept = ..Departments.GetAt(i)
        If $IsObject(tDept) && (tDept.Name = pName) {
            Set tResult = tDept
            Quit
        }
    }
    Quit tResult
}

/// <p>
/// Generate comprehensive hospital report
/// </p>
/// <param name="pIndent">Indentation level</param>
/// <returns>String report of hospital structure</returns>
Method GenerateReport(pIndent As %Integer = 0) As %String
{
    Set tIndentStr = ""
    For i = 1:1:pIndent {
        Set tIndentStr = tIndentStr _ "  "
    }
    
    Set tReport = tIndentStr _ "Hospital: " _ ..Name
    Set tReport = tReport _ " [Code: " _ ..UnitCode _ "]"
    Set tReport = tReport _ " [Location: " _ ..Location _ "]"
    Set tReport = tReport _ " [Beds: " _ ..BedCount _ "]"
    Set tReport = tReport _ " [Budget: $" _ $FNumber(..Budget, ",", 0) _ "]"
    Set tReport = tReport _ " [Direct Staff: " _ ..StaffCount _ "]"
    Set tReport = tReport _ " [Total Staff: " _ ..GetTotalStaffCount() _ "]"
    Set tReport = tReport _ " [Accreditation: " _ ..AccreditationStatus _ "]"
    
    // Add department reports
    For i = 1:1:..Departments.Count() {
        Set tDept = ..Departments.GetAt(i)
        If $IsObject(tDept) {
            Set tReport = tReport _ $Char(13,10) _ tDept.GenerateReport(pIndent + 1)
        }
    }
    
    Quit tReport
}

/// <p>
/// Get utilization statistics for the hospital
/// </p>
/// <returns>%Status with utilization metrics</returns>
Method GetUtilizationMetrics() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tTotalBudget = ..CalculateBudget()
        Set tTotalStaff = ..GetTotalStaffCount()
        
        If tTotalStaff > 0 {
            Set tBudgetPerStaff = tTotalBudget / tTotalStaff
        } Else {
            Set tBudgetPerStaff = 0
        }
        
        If ..BedCount > 0 {
            Set tBudgetPerBed = tTotalBudget / ..BedCount
            Set tStaffPerBed = tTotalStaff / ..BedCount
        } Else {
            Set tBudgetPerBed = 0
            Set tStaffPerBed = 0
        }
        
        // These metrics would be used for hospital management decisions
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Operation implementation for hospital
/// </p>
/// <returns>String describing the hospital operation</returns>
Method Operation() As %String
{
    Quit ..GenerateReport(0)
}

/// <p>
/// Check if this is a leaf node (hospitals are never leaves)
/// </p>
/// <returns>0 (false) - hospitals always have departments</returns>
Method IsLeaf() As %Boolean
{
    Quit 0
}

/// <p>
/// Find a unit by name within the hospital hierarchy
/// </p>
/// <param name="pName">Name of the unit to find</param>
/// <returns>OrganizationalUnit or empty string if not found</returns>
Method FindUnit(pName As %String) As Patterns.Examples.OrganizationalUnit
{
    Set tResult = ""
    
    // Check if this hospital matches
    If ..Name = pName {
        Set tResult = $this
        Quit tResult
    }
    
    // Search departments
    For i = 1:1:..Departments.Count() {
        Set tDept = ..Departments.GetAt(i)
        If $IsObject(tDept) {
            If tDept.Name = pName {
                Set tResult = tDept
                Quit
            }
            // If department has FindUnit method, search recursively
            Try {
                Set tFound = tDept.FindUnit(pName)
                If $IsObject(tFound) {
                    Set tResult = tFound
                    Quit
                }
            }
            Catch {
                // Department may not have FindUnit method
            }
        }
    }
    
    Quit tResult
}

}
