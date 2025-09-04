/// Helper class for testing complex property cloning
Class Patterns.GoF.Creational.ComplexObject Extends %RegisteredObject
{

/// Data value in the complex object
Property Data As %String;

/// Nested value for deep testing
Property NestedValue As %Integer [ InitialExpression = 0 ];

/// Copy from another ComplexObject
Method CopyFrom(pSource As Patterns.GoF.Creational.ComplexObject) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Data = pSource.Data
        Set ..NestedValue = pSource.NestedValue
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
