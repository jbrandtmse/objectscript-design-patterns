/// Concrete Product B2 Implementation for Abstract Factory Pattern
/// 
/// This is the second family's implementation of ProductB.
/// It is designed to work with ProductA2 from the same family.
/// 
/// @see Patterns.GoF.Creational.AbstractProductB
/// @see Patterns.GoF.Creational.ProductA2
/// @since 1.0.0
Class Patterns.GoF.Creational.ProductB2 Extends Patterns.GoF.Creational.AbstractProductB
{

// ===== PARAMETERS =====

/// Product family identifier
Parameter FAMILY = 2;

/// Product style
Parameter STYLE = "Classic";

// ===== PROPERTIES =====

/// Product-specific data
Property Data As %String [ InitialExpression = "ProductB2 Data" ];

/// Interaction count with ProductA
Property InteractionCount As %Integer [ InitialExpression = 0 ];

// ===== PUBLIC METHODS =====

/// Gets the description of this product
/// 
/// @return Product description string
Method GetDescription() As %String
{
    Quit "ProductB2: " _ ..#STYLE _ " style product from Family " _ ..#FAMILY
}

/// Performs the main operation for this product
/// 
/// @return %Status indicating success or failure
Method PerformOperation() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "ProductB2 performing ", ..#STYLE, " operation...", !
        Write "Processing data: ", ..Data, !
        Write "Interactions completed: ", ..InteractionCount, !
        
        // Simulate some work
        Hang 0.1
        
        Write "ProductB2 operation completed successfully", !
        
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
            Set tSC = $$$ERROR($$$GeneralError, "ProductB2 (Family " _ ..#FAMILY _ ") is not compatible with " _ pProductA.GetDescription())
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Perform interaction
        Write "ProductB2 interacting with ", pProductA.GetDescription(), !
        Write "Products are from the same ", ..#STYLE, " family - interaction successful!", !
        
        Set ..InteractionCount = ..InteractionCount + 1
        
        // Simulate collaborative operation
        Set tSC = pProductA.PerformOperation()
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Write "Collaborative operation between ProductB2 and ", pProductA.GetDescription(), " completed", !
        
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
