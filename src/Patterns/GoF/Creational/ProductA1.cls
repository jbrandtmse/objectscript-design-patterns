/// Concrete Product A1 Implementation for Abstract Factory Pattern
/// 
/// This is the first family's implementation of ProductA.
/// It is designed to work with ProductB1 from the same family.
/// 
/// @see Patterns.GoF.Creational.AbstractProductA
/// @see Patterns.GoF.Creational.ProductB1
/// @since 1.0.0
Class Patterns.GoF.Creational.ProductA1 Extends Patterns.GoF.Creational.AbstractProductA
{

// ===== PARAMETERS =====

/// Product family identifier
Parameter FAMILY = 1;

/// Product style
Parameter STYLE = "Modern";

// ===== PROPERTIES =====

/// Product-specific data
Property Data As %String [ InitialExpression = "ProductA1 Data" ];

// ===== PUBLIC METHODS =====

/// Gets the description of this product
/// 
/// @return Product description string
Method GetDescription() As %String
{
    Quit "ProductA1: " _ ..#STYLE _ " style product from Family " _ ..#FAMILY
}

/// Performs the main operation for this product
/// 
/// @return %Status indicating success or failure
Method PerformOperation() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "ProductA1 performing ", ..#STYLE, " operation...", !
        Write "Processing data: ", ..Data, !
        
        // Simulate some work
        Hang 0.1
        
        Write "ProductA1 operation completed successfully", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Gets compatibility information for this product
/// 
/// @return Compatibility information string
Method GetCompatibilityInfo() As %String
{
    Quit "Compatible with Family " _ ..#FAMILY _ " products (" _ ..#STYLE _ " style)"
}

/// Returns the product family for this implementation
/// 
/// @return Product family identifier
Method GetProductFamily() As %String
{
    Quit ..#FAMILY
}

}
