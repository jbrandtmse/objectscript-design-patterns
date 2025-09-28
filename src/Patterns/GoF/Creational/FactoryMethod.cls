/// Gang of Four Factory Method Pattern Implementation
/// 
/// Intent:
/// Define an interface for creating an object, but let subclasses decide which class to instantiate.
/// Factory Method lets a class defer instantiation to subclasses.
/// 
/// Also Known As:
/// Virtual Constructor
/// 
/// Applicability:
/// - A class can't anticipate the class of objects it must create
/// - A class wants its subclasses to specify the objects it creates
/// - Classes delegate responsibility to one of several helper subclasses
/// 
/// Structure:
/// <example>
/// Set factory = ##class(ConcreteFactory).%New()
/// Set product = factory.FactoryMethod()
/// Do product.Operation()
/// </example>
/// 
/// @see Patterns.GoF.Creational.AbstractFactory
/// @see Patterns.GoF.Creational.Prototype
/// @since 1.0.0
Class Patterns.GoF.Creational.FactoryMethod Extends %RegisteredObject [ Abstract ]
{

/// ===== PARAMETERS =====
Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Creational";

/// ===== PROPERTIES =====
/// Product counter for tracking created products
Property ProductCount As %Integer [ InitialExpression = 0 ];

/// Configuration for factory behavior
Property TrackProducts As %Boolean [ InitialExpression = 0 ];

/// ===== PUBLIC METHODS =====
/// Main factory method that creates products
/// This method uses the abstract CreateProduct() method which must be
/// implemented by concrete factory subclasses
/// 
/// @param pType Optional type parameter for product creation
/// @return Product instance created by the concrete factory
Method FactoryMethod(pType As %String = "") As Patterns.GoF.Creational.Product
{
    // Delegate to the abstract method that subclasses must implement
    Set product = ..CreateProduct(pType)
    
    // Perform any common initialization
    If $IsObject(product) {
        Do product.Initialize()
        
        // Track the product if needed
        If ..TrackProducts {
            Set ..ProductCount = ..ProductCount + 1
        }
    }
    
    Quit product
}

/// Abstract method that must be implemented by concrete factories
/// This is the core of the Factory Method pattern - subclasses decide
/// which class to instantiate
/// 
/// @param pType Type of product to create
/// @return Product instance
Method CreateProduct(pType As %String) As Patterns.GoF.Creational.Product [ Abstract ]
{
    // Abstract method - must return null object reference
    // Concrete subclasses will override with actual implementation
    Quit $$$NULLOREF
}

/// Initialize the factory with optional configuration
Method %OnNew(pTrackProducts As %Boolean = 0) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize configuration
        Set ..TrackProducts = pTrackProducts
        Set ..ProductCount = 0
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get count of products created by this factory
Method GetProductCount() As %Integer
{
    Quit ..ProductCount
}

/// Clear the product counter
Method ClearCounter() As %Status
{
    Set ..ProductCount = 0
    Quit $$$OK
}

}
