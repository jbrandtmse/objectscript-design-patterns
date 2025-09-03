/// Gang of Four Observer Pattern - Concrete Observer B Implementation
/// 
/// Purpose:
/// Demonstrates a different concrete observer implementation that
/// maintains a history of state changes and can filter notifications.
/// 
/// @see Patterns.GoF.Behavioral.Observer.Observer
/// @see Patterns.GoF.Behavioral.Observer.Subject
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Observer.ConcreteObserverB Extends Patterns.GoF.Behavioral.Observer.Observer
{

// ===== PROPERTIES =====

/// Name of this observer for identification
Property Name As %String;

/// Filter criteria - only react to states containing this text
Property StateFilter As %String;

/// Last processed state
Property LastProcessedState As %String;

/// Count of relevant notifications (matching filter)
Property RelevantNotificationCount As %Integer [ InitialExpression = 0 ];

/// Count of total notifications received
Property TotalNotificationCount As %Integer [ InitialExpression = 0 ];

/// State property for test compatibility 
Property ObserverState As %String;

/// Filter property for test compatibility (alias for StateFilter)
Property Filter As %String;

// ===== CONSTRUCTORS =====

/// Initialize the observer with a name and optional filter
Method %OnNew(pName As %String = "ObserverB", pFilter As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..Name = pName
        Set ..StateFilter = pFilter
        Set ..Filter = pFilter
        Set ..LastProcessedState = ""
        Set ..ObserverState = ""
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Update method with selective processing based on filter
/// 
/// @param pSubject The subject that is notifying this observer
/// @param pData Optional data passed from the subject
/// @return Status of the update operation
Method Update(pSubject As Patterns.GoF.Behavioral.Observer.Subject, pData As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Always increment total count
        Set ..TotalNotificationCount = ..TotalNotificationCount + 1
        
        // Get the subject's current state
        Set currentState = pSubject.GetState()
        
        // Check if this notification is relevant based on our filter
        // Use Filter if set, otherwise fall back to StateFilter
        Set filterToUse = ..Filter
        If filterToUse = "" {
            Set filterToUse = ..StateFilter
        }
        
        Set isRelevant = 0
        If filterToUse = "" {
            // No filter means all notifications are relevant
            Set isRelevant = 1
        } ElseIf currentState [ filterToUse {
            // State contains our filter text
            Set isRelevant = 1
        } ElseIf pData [ filterToUse {
            // Data contains our filter text
            Set isRelevant = 1
        }
        
        // Process only relevant notifications
        If isRelevant {
            Set ..RelevantNotificationCount = ..RelevantNotificationCount + 1
            Set ..LastProcessedState = currentState
            Set ..ObserverState = currentState
            
            // Log the relevant notification
            Write "[", ..Name, "] RELEVANT notification #", ..RelevantNotificationCount, !
            Write "  Filter: '", filterToUse, "'", !
            Write "  Subject state: ", currentState, !
            If pData '= "" {
                Write "  Additional data: ", pData, !
            }
            Write "  Action: Processing state change", !
            Write !
        } Else {
            // Log that we ignored this notification
            Write "[", ..Name, "] Ignored notification (", ..TotalNotificationCount, " total, ", ..RelevantNotificationCount, " relevant)", !
            Write "  Filter '", filterToUse, "' not matched in state '", currentState, "'", !
            Write !
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write "[", ..Name, "] Error during update: ", $System.Status.GetErrorText(tSC), !
    }
    Quit tSC
}

/// Set or change the filter criteria
Method SetFilter(pFilter As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..StateFilter = pFilter
        Set ..Filter = pFilter
        Write "[", ..Name, "] Filter updated to: '", pFilter, "'", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get statistics about notifications
Method GetStatistics() As %String
{
    Quit "Total: " _ ..TotalNotificationCount _ ", Relevant: " _ ..RelevantNotificationCount _ ", Ignored: " _ (..TotalNotificationCount - ..RelevantNotificationCount)
}

/// Get the last processed state
Method GetLastProcessedState() As %String
{
    Quit ..LastProcessedState
}

/// Reset the observer's state
Method Reset() As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..LastProcessedState = ""
        Set ..RelevantNotificationCount = 0
        Set ..TotalNotificationCount = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
