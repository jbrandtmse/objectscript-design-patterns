/// Concrete Product B1 Implementation for Abstract Factory Pattern
/// 
/// This is the first family's implementation of ProductB.
/// It is designed to work with ProductA1 from the same family.
/// 
/// @see Patterns.GoF.Creational.AbstractProductB
/// @see Patterns.GoF.Creational.ProductA1
/// @since 1.0.0
Class Patterns.GoF.Creational.ProductB1 Extends Patterns.GoF.Creational.AbstractProductB
{

// ===== PARAMETERS =====

/// Product family identifier
Parameter FAMILY = 1;

/// Product style
Parameter STYLE = "Modern";

// ===== PROPERTIES =====

/// Product-specific data
Property Data As %String [ InitialExpression = "ProductB1 Data" ];

/// Interaction count with ProductA
Property InteractionCount As %Integer [ InitialExpression = 0 ];

// ===== PUBLIC METHODS =====

/// Gets the description of this product
/// 
/// @return Product description string
Method GetDescription() As %String
{
    Quit "ProductB1: " _ ..#STYLE _ " style product from Family " _ ..#FAMILY
}

/// Performs the main operation for this product
/// 
/// @return %Status indicating success or failure
Method PerformOperation() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "ProductB1 performing ", ..#STYLE, " operation...", !
        Write "Processing data: ", ..Data, !
        Write "Interactions completed: ", ..InteractionCount, !
        
        // Simulate some work
        Hang 0.1
        
        Write "ProductB1 operation completed successfully", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Interacts with a ProductA from the same family
/// 
/// @param pProductA Instance of AbstractProductA to interact with
/// @return %Status indicating success or failure of interaction
Method InteractWithProductA(pProductA As AbstractProductA) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate input
        If '$IsObject(pProductA) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid ProductA object")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Check compatibility
        If '..IsCompatibleWith(pProductA) {
            Set tSC = $$$ERROR($$$GeneralError, "ProductB1 (Family " _ ..#FAMILY _ ") is not compatible with " _ pProductA.GetDescription())
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Perform interaction
        Write "ProductB1 interacting with ", pProductA.GetDescription(), !
        Write "Products are from the same ", ..#STYLE, " family - interaction successful!", !
        
        Set ..InteractionCount = ..InteractionCount + 1
        
        // Simulate collaborative operation
        Set tSC = pProductA.PerformOperation()
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Write "Collaborative operation between ProductB1 and ", pProductA.GetDescription(), " completed", !
        
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
