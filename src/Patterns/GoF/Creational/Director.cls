/// Gang of Four Builder Pattern - Director Class
/// 
/// Intent:
/// The Director constructs an object using the Builder interface.
/// It defines the order of construction steps and can create different
/// representations using the same construction process.
/// 
/// Applicability:
/// - When you want to encapsulate the construction logic separately from builders
/// - When you need to create different representations of an object using the same construction process
/// - When the construction process should be independent of the parts that constitute the object
/// 
/// Structure:
/// <example>
/// Set director = ##class(Patterns.GoF.Creational.Director).%New()
/// Set builder = ##class(ConcreteBuilder).%New()
/// Do director.Construct(builder, "full")
/// Set product = builder.GetResult()
/// </example>
/// 
/// @see Patterns.GoF.Creational.Builder
/// @since 1.0.0
Class Patterns.GoF.Creational.Director Extends %RegisteredObject
{

/// Current builder being used by the director
Property Builder As Patterns.GoF.Creational.Builder [ Private ];

/// Constructor - can optionally accept a builder
/// 
/// @param pBuilder Optional builder to use initially
Method %OnNew(pBuilder As Patterns.GoF.Creational.Builder = "") As %Status
{
    Set tSC = $$$OK
    
    If $ISOBJECT(pBuilder) {
        Set ..Builder = pBuilder
    }
    
    Quit tSC
}

/// Set the builder to be used for construction
/// 
/// @param pBuilder The builder instance to use
/// @return %Status
Method SetBuilder(pBuilder As Patterns.GoF.Creational.Builder) As %Status
{
    Set tSC = $$$OK
    
    If '$ISOBJECT(pBuilder) {
        Set tSC = $$$ERROR($$$GeneralError, "Builder cannot be null")
        Quit tSC
    }
    
    Set ..Builder = pBuilder
    
    Quit tSC
}

/// Construct an object using the specified template
/// 
/// @param pBuilder The builder to use for construction
/// @param pTemplate The construction template (minimal, full, custom)
/// @return The constructed product object
Method Construct(pBuilder As Patterns.GoF.Creational.Builder, pTemplate As %String = "minimal") As %RegisteredObject
{
    Set tProduct = ""
    
    Try {
        // Validate builder
        If '$ISOBJECT(pBuilder) {
            Set tSC = $$$ERROR($$$GeneralError, "Builder is required for construction")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Set the builder
        Set ..Builder = pBuilder
        
        // Reset builder to ensure clean state
        Do ..Builder.Reset()
        
        // Execute construction based on template
        Set pTemplate = $ZCONVERT(pTemplate, "L")
        
        If pTemplate = "minimal" {
            Set tSC = ..ConstructMinimal()
        }
        ElseIf pTemplate = "full" {
            Set tSC = ..ConstructFull()
        }
        ElseIf pTemplate = "custom" {
            Set tSC = ..ConstructCustom()
        }
        Else {
            Set tSC = $$$ERROR($$$GeneralError, "Unknown template: "_pTemplate)
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Validate the constructed product
        Set tSC = ..Builder.Validate()
        
        // Get the constructed product
        If $$$ISOK(tSC) {
            Set tProduct = ..Builder.GetResult()
        }
        
    } Catch ex {
        Set tProduct = ""
    }
    
    Quit tProduct
}

/// Construct a minimal product with only required parts
/// 
/// @return %Status
Method ConstructMinimal() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Check if this is ConcreteBuilder2 which requires ProductId
        If ..Builder.%IsA("Patterns.GoF.Creational.ConcreteBuilder2") {
            // Set a default ProductId for ConcreteBuilder2
            Do ..Builder.SetProperty("ProductId", "DIR-MIN")
        }
        
        // Build only the essential parts
        Do ..Builder.BuildPartA()
        
        // Validate after minimal construction
        Set tSC = ..Builder.Validate()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Construct a full product with all parts
/// 
/// @return %Status
Method ConstructFull() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Check if this is ConcreteBuilder2 which requires ProductId
        If ..Builder.%IsA("Patterns.GoF.Creational.ConcreteBuilder2") {
            // Set a default ProductId for ConcreteBuilder2
            Do ..Builder.SetProperty("ProductId", "DIR-FULL")
        }
        
        // Build all parts in sequence
        Do ..Builder.BuildPartA()
        Do ..Builder.BuildPartB()
        Do ..Builder.BuildPartC()
        
        // Validate after full construction
        Set tSC = ..Builder.Validate()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Construct a custom product with specific parts
/// This method demonstrates a custom construction sequence
/// 
/// @return %Status
Method ConstructCustom() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Check if this is ConcreteBuilder2 which requires ProductId
        If ..Builder.%IsA("Patterns.GoF.Creational.ConcreteBuilder2") {
            // Set a default ProductId for ConcreteBuilder2
            Do ..Builder.SetProperty("ProductId", "DIR-CUSTOM")
        }
        
        // Custom construction sequence
        Do ..Builder.BuildPartA()
        Do ..Builder.BuildPartC()
        // Intentionally skip PartB for custom template
        
        // Validate after custom construction
        Set tSC = ..Builder.Validate()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Construct with specific steps provided as a list
/// This allows dynamic construction sequences
/// 
/// @param pBuilder The builder to use
/// @param pSteps List of step names to execute (e.g., "A", "B", "C")
/// @return The constructed product object
Method ConstructWithSteps(pBuilder As Patterns.GoF.Creational.Builder, pSteps As %List) As %RegisteredObject
{
    Set tProduct = ""
    
    Try {
        // Validate builder
        If '$ISOBJECT(pBuilder) {
            Set tSC = $$$ERROR($$$GeneralError, "Builder is required for construction")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Set ..Builder = pBuilder
        Do ..Builder.Reset()
        
        // Check if this is ConcreteBuilder2 which requires ProductId
        If ..Builder.%IsA("Patterns.GoF.Creational.ConcreteBuilder2") {
            // Set a default ProductId for ConcreteBuilder2
            Do ..Builder.SetProperty("ProductId", "DIR-STEPS")
        }
        
        // Execute each step in the provided sequence
        Set tStepCount = $LISTLENGTH(pSteps)
        For i = 1:1:tStepCount {
            Set tStep = $LISTGET(pSteps, i)
            
            If tStep = "A" {
                Do ..Builder.BuildPartA()
            }
            ElseIf tStep = "B" {
                Do ..Builder.BuildPartB()
            }
            ElseIf tStep = "C" {
                Do ..Builder.BuildPartC()
            }
            Else {
                Set tSC = $$$ERROR($$$GeneralError, "Unknown build step: "_tStep)
                Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
            }
        }
        
        // Validate after construction
        Set tSC = ..Builder.Validate()
        
        // Get the constructed product
        If $$$ISOK(tSC) {
            Set tProduct = ..Builder.GetResult()
        }
        
    } Catch ex {
        Set tProduct = ""
    }
    
    Quit tProduct
}

/// Get available construction templates
/// 
/// @return %List of template names
ClassMethod GetAvailableTemplates() As %List
{
    Quit $LISTBUILD("minimal", "full", "custom")
}

/// Get a description of the Director's role
/// 
/// @return Description string
ClassMethod GetDescription() As %String
{
    Quit "Director orchestrates the construction of complex objects using Builder interface"
}

}
