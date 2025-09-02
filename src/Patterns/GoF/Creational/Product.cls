/// Base Product class that all products must extend
/// Part of the Factory Method pattern implementation
/// 
/// This abstract class defines the interface for products
/// created by factory methods. All concrete products must
/// extend this class and implement the Operation() method.
/// 
/// @see Patterns.GoF.Creational.FactoryMethod
/// @since 1.0.0
Class Patterns.GoF.Creational.Product Extends %RegisteredObject [ Abstract ]
{

/// Product name
Property Name As %String;

/// Product type
Property Type As %String;

/// Creation timestamp
Property CreatedAt As %TimeStamp;

/// Initialize the product
/// Called automatically after product creation by the factory
Method Initialize() As %Status
{
    Set ..CreatedAt = $ZDateTime($H, 3)
    Quit $$$OK
}

/// Abstract operation that products must implement
/// This is the main behavior that varies between product types
Method Operation() As %String [ Abstract ]
{
    // Abstract method - must be implemented by subclasses
}

/// Get product description
Method GetDescription() As %String
{
    Quit "Product: " _ ..Name _ " (Type: " _ ..Type _ ") created at " _ ..CreatedAt
}

}
