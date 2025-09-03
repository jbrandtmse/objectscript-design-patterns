/// Concrete Factory 2 Implementation for Abstract Factory Pattern
/// 
/// This factory creates the second family of products (ProductA2 and ProductB2).
/// All products created by this factory are designed to work together.
/// 
/// @see Patterns.GoF.Creational.AbstractFactory
/// @see Patterns.GoF.Creational.ProductA2
/// @see Patterns.GoF.Creational.ProductB2
/// @since 1.0.0
Class Patterns.GoF.Creational.ConcreteFactory2 Extends Patterns.GoF.Creational.AbstractFactory
{

// ===== PARAMETERS =====

/// Factory family identifier
Parameter FACTORYFAMILY = 2;

/// Factory style description
Parameter FACTORYSTYLE = "Classic";

// ===== PUBLIC METHODS =====

/// Creates a ProductA2 instance
/// 
/// @return Instance of ProductA2
Method CreateProductA() As AbstractProductA
{
    Set product = ##class(Patterns.GoF.Creational.ProductA2).%New()
    Quit product
}

/// Creates a ProductB2 instance
/// 
/// @return Instance of ProductB2
Method CreateProductB() As AbstractProductB
{
    Set product = ##class(Patterns.GoF.Creational.ProductB2).%New()
    Quit product
}

/// Gets factory-specific information
/// 
/// @return Factory description
Method GetFactoryDescription() As %String
{
    Quit "ConcreteFactory2 - Creates " _ ..#FACTORYSTYLE _ " style products (Family " _ ..#FACTORYFAMILY _ ")"
}

}
