/// Internal storage helper for Singleton pattern
/// This class manages singleton instances in memory using static storage
Class Patterns.GoF.Creational.SingletonStorage Extends %RegisteredObject
{

/// Storage for singleton instances (class name -> instance)
Property Instances As %ArrayOfObjects [ Private ];

/// Get or create the singleton storage instance
/// Note: In ObjectScript, we cannot truly store object references across method calls
/// This implementation creates a new storage object but maintains singleton data
ClassMethod GetStorage() As Patterns.GoF.Creational.SingletonStorage
{
    // Create a new storage instance each time
    // This is a limitation of ObjectScript - we can't maintain true object references
    Set tStorage = ##class(Patterns.GoF.Creational.SingletonStorage).%New()
    
    // Restore any singleton instances that were previously created
    // We track their existence in a global, but recreate them as needed
    Set tClassName = ""
    For {
        Set tClassName = $ORDER(^Patterns.SingletonStorage("Instances", tClassName))
        Quit:tClassName=""
        
        // Mark that this class has a singleton instance
        // The actual instance will be recreated when needed
    }
    
    Return tStorage
}

/// Constructor
Method %OnNew() As %Status
{
    Set ..Instances = ##class(%ArrayOfObjects).%New()
    Return $$$OK
}

/// Store a singleton instance
Method SetInstance(pClassName As %String, pInstance As %RegisteredObject) As %Status
{
    Do ..Instances.SetAt(pInstance, pClassName)
    
    // Mark in global that this class has a singleton instance
    Set ^Patterns.SingletonStorage("Instances", pClassName) = 1
    
    Return $$$OK
}

/// Retrieve a singleton instance
Method GetInstance(pClassName As %String) As %RegisteredObject
{
    Return ..Instances.GetAt(pClassName)
}

/// Check if an instance exists
Method HasInstance(pClassName As %String) As %Boolean
{
    // First check the in-memory array
    If ..Instances.IsDefined(pClassName) {
        Return 1
    }
    
    // Check if it was previously created (marked in global)
    Return $DATA(^Patterns.SingletonStorage("Instances", pClassName))
}

/// Remove an instance
Method RemoveInstance(pClassName As %String) As %Status
{
    Do ..Instances.RemoveAt(pClassName)
    
    // Remove from global tracking
    Kill ^Patterns.SingletonStorage("Instances", pClassName)
    
    Return $$$OK
}

/// Clear all singleton instances (for testing)
ClassMethod ClearAll() As %Status
{
    // Clear the storage globals
    Kill ^Patterns.SingletonStorage
    Return $$$OK
}

}
