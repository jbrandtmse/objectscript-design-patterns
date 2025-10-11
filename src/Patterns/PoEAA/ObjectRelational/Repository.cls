/// Repository Pattern Implementation
/// 
/// Intent:
/// Mediates between the domain and data mapping layers using a collection-like
/// interface for accessing domain objects. Provides domain-focused query methods
/// while hiding persistence implementation details.
/// 
/// Motivation:
/// Domain code needs to work with domain objects without concerning itself with
/// database queries or storage mechanisms. The Repository pattern encapsulates
/// the logic of accessing data sources and provides a collection-like interface
/// that domain code can use naturally. This separates domain logic from
/// infrastructure concerns and enables testability.
/// 
/// Structure:
/// Repository acts as an in-memory domain object collection. It uses Data Mapper
/// for persistence operations and Identity Map for caching. Specifications
/// provide flexible query criteria that can be combined and reused.
/// 
/// Applicability:
/// - You need domain-focused query methods
/// - Persistence implementation should be hidden from domain
/// - You want collection-like access to domain objects
/// - Complex queries should be encapsulated and reusable
/// - Domain-driven design is being used
/// 
/// <example>
/// Set repository = ##class(PatientRepository).%New()
/// Set patient = ##class(Patient).%New()
/// Set sc = repository.Add(patient)
/// Set foundPatient = repository.FindById(patient.ID)
/// Set spec = ##class(ActivePatientSpec).%New()
/// Set activePatients = repository.FindBySpecification(spec)
/// </example>
/// 
/// @see Patterns.PoEAA.ObjectRelational.Specification
/// @see Patterns.PoEAA.ObjectRelational.IdentityMap
/// @see Patterns.PoEAA.DataSource.DataMapper
/// @since 1.0.0
Class Patterns.PoEAA.ObjectRelational.Repository Extends %RegisteredObject [ Abstract ]
{

/// Version of the Repository pattern implementation
Parameter VERSION = "1.0.0";

/// Pattern type classification
Parameter PATTERNTYPE = "Object-Relational Behavioral";

// ===== PROPERTIES =====

/// Identity Map for caching loaded entities
Property IdentityMap As Patterns.PoEAA.ObjectRelational.IdentityMap;

/// Data Mapper for persistence operations
/// Subclasses must set this to their specific mapper
Property Mapper As Patterns.PoEAA.DataSource.DataMapper;

/// Entity class name managed by this repository
/// Subclasses must set this parameter
Parameter ENTITYCLASS;

// ===== CONSTRUCTOR =====

/// Initialize the repository with Identity Map
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize Identity Map
        Set ..IdentityMap = ##class(Patterns.PoEAA.ObjectRelational.IdentityMap).%New()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Add an entity to the repository
/// 
/// @param pEntity Domain entity to add
/// @return %Status indicating success or failure
/// 
/// Example:
/// <example>
/// Set status = repository.Add(patient)
/// </example>
Method Add(pEntity As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate entity
        If '$IsObject(pEntity) {
            Set tSC = $$$ERROR($$$GeneralError, "Entity must be a valid object")
            Quit
        }
        
        // Validate mapper exists
        If '$IsObject(..Mapper) {
            Set tSC = $$$ERROR($$$GeneralError, "Mapper not initialized")
            Quit
        }
        
        // Persist using mapper
        Set tSC = ..Mapper.Insert(pEntity)
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Add to identity map
        Set tId = ..GetEntityId(pEntity)
        If (tId '= "") {
            Do ..IdentityMap.Add(tId, pEntity)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Remove an entity from the repository
/// 
/// @param pEntity Domain entity to remove
/// @return %Status indicating success or failure
/// 
/// Example:
/// <example>
/// Set status = repository.Remove(patient)
/// </example>
Method Remove(pEntity As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate entity
        If '$IsObject(pEntity) {
            Set tSC = $$$ERROR($$$GeneralError, "Entity must be a valid object")
            Quit
        }
        
        // Validate mapper exists
        If '$IsObject(..Mapper) {
            Set tSC = $$$ERROR($$$GeneralError, "Mapper not initialized")
            Quit
        }
        
        // Get ID before deletion
        Set tId = ..GetEntityId(pEntity)
        
        // Delete using mapper
        Set tSC = ..Mapper.Delete(pEntity)
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Remove from identity map
        If (tId '= "") {
            Do ..IdentityMap.Remove(tId)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Find an entity by its unique identifier
/// 
/// @param pId Unique identifier of the entity
/// @return Entity object or null if not found
/// 
/// Example:
/// <example>
/// Set patient = repository.FindById("123")
/// </example>
Method FindById(pId As %String) As %RegisteredObject
{
    Set tEntity = ""
    
    Try {
        // Check identity map first
        Set tEntity = ..IdentityMap.Get(pId)
        
        // If not in cache, load from database
        If '$IsObject(tEntity) {
            If $IsObject(..Mapper) {
                Set tEntity = ..Mapper.Find(pId)
                
                // Add to identity map if found
                If $IsObject(tEntity) {
                    Do ..IdentityMap.Add(pId, tEntity)
                }
            }
        }
        
    } Catch ex {
        Set tEntity = ""
    }
    
    Quit tEntity
}

/// Find all entities in the repository
/// 
/// @return List of all entities
/// 
/// Example:
/// <example>
/// Set allPatients = repository.FindAll()
/// </example>
Method FindAll() As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        If $IsObject(..Mapper) {
            Set tList = ..Mapper.FindAll()
            
            // Add all entities to identity map
            For i=1:1:tList.Count() {
                Set tEntity = tList.GetAt(i)
                If $IsObject(tEntity) {
                    Set tId = ..GetEntityId(tEntity)
                    If (tId '= "") {
                        Do ..IdentityMap.Add(tId, tEntity)
                    }
                }
            }
        }
        
    } Catch ex {
        Set tList = ##class(%ListOfObjects).%New()
    }
    
    Quit tList
}

/// Find entities matching the given specification
/// 
/// @param pSpec Specification defining query criteria
/// @return List of entities matching the specification
/// 
/// Example:
/// <example>
/// Set spec = ##class(ActivePatientSpec).%New()
/// Set activePatients = repository.FindBySpecification(spec)
/// </example>
Method FindBySpecification(pSpec As Patterns.PoEAA.ObjectRelational.Specification) As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    
    Try {
        // Validate specification
        If '$IsObject(pSpec) {
            Quit
        }
        
        // Get SQL from specification
        Set tSQL = pSpec.ToSQL()
        If (tSQL = "") {
            Quit
        }
        
        // Execute query using FindBySQL (subclass must implement)
        Set tList = ..FindBySQL(tSQL)
        
    } Catch ex {
        Set tList = ##class(%ListOfObjects).%New()
    }
    
    Quit tList
}

/// Get the count of entities in the repository
/// 
/// @return Number of entities
/// 
/// Example:
/// <example>
/// Write "Patient count: ", repository.Count()
/// </example>
Method Count() As %Integer
{
    Set tCount = 0
    
    Try {
        Set tList = ..FindAll()
        Set tCount = tList.Count()
        
    } Catch ex {
        Set tCount = 0
    }
    
    Quit tCount
}

/// Check if an entity with the given ID exists in the repository
/// 
/// @param pId Unique identifier to check
/// @return 1 if entity exists, 0 otherwise
/// 
/// Example:
/// <example>
/// If repository.Contains("123") { Write "Patient exists" }
/// </example>
Method Contains(pId As %String) As %Boolean
{
    Set tExists = 0
    
    Try {
        Set tEntity = ..FindById(pId)
        Set tExists = $IsObject(tEntity)
        
    } Catch ex {
        Set tExists = 0
    }
    
    Quit tExists
}

/// Update an existing entity in the repository
/// 
/// @param pEntity Entity to update
/// @return %Status indicating success or failure
/// 
/// Example:
/// <example>
/// Set patient.Name = "New Name"
/// Set status = repository.Update(patient)
/// </example>
Method Update(pEntity As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate entity
        If '$IsObject(pEntity) {
            Set tSC = $$$ERROR($$$GeneralError, "Entity must be a valid object")
            Quit
        }
        
        // Validate mapper exists
        If '$IsObject(..Mapper) {
            Set tSC = $$$ERROR($$$GeneralError, "Mapper not initialized")
            Quit
        }
        
        // Update using mapper
        Set tSC = ..Mapper.Update(pEntity)
        If $$$ISERR(tSC) {
            Quit
        }
        
        // Update in identity map
        Set tId = ..GetEntityId(pEntity)
        If (tId '= "") {
            Do ..IdentityMap.Add(tId, pEntity)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clear the identity map cache
/// 
/// @return %Status indicating success or failure
/// 
/// Useful for long-running processes or when fresh data is needed
Method ClearCache() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $IsObject(..IdentityMap) {
            Set tSC = ..IdentityMap.Clear()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== ABSTRACT METHODS - SUBCLASSES MUST IMPLEMENT =====

/// Get the unique identifier from an entity
/// 
/// @param pEntity Entity to extract ID from
/// @return Unique identifier as string
/// 
/// Subclasses must implement this to extract the ID property
Method GetEntityId(pEntity As %RegisteredObject) As %String [ Abstract ]
{
    Quit ""
}

/// Find entities by SQL WHERE clause
/// 
/// @param pWhereClause SQL WHERE clause (without WHERE keyword)
/// @return List of entities matching the query
/// 
/// Subclasses must implement this for specification-based queries
Method FindBySQL(pWhereClause As %String) As %ListOfObjects [ Abstract ]
{
    Quit ##class(%ListOfObjects).%New()
}

}
