/// Gang of Four Composite Pattern - Component
/// <p>
/// The Component class declares the interface for objects in the composition
/// and implements default behavior for the interface common to all classes.
/// It declares an interface for accessing and managing its child components.
/// </p>
/// <p>
/// This abstract class serves as the base for both Leaf and Composite objects,
/// enabling uniform treatment of individual objects and compositions.
/// </p>
/// <example>
/// Set component = ##class(Patterns.GoF.Structural.Composite).%New()
/// Set component.Name = "Root"
/// Set leaf = ##class(Patterns.GoF.Structural.Leaf).%New()
/// Set leaf.Name = "Leaf1"
/// Do component.Add(leaf)
/// Do component.Operation()
/// </example>
Class Patterns.GoF.Structural.Component Extends %RegisteredObject [ Abstract ]
{

/// Name of the component for identification
Property Name As %String;

/// Parent reference for bidirectional tree navigation
Property Parent As Component;

/// <p>
/// Abstract method to perform the operation for this component.
/// Leaf nodes implement specific behavior while composite nodes
/// typically delegate to their children.
/// </p>
/// <returns>String result of the operation</returns>
Method Operation() As %String [ Abstract ]
{
    Quit ""
}

/// <p>
/// Adds a child component to this component.
/// Default implementation throws an error for leaf nodes.
/// Composite nodes should override this method.
/// </p>
/// <param name="pComponent">The component to add as a child</param>
/// <returns>%Status indicating success or failure</returns>
Method Add(pComponent As Component) As %Status
{
    Quit $$$ERROR($$$GeneralError, "Cannot add to leaf component: " _ ..Name)
}

/// <p>
/// Removes a child component from this component.
/// Default implementation throws an error for leaf nodes.
/// Composite nodes should override this method.
/// </p>
/// <param name="pComponent">The component to remove</param>
/// <returns>%Status indicating success or failure</returns>
Method Remove(pComponent As Component) As %Status
{
    Quit $$$ERROR($$$GeneralError, "Cannot remove from leaf component: " _ ..Name)
}

/// <p>
/// Gets a child component at the specified index.
/// Default implementation returns null for leaf nodes.
/// Composite nodes should override this method.
/// </p>
/// <param name="pIndex">The index of the child to retrieve</param>
/// <returns>Component at the specified index or null</returns>
Method GetChild(pIndex As %Integer) As Component
{
    Quit ""
}

/// <p>
/// Pre-order traversal of the component tree returning string of names.
/// Processes the current node before its children.
/// </p>
/// <returns>Comma-separated string of component names in pre-order</returns>
Method TraversePreOrder() As %String
{
    Set tResult = ..Name
    
    // Process children if this is a composite
    Set tIndex = 1
    Set tChild = ..GetChild(tIndex)
    While tChild '= "" {
        Set tChildResult = tChild.TraversePreOrder()
        If tChildResult '= "" {
            Set tResult = tResult _ "," _ tChildResult
        }
        Set tIndex = tIndex + 1
        Set tChild = ..GetChild(tIndex)
    }
    
    Quit tResult
}

/// <p>
/// Post-order traversal of the component tree returning string of names.
/// Processes children before the current node.
/// </p>
/// <returns>Comma-separated string of component names in post-order</returns>
Method TraversePostOrder() As %String
{
    Set tResult = ""
    
    // Process children first if this is a composite
    Set tIndex = 1
    Set tChild = ..GetChild(tIndex)
    While tChild '= "" {
        Set tChildResult = tChild.TraversePostOrder()
        If tChildResult '= "" {
            If tResult '= "" {
                Set tResult = tResult _ ","
            }
            Set tResult = tResult _ tChildResult
        }
        Set tIndex = tIndex + 1
        Set tChild = ..GetChild(tIndex)
    }
    
    // Add current node
    If tResult '= "" {
        Set tResult = tResult _ "," _ ..Name
    } Else {
        Set tResult = ..Name
    }
    
    Quit tResult
}

/// <p>
/// Level-order (breadth-first) traversal of the component tree returning string of names.
/// Processes nodes level by level using a queue approach.
/// </p>
/// <returns>Comma-separated string of component names in level-order</returns>
Method TraverseLevelOrder() As %String
{
    Set tResult = ""
    
    // Use a list to simulate a queue
    Set tQueue = ##class(%ListOfObjects).%New()
    Do tQueue.Insert($this)
    
    While tQueue.Count() > 0 {
        // Dequeue from front
        Set tCurrent = tQueue.GetAt(1)
        Do tQueue.RemoveAt(1)
        
        // Add current node name to result
        If tResult '= "" {
            Set tResult = tResult _ ","
        }
        Set tResult = tResult _ tCurrent.Name
        
        // Enqueue children
        Set tIndex = 1
        Set tChild = tCurrent.GetChild(tIndex)
        While tChild '= "" {
            Do tQueue.Insert(tChild)
            Set tIndex = tIndex + 1
            Set tChild = tCurrent.GetChild(tIndex)
        }
    }
    
    Quit tResult
}

/// <p>
/// Pre-order traversal of the component tree with visitor pattern.
/// Processes the current node before its children.
/// </p>
/// <param name="pVisitor">Optional visitor object with Visit(component) method</param>
/// <returns>%Status indicating success or failure</returns>
Method TraversePreOrderWithVisitor(pVisitor As %RegisteredObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Process current node
        If pVisitor '= "" {
            Do pVisitor.Visit($this)
        }
        
        // Process children if this is a composite
        Set tIndex = 1
        Set tChild = ..GetChild(tIndex)
        While tChild '= "" {
            Set tSC = tChild.TraversePreOrderWithVisitor(pVisitor)
            If $$$ISERR(tSC) Quit
            Set tIndex = tIndex + 1
            Set tChild = ..GetChild(tIndex)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Post-order traversal of the component tree with visitor pattern.
/// Processes children before the current node.
/// </p>
/// <param name="pVisitor">Optional visitor object with Visit(component) method</param>
/// <returns>%Status indicating success or failure</returns>
Method TraversePostOrderWithVisitor(pVisitor As %RegisteredObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Process children first if this is a composite
        Set tIndex = 1
        Set tChild = ..GetChild(tIndex)
        While tChild '= "" {
            Set tSC = tChild.TraversePostOrderWithVisitor(pVisitor)
            If $$$ISERR(tSC) Quit
            Set tIndex = tIndex + 1
            Set tChild = ..GetChild(tIndex)
        }
        
        // Process current node
        If pVisitor '= "" {
            Do pVisitor.Visit($this)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Level-order (breadth-first) traversal of the component tree with visitor pattern.
/// Processes nodes level by level using a queue approach.
/// </p>
/// <param name="pVisitor">Optional visitor object with Visit(component) method</param>
/// <returns>%Status indicating success or failure</returns>
Method TraverseLevelOrderWithVisitor(pVisitor As %RegisteredObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Use a list to simulate a queue
        Set tQueue = ##class(%ListOfObjects).%New()
        Do tQueue.Insert($this)
        
        While tQueue.Count() > 0 {
            // Dequeue from front
            Set tCurrent = tQueue.GetAt(1)
            Do tQueue.RemoveAt(1)
            
            // Process current node
            If pVisitor '= "" {
                Do pVisitor.Visit(tCurrent)
            }
            
            // Enqueue children
            Set tIndex = 1
            Set tChild = tCurrent.GetChild(tIndex)
            While tChild '= "" {
                Do tQueue.Insert(tChild)
                Set tIndex = tIndex + 1
                Set tChild = tCurrent.GetChild(tIndex)
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Gets the depth of the subtree rooted at this component.
/// A leaf has depth 1, a node with children has depth = max(child depths) + 1.
/// </p>
/// <returns>Integer depth of the subtree</returns>
Method GetDepth() As %Integer
{
    Set tMaxChildDepth = 0
    
    // Check children depths
    Set tIndex = 1
    Set tChild = ..GetChild(tIndex)
    While tChild '= "" {
        Set tChildDepth = tChild.GetDepth()
        If tChildDepth > tMaxChildDepth {
            Set tMaxChildDepth = tChildDepth
        }
        Set tIndex = tIndex + 1
        Set tChild = ..GetChild(tIndex)
    }
    
    // Return max child depth + 1, or 1 for leaf
    Quit tMaxChildDepth + 1
}

/// <p>
/// Gets the level of this component in the tree.
/// Root has level 0, its children have level 1, etc.
/// </p>
/// <returns>Integer level value</returns>
Method GetLevel() As %Integer
{
    Set tLevel = 0
    Set tParent = ..Parent
    
    While tParent '= "" {
        Set tLevel = tLevel + 1
        Set tParent = tParent.Parent
    }
    
    Quit tLevel
}

/// <p>
/// Checks if this component is a leaf (has no children).
/// Default implementation returns true, composites override.
/// </p>
/// <returns>Boolean indicating if this is a leaf</returns>
Method IsLeaf() As %Boolean
{
    Quit 1
}

/// <p>
/// Gets the total count of all components in the subtree rooted at this component.
/// </p>
/// <returns>Integer count of components</returns>
Method GetComponentCount() As %Integer
{
    Set tCount = 1  // Count self
    
    // Count children recursively
    Set tIndex = 1
    Set tChild = ..GetChild(tIndex)
    While tChild '= "" {
        Set tCount = tCount + tChild.GetComponentCount()
        Set tIndex = tIndex + 1
        Set tChild = ..GetChild(tIndex)
    }
    
    Quit tCount
}

/// <p>
/// Validates the component and its structure.
/// </p>
/// <returns>%Status indicating if the component is valid</returns>
Method Validate() As %Status
{
    If ..Name = "" {
        Quit $$$ERROR($$$GeneralError, "Component name cannot be empty")
    }
    Quit $$$OK
}

/// <p>
/// Creates a clone of this component.
/// Subclasses should override to provide deep copy functionality.
/// </p>
/// <returns>Clone of this component</returns>
Method Clone() As Component
{
    // Abstract method - subclasses must implement
    Quit ""
}

}
