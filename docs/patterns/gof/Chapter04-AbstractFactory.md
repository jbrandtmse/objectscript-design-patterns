# Chapter 4: Abstract Factory Pattern

## Intent
The Abstract Factory pattern provides an interface for creating families of related or dependent objects without specifying their concrete classes. It ensures that products created by a factory are compatible with each other.

## Also Known As
- Kit

## Motivation
Consider a medical information system that needs to support multiple user interface platforms (tablet, desktop, mobile). Each platform requires its own set of UI components (buttons, forms, charts) that must work together consistently. The Abstract Factory pattern ensures that all components created for a specific platform are compatible and maintain a consistent look and feel.

## Applicability
Use the Abstract Factory pattern when:
- A system should be independent of how its products are created, composed, and represented
- A system should be configured with one of multiple families of products
- A family of related product objects is designed to be used together, and you need to enforce this constraint
- You want to provide a class library of products, revealing only interfaces, not implementations

## Structure
```
AbstractFactory
├── ConcreteFactory1
├── ConcreteFactory2
├── AbstractProductA
│   ├── ProductA1
│   └── ProductA2
└── AbstractProductB
    ├── ProductB1
    └── ProductB2
```

## Participants
- **AbstractFactory** (MedicalDeviceUIFactory)
  - Declares an interface for operations that create abstract product objects
- **ConcreteFactory** (TabletUIFactory, DesktopUIFactory, MobileUIFactory)
  - Implements operations to create concrete product objects
- **AbstractProduct** (MedicalUIButton, MedicalUIForm, MedicalUIChart)
  - Declares an interface for a type of product object
- **ConcreteProduct** (TabletButton, DesktopButton, MobileButton)
  - Defines a product object to be created by the corresponding concrete factory
  - Implements the AbstractProduct interface
- **Client**
  - Uses only interfaces declared by AbstractFactory and AbstractProduct classes

## Collaborations
- Normally a single instance of a ConcreteFactory class is created at runtime
- AbstractFactory defers creation of product objects to its ConcreteFactory subclass
- Products from the same factory family are designed to work together

## Consequences
### Benefits
1. **Isolation of concrete classes**: Clients work with interfaces, not implementations
2. **Product family consistency**: Ensures products from one family are used together
3. **Easy to exchange product families**: Change entire product family by switching factory

### Liabilities
1. **Difficult to support new kinds of products**: Adding new products requires changing AbstractFactory interface and all concrete factories
2. **Increased complexity**: More classes and interfaces to manage

## Implementation in ObjectScript

### Core Pattern Implementation
```objectscript
/// Abstract Factory interface
Class Patterns.GoF.Creational.AbstractFactory Extends %RegisteredObject [ Abstract ]
{
    Parameter PATTERNTYPE = "Creational";
    Parameter PATTERNNAME = "Abstract Factory";
    
    Method CreateProductA() As AbstractProductA [ Abstract ]
    {
        Quit $$$NULLOREF
    }
    
    Method CreateProductB() As AbstractProductB [ Abstract ]
    {
        Quit $$$NULLOREF
    }
    
    /// Demonstrates product family creation and interaction
    Method DemonstrateProductFamily() As %Status
    {
        Set tSC = $$$OK
        Try {
            Set productA = ..CreateProductA()
            Set productB = ..CreateProductB()
            
            // Products from same factory should work together
            Set tSC = productB.InteractWithProductA(productA)
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    /// Gets factory information
    Method GetFactoryInfo() As %String
    {
        Quit "Abstract Factory: " _ ..%ClassName(1) _ 
             " (Type: " _ ..#PATTERNTYPE _ ", Pattern: " _ ..#PATTERNNAME _ ")"
    }
}
```

### Medical Device UI Factory Example
```objectscript
/// Abstract factory for medical device UI components
Class Patterns.Examples.MedicalDeviceUIFactory Extends %RegisteredObject [ Abstract ]
{
    Method CreateButton() As MedicalUIButton [ Abstract ]
    {
        Quit $$$NULLOREF
    }
    
    Method CreateForm() As MedicalUIForm [ Abstract ]
    {
        Quit $$$NULLOREF
    }
    
    Method CreateChart() As MedicalUIChart [ Abstract ]
    {
        Quit $$$NULLOREF
    }
    
    Method GetPlatformName() As %String [ Abstract ]
    {
        Quit ""
    }
    
    /// Demonstrates creating a complete UI suite
    Method CreateUIDemo() As %Status
    {
        Set tSC = $$$OK
        Try {
            // Create all UI components
            Set tButton = ..CreateButton()
            Set tForm = ..CreateForm()
            Set tChart = ..CreateChart()
            
            // Render components
            Do tButton.Render()
            Do tForm.Render()
            Do tChart.Display()
            
            // Test component interactions
            Set tSC = tForm.AttachButton(tButton)
            Set tSC = tForm.AttachChart(tChart)
            
            Write "UI suite created for: ", ..GetPlatformName(), !
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
}

/// Concrete factory for tablet UI
Class Patterns.Examples.TabletUIFactory Extends MedicalDeviceUIFactory
{
    Parameter PLATFORM = "Tablet";
    Parameter SCREENSIZE = "10-12 inch";
    Parameter INPUTMETHOD = "Touch";
    Parameter ORIENTATION = "Portrait/Landscape";
    
    Method CreateButton() As MedicalUIButton
    {
        Quit ##class(TabletButton).%New()
    }
    
    Method CreateForm() As MedicalUIForm
    {
        Quit ##class(TabletForm).%New()
    }
    
    Method CreateChart() As MedicalUIChart
    {
        Quit ##class(TabletChart).%New()
    }
    
    Method GetPlatformName() As %String
    {
        Quit ..#PLATFORM
    }
}
```

## Sample Code
### Creating and Using a Factory
```objectscript
// Select factory based on runtime configuration
If deviceType = "tablet" {
    Set factory = ##class(TabletUIFactory).%New()
} ElseIf deviceType = "desktop" {
    Set factory = ##class(DesktopUIFactory).%New()
} Else {
    Set factory = ##class(MobileUIFactory).%New()
}

// Create UI components using selected factory
Set button = factory.CreateButton()
Set form = factory.CreateForm()
Set chart = factory.CreateChart()

// All components are guaranteed to be from same platform
Do button.Render()
Do form.Render()
Do chart.Render()
```

### Product Compatibility Checking
```objectscript
/// Abstract ProductB with compatibility checking
Method InteractWithProductA(pProductA As AbstractProductA) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check compatibility
        If '..IsCompatibleWith(pProductA) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "Incompatible product families"))
        }
        
        // Perform interaction
        Write "ProductB interacting with ", pProductA.GetDescription(), !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}
```

## Known Uses in Healthcare
1. **Multi-platform Medical Applications**
   - Supporting tablet interfaces for bedside care
   - Desktop interfaces for administrative tasks
   - Mobile interfaces for on-the-go access

2. **Medical Device Integration**
   - Different factories for various device manufacturers
   - Ensuring compatibility within device families

3. **Laboratory Information Systems**
   - Different UI families for different lab departments
   - Specialized interfaces for different types of equipment

## Related Patterns
- **Factory Method**: Abstract Factory often uses Factory Methods to implement product creation
- **Singleton**: Concrete factories are often implemented as Singletons
- **Prototype**: An alternative to Abstract Factory when many product families are possible

## Testing Considerations
```objectscript
/// Test product family consistency
Method TestSameFactoryCompatibility()
{
    Set factory = ##class(TabletUIFactory).%New()
    Set button = factory.CreateButton()
    Set form = factory.CreateForm()
    
    // Components from same factory should work together
    Do $$$AssertEquals(button.GetPlatform(), "Tablet", "Button is for Tablet")
    Do $$$AssertEquals(form.GetPlatform(), "Tablet", "Form is for Tablet")
    
    // Verify products can interact (compatibility is checked in InteractWithProductA)
    Set productA = factory.CreateProductA()
    Set productB = factory.CreateProductB()
    Set tSC = productB.InteractWithProductA(productA)
    Do $$$AssertStatusOK(tSC, "Products from same factory are compatible")
}
```

## Best Practices in ObjectScript
1. **Abstract Methods**: In ObjectScript, abstract methods must have code blocks that return appropriate values:
   - Object types: `Quit $$$NULLOREF`
   - %Status: `Quit $$$OK`
   - Strings: `Quit ""`
   - Booleans/Numerics: `Quit 0`

2. **Factory Registry**: Consider using a registry pattern to manage factory instances:
```objectscript
Class FactoryRegistry
{
    ClassMethod GetFactory(pType As %String) As AbstractFactory
    {
        If pType = "tablet" Quit ##class(TabletUIFactory).%New()
        If pType = "desktop" Quit ##class(DesktopUIFactory).%New()
        If pType = "mobile" Quit ##class(MobileUIFactory).%New()
        Quit $$$NULLOREF
    }
}
```

3. **Product Family Parameters**: Use class parameters to identify product families:
```objectscript
// ConcreteFactory1 parameters
Parameter FACTORYFAMILY = 1;
Parameter FACTORYSTYLE = "Modern";

// TabletUIFactory parameters
Parameter PLATFORM = "Tablet";
Parameter SCREENSIZE = "10-12 inch";
Parameter INPUTMETHOD = "Touch";
Parameter ORIENTATION = "Portrait/Landscape";
```

4. **Abstract Product Interface**: Define clear interfaces for products:
```objectscript
Class AbstractProductA Extends %RegisteredObject [ Abstract ]
{
    Parameter PRODUCTTYPE = "A";
    
    Method GetDescription() As %String [ Abstract ] { Quit "" }
    Method PerformOperation() As %Status [ Abstract ] { Quit $$$OK }
    Method GetCompatibilityInfo() As %String [ Abstract ] { Quit "" }
    
    /// Base validation method
    Method IsValid() As %Boolean
    {
        Quit ($IsObject($This) && (..GetDescription() '= ""))
    }
    
    /// Extract product family from class name
    Method GetProductFamily() As %String
    {
        Set className = ..%ClassName(1)
        Quit $Extract(className, $Length(className))
    }
}
```

## Common Pitfalls
1. **Forgetting abstract method implementations**: ObjectScript requires code blocks in abstract methods
2. **Mixing products from different families**: Always validate compatibility
3. **Hard-coding factory selection**: Use configuration or runtime detection
4. **Not handling null returns**: Check for $$$NULLOREF when creating products

## Try It Yourself
1. **Exercise 1**: Extend the medical UI example to add a new product type (e.g., MedicalUIDialog)
2. **Exercise 2**: Create a factory for web-based UI components
3. **Exercise 3**: Implement a factory selection mechanism based on user preferences
4. **Exercise 4**: Add validation to ensure products from different factories cannot interact

## Summary
The Abstract Factory pattern is essential for creating families of related objects while maintaining consistency and compatibility. In healthcare systems, it's particularly useful for supporting multiple platforms and device types while ensuring that all components work together harmoniously. The pattern provides excellent isolation from concrete implementations and makes it easy to switch between different product families at runtime.

## References
- Implementation: `/src/Patterns/GoF/Creational/AbstractFactory.cls`
- Unit Tests: `/src/Patterns/Test/Unit/GoF/Creational/AbstractFactoryTest.cls`
- Healthcare Example: `/src/Patterns/Examples/MedicalDeviceUIFactory.cls`
