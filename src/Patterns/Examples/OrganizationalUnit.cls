/// Healthcare Organizational Unit - Base class for hospital hierarchy
/// <p>
/// Abstract base class for representing organizational units in a hospital
/// hierarchy using the Composite pattern. Extends the Component class to
/// provide healthcare-specific operations like budget calculation and
/// staff counting.
/// </p>
/// <example>
/// Set hospital = ##class(Patterns.Examples.Hospital).%New()
/// Set hospital.Name = "General Hospital"
/// Set hospital.Budget = 10000000
/// Set dept = ##class(Patterns.Examples.Department).%New()
/// Set dept.Name = "Cardiology"
/// Set dept.Budget = 2000000
/// Do hospital.Add(dept)
/// Write hospital.CalculateBudget()
/// </example>
Class Patterns.Examples.OrganizationalUnit Extends Patterns.GoF.Structural.Component [ Abstract ]
{

/// Annual budget for this organizational unit
Property Budget As %Numeric;

/// Number of staff directly assigned to this unit
Property StaffCount As %Integer;

/// Unit type (Hospital, Department, MedicalUnit, etc.)
Property UnitType As %String;

/// Unit code for identification in the healthcare system
Property UnitCode As %String;

/// <p>
/// Calculates the total budget for this unit and all sub-units.
/// Abstract method to be implemented by concrete classes.
/// </p>
/// <returns>Total budget amount</returns>
Method CalculateBudget() As %Numeric [ Abstract ]
{
    Quit 0
}

/// <p>
/// Gets the total staff count for this unit and all sub-units.
/// Abstract method to be implemented by concrete classes.
/// </p>
/// <returns>Total staff count</returns>
Method GetTotalStaffCount() As %Integer [ Abstract ]
{
    Quit 0
}

/// <p>
/// Finds a unit by its code in the hierarchy.
/// </p>
/// <param name="pCode">Unit code to search for</param>
/// <returns>OrganizationalUnit with matching code or null</returns>
Method FindUnitByCode(pCode As %String) As OrganizationalUnit
{
    // Check self
    If ..UnitCode = pCode {
        Quit $this
    }
    
    // Search children if this is a composite
    Set tResult = ""
    Set tIndex = 1
    Set tChild = ..GetChild(tIndex)
    While tChild '= "" {
        Set tFound = tChild.FindUnitByCode(pCode)
        If tFound '= "" {
            Set tResult = tFound
            Quit
        }
        Set tIndex = tIndex + 1
        Set tChild = ..GetChild(tIndex)
    }
    
    Quit tResult
}

/// <p>
/// Generates a report of the organizational structure.
/// </p>
/// <param name="pIndent">Indentation level for display</param>
/// <returns>String representation of the structure</returns>
Method GenerateReport(pIndent As %Integer = 0) As %String
{
    Set tIndentStr = ""
    For i = 1:1:pIndent {
        Set tIndentStr = tIndentStr _ "  "
    }
    
    Set tReport = tIndentStr _ ..UnitType _ ": " _ ..Name
    Set tReport = tReport _ " [Code: " _ ..UnitCode _ "]"
    Set tReport = tReport _ " [Budget: $" _ $FNumber(..Budget, ",", 0) _ "]"
    Set tReport = tReport _ " [Staff: " _ ..StaffCount _ "]"
    
    Quit tReport
}

/// <p>
/// Operation implementation for organizational units.
/// </p>
/// <returns>String describing the operation</returns>
Method Operation() As %String
{
    Quit ..GenerateReport()
}

/// <p>
/// Gets utilization statistics for this unit.
/// </p>
/// <returns>%Status with statistics</returns>
Method GetUtilization() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Calculate budget per staff member
        If ..GetTotalStaffCount() > 0 {
            Set tBudgetPerStaff = ..CalculateBudget() / ..GetTotalStaffCount()
        } Else {
            Set tBudgetPerStaff = 0
        }
        
        // This would normally include more complex metrics
        // For demonstration, we'll keep it simple
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Validates the organizational unit data.
/// </p>
/// <returns>%Status indicating if the unit is valid</returns>
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    If ..Name = "" {
        Quit $$$ERROR($$$GeneralError, "Unit name cannot be empty")
    }
    
    If ..UnitCode = "" {
        Quit $$$ERROR($$$GeneralError, "Unit code cannot be empty")
    }
    
    If ..Budget < 0 {
        Quit $$$ERROR($$$GeneralError, "Budget cannot be negative")
    }
    
    If ..StaffCount < 0 {
        Quit $$$ERROR($$$GeneralError, "Staff count cannot be negative")
    }
    
    Quit tSC
}

}
