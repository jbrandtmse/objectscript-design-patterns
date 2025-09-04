/// Gang of Four Builder Pattern - Product1 Class
/// 
/// This class represents a complex product that can be built step-by-step
/// using the Builder pattern. Product1 has multiple properties that can
/// be configured during construction.
/// 
/// @see Patterns.GoF.Creational.ConcreteBuilder1
/// @since 1.0.0
Class Patterns.GoF.Creational.Product1 Extends %RegisteredObject
{

/// Part A - Basic structure component
Property PartA As %String;

/// Part B - Additional component
Property PartB As %String;

/// Part C - Optional component
Property PartC As %String;

/// Name of the product
Property Name As %String;

/// Description of the product
Property Description As %String;

/// Product version
Property Version As %String [ InitialExpression = "1.0" ];

/// List of features included in this product
Property Features As list Of %String;

/// Configuration settings as key-value pairs
Property Configuration As %String [ MultiDimensional ];

/// Timestamp when product was created
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($ZTIMESTAMP, 3)} ];

/// Whether the product has been validated
Property IsValidated As %Boolean [ InitialExpression = 0 ];

/// Add a feature to the product
/// 
/// @param pFeature The feature to add
/// @return %Status
Method AddFeature(pFeature As %String) As %Status
{
    Set tSC = $$$OK
    
    If pFeature '= "" {
        Do ..Features.Insert(pFeature)
    }
    
    Quit tSC
}

/// Set a configuration value
/// 
/// @param pKey The configuration key
/// @param pValue The configuration value
/// @return %Status
Method SetConfig(pKey As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    
    If pKey '= "" {
        Set ..Configuration(pKey) = pValue
    }
    
    Quit tSC
}

/// Get a configuration value
/// 
/// @param pKey The configuration key
/// @return The configuration value or empty string if not found
Method GetConfig(pKey As %String) As %String
{
    Set tValue = ""
    
    If pKey '= "" {
        If $DATA(..Configuration(pKey)) {
            Set tValue = ..Configuration(pKey)
        }
    }
    
    Quit tValue
}

/// Check if the product is complete (has all required parts)
/// 
/// @return %Boolean indicating if product is complete
Method IsComplete() As %Boolean
{
    // Product1 requires at least PartA to be complete
    If ..PartA = "" {
        Quit 0
    }
    
    Quit 1
}

/// Get a string representation of the product
/// 
/// @return String representation
Method ToString() As %String
{
    Set tString = "Product1["
    Set tString = tString_"Name="_..Name
    
    If ..PartA '= "" {
        Set tString = tString_", PartA="_..PartA
    }
    
    If ..PartB '= "" {
        Set tString = tString_", PartB="_..PartB
    }
    
    If ..PartC '= "" {
        Set tString = tString_", PartC="_..PartC
    }
    
    Set tFeatureCount = ..Features.Count()
    If tFeatureCount > 0 {
        Set tString = tString_", Features="_tFeatureCount
    }
    
    Set tString = tString_", Version="_..Version
    Set tString = tString_", Complete="_..IsComplete()
    Set tString = tString_"]"
    
    Quit tString
}

/// Display detailed information about the product
Method Display()
{
    Write !,"=== Product1 Details ==="
    Write !,"Name: ", ..Name
    Write !,"Description: ", ..Description
    Write !,"Version: ", ..Version
    Write !,"Created: ", ..CreatedAt
    Write !,"Complete: ", $SELECT(..IsComplete():"Yes", 1:"No")
    Write !,"Validated: ", $SELECT(..IsValidated:"Yes", 1:"No")
    
    Write !,"Parts:"
    If ..PartA '= "" Write !,"  - PartA: ", ..PartA
    If ..PartB '= "" Write !,"  - PartB: ", ..PartB
    If ..PartC '= "" Write !,"  - PartC: ", ..PartC
    
    Set tFeatureCount = ..Features.Count()
    If tFeatureCount > 0 {
        Write !,"Features:"
        For i=1:1:tFeatureCount {
            Write !,"  - ", ..Features.GetAt(i)
        }
    }
    
    // Display configuration if present
    Set tKey = $ORDER(..Configuration(""))
    If tKey '= "" {
        Write !,"Configuration:"
        While tKey '= "" {
            Write !,"  - ", tKey, " = ", ..Configuration(tKey)
            Set tKey = $ORDER(..Configuration(tKey))
        }
    }
    
    Write !,"========================"
}

}
