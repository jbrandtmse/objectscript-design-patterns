/// Gang of Four Builder Pattern - Product2 Class
/// 
/// This class represents a different type of complex product that can be 
/// built step-by-step using the Builder pattern. Product2 has a different
/// structure than Product1, demonstrating pattern flexibility.
/// 
/// @see Patterns.GoF.Creational.ConcreteBuilder2
/// @since 1.0.0
Class Patterns.GoF.Creational.Product2 Extends %RegisteredObject
{

/// Components stored as a list instead of individual properties
Property Components As list Of %String;

/// Metadata about the product
Property Metadata As %String [ MultiDimensional ];

/// Product identifier
Property ProductId As %String;

/// Product category
Property Category As %String;

/// Priority level (1-5)
Property Priority As %Integer [ InitialExpression = 3 ];

/// Tags associated with the product
Property Tags As list Of %String;

/// Processing status
Property Status As %String [ InitialExpression = "New" ];

/// Timestamp when product was created
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($ZTIMESTAMP, 3)} ];

/// Timestamp when product was last modified
Property ModifiedAt As %TimeStamp;

/// Notes about the product
Property Notes As %String(MAXLEN = 1000);

/// Add a component to the product
/// 
/// @param pComponent The component to add
/// @return %Status
Method AddComponent(pComponent As %String) As %Status
{
    Set tSC = $$$OK
    
    If pComponent '= "" {
        Do ..Components.Insert(pComponent)
        Set ..ModifiedAt = $ZDATETIME($ZTIMESTAMP, 3)
    }
    
    Quit tSC
}

/// Add metadata to the product
/// 
/// @param pKey The metadata key
/// @param pValue The metadata value
/// @return %Status
Method AddMetadata(pKey As %String, pValue As %String) As %Status
{
    Set tSC = $$$OK
    
    If pKey '= "" {
        Set ..Metadata(pKey) = pValue
        Set ..ModifiedAt = $ZDATETIME($ZTIMESTAMP, 3)
    }
    
    Quit tSC
}

/// Add a tag to the product
/// 
/// @param pTag The tag to add
/// @return %Status
Method AddTag(pTag As %String) As %Status
{
    Set tSC = $$$OK
    
    If pTag '= "" {
        // Check if tag already exists
        Set tExists = 0
        For i=1:1:..Tags.Count() {
            If ..Tags.GetAt(i) = pTag {
                Set tExists = 1
                Quit
            }
        }
        
        If 'tExists {
            Do ..Tags.Insert(pTag)
            Set ..ModifiedAt = $ZDATETIME($ZTIMESTAMP, 3)
        }
    }
    
    Quit tSC
}

/// Check if the product has a specific component
/// 
/// @param pComponent The component to check for
/// @return %Boolean
Method HasComponent(pComponent As %String) As %Boolean
{
    Set found = 0
    For i=1:1:..Components.Count() {
        If ..Components.GetAt(i) = pComponent {
            Set found = 1
            Quit
        }
    }
    
    Quit found
}

/// Check if the product is complete (has required components)
/// 
/// @return %Boolean indicating if product is complete
Method IsComplete() As %Boolean
{
    // Product2 requires at least one component and a ProductId
    If ..ProductId = "" {
        Quit 0
    }
    
    If ..Components.Count() = 0 {
        Quit 0
    }
    
    Quit 1
}

/// Update the product status
/// 
/// @param pStatus The new status
/// @return %Status
Method UpdateStatus(pStatus As %String) As %Status
{
    Set tSC = $$$OK
    
    If pStatus '= "" {
        Set ..Status = pStatus
        Set ..ModifiedAt = $ZDATETIME($ZTIMESTAMP, 3)
    }
    
    Quit tSC
}

/// Get a string representation of the product
/// 
/// @return String representation
Method ToString() As %String
{
    Set tString = "Product2["
    Set tString = tString_"Id="_..ProductId
    Set tString = tString_", Category="_..Category
    Set tString = tString_", Priority="_..Priority
    Set tString = tString_", Status="_..Status
    
    Set tComponentCount = ..Components.Count()
    If tComponentCount > 0 {
        Set tString = tString_", Components="_tComponentCount
    }
    
    Set tTagCount = ..Tags.Count()
    If tTagCount > 0 {
        Set tString = tString_", Tags="_tTagCount
    }
    
    Set tString = tString_", Complete="_..IsComplete()
    Set tString = tString_"]"
    
    Quit tString
}

/// Display detailed information about the product
Method Display()
{
    Write !,"=== Product2 Details ==="
    Write !,"Product ID: ", ..ProductId
    Write !,"Category: ", ..Category
    Write !,"Priority: ", ..Priority
    Write !,"Status: ", ..Status
    Write !,"Created: ", ..CreatedAt
    If ..ModifiedAt '= "" {
        Write !,"Modified: ", ..ModifiedAt
    }
    Write !,"Complete: ", $SELECT(..IsComplete():"Yes", 1:"No")
    
    Set tComponentCount = ..Components.Count()
    If tComponentCount > 0 {
        Write !,"Components (",tComponentCount,"):"
        For i=1:1:tComponentCount {
            Write !,"  - ", ..Components.GetAt(i)
        }
    }
    
    Set tTagCount = ..Tags.Count()
    If tTagCount > 0 {
        Write !,"Tags:"
        For i=1:1:tTagCount {
            Write !,"  - ", ..Tags.GetAt(i)
        }
    }
    
    // Display metadata if present
    Set tKey = $ORDER(..Metadata(""))
    If tKey '= "" {
        Write !,"Metadata:"
        While tKey '= "" {
            Write !,"  - ", tKey, " = ", ..Metadata(tKey)
            Set tKey = $ORDER(..Metadata(tKey))
        }
    }
    
    If ..Notes '= "" {
        Write !,"Notes: ", ..Notes
    }
    
    Write !,"========================"
}

/// Compare this product with another Product2 instance
/// 
/// @param pOther The other Product2 to compare with
/// @return %Boolean indicating if products are equivalent
Method Equals(pOther As Product2) As %Boolean
{
    If '$ISOBJECT(pOther) Quit 0
    If ..ProductId '= pOther.ProductId Quit 0
    If ..Category '= pOther.Category Quit 0
    If ..Priority '= pOther.Priority Quit 0
    
    // Check component count
    If ..Components.Count() '= pOther.Components.Count() Quit 0
    
    Quit 1
}

}
