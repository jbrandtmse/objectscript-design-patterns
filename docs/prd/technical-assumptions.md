# Technical Assumptions

### Repository Structure: Monorepo
The project will use a monorepo structure on GitHub to house all pattern implementations, tests, and documentation in a single repository for simplified version control and team collaboration.

### Service Architecture
This is a library project with no service architecture per se. The codebase will be organized as:
- A collection of ObjectScript classes implementing design patterns
- Each pattern isolated in its own namespace/package
- No microservices or API endpoints required - purely a reference implementation library
- Patterns can be imported and used directly in IRIS applications

### Testing Requirements
- **Unit Testing**: Every pattern implementation must have comprehensive unit tests using IRIS's %UnitTest framework
- **Test Coverage**: 100% of public methods must be tested
- **Example Tests**: Tests should also serve as usage examples for developers
- **No Integration Testing Required**: As a library project, integration testing is not applicable
- **Manual Testing Convenience**: Each pattern should include a runnable demo method for manual verification

### Additional Technical Assumptions and Requests
- **InterSystems IRIS Platform**: All code must be compatible with InterSystems IRIS 2024.1 or later
- **ObjectScript Version**: Use modern ObjectScript syntax and features available in current IRIS versions
- **Documentation Format**: All documentation in Markdown format with potential for DocBook generation
- **IDE Support**: Code should work in both InterSystems Studio and VS Code with ObjectScript extension
- **Version Control**: Use Git with semantic versioning and conventional commits
- **CI/CD**: GitHub Actions for automated testing when possible (may require IRIS container)
- **Code Organization**: Follow package structure: `Patterns.GoF.Creational.*`, `Patterns.PoEAA.Domain.*`, etc.
- **Dependency Management**: No external dependencies beyond standard IRIS libraries
- **Coding Standards**: Strict adherence to the team's ObjectScript Coding Standards document
- **Language**: All code, comments, and documentation in English
- **Examples Database**: Use a separate namespace for example data to avoid conflicts
- **Performance**: Optimize for clarity over performance - this is educational reference code
