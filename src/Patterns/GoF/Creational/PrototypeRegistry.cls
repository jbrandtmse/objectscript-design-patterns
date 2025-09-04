/// Gang of Four Prototype Pattern - Prototype Registry
/// <p>Manages a collection of prototype instances for cloning.</p>
/// <p>Provides centralized access to prototype objects.</p>
Class Patterns.GoF.Creational.PrototypeRegistry Extends %RegisteredObject
{

/// Collection of registered prototypes
Property prototypes As %ArrayOfObjects [ Private ];

/// Constructor - initializes the prototype collection
Method %OnNew() As %Status
{
    Set ..prototypes = ##class(%ArrayOfObjects).%New()
    Quit $$$OK
}

/// Registers a prototype with a given key
/// <param name="pKey">Unique key for the prototype</param>
/// <param name="pPrototype">Prototype instance to register</param>
/// <returns>%Status indicating success or failure</returns>
Method Register(pKey As %String, pPrototype As Patterns.GoF.Creational.Prototype) As %Status
{
    Set tSC = $$$OK
    Try {
        If pKey = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Key cannot be empty")
            Quit
        }
        If '$IsObject(pPrototype) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid prototype object")
            Quit
        }
        
        // Store the prototype
        Do ..prototypes.SetAt(pPrototype, pKey)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Unregisters a prototype
/// <param name="pKey">Key of the prototype to remove</param>
/// <returns>%Status indicating success or failure</returns>
Method Unregister(pKey As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        If pKey = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Key cannot be empty")
            Quit
        }
        
        // Remove the prototype
        Do ..prototypes.RemoveAt(pKey)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Creates a new instance by cloning a registered prototype
/// <param name="pKey">Key of the prototype to clone</param>
/// <returns>Cloned prototype instance or empty string if not found</returns>
Method Create(pKey As %String) As Patterns.GoF.Creational.Prototype
{
    Set tClone = ""
    Try {
        If pKey = "" Quit
        
        // Get the registered prototype
        Set tPrototype = ..prototypes.GetAt(pKey)
        If '$IsObject(tPrototype) Quit
        
        // Clone the prototype
        Set tClone = tPrototype.Clone()
    }
    Catch ex {
        Set tClone = ""
    }
    Quit tClone
}

/// Creates a deep clone of a registered prototype
/// <param name="pKey">Key of the prototype to deep clone</param>
/// <returns>Deep cloned prototype instance or empty string if not found</returns>
Method CreateDeepClone(pKey As %String) As Patterns.GoF.Creational.Prototype
{
    Set tClone = ""
    Try {
        If pKey = "" Quit
        
        // Get the registered prototype
        Set tPrototype = ..prototypes.GetAt(pKey)
        If '$IsObject(tPrototype) Quit
        
        // Deep clone the prototype
        Set tClone = tPrototype.DeepClone()
    }
    Catch ex {
        Set tClone = ""
    }
    Quit tClone
}

/// Checks if a prototype is registered
/// <param name="pKey">Key to check</param>
/// <returns>1 if registered, 0 otherwise</returns>
Method IsRegistered(pKey As %String) As %Boolean
{
    If pKey = "" Quit 0
    Set tPrototype = ..prototypes.GetAt(pKey)
    Quit $IsObject(tPrototype)
}

/// Gets the count of registered prototypes
/// <returns>Number of registered prototypes</returns>
Method GetCount() As %Integer
{
    Quit ..prototypes.Count()
}

/// Clears all registered prototypes
/// <returns>%Status</returns>
Method Clear() As %Status
{
    Do ..prototypes.Clear()
    Quit $$$OK
}

/// Lists all registered prototype keys
/// <returns>Comma-separated list of keys</returns>
Method ListKeys() As %String
{
    Set tKeys = ""
    Set tKey = ""
    For {
        Set tPrototype = ..prototypes.GetNext(.tKey)
        If tKey = "" Quit
        If tKeys '= "" Set tKeys = tKeys_","
        Set tKeys = tKeys_tKey
    }
    Quit tKeys
}

}
