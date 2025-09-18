/// Unit tests for Gang of Four Composite Pattern implementation
/// Tests Component, Leaf, Composite classes and healthcare hierarchy
Class Patterns.Test.Unit.GoF.Structural.CompositeTest Extends %UnitTest.TestCase
{

/// Test leaf operations and error handling
Method TestLeafOperations()
{
    // Create a leaf node
    Set tLeaf = ##class(Patterns.GoF.Structural.Leaf).%New()
    Set tLeaf.Name = "TestLeaf"
    
    // Test Operation method
    Set tResult = tLeaf.Operation()
    Do $$$AssertTrue(tResult [ "Leaf TestLeaf", "Leaf operation returns expected string")
    
    // Test that leaf nodes cannot have children
    Set tChild = ##class(Patterns.GoF.Structural.Leaf).%New()
    Set tChild.Name = "ChildLeaf"
    
    // Test Add method returns error
    Set tSC = tLeaf.Add(tChild)
    Do $$$AssertStatusNotOK(tSC, "Leaf Add() method returns error status")
    
    // Test Remove method returns error
    Set tSC = tLeaf.Remove(tChild)
    Do $$$AssertStatusNotOK(tSC, "Leaf Remove() method returns error status")
    
    // Test GetChild returns null
    Set tRetrieved = tLeaf.GetChild(1)
    Do $$$AssertEquals(tRetrieved, "", "Leaf GetChild() returns empty string")
    
    // Test IsLeaf property
    Do $$$AssertTrue(tLeaf.IsLeaf(), "Leaf IsLeaf() returns true")
    
    Quit $$$OK
}

/// Test composite add/remove/get operations
Method TestCompositeOperations()
{
    // Create composite nodes
    Set tRoot = ##class(Patterns.GoF.Structural.Composite).%New()
    Set tRoot.Name = "RootComposite"
    
    Set tChild1 = ##class(Patterns.GoF.Structural.Leaf).%New()
    Set tChild1.Name = "Child1"
    
    Set tChild2 = ##class(Patterns.GoF.Structural.Leaf).%New()
    Set tChild2.Name = "Child2"
    
    Set tSubComposite = ##class(Patterns.GoF.Structural.Composite).%New()
    Set tSubComposite.Name = "SubComposite"
    
    // Test Add operations
    Set tSC = tRoot.Add(tChild1)
    Do $$$AssertStatusOK(tSC, "Add first child succeeds")
    
    Set tSC = tRoot.Add(tChild2)
    Do $$$AssertStatusOK(tSC, "Add second child succeeds")
    
    Set tSC = tRoot.Add(tSubComposite)
    Do $$$AssertStatusOK(tSC, "Add sub-composite succeeds")
    
    // Verify children count using GetChildCount method
    Do $$$AssertEquals(tRoot.GetChildCount(), 3, "Composite has 3 children")
    
    // Test GetChild operations
    Set tRetrieved = tRoot.GetChild(1)
    Do $$$AssertEquals(tRetrieved.Name, "Child1", "GetChild(1) returns first child")
    
    Set tRetrieved = tRoot.GetChild(2)
    Do $$$AssertEquals(tRetrieved.Name, "Child2", "GetChild(2) returns second child")
    
    Set tRetrieved = tRoot.GetChild(3)
    Do $$$AssertEquals(tRetrieved.Name, "SubComposite", "GetChild(3) returns sub-composite")
    
    // Test Remove operation
    Set tSC = tRoot.Remove(tChild2)
    Do $$$AssertStatusOK(tSC, "Remove child succeeds")
    Do $$$AssertEquals(tRoot.GetChildCount(), 2, "Composite has 2 children after removal")
    
    // Test Operation method cascades
    Set tResult = tRoot.Operation()
    Do $$$AssertTrue(tResult [ "Composite", "Composite operation includes self")
    Do $$$AssertTrue(tResult [ "Child1", "Composite operation includes children")
    
    // Test IsLeaf property
    Do $$$AssertTrue('tRoot.IsLeaf(), "Composite IsLeaf() returns false")
    
    Quit $$$OK
}

/// Test tree traversal algorithms
Method TestTreeTraversals()
{
    // Build test tree
    Set tRoot = ##class(Patterns.GoF.Structural.Composite).%New()
    Set tRoot.Name = "A"
    
    Set tB = ##class(Patterns.GoF.Structural.Composite).%New()
    Set tB.Name = "B"
    
    Set tC = ##class(Patterns.GoF.Structural.Composite).%New()
    Set tC.Name = "C"
    
    Set tD = ##class(Patterns.GoF.Structural.Leaf).%New()
    Set tD.Name = "D"
    
    Set tE = ##class(Patterns.GoF.Structural.Leaf).%New()
    Set tE.Name = "E"
    
    Set tF = ##class(Patterns.GoF.Structural.Leaf).%New()
    Set tF.Name = "F"
    
    // Build tree structure: A(B(D,E),C(F))
    Do tRoot.Add(tB)
    Do tRoot.Add(tC)
    Do tB.Add(tD)
    Do tB.Add(tE)
    Do tC.Add(tF)
    
    // Test pre-order traversal
    Set tPreOrder = tRoot.TraversePreOrder()
    Do $$$AssertEquals(tPreOrder, "A,B,D,E,C,F", "Pre-order traversal is correct")
    
    // Test post-order traversal
    Set tPostOrder = tRoot.TraversePostOrder()
    Do $$$AssertEquals(tPostOrder, "D,E,B,F,C,A", "Post-order traversal is correct")
    
    // Test level-order traversal
    Set tLevelOrder = tRoot.TraverseLevelOrder()
    Do $$$AssertEquals(tLevelOrder, "A,B,C,D,E,F", "Level-order traversal is correct")
    
    // Test GetDepth
    Set tDepth = tRoot.GetDepth()
    Do $$$AssertEquals(tDepth, 3, "Tree depth is 3")
    
    // Test GetLevel for specific nodes
    Set tLevel = tD.GetLevel()
    Do $$$AssertEquals(tLevel, 2, "Leaf D is at level 2")
    
    Quit $$$OK
}

/// Test healthcare hierarchy budget calculations
Method TestHealthcareBudgetCalculations()
{
    // Create hospital structure
    Set tHospital = ##class(Patterns.Examples.Hospital).%New()
    Set tHospital.Name = "City General Hospital"
    Set tHospital.UnitCode = "CGH001"
    Set tHospital.AccreditationStatus = "Level 1 Trauma Center"
    Set tHospital.Budget = 5000000
    
    // Create Emergency Department
    Set tEmergency = ##class(Patterns.Examples.Department).%New()
    Set tEmergency.Name = "Emergency Department"
    Set tEmergency.UnitCode = "ED001"
    Set tEmergency.Budget = 2000000
    
    // Create ICU units
    Set tICU1 = ##class(Patterns.Examples.MedicalUnit).%New()
    Set tICU1.Name = "ICU Unit 1"
    Set tICU1.UnitCategory = "Critical Care"
    Set tICU1.BedCapacity = 20
    Set tICU1.CurrentOccupancy = 18
    Set tICU1.Budget = 500000
    
    Set tICU2 = ##class(Patterns.Examples.MedicalUnit).%New()
    Set tICU2.Name = "ICU Unit 2"
    Set tICU2.UnitCategory = "Critical Care"
    Set tICU2.BedCapacity = 15
    Set tICU2.CurrentOccupancy = 12
    Set tICU2.Budget = 400000
    
    // Build hierarchy
    Do tHospital.Add(tEmergency)
    Do tEmergency.Add(tICU1)
    Do tEmergency.Add(tICU2)
    
    // Test budget calculations
    Set tTotalBudget = tHospital.CalculateBudget()
    Do $$$AssertEquals(tTotalBudget, 7900000, "Total hospital budget calculated correctly")
    
    Set tDeptBudget = tEmergency.CalculateBudget()
    Do $$$AssertEquals(tDeptBudget, 2900000, "Department budget includes units")
    
    // Test that leaf budget is just its own
    Set tUnitBudget = tICU1.CalculateBudget()
    Do $$$AssertEquals(tUnitBudget, 500000, "Unit budget is only its own")
    
    Quit $$$OK
}

/// Test staff count aggregation
Method TestStaffCountAggregation()
{
    // Create hospital structure
    Set tHospital = ##class(Patterns.Examples.Hospital).%New()
    Set tHospital.Name = "Regional Medical Center"
    Set tHospital.StaffCount = 100  // Admin staff
    
    // Create departments
    Set tSurgery = ##class(Patterns.Examples.Department).%New()
    Set tSurgery.Name = "Surgery Department"
    Set tSurgery.StaffCount = 50
    
    Set tPediatrics = ##class(Patterns.Examples.Department).%New()
    Set tPediatrics.Name = "Pediatrics Department"
    Set tPediatrics.StaffCount = 30
    
    // Create units
    Set tOR1 = ##class(Patterns.Examples.MedicalUnit).%New()
    Set tOR1.Name = "Operating Room 1"
    Set tOR1.StaffCount = 15
    
    Set tOR2 = ##class(Patterns.Examples.MedicalUnit).%New()
    Set tOR2.Name = "Operating Room 2"
    Set tOR2.StaffCount = 12
    
    Set tPICU = ##class(Patterns.Examples.MedicalUnit).%New()
    Set tPICU.Name = "Pediatric ICU"
    Set tPICU.StaffCount = 25
    
    // Build hierarchy
    Do tHospital.Add(tSurgery)
    Do tHospital.Add(tPediatrics)
    Do tSurgery.Add(tOR1)
    Do tSurgery.Add(tOR2)
    Do tPediatrics.Add(tPICU)
    
    // Test staff count aggregation
    Set tTotalStaff = tHospital.GetTotalStaffCount()
    Do $$$AssertEquals(tTotalStaff, 232, "Total hospital staff count aggregated correctly")
    
    Set tSurgeryStaff = tSurgery.GetTotalStaffCount()
    Do $$$AssertEquals(tSurgeryStaff, 77, "Surgery department staff includes units")
    
    Set tPediatricsStaff = tPediatrics.GetTotalStaffCount()
    Do $$$AssertEquals(tPediatricsStaff, 55, "Pediatrics department staff includes units")
    
    Quit $$$OK
}

/// Test tree persistence to/from globals
Method TestTreePersistence()
{
    // Create test tree
    Set tHospital = ##class(Patterns.Examples.Hospital).%New()
    Set tHospital.Name = "Test Hospital"
    Set tHospital.UnitCode = "TH001"
    Set tHospital.AccreditationStatus = "Level 2"
    Set tHospital.Budget = 1000000
    
    Set tDept = ##class(Patterns.Examples.Department).%New()
    Set tDept.Name = "Test Department"
    Set tDept.UnitCode = "TD001"
    Set tDept.Budget = 500000
    
    Set tUnit = ##class(Patterns.Examples.MedicalUnit).%New()
    Set tUnit.Name = "Test Unit"
    Set tUnit.UnitCategory = "Standard"
    Set tUnit.BedCapacity = 10
    Set tUnit.Budget = 100000
    
    Do tHospital.Add(tDept)
    Do tDept.Add(tUnit)
    
    // Save tree to global
    Set tTreeName = "TestCompositeTree"_$Random(10000)
    Set tSC = ##class(Patterns.GoF.Structural.GlobalTreeStorage).SaveTree(tHospital, tTreeName)
    Do $$$AssertStatusOK(tSC, "Tree saved successfully")
    
    // Verify tree exists
    Set tExists = ##class(Patterns.GoF.Structural.GlobalTreeStorage).TreeExists(tTreeName)
    Do $$$AssertTrue(tExists, "Saved tree exists in global")
    
    // Load tree from global
    Set tLoadedTree = ##class(Patterns.GoF.Structural.GlobalTreeStorage).LoadTree(tTreeName)
    Do $$$AssertTrue($IsObject(tLoadedTree), "Tree loaded successfully")
    Do $$$AssertEquals(tLoadedTree.Name, "Test Hospital", "Root node name preserved")
    
    // Verify structure preserved
    Set tLoadedDept = tLoadedTree.GetChild(1)
    Do $$$AssertEquals(tLoadedDept.Name, "Test Department", "Department loaded correctly")
    
    Set tLoadedUnit = tLoadedDept.GetChild(1)
    Do $$$AssertEquals(tLoadedUnit.Name, "Test Unit", "Unit loaded correctly")
    
    // Test budget calculation on loaded tree
    Set tLoadedBudget = tLoadedTree.CalculateBudget()
    Do $$$AssertEquals(tLoadedBudget, 1600000, "Budget calculation works on loaded tree")
    
    // Clean up
    Set tSC = ##class(Patterns.GoF.Structural.GlobalTreeStorage).DeleteTree(tTreeName)
    Do $$$AssertStatusOK(tSC, "Tree deleted successfully")
    
    Quit $$$OK
}

/// Test large tree performance
Method TestLargeTreePerformance()
{
    // Create large hospital with many departments and units
    Set tStartTime = $ZH
    
    Set tHospital = ##class(Patterns.Examples.Hospital).%New()
    Set tHospital.Name = "Mega Hospital Complex"
    Set tHospital.StaffCount = 500
    Set tHospital.Budget = 50000000
    
    // Create 50 departments
    For i = 1:1:50 {
        Set tDept = ##class(Patterns.Examples.Department).%New()
        Set tDept.Name = "Department "_i
        Set tDept.UnitCode = "DEPT"_i
        Set tDept.StaffCount = 20
        Set tDept.Budget = 100000 * i
        
        // Add 20 units per department (1000 units total)
        For j = 1:1:20 {
            Set tUnit = ##class(Patterns.Examples.MedicalUnit).%New()
            Set tUnit.Name = "Unit "_i_"-"_j
            Set tUnit.UnitCategory = "Standard"
            Set tUnit.StaffCount = 5
            Set tUnit.Budget = 10000 * j
            Do tDept.Add(tUnit)
        }
        
        Do tHospital.Add(tDept)
    }
    
    Set tBuildTime = $ZH - tStartTime
    Do $$$AssertTrue(tBuildTime < 1, "Building 1000+ node tree takes less than 1 second")
    
    // Test traversal performance
    Set tStartTime = $ZH
    Set tResult = tHospital.TraversePreOrder()
    Set tTraverseTime = $ZH - tStartTime
    Do $$$AssertTrue(tTraverseTime < 1, "Traversing 1000+ nodes takes less than 1 second")
    
    // Test aggregation performance
    Set tStartTime = $ZH
    Set tTotalStaff = tHospital.GetTotalStaffCount()
    Set tAggregateTime = $ZH - tStartTime
    Do $$$AssertTrue(tAggregateTime < 1, "Aggregating 1000+ nodes takes less than 1 second")
    
    // Verify correctness
    Do $$$AssertEquals(tTotalStaff, 6500, "Staff count aggregation correct for large tree")
    
    // Test find operation performance
    Set tStartTime = $ZH
    Set tFound = tHospital.FindUnit("Unit 25-10")
    Set tFindTime = $ZH - tStartTime
    Do $$$AssertTrue(tFindTime < 0.5, "Finding specific unit in large tree takes less than 0.5 seconds")
    Do $$$AssertTrue($IsObject(tFound), "Unit found in large tree")
    
    Quit $$$OK
}

/// Test circular reference prevention
Method TestCircularReferencePrevention()
{
    // Create nodes
    Set tRoot = ##class(Patterns.GoF.Structural.Composite).%New()
    Set tRoot.Name = "Root"
    
    Set tChild = ##class(Patterns.GoF.Structural.Composite).%New()
    Set tChild.Name = "Child"
    
    Set tGrandchild = ##class(Patterns.GoF.Structural.Composite).%New()
    Set tGrandchild.Name = "Grandchild"
    
    // Build initial valid hierarchy
    Do tRoot.Add(tChild)
    Do tChild.Add(tGrandchild)
    
    // Try to create circular reference - add root to grandchild
    Set tSC = tGrandchild.Add(tRoot)
    Do $$$AssertStatusNotOK(tSC, "Adding ancestor as child is prevented")
    
    // Try to add child to itself
    Set tSC = tChild.Add(tChild)
    Do $$$AssertStatusNotOK(tSC, "Adding self as child is prevented")
    
    // Verify structure remains intact using GetChildCount
    Do $$$AssertEquals(tRoot.GetChildCount(), 1, "Root still has one child")
    Do $$$AssertEquals(tChild.GetChildCount(), 1, "Child still has one grandchild")
    Do $$$AssertEquals(tGrandchild.GetChildCount(), 0, "Grandchild has no children")
    
    // Test with healthcare hierarchy
    Set tHospital = ##class(Patterns.Examples.Hospital).%New()
    Set tHospital.Name = "Test Hospital"
    
    Set tDept = ##class(Patterns.Examples.Department).%New()
    Set tDept.Name = "Test Department"
    
    Do tHospital.Add(tDept)
    
    // Try to add hospital to department
    Set tSC = tDept.Add(tHospital)
    Do $$$AssertStatusNotOK(tSC, "Circular reference prevented in healthcare hierarchy")
    
    Quit $$$OK
}

/// Test null component handling
Method TestNullComponentHandling()
{
    Set tComposite = ##class(Patterns.GoF.Structural.Composite).%New()
    Set tComposite.Name = "TestComposite"
    
    // Try to add null component
    Set tSC = tComposite.Add("")
    Do $$$AssertStatusNotOK(tSC, "Adding null component returns error")
    
    // Try to remove null component
    Set tSC = tComposite.Remove("")
    Do $$$AssertStatusNotOK(tSC, "Removing null component returns error")
    
    // Verify no children added using GetChildCount
    Do $$$AssertEquals(tComposite.GetChildCount(), 0, "No children in composite after null operations")
    
    // Test with healthcare hierarchy
    Set tHospital = ##class(Patterns.Examples.Hospital).%New()
    Set tHospital.Name = "Null Test Hospital"
    
    Set tSC = tHospital.Add("")
    Do $$$AssertStatusNotOK(tSC, "Hospital rejects null department")
    
    Quit $$$OK
}

/// Test healthcare-specific operations
Method TestHealthcareOperations()
{
    // Create emergency department scenario
    Set tEmergency = ##class(Patterns.Examples.Department).%New()
    Set tEmergency.Name = "Emergency Department"
    Set tEmergency.Specialization = "Emergency Medicine"
    Set tEmergency.Budget = 3000000
    
    // Create trauma units
    Set tTrauma1 = ##class(Patterns.Examples.MedicalUnit).%New()
    Set tTrauma1.Name = "Trauma Bay 1"
    Set tTrauma1.UnitCategory = "Trauma"
    Set tTrauma1.BedCapacity = 4
    Set tTrauma1.CurrentOccupancy = 4
    Set tTrauma1.EquipmentValue = 2000000
    
    Set tTrauma2 = ##class(Patterns.Examples.MedicalUnit).%New()
    Set tTrauma2.Name = "Trauma Bay 2"
    Set tTrauma2.UnitCategory = "Trauma"
    Set tTrauma2.BedCapacity = 4
    Set tTrauma2.CurrentOccupancy = 3
    Set tTrauma2.EquipmentValue = 1800000
    
    Do tEmergency.Add(tTrauma1)
    Do tEmergency.Add(tTrauma2)
    
    // Test occupancy calculations
    Set tOccupancy1 = tTrauma1.GetOccupancyRate()
    Do $$$AssertEquals(tOccupancy1, 100, "Trauma Bay 1 at full capacity")
    
    Set tOccupancy2 = tTrauma2.GetOccupancyRate()
    Do $$$AssertEquals(tOccupancy2, 75, "Trauma Bay 2 at 75% capacity")
    
    // Test critical status - full occupancy should require attention
    Set tRequiresAttention = (tTrauma1.CurrentOccupancy >= tTrauma1.BedCapacity)
    Do $$$AssertTrue(tRequiresAttention, "Full trauma bay requires attention")
    
    // Test unit finding
    Set tFound = tEmergency.FindUnit("Trauma Bay 1")
    Do $$$AssertTrue($IsObject(tFound), "Unit found by name")
    Do $$$AssertEquals(tFound.Name, "Trauma Bay 1", "Correct unit found")
    
    Quit $$$OK
}

/// Test JSON export functionality
Method TestJSONExport()
{
    // Create small tree for JSON export
    Set tHospital = ##class(Patterns.Examples.Hospital).%New()
    Set tHospital.Name = "JSON Test Hospital"
    Set tHospital.UnitCode = "JTH001"
    
    Set tDept = ##class(Patterns.Examples.Department).%New()
    Set tDept.Name = "Radiology"
    Set tDept.UnitCode = "RAD001"
    
    Set tUnit = ##class(Patterns.Examples.MedicalUnit).%New()
    Set tUnit.Name = "MRI Suite"
    Set tUnit.UnitCategory = "Imaging"
    
    Do tHospital.Add(tDept)
    Do tDept.Add(tUnit)
    
    // Save and export to JSON
    Set tTreeName = "JSONTestTree"_$Random(10000)
    Set tSC = ##class(Patterns.GoF.Structural.GlobalTreeStorage).SaveTree(tHospital, tTreeName)
    Do $$$AssertStatusOK(tSC, "Tree saved for JSON export")
    
    Set tJSON = ##class(Patterns.GoF.Structural.GlobalTreeStorage).ExportToJSON(tTreeName)
    Do $$$AssertTrue(tJSON '= "", "JSON export produced output")
    Do $$$AssertTrue(tJSON [ "JSON Test Hospital", "JSON contains hospital name")
    Do $$$AssertTrue(tJSON [ "Radiology", "JSON contains department name")
    Do $$$AssertTrue(tJSON [ "MRI Suite", "JSON contains unit name")
    
    // Clean up
    Do ##class(Patterns.GoF.Structural.GlobalTreeStorage).DeleteTree(tTreeName)
    
    Quit $$$OK
}

/// Clean up any test artifacts
Method OnAfterOneTest() As %Status
{
    // Clean up any test trees in globals
    Set tSC = $$$OK
    
    // Remove any test trees created during tests
    Set tTreeName = ""
    For {
        Set tTreeName = $Order(^TreeStorage(tTreeName))
        Quit:tTreeName=""
        
        If tTreeName [ "Test" {
            Kill ^TreeStorage(tTreeName)
        }
    }
    
    Quit tSC
}

}
