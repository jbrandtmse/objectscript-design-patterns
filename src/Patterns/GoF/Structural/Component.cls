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
/// Pre-order traversal of the component tree.
/// Processes the current node before its children.
/// </p>
/// <param name="pVisitor">Optional visitor object with Visit(component) method</param>
/// <returns>%Status indicating success or failure</returns>
Method TraversePreOrder(pVisitor As %RegisteredObject = "") As %Status
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
            Set tSC = tChild.TraversePreOrder(pVisitor)
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
/// Post-order traversal of the component tree.
/// Processes children before the current node.
/// </p>
/// <param name="pVisitor">Optional visitor object with Visit(component) method</param>
/// <returns>%Status indicating success or failure</returns>
Method TraversePostOrder(pVisitor As %RegisteredObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Process children first if this is a composite
        Set tIndex = 1
        Set tChild = ..GetChild(tIndex)
        While tChild '= "" {
            Set tSC = tChild.TraversePostOrder(pVisitor)
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
/// Level-order (breadth-first) traversal of the component tree.
/// Processes nodes level by level using a queue approach.
/// </p>
/// <param name="pVisitor">Optional visitor object with Visit(component) method</param>
/// <returns>%Status indicating success or failure</returns>
Method TraverseLevelOrder(pVisitor As %RegisteredObject = "") As %Status
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
/// Gets the depth of this component in the tree.
/// Root has depth 0, its children have depth 1, etc.
/// </p>
/// <returns>Integer depth value</returns>
Method GetDepth() As %Integer
{
    Set tDepth = 0
    Set tParent = ..Parent
    
    While tParent '= "" {
        Set tDepth = tDepth + 1
        Set tParent = tParent.Parent
    }
    
    Quit tDepth
}

/// <p>
/// Gets the level of this component (alias for GetDepth).
/// </p>
/// <returns>Integer level value</returns>
Method GetLevel() As %Integer
{
    Quit ..GetDepth()
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

}
