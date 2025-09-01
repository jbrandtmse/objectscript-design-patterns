# Source Tree

### Repository Structure

```
objectscript-design-patterns/
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                    # Continuous integration workflow
│   │   ├── release.yml                # Release automation
│   │   └── documentation.yml          # Documentation generation
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
│
├── src/
│   ├── Patterns/
│   │   ├── GoF/
│   │   │   ├── Creational/
│   │   │   │   ├── Singleton.cls
│   │   │   │   ├── Factory.cls
│   │   │   │   ├── AbstractFactory.cls
│   │   │   │   ├── Builder.cls
│   │   │   │   └── Prototype.cls
│   │   │   ├── Structural/
│   │   │   │   ├── Adapter.cls
│   │   │   │   ├── Bridge.cls
│   │   │   │   ├── Composite.cls
│   │   │   │   ├── Decorator.cls
│   │   │   │   ├── Facade.cls
│   │   │   │   ├── Flyweight.cls
│   │   │   │   └── Proxy.cls
│   │   │   └── Behavioral/
│   │   │       ├── ChainOfResponsibility.cls
│   │   │       ├── Command.cls
│   │   │       ├── Interpreter.cls
│   │   │       ├── Iterator.cls
│   │   │       ├── Mediator.cls
│   │   │       ├── Memento.cls
│   │   │       ├── Observer.cls
│   │   │       ├── State.cls
│   │   │       ├── Strategy.cls
│   │   │       ├── TemplateMethod.cls
│   │   │       └── Visitor.cls
│   │   │
│   │   ├── PoEAA/
│   │   │   ├── DataSource/
│   │   │   ├── DomainLogic/
│   │   │   ├── ObjectRelational/
│   │   │   ├── WebPresentation/
│   │   │   ├── Distribution/
│   │   │   ├── Offline/
│   │   │   ├── Session/
│   │   │   └── Base/
│   │   │
│   │   ├── Registry/
│   │   │   ├── Manager.cls
│   │   │   ├── PatternInfo.cls
│   │   │   └── Loader.cls
│   │   │
│   │   ├── Utils/
│   │   │   ├── Logger.cls
│   │   │   ├── Validator.cls
│   │   │   ├── Performance.cls
│   │   │   └── Documentation.cls
│   │   │
│   │   └── Examples/
│   │       ├── Person.cls
│   │       ├── Address.cls
│   │       ├── Order.cls
│   │       ├── OrderItem.cls
│   │       └── Demo.cls
│   │
│   └── includes/
│       ├── PatternMacros.inc         # Common macros
│       └── ErrorCodes.inc            # Error code definitions
│
├── tests/
│   ├── Unit/
│   │   ├── GoF/
│   │   │   ├── Creational/
│   │   │   ├── Structural/
│   │   │   └── Behavioral/
│   │   └── PoEAA/
│   │       ├── DataSource/
│   │       └── [other categories]/
│   │
│   ├── Integration/
│   │   ├── PatternIntegrationTests.cls
│   │   └── RegistryTests.cls
│   │
│   ├── Performance/
│   │   ├── BenchmarkSuite.cls
│   │   └── MemoryTests.cls
│   │
│   └── Fixtures/
│       ├── TestData.cls
│       └── MockFactory.cls
│
├── examples/
│   ├── basic/
│   │   ├── singleton-example.cls
│   │   ├── factory-example.cls
│   │   └── observer-example.cls
│   │
│   ├── advanced/
│   │   ├── composite-pattern-ui.cls
│   │   ├── mvc-implementation.cls
│   │   └── unit-of-work-demo.cls
│   │
│   └── real-world/
│       ├── order-processing-system.cls
│       ├── notification-system.cls
│       └── cache-implementation.cls
│
├── docs/
│   ├── api/                          # Generated API documentation
│   ├── patterns/                     # Pattern-specific documentation
│   │   ├── gof/
│   │   └── poeaa/
│   ├── guides/
│   │   ├── getting-started.md
│   │   ├── installation.md
│   │   └── contributing.md
│   └── architecture/
│       ├── architecture.md           # This document
│       └── diagrams/
│
├── scripts/
│   ├── install.sh                    # Installation script
│   ├── build.sh                      # Build script
│   ├── test.sh                       # Test runner
│   └── deploy.sh                     # Deployment script
│
├── docker/
│   ├── Dockerfile                    # IRIS container definition
│   ├── docker-compose.yml            # Development environment
│   └── iris.key                      # License key (gitignored)
│
├── .vscode/
│   ├── settings.json                 # VS Code settings
│   ├── launch.json                   # Debug configurations
│   └── extensions.json               # Recommended extensions
│
├── README.md                         # Project overview
├── LICENSE                           # MIT License
├── CONTRIBUTING.md                   # Contribution guidelines
├── CHANGELOG.md                     # Release history
├── module.xml                        # ZPM package definition
├── .gitignore                        # Git ignore rules
└── .editorconfig                     # Editor configuration
```

### File Naming Conventions

1. **ObjectScript Classes** - PascalCase with .cls extension
2. **Include Files** - PascalCase with .inc extension
3. **Documentation** - kebab-case with .md extension
4. **Scripts** - kebab-case with appropriate extension
5. **Configuration** - lowercase with standard extensions

### Directory Purposes

| Directory | Purpose | Contents |
|-----------|---------|----------|
| `/src` | Source code | All pattern implementations and utilities |
| `/tests` | Test code | Unit, integration, and performance tests |
| `/examples` | Usage examples | Demonstration code for each pattern |
| `/docs` | Documentation | Guides, API docs, architecture |
| `/scripts` | Build scripts | Installation and deployment automation |
| `/docker` | Container config | Docker setup for development |
| `/.github` | GitHub config | CI/CD workflows and templates |

### Module Organization Rules

1. **One Pattern Per File** - Each pattern is a single class file
2. **Test Mirrors Source** - Test structure matches source structure
3. **Examples Are Standalone** - Each example is self-contained
4. **Documentation Collocated** - Pattern docs next to implementation
5. **Shared Code in Utils** - Common functionality in utility classes
