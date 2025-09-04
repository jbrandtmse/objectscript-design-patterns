/// Gang of Four Prototype Pattern - Concrete Prototype 2
/// <p>Demonstrates cloning with collections and nested prototypes.</p>
Class Patterns.GoF.Creational.ConcretePrototype2 Extends Patterns.GoF.Creational.Prototype
{

/// A list property for testing collection cloning
Property ListProperty As list Of %String;

/// A nested prototype object
Property NestedObject As Patterns.GoF.Creational.ConcretePrototype1;

/// Additional metadata as key-value pairs
Property Metadata As array Of %String;

/// Creates a shallow clone using %ConstructClone
/// <returns>A new instance with shallow copy of properties</returns>
Method Clone() As Patterns.GoF.Creational.Prototype
{
    // Use ObjectScript's built-in shallow clone
    Set tClone = ..%ConstructClone()
    
    // Call post-clone initialization
    Do tClone.InitializeAfterClone()
    
    Quit tClone
}

/// Creates a deep clone with independent collections and nested objects
/// <returns>A new instance with deep copy of all properties</returns>
Method DeepClone() As Patterns.GoF.Creational.Prototype
{
    Set tClone = ""
    Try {
        // Create new instance
        Set tClone = ##class(Patterns.GoF.Creational.ConcretePrototype2).%New()
        
        // Deep copy the list property
        Set tCount = ..ListProperty.Count()
        For i=1:1:tCount {
            Do tClone.ListProperty.Insert(..ListProperty.GetAt(i))
        }
        
        // Deep copy the metadata array
        Set tKey = ""
        For {
            Set tValue = ..Metadata.GetNext(.tKey)
            If tKey = "" Quit
            Do tClone.Metadata.SetAt(tValue, tKey)
        }
        
        // Deep clone nested object if it exists
        If $IsObject(..NestedObject) {
            Set tClone.NestedObject = ..NestedObject.Clone()
        }
        
        // Initialize after deep clone
        Do tClone.InitializeAfterClone()
    }
    Catch ex {
        Set tClone = ""
    }
    
    Quit tClone
}

/// Copies properties from another ConcretePrototype2
/// <param name="pSource">Source object to copy from</param>
/// <returns>%Status</returns>
Method CopyFrom(pSource As Patterns.GoF.Creational.Prototype) As %Status
{
    Set tSC = $$$OK
    Try {
        // Check if source is correct type
        If 'pSource.%IsA("Patterns.GoF.Creational.ConcretePrototype2") {
            Set tSC = $$$ERROR($$$GeneralError, "Source must be ConcretePrototype2")
            Quit
        }
        
        // Clear and copy list property
        Do ..ListProperty.Clear()
        Set tCount = pSource.ListProperty.Count()
        For i=1:1:tCount {
            Do ..ListProperty.Insert(pSource.ListProperty.GetAt(i))
        }
        
        // Clear and copy metadata
        Do ..Metadata.Clear()
        Set tKey = ""
        For {
            Set tValue = pSource.Metadata.GetNext(.tKey)
            If tKey = "" Quit
            Do ..Metadata.SetAt(tValue, tKey)
        }
        
        // Copy nested object (shallow)
        Set ..NestedObject = pSource.NestedObject
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Adds test data to collections
/// <param name="pListItem">Item to add to list</param>
/// <param name="pMetaKey">Metadata key</param>
/// <param name="pMetaValue">Metadata value</param>
/// <returns>%Status</returns>
Method AddTestData(pListItem As %String = "", pMetaKey As %String = "", pMetaValue As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        If pListItem '= "" {
            Do ..ListProperty.Insert(pListItem)
        }
        If (pMetaKey '= "") && (pMetaValue '= "") {
            Do ..Metadata.SetAt(pMetaValue, pMetaKey)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
