/// MedicalUnit - Leaf node in healthcare organizational hierarchy
/// <p>
/// Represents a medical unit (e.g., ICU, Emergency Room, Laboratory) which is
/// the smallest organizational unit in a healthcare facility. Medical units
/// do not contain other units - they are leaf nodes in the composite pattern.
/// </p>
/// <example>
/// Set unit = ##class(Patterns.Examples.MedicalUnit).%New()
/// Set unit.Name = "Cardiac ICU"
/// Set unit.UnitCode = "CICU001"
/// Set unit.RoomNumbers = "201-210"
/// Set unit.UnitCategory = "Critical Care"
/// Set unit.Budget = 1500000
/// Set unit.StaffCount = 30
/// Set unit.BedCapacity = 10
/// 
/// Write "Unit Budget: $", unit.CalculateBudget()
/// Write "Staff Count: ", unit.GetTotalStaffCount()
/// Write "Is Leaf: ", unit.IsLeaf()  // Returns 1 (true)
/// </example>
Class Patterns.Examples.MedicalUnit Extends Patterns.Examples.OrganizationalUnit
{

/// Medical unit category (e.g., "Critical Care", "Emergency", "Diagnostic")
Property UnitCategory As %String;

/// Room numbers or locations
Property RoomNumbers As %String;

/// Bed capacity for patient care units
Property BedCapacity As %Integer;

/// Current occupancy
Property CurrentOccupancy As %Integer;

/// Equipment value
Property EquipmentValue As %Numeric;

/// <p>
/// Constructor - Initialize the medical unit
/// </p>
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..UnitType = "MedicalUnit"
        Set ..BedCapacity = 0
        Set ..CurrentOccupancy = 0
        Set ..EquipmentValue = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Add operation - Not supported for leaf nodes
/// </p>
/// <param name="pComponent">Component to add (not applicable)</param>
/// <returns>Error status - leaves cannot contain children</returns>
Method Add(pComponent As Patterns.GoF.Structural.Component) As %Status
{
    Quit $$$ERROR($$$GeneralError, "Cannot add components to a medical unit (leaf node)")
}

/// <p>
/// Remove operation - Not supported for leaf nodes
/// </p>
/// <param name="pComponent">Component to remove (not applicable)</param>
/// <returns>Error status - leaves cannot contain children</returns>
Method Remove(pComponent As Patterns.GoF.Structural.Component) As %Status
{
    Quit $$$ERROR($$$GeneralError, "Cannot remove components from a medical unit (leaf node)")
}

/// <p>
/// Get child operation - Not supported for leaf nodes
/// </p>
/// <param name="pIndex">Index of child (not applicable)</param>
/// <returns>Empty string - leaves have no children</returns>
Method GetChild(pIndex As %Integer) As Patterns.GoF.Structural.Component
{
    Quit ""
}

/// <p>
/// Calculate budget for this medical unit
/// </p>
/// <returns>Unit's budget amount</returns>
Method CalculateBudget() As %Numeric
{
    // Leaf nodes return their own budget
    Quit ..Budget
}

/// <p>
/// Get staff count for this medical unit
/// </p>
/// <returns>Unit's staff count</returns>
Method GetTotalStaffCount() As %Integer
{
    // Leaf nodes return their own staff count
    Quit ..StaffCount
}

/// <p>
/// Generate unit report
/// </p>
/// <param name="pIndent">Indentation level</param>
/// <returns>String report of unit details</returns>
Method GenerateReport(pIndent As %Integer = 0) As %String
{
    Set tIndentStr = ""
    For i = 1:1:pIndent {
        Set tIndentStr = tIndentStr _ "  "
    }
    
    Set tReport = tIndentStr _ "Medical Unit: " _ ..Name
    Set tReport = tReport _ " [Code: " _ ..UnitCode _ "]"
    Set tReport = tReport _ " [Category: " _ ..UnitCategory _ "]"
    Set tReport = tReport _ " [Rooms: " _ ..RoomNumbers _ "]"
    Set tReport = tReport _ " [Budget: $" _ $FNumber(..Budget, ",", 0) _ "]"
    Set tReport = tReport _ " [Staff: " _ ..StaffCount _ "]"
    Set tReport = tReport _ " [Beds: " _ ..BedCapacity _ "]"
    Set tReport = tReport _ " [Occupancy: " _ ..CurrentOccupancy _ "/" _ ..BedCapacity _ "]"
    Set tReport = tReport _ " [Equipment Value: $" _ $FNumber(..EquipmentValue, ",", 0) _ "]"
    
    Quit tReport
}

/// <p>
/// Get occupancy rate
/// </p>
/// <returns>Occupancy percentage (0-100)</returns>
Method GetOccupancyRate() As %Numeric
{
    If ..BedCapacity = 0 {
        Quit 0
    }
    Quit (..CurrentOccupancy / ..BedCapacity) * 100
}

/// <p>
/// Update occupancy
/// </p>
/// <param name="pNewOccupancy">New occupancy count</param>
/// <returns>%Status</returns>
Method UpdateOccupancy(pNewOccupancy As %Integer) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pNewOccupancy < 0 {
            Set tSC = $$$ERROR($$$GeneralError, "Occupancy cannot be negative")
            Quit
        }
        If pNewOccupancy > ..BedCapacity {
            Set tSC = $$$ERROR($$$GeneralError, "Occupancy cannot exceed bed capacity")
            Quit
        }
        Set ..CurrentOccupancy = pNewOccupancy
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Get unit efficiency metrics
/// </p>
/// <returns>%Status with efficiency calculations</returns>
Method GetEfficiencyMetrics() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Calculate various efficiency metrics
        If ..StaffCount > 0 {
            Set tBudgetPerStaff = ..Budget / ..StaffCount
        } Else {
            Set tBudgetPerStaff = 0
        }
        
        If ..BedCapacity > 0 {
            Set tStaffPerBed = ..StaffCount / ..BedCapacity
            Set tBudgetPerBed = ..Budget / ..BedCapacity
            Set tOccupancyRate = ..GetOccupancyRate()
        } Else {
            Set tStaffPerBed = 0
            Set tBudgetPerBed = 0
            Set tOccupancyRate = 0
        }
        
        // These metrics would be used for unit management
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Check if unit requires urgent attention
/// </p>
/// <returns>%Boolean - 1 if attention needed, 0 otherwise</returns>
Method RequiresAttention() As %Boolean
{
    // High occupancy rate
    If ..GetOccupancyRate() > 95 {
        Quit 1
    }
    
    // Very low occupancy (underutilized)
    If (..BedCapacity > 0) && (..GetOccupancyRate() < 20) {
        Quit 1
    }
    
    // Understaffed (less than 2 staff per bed for critical care)
    If (..UnitCategory = "Critical Care") && (..BedCapacity > 0) {
        If (..StaffCount / ..BedCapacity) < 2 {
            Quit 1
        }
    }
    
    Quit 0
}

/// <p>
/// Operation implementation for medical unit
/// </p>
/// <returns>String describing the unit operation</returns>
Method Operation() As %String
{
    Quit ..GenerateReport(0)
}

/// <p>
/// Check if this is a leaf node (medical units are always leaves)
/// </p>
/// <returns>1 (true) - medical units cannot contain other units</returns>
Method IsLeaf() As %Boolean
{
    Quit 1
}

/// <p>
/// Get unit status summary
/// </p>
/// <returns>String with unit status</returns>
Method GetStatusSummary() As %String
{
    Set tStatus = "Unit: " _ ..Name _ " ("_ ..UnitCode _ ")"
    Set tStatus = tStatus _ " - Category: " _ ..UnitCategory
    Set tStatus = tStatus _ " - Occupancy: " _ ..CurrentOccupancy _ "/" _ ..BedCapacity
    Set tStatus = tStatus _ " (" _ $FNumber(..GetOccupancyRate(), "", 1) _ "%)"
    
    If ..RequiresAttention() {
        Set tStatus = tStatus _ " [ATTENTION REQUIRED]"
    }
    
    Quit tStatus
}

}
