/// Gang of Four Mediator Pattern - Abstract Mediator
/// 
/// Intent:
/// Define an object that encapsulates how a set of objects interact.
/// Mediator promotes loose coupling by keeping objects from referring to 
/// each other explicitly, and it lets you vary their interaction independently.
/// 
/// Applicability:
/// - Set of objects communicate in well-defined but complex ways
/// - Reusing an object is difficult because it refers to many other objects
/// - A behavior distributed between several classes should be customizable
/// 
/// Structure:
/// <example>
/// Set mediator = ##class(ConcreteMediator).%New()
/// Set colleague1 = ##class(ConcreteColleague).%New()
/// Set colleague2 = ##class(ConcreteColleague).%New()
/// Do colleague1.SetMediator(mediator)
/// Do colleague2.SetMediator(mediator)
/// Do mediator.RegisterColleague(colleague1)
/// Do mediator.RegisterColleague(colleague2)
/// Do colleague1.Send("Hello from colleague1")
/// </example>
Class Patterns.GoF.Behavioral.Mediator Extends %RegisteredObject [ Abstract ]
{

/// Collection of registered colleagues
Property Colleagues As %ListOfObjects [ Private ];

/// Constructor
Method %OnNew() As %Status
{
        Set ..Colleagues = ##class(%ListOfObjects).%New()
        Quit $$$OK
}

/// Notify mediator of an event from a colleague
Method Notify(pSender As Patterns.GoF.Behavioral.Colleague, pEvent As %String, pData As %DynamicObject = "") As %Status [ Abstract ]
{
        Quit $$$OK
}

/// Register a colleague with the mediator
Method RegisterColleague(pColleague As Patterns.GoF.Behavioral.Colleague) As %Status
{
        Set tSC = $$$OK
        
        Try {
            If '$IsObject(pColleague) {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid colleague object")
                Quit
            }
            
            // Set mediator reference in colleague
            Set pColleague.Mediator = $THIS
            
            // Add to colleagues list
            Do ..Colleagues.Insert(pColleague)
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Deregister a colleague from the mediator
Method DeregisterColleague(pColleague As Patterns.GoF.Behavioral.Colleague) As %Status
{
        Set tSC = $$$OK
        
        Try {
            If '$IsObject(pColleague) {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid colleague object")
                Quit
            }
            
            // Find and remove colleague
            For i=1:1:..Colleagues.Count() {
                Set tColleague = ..Colleagues.GetAt(i)
                If tColleague = pColleague {
                    Do ..Colleagues.RemoveAt(i)
                    Set pColleague.Mediator = ""
                    Quit
                }
            }
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Broadcast message to all colleagues except sender
Method BroadcastMessage(pSender As Patterns.GoF.Behavioral.Colleague, pMessage As %String, pData As %DynamicObject = "") As %Status
{
        Set tSC = $$$OK
        
        Try {
            For i=1:1:..Colleagues.Count() {
                Set tColleague = ..Colleagues.GetAt(i)
                // Don't send back to sender
                If (tColleague '= pSender) {
                    Set tSC = tColleague.Receive(pMessage, pData)
                    If $$$ISERR(tSC) {
                        // Log error but continue broadcasting
                        Continue
                    }
                }
            }
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Get count of registered colleagues
Method GetColleagueCount() As %Integer
{
        Quit ..Colleagues.Count()
}

}
