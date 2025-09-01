# Contributing to ObjectScript Design Patterns Library

Thank you for your interest in contributing to the ObjectScript Design Patterns Library! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Accept feedback gracefully
- Put the project's best interests first

## How to Contribute

### Reporting Issues

Before creating an issue, please check existing issues to avoid duplicates.

#### Bug Reports

When reporting bugs, include:

1. **Description**: Clear, concise description of the bug
2. **Steps to Reproduce**: Detailed steps to reproduce the issue
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**: IRIS version, OS, relevant configuration
6. **Code Sample**: Minimal code example demonstrating the issue
7. **Error Messages**: Complete error messages or stack traces

Example bug report template:
```markdown
**Description**
The Singleton pattern returns multiple instances when called from different namespaces.

**Steps to Reproduce**
1. Import pattern library into namespace USER
2. Create singleton instance in USER namespace
3. Switch to namespace SAMPLES
4. Create another singleton instance
5. Compare instance IDs

**Expected Behavior**
Should return the same instance across namespaces

**Actual Behavior**
Returns different instances

**Environment**
- IRIS Version: 2023.1
- OS: Windows 10
- Namespace configuration: Standard

**Code Sample**
```objectscript
// In USER namespace
Set instance1 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
Write instance1, !

// In SAMPLES namespace
Set instance2 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
Write instance2, !  // Different from instance1
```
```

#### Feature Requests

For feature requests, provide:

1. **Use Case**: Describe the problem you're trying to solve
2. **Proposed Solution**: Your suggested implementation
3. **Alternatives**: Other solutions you've considered
4. **Additional Context**: Any relevant information

### Submitting Pull Requests

#### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/yourusername/objectscript-design-patterns.git
cd objectscript-design-patterns
git remote add upstream https://github.com/originalrepo/objectscript-design-patterns.git
```

#### 2. Create a Feature Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/pattern-name
# or
git checkout -b fix/issue-description
```

#### 3. Make Your Changes

Follow our coding standards:

- Adhere to ObjectScript coding conventions (see [Object Script Coding Standards.md](../Object%20Script%20Coding%20Standards.md))
- Include comprehensive documentation
- Write unit tests for new functionality
- Update examples if applicable

#### 4. Commit Your Changes

Use clear, descriptive commit messages:

```bash
# Good commit messages
git commit -m "Add: Implement Memento pattern with transaction support"
git commit -m "Fix: Correct singleton instance leak in multi-namespace setup"
git commit -m "Docs: Add advanced usage examples for Observer pattern"
git commit -m "Test: Add unit tests for Factory pattern edge cases"
git commit -m "Refactor: Optimize Registry pattern performance"

# Commit message format
<type>: <description>

# Types:
# Add - New feature or pattern
# Fix - Bug fix
# Docs - Documentation changes
# Test - Test additions or changes
# Refactor - Code refactoring
# Style - Code style changes
# Perf - Performance improvements
```

#### 5. Run Tests

Before submitting, ensure all tests pass:

```objectscript
// Run all tests
Do ##class(%UnitTest.Manager).RunTest("Patterns.Test")

// Run specific pattern tests
Do ##class(%UnitTest.Manager).RunTest("Patterns.Test.GoF.Creational.YourPattern")
```

#### 6. Push and Create Pull Request

```bash
# Push your branch
git push origin feature/pattern-name

# Create pull request on GitHub
```

In your pull request:

1. Reference any related issues
2. Describe your changes
3. Include test results
4. Add screenshots if UI-related
5. Update documentation

### Adding New Patterns

When contributing a new pattern:

#### 1. Pattern Implementation

Create the pattern class following our structure:

```objectscript
/// <Pattern Name> Pattern Implementation
/// 
/// Intent:
/// <Describe the pattern's intent>
/// 
/// Applicability:
/// <When to use this pattern>
/// 
/// @since 1.0.0
Class Patterns.Category.PatternName Extends %RegisteredObject
{
    // Implementation following coding standards
}
```

#### 2. Unit Tests

Create comprehensive tests:

```objectscript
Class Patterns.Test.Category.PatternNameTest Extends %UnitTest.TestCase
{
    Method TestBasicFunctionality()
    {
        // Test implementation
    }
    
    Method TestEdgeCases()
    {
        // Edge case tests
    }
    
    Method TestPerformance()
    {
        // Performance tests
    }
}
```

#### 3. Documentation

Create pattern documentation in `docs/patterns/`:

```markdown
# Pattern Name

## Intent
Describe what the pattern does

## Motivation
Explain why this pattern is needed

## Structure
Describe the pattern structure

## Implementation
Show implementation details

## Example Usage
Provide usage examples

## Known Uses
List real-world uses

## Related Patterns
Reference related patterns
```

#### 4. Examples

Add examples in `examples/`:

```objectscript
/// Example demonstrating Pattern usage
Class Examples.PatternNameExample
{
    ClassMethod RunExample()
    {
        // Demonstration code
    }
}
```

## Coding Standards

### ObjectScript Conventions

Follow our established conventions:

1. **Naming**:
   - Classes: PascalCase
   - Methods: PascalCase (public), camelCase (private)
   - Properties: PascalCase
   - Parameters: Prefix with 'p'
   - Variables: camelCase

2. **Documentation**:
   - All public methods must have documentation
   - Include parameter descriptions
   - Provide usage examples

3. **Error Handling**:
   - Always return %Status from methods
   - Use Try-Catch for exception handling
   - Log errors appropriately

4. **Testing**:
   - Minimum 80% code coverage
   - Test happy path and edge cases
   - Include performance tests for critical paths

### Code Review Checklist

Before submitting, ensure:

- [ ] Code follows ObjectScript coding standards
- [ ] All tests pass
- [ ] Documentation is complete
- [ ] No hardcoded values
- [ ] Error handling is implemented
- [ ] Performance is optimized
- [ ] Security is considered
- [ ] Examples are provided
- [ ] Changes are backward compatible

## Documentation Guidelines

### Writing Style

- Use clear, concise language
- Include code examples
- Explain "why" not just "how"
- Keep examples practical
- Update all affected documentation

### Documentation Structure

1. **Class Documentation**: Comprehensive class-level docs
2. **Method Documentation**: Clear method descriptions
3. **Usage Examples**: Practical, runnable examples
4. **Pattern Guides**: Detailed pattern explanations
5. **API Reference**: Complete API documentation

## Testing Guidelines

### Test Categories

1. **Unit Tests**: Test individual components
2. **Integration Tests**: Test pattern interactions
3. **Performance Tests**: Benchmark critical operations
4. **Regression Tests**: Prevent reintroduction of bugs

### Writing Tests

```objectscript
Method TestPatternBehavior()
{
    // Arrange
    Set pattern = ##class(Pattern).%New()
    Set expected = "ExpectedResult"
    
    // Act
    Set actual = pattern.Execute()
    
    // Assert
    Do ..AssertEquals(actual, expected, "Description")
    
    // Cleanup
    Do pattern.%Close()
}
```

## Release Process

### Version Numbering

We use Semantic Versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backward-compatible functionality additions
- **PATCH**: Backward-compatible bug fixes

### Release Checklist

1. [ ] All tests pass
2. [ ] Documentation updated
3. [ ] CHANGELOG.md updated
4. [ ] Version numbers updated
5. [ ] Release notes prepared
6. [ ] Tagged in git

## Getting Help

### Resources

- [Getting Started Guide](getting-started.md)
- [Installation Guide](installation.md)
- [Architecture Documentation](../architecture/)
- [ObjectScript Documentation](https://docs.intersystems.com/iris/latest/csp/docbook/DocBook.UI.Page.cls)

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and discussions
- **Email**: patterns@example.com
- **Community Forum**: InterSystems Developer Community

## Recognition

Contributors are recognized in:

- CONTRIBUTORS.md file
- Release notes
- Project documentation
- Annual contributor report

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

If you have questions about contributing:

1. Check this guide
2. Review existing issues and discussions
3. Ask in GitHub Discussions
4. Contact the maintainers

Thank you for contributing to the ObjectScript Design Patterns Library!
