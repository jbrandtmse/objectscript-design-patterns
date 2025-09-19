/// Gang of Four Decorator Pattern - Concrete Component Implementation
/// 
/// <p>Intent:
/// Provides the base implementation of the component interface that can be
/// decorated with additional responsibilities.</p>
/// 
/// <p>Motivation:
/// This class represents the core object to which we can attach additional
/// responsibilities dynamically through decorators. It provides the base
/// functionality that decorators will enhance.</p>
/// 
/// <p>Structure:
/// ConcreteComponent implements the IComponent interface and defines the
/// base behavior that decorators will extend.</p>
/// 
/// <p>Participants:
/// - Defines an object to which additional responsibilities can be attached
/// - Implements the base behavior that decorators will enhance</p>
/// 
/// @since 1.0.0
/// @see Patterns.GoF.Structural.IComponent
/// @see Patterns.GoF.Structural.Decorator
Class Patterns.GoF.Structural.ConcreteComponent Extends Patterns.GoF.Structural.IComponent
{

/// Name or identifier for this component
Property Name As %String [ InitialExpression = "Base Component" ];

/// Base cost for this component
Property BaseCost As %Numeric [ InitialExpression = 10 ];

/// Additional data specific to this component
Property Data As %String;

/// Component creation timestamp
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

/// Constructor to initialize the concrete component
/// 
/// @param pName Optional name for the component
/// @param pData Optional data to store in the component
/// @return %Status indicating success or failure
Method %OnNew(pName As %String = "", pData As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pName '= "" {
            Set ..Name = pName
        }
        
        If pData '= "" {
            Set ..Data = pData
        }
        
        // Initialize creation timestamp
        Set ..CreatedAt = $ZDATETIME($HOROLOG, 3)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Perform the component's base operation
/// 
/// <p>This method provides the core functionality that decorators
/// will enhance. The base implementation performs a simple operation
/// and returns a description of what was done.</p>
/// 
/// @return Operation result describing the base operation
/// 
/// <example>
/// Set component = ##class(Patterns.GoF.Structural.ConcreteComponent).%New("MyComponent")
/// Set result = component.Operation()
/// Write "Result: ", result, !
/// // Output: Result: ConcreteComponent.Operation()
/// </example>
Method Operation() As %String
{
    Set tResult = "ConcreteComponent.Operation()"
    
    // Simulate some base processing
    If ..Data '= "" {
        Set tResult = tResult _ " [Processing: " _ $EXTRACT(..Data, 1, 20) _ "]"
    }
    
    Quit tResult
}

/// Get the component's description
/// 
/// <p>Returns a description of the concrete component including its
/// name and any relevant properties.</p>
/// 
/// @return Component description as a string
/// 
/// <example>
/// Set component = ##class(ConcreteComponent).%New("Report")
/// Set description = component.GetDescription()
/// Write "Description: ", description, !
/// </example>
Method GetDescription() As %String
{
    Set tDescription = "ConcreteComponent"
    
    If ..Name '= "" {
        Set tDescription = tDescription _ "(" _ ..Name _ ")"
    }
    
    Quit tDescription
}

/// Get the cost associated with this component
/// 
/// <p>Returns the base cost of the component. Decorators can add
/// to this value to show cumulative costs.</p>
/// 
/// @return Base cost of the component
Method GetCost() As %Numeric
{
    Quit ..BaseCost
}

/// Validate the component
/// 
/// <p>Performs basic validation on the component data.</p>
/// 
/// @return %Boolean indicating whether the component is valid
Method IsValid() As %Boolean
{
    // Basic validation: component should have a name
    If ..Name = "" {
        Quit 0
    }
    
    // Check if data length is reasonable
    If $LENGTH(..Data) > 10000 {
        Quit 0
    }
    
    Quit 1
}

/// Process the component's data
/// 
/// <p>Additional method to demonstrate base functionality that
/// decorators can enhance.</p>
/// 
/// @param pInput Input data to process
/// @return Processed result
Method ProcessData(pInput As %String = "") As %String
{
    Set tResult = "Processed"
    
    If pInput '= "" {
        Set tResult = tResult _ ": " _ pInput
    }
    
    If ..Data '= "" {
        Set tResult = tResult _ " with " _ ..Data
    }
    
    Quit tResult
}

/// Display component information
/// 
/// <p>Utility method to display component details.</p>
Method Display()
{
    Write "=== Concrete Component ===", !
    Write "Name: ", ..Name, !
    Write "Description: ", ..GetDescription(), !
    Write "Cost: $", ..GetCost(), !
    Write "Valid: ", $SELECT(..IsValid():"Yes", 1:"No"), !
    Write "Created: ", ..CreatedAt, !
    If ..Data '= "" {
        Write "Data: ", $EXTRACT(..Data, 1, 50)
        If $LENGTH(..Data) > 50 Write "..."
        Write !
    }
    Write "========================", !
}

/// Class method to create and return a sample component
/// 
/// @return Instance of ConcreteComponent with sample data
ClassMethod CreateSample() As Patterns.GoF.Structural.ConcreteComponent
{
    Set tComponent = ..%New("Sample Component", "Sample data for testing")
    Set tComponent.BaseCost = 25
    Quit tComponent
}

}
