/// Gang of Four Builder Pattern - Concrete Builder 1
/// 
/// This class implements the Builder interface to construct Product1 objects.
/// It provides specific implementation for building each part of Product1
/// and supports fluent interface for method chaining.
/// 
/// <example>
/// Set builder = ##class(Patterns.GoF.Creational.ConcreteBuilder1).%New()
/// Set product = builder.BuildPartA("Component A")
///                      .BuildPartB("Component B")
///                      .BuildPartC("Component C")
///                      .GetResult()
/// </example>
/// 
/// @see Patterns.GoF.Creational.Builder
/// @see Patterns.GoF.Creational.Product1
/// @since 1.0.0
Class Patterns.GoF.Creational.ConcreteBuilder1 Extends Patterns.GoF.Creational.Builder
{

/// The product being built
Property Product As Patterns.GoF.Creational.Product1 [ Private ];

/// Constructor - initializes a new product
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..Product = ##class(Patterns.GoF.Creational.Product1).%New()
        If '$ISOBJECT(..Product) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to create Product1 instance")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Reset the builder to start building a new product
Method Reset()
{
    Set ..Product = ##class(Patterns.GoF.Creational.Product1).%New()
    Write !,"ConcreteBuilder1: Reset - Starting new Product1"
}

/// Build Part A of the product
/// 
/// @param pData Optional data for Part A
/// @return Builder instance for fluent interface
Method BuildPartA(pData As %String = "") As Patterns.GoF.Creational.Builder
{
    If pData = "" {
        Set pData = "Part A from ConcreteBuilder1"
    }
    
    Set ..Product.PartA = pData
    Write !,"ConcreteBuilder1: Built Part A = ",pData
    
    Quit $THIS
}

/// Build Part B of the product
/// 
/// @param pData Optional data for Part B
/// @return Builder instance for fluent interface
Method BuildPartB(pData As %String = "") As Patterns.GoF.Creational.Builder
{
    If pData = "" {
        Set pData = "Part B from ConcreteBuilder1"
    }
    
    Set ..Product.PartB = pData
    Write !,"ConcreteBuilder1: Built Part B = ",pData
    
    Quit $THIS
}

/// Build Part C of the product
/// 
/// @param pData Optional data for Part C
/// @return Builder instance for fluent interface
Method BuildPartC(pData As %String = "") As Patterns.GoF.Creational.Builder
{
    If pData = "" {
        Set pData = "Part C from ConcreteBuilder1"
    }
    
    Set ..Product.PartC = pData
    Write !,"ConcreteBuilder1: Built Part C = ",pData
    
    Quit $THIS
}

/// Set a specific property on the product
/// 
/// @param pName Property name
/// @param pValue Property value
/// @return Builder instance for fluent interface
Method SetProperty(pName As %String, pValue As %String) As Patterns.GoF.Creational.Builder
{
    Try {
        If pName = "PartA" {
            Set ..Product.PartA = pValue
        }
        ElseIf pName = "PartB" {
            Set ..Product.PartB = pValue
        }
        ElseIf pName = "PartC" {
            Set ..Product.PartC = pValue
        }
        ElseIf pName = "Configuration" {
            // Parse configuration as key=value
            If pValue [ "=" {
                Set tKey = $PIECE(pValue, "=", 1)
                Set tVal = $PIECE(pValue, "=", 2, *)
                Set ..Product.Configuration(tKey) = tVal
            }
        }
        ElseIf pName = "Feature" {
            Do ..Product.Features.Insert(pValue)
        }
        ElseIf pName = "Version" {
            Set ..Product.Version = pValue
        }
        ElseIf pName = "Name" {
            Set ..Product.Name = pValue
        }
        ElseIf pName = "Description" {
            Set ..Product.Description = pValue
        }
        ElseIf pName = "IsActive" {
            Set ..Product.IsActive = $SELECT(pValue="true":1, pValue="1":1, 1:0)
        }
        ElseIf pName = "Priority" {
            Set ..Product.Priority = +pValue
        }
        Else {
            Write !,"ConcreteBuilder1: Unknown property: ",pName
        }
        
        Write !,"ConcreteBuilder1: Set ",pName," = ",pValue
    }
    Catch ex {
        Write !,"ConcreteBuilder1: Error setting property ",pName,": ",ex.DisplayString()
    }
    
    Quit $THIS
}

/// Add a feature to the product
/// 
/// @param pFeature Feature to add
/// @return Builder instance for fluent interface
Method AddFeature(pFeature As %String) As Patterns.GoF.Creational.Builder
{
    If pFeature '= "" {
        Do ..Product.Features.Insert(pFeature)
        Write !,"ConcreteBuilder1: Added feature: ",pFeature
    }
    
    Quit $THIS
}

/// Set configuration for the product
/// 
/// @param pKey Configuration key
/// @param pValue Configuration value
/// @return Builder instance for fluent interface
Method SetConfiguration(pKey As %String, pValue As %String) As Patterns.GoF.Creational.Builder
{
    If pKey '= "" {
        Set ..Product.Configuration(pKey) = pValue
        Write !,"ConcreteBuilder1: Set configuration ",pKey," = ",pValue
    }
    
    Quit $THIS
}

/// Set product name
/// 
/// @param pName Product name
/// @return Builder instance for fluent interface
Method SetName(pName As %String) As Patterns.GoF.Creational.Builder
{
    Set ..Product.Name = pName
    Write !,"ConcreteBuilder1: Set name = ",pName
    
    Quit $THIS
}

/// Set product version
/// 
/// @param pVersion Version string
/// @return Builder instance for fluent interface
Method SetVersion(pVersion As %String) As Patterns.GoF.Creational.Builder
{
    Set ..Product.Version = pVersion
    Write !,"ConcreteBuilder1: Set version = ",pVersion
    
    Quit $THIS
}

/// Set product description
/// 
/// @param pDescription Description text
/// @return Builder instance for fluent interface
Method SetDescription(pDescription As %String) As Patterns.GoF.Creational.Builder
{
    Set ..Product.Description = pDescription
    Write !,"ConcreteBuilder1: Set description = ",pDescription
    
    Quit $THIS
}

/// Validate the product before returning it
/// 
/// @return %Status indicating if validation passed
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '$ISOBJECT(..Product) {
            Set tSC = $$$ERROR($$$GeneralError, "No product to validate")
            Quit
        }
        
        // Check if product is complete
        If '..Product.IsComplete() {
            Set tSC = $$$ERROR($$$GeneralError, "Product is not complete - missing required parts")
            Quit
        }
        
        Write !,"ConcreteBuilder1: Product validation successful"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the constructed product and reset the builder
/// 
/// @return The constructed Product1 instance
Method GetResult() As %RegisteredObject
{
    Set tProduct = ..Product
    
    // Validate before returning
    Set tSC = ..Validate()
    If $$$ISERR(tSC) {
        Write !,"ConcreteBuilder1: Warning - returning incomplete product"
    }
    
    // Reset for next build
    Do ..Reset()
    
    Quit tProduct
}

/// Build a complete product with all parts
/// 
/// @param pName Product name
/// @param pVersion Product version
/// @return Builder instance for fluent interface
Method BuildComplete(pName As %String = "Product1", pVersion As %String = "1.0") As Patterns.GoF.Creational.Builder
{
    Do ..Reset()
    
    // Build complete product with method chaining
    Do ..SetName(pName)
    Do ..SetVersion(pVersion)
    Do ..BuildPartA("Complete Part A")
    Do ..BuildPartB("Complete Part B")
    Do ..BuildPartC("Complete Part C")
    Do ..AddFeature("Feature 1")
    Do ..AddFeature("Feature 2")
    Do ..SetConfiguration("mode", "production")
    Do ..SetConfiguration("debug", "false")
    Do ..SetDescription("A complete Product1 built by ConcreteBuilder1")
    
    Write !,"ConcreteBuilder1: Built complete product"
    
    Quit $THIS
}

/// Build a minimal product with only required parts
/// 
/// @return Builder instance for fluent interface
Method BuildMinimal() As Patterns.GoF.Creational.Builder
{
    Do ..Reset()
    
    Do ..BuildPartA("Minimal Part A")
    
    Write !,"ConcreteBuilder1: Built minimal product"
    
    Quit $THIS
}

/// Display information about the current product being built
Method DisplayProgress()
{
    Write !,"=== ConcreteBuilder1 Progress ==="
    
    If '$ISOBJECT(..Product) {
        Write !,"No product in progress"
    }
    Else {
        Write !,"Building Product1:"
        Write !,"  Name: ",..Product.Name
        Write !,"  Version: ",..Product.Version
        Write !,"  Part A: ",..Product.PartA
        Write !,"  Part B: ",..Product.PartB
        Write !,"  Part C: ",..Product.PartC
        Write !,"  Features: ",..Product.Features.Count()," items"
        Write !,"  Complete: ",$SELECT(..Product.IsComplete():"Yes", 1:"No")
    }
    
    Write !,"================================="
}

}
