# Tech Stack

This is the DEFINITIVE technology selection section for the ObjectScript Design Patterns Library.

### Languages & Frameworks

**Primary Language:**
- **InterSystems ObjectScript** - The sole implementation language for all pattern implementations
  - Version: Compatible with IRIS 2023.1+ 
  - Rationale: Native language for IRIS platform with unique features (globals, multidimensional arrays)
  - Features Used: Classes, Methods, Properties, Embedded SQL, Macros, Globals

**Testing Framework:**
- **%UnitTest** - Built-in IRIS testing framework
  - Rationale: Native integration, no external dependencies
  - Coverage: Unit tests, integration tests, performance benchmarks

**Documentation Generation:**
- **ObjectScript Documatic** - Built-in class documentation
  - Rationale: Automatic API documentation from class definitions
  - Output: HTML documentation for all patterns

### Databases

**Primary Database:**
- **InterSystems IRIS** - Native object-relational database
  - Version: 2023.1 or higher
  - Namespaces: PATTERNS (production), PATTERNS-TEST (testing)
  - Features: Persistent classes, SQL projections, globals for metadata

**Data Storage Patterns:**
- **Persistent Classes** - For example data and pattern metadata
- **Serial Classes** - For embedded objects and value types
- **Registered Classes** - For non-persistent pattern implementations
- **Globals** - For pattern registry and configuration

### Development Tools

**IDE & Development:**
- **VS Code** with ObjectScript Extension
  - Primary development environment
  - Features: Syntax highlighting, debugging, server-side compilation
- **InterSystems Studio** (optional)
  - Alternative IDE for developers preferring native tools

**Version Control:**
- **Git** with GitHub
  - Repository: objectscript-design-patterns
  - Branching: Git Flow (main, develop, feature/*, release/*)

**Build & Deployment:**
- **Manual Class Import**
  - Developers import classes directly into sandbox environments
  - No automated deployment or CI/CD required
- **Docker** (Optional)
  - For consistent development environments
  - Image: intersystemsdc/iris-community:latest

**Code Quality:**
- **ObjectScript Quality** - Static analysis tool
  - Checks: Naming conventions, best practices, potential issues
- **Custom Linter Rules**
  - Pattern-specific validation
  - Documentation completeness checks

### 3rd Party Services

**Documentation & Examples:**
- **GitHub Pages**
  - Hosts pattern documentation and examples
  - Auto-generated from /docs folder
  
**Package Registry:**
- **InterSystems Package Manager Registry**
  - Public distribution of library
  - Version management

**Development Support:**
- **Manual Testing**
  - Developers run tests in their sandbox environments
  - Documentation maintained in repository

**Code Analysis:**
- **SonarQube** (optional)
  - Code quality metrics
  - Technical debt tracking

### Technology Constraints

**Mandatory Constraints:**
1. Pure ObjectScript implementation - no embedded Java/Python
2. No external dependencies outside IRIS platform
3. Compatible with IRIS Community Edition
4. All patterns must be namespace-agnostic
5. No UI components or web services

**Recommended Practices:**
1. Leverage ObjectScript-native features over emulating other languages
2. Use embedded SQL for data access patterns
3. Implement using %Library base classes where appropriate
4. Follow InterSystems naming conventions
5. Maintain backward compatibility with IRIS 2023.1+
