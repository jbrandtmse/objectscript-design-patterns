/// Gang of Four Builder Pattern - Concrete Builder 2
/// 
/// This class implements the Builder interface to construct Product2 objects.
/// It demonstrates a different implementation approach for building products
/// with different structure than Product1.
/// 
/// <example>
/// Set builder = ##class(Patterns.GoF.Creational.ConcreteBuilder2).%New()
/// Set product = builder.AddComponent("Engine")
///                      .AddComponent("Wheels")
///                      .SetMetadata("type", "vehicle")
///                      .GetResult()
/// </example>
/// 
/// @see Patterns.GoF.Creational.Builder
/// @see Patterns.GoF.Creational.Product2
/// @since 1.0.0
Class Patterns.GoF.Creational.ConcreteBuilder2 Extends Patterns.GoF.Creational.Builder
{

/// The product being built
Property Product As Patterns.GoF.Creational.Product2 [ Private ];

/// Constructor - initializes a new product
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..Product = ##class(Patterns.GoF.Creational.Product2).%New()
        If '$ISOBJECT(..Product) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to create Product2 instance")
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
    Set ..Product = ##class(Patterns.GoF.Creational.Product2).%New()
    Write !,"ConcreteBuilder2: Reset - Starting new Product2"
}

/// Build Part A - translates to adding a component
/// 
/// @param pData Optional data for component
/// @return Builder instance for fluent interface
Method BuildPartA(pData As %String = "") As Patterns.GoF.Creational.Builder
{
    If pData = "" {
        Set pData = "Component A from ConcreteBuilder2"
    }
    
    Do ..Product.AddComponent(pData)
    Write !,"ConcreteBuilder2: Added component (Part A) = ",pData
    
    Quit $THIS
}

/// Build Part B - translates to adding another component
/// 
/// @param pData Optional data for component
/// @return Builder instance for fluent interface
Method BuildPartB(pData As %String = "") As Patterns.GoF.Creational.Builder
{
    If pData = "" {
        Set pData = "Component B from ConcreteBuilder2"
    }
    
    Do ..Product.AddComponent(pData)
    Write !,"ConcreteBuilder2: Added component (Part B) = ",pData
    
    Quit $THIS
}

/// Build Part C - translates to adding configuration component
/// 
/// @param pData Optional data for configuration
/// @return Builder instance for fluent interface
Method BuildPartC(pData As %String = "") As Patterns.GoF.Creational.Builder
{
    If pData = "" {
        Set pData = "Component C from ConcreteBuilder2"
    }
    
    Do ..Product.AddComponent(pData)
    Write !,"ConcreteBuilder2: Added component (Part C) = ",pData
    
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
        If pName = "ProductId" {
            Set ..Product.ProductId = pValue
        }
        ElseIf pName = "Category" {
            Set ..Product.Category = pValue
        }
        ElseIf pName = "Priority" {
            Set ..Product.Priority = +pValue
        }
        ElseIf pName = "Status" {
            Set ..Product.Status = pValue
        }
        ElseIf pName = "Notes" {
            Set ..Product.Notes = pValue
        }
        ElseIf pName = "Component" {
            Do ..Product.AddComponent(pValue)
        }
        ElseIf pName = "Tag" {
            Do ..Product.AddTag(pValue)
        }
        ElseIf pName = "Metadata" {
            // Parse as key=value
            If pValue [ "=" {
                Set tKey = $PIECE(pValue, "=", 1)
                Set tVal = $PIECE(pValue, "=", 2, *)
                Do ..Product.AddMetadata(tKey, tVal)
            }
        }
        Else {
            Write !,"ConcreteBuilder2: Unknown property: ",pName
        }
        
        Write !,"ConcreteBuilder2: Set ",pName," = ",pValue
    }
    Catch ex {
        Write !,"ConcreteBuilder2: Error setting property ",pName,": ",ex.DisplayString()
    }
    
    Quit $THIS
}

/// Add a component to the product
/// 
/// @param pComponent Component to add
/// @return Builder instance for fluent interface
Method AddComponent(pComponent As %String) As Patterns.GoF.Creational.Builder
{
    If pComponent '= "" {
        Do ..Product.AddComponent(pComponent)
        Write !,"ConcreteBuilder2: Added component: ",pComponent
    }
    
    Quit $THIS
}

/// Add metadata to the product
/// 
/// @param pKey Metadata key
/// @param pValue Metadata value
/// @return Builder instance for fluent interface
Method AddMetadata(pKey As %String, pValue As %String) As Patterns.GoF.Creational.Builder
{
    If pKey '= "" {
        Do ..Product.AddMetadata(pKey, pValue)
        Write !,"ConcreteBuilder2: Added metadata ",pKey," = ",pValue
    }
    
    Quit $THIS
}

/// Add a tag to the product
/// 
/// @param pTag Tag to add
/// @return Builder instance for fluent interface
Method AddTag(pTag As %String) As Patterns.GoF.Creational.Builder
{
    If pTag '= "" {
        Do ..Product.AddTag(pTag)
        Write !,"ConcreteBuilder2: Added tag: ",pTag
    }
    
    Quit $THIS
}

/// Set product ID
/// 
/// @param pId Product identifier
/// @return Builder instance for fluent interface
Method SetProductId(pId As %String) As Patterns.GoF.Creational.Builder
{
    Set ..Product.ProductId = pId
    Write !,"ConcreteBuilder2: Set product ID = ",pId
    
    Quit $THIS
}

/// Set product category
/// 
/// @param pCategory Category name
/// @return Builder instance for fluent interface
Method SetCategory(pCategory As %String) As Patterns.GoF.Creational.Builder
{
    Set ..Product.Category = pCategory
    Write !,"ConcreteBuilder2: Set category = ",pCategory
    
    Quit $THIS
}

/// Set product priority
/// 
/// @param pPriority Priority level (1-5)
/// @return Builder instance for fluent interface
Method SetPriority(pPriority As %Integer) As Patterns.GoF.Creational.Builder
{
    Set ..Product.Priority = pPriority
    Write !,"ConcreteBuilder2: Set priority = ",pPriority
    
    Quit $THIS
}

/// Set product status
/// 
/// @param pStatus Status value
/// @return Builder instance for fluent interface
Method SetStatus(pStatus As %String) As Patterns.GoF.Creational.Builder
{
    Do ..Product.UpdateStatus(pStatus)
    Write !,"ConcreteBuilder2: Set status = ",pStatus
    
    Quit $THIS
}

/// Set product notes
/// 
/// @param pNotes Notes text
/// @return Builder instance for fluent interface
Method SetNotes(pNotes As %String) As Patterns.GoF.Creational.Builder
{
    Set ..Product.Notes = pNotes
    Write !,"ConcreteBuilder2: Set notes = ",pNotes
    
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
            Set tSC = $$$ERROR($$$GeneralError, "Product is not complete - requires ProductId and at least one component")
            Quit
        }
        
        Write !,"ConcreteBuilder2: Product validation successful"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the constructed product and reset the builder
/// 
/// @return The constructed Product2 instance
Method GetResult() As %RegisteredObject
{
    Set tProduct = ..Product
    
    // Validate before returning
    Set tSC = ..Validate()
    If $$$ISERR(tSC) {
        Write !,"ConcreteBuilder2: Warning - returning incomplete product"
    }
    
    // Reset for next build
    Do ..Reset()
    
    Quit tProduct
}

/// Build a complete product with all components
/// 
/// @param pId Product ID
/// @param pCategory Product category
/// @return Builder instance for fluent interface
Method BuildComplete(pId As %String = "PROD2", pCategory As %String = "Standard") As Patterns.GoF.Creational.Builder
{
    Do ..Reset()
    
    // Build complete product
    Do ..SetProductId(pId)
    Do ..SetCategory(pCategory)
    Do ..SetPriority(1)
    Do ..AddComponent("Core Module")
    Do ..AddComponent("Processing Unit")
    Do ..AddComponent("Interface Module")
    Do ..AddMetadata("version", "2.0")
    Do ..AddMetadata("environment", "production")
    Do ..AddTag("enterprise")
    Do ..AddTag("critical")
    Do ..SetStatus("Ready")
    Do ..SetNotes("Complete Product2 built by ConcreteBuilder2")
    
    Write !,"ConcreteBuilder2: Built complete product"
    
    Quit $THIS
}

/// Build a minimal product with only required components
/// 
/// @return Builder instance for fluent interface
Method BuildMinimal() As Patterns.GoF.Creational.Builder
{
    Do ..Reset()
    
    Do ..SetProductId("MINIMAL2")
    Do ..AddComponent("Basic Component")
    
    Write !,"ConcreteBuilder2: Built minimal product"
    
    Quit $THIS
}

/// Build a specialized product with specific configuration
/// 
/// @param pType Specialization type
/// @return The constructed Product2 instance
Method BuildSpecialized(pType As %String = "Advanced") As Patterns.GoF.Creational.Product2
{
    Do ..Reset()
    
    Do ..SetProductId("SPEC-"_pType)
    Do ..SetCategory(pType)
    Do ..SetPriority(2)
    
    If pType = "Advanced" {
        Do ..AddComponent("Advanced Processing")
        Do ..AddComponent("Analytics Module")
        Do ..AddComponent("Optimization Engine")
        Do ..AddTag("advanced")
        Do ..AddTag("analytics")
        Do ..AddMetadata("capabilities", "full")
    }
    ElseIf pType = "Basic" {
        Do ..AddComponent("Basic Processing")
        Do ..AddTag("basic")
        Do ..AddMetadata("capabilities", "limited")
    }
    Else {
        Do ..AddComponent("Standard Processing")
        Do ..AddTag("standard")
        Do ..AddMetadata("capabilities", "standard")
    }
    
    Do ..SetStatus("Configured")
    Do ..SetNotes("Specialized "_pType_" product")
    
    Write !,"ConcreteBuilder2: Built specialized ",pType," product"
    
    // Return the actual product, not the builder
    Quit ..GetResult()
}

/// Display information about the current product being built
Method DisplayProgress()
{
    Write !,"=== ConcreteBuilder2 Progress ==="
    
    If '$ISOBJECT(..Product) {
        Write !,"No product in progress"
    }
    Else {
        Write !,"Building Product2:"
        Write !,"  Product ID: ",..Product.ProductId
        Write !,"  Category: ",..Product.Category
        Write !,"  Priority: ",..Product.Priority
        Write !,"  Status: ",..Product.Status
        Write !,"  Components: ",..Product.Components.Count()," items"
        Write !,"  Tags: ",..Product.Tags.Count()," items"
        Write !,"  Complete: ",$SELECT(..Product.IsComplete():"Yes", 1:"No")
    }
    
    Write !,"================================="
}

}
