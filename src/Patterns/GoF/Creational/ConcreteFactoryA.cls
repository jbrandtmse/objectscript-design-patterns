/// Concrete Factory A Implementation
/// Creates Type A products
/// 
/// This concrete factory demonstrates one variation of the Factory Method pattern
/// where the factory creates a specific type of product (ConcreteProductA)
/// 
/// @see Patterns.GoF.Creational.FactoryMethod
/// @see Patterns.GoF.Creational.ConcreteProductA
/// @since 1.0.0
Class Patterns.GoF.Creational.ConcreteFactoryA Extends Patterns.GoF.Creational.FactoryMethod
{

/// Create a Type A product
/// This method implements the abstract CreateProduct method from the base class
/// 
/// @param pType Optional type parameter (ignored in this implementation)
/// @return ConcreteProductA instance
Method CreateProduct(pType As %String) As Patterns.GoF.Creational.Product
{
    Set product = ##class(Patterns.GoF.Creational.ConcreteProductA).%New()
    Set product.Name = "Product A-" _ $Random(1000)
    Set product.Type = "TypeA"
    Quit product
}

/// Get factory description
Method GetFactoryType() As %String
{
    Quit "ConcreteFactoryA - Creates Type A Products"
}

}
