/// Gang of Four and Patterns of Enterprise Application Architecture
/// Value Object Pattern - Base Implementation
/// 
/// Intent:
/// A small simple object, like money or date range, whose equality isn't based on identity.
/// Value objects are immutable and should be equal based on their property values, not their identity.
/// 
/// Motivation:
/// In many cases, you don't care about which object instance you have; you only care about the values
/// it contains. For example, two money objects representing $50 should be considered equal even if
/// they are different object instances. Value objects simplify equality checking and enable safe sharing.
/// 
/// Applicability:
/// Use Value Object when:
/// - Objects are distinguished by their values, not identity
/// - Objects should be immutable after creation
/// - Objects need value-based equality semantics
/// - You want to avoid aliasing bugs from shared mutable objects
/// - Objects represent measurements, quantities, or descriptive aspects
/// 
/// Structure:
/// - Immutable properties (read-only after construction)
/// - Value-based Equals() method
/// - GetHashCode() for use in hash-based collections
/// - ToString() for string representation
/// - Copy() or With* methods for creating modified instances
/// 
/// Consequences:
/// + Thread-safe due to immutability
/// + No aliasing bugs
/// + Safe to use as hash keys
/// + Can be freely shared
/// - Cannot be modified after creation
/// - Creating new instance for each "change" can impact performance
/// 
/// Implementation Notes for ObjectScript:
/// - Use Private keyword on property setters to enforce read-only
/// - Set properties using i%PropertyName in constructor
/// - Implement Equals() to compare all property values
/// - Implement GetHashCode() for collection support
/// 
/// Example:
/// <example>
/// Set temp = 98.6
/// Set hr = 72
/// Set vitals = ##class(VitalSigns).%New(temp, hr)
/// Write vitals.Temperature  // 98.6
/// 
/// // Attempt to modify fails (property is read-only)
/// // Set vitals.Temperature = 100  // Error
/// 
/// // Create modified copy instead
/// Set vitals2 = vitals.WithTemperature(100)
/// </example>
/// 
/// @see Patterns.PoEAA.Base.Entity
/// @see Patterns.Examples.Clinical.VitalSigns
/// @since 1.0.0
Class Patterns.PoEAA.Base.ValueObject Extends %RegisteredObject [ Abstract ]
{

Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Data Source";

Parameter PATTERNCATEGORY = "Base";

/// Compares this value object with another for value-based equality.
/// Two value objects are equal if they are of the same type and all their properties have equal values.
/// 
/// @param pOther The other value object to compare with
/// @return %Boolean - 1 if objects are equal, 0 otherwise
/// 
/// Example:
/// <example>
/// Set obj1 = ##class(Money).%New(50, "USD")
/// Set obj2 = ##class(Money).%New(50, "USD")
/// Set obj3 = ##class(Money).%New(100, "USD")
/// Write obj1.Equals(obj2)  // 1 (equal values)
/// Write obj1.Equals(obj3)  // 0 (different values)
/// </example>
Method Equals(pOther As Patterns.PoEAA.Base.ValueObject) As %Boolean
{
    Set tEquals = 0

    Try {
        // Null check
        If '$IsObject(pOther) {
            Set tEquals = 0
            Quit
        }

        // Type check - must be same class
        If (pOther.%ClassName(1) '= ..%ClassName(1)) {
            Set tEquals = 0
            Quit
        }

        // If same instance, equal
        If (pOther = $THIS) {
            Set tEquals = 1
            Quit
        }

        // Subclasses must override to compare properties
        // Base implementation only compares type
        Set tEquals = 1

    } Catch ex {
        Set tEquals = 0
    }

    Quit tEquals
}

/// Gets a hash code for this value object based on its values.
/// Objects that are equal (via Equals()) must return the same hash code.
/// Used for hash-based collections like %ArrayOfObjects.
/// 
/// @return %Integer - Hash code for this object
/// 
/// Example:
/// <example>
/// Set obj1 = ##class(Money).%New(50, "USD")
/// Set obj2 = ##class(Money).%New(50, "USD")
/// Write obj1.GetHashCode()  // Same as obj2.GetHashCode()
/// </example>
Method GetHashCode() As %Integer
{
    Set tHash = 0

    Try {
        // Simple hash based on class name
        // Subclasses should override to include property values
        Set tClassName = ..%ClassName(1)
        Set tHash = $LENGTH(tClassName)

        For tIdx = 1:1:$LENGTH(tClassName) {
            Set tChar = $ASCII(tClassName, tIdx)
            Set tHash = ((tHash * 31) + tChar) # 2147483647
        }

    } Catch ex {
        Set tHash = 0
    }

    Quit tHash
}

/// Returns a string representation of this value object.
/// Useful for debugging and logging.
/// 
/// @return %String - String representation of the object
/// 
/// Example:
/// <example>
/// Set money = ##class(Money).%New(50, "USD")
/// Write money.ToString()  // "Money[amount=50, currency=USD]"
/// </example>
Method ToString() As %String
{
    Set tString = ""

    Try {
        // Default implementation shows class name
        // Subclasses should override to include property values
        Set tString = ..%ClassName(1) _ "[]"

    } Catch ex {
        Set tString = "ValueObject[error]"
    }

    Quit tString
}

/// Creates a copy of this value object.
/// Since value objects are immutable, this returns a new instance with the same values.
/// Subclasses should override to copy their specific properties.
/// 
/// @return ValueObject - A new instance with the same values
/// 
/// Example:
/// <example>
/// Set original = ##class(Money).%New(50, "USD")
/// Set copy = original.Copy()
/// Write copy.Equals(original)  // 1 (same values)
/// </example>
Method Copy() As Patterns.PoEAA.Base.ValueObject
{
    Set tCopy = $$$NULLOREF

    Try {
        // Base implementation returns null
        // Subclasses must override to create proper copies
        Set tCopy = $$$NULLOREF

    } Catch ex {
        Set tCopy = $$$NULLOREF
    }

    Quit tCopy
}

/// Validates this value object's state.
/// Called during construction to ensure all invariants are satisfied.
/// 
/// @return %Status - $$$OK if valid, error status otherwise
/// 
/// Example:
/// <example>
/// Method %OnNew(pAmount) As %Status
/// {
///     Set i%Amount = pAmount
///     Quit ..Validate()
/// }
/// </example>
Method Validate() As %Status
{
    Set tSC = $$$OK

    Try {
        // Base implementation always valid
        // Subclasses override to add validation rules
        Set tSC = $$$OK

    } Catch ex {
        Set tSC = ex.AsStatus()
    }

    Quit tSC
}

}
