# High Level Architecture

### Technical Summary

The ObjectScript Design Patterns Library is a comprehensive reference implementation of design patterns for InterSystems IRIS. Built as a modular library architecture without services or runtime components, it provides developers with production-ready pattern implementations that leverage ObjectScript's unique features while maintaining Gang of Four and PoEAA pattern fidelity.

### High Level Overview

The system architecture embraces five key architectural decisions:

1. **Pure Library Architecture** - No services, APIs, or runtime components. This is a reference library providing importable pattern implementations.

2. **Namespace Segregation** - Clean separation between production code (PATTERNS) and test code (PATTERNS-TEST) ensuring isolation and clarity.

3. **Hierarchical Package Organization** - Structured as `Patterns.GoF.Category.*` and `Patterns.PoEAA.Category.*` for intuitive navigation and discovery.

4. **ObjectScript-First Design** - Leverages native ObjectScript features (globals, multidimensional arrays, embedded SQL) rather than forcing Java-like implementations.

5. **Comprehensive Test Coverage** - Every pattern includes unit tests, integration tests, and example implementations using %UnitTest framework.

### Architectural Diagram

```mermaid
graph TB
    subgraph "GitHub Repository"
        GH[objectscript-design-patterns]
        GH --> SRC[/src]
        GH --> TEST[/tests]
        GH --> DOCS[/docs]
        GH --> EX[/examples]
    end
    
    subgraph "IRIS Instance"
        subgraph "PATTERNS Namespace"
            PLIB[Pattern Library Classes]
            PLIB --> GOF[Patterns.GoF.*]
            PLIB --> POEAA[Patterns.PoEAA.*]
            PLIB --> UTIL[Patterns.Utils.*]
        end
        
        subgraph "PATTERNS-TEST Namespace"
            TLIB[Test Classes]
            TLIB --> UNIT[Unit Tests]
            TLIB --> INT[Integration Tests]
            TLIB --> PERF[Performance Tests]
        end
    end
    
    SRC -.->|Deploy| PLIB
    TEST -.->|Deploy| TLIB
    DOCS -.->|Reference| GH
    EX -.->|Examples| GOF
    EX -.->|Examples| POEAA
```

### Architectural Patterns

The library architecture follows these guiding patterns:

1. **Separation of Concerns** - Each pattern is self-contained with clear boundaries
2. **Dependency Inversion** - Patterns depend on abstractions, not concretions
3. **Single Responsibility** - Each class has one reason to change
4. **Interface Segregation** - Clients aren't forced to depend on unused methods
5. **Package Cohesion** - Related patterns are grouped logically
6. **Test Isolation** - Tests run independently without side effects
7. **Documentation as Code** - Examples serve as living documentation
