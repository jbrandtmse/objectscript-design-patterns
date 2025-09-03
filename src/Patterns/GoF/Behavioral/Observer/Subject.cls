/// Gang of Four Observer Pattern - Subject Class
/// <p>
/// Intent:
/// Define a one-to-many dependency between objects so that when one object
/// changes state, all its dependents are notified and updated automatically.
/// </p>
/// <p>
/// Also Known As:
/// Dependents, Publish-Subscribe
/// </p>
Class Patterns.GoF.Behavioral.Observer.Subject Extends %RegisteredObject
{

Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Behavioral";

/// Collection of registered observers
Property Observers As %ListOfObjects;

/// Subject state that observers may be interested in
Property State As %String;

/// Initialize the subject with empty observer list
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Observers = ##class(%Library.ListOfObjects).%New()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Attach an observer to this subject
Method Attach(pObserver As Patterns.GoF.Behavioral.Observer.Observer) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$IsObject(pObserver) {
            Set tSC = $$$ERROR($$$GeneralError, "Observer parameter must be a valid object")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Validate that the object is actually an Observer
        If 'pObserver.%IsA("Patterns.GoF.Behavioral.Observer.Observer") {
            Set tSC = $$$ERROR($$$GeneralError, "Object must be an instance of Observer")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        For i=1:1:..Observers.Count() {
            If ..Observers.GetAt(i) = pObserver {
                Quit
            }
        }
        
        Set tSC = ..Observers.Insert(pObserver)
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Detach an observer from this subject
Method Detach(pObserver As Patterns.GoF.Behavioral.Observer.Observer) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$IsObject(pObserver) {
            Set tSC = $$$ERROR($$$GeneralError, "Observer parameter must be a valid object")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        For i=1:1:..Observers.Count() {
            If ..Observers.GetAt(i) = pObserver {
                Do ..Observers.RemoveAt(i)
                Quit
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Notify all attached observers of a state change
Method Notify(pData As %String = "") As %Status
{
    Set tSC = $$$OK
    Set errorOccurred = 0
    Set errorMessages = ""
    
    Try {
        For i=1:1:..Observers.Count() {
            Set observer = ..Observers.GetAt(i)
            If $IsObject(observer) {
                Try {
                    Set notifyStatus = observer.Update($this, pData)
                    If $$$ISERR(notifyStatus) {
                        Set errorOccurred = 1
                        Set errorMessages = errorMessages _ " Observer " _ i _ ": " _ $System.Status.GetErrorText(notifyStatus) _ ";"
                    }
                }
                Catch notifyEx {
                    Set errorOccurred = 1
                    Set errorMessages = errorMessages _ " Observer " _ i _ ": " _ notifyEx.Name _ ";"
                }
            }
        }
        
        If errorOccurred {
            Set tSC = $$$ERROR($$$GeneralError, "Some observers failed to update:" _ errorMessages)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Set the state and optionally notify observers
Method SetState(pNewState As %String, pNotify As %Boolean = 1) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..State = pNewState
        
        If pNotify {
            Set tSC = ..Notify(pNewState)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get the current state
Method GetState() As %String
{
    Quit ..State
}

/// Get the count of attached observers
Method GetObserverCount() As %Integer
{
    Quit ..Observers.Count()
}

}
