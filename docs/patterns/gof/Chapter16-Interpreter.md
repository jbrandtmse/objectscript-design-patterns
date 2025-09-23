# Chapter 16: Interpreter Pattern

## Intent

Given a language, define a representation for its grammar along with an interpreter that uses the representation to interpret sentences in the language.

## Also Known As

- Expression Tree
- Abstract Syntax Tree (AST)

## Motivation

The Interpreter pattern is useful when you have a simple language to interpret, and you can represent statements in the language as abstract syntax trees. The pattern works best when:

- The grammar is simple (for complex grammars, tools like parser generators are better)
- Efficiency is not critical (the most efficient interpreters are usually not implemented by interpreting syntax trees directly)

In ObjectScript healthcare applications, the Interpreter pattern can be used to evaluate clinical rules, process laboratory value expressions, or implement decision support languages.

## Applicability

Use the Interpreter pattern when:

- You have a simple language to interpret
- The grammar of the language is simple and relatively stable
- Efficiency is not critical
- You want to be able to easily change and extend the grammar

## Structure

```
     Context
        |
    Expression (abstract)
        |
    +---+---+
    |       |
Terminal  NonTerminal
    |         |
    |    +----+----+
    |    |         |
Number  Add    Subtract
Variable
Boolean
```

## Participants

### Expression (Expression.cls)
- Declares an abstract Interpret operation that is common to all nodes in the abstract syntax tree

### TerminalExpression (NumberExpression, VariableExpression, BooleanExpression)
- Implements an Interpret operation for terminal symbols in the grammar
- An instance is required for every terminal symbol in a sentence

### NonTerminalExpression (AddExpression, SubtractExpression)
- Maintains instance variables of type Expression for each of the symbols it represents
- Implements an Interpret operation for nonterminal symbols in the grammar

### Context (Context.cls)
- Contains information that's global to the interpreter
- Stores variable bindings and function definitions

### Client
- Builds (or is given) an abstract syntax tree representing a particular sentence in the language
- Invokes the Interpret operation

## Collaborations

- The client builds the abstract syntax tree and initializes the context
- The client calls Interpret on the tree
- Each NonTerminalExpression node defines Interpret in terms of Interpret on each subexpression
- The Interpret operation at each TerminalExpression defines the base case in the recursion

## Implementation in ObjectScript

### Basic Expression Classes

```objectscript
/// Abstract Expression Base
Class Patterns.GoF.Behavioral.Expression Extends %RegisteredObject [ Abstract ]
{
    Method Interpret(pContext As Context) As %String [ Abstract ]
    {
        Quit ""
    }
    
    Method ToString() As %String [ Abstract ]
    {
        Quit ""
    }
}

/// Terminal Expression for Numbers
Class Patterns.GoF.Behavioral.NumberExpression Extends TerminalExpression
{
    Property Value As %String;
    
    Method Interpret(pContext As Context) As %String
    {
        Quit ..Value
    }
}

/// Terminal Expression for Variables
Class Patterns.GoF.Behavioral.VariableExpression Extends TerminalExpression
{
    Property VariableName As %String;
    
    Method Interpret(pContext As Context) As %String
    {
        Quit pContext.GetVariable(..VariableName)
    }
}

/// Non-Terminal Expression for Addition
Class Patterns.GoF.Behavioral.AddExpression Extends NonTerminalExpression
{
    Method Interpret(pContext As Context) As %String
    {
        Set tLeft = ..LeftOperand.Interpret(pContext)
        Set tRight = ..RightOperand.Interpret(pContext)
        Quit +tLeft + +tRight
    }
}
```

### Example Usage

```objectscript
// Create context with variables
Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
Do context.SetVariable("x", "10")
Do context.SetVariable("y", "20")

// Build expression tree: x + y + 5
Set varX = ##class(VariableExpression).%New("x")
Set varY = ##class(VariableExpression).%New("y")
Set num5 = ##class(NumberExpression).%New("5")

Set addXY = ##class(AddExpression).%New(varX, varY)
Set finalAdd = ##class(AddExpression).%New(addXY, num5)

// Interpret the expression
Set result = finalAdd.Interpret(context)  // Returns "35"
Write "Result: ", result, !
```

## Healthcare Clinical Rule Example

```objectscript
/// Clinical Rule Expression Example
/// Check if patient's glucose level indicates diabetes

// Create patient context
Set patientContext = ##class(Context).%New()
Do patientContext.SetVariable("glucose_mg_dl", "140")
Do patientContext.SetVariable("fasting", "true")

// Build rule: if fasting AND glucose > 126 then "diabetes risk"
Set glucoseVar = ##class(VariableExpression).%New("glucose_mg_dl")
Set threshold = ##class(NumberExpression).%New("126")
Set comparison = ##class(GreaterThanExpression).%New(glucoseVar, threshold)

Set fastingVar = ##class(VariableExpression).%New("fasting")
Set fastingTrue = ##class(BooleanExpression).%New("true")
Set fastingCheck = ##class(EqualsExpression).%New(fastingVar, fastingTrue)

Set andExpr = ##class(LogicalAndExpression).%New(fastingCheck, comparison)

// Evaluate clinical rule
Set ruleResult = andExpr.Interpret(patientContext)
If ruleResult {
    Write "Alert: Patient shows diabetes risk indicators", !
}
```

## Sample Code

### Building Complex Expressions

```objectscript
/// Complex expression with nested operations
/// Calculate: (a * 2) + (b - 5)

ClassMethod BuildComplexExpression() As Expression
{
    // Create variables
    Set a = ##class(VariableExpression).%New("a")
    Set b = ##class(VariableExpression).%New("b")
    
    // Create constants
    Set two = ##class(NumberExpression).%New("2")
    Set five = ##class(NumberExpression).%New("5")
    
    // Build sub-expressions
    Set multiply = ##class(MultiplyExpression).%New(a, two)
    Set subtract = ##class(SubtractExpression).%New(b, five)
    
    // Combine sub-expressions
    Set result = ##class(AddExpression).%New(multiply, subtract)
    
    Quit result
}
```

### Expression Parser (Simplified)

```objectscript
/// Simple recursive descent parser
Class Patterns.GoF.Behavioral.ExpressionParser
{
    Property Tokens As %ListOfDataTypes;
    Property CurrentIndex As %Integer;
    
    /// Parse an expression string
    Method Parse(pExpression As %String) As Expression
    {
        Do ..Tokenize(pExpression)
        Set ..CurrentIndex = 1
        Quit ..ParseExpression()
    }
    
    /// Parse expression with precedence
    Method ParseExpression() As Expression [ Private ]
    {
        Set tLeft = ..ParseTerm()
        
        While ..HasNext() && ..IsAddOrSubtract() {
            Set tOp = ..GetNext()
            Set tRight = ..ParseTerm()
            
            If tOp = "+" {
                Set tLeft = ##class(AddExpression).%New(tLeft, tRight)
            } ElseIf tOp = "-" {
                Set tLeft = ##class(SubtractExpression).%New(tLeft, tRight)
            }
        }
        
        Quit tLeft
    }
    
    /// Parse term (higher precedence)
    Method ParseTerm() As Expression [ Private ]
    {
        Set tToken = ..GetNext()
        
        If $ISVALIDNUM(tToken) {
            Quit ##class(NumberExpression).%New(tToken)
        } ElseIf tToken?1A.AN {
            Quit ##class(VariableExpression).%New(tToken)
        } ElseIf tToken = "(" {
            Set tExpr = ..ParseExpression()
            Do ..Expect(")")
            Quit tExpr
        }
        
        Throw ##class(%Exception.General).%New("Unexpected token: " _ tToken)
    }
}
```

## Known Uses

1. **Regular Expressions** - Pattern matching engines use interpreter patterns
2. **SQL Parsers** - Database query processors
3. **Configuration Languages** - DSLs for system configuration
4. **Mathematical Expression Evaluators** - Calculators and formula engines
5. **Clinical Rule Engines** - Healthcare decision support systems

## Related Patterns

- **Composite**: The abstract syntax tree is an instance of the Composite pattern
- **Flyweight**: Can share terminal symbols in the abstract syntax tree
- **Iterator**: Can be used to traverse the expression structure
- **Visitor**: Can be used to add new operations to expression classes without changing them

## Consequences

### Benefits

1. **Easy to change and extend the grammar** - New expression classes can be added easily
2. **Easy to implement** - Classes for nodes in the syntax tree are simple to write
3. **Complex expressions through composition** - Can build arbitrarily complex expressions
4. **Separation of concerns** - Grammar rules are encapsulated in classes

### Liabilities

1. **Complex grammars are hard to maintain** - Each rule requires a class
2. **Inefficient for complex grammars** - Indirect interpretation can be slow
3. **May lead to many small classes** - One class per grammar rule
4. **Not suitable for frequently changing grammars** - Requires code changes

## Implementation Considerations

### ObjectScript-Specific Considerations

1. **Use %DynamicObject for Context Variables**
   ```objectscript
   Property Variables As %DynamicObject;
   ```

2. **Leverage ObjectScript String Operations**
   ```objectscript
   // Tokenization using $PIECE
   Set token = $PIECE(expression, " ", index)
   ```

3. **Handle Type Coercion Carefully**
   ```objectscript
   // Numeric operations
   If $ISVALIDNUM(value) {
       Set result = +value
   }
   ```

4. **Use Macros for DSL Support**
   ```objectscript
   #define EXPR(%e) ##class(ExpressionParser).Parse(%e)
   ```

### Performance Optimization

1. **Cache Compiled Expressions**
   ```objectscript
   Property ExpressionCache [ MultiDimensional ];
   ```

2. **Implement Expression Simplification**
   - Constant folding
   - Dead code elimination
   - Common subexpression elimination

3. **Use Iterative Interpretation for Deep Trees**
   - Avoid stack overflow with deep recursion
   - Convert recursive interpretation to iterative

### Error Handling

1. **Parse Errors**
   - Include position information
   - Provide meaningful error messages
   - Support error recovery

2. **Runtime Errors**
   - Handle undefined variables
   - Type mismatches
   - Division by zero

## Summary

The Interpreter pattern provides a way to evaluate sentences in a simple language by representing the grammar as a class hierarchy and implementing an interpreter as operations on instances of these classes. In ObjectScript healthcare applications, it's particularly useful for implementing clinical rule engines and decision support systems.

While the pattern is elegant for simple languages, it becomes unwieldy for complex grammars. In those cases, consider using parser generators or other language processing tools. The pattern's real strength lies in its flexibility and ease of extension for domain-specific languages where the grammar is relatively simple and stable.
