/// Unit tests for Gang of Four Interpreter Pattern
/// 
/// Tests the expression tree implementation including:
/// - Terminal expressions (Number, Variable, Boolean)
/// - Non-terminal expressions (Add, Subtract)
/// - Context management
/// - Expression validation
/// 
/// @since 1.0.0
Class Patterns.Test.Unit.GoF.Behavioral.InterpreterTest Extends %UnitTest.TestCase
{

/// Test basic number expression interpretation
Method TestNumberExpression()
{
    Set ^ClineDebug = ""  // Clear debug global
    Set ^ClineDebug = ^ClineDebug _ "TestNumberExpression started; "
    
    // Create context and number expression
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    Set numExpr = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("42")
    
    // Test interpretation
    Set result = numExpr.Interpret(context)
    Do $$$AssertEquals(result, "42", "Number expression should return its value")
    
    // Test string representation
    Set strRep = numExpr.ToString()
    Do $$$AssertEquals(strRep, "42", "ToString should return the number")
    
    // Test numeric value method
    Set numValue = numExpr.GetNumericValue()
    Do $$$AssertEquals(numValue, 42, "GetNumericValue should return numeric 42")
    
    // Test integer check
    Do $$$AssertTrue(numExpr.IsInteger(), "42 should be recognized as integer")
    Do $$$AssertTrue('numExpr.IsDecimal(), "42 should not be decimal")
    
    Set ^ClineDebug = ^ClineDebug _ "TestNumberExpression completed; "
    Quit $$$OK
}

/// Test decimal number expression
Method TestDecimalNumber()
{
    Set ^ClineDebug = ^ClineDebug _ "TestDecimalNumber started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    Set numExpr = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("3.14")
    
    Set result = numExpr.Interpret(context)
    Do $$$AssertEquals(result, "3.14", "Decimal number should be interpreted correctly")
    
    Do $$$AssertTrue(numExpr.IsDecimal(), "3.14 should be recognized as decimal")
    Do $$$AssertTrue('numExpr.IsInteger(), "3.14 should not be integer")
    
    Set ^ClineDebug = ^ClineDebug _ "TestDecimalNumber completed; "
    Quit $$$OK
}

/// Test variable expression with context
Method TestVariableExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestVariableExpression started; "
    
    // Create context and set variables
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    Do context.SetVariable("x", "100")
    Do context.SetVariable("y", "200")
    
    // Test variable lookup
    Set varExpr = ##class(Patterns.GoF.Behavioral.VariableExpression).%New("x")
    Set result = varExpr.Interpret(context)
    Do $$$AssertEquals(result, "100", "Variable x should resolve to 100")
    
    // Test string representation
    Set strRep = varExpr.ToString()
    Do $$$AssertEquals(strRep, "$x", "Variable should be represented as $x")
    
    // Test non-existent variable
    Set varExpr2 = ##class(Patterns.GoF.Behavioral.VariableExpression).%New("z")
    Set result2 = varExpr2.Interpret(context)
    Do $$$AssertEquals(result2, "", "Non-existent variable should return empty")
    
    Set ^ClineDebug = ^ClineDebug _ "TestVariableExpression completed; "
    Quit $$$OK
}

/// Test boolean expression
Method TestBooleanExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestBooleanExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Test true boolean
    Set boolExpr = ##class(Patterns.GoF.Behavioral.BooleanExpression).%New("true")
    Set result = boolExpr.Interpret(context)
    Do $$$AssertEquals(result, "true", "Boolean true should interpret as 'true'")
    Do $$$AssertTrue(boolExpr.IsTrue(), "IsTrue should return 1")
    Do $$$AssertTrue('boolExpr.IsFalse(), "IsFalse should return 0")
    
    // Test false boolean
    Set boolExpr2 = ##class(Patterns.GoF.Behavioral.BooleanExpression).%New("false")
    Set result2 = boolExpr2.Interpret(context)
    Do $$$AssertEquals(result2, "false", "Boolean false should interpret as 'false'")
    Do $$$AssertTrue(boolExpr2.IsFalse(), "IsFalse should return 1")
    
    // Test numeric boolean
    Set boolExpr3 = ##class(Patterns.GoF.Behavioral.BooleanExpression).%New("1")
    Set result3 = boolExpr3.Interpret(context)
    Do $$$AssertEquals(result3, "true", "Boolean 1 should interpret as 'true'")
    
    Set ^ClineDebug = ^ClineDebug _ "TestBooleanExpression completed; "
    Quit $$$OK
}

/// Test addition expression
Method TestAddExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestAddExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Create operands
    Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
    Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("20")
    
    // Create add expression
    Set addExpr = ##class(Patterns.GoF.Behavioral.AddExpression).%New(left, right)
    
    // Test interpretation
    Set result = addExpr.Interpret(context)
    Do $$$AssertEquals(result, "30", "10 + 20 should equal 30")
    
    // Test string representation
    Set strRep = addExpr.ToString()
    Do $$$AssertEquals(strRep, "(10 + 20)", "String representation should show operation")
    
    Set ^ClineDebug = ^ClineDebug _ "TestAddExpression completed; "
    Quit $$$OK
}

/// Test subtraction expression
Method TestSubtractExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestSubtractExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Create operands
    Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("50")
    Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("20")
    
    // Create subtract expression
    Set subtractExpr = ##class(Patterns.GoF.Behavioral.SubtractExpression).%New(left, right)
    
    // Test interpretation
    Set result = subtractExpr.Interpret(context)
    Do $$$AssertEquals(result, "30", "50 - 20 should equal 30")
    
    // Test string representation
    Set strRep = subtractExpr.ToString()
    Do $$$AssertEquals(strRep, "(50 - 20)", "String representation should show operation")
    
    Set ^ClineDebug = ^ClineDebug _ "TestSubtractExpression completed; "
    Quit $$$OK
}

/// Test complex expression with variables
Method TestComplexExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestComplexExpression started; "
    
    // Create context with variables
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    Do context.SetVariable("a", "15")
    Do context.SetVariable("b", "25")
    
    // Create expression: (a + 10) - b
    Set varA = ##class(Patterns.GoF.Behavioral.VariableExpression).%New("a")
    Set num10 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
    Set addExpr = ##class(Patterns.GoF.Behavioral.AddExpression).%New(varA, num10)
    
    Set varB = ##class(Patterns.GoF.Behavioral.VariableExpression).%New("b")
    Set subtractExpr = ##class(Patterns.GoF.Behavioral.SubtractExpression).%New(addExpr, varB)
    
    // Test interpretation: (15 + 10) - 25 = 0
    Set result = subtractExpr.Interpret(context)
    Do $$$AssertEquals(result, "0", "(a + 10) - b should equal 0 when a=15, b=25")
    
    Set ^ClineDebug = ^ClineDebug _ "TestComplexExpression completed; "
    Quit $$$OK
}

/// Test context variable management
Method TestContextVariables()
{
    Set ^ClineDebug = ^ClineDebug _ "TestContextVariables started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Test setting and getting variables
    Do context.SetVariable("test", "value1")
    Set value = context.GetVariable("test")
    Do $$$AssertEquals(value, "value1", "Variable should be stored correctly")
    
    // Test variable existence
    Do $$$AssertTrue(context.HasVariable("test"), "HasVariable should return true")
    Do $$$AssertTrue('context.HasVariable("nonexistent"), "HasVariable should return false for non-existent")
    
    // Test removing variable
    Do context.RemoveVariable("test")
    Do $$$AssertTrue('context.HasVariable("test"), "Variable should be removed")
    
    // Test clearing all variables
    Do context.SetVariable("var1", "val1")
    Do context.SetVariable("var2", "val2")
    Do context.ClearVariables()
    Do $$$AssertTrue('context.HasVariable("var1"), "All variables should be cleared")
    Do $$$AssertTrue('context.HasVariable("var2"), "All variables should be cleared")
    
    Set ^ClineDebug = ^ClineDebug _ "TestContextVariables completed; "
    Quit $$$OK
}

/// Test context debug mode
Method TestContextDebugMode()
{
    Set ^ClineDebug = ^ClineDebug _ "TestContextDebugMode started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    Do context.EnableDebug()
    
    // Perform some operations with debug enabled
    Do context.SetVariable("debug_test", "123")
    
    Set numExpr = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("42")
    Set result = numExpr.Interpret(context)
    
    // Get debug output
    Set debugOutput = context.GetDebugOutput()
    Do $$$AssertTrue(debugOutput '= "", "Debug output should not be empty")
    
    // Disable debug mode
    Do context.DisableDebug()
    Do $$$AssertEquals(context.DebugMode, 0, "Debug mode should be disabled")
    
    Set ^ClineDebug = ^ClineDebug _ "TestContextDebugMode completed; "
    Quit $$$OK
}

/// Test expression validation
Method TestExpressionValidation()
{
    Set ^ClineDebug = ^ClineDebug _ "TestExpressionValidation started; "
    
    // Test valid number expression
    Set numExpr = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("42")
    Set tSC = numExpr.Validate()
    Do $$$AssertStatusOK(tSC, "Valid number expression should pass validation")
    
    // Test valid variable expression
    Set varExpr = ##class(Patterns.GoF.Behavioral.VariableExpression).%New("validName")
    Set tSC = varExpr.Validate()
    Do $$$AssertStatusOK(tSC, "Valid variable expression should pass validation")
    
    // Test valid boolean expression
    Set boolExpr = ##class(Patterns.GoF.Behavioral.BooleanExpression).%New("true")
    Set tSC = boolExpr.Validate()
    Do $$$AssertStatusOK(tSC, "Valid boolean expression should pass validation")
    
    // Test valid add expression
    Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
    Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("20")
    Set addExpr = ##class(Patterns.GoF.Behavioral.AddExpression).%New(left, right)
    Set tSC = addExpr.Validate()
    Do $$$AssertStatusOK(tSC, "Valid add expression should pass validation")
    
    Set ^ClineDebug = ^ClineDebug _ "TestExpressionValidation completed; "
    Quit $$$OK
}

/// Test nested expression evaluation
Method TestNestedExpressions()
{
    Set ^ClineDebug = ^ClineDebug _ "TestNestedExpressions started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Create nested expression: ((10 + 20) + (30 - 15))
    Set num1 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
    Set num2 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("20")
    Set add1 = ##class(Patterns.GoF.Behavioral.AddExpression).%New(num1, num2)
    
    Set num3 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("30")
    Set num4 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("15")
    Set subtract1 = ##class(Patterns.GoF.Behavioral.SubtractExpression).%New(num3, num4)
    
    Set finalAdd = ##class(Patterns.GoF.Behavioral.AddExpression).%New(add1, subtract1)
    
    // Test interpretation: (10 + 20) + (30 - 15) = 30 + 15 = 45
    Set result = finalAdd.Interpret(context)
    Do $$$AssertEquals(result, "45", "Nested expression should evaluate correctly")
    
    Set ^ClineDebug = ^ClineDebug _ "TestNestedExpressions completed; "
    Quit $$$OK
}

/// Test expression tree depth
Method TestExpressionDepth()
{
    Set ^ClineDebug = ^ClineDebug _ "TestExpressionDepth started; "
    
    // Create a simple expression tree
    Set num1 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("5")
    Set num2 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
    Set addExpr = ##class(Patterns.GoF.Behavioral.AddExpression).%New(num1, num2)
    
    // Test depth calculation
    Set depth = addExpr.GetDepth()
    Do $$$AssertEquals(depth, 0, "Root expression should have depth 0")
    
    Set ^ClineDebug = ^ClineDebug _ "TestExpressionDepth completed; "
    Quit $$$OK
}

/// Test context cloning
Method TestContextClone()
{
    Set ^ClineDebug = ^ClineDebug _ "TestContextClone started; "
    
    // Create original context
    Set context1 = ##class(Patterns.GoF.Behavioral.Context).%New()
    Do context1.SetVariable("x", "100")
    Do context1.SetVariable("y", "200")
    
    // Clone context
    Set context2 = context1.Clone()
    
    // Verify cloned values
    Set xVal = context2.GetVariable("x")
    Do $$$AssertEquals(xVal, "100", "Cloned context should have same x value")
    
    Set yVal = context2.GetVariable("y")
    Do $$$AssertEquals(yVal, "200", "Cloned context should have same y value")
    
    // Modify clone and verify original unchanged
    Do context2.SetVariable("x", "300")
    Set origX = context1.GetVariable("x")
    Do $$$AssertEquals(origX, "100", "Original context should be unchanged")
    
    Set ^ClineDebug = ^ClineDebug _ "TestContextClone completed; "
    Quit $$$OK
}

/// Test multiplication expression
Method TestMultiplyExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestMultiplyExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Create operands
    Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("7")
    Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("8")
    
    // Create multiply expression
    Set multiplyExpr = ##class(Patterns.GoF.Behavioral.MultiplyExpression).%New(left, right)
    
    // Test interpretation
    Set result = multiplyExpr.Interpret(context)
    Do $$$AssertEquals(result, "56", "7 * 8 should equal 56")
    
    // Test string representation
    Set strRep = multiplyExpr.ToString()
    Do $$$AssertEquals(strRep, "(7 * 8)", "String representation should show operation")
    
    // Test with decimals
    Set left2 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("2.5")
    Set right2 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("4")
    Set multiplyExpr2 = ##class(Patterns.GoF.Behavioral.MultiplyExpression).%New(left2, right2)
    Set result2 = multiplyExpr2.Interpret(context)
    Do $$$AssertEquals(result2, "10", "2.5 * 4 should equal 10")
    
    Set ^ClineDebug = ^ClineDebug _ "TestMultiplyExpression completed; "
    Quit $$$OK
}

/// Test division expression
Method TestDivideExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestDivideExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Create operands for normal division
    Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("20")
    Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("4")
    
    // Create divide expression
    Set divideExpr = ##class(Patterns.GoF.Behavioral.DivideExpression).%New(left, right)
    
    // Test interpretation
    Set result = divideExpr.Interpret(context)
    Do $$$AssertEquals(result, "5", "20 / 4 should equal 5")
    
    // Test string representation
    Set strRep = divideExpr.ToString()
    Do $$$AssertEquals(strRep, "(20 / 4)", "String representation should show operation")
    
    // Test with decimals
    Set left2 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
    Set right2 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("4")
    Set divideExpr2 = ##class(Patterns.GoF.Behavioral.DivideExpression).%New(left2, right2)
    Set result2 = divideExpr2.Interpret(context)
    Do $$$AssertEquals(result2, "2.5", "10 / 4 should equal 2.5")
    
    // Test division by zero handling - returns NaN
    Set zero = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("0")
    Set divByZero = ##class(Patterns.GoF.Behavioral.DivideExpression).%New(left, zero)
    Set resultZero = divByZero.Interpret(context)
    Do $$$AssertEquals(resultZero, "NaN", "Division by zero should return NaN")
    
    Set ^ClineDebug = ^ClineDebug _ "TestDivideExpression completed; "
    Quit $$$OK
}

/// Test comparison expressions
Method TestComparisonExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestComparisonExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Create operands
    Set left = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
    Set right = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("20")
    
    // Test less than
    Set ltExpr = ##class(Patterns.GoF.Behavioral.ComparisonExpression).CreateWithOperator(left, "<", right)
    Set result = ltExpr.Interpret(context)
    Do $$$AssertEquals(result, "true", "10 < 20 should be true")
    
    // Test greater than
    Set gtExpr = ##class(Patterns.GoF.Behavioral.ComparisonExpression).CreateWithOperator(left, ">", right)
    Set result = gtExpr.Interpret(context)
    Do $$$AssertEquals(result, "false", "10 > 20 should be false")
    
    // Test equals
    Set eq1 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("15")
    Set eq2 = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("15")
    Set eqExpr = ##class(Patterns.GoF.Behavioral.ComparisonExpression).CreateWithOperator(eq1, "=", eq2)
    Set result = eqExpr.Interpret(context)
    Do $$$AssertEquals(result, "true", "15 = 15 should be true")
    
    // Test not equals
    Set neExpr = ##class(Patterns.GoF.Behavioral.ComparisonExpression).CreateWithOperator(left, "!=", right)
    Set result = neExpr.Interpret(context)
    Do $$$AssertEquals(result, "true", "10 != 20 should be true")
    
    // Test less than or equal
    Set leExpr = ##class(Patterns.GoF.Behavioral.ComparisonExpression).CreateWithOperator(left, "<=", right)
    Set result = leExpr.Interpret(context)
    Do $$$AssertEquals(result, "true", "10 <= 20 should be true")
    
    // Test greater than or equal
    Set geExpr = ##class(Patterns.GoF.Behavioral.ComparisonExpression).CreateWithOperator(eq1, ">=", eq2)
    Set result = geExpr.Interpret(context)
    Do $$$AssertEquals(result, "true", "15 >= 15 should be true")
    
    Set ^ClineDebug = ^ClineDebug _ "TestComparisonExpression completed; "
    Quit $$$OK
}

/// Test logical expressions (AND, OR, NOT)
Method TestLogicalExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestLogicalExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Create boolean operands
    Set trueExpr = ##class(Patterns.GoF.Behavioral.BooleanExpression).%New("true")
    Set falseExpr = ##class(Patterns.GoF.Behavioral.BooleanExpression).%New("false")
    
    // Test AND using And() class method
    Set andExpr1 = ##class(Patterns.GoF.Behavioral.LogicalExpression).And(trueExpr, trueExpr)
    Set result = andExpr1.Interpret(context)
    Do $$$AssertEquals(result, "true", "true AND true should be true")
    
    Set andExpr2 = ##class(Patterns.GoF.Behavioral.LogicalExpression).And(trueExpr, falseExpr)
    Set result = andExpr2.Interpret(context)
    Do $$$AssertEquals(result, "false", "true AND false should be false")
    
    // Test OR using Or() class method
    Set orExpr1 = ##class(Patterns.GoF.Behavioral.LogicalExpression).Or(trueExpr, falseExpr)
    Set result = orExpr1.Interpret(context)
    Do $$$AssertEquals(result, "true", "true OR false should be true")
    
    Set orExpr2 = ##class(Patterns.GoF.Behavioral.LogicalExpression).Or(falseExpr, falseExpr)
    Set result = orExpr2.Interpret(context)
    Do $$$AssertEquals(result, "false", "false OR false should be false")
    
    // Test NOT (unary operator) using Not() class method
    Set notExpr1 = ##class(Patterns.GoF.Behavioral.LogicalExpression).Not(trueExpr)
    Set result = notExpr1.Interpret(context)
    Do $$$AssertEquals(result, "false", "NOT true should be false")
    
    Set notExpr2 = ##class(Patterns.GoF.Behavioral.LogicalExpression).Not(falseExpr)
    Set result = notExpr2.Interpret(context)
    Do $$$AssertEquals(result, "true", "NOT false should be true")
    
    Set ^ClineDebug = ^ClineDebug _ "TestLogicalExpression completed; "
    Quit $$$OK
}

/// Test conditional expression (IF-THEN-ELSE)
Method TestConditionalExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestConditionalExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    Do context.SetVariable("score", "85")
    
    // Create condition: score > 80
    Set scoreVar = ##class(Patterns.GoF.Behavioral.VariableExpression).%New("score")
    Set threshold = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("80")
    Set condition = ##class(Patterns.GoF.Behavioral.ComparisonExpression).CreateWithOperator(scoreVar, ">", threshold)
    
    // Create then and else branches
    Set thenExpr = ##class(Patterns.GoF.Behavioral.StringExpression).%New("Pass")
    Set elseExpr = ##class(Patterns.GoF.Behavioral.StringExpression).%New("Fail")
    
    // Create conditional expression
    Set condExpr = ##class(Patterns.GoF.Behavioral.ConditionalExpression).%New(condition, thenExpr, elseExpr)
    
    // Test when condition is true (score = 85 > 80)
    Set result = condExpr.Interpret(context)
    Do $$$AssertEquals(result, "Pass", "IF score > 80 THEN Pass ELSE Fail should return Pass when score=85")
    
    // Change score to fail condition
    Do context.SetVariable("score", "75")
    Set result2 = condExpr.Interpret(context)
    Do $$$AssertEquals(result2, "Fail", "IF score > 80 THEN Pass ELSE Fail should return Fail when score=75")
    
    // Test string representation
    Set strRep = condExpr.ToString()
    Do $$$AssertTrue(strRep [ "IF", "String representation should contain IF keyword")
    
    Set ^ClineDebug = ^ClineDebug _ "TestConditionalExpression completed; "
    Quit $$$OK
}

/// Test string expression
Method TestStringExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestStringExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Test string literal
    Set strExpr = ##class(Patterns.GoF.Behavioral.StringExpression).%New("Hello World")
    Set result = strExpr.Interpret(context)
    Do $$$AssertEquals(result, "Hello World", "String expression should return its value")
    
    // Test string representation
    Set strRep = strExpr.ToString()
    Do $$$AssertEquals(strRep, """Hello World""", "String should be quoted in representation")
    
    // Test Create factory method
    Set str2 = ##class(Patterns.GoF.Behavioral.StringExpression).Create("Test String")
    Set result2 = str2.Interpret(context)
    Do $$$AssertEquals(result2, "Test String", "Factory-created string should work")
    
    // Test empty string
    Set emptyExpr = ##class(Patterns.GoF.Behavioral.StringExpression).%New("")
    Set result = emptyExpr.Interpret(context)
    Do $$$AssertEquals(result, "", "Empty string should return empty")
    
    Set ^ClineDebug = ^ClineDebug _ "TestStringExpression completed; "
    Quit $$$OK
}

/// Test constant expression
Method TestConstantExpression()
{
    Set ^ClineDebug = ^ClineDebug _ "TestConstantExpression started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    
    // Context already has PI initialized - let's use it
    // And add a custom constant
    Do context.SetConstant("MAX_VALUE", "100")
    
    // Test constant retrieval - PI should already be set
    Set piExpr = ##class(Patterns.GoF.Behavioral.ConstantExpression).%New("PI")
    Set result = piExpr.Interpret(context)
    Do $$$AssertEquals(+result, 3.14159265359, "PI constant should return 3.14159...")
    
    Set maxExpr = ##class(Patterns.GoF.Behavioral.ConstantExpression).%New("MAX_VALUE")
    Set result = maxExpr.Interpret(context)
    Do $$$AssertEquals(result, "100", "MAX_VALUE constant should return 100")
    
    // Test undefined constant
    Set undefinedExpr = ##class(Patterns.GoF.Behavioral.ConstantExpression).%New("UNDEFINED")
    Set result = undefinedExpr.Interpret(context)
    Do $$$AssertEquals(result, "", "Undefined constant should return empty string")
    
    // Test constant in expression with default PI
    Set piConst = ##class(Patterns.GoF.Behavioral.ConstantExpression).%New("PI")
    Set radius = ##class(Patterns.GoF.Behavioral.NumberExpression).%New("10")
    Set multiplyExpr = ##class(Patterns.GoF.Behavioral.MultiplyExpression).%New(piConst, radius)
    Set result = multiplyExpr.Interpret(context)
    Set expected = 3.14159265359 * 10
    // Round to 4 decimal places for comparison
    Set roundedResult = $FNUMBER(+result, "", 4)
    Set roundedExpected = $FNUMBER(expected, "", 4)
    Do $$$AssertEquals(roundedResult, roundedExpected, "PI * 10 should equal approximately 31.4159")
    
    Set ^ClineDebug = ^ClineDebug _ "TestConstantExpression completed; "
    Quit $$$OK
}

/// Test DSL Builder functionality
Method TestDSLBuilder()
{
    Set ^ClineDebug = ^ClineDebug _ "TestDSLBuilder started; "
    
    Set context = ##class(Patterns.GoF.Behavioral.Context).%New()
    Do context.SetVariable("x", "5")
    
    // Build expression: 10 + 20 * 3
    Set builder = ##class(Patterns.GoF.Behavioral.DSLBuilder).%New()
    Set expr = builder.Number(10).Add().Number(20).Multiply().Number(3).Build()
    Set result = expr.Interpret(context)
    Do $$$AssertEquals(result, "70", "10 + 20 * 3 should equal 70 with correct precedence")
    
    // Build expression with parentheses: (10 + 20) * 3
    Set builder2 = ##class(Patterns.GoF.Behavioral.DSLBuilder).%New()
    Set expr2 = builder2.OpenParen().Number(10).Add().Number(20).CloseParen().Multiply().Number(3).Build()
    Set result2 = expr2.Interpret(context)
    Do $$$AssertEquals(result2, "90", "(10 + 20) * 3 should equal 90")
    
    // Build expression with variables: x * 2 + 10
    Set builder3 = ##class(Patterns.GoF.Behavioral.DSLBuilder).%New()
    Set expr3 = builder3.Variable("x").Multiply().Number(2).Add().Number(10).Build()
    Set result3 = expr3.Interpret(context)
    Do $$$AssertEquals(result3, "20", "x * 2 + 10 should equal 20 when x=5")
    
    Set ^ClineDebug = ^ClineDebug _ "TestDSLBuilder completed; "
    Quit $$$OK
}

/// Test parser error handling
Method TestParserErrorHandling()
{
    Set ^ClineDebug = ^ClineDebug _ "TestParserErrorHandling started; "
    
    Set parser = ##class(Patterns.GoF.Behavioral.ExpressionParser).%New()
    
    // Test invalid expression (unmatched parenthesis)
    Set expr1 = parser.Parse("(10 + 20")
    Do $$$AssertEquals(expr1, "", "Unmatched parenthesis should return empty")
    
    // Test empty expression
    Set expr2 = parser.Parse("")
    Do $$$AssertTrue($ISOBJECT(expr2) || (expr2 = ""), "Empty expression should be handled gracefully")
    
    // Test invalid operator sequence
    Set expr3 = parser.Parse("10 + + 20")
    Do $$$AssertTrue($ISOBJECT(expr3) || (expr3 = ""), "Invalid operator sequence should be handled")
    
    // Test valid complex expression
    Set expr4 = parser.Parse("(10 + 20) * (30 - 15)")
    Do $$$AssertTrue($ISOBJECT(expr4), "Valid complex expression should parse successfully")
    
    Set ^ClineDebug = ^ClineDebug _ "TestParserErrorHandling completed; "
    Quit $$$OK
}

/// Clean up after tests
Method OnAfterOneTest() As %Status
{
    // Clear debug global
    Set ^ClineDebug = ""
    Quit $$$OK
}

}
