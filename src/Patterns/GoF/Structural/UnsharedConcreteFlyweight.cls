/// Gang of Four Flyweight Pattern - Unshared Concrete Flyweight
/// 
/// Not all flyweight subclasses need to be shared. The Flyweight interface enables sharing,
/// but doesn't enforce it. UnsharedConcreteFlyweight objects have intrinsic state that is NOT shared.
/// 
/// Structure:
/// <example>
/// Set unshared = ##class(Patterns.GoF.Structural.UnsharedConcreteFlyweight).%New()
/// Set unshared.AllState = "CompleteState"
/// Set result = unshared.Operation("AdditionalContext")
/// </example>
/// 
/// @see Patterns.GoF.Structural.Flyweight
/// @see Patterns.GoF.Structural.FlyweightFactory
/// @since 1.0.0
Class Patterns.GoF.Structural.UnsharedConcreteFlyweight Extends Patterns.GoF.Structural.Flyweight
{

/// All state for unshared flyweight (not separated into intrinsic/extrinsic)
Property AllState As %String;

/// Additional properties that make this flyweight unique
Property UniqueIdentifier As %String;

/// Timestamp when this unshared instance was created
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($ZTIMESTAMP, 3, 1, 3)} ];

/// Constructor for unshared flyweight
Method %OnNew(pState As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Generate unique identifier
        Set ..UniqueIdentifier = $SYSTEM.Util.CreateGUID()
        
        If pState '= "" {
            Set ..AllState = pState
            Set ..IntrinsicState = "Unshared-"_pState
        } Else {
            Set ..IntrinsicState = "Unshared-"_..UniqueIdentifier
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Operation for unshared flyweight
/// Unshared flyweights can have more complex operations since they don't need to be shared
/// 
/// @param pExtrinsicState Additional context for the operation
/// @return Result of operation on unshared flyweight
Method Operation(pExtrinsicState As %String) As %String
{
    Set tResult = ""
    
    Try {
        // Unshared flyweights can maintain and modify their own complete state
        Set tResult = "UnsharedConcreteFlyweight: ["
        Set tResult = tResult_"ID='"_..UniqueIdentifier_"'"
        Set tResult = tResult_", AllState='"_..AllState_"'"
        Set tResult = tResult_", Created='"_..CreatedAt_"'"
        Set tResult = tResult_"] + Context='"_pExtrinsicState_"'"
    }
    Catch ex {
        Set tResult = "Error: "_ex.Name
    }
    
    Quit tResult
}

/// Modify the internal state (possible for unshared flyweights)
Method ModifyState(pNewState As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..AllState = pNewState
        Set ..IntrinsicState = "Unshared-"_pNewState
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get complete state information
Method GetCompleteState() As %String
{
    Set tState = "{"
    Set tState = tState_"""id"":"""_..UniqueIdentifier_""""
    Set tState = tState_",""state"":"""_..AllState_""""
    Set tState = tState_",""created"":"""_..CreatedAt_""""
    Set tState = tState_"}"
    Quit tState
}

/// Display detailed information about unshared flyweight
Method Display() As %String
{
    Set tDisplay = "UnsharedConcreteFlyweight: "
    Set tDisplay = tDisplay_"ID="_..UniqueIdentifier
    Set tDisplay = tDisplay_", State="_..AllState
    Set tDisplay = tDisplay_", Created="_..CreatedAt
    Quit tDisplay
}

/// Clone this unshared flyweight (creates a new unique instance)
Method Clone() As UnsharedConcreteFlyweight
{
    Set tClone = ##class(UnsharedConcreteFlyweight).%New()
    Set tClone.AllState = ..AllState
    // Note: UniqueIdentifier and CreatedAt will be different for the clone
    Quit tClone
}

}
