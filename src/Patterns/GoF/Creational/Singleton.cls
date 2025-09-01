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
/// <li>Static instance storage using a global variable (^Patterns.Singleton)</li>
/// <li>Thread-safe double-checked locking using IRIS $LOCK commands</li>
/// <li>Reset method for testing purposes to clear the singleton instance</li>
/// </ul></p>
/// 
/// <p><b>Sample Code:</b></p>
/// <example>
/// // Get the singleton instance
/// Set singleton = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
/// 
/// // Both variables reference the same instance
/// Set singleton1 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
/// Set singleton2 = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
/// Write "Same instance: ", (singleton1 = singleton2), !  // Outputs: 1 (true)
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

// ===== CONSTRUCTORS/DESTRUCTORS =====

/// Private constructor to prevent direct instantiation
/// Clients must use GetInstance() to obtain the singleton instance
/// 
/// @return Status code
Method %OnNew() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Initialize the creation timestamp
        Set ..CreationTimestamp = $ZDATETIME($HOROLOG, 3)
        
        // Initialize access counter
        Set ..AccessCount = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Return tSC
}

// ===== CLASS METHODS =====

/// Get the singleton instance (thread-safe with double-checked locking)
/// This method ensures that only one instance of the class exists
/// 
/// <p>Implementation uses double-checked locking pattern for thread safety:
/// <ol>
/// <li>First check if instance exists (without lock for performance)</li>
/// <li>If not exists, acquire exclusive lock</li>
/// <li>Double-check inside lock (another thread may have created it)</li>
/// <li>Create instance if still doesn't exist</li>
/// <li>Release lock and return instance</li>
/// </ol></p>
/// 
/// @return The singleton instance of this class
/// @throws Lock timeout exception if unable to acquire lock within 5 seconds
ClassMethod GetInstance() As Patterns.GoF.Creational.Singleton
{
    Set tInstance = ""
    Set tLockName = "^Patterns.Lock(""Singleton"")"
    Set tGlobalName = "^Patterns.Singleton"
    Set tTimeout = 5
    
    Try {
        // First check - without lock for performance
        If $DATA(@tGlobalName) {
            Set tOref = @tGlobalName
            If $ISOBJECT(tOref) {
                // Increment access count
                Set tOref.AccessCount = tOref.AccessCount + 1
                Return tOref
            }
        }
        
        // Need to create instance - acquire exclusive lock
        Lock +@tLockName:tTimeout
        If '$TEST {
            Set tError = ##class(%Exception.General).%New("SingletonLockTimeout")
            Set tError.Name = "SingletonLockTimeout"
            Set tError.Code = "Unable to acquire lock for Singleton creation within " _ tTimeout _ " seconds"
            Throw tError
        }
        
        // Double-check inside lock (another thread may have created it)
        If $DATA(@tGlobalName) {
            Set tOref = @tGlobalName
            If $ISOBJECT(tOref) {
                // Increment access count
                Set tOref.AccessCount = tOref.AccessCount + 1
                Lock -@tLockName
                Return tOref
            }
        }
        
        // Create the singleton instance
        Set tInstance = ..%New()
        If $ISOBJECT(tInstance) {
            // Store in global for persistence across processes
            Set @tGlobalName = tInstance
            
            // Increment initial access count
            Set tInstance.AccessCount = 1
        }
        
        // Release the lock
        Lock -@tLockName
        
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
/// This method clears the stored singleton instance, forcing a new instance
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
    Set tLockName = "^Patterns.Lock(""Singleton"")"
    Set tGlobalName = "^Patterns.Singleton"
    Set tTimeout = 5
    
    Try {
        // Acquire exclusive lock before resetting
        Lock +@tLockName:tTimeout
        If '$TEST {
            Set tSC = $$$ERROR($$$GeneralError, "Unable to acquire lock for Singleton reset within " _ tTimeout _ " seconds")
            Return tSC
        }
        
        // Clear the singleton instance
        If $DATA(@tGlobalName) {
            Set tOref = @tGlobalName
            If $ISOBJECT(tOref) {
                // Properly close the object
                Do tOref.%Close()
            }
            Kill @tGlobalName
        }
        
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
    Set tGlobalName = "^Patterns.Singleton"
    
    If $DATA(@tGlobalName) {
        Set tOref = @tGlobalName
        Return $ISOBJECT(tOref)
    }
    
    Return 0
}

/// Get information about the current singleton instance
/// Returns a dynamic object with instance details
/// 
/// @return %DynamicObject with instance information or empty string if no instance
ClassMethod GetInstanceInfo() As %DynamicObject
{
    Set tInfo = ##class(%DynamicObject).%New()
    Set tGlobalName = "^Patterns.Singleton"
    
    If $DATA(@tGlobalName) {
        Set tOref = @tGlobalName
        If $ISOBJECT(tOref) {
            Set tInfo.exists = 1
            Set tInfo.creationTimestamp = tOref.CreationTimestamp
            Set tInfo.accessCount = tOref.AccessCount
            Set tInfo.className = tOref.%ClassName(1)
            Return tInfo
        }
    }
    
    Set tInfo.exists = 0
    Return tInfo
}

// ===== PUBLIC METHODS =====

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
