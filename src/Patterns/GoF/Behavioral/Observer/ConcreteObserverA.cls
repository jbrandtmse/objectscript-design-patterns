/// Gang of Four Observer Pattern - Concrete Observer A Implementation
/// 
/// Purpose:
/// Demonstrates a concrete observer that logs all notifications
/// and maintains its own state synchronized with the subject.
/// 
/// @see Patterns.GoF.Behavioral.Observer.Observer
/// @see Patterns.GoF.Behavioral.Observer.Subject
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Observer.ConcreteObserverA Extends Patterns.GoF.Behavioral.Observer.Observer
{

// ===== PROPERTIES =====

/// Name of this observer for identification
Property Name As %String;

/// Local copy of observed state  
Property ObservedState As %String;

/// State property for test compatibility
Property ObserverState As %String;

/// Count of notifications received
Property NotificationCount As %Integer [ InitialExpression = 0 ];

// ===== CONSTRUCTORS =====

/// Initialize the observer with a name
Method %OnNew(pName As %String = "ObserverA") As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Name = pName
        Set ..ObservedState = ""
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Update method called when subject notifies observers
/// 
/// @param pSubject The subject that is notifying this observer
/// @param pData Optional data passed from the subject
/// @return Status of the update operation
Method Update(pSubject As Patterns.GoF.Behavioral.Observer.Subject, pData As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Increment notification count
        Set ..NotificationCount = ..NotificationCount + 1
        
        // Query the subject for its current state
        Set newState = pSubject.GetState()
        
        // Update our local state copy
        Set ..ObservedState = newState
        Set ..ObserverState = newState
        
        // Log the notification (in production, this would go to a proper logger)
        Write "[", ..Name, "] Notification #", ..NotificationCount, " received", !
        Write "  Subject state: ", newState, !
        If pData '= "" {
            Write "  Additional data: ", pData, !
        }
        Write "  Observer state updated to: ", ..ObservedState, !
        Write !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write "[", ..Name, "] Error during update: ", $System.Status.GetErrorText(tSC), !
    }
    Quit tSC
}

/// Get the current observed state
Method GetObservedState() As %String
{
    Quit ..ObservedState
}

/// Get the notification count
Method GetNotificationCount() As %Integer
{
    Quit ..NotificationCount
}

/// Reset the observer's state
Method Reset() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..ObservedState = ""
        Set ..NotificationCount = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
