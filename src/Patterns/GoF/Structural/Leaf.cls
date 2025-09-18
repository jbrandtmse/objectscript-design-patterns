/// Gang of Four Composite Pattern - Leaf
/// <p>
/// The Leaf class represents leaf objects in the composition. A leaf has no children.
/// It defines behavior for primitive objects in the composition.
/// </p>
/// <p>
/// Leaf objects are the terminal nodes in the composite structure. They implement
/// the Operation() method with actual behavior but cannot have children.
/// </p>
/// <example>
/// Set leaf = ##class(Patterns.GoF.Structural.Leaf).%New()
/// Set leaf.Name = "Document1"
/// Set leaf.Data = "Important content"
/// Write leaf.Operation()
/// </example>
Class Patterns.GoF.Structural.Leaf Extends Patterns.GoF.Structural.Component
{

/// Data specific to this leaf node
Property Data As %String;

/// <p>
/// Performs the operation for this leaf component.
/// Returns a string representation of the leaf's operation.
/// </p>
/// <returns>String result of the leaf operation</returns>
Method Operation() As %String
{
    Set tResult = "Leaf " _ ..Name
    If ..Data '= "" {
        Set tResult = tResult _ ": " _ ..Data
    }
    Quit tResult
}

/// <p>
/// Leaf nodes are always leaves, so this always returns true.
/// </p>
/// <returns>Boolean true</returns>
Method IsLeaf() As %Boolean
{
    Quit 1
}

/// <p>
/// Creates a string representation of this leaf.
/// </p>
/// <returns>String representation of the leaf</returns>
Method ToString() As %String
{
    Quit "Leaf: " _ ..Name _ " (Data: " _ ..Data _ ")"
}

/// <p>
/// Processes this leaf with the given processor function.
/// The processor should be an object with a Process(leaf) method.
/// </p>
/// <param name="pProcessor">Object with Process method</param>
/// <returns>%Status indicating success or failure</returns>
Method Process(pProcessor As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pProcessor '= "" {
            If ##class(%Dictionary.CompiledMethod).%ExistsId(pProcessor.%ClassName(1) _ "||Process") {
                Do pProcessor.Process($this)
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>
/// Gets the size of this leaf (always 1 for leaf nodes).
/// </p>
/// <returns>Integer size value (1)</returns>
Method GetSize() As %Integer
{
    Quit 1
}

/// <p>
/// Validates the leaf node's data.
/// </p>
/// <returns>%Status indicating if the leaf is valid</returns>
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    If ..Name = "" {
        Set tSC = $$$ERROR($$$GeneralError, "Leaf name cannot be empty")
    }
    
    Quit tSC
}

/// <p>
/// Creates a deep copy of this leaf.
/// </p>
/// <returns>New Leaf instance with copied properties</returns>
Method Clone() As Leaf
{
    Set tClone = ##class(Leaf).%New()
    Set tClone.Name = ..Name
    Set tClone.Data = ..Data
    // Don't copy parent reference
    Quit tClone
}

}
