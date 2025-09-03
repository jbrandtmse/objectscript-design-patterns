/// Concrete Factory 1 Implementation for Abstract Factory Pattern
/// 
/// This factory creates the first family of products (ProductA1 and ProductB1).
/// All products created by this factory are designed to work together.
/// 
/// @see Patterns.GoF.Creational.AbstractFactory
/// @see Patterns.GoF.Creational.ProductA1
/// @see Patterns.GoF.Creational.ProductB1
/// @since 1.0.0
Class Patterns.GoF.Creational.ConcreteFactory1 Extends Patterns.GoF.Creational.AbstractFactory
{

// ===== PARAMETERS =====

/// Factory family identifier
Parameter FACTORYFAMILY = 1;

/// Factory style description
Parameter FACTORYSTYLE = "Modern";

// ===== PUBLIC METHODS =====

/// Creates a ProductA1 instance
/// 
/// @return Instance of ProductA1
Method CreateProductA() As AbstractProductA
{
    Set product = ##class(Patterns.GoF.Creational.ProductA1).%New()
    Quit product
}

/// Creates a ProductB1 instance
/// 
/// @return Instance of ProductB1
Method CreateProductB() As AbstractProductB
{
    Set product = ##class(Patterns.GoF.Creational.ProductB1).%New()
    Quit product
}

/// Gets factory-specific information
/// 
/// @return Factory description
Method GetFactoryDescription() As %String
{
    Quit "ConcreteFactory1 - Creates " _ ..#FACTORYSTYLE _ " style products (Family " _ ..#FACTORYFAMILY _ ")"
}

}
