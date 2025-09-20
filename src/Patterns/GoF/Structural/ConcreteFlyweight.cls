/// Gang of Four Flyweight Pattern - Concrete Flyweight Implementation
/// 
/// Concrete implementation of Flyweight that stores intrinsic state.
/// All instances sharing the same intrinsic state are represented by a single flyweight object.
/// 
/// Structure:
/// <example>
/// Set flyweight = ##class(Patterns.GoF.Structural.ConcreteFlyweight).%New()
/// Set flyweight.IntrinsicState = "SharedData"
/// Set result = flyweight.Operation("ExtrinsicData")
/// </example>
/// 
/// @see Patterns.GoF.Structural.Flyweight
/// @see Patterns.GoF.Structural.FlyweightFactory
/// @since 1.0.0
Class Patterns.GoF.Structural.ConcreteFlyweight Extends Patterns.GoF.Structural.Flyweight
{

/// Additional shared properties specific to concrete flyweights
Property SharedData As %String;

/// Reference count for tracking usage
Property ReferenceCount As %Integer [ InitialExpression = 0 ];

/// Constructor to initialize the concrete flyweight
Method %OnNew(pIntrinsicState As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pIntrinsicState '= "" {
            Set ..IntrinsicState = pIntrinsicState
        }
        Set ..ReferenceCount = 1
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Concrete implementation of operation combining intrinsic and extrinsic state
/// 
/// @param pExtrinsicState Context-specific state from client
/// @return Combined result of intrinsic and extrinsic state processing
Method Operation(pExtrinsicState As %String) As %String
{
    Set tResult = ""
    
    Try {
        // Combine intrinsic state with extrinsic state for operation
        Set tResult = "ConcreteFlyweight: ["
        Set tResult = tResult_"Intrinsic='"_..IntrinsicState_"'"
        
        If ..SharedData '= "" {
            Set tResult = tResult_", SharedData='"_..SharedData_"'"
        }
        
        Set tResult = tResult_"] + Extrinsic='"_pExtrinsicState_"'"
    }
    Catch ex {
        Set tResult = "Error: "_ex.Name
    }
    
    Quit tResult
}

/// Increment reference count
Method IncrementReference() As %Integer
{
    Set ..ReferenceCount = ..ReferenceCount + 1
    Quit ..ReferenceCount
}

/// Decrement reference count
Method DecrementReference() As %Integer
{
    If ..ReferenceCount > 0 {
        Set ..ReferenceCount = ..ReferenceCount - 1
    }
    Quit ..ReferenceCount
}

/// Get current reference count
Method GetReferenceCount() As %Integer
{
    Quit ..ReferenceCount
}

/// Clone intrinsic state to create a new flyweight with same shared data
Method CloneIntrinsicState() As ConcreteFlyweight
{
    Set tClone = ##class(ConcreteFlyweight).%New()
    Set tClone.IntrinsicState = ..IntrinsicState
    Set tClone.SharedData = ..SharedData
    Quit tClone
}

/// Display detailed state information
Method Display() As %String
{
    Set tDisplay = ##super()
    If ..SharedData '= "" {
        Set tDisplay = tDisplay_", SharedData: "_..SharedData
    }
    Set tDisplay = tDisplay_" (References: "_..ReferenceCount_")"
    Quit tDisplay
}

}
