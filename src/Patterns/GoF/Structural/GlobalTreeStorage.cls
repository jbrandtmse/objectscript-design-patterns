/// GlobalTreeStorage - Persistence layer for Composite pattern tree structures
/// <p>
/// Provides functionality to save and load tree structures to/from ObjectScript globals.
/// Handles parent-child relationships and node data serialization.
/// </p>
/// <p>
/// Global Storage Structure:
/// ^TreeStorage(treeName, nodeId) = $listbuild(name, type, parentId)
/// ^TreeStorage(treeName, nodeId, "children") = $listbuild(childId1, childId2, ...)
/// ^TreeStorage(treeName, nodeId, "data", property) = value
/// </p>
/// <example>
/// // Save a tree
/// Set hospital = ##class(Patterns.Examples.Hospital).%New()
/// Set hospital.Name = "City General Hospital"
/// // ... build tree structure ...
/// Do ##class(Patterns.GoF.Structural.GlobalTreeStorage).SaveTree(hospital, "HospitalTree")
/// 
/// // Load a tree
/// Set loadedTree = ##class(Patterns.GoF.Structural.GlobalTreeStorage).LoadTree("HospitalTree")
/// </example>
Class Patterns.GoF.Structural.GlobalTreeStorage Extends %RegisteredObject
{

/// <p>
/// Save a tree structure to a global
/// </p>
/// <param name="pRoot">Root component of the tree</param>
/// <param name="pGlobalName">Name for the global storage</param>
/// <returns>%Status</returns>
ClassMethod SaveTree(pRoot As Patterns.GoF.Structural.Component, pGlobalName As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate input
        If '$IsObject(pRoot) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid root component")
            Quit
        }
        If pGlobalName = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Global name cannot be empty")
            Quit
        }
        
        // Clear existing tree data
        Kill ^TreeStorage(pGlobalName)
        
        // Initialize node counter
        Set tNodeCounter = 0
        
        // Save metadata
        Set ^TreeStorage(pGlobalName, "metadata") = $listbuild($zdt($h,3), pRoot.%ClassName(1))
        
        // Recursively save tree starting from root
        Set tRootId = ..SaveNodeRecursive(pRoot, pGlobalName, 0, .tNodeCounter)
        
        // Save root node ID
        Set ^TreeStorage(pGlobalName, "root") = tRootId
        
        // Save node count
        Set ^TreeStorage(pGlobalName, "nodecount") = tNodeCounter
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Recursively save a node and its children
/// </p>
/// <param name="pNode">Node to save</param>
/// <param name="pGlobalName">Global storage name</param>
/// <param name="pParentId">Parent node ID</param>
/// <param name="pNodeCounter">Node counter by reference</param>
/// <returns>Node ID</returns>
ClassMethod SaveNodeRecursive(pNode As Patterns.GoF.Structural.Component, pGlobalName As %String, pParentId As %Integer, ByRef pNodeCounter As %Integer) As %Integer [ Private ]
{
    // Increment and get node ID
    Set pNodeCounter = pNodeCounter + 1
    Set tNodeId = pNodeCounter
    
    // Get node properties
    Set tName = ""
    Set tType = pNode.%ClassName(1)
    Try {
        Set tName = pNode.Name
    }
    Catch {
        // Node may not have Name property
    }
    
    // Save basic node information
    Set ^TreeStorage(pGlobalName, tNodeId) = $listbuild(tName, tType, pParentId)
    
    // Save node-specific data based on type
    If pNode.%IsA("Patterns.Examples.OrganizationalUnit") {
        Set tOrgUnit = pNode
        Set ^TreeStorage(pGlobalName, tNodeId, "data", "UnitCode") = tOrgUnit.UnitCode
        Set ^TreeStorage(pGlobalName, tNodeId, "data", "Budget") = tOrgUnit.Budget
        Set ^TreeStorage(pGlobalName, tNodeId, "data", "StaffCount") = tOrgUnit.StaffCount
        Set ^TreeStorage(pGlobalName, tNodeId, "data", "UnitType") = tOrgUnit.UnitType
        
        // Save type-specific properties
        If pNode.%IsA("Patterns.Examples.Hospital") {
            Set tHospital = pNode
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "Location") = tHospital.Location
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "BedCount") = tHospital.BedCount
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "AccreditationStatus") = tHospital.AccreditationStatus
        }
        ElseIf pNode.%IsA("Patterns.Examples.Department") {
            Set tDept = pNode
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "Specialization") = tDept.Specialization
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "DepartmentHead") = tDept.DepartmentHead
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "OperatingHours") = tDept.OperatingHours
        }
        ElseIf pNode.%IsA("Patterns.Examples.MedicalUnit") {
            Set tUnit = pNode
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "UnitCategory") = tUnit.UnitCategory
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "RoomNumbers") = tUnit.RoomNumbers
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "BedCapacity") = tUnit.BedCapacity
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "CurrentOccupancy") = tUnit.CurrentOccupancy
            Set ^TreeStorage(pGlobalName, tNodeId, "data", "EquipmentValue") = tUnit.EquipmentValue
        }
    }
    
    // Save children if it's a composite
    Set tChildList = ""
    If 'pNode.IsLeaf() {
        Set tChildIndex = 1
        Set tChild = pNode.GetChild(tChildIndex)
        While $IsObject(tChild) {
            Set tChildId = ..SaveNodeRecursive(tChild, pGlobalName, tNodeId, .pNodeCounter)
            Set tChildList = tChildList _ $listbuild(tChildId)
            Set tChildIndex = tChildIndex + 1
            Set tChild = pNode.GetChild(tChildIndex)
        }
    }
    
    // Save children list if any
    If tChildList '= "" {
        Set ^TreeStorage(pGlobalName, tNodeId, "children") = tChildList
    }
    
    Quit tNodeId
}

/// <p>
/// Load a tree structure from a global
/// </p>
/// <param name="pGlobalName">Name of the global storage</param>
/// <returns>Root component of the loaded tree</returns>
ClassMethod LoadTree(pGlobalName As %String) As Patterns.GoF.Structural.Component
{
    Set tRoot = ""
    
    Try {
        // Check if tree exists
        If '$Data(^TreeStorage(pGlobalName, "root")) {
            Quit
        }
        
        // Get root node ID
        Set tRootId = ^TreeStorage(pGlobalName, "root")
        
        // Create node map for parent-child linking
        Kill tNodeMap
        
        // Recursively load tree starting from root
        Set tRoot = ..LoadNodeRecursive(pGlobalName, tRootId, .tNodeMap)
    }
    Catch ex {
        // Log error but return empty string
        Set tRoot = ""
    }
    
    Quit tRoot
}

/// <p>
/// Recursively load a node and its children
/// </p>
/// <param name="pGlobalName">Global storage name</param>
/// <param name="pNodeId">Node ID to load</param>
/// <param name="pNodeMap">Node map by reference</param>
/// <returns>Loaded component</returns>
ClassMethod LoadNodeRecursive(pGlobalName As %String, pNodeId As %Integer, ByRef pNodeMap) As Patterns.GoF.Structural.Component [ Private ]
{
    Set tNode = ""
    
    Try {
        // Get node information
        If '$Data(^TreeStorage(pGlobalName, pNodeId)) {
            Quit
        }
        
        Set tNodeInfo = ^TreeStorage(pGlobalName, pNodeId)
        Set tName = $list(tNodeInfo, 1)
        Set tType = $list(tNodeInfo, 2)
        Set tParentId = $list(tNodeInfo, 3)
        
        // Create node instance based on type
        Set tNode = $classmethod(tType, "%New")
        If '$IsObject(tNode) {
            Quit
        }
        
        // Set basic properties
        Try {
            Set tNode.Name = tName
        }
        Catch {
            // Node may not have Name property
        }
        
        // Load node-specific data
        If tNode.%IsA("Patterns.Examples.OrganizationalUnit") {
            If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "UnitCode")) {
                Set tNode.UnitCode = ^TreeStorage(pGlobalName, pNodeId, "data", "UnitCode")
            }
            If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "Budget")) {
                Set tNode.Budget = ^TreeStorage(pGlobalName, pNodeId, "data", "Budget")
            }
            If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "StaffCount")) {
                Set tNode.StaffCount = ^TreeStorage(pGlobalName, pNodeId, "data", "StaffCount")
            }
            If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "UnitType")) {
                Set tNode.UnitType = ^TreeStorage(pGlobalName, pNodeId, "data", "UnitType")
            }
            
            // Load type-specific properties
            If tNode.%IsA("Patterns.Examples.Hospital") {
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "Location")) {
                    Set tNode.Location = ^TreeStorage(pGlobalName, pNodeId, "data", "Location")
                }
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "BedCount")) {
                    Set tNode.BedCount = ^TreeStorage(pGlobalName, pNodeId, "data", "BedCount")
                }
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "AccreditationStatus")) {
                    Set tNode.AccreditationStatus = ^TreeStorage(pGlobalName, pNodeId, "data", "AccreditationStatus")
                }
            }
            ElseIf tNode.%IsA("Patterns.Examples.Department") {
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "Specialization")) {
                    Set tNode.Specialization = ^TreeStorage(pGlobalName, pNodeId, "data", "Specialization")
                }
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "DepartmentHead")) {
                    Set tNode.DepartmentHead = ^TreeStorage(pGlobalName, pNodeId, "data", "DepartmentHead")
                }
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "OperatingHours")) {
                    Set tNode.OperatingHours = ^TreeStorage(pGlobalName, pNodeId, "data", "OperatingHours")
                }
            }
            ElseIf tNode.%IsA("Patterns.Examples.MedicalUnit") {
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "UnitCategory")) {
                    Set tNode.UnitCategory = ^TreeStorage(pGlobalName, pNodeId, "data", "UnitCategory")
                }
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "RoomNumbers")) {
                    Set tNode.RoomNumbers = ^TreeStorage(pGlobalName, pNodeId, "data", "RoomNumbers")
                }
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "BedCapacity")) {
                    Set tNode.BedCapacity = ^TreeStorage(pGlobalName, pNodeId, "data", "BedCapacity")
                }
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "CurrentOccupancy")) {
                    Set tNode.CurrentOccupancy = ^TreeStorage(pGlobalName, pNodeId, "data", "CurrentOccupancy")
                }
                If $Data(^TreeStorage(pGlobalName, pNodeId, "data", "EquipmentValue")) {
                    Set tNode.EquipmentValue = ^TreeStorage(pGlobalName, pNodeId, "data", "EquipmentValue")
                }
            }
        }
        
        // Store node in map
        Set pNodeMap(pNodeId) = tNode
        
        // Load children if present
        If $Data(^TreeStorage(pGlobalName, pNodeId, "children")) {
            Set tChildList = ^TreeStorage(pGlobalName, pNodeId, "children")
            For i = 1:1:$listlength(tChildList) {
                Set tChildId = $list(tChildList, i)
                Set tChild = ..LoadNodeRecursive(pGlobalName, tChildId, .pNodeMap)
                If $IsObject(tChild) {
                    Do tNode.Add(tChild)
                }
            }
        }
    }
    Catch ex {
        // Log error but continue
        Set tNode = ""
    }
    
    Quit tNode
}

/// <p>
/// Delete a saved tree from global storage
/// </p>
/// <param name="pGlobalName">Name of the global storage</param>
/// <returns>%Status</returns>
ClassMethod DeleteTree(pGlobalName As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pGlobalName = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Global name cannot be empty")
            Quit
        }
        
        Kill ^TreeStorage(pGlobalName)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Check if a tree exists in global storage
/// </p>
/// <param name="pGlobalName">Name of the global storage</param>
/// <returns>%Boolean - 1 if exists, 0 otherwise</returns>
ClassMethod TreeExists(pGlobalName As %String) As %Boolean
{
    If pGlobalName = "" {
        Quit 0
    }
    
    Quit $Data(^TreeStorage(pGlobalName, "root"))
}

/// <p>
/// Get metadata about a saved tree
/// </p>
/// <param name="pGlobalName">Name of the global storage</param>
/// <param name="pSaveDate">Output: Save date/time</param>
/// <param name="pRootType">Output: Root node type</param>
/// <param name="pNodeCount">Output: Total node count</param>
/// <returns>%Status</returns>
ClassMethod GetTreeMetadata(pGlobalName As %String, Output pSaveDate As %String, Output pRootType As %String, Output pNodeCount As %Integer) As %Status
{
    Set tSC = $$$OK
    Set pSaveDate = ""
    Set pRootType = ""
    Set pNodeCount = 0
    
    Try {
        If pGlobalName = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Global name cannot be empty")
            Quit
        }
        
        If '$Data(^TreeStorage(pGlobalName, "metadata")) {
            Set tSC = $$$ERROR($$$GeneralError, "Tree not found: " _ pGlobalName)
            Quit
        }
        
        Set tMetadata = ^TreeStorage(pGlobalName, "metadata")
        Set pSaveDate = $list(tMetadata, 1)
        Set pRootType = $list(tMetadata, 2)
        
        If $Data(^TreeStorage(pGlobalName, "nodecount")) {
            Set pNodeCount = ^TreeStorage(pGlobalName, "nodecount")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// List all saved trees
/// </p>
/// <returns>%ListOfDataTypes containing tree names</returns>
ClassMethod ListSavedTrees() As %ListOfDataTypes
{
    Set tList = ##class(%ListOfDataTypes).%New()
    
    Set tName = ""
    For {
        Set tName = $Order(^TreeStorage(tName))
        Quit:tName=""
        
        // Check if it's a valid tree (has root)
        If $Data(^TreeStorage(tName, "root")) {
            Do tList.Insert(tName)
        }
    }
    
    Quit tList
}

/// <p>
/// Export tree structure to JSON string from saved global
/// </p>
/// <param name="pGlobalName">Name of the global storage</param>
/// <returns>JSON string representation</returns>
ClassMethod ExportToJSON(pGlobalName As %String) As %String
{
    Set tJSON = ""
    
    Try {
        // Load the tree from global
        Set tRoot = ..LoadTree(pGlobalName)
        If '$IsObject(tRoot) {
            Quit
        }
        
        // Convert to JSON
        Set tJSON = ..ExportTreeToJSON(tRoot)
    }
    Catch ex {
        Set tJSON = ""
    }
    
    Quit tJSON
}

/// <p>
/// Export tree structure to JSON string
/// </p>
/// <param name="pRoot">Root component of the tree</param>
/// <returns>JSON string representation</returns>
ClassMethod ExportTreeToJSON(pRoot As Patterns.GoF.Structural.Component) As %String
{
    Set tJSON = ""
    
    Try {
        If '$IsObject(pRoot) {
            Quit
        }
        
        Set tDynObj = ##class(%DynamicObject).%New()
        Set tSC = ..NodeToJSON(pRoot, tDynObj)
        If $$$ISOK(tSC) {
            Set tJSON = tDynObj.%ToJSON()
        }
    }
    Catch ex {
        Set tJSON = ""
    }
    
    Quit tJSON
}

/// <p>
/// Convert a node to JSON object
/// </p>
/// <param name="pNode">Node to convert</param>
/// <param name="pDynObj">Dynamic object to populate</param>
/// <returns>%Status</returns>
ClassMethod NodeToJSON(pNode As Patterns.GoF.Structural.Component, pDynObj As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Set basic properties
        Set pDynObj.type = pNode.%ClassName(1)
        Try { Set pDynObj.name = pNode.Name } Catch { }
        Set pDynObj.isLeaf = pNode.IsLeaf()
        
        // Add type-specific properties
        If pNode.%IsA("Patterns.Examples.OrganizationalUnit") {
            Set pDynObj.unitCode = pNode.UnitCode
            Set pDynObj.budget = pNode.Budget
            Set pDynObj.staffCount = pNode.StaffCount
            Set pDynObj.unitType = pNode.UnitType
        }
        
        // Add children if composite
        If 'pNode.IsLeaf() {
            Set tChildren = ##class(%DynamicArray).%New()
            Set i = 1
            Set tChild = pNode.GetChild(i)
            While $IsObject(tChild) {
                Set tChildObj = ##class(%DynamicObject).%New()
                Set tSC = ..NodeToJSON(tChild, tChildObj)
                Quit:$$$ISERR(tSC)
                Do tChildren.%Push(tChildObj)
                Set i = i + 1
                Set tChild = pNode.GetChild(i)
            }
            Set pDynObj.children = tChildren
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
