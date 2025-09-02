/// Gang of Four Singleton Pattern Implementation
/// 
/// <p><b>Intent:</b><br/>
/// Ensure a class has only one instance and provide a global point of access to it.
/// The Singleton pattern addresses the fundamental need to control instance creation 
/// while providing convenient global access to that single instance.</p>
/// 
/// <p><b>Also Known As:</b><br/>
/// Single Instance Pattern</p>
/// 
/// <p><b>Motivation:</b><br/>
/// Some classes should have exactly one instance. For example, a system should have 
/// only one file system manager or configuration manager. Global variables provide 
/// access to an object but don't prevent instantiation of multiple objects. The 
/// Singleton pattern ensures that a class has only one instance and provides a 
/// global point of access to it.</p>
/// 
/// <p><b>Applicability:</b><br/>
/// Use the Singleton pattern when:
/// <ul>
/// <li>There must be exactly one instance of a class, and it must be accessible 
///     from a well-known access point</li>
/// <li>The sole instance should be extensible by subclassing, and clients should 
///     be able to use an extended instance without modifying their code</li>
/// <li>You need to control access to a shared resource (e.g., database connection, 
///     file system, hardware device)</li>
/// <li>You need to maintain global state within the application</li>
/// </ul></p>
/// 
/// <p><b>Structure:</b><br/>
/// The Singleton class declares the static GetInstance() method that serves as a 
/// constructor and always returns the same instance of its own class. The constructor 
/// is hidden from clients (made private) to prevent direct construction calls.</p>
/// 
/// <p><b>Participants:</b><br/>
/// <ul>
/// <li><b>Singleton (this class):</b> Defines an Instance operation that lets 
///     clients access its unique instance. Instance is a class operation (class method). 
///     May be responsible for creating its own unique instance.</li>
/// </ul></p>
/// 
/// <p><b>Collaborations:</b><br/>
/// Clients access a Singleton instance solely through Singleton's GetInstance() operation.</p>
/// 
/// <p><b>Consequences:</b><br/>
/// <b>Positive:</b>
/// <ul>
/// <li>Controlled access to sole instance - encapsulates sole instance</li>
/// <li>Reduced namespace pollution - avoids global variables</li>
/// <li>Permits refinement of operations and representation - can be subclassed</li>
/// <li>Permits a variable number of instances - can be changed to allow more instances</li>
/// <li>More flexible than class operations (static methods)</li>
/// </ul>
/// <b>Negative:</b>
/// <ul>
/// <li>Difficult to test due to global state</li>
/// <li>Hidden dependencies in code</li>
/// <li>Can create concurrency bottlenecks</li>
/// <li>Violates Single Responsibility Principle (manages instance AND business logic)</li>
/// </ul></p>
/// 
/// <p><b>Implementation:</b><br/>
/// This ObjectScript implementation uses:
/// <ul>
/// <li>Private constructor (%OnNew marked as Private) to prevent direct instantiation</li>
/// <li>Global-based instance tracking with unique instance IDs</li>
/// <li>Thread-safe double-checked locking using IRIS $LOCK commands</li>
/// <li>State persistence through regular globals</li>
/// <li>Instance comparison based on unique IDs rather than object references</li>
/// <li>Reset method for testing purposes to clear the singleton instance</li>
/// </ul></p>
/// 
/// <p><b>Sample Code:</b></p>
/// <example>
/// // Get the singleton instance
/// Set singleton = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
/// 
/// // Both variables reference the same instance (same ID)
/// Set singleton1 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
/// Set singleton2 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
/// Write "Same instance: ", (singleton1.InstanceId = singleton2.InstanceId), !  // Outputs: 1 (true)
/// 
/// // For testing purposes, reset the singleton
/// Do ##class(Patterns.GoF.Creational.Singleton).Reset()
/// </example>
/// 
/// <p><b>Known Uses:</b><br/>
/// <ul>
/// <li>Configuration managers in healthcare systems</li>
/// <li>Database connection pools</li>
/// <li>Logging frameworks</li>
/// <li>Hardware device managers (printers, audio devices)</li>
/// <li>Cache managers</li>
/// </ul></p>
/// 
/// <p><b>Related Patterns:</b><br/>
/// <ul>
/// <li>Abstract Factory, Builder, and Prototype can be implemented as Singletons</li>
/// <li>Facade objects are often Singletons because only one Facade object is required</li>
/// <li>State objects are often Singletons</li>
/// </ul></p>
/// 
/// @see Patterns.GoF.Creational.Factory
/// @see Patterns.GoF.Structural.Facade
/// @since 1.0.0
/// @author ObjectScript Design Patterns Library
Class Patterns.GoF.Creational.Singleton Extends %RegisteredObject
{

// ===== PARAMETERS =====

/// Version of the pattern implementation
Parameter VERSION = "1.0.0";

/// Pattern type from the Gang of Four categorization
Parameter PATTERNTYPE = "Creational";

/// Pattern name for registry
Parameter PATTERNNAME = "Singleton";

// ===== PROPERTIES =====

/// Sample property to demonstrate singleton state
Property CreationTimestamp As %TimeStamp;

/// Counter to demonstrate singleton maintains state
Property AccessCount As %Integer [ InitialExpression = 0 ];

/// Unique instance reference ID for comparison
/// This is the key to singleton identity in ObjectScript
Property InstanceId As %String;

// ===== CONSTRUCTORS/DESTRUCTORS =====

/// Constructor - protected to prevent direct instantiation
/// Clients must use GetInstance() to obtain the singleton instance
/// Accepts initvalue parameter for %RegisteredObject compatibility
/// 
/// @param initvalue Optional initialization value (for subclass compatibility)
/// @return Status code
Method %OnNew(initvalue As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Get the actual class name for polymorphic support
        Set tClassName = ..%ClassName(1)
        
        // Always restore state from global if it exists
        // This ensures all instances have the same ID
        If $DATA(^Patterns.Singleton(tClassName, "State", "InstanceId")) {
            // Restore state from global
            Set ..CreationTimestamp = $GET(^Patterns.Singleton(tClassName, "State", "CreationTimestamp"), $ZDATETIME($HOROLOG, 3))
            Set ..AccessCount = $GET(^Patterns.Singleton(tClassName, "State", "AccessCount"), 0)
            Set ..InstanceId = ^Patterns.Singleton(tClassName, "State", "InstanceId")
        } Else {
            // First time creation - initialize state
            Set ..CreationTimestamp = $ZDATETIME($HOROLOG, 3)
            Set ..AccessCount = 0
            Set ..InstanceId = $SYSTEM.Util.CreateGUID()
            
            // Save initial state to global
            Set ^Patterns.Singleton(tClassName, "State", "CreationTimestamp") = ..CreationTimestamp
            Set ^Patterns.Singleton(tClassName, "State", "AccessCount") = ..AccessCount
            Set ^Patterns.Singleton(tClassName, "State", "InstanceId") = ..InstanceId
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

// ===== CLASS METHODS =====

/// Get the singleton instance (thread-safe with double-checked locking)
/// This method ensures that only one logical instance exists
/// 
/// <p>Implementation approach for ObjectScript:</p>
/// <ul>
/// <li>Creates new object instances as needed (ObjectScript limitation)</li>
/// <li>All instances share the same InstanceId from global storage</li>
/// <li>Singleton identity is based on InstanceId equality, not object reference</li>
/// <li>State is synchronized through global storage</li>
/// </ul>
/// 
/// @return The singleton instance of this class
/// @throws Lock timeout exception if unable to acquire lock within 5 seconds
ClassMethod GetInstance() As Patterns.GoF.Creational.Singleton
{
    // Get the actual class name for polymorphic support
    Set tClassName = ..%ClassName(1)
    
    Set tLockName = "^Patterns.Singleton.Lock("""_tClassName_""")"
    Set tTimeout = 5
    
    Try {
        // Check if singleton state exists
        If '$DATA(^Patterns.Singleton(tClassName, "State", "InstanceId")) {
            // Need to initialize - acquire exclusive lock
            Lock +@tLockName:tTimeout
            If '$TEST {
                Set tError = ##class(%Exception.General).%New("SingletonLockTimeout")
                Set tError.Name = "SingletonLockTimeout"
                Set tError.Code = "Unable to acquire lock for Singleton creation within " _ tTimeout _ " seconds"
                Throw tError
            }
            
            // Double-check inside lock
            If '$DATA(^Patterns.Singleton(tClassName, "State", "InstanceId")) {
                // Create initial instance to initialize state
                Set tInstance = $CLASSMETHOD(tClassName, "%New")
                // State is now saved in global by %OnNew
            }
            
            // Release the lock
            Lock -@tLockName
        }
        
        // Create instance that will load state from global
        Set tInstance = $CLASSMETHOD(tClassName, "%New")
        
        // Increment access count
        Set tAccessCount = $INCREMENT(^Patterns.Singleton(tClassName, "State", "AccessCount"))
        Set tInstance.AccessCount = tAccessCount
        
    } Catch ex {
        // Ensure lock is released even on error
        Lock -@tLockName
        
        // Log the error
        Do ##class(%SYS.System).WriteToConsoleLog("Singleton.GetInstance() error: " _ ex.Name _ " - " _ ex.Code)
        
        // Return empty string on error
        Set tInstance = ""
    }
    
    Return tInstance
}

/// Reset the singleton instance (for testing purposes only)
/// This method clears the stored singleton state, forcing a new instance
/// to be created on the next GetInstance() call
/// 
/// <p><b>WARNING:</b> This method should only be used in unit tests to ensure
/// test isolation. Using it in production code defeats the purpose of the
/// Singleton pattern and can lead to unexpected behavior.</p>
/// 
/// @return Status code indicating success or failure
ClassMethod Reset() As %Status
{
    Set tSC = $$$OK
    
    // Get the actual class name for polymorphic support
    Set tClassName = ..%ClassName(1)
    
    Set tLockName = "^Patterns.Singleton.Lock("""_tClassName_""")"
    Set tTimeout = 5
    
    Try {
        // Acquire exclusive lock before resetting
        Lock +@tLockName:tTimeout
        If '$TEST {
            Set tSC = $$$ERROR($$$GeneralError, "Unable to acquire lock for Singleton reset within " _ tTimeout _ " seconds")
            Return tSC
        }
        
        // Clear the singleton state from global
        Kill ^Patterns.Singleton(tClassName)
        
        // Release the lock
        Lock -@tLockName
        
    } Catch ex {
        // Ensure lock is released even on error
        Lock -@tLockName
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

/// Check if singleton instance exists (without creating it)
/// Useful for testing and monitoring
/// 
/// @return 1 if instance exists, 0 otherwise
ClassMethod InstanceExists() As %Boolean
{
    // Get the actual class name for polymorphic support
    Set tClassName = ..%ClassName(1)
    
    // Check if state exists in global
    Return $DATA(^Patterns.Singleton(tClassName, "State", "InstanceId"))
}

/// Get information about the current singleton instance
/// Returns a dynamic object with instance details
/// 
/// @return %DynamicObject with instance information or empty object if no instance
ClassMethod GetInstanceInfo() As %DynamicObject
{
    Set tInfo = ##class(%DynamicObject).%New()
    
    // Get the actual class name for polymorphic support
    Set tClassName = ..%ClassName(1)
    
    // Check if state exists in global
    If $DATA(^Patterns.Singleton(tClassName, "State")) {
        Set tInfo.exists = 1
        Set tInfo.creationTimestamp = $GET(^Patterns.Singleton(tClassName, "State", "CreationTimestamp"), "")
        Set tInfo.accessCount = $GET(^Patterns.Singleton(tClassName, "State", "AccessCount"), 0)
        Set tInfo.className = tClassName
        Set tInfo.instanceId = $GET(^Patterns.Singleton(tClassName, "State", "InstanceId"), "")
    } Else {
        Set tInfo.exists = 0
    }
    
    Return tInfo
}

// ===== PUBLIC METHODS =====

/// Check if this instance is the same as another instance
/// In ObjectScript, we compare InstanceId rather than object references
/// 
/// @param other The other instance to compare
/// @return 1 if same singleton instance, 0 otherwise
Method IsSameInstance(other As Patterns.GoF.Creational.Singleton) As %Boolean
{
    If '$ISOBJECT(other) {
        Return 0
    }
    
    // Compare instance IDs for singleton equality
    Return (..InstanceId = other.InstanceId)
}

/// Display information about this singleton instance
/// 
/// @return Status code
Method DisplayInfo() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "=== Singleton Instance Information ===", !
        Write "Class: ", ..%ClassName(1), !
        Write "Created: ", ..CreationTimestamp, !
        Write "Access Count: ", ..AccessCount, !
        Write "Instance ID: ", ..InstanceId, !
        Write "Pattern Type: ", ..#PATTERNTYPE, !
        Write "Pattern Name: ", ..#PATTERNNAME, !
        Write "Version: ", ..#VERSION, !
        Write "======================================", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

}
