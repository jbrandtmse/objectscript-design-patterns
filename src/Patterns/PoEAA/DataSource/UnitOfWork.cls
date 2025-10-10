/// Unit of Work Pattern Implementation
/// 
/// Intent:
/// Maintains a list of objects affected by a business transaction and coordinates
/// the writing out of changes and the resolution of concurrency problems.
/// 
/// Motivation:
/// When making changes to objects, you need to track them so you can write them out
/// in a single database transaction. This avoids multiple database calls and ensures
/// consistency through atomicity.
/// 
/// Structure:
/// <example>
/// Set uow = ##class(Patterns.PoEAA.DataSource.UnitOfWork).%New()
/// Do uow.RegisterNew(newObject)
/// Do uow.RegisterDirty(modifiedObject)
/// Do uow.RegisterDeleted(oldObject)
/// Set status = uow.Commit()
/// </example>
/// 
/// @see Patterns.PoEAA.DataSource.DataMapper
/// @since 1.0.0
Class Patterns.PoEAA.DataSource.UnitOfWork Extends %RegisteredObject
{

/// Version of the Unit of Work pattern implementation
Parameter VERSION = "1.0.0";

/// Pattern category
Parameter PATTERNTYPE = "DataSource";

/// Collection of new objects to be inserted
Property NewObjects As list Of %RegisteredObject;

/// Collection of modified objects to be updated
Property DirtyObjects As list Of %RegisteredObject;

/// Collection of objects to be deleted
Property DeletedObjects As list Of %RegisteredObject;

/// Collection of clean objects (no changes)
Property CleanObjects As list Of %RegisteredObject;

/// Registry of mappers by class name for persistence operations
Property Mappers As %String [ MultiDimensional ];

/// Registers a new object to be inserted on commit
/// 
/// @param pObject The object to insert
/// @return %Status indicating success or failure
Method RegisterNew(pObject As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate input
        If '$IsObject(pObject) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid object provided to RegisterNew")
            Quit
        }
        
        // Check if already registered as new
        If ..IsInCollection(pObject, "new") {
            Quit
        }
        
        // Check if registered in other collections (conflict)
        If ..IsInCollection(pObject, "dirty") || ..IsInCollection(pObject, "deleted") || ..IsInCollection(pObject, "clean") {
            Set tSC = $$$ERROR($$$GeneralError, "Object already registered in another state")
            Quit
        }
        
        // Add to new objects collection
        Do ..NewObjects.Insert(pObject)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Registers a modified object to be updated on commit
/// 
/// @param pObject The object to update
/// @return %Status indicating success or failure
Method RegisterDirty(pObject As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate input
        If '$IsObject(pObject) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid object provided to RegisterDirty")
            Quit
        }
        
        // Check if already registered as dirty
        If ..IsInCollection(pObject, "dirty") {
            Quit
        }
        
        // Remove from clean if present
        Do ..RemoveFromCollection(pObject, "clean")
        
        // Don't register as dirty if it's new or deleted
        If ..IsInCollection(pObject, "new") || ..IsInCollection(pObject, "deleted") {
            Quit
        }
        
        // Add to dirty objects collection
        Do ..DirtyObjects.Insert(pObject)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Marks an object as clean (no changes)
/// 
/// @param pObject The object to mark as clean
/// @return %Status indicating success or failure
Method RegisterClean(pObject As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate input
        If '$IsObject(pObject) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid object provided to RegisterClean")
            Quit
        }
        
        // Remove from dirty collection if present
        Do ..RemoveFromCollection(pObject, "dirty")
        
        // Check if already registered as clean
        If ..IsInCollection(pObject, "clean") {
            Quit
        }
        
        // Don't register as clean if it's new or deleted
        If ..IsInCollection(pObject, "new") || ..IsInCollection(pObject, "deleted") {
            Quit
        }
        
        // Add to clean objects collection
        Do ..CleanObjects.Insert(pObject)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Registers an object to be deleted on commit
/// 
/// @param pObject The object to delete
/// @return %Status indicating success or failure
Method RegisterDeleted(pObject As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate input
        If '$IsObject(pObject) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid object provided to RegisterDeleted")
            Quit
        }
        
        // Check if already registered as deleted
        If ..IsInCollection(pObject, "deleted") {
            Quit
        }
        
        // Remove from other collections
        Do ..RemoveFromCollection(pObject, "new")
        Do ..RemoveFromCollection(pObject, "dirty")
        Do ..RemoveFromCollection(pObject, "clean")
        
        // Add to deleted objects collection
        Do ..DeletedObjects.Insert(pObject)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Commits all pending changes in a single transaction
/// Operations are executed in order: Insert, Update, Delete
/// 
/// @return %Status indicating success or failure
Method Commit() As %Status
{
    Set tSC = $$$OK
    Set tResult = ""
    
    Try {
        // Start transaction
        TSTART
        
        // 1. Insert new objects first (dependencies may require them to exist)
        For i=1:1:..NewObjects.Count() {
            Set tObject = ..NewObjects.GetAt(i)
            Set tResult = ..InsertObject(tObject)
            If $$$ISERR(tResult) {
                Set tSC = tResult
                TROLLBACK
                Quit
            }
        }
        If $$$ISERR(tSC) Quit
        
        // 2. Update dirty objects
        For i=1:1:..DirtyObjects.Count() {
            Set tObject = ..DirtyObjects.GetAt(i)
            Set tResult = ..UpdateObject(tObject)
            If $$$ISERR(tResult) {
                Set tSC = tResult
                TROLLBACK
                Quit
            }
        }
        If $$$ISERR(tSC) Quit
        
        // 3. Delete removed objects last (dependencies may require others to exist)
        For i=1:1:..DeletedObjects.Count() {
            Set tObject = ..DeletedObjects.GetAt(i)
            Set tResult = ..DeleteObject(tObject)
            If $$$ISERR(tResult) {
                Set tSC = tResult
                TROLLBACK
                Quit
            }
        }
        If $$$ISERR(tSC) Quit
        
        // Commit transaction
        TCOMMIT
        
        // Clear tracking collections
        Do ..Clear()
        
    } Catch ex {
        TROLLBACK
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Rolls back all pending changes without committing
/// 
/// @return %Status indicating success or failure
Method Rollback() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear all tracking collections
        Do ..Clear()
        
        // Rollback any active transaction
        TROLLBACK
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clears all tracking collections
Method Clear()
{
    Do ..NewObjects.Clear()
    Do ..DirtyObjects.Clear()
    Do ..DeletedObjects.Clear()
    Do ..CleanObjects.Clear()
}

/// Checks if an object is in a specific collection
/// 
/// @param pObject The object to check
/// @param pCollection The collection name (new, dirty, deleted, clean)
/// @return Boolean indicating if object is in collection
Method IsInCollection(pObject As %RegisteredObject, pCollection As %String) As %Boolean [ Private ]
{
    Set tFound = 0
    Set tList = ""
    
    If pCollection = "new" {
        Set tList = ..NewObjects
    } ElseIf pCollection = "dirty" {
        Set tList = ..DirtyObjects
    } ElseIf pCollection = "deleted" {
        Set tList = ..DeletedObjects
    } ElseIf pCollection = "clean" {
        Set tList = ..CleanObjects
    } Else {
        Quit 0
    }
    
    // Use index-based iteration for list collections
    For i=1:1:tList.Count() {
        Set tObj = tList.GetAt(i)
        If tObj = pObject {
            Set tFound = 1
            Quit
        }
    }
    
    Quit tFound
}

/// Removes an object from a specific collection
/// 
/// @param pObject The object to remove
/// @param pCollection The collection name (new, dirty, deleted, clean)
Method RemoveFromCollection(pObject As %RegisteredObject, pCollection As %String) [ Private ]
{
    Set tList = ""
    
    If pCollection = "new" {
        Set tList = ..NewObjects
    } ElseIf pCollection = "dirty" {
        Set tList = ..DirtyObjects
    } ElseIf pCollection = "deleted" {
        Set tList = ..DeletedObjects
    } ElseIf pCollection = "clean" {
        Set tList = ..CleanObjects
    } Else {
        Quit
    }
    
    // Use index-based iteration for list collections
    For i=1:1:tList.Count() {
        Set tObj = tList.GetAt(i)
        If tObj = pObject {
            Do tList.RemoveAt(i)
            Quit
        }
    }
}

/// Inserts an object using its mapper
/// 
/// @param pObject The object to insert
/// @return %Status indicating success or failure
Method InsertObject(pObject As %RegisteredObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    Set tResult = ""
    
    Try {
        Set tMapper = ..GetMapper(pObject)
        If '$IsObject(tMapper) {
            Set tSC = $$$ERROR($$$GeneralError, "No mapper found for object type: " _ pObject.%ClassName(1))
            Quit
        }
        
        Set tResult = tMapper.Insert(pObject)
        Set tSC = tResult
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Updates an object using its mapper
/// 
/// @param pObject The object to update
/// @return %Status indicating success or failure
Method UpdateObject(pObject As %RegisteredObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    Set tResult = ""
    
    Try {
        Set tMapper = ..GetMapper(pObject)
        If '$IsObject(tMapper) {
            Set tSC = $$$ERROR($$$GeneralError, "No mapper found for object type: " _ pObject.%ClassName(1))
            Quit
        }
        
        Set tResult = tMapper.Update(pObject)
        Set tSC = tResult
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Deletes an object using its mapper
/// 
/// @param pObject The object to delete
/// @return %Status indicating success or failure
Method DeleteObject(pObject As %RegisteredObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    Set tResult = ""
    
    Try {
        Set tMapper = ..GetMapper(pObject)
        If '$IsObject(tMapper) {
            Set tSC = $$$ERROR($$$GeneralError, "No mapper found for object type: " _ pObject.%ClassName(1))
            Quit
        }
        
        Set tResult = tMapper.Delete(pObject)
        Set tSC = tResult
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Registers a mapper for a specific class type
/// 
/// @param pClassName The class name to register mapper for
/// @param pMapper The mapper instance
Method RegisterMapper(pClassName As %String, pMapper As %RegisteredObject)
{
    Set ..Mappers(pClassName) = pMapper
}

/// Gets the mapper for a specific object
/// 
/// @param pObject The object to get mapper for
/// @return The mapper instance or null if not found
Method GetMapper(pObject As %RegisteredObject) As %RegisteredObject [ Private ]
{
    Set tClassName = pObject.%ClassName(1)
    
    If $Data(..Mappers(tClassName)) {
        Quit ..Mappers(tClassName)
    }
    
    Quit $$$NULLOREF
}

}
