/// Gang of Four Mediator Pattern - Abstract Colleague
/// 
/// Purpose:
/// Base class for objects that communicate through a mediator
/// 
/// Features:
/// - Reference to mediator
/// - Send messages through mediator
/// - Receive messages from mediator
/// - Unique identification
Class Patterns.GoF.Behavioral.Colleague Extends %RegisteredObject [ Abstract ]
{

/// Reference to the mediator
Property Mediator As Patterns.GoF.Behavioral.Mediator;

/// Unique identifier for this colleague
Property ColleagueId As %String;

/// Constructor
Method %OnNew(pId As %String = "") As %Status
{
        If pId = "" {
            Set ..ColleagueId = ..%ClassName(1) _ "_" _ $Random(99999)
        } Else {
            Set ..ColleagueId = pId
        }
        Quit $$$OK
}

/// Send message through mediator
Method Send(pEvent As %String, pData As %DynamicObject = "") As %Status
{
        Set tSC = $$$OK
        
        Try {
            If '$IsObject(..Mediator) {
                Set tSC = $$$ERROR($$$GeneralError, "No mediator set for colleague: " _ ..ColleagueId)
                Quit
            }
            
            Set tSC = ..Mediator.Notify($THIS, pEvent, pData)
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Receive message from mediator
Method Receive(pMessage As %String, pData As %DynamicObject = "") As %Status [ Abstract ]
{
        Quit $$$OK
}

/// Set mediator for this colleague
Method SetMediator(pMediator As Patterns.GoF.Behavioral.Mediator) As %Status
{
        Set tSC = $$$OK
        
        Try {
            If '$IsObject(pMediator) {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid mediator object")
                Quit
            }
            
            Set ..Mediator = pMediator
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Get colleague identifier
Method GetId() As %String
{
        Quit ..ColleagueId
}

}
