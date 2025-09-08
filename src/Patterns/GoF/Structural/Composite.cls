/// Gang of Four Composite Pattern - Composite
/// <p>
/// The Composite class defines behavior for components having children.
/// It stores child components and implements child-related operations
/// in the Component interface.
/// </p>
/// <p>
/// Composite objects form the branch nodes of the tree structure. They can
/// contain both leaf nodes and other composite nodes, enabling recursive composition.
/// </p>
/// <example>
/// Set root = ##class(Patterns.GoF.Structural.Composite).%New()
/// Set root.Name = "Root"
/// Set branch = ##class(Patterns.GoF.Structural.Composite).%New()
/// Set branch.Name = "Branch"
/// Set leaf = ##class(Patterns.GoF.Structural.Leaf).%New()
/// Set leaf.Name = "Leaf1"
/// Do root.Add(branch)
/// Do branch.Add(leaf)
/// Write root.Operation()
/// </example>
Class Patterns.GoF.Structural.Composite Extends Patterns.GoF.Structural.Component
{

/// Collection of child components
Property Children As %ListOfObjects [ Private ];

/// <p>
/// Constructor - initializes the children collection.
/// </p>
/// <returns>%Status indicating success or failure</returns>
Method %OnNew() As %Status
{
    Set ..Children = ##class(%ListOfObjects).%New()
    Quit $$$OK
}

/// <p>
/// Performs the operation for this composite by delegating to all children.
/// Aggregates results from all child operations.
/// </p>
/// <returns>String result of the composite operation</returns>
Method Operation() As %String
{
    Set tResult = "Composite[" _ ..Name _ "]{"
    Set tFirst = 1
    
    For tIndex = 1:1:..Children.Count() {
        Set tChild = ..Children.GetAt(tIndex)
        If tChild '= "" {
            If 'tFirst {
                Set tResult = tResult _ ", "
            }
            Set tResult = tResult _ tChild.Operation()
            Set tFirst = 0
        }
    }
    
    Set tResult = tResult _ "}"
    Quit tResult
}

/// <p>
/// Adds a child component to this composite.
/// Sets the parent reference of the child.
/// </p>
/// <param name="pComponent">The component to add as a child</param>
/// <returns>%Status indicating success or failure</returns>
Method Add(pComponent As Component) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate input
        If pComponent = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot add null component")
            Quit
        }
        
        // Check for circular reference
        If ..IsAncestorOf(pComponent) {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot add component - would create circular reference")
            Quit
        }
        
        // Remove from current parent if exists
        If pComponent.Parent '= "" {
            Set tSC = pComponent.Parent.Remove(pComponent)
            If $$$ISERR(tSC) Quit
        }
        
        // Add to children collection
        Do ..Children.Insert(pComponent)
        
        // Set parent reference
        Set pComponent.Parent = $this
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Removes a child component from this composite.
/// Clears the parent reference of the removed child.
/// </p>
/// <param name="pComponent">The component to remove</param>
/// <returns>%Status indicating success or failure</returns>
Method Remove(pComponent As Component) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pComponent = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot remove null component")
            Quit
        }
        
        // Find and remove the component
        Set tFound = 0
        For tIndex = 1:1:..Children.Count() {
            Set tChild = ..Children.GetAt(tIndex)
            If tChild = pComponent {
                Do ..Children.RemoveAt(tIndex)
                Set pComponent.Parent = ""
                Set tFound = 1
                Quit
            }
        }
        
        If 'tFound {
            Set tSC = $$$ERROR($$$GeneralError, "Component not found in children")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Gets a child component at the specified index.
/// Returns null if index is out of bounds.
/// </p>
/// <param name="pIndex">The 1-based index of the child to retrieve</param>
/// <returns>Component at the specified index or null</returns>
Method GetChild(pIndex As %Integer) As Component
{
    If (pIndex < 1) || (pIndex > ..Children.Count()) {
        Quit ""
    }
    
    Quit ..Children.GetAt(pIndex)
}

/// <p>
/// Gets the number of direct children of this composite.
/// </p>
/// <returns>Integer count of direct children</returns>
Method GetChildCount() As %Integer
{
    Quit ..Children.Count()
}

/// <p>
/// Composite nodes are never leaves, so this always returns false.
/// </p>
/// <returns>Boolean false</returns>
Method IsLeaf() As %Boolean
{
    Quit 0
}

/// <p>
/// Checks if this composite is an ancestor of the given component.
/// Used to prevent circular references.
/// </p>
/// <param name="pComponent">Component to check</param>
/// <returns>Boolean true if this is an ancestor</returns>
Method IsAncestorOf(pComponent As Component) As %Boolean [ Private ]
{
    Set tResult = 0
    Set tCurrent = pComponent
    While tCurrent '= "" {
        If tCurrent = $this {
            Set tResult = 1
            Quit
        }
        Set tCurrent = tCurrent.Parent
    }
    Quit tResult
}

/// <p>
/// Removes all children from this composite.
/// </p>
/// <returns>%Status indicating success or failure</returns>
Method Clear() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear parent references
        For tIndex = 1:1:..Children.Count() {
            Set tChild = ..Children.GetAt(tIndex)
            If tChild '= "" {
                Set tChild.Parent = ""
            }
        }
        
        // Clear the collection
        Do ..Children.Clear()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Finds a component by name in the subtree rooted at this composite.
/// Uses depth-first search.
/// </p>
/// <param name="pName">Name to search for</param>
/// <returns>Component with matching name or null</returns>
Method FindByName(pName As %String) As Component
{
    Set tResult = ""
    
    // Check self
    If ..Name = pName {
        Quit $this
    }
    
    // Search children recursively
    For tIndex = 1:1:..Children.Count() {
        Set tChild = ..Children.GetAt(tIndex)
        If tChild '= "" {
            If tChild.Name = pName {
                Set tResult = tChild
                Quit
            }
            // If child is composite, search recursively
            If 'tChild.IsLeaf() {
                Set tFound = tChild.FindByName(pName)
                If tFound '= "" {
                    Set tResult = tFound
                    Quit
                }
            }
        }
    }
    
    Quit tResult
}

/// <p>
/// Gets all leaf nodes in the subtree rooted at this composite.
/// </p>
/// <returns>%ListOfObjects containing all leaf nodes</returns>
Method GetAllLeaves() As %ListOfObjects
{
    Set tLeaves = ##class(%ListOfObjects).%New()
    
    For tIndex = 1:1:..Children.Count() {
        Set tChild = ..Children.GetAt(tIndex)
        If tChild '= "" {
            If tChild.IsLeaf() {
                Do tLeaves.Insert(tChild)
            } Else {
                // Recursively get leaves from composite children
                Set tChildLeaves = tChild.GetAllLeaves()
                For tLeafIndex = 1:1:tChildLeaves.Count() {
                    Do tLeaves.Insert(tChildLeaves.GetAt(tLeafIndex))
                }
            }
        }
    }
    
    Quit tLeaves
}

/// <p>
/// Creates a string representation of this composite.
/// </p>
/// <returns>String representation of the composite</returns>
Method ToString() As %String
{
    Quit "Composite: " _ ..Name _ " (Children: " _ ..Children.Count() _ ")"
}

/// <p>
/// Validates the composite and all its children.
/// </p>
/// <returns>%Status indicating if the composite is valid</returns>
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    If ..Name = "" {
        Quit $$$ERROR($$$GeneralError, "Composite name cannot be empty")
    }
    
    // Validate all children
    For tIndex = 1:1:..Children.Count() {
        Set tChild = ..Children.GetAt(tIndex)
        If tChild '= "" {
            Set tSC = tChild.Validate()
            If $$$ISERR(tSC) Quit
        }
    }
    
    Quit tSC
}

/// <p>
/// Creates a deep copy of this composite and all its children.
/// </p>
/// <returns>New Composite instance with cloned children</returns>
Method Clone() As Composite
{
    Set tClone = ##class(Composite).%New()
    Set tClone.Name = ..Name
    
    // Clone all children
    For tIndex = 1:1:..Children.Count() {
        Set tChild = ..Children.GetAt(tIndex)
        If tChild '= "" {
            Set tChildClone = tChild.Clone()
            Do tClone.Add(tChildClone)
        }
    }
    
    Quit tClone
}

}
