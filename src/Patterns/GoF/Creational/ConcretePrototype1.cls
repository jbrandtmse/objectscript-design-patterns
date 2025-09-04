/// Gang of Four Prototype Pattern - Concrete Prototype 1
/// <p>Demonstrates cloning with both simple and complex properties.</p>
/// <p>Shows the difference between shallow and deep cloning.</p>
Class Patterns.GoF.Creational.ConcretePrototype1 Extends Patterns.GoF.Creational.Prototype
{

/// A simple string property
Property SimpleProperty As %String;

/// A complex property referencing another object
Property ComplexProperty As Patterns.GoF.Creational.ComplexObject;

/// An integer property for testing
Property IntegerValue As %Integer [ InitialExpression = 0 ];

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

/// Creates a deep clone using serialization
/// <returns>A new instance with deep copy of all properties</returns>
Method DeepClone() As Patterns.GoF.Creational.Prototype
{
    Set tClone = ""
    Try {
        // Serialize this object to a stream
        Set tStream = ##class(%Stream.GlobalCharacter).%New()
        Set tSC = ..%SerializeObject(tStream)
        If $$$ISERR(tSC) Quit
        
        // Reset stream position
        Do tStream.Rewind()
        
        // Create new instance and deserialize
        Set tClone = ##class(Patterns.GoF.Creational.ConcretePrototype1).%New()
        Set tSC = tClone.%DeserializeObject(tStream)
        If $$$ISERR(tSC) {
            Set tClone = ""
            Quit
        }
        
        // Deep clone the complex property if it exists
        If $IsObject(..ComplexProperty) {
            Set tClone.ComplexProperty = ##class(Patterns.GoF.Creational.ComplexObject).%New()
            Do tClone.ComplexProperty.CopyFrom(..ComplexProperty)
        }
        
        // Initialize after deep clone
        Do tClone.InitializeAfterClone()
    }
    Catch ex {
        Set tClone = ""
    }
    
    Quit tClone
}

/// Copies properties from another ConcretePrototype1
/// <param name="pSource">Source object to copy from</param>
/// <returns>%Status</returns>
Method CopyFrom(pSource As Patterns.GoF.Creational.Prototype) As %Status
{
    Set tSC = $$$OK
    Try {
        // Check if source is correct type
        If 'pSource.%IsA("Patterns.GoF.Creational.ConcretePrototype1") {
            Set tSC = $$$ERROR($$$GeneralError, "Source must be ConcretePrototype1")
            Quit
        }
        
        // Copy simple properties
        Set ..SimpleProperty = pSource.SimpleProperty
        Set ..IntegerValue = pSource.IntegerValue
        
        // Copy complex property (shallow)
        Set ..ComplexProperty = pSource.ComplexProperty
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Sets initial values for testing
/// <param name="pSimple">Simple property value</param>
/// <param name="pInteger">Integer value</param>
/// <returns>%Status</returns>
Method SetTestValues(pSimple As %String = "", pInteger As %Integer = 0) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..SimpleProperty = pSimple
        Set ..IntegerValue = pInteger
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
