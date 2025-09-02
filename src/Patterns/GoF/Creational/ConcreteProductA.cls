/// Concrete Product A Implementation
/// Represents a specific type of product created by ConcreteFactoryA
/// 
/// This concrete product demonstrates one variation of products
/// that can be created by the Factory Method pattern
/// 
/// @see Patterns.GoF.Creational.Product
/// @see Patterns.GoF.Creational.ConcreteFactoryA
/// @since 1.0.0
Class Patterns.GoF.Creational.ConcreteProductA Extends Patterns.GoF.Creational.Product
{

/// Specific property for Product A
Property SpecialFeatureA As %String;

/// Initialize Product A with its special features
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..SpecialFeatureA = "Advanced Feature A"
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Implementation of abstract Operation method
/// Performs the specific operation for Product A
Method Operation() As %String
{
    // Product A specific operation
    Write !, "ConcreteProductA Operation:"
    Write !, "  - Name: ", ..Name
    Write !, "  - Type: ", ..Type
    Write !, "  - Special Feature: ", ..SpecialFeatureA
    Write !, "  - Created: ", ..CreatedAt
    
    Quit "ConcreteProductA Operation"
}

/// Process data specific to Product A
Method ProcessData(pData As %String) As %String
{
    Quit "ProductA processed: " _ pData _ " with " _ ..SpecialFeatureA
}

/// Get product-specific information
Method GetProductInfo() As %DynamicObject
{
    Set info = {}
    Set info.name = ..Name
    Set info.type = ..Type
    Set info.feature = ..SpecialFeatureA
    Set info.created = ..CreatedAt
    Quit info
}

}
