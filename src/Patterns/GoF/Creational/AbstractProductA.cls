/// Abstract Product A Interface for Abstract Factory Pattern
/// 
/// This class defines the interface for type A products in a product family.
/// All concrete ProductA implementations must extend this class and implement
/// its abstract methods.
/// 
/// @see Patterns.GoF.Creational.AbstractFactory
/// @since 1.0.0
Class Patterns.GoF.Creational.AbstractProductA Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// Product type identifier
Parameter PRODUCTTYPE = "A";

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
/// This is the primary functionality that ProductA provides
/// 
/// @return %Status indicating success or failure
Method PerformOperation() As %Status [ Abstract ]
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
    // Extract family from class name (e.g., ProductA1 -> "1", ProductA2 -> "2")
    Set className = ..%ClassName(1)
    Quit $Extract(className, $Length(className))
}

}
