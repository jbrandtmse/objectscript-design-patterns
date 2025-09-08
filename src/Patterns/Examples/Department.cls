/// Department - Intermediate composite in healthcare organizational hierarchy
/// <p>
/// Represents a department within a hospital. A department can contain
/// medical units (leaf nodes) or sub-departments (other composites).
/// </p>
/// <example>
/// Set dept = ##class(Patterns.Examples.Department).%New()
/// Set dept.Name = "Cardiology Department"
/// Set dept.UnitCode = "CARD001"
/// Set dept.Specialization = "Cardiovascular Medicine"
/// Set dept.Budget = 5000000
/// Set dept.StaffCount = 50
/// 
/// Set icu = ##class(Patterns.Examples.MedicalUnit).%New()
/// Set icu.Name = "Cardiac ICU"
/// Do dept.Add(icu)
/// 
/// Write "Department Budget: $", dept.CalculateBudget()
/// </example>
Class Patterns.Examples.Department Extends Patterns.Examples.OrganizationalUnit
{

/// Collection of sub-units (medical units or sub-departments)
Property SubUnits As %ListOfObjects [ Private ];

/// Department specialization
Property Specialization As %String;

/// Department head/director name
Property DepartmentHead As %String;

/// Operating hours (24/7, Business Hours, etc.)
Property OperatingHours As %String;

/// <p>
/// Constructor - Initialize the department
/// </p>
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..SubUnits = ##class(%ListOfObjects).%New()
        Set ..UnitType = "Department"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Add a sub-unit to this department
/// </p>
/// <param name="pComponent">Medical unit or sub-department to add</param>
/// <returns>%Status</returns>
Method Add(pComponent As Patterns.GoF.Structural.Component) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate component
        If '$IsObject(pComponent) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid component")
            Quit
        }
        
        // Check for circular reference
        If pComponent = $this {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot add department to itself")
            Quit
        }
        
        // Check if it would create a cycle
        Set tParent = ..Parent
        Set tCycleError = ""
        While $IsObject(tParent) {
            If tParent = pComponent {
                Set tCycleError = $$$ERROR($$$GeneralError, "Adding component would create a cycle")
                Quit
            }
            Try {
                Set tParent = tParent.Parent
            }
            Catch {
                Set tParent = ""
            }
        }
        
        // If cycle detected, return error
        If tCycleError '= "" {
            Set tSC = tCycleError
            Quit
        }
        
        // Add to sub-units collection
        Do ..SubUnits.Insert(pComponent)
        
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
/// Remove a sub-unit from this department
/// </p>
/// <param name="pComponent">Sub-unit to remove</param>
/// <returns>%Status</returns>
Method Remove(pComponent As Patterns.GoF.Structural.Component) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tIndex = ""
        For i = 1:1:..SubUnits.Count() {
            If ..SubUnits.GetAt(i) = pComponent {
                Set tIndex = i
                Quit
            }
        }
        
        If tIndex '= "" {
            Do ..SubUnits.RemoveAt(tIndex)
            
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
/// Get a child sub-unit by index
/// </p>
/// <param name="pIndex">Index of the sub-unit</param>
/// <returns>Component at the specified index or empty string</returns>
Method GetChild(pIndex As %Integer) As Patterns.GoF.Structural.Component
{
    If (pIndex > 0) && (pIndex <= ..SubUnits.Count()) {
        Quit ..SubUnits.GetAt(pIndex)
    }
    Quit ""
}

/// <p>
/// Calculate total budget for department and all sub-units
/// </p>
/// <returns>Total budget amount</returns>
Method CalculateBudget() As %Numeric
{
    Set tTotal = ..Budget
    
    For i = 1:1:..SubUnits.Count() {
        Set tUnit = ..SubUnits.GetAt(i)
        If $IsObject(tUnit) {
            Set tTotal = tTotal + tUnit.CalculateBudget()
        }
    }
    
    Quit tTotal
}

/// <p>
/// Get total staff count for department and all sub-units
/// </p>
/// <returns>Total staff count</returns>
Method GetTotalStaffCount() As %Integer
{
    Set tTotal = ..StaffCount
    
    For i = 1:1:..SubUnits.Count() {
        Set tUnit = ..SubUnits.GetAt(i)
        If $IsObject(tUnit) {
            Set tTotal = tTotal + tUnit.GetTotalStaffCount()
        }
    }
    
    Quit tTotal
}

/// <p>
/// Get all medical units (leaves) under this department
/// </p>
/// <returns>%ListOfObjects containing all medical units</returns>
Method GetAllMedicalUnits() As %ListOfObjects
{
    Set tUnits = ##class(%ListOfObjects).%New()
    
    For i = 1:1:..SubUnits.Count() {
        Set tUnit = ..SubUnits.GetAt(i)
        If $IsObject(tUnit) {
            // If it's a leaf (MedicalUnit), add it
            If tUnit.IsLeaf() {
                Do tUnits.Insert(tUnit)
            } Else {
                // If it's another department, get its medical units
                Try {
                    Set tSubUnits = tUnit.GetAllMedicalUnits()
                    For j = 1:1:tSubUnits.Count() {
                        Do tUnits.Insert(tSubUnits.GetAt(j))
                    }
                }
                Catch {
                    // Sub-unit may not have GetAllMedicalUnits method
                }
            }
        }
    }
    
    Quit tUnits
}

/// <p>
/// Generate department report
/// </p>
/// <param name="pIndent">Indentation level</param>
/// <returns>String report of department structure</returns>
Method GenerateReport(pIndent As %Integer = 0) As %String
{
    Set tIndentStr = ""
    For i = 1:1:pIndent {
        Set tIndentStr = tIndentStr _ "  "
    }
    
    Set tReport = tIndentStr _ "Department: " _ ..Name
    Set tReport = tReport _ " [Code: " _ ..UnitCode _ "]"
    Set tReport = tReport _ " [Specialization: " _ ..Specialization _ "]"
    Set tReport = tReport _ " [Head: " _ ..DepartmentHead _ "]"
    Set tReport = tReport _ " [Hours: " _ ..OperatingHours _ "]"
    Set tReport = tReport _ " [Budget: $" _ $FNumber(..Budget, ",", 0) _ "]"
    Set tReport = tReport _ " [Direct Staff: " _ ..StaffCount _ "]"
    Set tReport = tReport _ " [Total Staff: " _ ..GetTotalStaffCount() _ "]"
    
    // Add sub-unit reports
    For i = 1:1:..SubUnits.Count() {
        Set tUnit = ..SubUnits.GetAt(i)
        If $IsObject(tUnit) {
            Set tReport = tReport _ $Char(13,10) _ tUnit.GenerateReport(pIndent + 1)
        }
    }
    
    Quit tReport
}

/// <p>
/// Get department efficiency metrics
/// </p>
/// <returns>%Status with efficiency calculations</returns>
Method GetEfficiencyMetrics() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tTotalBudget = ..CalculateBudget()
        Set tTotalStaff = ..GetTotalStaffCount()
        Set tMedicalUnits = ..GetAllMedicalUnits()
        Set tUnitCount = tMedicalUnits.Count()
        
        If tTotalStaff > 0 {
            Set tBudgetPerStaff = tTotalBudget / tTotalStaff
        } Else {
            Set tBudgetPerStaff = 0
        }
        
        If tUnitCount > 0 {
            Set tStaffPerUnit = tTotalStaff / tUnitCount
            Set tBudgetPerUnit = tTotalBudget / tUnitCount
        } Else {
            Set tStaffPerUnit = 0
            Set tBudgetPerUnit = 0
        }
        
        // These metrics would be used for department management
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Operation implementation for department
/// </p>
/// <returns>String describing the department operation</returns>
Method Operation() As %String
{
    Quit ..GenerateReport(0)
}

/// <p>
/// Check if this is a leaf node (departments are not leaves)
/// </p>
/// <returns>0 (false) - departments contain sub-units</returns>
Method IsLeaf() As %Boolean
{
    Quit 0
}

}
