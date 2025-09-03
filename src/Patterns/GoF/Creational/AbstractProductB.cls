/// Abstract Product B Interface for Abstract Factory Pattern
/// 
/// This class defines the interface for type B products in a product family.
/// All concrete ProductB implementations must extend this class and implement
/// its abstract methods. ProductB instances must be able to interact with
/// ProductA instances from the same family.
/// 
/// @see Patterns.GoF.Creational.AbstractFactory
/// @see Patterns.GoF.Creational.AbstractProductA
/// @since 1.0.0
Class Patterns.GoF.Creational.AbstractProductB Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// Product type identifier
Parameter PRODUCTTYPE = "B";

// ===== PUBLIC METHODS =====

/// Gets the description of this product
/// 
/// Each concrete product must provide its own description
/// 
/// @return Product description string
Method GetDescription() As %String [ Abstract ]
{
    Quit ""
}

/// Performs the main operation for this product
/// 
/// This is the primary functionality that ProductB provides
/// 
/// @return %Status indicating success or failure
Method PerformOperation() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Interacts with a ProductA from the same family
/// 
/// This method demonstrates how products from the same family work together.
/// Products from different families should not be compatible.
/// 
/// @param pProductA Instance of AbstractProductA to interact with
/// @return %Status indicating success or failure of interaction
Method InteractWithProductA(pProductA As AbstractProductA) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Gets compatibility information for this product
/// 
/// Returns information about which product families this product belongs to
/// 
/// @return Compatibility information string
Method GetCompatibilityInfo() As %String [ Abstract ]
{
    Quit ""
}

/// Validates that this product is properly configured
/// 
/// @return %Boolean True if valid, False otherwise
Method IsValid() As %Boolean
{
    // Base validation - can be overridden by subclasses
    Quit ($IsObject($This) && (..GetDescription() '= ""))
}

/// Gets the product family identifier
/// 
/// @return Product family name
Method GetProductFamily() As %String
{
    // Extract family from class name (e.g., ProductB1 -> "1", ProductB2 -> "2")
    Set className = ..%ClassName(1)
    Quit $Extract(className, $Length(className))
}

/// Checks if this ProductB is compatible with a given ProductA
/// 
/// Products are compatible if they belong to the same family
/// 
/// @param pProductA ProductA instance to check compatibility with
/// @return %Boolean True if compatible, False otherwise
Method IsCompatibleWith(pProductA As AbstractProductA) As %Boolean
{
    If '$IsObject(pProductA) Quit 0
    
    // Products are compatible if they're from the same family
    Quit (..GetProductFamily() = pProductA.GetProductFamily())
}

}
