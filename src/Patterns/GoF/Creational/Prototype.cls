/// Gang of Four Prototype Pattern - Abstract Prototype Interface
/// <p>Provides an interface for cloning objects in ObjectScript.</p>
/// <p>Supports both shallow and deep cloning mechanisms using ObjectScript
/// built-in features like %ConstructClone and serialization.</p>
Class Patterns.GoF.Creational.Prototype Extends %RegisteredObject [ Abstract ]
{

/// Creates a shallow clone of this prototype
/// <p>Uses ObjectScript's %ConstructClone for shallow copying.</p>
/// <p>Shallow clone copies primitive values and references to objects,
/// not the objects themselves.</p>
/// <returns>A new instance of Prototype (shallow copy)</returns>
Method Clone() As Patterns.GoF.Creational.Prototype [ Abstract ]
{
    Quit ""
}

/// Creates a deep clone of this prototype
/// <p>Uses serialization/deserialization for deep copying.</p>
/// <p>Deep clone creates independent copies of all nested objects.</p>
/// <returns>A new instance of Prototype (deep copy)</returns>
Method DeepClone() As Patterns.GoF.Creational.Prototype [ Abstract ]
{
    Quit ""
}

/// Copies property values from another prototype
/// <p>Utility method for copying properties between instances.</p>
/// <param name="pSource">The source prototype to copy from</param>
/// <returns>%Status indicating success or failure</returns>
Method CopyFrom(pSource As Patterns.GoF.Creational.Prototype) As %Status
{
    Set tSC = $$$OK
    Try {
        // Base implementation - subclasses should override
        // to copy specific properties
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Called after cloning for any additional initialization
/// <p>Subclasses can override to perform post-clone setup.</p>
/// <returns>%Status indicating success or failure</returns>
Method InitializeAfterClone() As %Status
{
    Quit $$$OK
}

}
