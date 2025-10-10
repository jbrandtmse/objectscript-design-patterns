/// Gang of Four Data Mapper Pattern - Base Implementation
/// 
/// Intent:
/// Provides a layer of mappers that moves data between objects and a database
/// while keeping them independent of each other and the mapper itself.
/// 
/// Key Responsibilities:
/// - Complete separation of domain objects from database persistence
/// - Object-relational mapping between domain model and database schema
/// - Identity Map pattern for preventing duplicate object loads
/// - Insert, Update, Delete operations on domain objects
/// - Finder methods returning fully-populated domain objects
/// 
/// Applicability:
/// - Complex domain models requiring clean separation from persistence
/// - Rich business logic that should not be coupled to database
/// - Need for testable domain objects without database dependencies
/// - Object-oriented design with relational database storage
/// 
/// Structure:
/// <example>
/// Set mapper = ##class(ClinicalEncounterMapper).%New()
/// Set encounter = ##class(ClinicalEncounter).%New()
/// Set encounter.PatientMRN = "MRN123"
/// Set sc = mapper.Insert(encounter)
/// Set loadedEncounter = mapper.Find(encounter.EncounterId)
/// </example>
/// 
/// @see Patterns.PoEAA.DataSource.ActiveRecord
/// @see Patterns.PoEAA.DataSource.RowDataGateway
/// @see Patterns.PoEAA.DataSource.TableDataGateway
/// @since 1.0.0
Class Patterns.PoEAA.DataSource.DataMapper Extends %RegisteredObject
{

/// Pattern type classification
Parameter PATTERNTYPE = "DataSource";

/// Pattern category from PoEAA
Parameter PATTERNCATEGORY = "Object-Relational Structural";

/// Insert a new domain object into the database
/// 
/// @param pDomainObject Domain object to insert
/// @return %Status indicating success or failure
/// 
/// Subclasses must override this method to provide specific SQL INSERT logic
Method Insert(pDomainObject As %RegisteredObject) As %Status [ Abstract ]
{
    Quit $$$ERROR($$$GeneralError, "Insert() must be implemented by subclass")
}

/// Update an existing domain object in the database
/// 
/// @param pDomainObject Domain object to update
/// @return %Status indicating success or failure
/// 
/// Subclasses must override this method to provide specific SQL UPDATE logic
Method Update(pDomainObject As %RegisteredObject) As %Status [ Abstract ]
{
    Quit $$$ERROR($$$GeneralError, "Update() must be implemented by subclass")
}

/// Delete a domain object from the database
/// 
/// @param pDomainObject Domain object to delete
/// @return %Status indicating success or failure
/// 
/// Subclasses must override this method to provide specific SQL DELETE logic
Method Delete(pDomainObject As %RegisteredObject) As %Status [ Abstract ]
{
    Quit $$$ERROR($$$GeneralError, "Delete() must be implemented by subclass")
}

/// Find a domain object by ID
/// 
/// @param pId Unique identifier of the object
/// @return Domain object instance or null if not found
/// 
/// Checks Identity Map first before querying database
/// Subclasses must override this method to provide specific SQL SELECT logic
Method Find(pId As %String) As %RegisteredObject [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Find all domain objects
/// 
/// @return List of domain object instances
/// 
/// Subclasses must override this method to provide specific SQL SELECT logic
Method FindAll() As %ListOfObjects [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Map database result set data to domain object
/// 
/// @param pId Unique identifier
/// @param pData Dynamic object containing database row data
/// @return Populated domain object
/// 
/// Subclasses must override this method to map specific fields
Method MapToDomain(pId As %String, pData As %DynamicObject) As %RegisteredObject [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Map domain object to database-ready data structure
/// 
/// @param pDomainObject Domain object to extract data from
/// @return Dynamic object containing data for SQL operations
/// 
/// Subclasses must override this method to extract specific fields
Method MapToDatabase(pDomainObject As %RegisteredObject) As %DynamicObject [ Abstract ]
{
    Quit {}
}

}
