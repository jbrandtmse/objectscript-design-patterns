# Chapter 1: The Singleton Pattern

## What is the Singleton Pattern?

Imagine you're running a hospital, and you need one central place to manage all your settings - like whether to use HL7 messaging, where your FHIR server is located, and how many connections your system can handle. You wouldn't want multiple, conflicting configuration managers running around. The Singleton pattern ensures you have exactly one instance of something important, and everyone in your program uses that same instance.

## Intent

The Singleton pattern makes sure a class has only one instance and provides a way for everyone to access that single instance. Think of it like having only one principal in a school - everyone knows there's just one, and everyone knows how to find them.

In our ObjectScript implementation (`src/Patterns/GoF/Creational/Singleton.cls`), we achieve this by:
- Making the constructor private so no one can create new instances directly
- Providing a special method called `GetInstance()` that either creates the one instance or returns the existing one

## When Should You Use It? (Applicability)

Use the Singleton pattern when:

1. **You need exactly one instance** - Like our `ConfigurationManager` that holds all the hospital's settings
2. **That instance needs to be accessible from everywhere** - Any part of your program can call `ConfigurationManager.GetInstance()`
3. **You want controlled access** - The singleton controls when and how it's created

Real-world examples in healthcare:
- Configuration managers (our example!)
- Database connection pools
- Logging systems
- Cache managers
- License managers

## How It Works (Structure)

Here's a simple diagram showing how the Singleton pattern works:

```
┌─────────────────────────────────────┐
│           Singleton Class           │
├─────────────────────────────────────┤
│ - instance (stored in global)       │
│ - AccessCount                       │
│ - InstanceID                        │
├─────────────────────────────────────┤
│ + GetInstance() : Singleton         │
│ + Reset() : void                    │
│ - %OnNew() : %Status (private)      │
└─────────────────────────────────────┘
            ▲
            │ extends
            │
┌─────────────────────────────────────┐
│      ConfigurationManager           │
├─────────────────────────────────────┤
│ + HL7Enabled                        │
│ + FHIREndpoint                      │
│ + MaxConnections                    │
├─────────────────────────────────────┤
│ + LoadConfiguration()               │
│ + SaveConfiguration()               │
│ + GetSetting()                      │
│ + SetSetting()                      │
└─────────────────────────────────────┘
```

### How GetInstance() Works - Step by Step

Let's look at the actual code from our implementation:

```objectscript
ClassMethod GetInstance() As Patterns.GoF.Creational.Singleton
{
    // Step 1: Check if instance already exists (fast check)
    If $DATA(^Patterns.Singleton) {
        Set tOref = ^Patterns.Singleton
        If $ISOBJECT(tOref) {
            // Instance exists! Just return it
            Set tOref.AccessCount = tOref.AccessCount + 1
            Return tOref
        }
    }
    
    // Step 2: Lock to prevent race conditions
    Lock +^Patterns.Lock("Singleton"):5
    
    // Step 3: Check again (someone might have created it while we waited)
    If $DATA(^Patterns.Singleton) {
        Set tOref = ^Patterns.Singleton
        If $ISOBJECT(tOref) {
            Lock -^Patterns.Lock("Singleton")
            Return tOref
        }
    }
    
    // Step 4: Create the one and only instance
    Set tOref = ..%New()
    Set ^Patterns.Singleton = tOref
    
    // Step 5: Unlock and return
    Lock -^Patterns.Lock("Singleton")
    Return tOref
}
```

This is called "double-checked locking" - we check twice to make sure we're thread-safe (multiple processes won't create multiple instances).

**Important ObjectScript Implementation Note**: Due to ObjectScript's architecture, we can't store object references directly in globals. Instead, our actual implementation stores a unique InstanceId in the global `^Patterns.Singleton("InstanceId")` and creates new object references that share this ID. Each call to GetInstance() returns a new object reference, but all references share the same InstanceId. The IsSameInstance() method verifies singleton identity by comparing these IDs:

```objectscript
Method IsSameInstance(pOther As Patterns.GoF.Creational.Singleton) As %Boolean
{
    If '$ISOBJECT(pOther) Return 0
    Return (..InstanceId = pOther.InstanceId)
}
```

## What Happens When You Use It (Consequences)

### The Good Parts ✅

1. **Controlled Access**: You have complete control over the one instance
   ```objectscript
   // Everyone gets the same configuration manager
   Set config1 = ##class(ConfigurationManager).GetInstance()
   Set config2 = ##class(ConfigurationManager).GetInstance()
   // config1 and config2 are the exact same object!
   ```

2. **Saves Memory**: Only one instance exists, no matter how many times you ask for it

3. **Global Access**: Any part of your program can access it
   ```objectscript
   // In any class, anywhere in your program:
   Set config = ##class(ConfigurationManager).GetInstance()
   Do config.SetSetting("MaxConnections", 100)
   ```

4. **Lazy Creation**: The instance is only created when first needed

### The Challenging Parts ⚠️

1. **Testing Can Be Tricky**: Since there's only one instance, tests can affect each other
   ```objectscript
   // That's why we have a Reset() method for testing
   Do ##class(Singleton).Reset()
   ```

2. **Can Hide Dependencies**: It's not always obvious which classes depend on the singleton

3. **Multi-threading Complexity**: We need special locking code to be thread-safe

## Real Example: Healthcare Configuration Manager

Our `ConfigurationManager` (in `src/Patterns/Examples/ConfigurationManager.cls`) shows the Singleton pattern in action:

```objectscript
// First call creates the instance
Set config = ##class(ConfigurationManager).GetInstance()

// Configure hospital settings
Set config.HL7Enabled = 1
Set config.FHIREndpoint = "https://fhir.hospital.org/api"
Set config.MaxConnections = 50
Set config.AuditLevel = "FULL"

// Save to persistent storage
Do config.SaveConfiguration()

// Later, anywhere else in the program...
Set sameConfig = ##class(ConfigurationManager).GetInstance()
Write sameConfig.FHIREndpoint  // Outputs: https://fhir.hospital.org/api
```

The configuration is shared across your entire application - perfect for system-wide settings!

## Testing the Pattern

Our test class (`src/Patterns/Test/Unit/GoF/Creational/SingletonTest.cls`) verifies that:

1. **Only one instance exists**:
   ```objectscript
   Method TestSingleInstance()
   {
       Set instance1 = ##class(Singleton).GetInstance()
       Set instance2 = ##class(Singleton).GetInstance()
       Do $$$AssertEquals(instance1, instance2, "Same instance returned")
   }
   ```

2. **State is preserved**:
   ```objectscript
   Method TestStatePreservation()
   {
       Set instance1 = ##class(Singleton).GetInstance()
       Set instance1.TestProperty = "Hello"
       
       Set instance2 = ##class(Singleton).GetInstance()
       Do $$$AssertEquals(instance2.TestProperty, "Hello", "State preserved")
   }
   ```

## Summary

The Singleton pattern is like having one principal for a school, one configuration manager for a hospital, or one president for a country. It ensures:
- There's exactly one instance
- Everyone can access it
- It's created only when needed
- It's thread-safe (multiple processes won't create duplicates)

Use it when you need to coordinate system-wide resources or settings, but remember that with great power comes great responsibility - make sure you really need just one instance before using this pattern!

## Try It Yourself

1. Look at the `ConfigurationManager` class and try adding a new setting
2. Run the unit tests to see how the Singleton behaves
3. Try creating your own Singleton for a different purpose (like a LogManager or CacheManager)

Remember: The Singleton pattern is powerful but should be used wisely. Not everything needs to be a singleton - only things that truly need to be unique across your entire application!
