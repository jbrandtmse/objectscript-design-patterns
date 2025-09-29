# Chapter 21: Strategy Pattern

## Intent
Define a family of algorithms, encapsulate each one, and make them interchangeable. Strategy lets the algorithm vary independently from clients that use it.

## Also Known As
- Policy

## Motivation
Many algorithms exist for breaking a stream of text into lines. Hard-wiring all such algorithms into the classes that require them isn't desirable for several reasons:
- Clients that need line-breaking get more complex if they include the line-breaking code
- Different algorithms will be appropriate at different times
- It's difficult to add new algorithms and vary existing ones when they're an integral part of a client

We can avoid these problems by defining classes that encapsulate different line-breaking algorithms. An algorithm that's encapsulated in this way is called a strategy.

In our healthcare billing example, different payer types require different calculation algorithms:
- Standard billing applies list prices with administrative fees
- Insurance billing applies negotiated rates, copays, deductibles, and coinsurance
- Medicare uses DRG-based bundled payments
- Medicaid has state-specific rates and prior authorization requirements

## Applicability
Use the Strategy pattern when:
- Many related classes differ only in their behavior
- You need different variants of an algorithm
- An algorithm uses data that clients shouldn't know about
- A class defines many behaviors, and these appear as multiple conditional statements in its operations

## Structure
```
         Context                     Strategy
    ----------------           ------------------
    | -strategy     |<>------->| +Execute()     |
    ----------------           ------------------
    | +SetStrategy()|                  ^
    | +ExecuteAlgo()|                  |
    ----------------                   |
                              +--------+--------+
                              |        |        |
                    ConcreteA |  ConcreteB |  ConcreteC
                    ----------   ----------   ----------
                    |+Execute()|  |+Execute()|  |+Execute()|
                    ----------    ----------    ----------
```

## Participants

### Strategy (Patterns.GoF.Behavioral.Strategy)
- Declares an interface common to all supported algorithms
- Context uses this interface to call the algorithm defined by a ConcreteStrategy

### ConcreteStrategy (StandardBillingStrategy, InsuranceBillingStrategy)
- Implements the algorithm using the Strategy interface

### Context (StrategyContext, BillingContext)
- Is configured with a ConcreteStrategy object
- Maintains a reference to a Strategy object
- May define an interface that lets Strategy access its data

## Collaborations
- Strategy and Context interact to implement the chosen algorithm
- A context may pass all data required by the algorithm to the strategy when the algorithm is called
- Alternatively, the context can pass itself as an argument to Strategy operations
- A context forwards requests from its clients to its strategy

## Consequences

### Benefits:
1. **Families of related algorithms** - Hierarchies of Strategy classes define a family of algorithms for contexts to reuse
2. **An alternative to subclassing** - Encapsulating the algorithm in separate Strategy classes lets you vary the algorithm independently
3. **Strategies eliminate conditional statements** - The Strategy pattern offers an alternative to conditional statements for selecting desired behavior
4. **A choice of implementations** - Strategies can provide different implementations of the same behavior

### Liabilities:
1. **Clients must be aware of different Strategies** - Clients might be exposed to implementation issues
2. **Communication overhead between Strategy and Context** - The Strategy interface is shared by all ConcreteStrategy classes whether they use all the interface or not
3. **Increased number of objects** - Strategies increase the number of objects in an application

## Implementation

### Basic Strategy Implementation in ObjectScript:
```objectscript
/// Abstract Strategy
Class Patterns.GoF.Behavioral.Strategy Extends %RegisteredObject [ Abstract ]
{
    Method Execute(pContext As %RegisteredObject, pData As %RegisteredObject) As %String [ Abstract ]
    {
        Quit ""
    }
    
    Method CanHandle(pData As %RegisteredObject) As %Boolean
    {
        Quit 1
    }
}

/// Context that uses strategies
Class Patterns.GoF.Behavioral.StrategyContext Extends %RegisteredObject
{
    Property CurrentStrategy As Strategy;
    Property StrategyCache As %ArrayOfObjects [ Private ];
    
    Method SetStrategy(pStrategy As Strategy) As %Status
    {
        Set tSC = $$$OK
        If '$IsObject(pStrategy) {
            Quit $$$ERROR($$$GeneralError, "Invalid strategy object")
        }
        Set ..CurrentStrategy = pStrategy
        Quit tSC
    }
    
    Method ExecuteStrategy(pData As %RegisteredObject = "") As %String
    {
        If '$IsObject(..CurrentStrategy) Quit ""
        Quit ..CurrentStrategy.Execute($this, pData)
    }
}
```

### Healthcare Billing Example:
```objectscript
/// Standard Billing Strategy
Class StandardBillingStrategy Extends BillingStrategy
{
    Parameter PROMPTPAYMENTDISCOUNT = 5;
    Parameter ADMINFEEPERCENTAGE = 2;
    
    Method CalculateBilling(pCharges As %Decimal, pPatientInfo As %DynamicObject) As %DynamicObject
    {
        Set result = {}
        Set adminFee = pCharges * (..#ADMINFEEPERCENTAGE / 100)
        Set totalWithFees = pCharges + adminFee
        
        Set promptPayDiscount = 0
        If ..IsEligibleForPromptPayment(pPatientInfo) {
            Set promptPayDiscount = totalWithFees * (..#PROMPTPAYMENTDISCOUNT / 100)
        }
        
        Set finalAmount = totalWithFees - promptPayDiscount
        Set result.finalAmount = $FNUMBER(finalAmount, "", 2)
        Quit result
    }
}

/// Insurance Billing Strategy
Class InsuranceBillingStrategy Extends BillingStrategy
{
    Parameter NEGOTIATEDRATE = 35;
    
    Method CalculateBilling(pCharges As %Decimal, pPatientInfo As %DynamicObject) As %DynamicObject
    {
        Set result = {}
        Set discountAmount = pCharges * (..#NEGOTIATEDRATE / 100)
        Set allowedAmount = pCharges - discountAmount
        
        // Apply deductible, copay, coinsurance...
        Set patientResponsibility = ..CalculatePatientResponsibility(allowedAmount, pPatientInfo)
        
        Set result.patientResponsibility = patientResponsibility
        Set result.finalAmount = patientResponsibility
        Quit result
    }
}
```

## Sample Code

### Complete Working Example:
```objectscript
// Create billing context
Set context = ##class(Patterns.Examples.BillingContext).%New()

// Create billing data
Set data = {}
Set data.charges = 1000
Set data.patientInfo = {"patientId": "P001", "insuranceId": "INS123"}

// Use standard billing
Do context.SelectStrategyByType("Standard")
Set standardResult = context.CalculateBill(data)
Write "Standard billing: ", standardResult.finalAmount, !

// Switch to insurance billing
Do context.SelectStrategyByType("Insurance")
Set insuranceResult = context.CalculateBill(data)
Write "Insurance billing: ", insuranceResult.finalAmount, !

// Auto-select strategy based on data
Do context.AutoSelectStrategy(data)
Write "Auto-selected: ", context.GetCurrentStrategyName(), !
```

### Dynamic Strategy Selection:
```objectscript
// Register custom strategies
Do context.RegisterStrategy("Custom", "MyApp.CustomBillingStrategy")

// Select by criteria
Set tSC = context.SelectStrategy("Custom")

// Process batch with different strategies
Set batch = []
Do batch.%Push(##class(BillingContext).CreateBillingData(100, "P1"))
Do batch.%Push(##class(BillingContext).CreateBillingData(200, "P2", "INS001"))
Set batchResult = context.ProcessBatch(batch)
```

## Known Uses
1. **Text formatting** - Different line-breaking algorithms in document composition
2. **Routing algorithms** - Different strategies for finding paths in navigation systems
3. **Memory allocation** - Different strategies for allocating and deallocating memory
4. **Compression algorithms** - Different strategies for compressing data
5. **Payment processing** - Different strategies for processing various payment types

## Related Patterns

### Flyweight
Strategy objects often make good flyweights when they don't maintain state.

### State
Both patterns have similar structures, but they differ in intent:
- Strategy focuses on algorithms and lets clients choose
- State focuses on object state and manages transitions internally

### Template Method
Template Method uses inheritance to vary part of an algorithm, while Strategy uses delegation to vary the entire algorithm.

### Bridge
Strategy is often confused with Bridge. Bridge separates an abstraction from its implementation so that both can vary independently. Strategy encapsulates algorithms.

## ObjectScript-Specific Considerations

### Polymorphism in ObjectScript
ObjectScript supports polymorphism through:
- Abstract classes with [ Abstract ] keyword
- Method overriding in subclasses
- %IsA() for type checking
- $CLASSMETHOD for dynamic invocation

### Performance Optimization
```objectscript
// Cache strategy instances
Property StrategyCache As %ArrayOfObjects;

// Use $CLASSMETHOD for dynamic instantiation
Set strategy = $CLASSMETHOD(className, "%New")

// Use globals for strategy registry
Set ^Patterns.Strategy.Registry(alias) = className
```

### Thread Safety
Strategy objects should be stateless when possible to ensure thread safety in concurrent environments.

## Summary
The Strategy pattern is essential for managing families of algorithms in a flexible, maintainable way. It eliminates conditional logic, supports runtime algorithm selection, and promotes code reuse. In our ObjectScript implementation, we've leveraged the language's object-oriented features while maintaining compatibility with InterSystems IRIS platform conventions. The healthcare billing example demonstrates real-world applicability where different payer types require distinct calculation algorithms, all managed through a common interface.
