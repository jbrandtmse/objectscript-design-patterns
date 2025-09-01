# Quick Start

### Using a Pattern
```objectscript
// Import the pattern
Set factory = ##class(Patterns.GoF.Creational.Factory).%New()

// Configure the pattern
Do factory.RegisterProduct("TypeA", "Patterns.Examples.ProductA")

// Use the pattern
Set product = factory.CreateProduct("TypeA")
```
