/// Registry for dynamic colleague discovery and management
Class Patterns.GoF.Behavioral.ColleagueRegistry Extends %RegisteredObject
{

/// Registered colleagues by ID
Property Colleagues As %ArrayOfObjects;

/// Colleagues grouped by capability/type
Property ColleaguesByType [ MultiDimensional ];

/// Metadata about colleagues
Property Metadata [ MultiDimensional ];

/// Active status tracking
Property ActiveStatus As %ArrayOfDataTypes;

/// <p>
/// <b>Purpose:</b> Initialize the registry for colleague management.<br/>
/// <b>Pattern:</b> Singleton-like initialization for centralized registry
/// </p>
Method %OnNew() As %Status
{
    Set ..Colleagues = ##class(%ArrayOfObjects).%New()
    Set ..ActiveStatus = ##class(%ArrayOfDataTypes).%New()
    Quit $$$OK
}

/// <p>
/// <b>Purpose:</b> Register a colleague with automatic discovery of capabilities.<br/>
/// <b>Pattern:</b> Service Locator pattern for dynamic registration<br/>
/// <b>Benefit:</b> Allows runtime registration without compile-time coupling
/// </p>
/// Register a colleague with metadata
/// @param pColleagueId Unique identifier for colleague
/// @param pColleague The colleague instance
/// @param pType Colleague type/capability
/// @param pMetadata Additional metadata
/// @return Status of registration
Method RegisterColleague(pColleagueId As %String, pColleague As Patterns.GoF.Behavioral.Colleague, pType As %String = "", pMetadata As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    // Store colleague
    Do ..Colleagues.SetAt(pColleague, pColleagueId)
    
    // Store by type if provided
    If pType '= "" {
        If '$DATA(..ColleaguesByType(pType)) {
            Set ..ColleaguesByType(pType) = $LISTBUILD()
        }
        Set ..ColleaguesByType(pType) = ..ColleaguesByType(pType) _ $LISTBUILD(pColleagueId)
    }
    
    // Store metadata
    If pMetadata '= "" {
        Set ..Metadata(pColleagueId) = pMetadata.%ToJSON()
    }
    
    // Set as active
    Do ..ActiveStatus.SetAt(1, pColleagueId)
    
    Quit tSC
}

/// <p>
/// <b>Purpose:</b> Remove colleague and clean up all references.<br/>
/// <b>Lifecycle:</b> Proper cleanup prevents memory leaks and stale references
/// </p>
/// Deregister a colleague
/// @param pColleagueId Colleague identifier
/// @return Status of deregistration
Method DeregisterColleague(pColleagueId As %String) As %Status
{
    Set tSC = $$$OK
    
    // Mark as inactive first
    Do ..ActiveStatus.SetAt(0, pColleagueId)
    
    // Remove from main registry
    Do ..Colleagues.RemoveAt(pColleagueId)
    
    // Remove from type groups
    Set type = ""
    For {
        Set type = $ORDER(..ColleaguesByType(type))
        Quit:type=""
        
        Set list = ..ColleaguesByType(type)
        Set newList = $LISTBUILD()
        For i=1:1:$LISTLENGTH(list) {
            Set id = $LISTGET(list, i)
            If id '= pColleagueId {
                Set newList = newList _ $LISTBUILD(id)
            }
        }
        
        If $LISTLENGTH(newList) > 0 {
            Set ..ColleaguesByType(type) = newList
        } Else {
            Kill ..ColleaguesByType(type)
        }
    }
    
    // Clean up metadata
    Kill ..Metadata(pColleagueId)
    Do ..ActiveStatus.RemoveAt(pColleagueId)
    
    Quit tSC
}

/// <p>
/// <b>Purpose:</b> Find colleagues by capability without knowing concrete types.<br/>
/// <b>Pattern:</b> Service discovery for decoupled communication<br/>
/// <b>Example:</b> Find all colleagues that can handle "LAB_TEST" messages
/// </p>
/// Find colleagues by type/capability
/// @param pType Type or capability to search for
/// @return List of colleague IDs
Method FindByType(pType As %String) As %ListOfDataTypes
{
    Set result = ##class(%ListOfDataTypes).%New()
    
    If $DATA(..ColleaguesByType(pType)) {
        Set list = ..ColleaguesByType(pType)
        For i=1:1:$LISTLENGTH(list) {
            Set id = $LISTGET(list, i)
            // Only include active colleagues
            If ..IsActive(id) {
                Do result.Insert(id)
            }
        }
    }
    
    Quit result
}

/// <p>
/// <b>Purpose:</b> Get colleague without knowing concrete type.<br/>
/// <b>Benefit:</b> Allows mediator to work with abstract references
/// </p>
/// Get colleague by ID
/// @param pColleagueId Colleague identifier
/// @return Colleague instance or empty string
Method GetColleague(pColleagueId As %String) As Patterns.GoF.Behavioral.Colleague
{
    If ..Colleagues.IsDefined(pColleagueId) {
        Quit ..Colleagues.GetAt(pColleagueId)
    }
    Quit ""
}

/// <p>
/// <b>Purpose:</b> Check colleague availability for fault tolerance.<br/>
/// <b>Usage:</b> Mediator can skip inactive colleagues
/// </p>
/// Check if colleague is active
/// @param pColleagueId Colleague identifier
/// @return Boolean indicating active status
Method IsActive(pColleagueId As %String) As %Boolean
{
    If ..ActiveStatus.IsDefined(pColleagueId) {
        Quit ..ActiveStatus.GetAt(pColleagueId)
    }
    Quit 0
}

/// <p>
/// <b>Purpose:</b> Temporarily disable colleague without removal.<br/>
/// <b>Benefit:</b> Allows maintenance mode or graceful degradation
/// </p>
/// Set colleague active status
/// @param pColleagueId Colleague identifier
/// @param pActive Active status
/// @return Status
Method SetActive(pColleagueId As %String, pActive As %Boolean) As %Status
{
    Do ..ActiveStatus.SetAt(pActive, pColleagueId)
    Quit $$$OK
}

/// <p>
/// <b>Purpose:</b> Get all active colleagues for broadcast scenarios.<br/>
/// <b>Usage:</b> Used for system-wide notifications
/// </p>
/// Get all active colleagues
/// @return List of active colleague IDs
Method GetActiveColleagues() As %ListOfDataTypes
{
    Set result = ##class(%ListOfDataTypes).%New()
    Set key = ""
    For {
        Set key = ..Colleagues.Next(key)
        Quit:key=""
        
        If ..IsActive(key) {
            Do result.Insert(key)
        }
    }
    Quit result
}

/// <p>
/// <b>Purpose:</b> Get colleague metadata for routing decisions.<br/>
/// <b>Example:</b> Check colleague's department, priority, capabilities
/// </p>
/// Get colleague metadata
/// @param pColleagueId Colleague identifier
/// @return Metadata as dynamic object
Method GetMetadata(pColleagueId As %String) As %DynamicObject
{
    If $DATA(..Metadata(pColleagueId)) {
        Quit {}.%FromJSON(..Metadata(pColleagueId))
    }
    Quit ""
}

/// <p>
/// <b>Purpose:</b> Update colleague metadata at runtime.<br/>
/// <b>Benefit:</b> Allows dynamic reconfiguration without restart
/// </p>
/// Update colleague metadata
/// @param pColleagueId Colleague identifier
/// @param pMetadata New metadata
/// @return Status
Method UpdateMetadata(pColleagueId As %String, pMetadata As %DynamicObject) As %Status
{
    If ..Colleagues.IsDefined(pColleagueId) {
        Set ..Metadata(pColleagueId) = pMetadata.%ToJSON()
        Quit $$$OK
    }
    Quit $$$ERROR($$$GeneralError, "Colleague not found: "_pColleagueId)
}

/// Check if colleague exists in registry
/// @param pColleagueId Colleague identifier
/// @return Boolean indicating if colleague exists
Method HasColleague(pColleagueId As %String) As %Boolean
{
    Quit ..Colleagues.IsDefined(pColleagueId)
}

}
