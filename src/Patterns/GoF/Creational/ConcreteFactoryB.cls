/// Concrete Factory B - Creates ConcreteProductB instances
/// <p>This class extends the abstract FactoryMethod class to create
/// instances of ConcreteProductB. It demonstrates a different product
/// creation strategy compared to ConcreteFactoryA.</p>
Class Patterns.GoF.Creational.ConcreteFactoryB Extends Patterns.GoF.Creational.FactoryMethod
{

/// Factory name identifier
Parameter FACTORYNAME = "ConcreteFactoryB";

/// Product configuration for Factory B
Parameter PRODUCTCONFIG = "Advanced Configuration";

/// Create a ConcreteProductB instance
/// <p>This method implements the abstract CreateProduct method
/// to create instances of ConcreteProductB with specific initialization.</p>
/// <param name="pType">Optional type parameter (ignored in this implementation)</param>
/// <returns>A new instance of ConcreteProductB</returns>
Method CreateProduct(pType As %String) As Patterns.GoF.Creational.Product
{
    Set tSC = $$$OK
    Set product = ""  // Initialize return variable before Try block
    
    Try {
        // Create new ConcreteProductB instance
        Set product = ##class(Patterns.GoF.Creational.ConcreteProductB).%New()
        
        // Configure product with Factory B specific settings
        Set product.Name = "Product B-" _ $Random(10000)
        Set product.Type = "Type B"
        Set product.Priority = $Random(10) + 1  // Priority 1-10
        Set product.ConfigurationLevel = ..#PRODUCTCONFIG
        
        // Set creation timestamp
        Set product.CreatedAt = $ZDateTime($Horolog, 3)
        
        Quit  // Argumentless QUIT in Try block
    }
    Catch ex {
        // Log error and clear product
        Do ##class(%SYS.System).WriteToConsoleLog(
            "ConcreteFactoryB.CreateProduct error: " _ ex.DisplayString())
        Set product = ""
        Quit  // Argumentless QUIT in Catch block
    }
    
    Quit product  // Return the result after Try/Catch
}

/// Get factory description
/// <returns>Description of this factory</returns>
Method GetFactoryDescription() As %String
{
    Quit "Factory B - Creates advanced products with priority and configuration settings"
}

/// Validate product before returning
/// <p>Factory B performs additional validation on products</p>
/// <param name="pProduct">The product to validate</param>
/// <returns>%Status indicating validation result</returns>
Method ValidateProduct(pProduct As Patterns.GoF.Creational.Product) As %Status
{
    Set tSC = $$$OK
    
    // Check if product is ConcreteProductB
    If '$IsObject(pProduct) {
        Quit $$$ERROR($$$GeneralError, "Product is null")
    }
    
    If pProduct.%ClassName(1) '= "Patterns.GoF.Creational.ConcreteProductB" {
        Quit $$$ERROR($$$GeneralError, "Product is not ConcreteProductB")
    }
    
    // Validate priority is set
    Set productB = pProduct
    If productB.Priority = "" {
        Quit $$$ERROR($$$GeneralError, "Product priority not set")
    }
    
    Quit tSC
}

}
