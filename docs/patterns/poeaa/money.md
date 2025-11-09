# Money Pattern

## Intent

Represent monetary values with currency, ensuring precise decimal arithmetic and preventing common financial calculation errors.

## Motivation

Using floating-point numbers for money leads to rounding errors and precision loss. For example:

```objectscript
// BAD: Using regular numeric types
Set price = 10.10
Set quantity = 3
Set total = price * quantity  // Could be 30.299999... instead of 30.30
```

The Money pattern solves this by:
- Using precise decimal types (not floating-point)
- Always associating amount with currency
- Providing explicit rounding strategies
- Preventing operations on different currencies
- Implementing value object semantics (immutability)

## Structure

```
┌─────────────────┐
│     Money       │
├─────────────────┤
│ Amount: Numeric │
│ Currency: String│
├─────────────────┤
│ Add()           │
│ Subtract()      │
│ Multiply()      │
│ Divide()        │
│ Equals()        │
└─────────────────┘
```

## When to Use

✓ **Financial calculations** - Banking, billing, accounting
✓ **E-commerce** - Product prices, cart totals, taxes
✓ **Healthcare billing** - Procedure charges, insurance calculations
✓ **Payroll systems** - Salaries, deductions, taxes
✓ **Multi-currency applications** - International transactions
✓ **Regulatory compliance** - When precision is legally required

## When NOT to Use

✗ **Scientific calculations** - Use floating-point for scientific/engineering work
✗ **Performance-critical paths** - Money operations are slower than primitive types
✗ **Internal-only calculations** - Simple counters or non-monetary metrics
✗ **Single-use scripts** - Overkill for throwaway code

## Implementation

### Basic Usage

```objectscript
// Create money instances
Set price = ##class(Patterns.PoEAA.Base.Money).%New(100.50, "USD")
Set discount = ##class(Patterns.PoEAA.Base.Money).%New(10.25, "USD")

// Perform operations (returns new instances - immutable)
Set final = price.Subtract(discount)
Write final.ToString()  // "USD 90.25"

// Operations on different currencies return null
Set euros = ##class(Patterns.PoEAA.Base.Money).%New(100, "EUR")
Set invalid = price.Add(euros)  // Returns $$$NULLOREF
```

### Arithmetic Operations

#### Addition & Subtraction
```objectscript
Set money1 = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
Set money2 = ##class(Patterns.PoEAA.Base.Money).%New(50, "USD")

Set sum = money1.Add(money2)        // USD 150.00
Set diff = money1.Subtract(money2)  // USD 50.00
```

#### Multiplication
```objectscript
Set price = ##class(Patterns.PoEAA.Base.Money).%New(10.33, "USD")
Set total = price.Multiply(3)  // USD 30.99 (rounded to 2 decimal places)
```

#### Division with Rounding
```objectscript
Set amount = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")

// HALF_UP rounding (standard rounding - .5 rounds up)
Set result1 = amount.Divide(3, "HALF_UP")    // USD 33.33

// HALF_EVEN rounding (banker's rounding - .5 rounds to nearest even)
Set result2 = amount.Divide(3, "HALF_EVEN")  // USD 33.33
```

### Comparison Operations

```objectscript
Set money1 = ##class(Patterns.PoEAA.Base.Money).%New(50, "USD")
Set money2 = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")

If money1.LessThan(money2) {
    Write "money1 is less"
}

If money1.Equals(money2) {
    Write "Equal amounts"
}

If money2.GreaterThan(money1) {
    Write "money2 is greater"
}
```

## Decimal Precision Requirements

### Storage Precision

Money amounts are stored using `%Numeric(SCALE = 2)` which provides:
- **2 decimal places** for most currencies (USD, EUR, GBP)
- **Exact decimal representation** (not binary floating-point)
- **No precision loss** in storage

For currencies requiring different precision (e.g., Japanese Yen with 0 decimals, or Bitcoin with 8 decimals), extend the Money class and override the SCALE parameter.

### Calculation Precision

All arithmetic operations:
1. Perform calculation with full precision
2. Apply rounding strategy
3. Store result with 2 decimal places
4. Return new Money instance (immutability)

## Rounding Strategies

### HALF_UP (Standard Rounding)
- **When to use**: Most business calculations, user-facing amounts
- **Behavior**: .5 always rounds up
- **Example**: 33.335 → 33.34, 33.325 → 33.33

```objectscript
Set result = money.Divide(3, "HALF_UP")
```

### HALF_EVEN (Banker's Rounding)
- **When to use**: Statistical calculations, reducing rounding bias
- **Behavior**: .5 rounds to nearest even number
- **Example**: 33.335 → 33.34 (even), 33.325 → 33.32 (even)

```objectscript
Set result = money.Divide(3, "HALF_EVEN")
```

## Currency Handling

### Currency Validation

Money enforces currency compatibility:

```objectscript
Set usd = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
Set eur = ##class(Patterns.PoEAA.Base.Money).%New(100, "EUR")

Set invalid = usd.Add(eur)  // Returns $$$NULLOREF - cannot mix currencies
```

### Multi-Currency Support

For international applications:

```objectscript
// Healthcare example with international patient
Set chargeUSD = ##class(Patterns.Examples.Clinical.BillingAmount).%New(1000, "USD")
Set chargeEUR = ##class(Patterns.Examples.Clinical.BillingAmount).%New(850, "EUR")

// Handle each currency separately
Set totalUSD = ##class(Patterns.Examples.Clinical.BillingAmount).CalculateTotal(usdList)
Set totalEUR = ##class(Patterns.Examples.Clinical.BillingAmount).CalculateTotal(eurList)
```

## Healthcare Billing Example

### Basic Billing Amount

```objectscript
// Create a billing amount
Set charge = ##class(Patterns.Examples.Clinical.BillingAmount).%New(1000, "USD")

// Apply negotiated discount (10%)
Set discounted = charge.ApplyDiscount(10)  // USD 900.00

// Apply sales tax (8%)
Set withTax = discounted.ApplyTax(8)  // USD 972.00
```

### Insurance Calculations

```objectscript
Set procedureCost = ##class(Patterns.Examples.Clinical.BillingAmount).%New(5000, "USD")

// Calculate insurance portion (80% coverage)
Set insurancePays = procedureCost.CalculateInsurancePortion(80)  // USD 4000.00

// Calculate patient responsibility
Set patientPays = procedureCost.CalculatePatientPortion(80)  // USD 1000.00
```

### Itemized Billing

```objectscript
// Create procedure charges
Set proc1 = ##class(Patterns.Examples.Clinical.ProcedureCharge).%New(
    "99213", "Office Visit", 150, "USD")
Set proc2 = ##class(Patterns.Examples.Clinical.ProcedureCharge).%New(
    "85025", "CBC Lab Test", 45, "USD")
Set proc3 = ##class(Patterns.Examples.Clinical.ProcedureCharge).%New(
    "73610", "X-Ray Ankle", 120, "USD")

// Add to billing items list
Set items = ##class(%ListOfObjects).%New()
Do items.Insert(proc1.Charge)
Do items.Insert(proc2.Charge)
Do items.Insert(proc3.Charge)

// Calculate total
Set total = ##class(Patterns.Examples.Clinical.BillingAmount).CalculateTotal(items)
Write total.ToString()  // "USD 315.00"
```

## Comparison with Simple Numeric Types

| Aspect | Simple Numeric | Money Pattern |
|--------|---------------|---------------|
| **Precision** | Binary floating-point (imprecise) | Exact decimal (precise) |
| **Currency** | No currency association | Always includes currency |
| **Mixing Currencies** | Allowed (incorrect!) | Prevented by design |
| **Rounding** | Implicit, inconsistent | Explicit strategies |
| **Immutability** | Mutable | Immutable value object |
| **Type Safety** | Weak | Strong (cannot add USD + EUR) |
| **Performance** | Fast | Slower (but correct!) |

### Example of Floating-Point Problem

```objectscript
// BAD: Using regular numbers
Set price = 0.1
Set quantity = 3
Set total = price * quantity
// Result: 0.30000000000000004 (!!!)

// GOOD: Using Money pattern
Set price = ##class(Patterns.PoEAA.Base.Money).%New(0.10, "USD")
Set total = price.Multiply(3)
// Result: USD 0.30 (exact)
```

## Common Money Calculation Pitfalls

### ❌ Pitfall 1: Using Floating-Point Types
```objectscript
// WRONG
Set amount = 10.1 * 3  // 30.299999...
```

### ✓ Solution: Use Money Pattern
```objectscript
// CORRECT
Set money = ##class(Patterns.PoEAA.Base.Money).%New(10.10, "USD")
Set result = money.Multiply(3)  // USD 30.30
```

### ❌ Pitfall 2: Mixing Currencies
```objectscript
// WRONG
Set usdAmount = 100
Set eurAmount = 85
Set wrongTotal = usdAmount + eurAmount  // 185 what?!
```

### ✓ Solution: Validate Currency
```objectscript
// CORRECT
Set usd = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
Set eur = ##class(Patterns.PoEAA.Base.Money).%New(85, "EUR")
Set result = usd.Add(eur)  // Returns null - cannot mix!
```

### ❌ Pitfall 3: Inconsistent Rounding
```objectscript
// WRONG
Set result = 100 / 3  // 33.333333... rounds unpredictably
```

### ✓ Solution: Explicit Rounding
```objectscript
// CORRECT
Set money = ##class(Patterns.PoEAA.Base.Money).%New(100, "USD")
Set result = money.Divide(3, "HALF_UP")  // USD 33.33 (explicit strategy)
```

### ❌ Pitfall 4: Modifying Money Objects
```objectscript
// WRONG (if Money were mutable)
Do money.SetAmount(money.Amount + 10)  // Mutating is dangerous!
```

### ✓ Solution: Immutability
```objectscript
// CORRECT
Set increase = ##class(Patterns.PoEAA.Base.Money).%New(10, "USD")
Set newMoney = money.Add(increase)  // Returns new instance
```

## Known Uses

- **InterSystems IRIS Healthcare** - Patient billing, insurance claims
- **Banking Systems** - Account balances, transaction amounts
- **E-commerce Platforms** - Product pricing, shopping carts
- **Payroll Systems** - Salary calculations, tax withholding
- **Accounting Software** - General ledger, invoicing

## Related Patterns

- **Value Object** - Money is an immutable value object
- **Quantity** - Similar pattern for measurements (length, weight)
- **Unit of Work** - Often used together for transactional money operations
- **Repository** - Money objects stored/retrieved via repositories

## Benefits

✓ **Precision** - Exact decimal arithmetic, no rounding errors
✓ **Safety** - Cannot mix currencies accidentally
✓ **Clarity** - Amount always paired with currency
✓ **Immutability** - Thread-safe, prevents bugs
✓ **Explicit Rounding** - Predictable, auditable calculations
✓ **Type Safety** - Compile-time prevention of money misuse

## Drawbacks

✗ **Performance** - Slower than primitive numeric types
✗ **Verbosity** - More code than simple numeric operations
✗ **Learning Curve** - Developers must understand the pattern
✗ **Memory** - More memory than a simple number

## Best Practices

1. **Always use Money for financial amounts** - Never use raw numerics for money
2. **Validate currency compatibility** - Check before arithmetic operations
3. **Choose appropriate rounding** - HALF_UP for business, HALF_EVEN for statistics
4. **Document precision requirements** - Specify SCALE for different currencies
5. **Test edge cases** - Division by zero, negative amounts, very large/small values
6. **Use immutability** - Never modify Money objects, create new ones
7. **Format for display** - Use ToString() for user-facing amounts

## References

- Fowler, Martin. *Patterns of Enterprise Application Architecture*. Addison-Wesley, 2002. (Money pattern, p. 488)
- Bloch, Joshua. *Effective Java*, 3rd Edition. Item 60: Avoid float and double if exact answers are required
- ISO 4217 - Currency code standard

## See Also

- [Value Object Pattern](value-object.md)
- [Repository Pattern](../objectrelational/repository.md)
- [Unit of Work Pattern](../datasource/unit-of-work.md)
