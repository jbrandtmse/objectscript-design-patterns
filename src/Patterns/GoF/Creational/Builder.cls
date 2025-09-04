/// Gang of Four Builder Pattern - Abstract Builder Interface
/// 
/// Intent:
/// Separate the construction of a complex object from its representation
/// so that the same construction process can create different representations.
/// 
/// Applicability:
/// - The algorithm for creating a complex object should be independent of the parts that make up the object and how they're assembled
/// - The construction process must allow different representations for the object that's constructed
/// 
/// Structure:
/// <example>
/// Set builder = ##class(Patterns.GoF.Creational.ConcreteBuilder).%New()
/// Do builder.BuildPartA()
/// Do builder.BuildPartB()
/// Set product = builder.GetResult()
/// </example>
/// 
/// @see Patterns.GoF.Creational.Director
/// @see Patterns.GoF.Creational.AbstractFactory
/// @since 1.0.0
Class Patterns.GoF.Creational.Builder Extends %RegisteredObject [ Abstract ]
{

/// Reset the builder to its initial state
/// This method allows builder instance reuse for constructing multiple objects
Method Reset() [ Abstract ]
{
    Quit
}

/// Build the basic structure of the product
/// This is typically the first step in construction
Method BuildPartA() [ Abstract ]
{
    Quit
}

/// Build additional components of the product
/// This adds supplementary parts to the basic structure
Method BuildPartB() [ Abstract ]
{
    Quit
}

/// Build optional components of the product
/// This adds optional features that may not be required in all products
Method BuildPartC() [ Abstract ]
{
    Quit
}

/// Get the constructed product
/// Returns the fully or partially constructed product
/// Concrete builders must override this to return their specific product type
Method GetResult() As %RegisteredObject [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Set a property value on the product being built
/// This is a helper method for fluent interface implementations
/// 
/// @param pPropertyName The name of the property to set
/// @param pValue The value to set
/// @return The builder instance for method chaining
Method SetProperty(pPropertyName As %String, pValue As %String) As Builder
{
    // Default implementation - concrete builders should override
    Quit $THIS
}

/// Validate the current state of the product being built
/// 
/// @return %Status indicating if the current build state is valid
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    // Default validation - concrete builders should override with specific rules
    
    Quit tSC
}

/// Get a description of what this builder creates
/// This is useful for documentation and debugging purposes
/// 
/// @return Description of the builder's purpose
ClassMethod GetDescription() As %String
{
    Quit "Abstract builder interface for step-by-step object construction"
}

}
