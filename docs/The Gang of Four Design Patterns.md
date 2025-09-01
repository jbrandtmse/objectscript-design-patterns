<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# The Gang of Four Design Patterns

The **Gang of Four (GoF) Design Patterns** are a collection of 23 classic software design patterns documented in the influential 1994 book "Design Patterns: Elements of Reusable Object-Oriented Software". Authored by Erich Gamma, Richard Helm, Ralph Johnson, and John Vlissides (collectively known as the "Gang of Four"), these patterns have become the foundation of modern software engineering and object-oriented design.[^1_1][^1_2]

These patterns provide proven solutions to recurring design problems in software development, offering developers a shared vocabulary and systematic approaches to creating flexible, maintainable, and reusable code. The patterns are organized into three main categories based on their purpose: **Creational**, **Structural**, and **Behavioral** patterns.[^1_3][^1_2][^1_1]

## Creational Design Patterns

Creational patterns focus on object creation mechanisms, providing ways to create objects while hiding the creation logic and making the system independent of how objects are created, composed, and represented. There are **5 creational patterns**:[^1_2][^1_1]


| Pattern | Description |
| :-- | :-- |
| **Singleton** | Ensures a class has only one instance and provides global access to it[^1_1][^1_4]. Useful for managing shared resources like database connections or configuration settings. |
| **Factory Method** | Creates objects without specifying their exact class, allowing subclasses to decide which class to instantiate[^1_1][^1_4]. Promotes loose coupling between creator and product classes. |
| **Abstract Factory** | Provides an interface for creating families of related objects without specifying their concrete classes[^1_1][^1_4]. Often described as a "factory of factories." |
| **Builder** | Separates the construction of complex objects from their representation, allowing the same construction process to create different representations[^1_1][^1_4]. Ideal for objects with many optional parameters. |
| **Prototype** | Creates new objects by copying existing instances rather than creating from scratch[^1_1][^1_4]. Particularly efficient when object creation is expensive. |

## Structural Design Patterns

Structural patterns deal with object composition and relationships, focusing on how classes and objects are composed to form larger, more complex structures while maintaining flexibility and efficiency. There are **7 structural patterns**:[^1_1][^1_2]


| Pattern | Description |
| :-- | :-- |
| **Adapter** | Allows incompatible interfaces to work together by acting as a bridge between different systems[^1_1][^1_4]. Like using an electrical adapter for different plug types. |
| **Bridge** | Separates an abstraction from its implementation, allowing both to vary independently[^1_1][^1_4]. Useful when both abstraction and implementation need to change. |
| **Composite** | Composes objects into tree structures to represent part-whole hierarchies[^1_1][^1_4]. Allows clients to treat individual objects and compositions uniformly. |
| **Decorator** | Adds new responsibilities to objects dynamically without modifying their structure[^1_1][^1_4]. Provides a flexible alternative to subclassing for extending functionality. |
| **Facade** | Provides a simplified interface to a complex subsystem[^1_1][^1_4]. Hides complexity from clients by offering a unified interface. |
| **Flyweight** | Minimizes memory usage by sharing data among similar objects[^1_1][^1_4]. Efficient for handling large numbers of fine-grained objects. |
| **Proxy** | Provides a placeholder or surrogate to control access to another object[^1_1][^1_4]. Used for lazy loading, access control, or caching. |

## Behavioral Design Patterns

Behavioral patterns focus on communication between objects and the assignment of responsibilities, defining how objects interact and collaborate to accomplish tasks. There are **11 behavioral patterns**:[^1_2][^1_1]


| Pattern | Description |
| :-- | :-- |
| **Observer** | Defines a one-to-many dependency between objects, automatically notifying dependents when the subject changes state[^1_1][^1_4]. Essential for event-driven systems. |
| **Strategy** | Defines a family of algorithms, encapsulates each one, and makes them interchangeable[^1_1][^1_4]. Allows algorithms to vary independently from clients. |
| **Command** | Encapsulates requests as objects, enabling parameterization, queuing, logging, and undo operations[^1_1][^1_4]. Decouples sender from receiver. |
| **State** | Allows objects to alter behavior when their internal state changes[^1_1][^1_4]. The object appears to change its class based on state transitions. |
| **Template Method** | Defines the skeleton of an algorithm, allowing subclasses to override specific steps without changing the algorithm's structure[^1_1][^1_4]. |
| **Chain of Responsibility** | Passes requests along a chain of handlers until one handles it[^1_1][^1_4]. Avoids coupling the sender to specific receivers. |
| **Mediator** | Defines how objects interact through a central mediator, reducing direct dependencies[^1_1][^1_4]. Promotes loose coupling by centralizing communication. |
| **Iterator** | Provides sequential access to elements of a collection without exposing its internal representation[^1_1][^1_4]. Standardizes traversal across different data structures. |
| **Visitor** | Defines new operations on object structures without modifying the objects themselves[^1_1][^1_4]. Separates algorithms from the objects they operate on. |
| **Memento** | Captures and externalizes an object's internal state for later restoration[^1_1][^1_4]. Enables undo functionality while maintaining encapsulation. |
| **Interpreter** | Defines a representation for a language's grammar and provides an interpreter for it[^1_1][^1_4]. Used for implementing domain-specific languages or expression evaluators. |

## Benefits and Impact

The Gang of Four design patterns provide several key advantages for software development:[^1_1][^1_2]

**Reusability**: Patterns promote code reuse by providing tested solutions that can be applied across different projects and contexts.

**Maintainability**: Well-structured patterns make code easier to understand, debug, and modify by providing clear separation of concerns.

**Communication**: Patterns establish a common vocabulary among developers, facilitating better collaboration and knowledge sharing.

**Flexibility**: By following these patterns, systems become more adaptable to change and easier to extend with new functionality.

**Quality**: Patterns represent best practices developed over decades of software engineering experience, helping prevent common design mistakes.

These 23 patterns continue to be fundamental to modern software engineering, serving as building blocks for creating robust, scalable, and maintainable software architectures. While originally focused on object-oriented programming, many of these concepts have been adapted and applied across different programming paradigms and modern development frameworks.[^1_1]
<span style="display:none">[^1_10][^1_11][^1_12][^1_13][^1_14][^1_15][^1_16][^1_5][^1_6][^1_7][^1_8][^1_9]</span>

<div style="text-align: center">⁂</div>

[^1_1]: https://www.digitalocean.com/community/tutorials/gangs-of-four-gof-design-patterns

[^1_2]: https://www.geeksforgeeks.org/introduction-to-gang-of-fourgof-design-patterns/

[^1_3]: https://www.geeksforgeeks.org/system-design/gang-of-four-gof-design-patterns/

[^1_4]: https://www.dofactory.com/net/design-patterns

[^1_5]: https://dev.to/lovestaco/the-gang-of-four-gof-design-patterns-a-developers-guide-473a

[^1_6]: https://www.javier8a.com/itc/bd1/articulo.pdf

[^1_7]: https://hackmd.io/5zpNE4F1QUGOkEP4LlUirg

[^1_8]: https://www.coursera.org/articles/gang-of-four-design-patterns

[^1_9]: https://springframework.guru/gang-of-four-design-patterns/

[^1_10]: https://gist.github.com/xnuinside/0de6418355d39a3babbd857c25457861

[^1_11]: https://www.emse.fr/~boissier/enseignement/tbi2si/SoftGoodPractices/pdf/2.3.BehavioralPatterns.pdf

[^1_12]: https://www.linkedin.com/pulse/design-patterns-divided-three-categories-creational-structural-zhou

[^1_13]: https://www.geeksforgeeks.org/system-design/behavioral-design-patterns/

[^1_14]: https://www.gofpattern.com/design-patterns/module2/three-types-design-patterns.php

[^1_15]: https://refactoring.guru/design-patterns/behavioral-patterns

[^1_16]: https://www.geeksforgeeks.org/system-design/introduction-to-pattern-designing/


---

# Modern Design Patterns Beyond the Gang of Four

Yes, there are indeed numerous **additional design patterns** that have emerged since the original Gang of Four's 23 patterns in 1994. While the GoF patterns remain foundational, the software development landscape has evolved significantly, giving rise to new architectural challenges and corresponding pattern solutions.[^2_1][^2_2][^2_3][^2_4]

## Categories of Modern Patterns

### Enterprise Application Patterns

**Martin Fowler's "Patterns of Enterprise Application Architecture" (PoEAA)** introduced over 40 additional patterns specifically for enterprise applications. These patterns address challenges not covered by the original GoF patterns:[^2_5][^2_6][^2_7]


| Pattern Category | Examples |
| :-- | :-- |
| **Domain Logic Patterns** | Transaction Script, Domain Model, Table Module, Service Layer[^2_7] |
| **Data Source Patterns** | Table Data Gateway, Row Data Gateway, Active Record, Data Mapper[^2_7] |
| **Object-Relational Mapping** | Identity Map, Unit of Work, Lazy Load[^2_7] |
| **Web Presentation** | Model View Controller (for web), Page Controller, Front Controller[^2_7] |
| **Distribution Patterns** | Remote Facade, Data Transfer Object[^2_7] |
| **Offline Concurrency** | Optimistic Offline Lock, Pessimistic Offline Lock[^2_7] |

### Microservices Design Patterns

The rise of **microservices architecture** has spawned an entirely new category of patterns:[^2_8][^2_9][^2_10]

**Core Microservices Patterns:**

- **API Gateway Pattern** - Single entry point for client requests with cross-cutting concerns[^2_9][^2_8]
- **Database per Service** - Each microservice owns its data store[^2_10][^2_8]
- **Circuit Breaker Pattern** - Prevents cascading failures in distributed systems[^2_11][^2_8]
- **Service Discovery** - Dynamic registration and location of services[^2_8][^2_10]
- **Saga Pattern** - Managing distributed transactions across microservices[^2_8]

**Deployment Patterns:**

- **Service Instance per Container** - Containerized microservice deployment[^2_8]
- **Blue-Green Deployment** - Zero-downtime deployments[^2_8]
- **Backends for Frontends (BFF)** - Separate backend services for different client types[^2_9][^2_10]


### Modern Architectural Patterns

Contemporary software development has introduced several **architectural patterns** that extend beyond the original GoF scope:[^2_12][^2_13]


| Pattern | Purpose |
| :-- | :-- |
| **Event Sourcing** | Captures all changes as events for audit trails and temporal queries[^2_12] |
| **CQRS (Command Query Responsibility Segregation)** | Separates read and write operations for scalability[^2_11] |
| **Hexagonal Architecture** | Isolates core business logic from external dependencies[^2_12] |
| **Serverless Architecture** | Event-driven functions without server management[^2_12] |
| **Layered Architecture** | N-tier separation of concerns[^2_12] |

### Behavioral Pattern Extensions

Several patterns have emerged that complement the original behavioral patterns:[^2_14][^2_15]

**Null Object Pattern**: Provides default "do nothing" behavior instead of null references, eliminating null checks. While some sources list this as part of GoF extensions, it represents a commonly recognized pattern that addresses modern null-safety concerns.[^2_15][^2_16][^2_14]

**Model-View-ViewModel (MVVM)** and **Model-View-Presenter (MVP)**: These extend the original MVC pattern with improved data binding and testability:[^2_17][^2_18][^2_19]


| Pattern | Key Characteristic |
| :-- | :-- |
| **MVC** | Controller mediates between Model and View[^2_18] |
| **MVP** | Presenter handles all UI logic, one-to-one with View[^2_18] |
| **MVVM** | ViewModel with two-way data binding, supports multiple Views[^2_18] |

### Dependency Management Patterns

Modern dependency management has introduced patterns that complement the original GoF patterns:[^2_20][^2_21][^2_22]

**Dependency Injection vs Service Locator**: While both implement inversion of control, they differ in approach:[^2_22][^2_20]

- **Dependency Injection**: Dependencies are injected via constructors/setters[^2_20]
- **Service Locator**: Objects actively request dependencies from a central registry[^2_22][^2_20]


### Emerging Patterns for Modern Technologies

**AI and Machine Learning Patterns**: As noted in recent research, modern AI systems have introduced entirely new pattern categories:[^2_4]

- **Feature Store Pattern** - Centralized feature management for ML models[^2_4]
- **Model Versioning Pattern** - Managing ML model deployments[^2_4]
- **Checkpointing Pattern** - Saving and restoring model state[^2_4]

**Cloud-Native Patterns**: Cloud computing has spawned patterns like:[^2_4]

- **Publish-Subscribe (Pub-Sub)** - Event-driven messaging[^2_4]
- **Event-Driven Workflows** - Reactive system architectures[^2_4]
- **Bulkhead Pattern** - Resource isolation for fault tolerance[^2_9]


## Evolution and Adoption

**Pattern Discovery vs. Invention**: As noted by developers, patterns are typically "discovered" rather than "invented," representing solutions that emerge from real-world software development challenges. The **Pattern-Oriented Software Architecture** series has documented many additional patterns beyond the original 23.[^2_2]

**Industry Recognition**: While the GoF patterns remain the most universally recognized, these additional patterns have gained significant adoption in their respective domains. Enterprise patterns are standard in business applications, microservices patterns are essential for distributed systems, and architectural patterns guide modern system design.[^2_3][^2_5][^2_12][^2_8]

**Language Evolution Impact**: Modern programming languages with advanced features have both simplified some GoF pattern implementations and created needs for new patterns. Functional programming languages, for instance, may eliminate the need for certain object-oriented patterns while introducing their own pattern categories.[^2_23][^2_24]

The software engineering field continues to evolve, and new patterns emerge as developers face novel challenges in areas like distributed systems, cloud computing, artificial intelligence, and modern web development. While the original 23 Gang of Four patterns remain foundational, this expanding catalog of patterns reflects the growing sophistication and diversity of modern software systems.[^2_2][^2_3][^2_4]
<span style="display:none">[^2_25][^2_26][^2_27][^2_28][^2_29][^2_30][^2_31][^2_32][^2_33][^2_34]</span>

<div style="text-align: center">⁂</div>

[^2_1]: https://www.digitalocean.com/community/tutorials/gangs-of-four-gof-design-patterns

[^2_2]: https://www.reddit.com/r/cpp_questions/comments/qyaqhw/has_any_new_design_patterns_been_invented_since/

[^2_3]: https://blogs.newardassociates.com/blog/2016/reclaiming-design-patterns.html

[^2_4]: https://www.infoq.com/articles/practical-design-patterns-modern-ai-systems/

[^2_5]: https://www.oreilly.com/library/view/patterns-of-enterprise/0321127420/

[^2_6]: https://dl.ebooksworld.ir/motoman/Patterns of Enterprise Application Architecture.pdf

[^2_7]: https://martinfowler.com/eaaCatalog/

[^2_8]: https://www.geeksforgeeks.org/system-design/microservices-design-patterns/

[^2_9]: https://learn.microsoft.com/en-us/azure/architecture/microservices/design/patterns

[^2_10]: https://dev.to/somadevtoo/19-microservices-patterns-for-system-design-interviews-3o39

[^2_11]: https://www.redhat.com/en/blog/14-software-architecture-patterns

[^2_12]: https://dzone.com/articles/top-10-software-architecture-patterns-to-follow

[^2_13]: https://www.sencha.com/blog/top-architecture-pattern-used-in-modern-enterprise-software-development/

[^2_14]: https://sourcemaking.com/design_patterns

[^2_15]: https://www.geeksforgeeks.org/system-design/null-object-design-pattern/

[^2_16]: https://sourcemaking.com/design_patterns/null_object

[^2_17]: https://dev.to/chiragagg5k/architecture-patterns-for-beginners-mvc-mvp-and-mvvm-2pe7

[^2_18]: https://www.geeksforgeeks.org/android/difference-between-mvc-mvp-and-mvvm-architecture-pattern-in-android/

[^2_19]: https://www.scholarhat.com/tutorial/designpatterns/understanding-mvc-mvp-and-mvvm-design-patterns

[^2_20]: https://stackoverflow.com/questions/1557781/whats-the-difference-between-the-dependency-injection-and-service-locator-patte

[^2_21]: https://en.wikipedia.org/wiki/Service_locator_pattern

[^2_22]: https://www.baeldung.com/cs/dependency-injection-vs-service-locator

[^2_23]: https://news.ycombinator.com/item?id=12712189

[^2_24]: https://stackoverflow.com/questions/327955/does-functional-programming-replace-gof-design-patterns

[^2_25]: https://www.youtube.com/watch?v=YMAwgRwjEOQ

[^2_26]: https://www.youtube.com/watch?v=tAuRQs_d9F8

[^2_27]: https://blog.frankel.ch/dissolving-design-patterns/

[^2_28]: https://stackoverflow.com/questions/1175506/design-patterns-not-in-the-gang-of-four

[^2_29]: http://princetonacm.acm.org/tcfpro/presentations/mancl_new_patterns_talk_2017.pdf

[^2_30]: https://www.reddit.com/r/learnprogramming/comments/10ora93/alternatives_to_design_pattern_references_other/

[^2_31]: https://www.simform.com/blog/software-architecture-patterns/

[^2_32]: https://www.bennadel.com/blog/3353-patterns-of-enterprise-application-architecture-by-martin-fowler.htm

[^2_33]: https://www.youtube.com/watch?v=D4Dja5WSZoA

[^2_34]: https://en.wikipedia.org/wiki/Null_object_pattern


---

# A Comprehensive Learning Outline for GoF and PoEAA Design Patterns

This learning outline presents a **logical progression** through the 23 Gang of Four patterns followed by Martin Fowler's 40+ Patterns of Enterprise Application Architecture (PoEAA). The sequence builds foundational knowledge first, then advances to enterprise-level concerns, ensuring each pattern builds upon previously learned concepts.[^3_1][^3_2][^3_3]

## Phase 1: Object-Oriented Fundamentals (Prerequisites)

Before diving into patterns, ensure solid understanding of:

- **Encapsulation, Abstraction, Inheritance, Polymorphism**
- **SOLID Principles** (especially Dependency Inversion and Open/Closed)
- **Basic UML notation** for class diagrams[^3_4]
- **Test-Driven Development basics** (patterns become clearer when refactoring tested code)[^3_5]


## Phase 2: Foundation Patterns - Creational (Weeks 1-2)

Start with **creational patterns** as they establish fundamental object creation concepts that other patterns will reference:[^3_2][^3_6][^3_1]

### Week 1: Simple Creation Patterns

1. **Singleton** - Master controlled instantiation first[^3_6][^3_1]
    - Practice: Configuration manager, logger, database connection pool
    - Key concept: Global access control
2. **Factory Method** - Learn flexible object creation[^3_1][^3_6]
    - Practice: Shape factory, database connection factory
    - Key concept: Loose coupling between creator and product

### Week 2: Complex Creation Patterns

3. **Abstract Factory** - Extend Factory Method for families of objects[^3_6][^3_1]
    - Practice: UI theme factory (Windows/Mac), database driver factory
    - Key concept: Creating related object families
4. **Builder** - Handle complex object construction[^3_1][^3_6]
    - Practice: SQL query builder, configuration builder
    - Key concept: Step-by-step construction vs monolithic creation
5. **Prototype** - Understand cloning for expensive objects[^3_6][^3_1]
    - Practice: Game character templates, document templates
    - Key concept: Creation through copying

## Phase 3: Object Relationship Patterns - Structural (Weeks 3-4)

**Structural patterns** teach how objects collaborate and compose, essential for understanding enterprise architectures:[^3_2][^3_1]

### Week 3: Basic Composition

6. **Adapter** - Learn interface compatibility[^3_1]
    - Practice: Legacy system integration, third-party API wrappers
    - Key concept: Making incompatible interfaces work together
7. **Facade** - Master subsystem simplification[^3_1]
    - Practice: Complex library wrapper, system API gateway
    - Key concept: Hiding complexity behind simple interfaces
8. **Decorator** - Understand dynamic behavior addition[^3_1]
    - Practice: Stream processors, middleware chains
    - Key concept: Extending object behavior without inheritance

### Week 4: Advanced Composition

9. **Composite** - Learn part-whole hierarchies[^3_1]
    - Practice: File system, GUI components, organizational charts
    - Key concept: Treating individual and composite objects uniformly
10. **Bridge** - Separate abstraction from implementation[^3_1]
    - Practice: Database abstraction layer, device drivers
    - Key concept: Allowing both abstraction and implementation to vary
11. **Proxy** - Control object access[^3_1]
    - Practice: Lazy loading, security proxy, caching proxy
    - Key concept: Placeholder for controlling access
12. **Flyweight** - Optimize memory usage[^3_1]
    - Practice: Text editor character objects, game sprite management
    - Key concept: Sharing to minimize memory footprint

## Phase 4: Interaction Patterns - Behavioral (Weeks 5-7)

**Behavioral patterns** are most complex but crucial for enterprise applications. Learn them in order of dependency:[^3_2][^3_1]

### Week 5: Basic Communication

13. **Observer** - Master one-to-many notifications[^3_1]
    - Practice: Event systems, model-view architectures
    - Key concept: Loose coupling in event-driven systems
14. **Strategy** - Learn algorithm encapsulation[^3_1]
    - Practice: Payment processors, sorting algorithms, validation rules
    - Key concept: Making algorithms interchangeable
15. **Command** - Understand request encapsulation[^3_1]
    - Practice: Undo systems, macro recording, queuing systems
    - Key concept: Treating requests as objects

### Week 6: Control Flow Patterns

16. **Template Method** - Learn algorithm skeleton definition[^3_1]
    - Practice: Data processing pipelines, workflow templates
    - Key concept: Defining algorithm structure while allowing step variations
17. **State** - Master state-dependent behavior[^3_1]
    - Practice: State machines, game character states, order processing
    - Key concept: Objects that change behavior based on internal state
18. **Chain of Responsibility** - Learn request handling chains[^3_1]
    - Practice: Middleware pipelines, validation chains, logging chains
    - Key concept: Passing requests along handler chains

### Week 7: Advanced Behavioral Patterns

19. **Mediator** - Understand centralized communication[^3_1]
    - Practice: Chat room systems, form validation, component coordination
    - Key concept: Reducing direct dependencies between objects
20. **Iterator** - Master collection traversal[^3_1]
    - Practice: Database cursors, tree traversal, collection abstractions
    - Key concept: Accessing elements without exposing internal structure
21. **Visitor** - Learn operation separation[^3_1]
    - Practice: Syntax tree processing, report generation, data export
    - Key concept: Adding operations without modifying object structures
22. **Memento** - Understand state capture and restoration[^3_1]
    - Practice: Undo mechanisms, checkpoints, state snapshots
    - Key concept: Capturing state without violating encapsulation
23. **Interpreter** - Learn language representation[^3_1]
    - Practice: Expression evaluators, configuration languages, rule engines
    - Key concept: Representing and interpreting language grammar

## Phase 5: Enterprise Foundation Concepts (Week 8)

Before diving into PoEAA patterns, establish enterprise application fundamentals:[^3_7][^3_3][^3_8]

### Enterprise Architecture Basics

- **Layered Architecture** principles[^3_3][^3_9]
- **Three-tier architecture**: Presentation, Domain, Data Source[^3_9][^3_3]
- **Separation of Concerns** in enterprise contexts[^3_3]
- **Transaction and concurrency** basics[^3_3]


### Key Concepts

- **Business Logic vs. Application Logic**[^3_10][^3_3]
- **Object-Relational Mapping** challenges[^3_3]
- **Web presentation** patterns[^3_3]
- **Distribution and integration** concerns[^3_3]


## Phase 6: Domain Logic Organization (Weeks 9-10)

Start with **domain logic patterns** as they form the heart of enterprise applications:[^3_11][^3_10][^3_3]

### Week 9: Simple Domain Logic

24. **Transaction Script** - Learn procedural domain logic organization[^3_10][^3_3]
    - Practice: Simple CRUD applications, basic business operations
    - Key concept: One procedure per business transaction
    - When to use: Simple domain logic, small applications
25. **Table Module** - Understand table-based logic organization[^3_10][^3_3]
    - Practice: Report generation, data processing applications
    - Key concept: One class handles all rows in a database table
    - When to use: Record-set oriented environments

### Week 10: Rich Domain Logic

26. **Domain Model** - Master object-oriented domain logic[^3_10][^3_3]
    - Practice: Complex business applications, rich domain logic
    - Key concept: Objects incorporating both data and behavior
    - When to use: Complex domain logic, object-oriented teams
27. **Service Layer** - Learn application boundary definition[^3_9][^3_3]
    - Practice: API design, transaction boundaries, security enforcement
    - Key concept: Defining available operations and coordinating responses
    - Relationship: Often sits above Domain Model

## Phase 7: Data Source Architectural Patterns (Weeks 11-12)

Learn **data access patterns** that complement domain logic patterns:[^3_3]

### Week 11: Gateway Patterns

28. **Table Data Gateway** - One gateway per table[^3_3]
    - Practice: Simple data access, stored procedure wrappers
    - Key concept: Gateway to database table operations
    - Works well with: Transaction Script, Table Module
29. **Row Data Gateway** - One gateway per row[^3_3]
    - Practice: Record-based data access, simple domain objects
    - Key concept: Gateway wrapping single database records
    - Works well with: Transaction Script

### Week 12: Rich Data Patterns

30. **Active Record** - Combine data and behavior[^3_3]
    - Practice: Simple domain objects, Rails-style applications
    - Key concept: Object wraps database row and includes domain logic
    - Works well with: Simple Domain Model
31. **Data Mapper** - Separate domain from database[^3_10][^3_3]
    - Practice: Complex domain models, database independence
    - Key concept: Layer moving data between objects and database
    - Works well with: Rich Domain Model

## Phase 8: Object-Relational Behavioral Patterns (Weeks 13-14)

Learn patterns for managing **object-relational complexity**:[^3_3]

### Week 13: Identity and References

32. **Identity Map** - Ensure one object per database record[^3_3]
    - Practice: Preventing duplicate objects, maintaining object identity
    - Key concept: Registry of loaded objects
33. **Lazy Load** - Defer expensive operations[^3_3]
    - Practice: Performance optimization, large object graphs
    - Key concept: Loading objects only when needed

### Week 14: Transaction Management

34. **Unit of Work** - Track object changes[^3_3]
    - Practice: Transaction management, change tracking
    - Key concept: Maintaining list of objects affected by business transaction

## Phase 9: Object-Relational Structural Patterns (Weeks 15-16)

Master **inheritance and relationship mapping** patterns:[^3_3]

### Week 15: Inheritance Mapping

35. **Single Table Inheritance** - Map hierarchy to single table[^3_3]
36. **Class Table Inheritance** - Map hierarchy to multiple tables[^3_3]
37. **Concrete Table Inheritance** - Map each concrete class to table[^3_3]

### Week 16: Relationship Mapping

38. **Foreign Key Mapping** - Use foreign keys for associations[^3_3]
39. **Association Table Mapping** - Use association tables for many-to-many[^3_3]
40. **Dependent Mapping** - Handle object composition[^3_3]

## Phase 10: Web Presentation Patterns (Weeks 17-18)

Learn **web-specific** presentation patterns:[^3_3]

### Week 17: MVC Variants

41. **Model View Controller** - Separate presentation concerns[^3_3]
42. **Page Controller** - One controller per page[^3_3]
43. **Front Controller** - Centralized request handling[^3_3]

### Week 18: View Patterns

44. **Template View** - Embed markers in HTML[^3_3]
45. **Transform View** - Transform domain data to HTML[^3_3]
46. **Two Step View** - Transform to logical screen then HTML[^3_3]

## Phase 11: Distribution and Integration (Weeks 19-20)

Learn patterns for **distributed systems**:[^3_8][^3_3]

### Week 19: Distribution Patterns

47. **Remote Facade** - Coarse-grained remote interface[^3_3]
48. **Data Transfer Object** - Reduce remote calls[^3_3]

### Week 20: Integration Patterns

49. **Gateway** - Encapsulate access to external systems[^3_3]
50. **Mapper** - Handle data format translation[^3_3]

## Phase 12: Advanced Enterprise Patterns (Weeks 21-22)

Complete with **concurrency and optimization** patterns:[^3_3]

### Week 21: Concurrency Patterns

51. **Optimistic Offline Lock** - Handle concurrent access optimistically[^3_3]
52. **Pessimistic Offline Lock** - Handle concurrent access pessimistically[^3_3]

### Week 22: Session State and Base Patterns

53. **Client Session State** - Store state on client[^3_3]
54. **Server Session State** - Store state on server[^3_3]
55. **Database Session State** - Store state in database[^3_3]

Plus foundational patterns like **Registry**, **Value Object**, **Money**, and **Special Case**.[^3_3]

## Learning Strategy and Best Practices

### Recommended Approach

1. **Practice-Driven Learning**: Implement each pattern in your preferred language[^3_5]
2. **Refactoring Focus**: Start with simple code and refactor into patterns[^3_5]
3. **Real-World Application**: Apply patterns to actual projects, not just toy examples[^3_1]
4. **Progressive Complexity**: Master simple patterns before complex ones[^3_4]

### Key Learning Principles

- **Patterns are discovered, not invented** - Look for recurring problems in your code[^3_12]
- **Don't force patterns** - Use them when they solve real problems[^3_5]
- **Understand the trade-offs** - Every pattern has costs and benefits[^3_7]
- **Focus on communication** - Patterns create shared vocabulary[^3_2][^3_1]


### Assessment Milestones

- **Week 8**: Implement a simple application using GoF patterns
- **Week 16**: Build an enterprise application using domain and data patterns
- **Week 22**: Design a distributed enterprise system using all pattern categories

This progression ensures that foundational concepts support more advanced enterprise patterns, creating a solid understanding of both object-oriented design and enterprise architecture principles.[^3_7][^3_1][^3_3]
<span style="display:none">[^3_13][^3_14][^3_15][^3_16][^3_17][^3_18][^3_19][^3_20]</span>

<div style="text-align: center">⁂</div>

[^3_1]: https://www.digitalocean.com/community/tutorials/gangs-of-four-gof-design-patterns

[^3_2]: https://www.geeksforgeeks.org/introduction-to-gang-of-fourgof-design-patterns/

[^3_3]: https://martinfowler.com/eaaCatalog/

[^3_4]: https://www.youtube.com/watch?v=rylaiB2uH2A

[^3_5]: https://stackoverflow.com/questions/315000/how-to-study-design-patterns

[^3_6]: https://springframework.guru/gang-of-four-design-patterns/

[^3_7]: https://culttt.com/2015/03/11/patterns-of-enterprise-application-architecture-review

[^3_8]: https://martinfowler.com/articles/enterprisePatterns.html

[^3_9]: https://gist.github.com/9547489

[^3_10]: https://inviqa.com/blog/architecture-patterns-domain-model-and-friends

[^3_11]: https://dev.to/edgaremmanuel/patterns-of-entreprise-application-architecture-organizing-domain-logic-k4c

[^3_12]: https://dl.ebooksworld.ir/motoman/Patterns of Enterprise Application Architecture.pdf

[^3_13]: https://mathteachercoach.com/number-sequences-and-patterns/

[^3_14]: https://stackoverflow.com/questions/125656/categories-of-design-patterns

[^3_15]: https://refactoring.guru/design-patterns

[^3_16]: https://dev.to/lovestaco/the-gang-of-four-gof-design-patterns-a-developers-guide-473a

[^3_17]: https://www.oreilly.com/library/view/patterns-of-enterprise/0321127420/

[^3_18]: https://www.informit.com/store/patterns-of-enterprise-application-architecture-9780321127426

[^3_19]: https://sar.ac.id/stmik_ebook/prog_file_file/EFCofwzsj0.pdf

[^3_20]: https://herbertograca.com/category/development/book-notes/patterns-of-enterprise-application-architecture-by-martin-fowler/

