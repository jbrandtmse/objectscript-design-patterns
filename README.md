# ObjectScript Design Patterns Library

A comprehensive implementation of Gang of Four (GoF) and Patterns of Enterprise Application Architecture (PoEAA) design patterns in InterSystems ObjectScript.

## Overview

This library provides production-ready implementations of classic design patterns optimized for the InterSystems IRIS platform. Each pattern is thoroughly documented, tested, and includes practical examples demonstrating real-world usage.

## Features

- ✅ **23 Gang of Four Patterns** - Complete implementations of all GoF patterns
- ✅ **40+ PoEAA Patterns** - Enterprise application patterns from Martin Fowler's catalog
- ✅ **Pure ObjectScript** - Native implementations leveraging IRIS platform capabilities
- ✅ **Comprehensive Documentation** - Detailed guides, API docs, and examples for each pattern
- ✅ **Full Test Coverage** - Unit, integration, and performance tests for all patterns
- ✅ **Production Ready** - Following enterprise coding standards and best practices

## Quick Start

### Prerequisites

- InterSystems IRIS 2023.1 or higher
- VS Code with ObjectScript Extension (recommended)
- Git for version control

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/objectscript-design-patterns.git
cd objectscript-design-patterns
```

2. Import into IRIS:
```objectscript
Do $System.OBJ.LoadDir("/path/to/objectscript-design-patterns/src", "ck", .errors, 1)
```

3. Run tests to verify installation:
```objectscript
Do ##class(%UnitTest.Manager).RunTest("Patterns.Test", "/nodelete")
```

## Pattern Categories

### Gang of Four Patterns

#### Creational Patterns
- **Singleton** - Ensure a class has only one instance
- **Factory Method** - Define an interface for creating objects
- **Abstract Factory** - Create families of related objects
- **Builder** - Construct complex objects step by step
- **Prototype** - Clone objects without coupling to their classes

#### Structural Patterns
- **Adapter** - Allow incompatible interfaces to work together
- **Bridge** - Separate abstraction from implementation
- **Composite** - Compose objects into tree structures
- **Decorator** - Add new functionality to objects dynamically
- **Facade** - Provide a simplified interface to a complex subsystem
- **Flyweight** - Use sharing to support large numbers of fine-grained objects
- **Proxy** - Provide a placeholder or surrogate for another object

#### Behavioral Patterns
- **Chain of Responsibility** - Pass requests along a chain of handlers
- **Command** - Encapsulate a request as an object
- **Interpreter** - Define a grammatical representation for a language
- **Iterator** - Provide a way to access elements of a collection sequentially
- **Mediator** - Define how a set of objects interact
- **Memento** - Capture and restore an object's internal state
- **Observer** - Define a one-to-many dependency between objects
- **State** - Allow an object to alter its behavior when its state changes
- **Strategy** - Define a family of algorithms and make them interchangeable
- **Template Method** - Define the skeleton of an algorithm in a base class
- **Visitor** - Separate algorithms from the objects on which they operate

### PoEAA Patterns

- **Domain Logic Patterns** - Transaction Script, Domain Model, Table Module, Service Layer
- **Data Source Patterns** - Table Data Gateway, Row Data Gateway, Active Record, Data Mapper
- **Object-Relational Patterns** - Identity Map, Unit of Work, Lazy Load, Repository
- **Web Presentation Patterns** - Model View Controller, Page Controller, Front Controller
- **Distribution Patterns** - Remote Facade, Data Transfer Object
- **Offline Concurrency Patterns** - Optimistic Offline Lock, Pessimistic Offline Lock
- **Session State Patterns** - Client Session State, Server Session State, Database Session State
- **Base Patterns** - Gateway, Mapper, Layer Supertype, Registry, Value Object

## Usage Examples

### Singleton Pattern
```objectscript
// Get the singleton instance
Set singleton = ##class(Patterns.GoF.Creational.Singleton).GetInstance()

// Use the singleton
Do singleton.DoSomething()
```

### Factory Pattern
```objectscript
// Create a factory
Set factory = ##class(Patterns.GoF.Creational.Factory).%New()

// Create products using the factory
Set productA = factory.CreateProduct("TypeA")
Set productB = factory.CreateProduct("TypeB")
```

### Observer Pattern
```objectscript
// Create subject and observers
Set subject = ##class(Patterns.GoF.Behavioral.Observer.Subject).%New()
Set observer1 = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserver).%New("Observer1")
Set observer2 = ##class(Patterns.GoF.Behavioral.Observer.ConcreteObserver).%New("Observer2")

// Attach observers
Do subject.Attach(observer1)
Do subject.Attach(observer2)

// Notify all observers of state change
Do subject.Notify()
```

## Documentation

Comprehensive documentation is available in the `/docs` directory:

- **[Getting Started Guide](docs/guides/getting-started.md)** - Quick introduction and setup
- **[Installation Guide](docs/guides/installation.md)** - Detailed installation instructions
- **[Pattern Catalog](docs/patterns/)** - Complete documentation for each pattern
- **[API Reference](docs/api/)** - Generated API documentation
- **[Architecture Overview](docs/architecture/)** - System design and structure
- **[Contributing Guide](docs/guides/contributing.md)** - How to contribute to the project

## Project Structure

```
objectscript-design-patterns/
├── src/                    # Source code
│   └── Patterns/          # Pattern implementations
│       ├── GoF/           # Gang of Four patterns
│       └── PoEAA/         # Enterprise patterns
├── tests/                 # Test suites
│   ├── Unit/             # Unit tests
│   └── Integration/      # Integration tests
├── examples/              # Usage examples
│   ├── basic/            # Simple examples
│   └── real-world/       # Production scenarios
├── docs/                  # Documentation
│   ├── patterns/         # Pattern guides
│   └── api/              # API reference
└── scripts/              # Build & deployment
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](docs/guides/contributing.md) for details on:

- Code style and standards
- Testing requirements
- Pull request process
- Issue reporting

## Testing

Run the test suite:

```objectscript
// Run all tests
Do ##class(%UnitTest.Manager).RunTest("Patterns.Test")

// Run specific pattern tests
Do ##class(%UnitTest.Manager).RunTest("Patterns.Test.GoF.Creational")
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [https://github.com/yourusername/objectscript-design-patterns/wiki](https://github.com/yourusername/objectscript-design-patterns/wiki)
- **Issues**: [https://github.com/yourusername/objectscript-design-patterns/issues](https://github.com/yourusername/objectscript-design-patterns/issues)
- **Discussions**: [https://github.com/yourusername/objectscript-design-patterns/discussions](https://github.com/yourusername/objectscript-design-patterns/discussions)

## Acknowledgments

- Gang of Four - Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides
- Martin Fowler - Patterns of Enterprise Application Architecture
- InterSystems Developer Community

## Version

Current Version: 1.0.0

Compatible with InterSystems IRIS 2023.1 and higher.
