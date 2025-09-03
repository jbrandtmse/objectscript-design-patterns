/// Gang of Four Abstract Factory Pattern Implementation
/// 
/// Intent:
/// Provide an interface for creating families of related or dependent objects
/// without specifying their concrete classes.
/// 
/// Applicability:
/// - A system should be independent of how its products are created, composed, and represented
/// - A system should be configured with one of multiple families of products
/// - A family of related product objects is designed to be used together
/// - You want to provide a class library of products revealing just their interfaces
/// 
/// Structure:
/// <example>
/// Set factory = ##class(Patterns.GoF.Creational.ConcreteFactory1).%New()
/// Set productA = factory.CreateProductA()
/// Set productB = factory.CreateProductB()
/// </example>
/// 
/// @see Patterns.GoF.Creational.FactoryMethod
/// @since 1.0.0
Class Patterns.GoF.Creational.AbstractFactory Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// Pattern type identifier
Parameter PATTERNTYPE = "Creational";

/// Pattern name
Parameter PATTERNNAME = "Abstract Factory";

// ===== PUBLIC METHODS =====

/// Creates a product of type A in the product family
/// 
/// This method must be implemented by concrete factories to create
/// their specific version of ProductA
/// 
/// @return Instance of AbstractProductA or null on error
Method CreateProductA() As AbstractProductA [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Creates a product of type B in the product family
/// 
/// This method must be implemented by concrete factories to create
/// their specific version of ProductB
/// 
/// @return Instance of AbstractProductB or null on error
Method CreateProductB() As AbstractProductB [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Demonstrates the use of the factory to create a family of products
/// 
/// This method shows how products from the same factory work together
/// 
/// @return %Status indicating success or failure
Method DemonstrateProductFamily() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create products from this factory
        Set productA = ..CreateProductA()
        If '$IsObject(productA) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to create ProductA")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Set productB = ..CreateProductB()
        If '$IsObject(productB) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to create ProductB")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Demonstrate product interaction
        Write "Created product family from ", ..%ClassName(1), !
        Write "ProductA: ", productA.GetDescription(), !
        Write "ProductB: ", productB.GetDescription(), !
        
        // Products from same factory should work together
        Set tSC = productB.InteractWithProductA(productA)
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Gets information about this factory
/// 
/// @return Factory description string
Method GetFactoryInfo() As %String
{
    Quit "Abstract Factory: " _ ..%ClassName(1) _ " (Type: " _ ..#PATTERNTYPE _ ", Pattern: " _ ..#PATTERNNAME _ ")"
}

}
