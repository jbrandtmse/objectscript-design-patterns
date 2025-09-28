/// Gang of Four State Pattern - Context Class
/// 
/// Purpose:
/// Maintains an instance of a ConcreteState subclass that defines the current state.
/// Defines the interface of interest to clients and maintains a reference to the current state object.
/// 
/// Responsibilities:
/// - Delegates state-specific requests to the current State object
/// - Allows State objects to change the current state
/// - Maintains state history for tracking and debugging
/// - Handles state persistence and restoration
/// 
/// Collaborations:
/// - Context delegates state-specific requests to the current State object
/// - Context may pass itself as an argument to State objects
/// - Either Context or State subclasses can decide which state succeeds another
/// 
/// <example>
/// Set context = ##class(Patterns.GoF.Behavioral.StateContext).%New()
/// Set initialState = ##class(ConcreteStateA).%New()
/// Do context.TransitionTo(initialState)
/// Set response = context.Request("process")
/// </example>
Class Patterns.GoF.Behavioral.StateContext Extends %RegisteredObject
{

// ===== PROPERTIES =====

/// Current state instance
Property CurrentState As Patterns.GoF.Behavioral.State;

/// Previous state for rollback capability
Property PreviousState As Patterns.GoF.Behavioral.State;

/// State history for tracking
Property StateHistory As list Of %String;

/// Timestamp of last state change
Property LastTransitionTime As %String;

/// Count of total transitions
Property TransitionCount As %Integer [ InitialExpression = 0 ];

/// Maximum history size (0 = unlimited)
Property MaxHistorySize As %Integer [ InitialExpression = 100 ];

/// Enable state transition logging
Property EnableLogging As %Boolean [ InitialExpression = 0 ];

/// State-specific data storage
Property StateData [ MultiDimensional ];

/// Timeout duration in seconds (0 = no timeout)
Property TimeoutDuration As %Integer [ InitialExpression = 0 ];

/// Last timeout check timestamp
Property LastTimeoutCheck As %String;

// ===== CONSTRUCTOR =====

/// Initialize the state context
Method %OnNew(pInitialState As Patterns.GoF.Behavioral.State = "") As %Status
{
    Set tSC = $$$OK
    
    // Initialize timestamps as strings
    Set ..LastTransitionTime = $ZDATETIME($HOROLOG, 3)
    Set ..LastTimeoutCheck = ..LastTransitionTime
    
    // Set initial state if provided
    If $IsObject(pInitialState) {
        Set tSC = ..TransitionTo(pInitialState)
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Transition to a new state
/// 
/// @param pNewState The new state to transition to
/// @return %Status indicating success or failure
Method TransitionTo(pNewState As Patterns.GoF.Behavioral.State) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate new state
        If '$IsObject(pNewState) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid state object")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Check guard conditions
        If $IsObject(..CurrentState) {
            If '..CurrentState.CanTransitionTo(pNewState) {
                Set tSC = $$$ERROR($$$GeneralError, "Transition not allowed from " _ ..CurrentState.GetStateName() _ " to " _ pNewState.GetStateName())
                Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
            }
            
            // Exit current state
            Set tSC = ..CurrentState.OnExit($this)
            If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
            
            // Save as previous state
            Set ..PreviousState = ..CurrentState
        }
        
        // Record in history
        Do ..RecordTransition(pNewState.GetStateName())
        
        // Enter new state
        Set ..CurrentState = pNewState
        Set tSC = pNewState.OnEntry($this)
        If $$$ISERR(tSC) {
            // Rollback on entry failure
            If $IsObject(..PreviousState) {
                Set ..CurrentState = ..PreviousState
                Set ..PreviousState = ""
            }
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Update transition tracking
        Set ..LastTransitionTime = $ZDATETIME($HOROLOG, 3)
        Set ..TransitionCount = ..TransitionCount + 1
        
        // Log transition if enabled
        If ..EnableLogging {
            Do ..LogTransition(pNewState.GetStateName())
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Delegate request to current state
/// 
/// @param pRequest The request to handle
/// @return Response from the current state
Method Request(pRequest As %String)
{
    Set tResponse = ""
    
    // Check for timeout first
    Do ..CheckTimeout()
    
    If $IsObject(..CurrentState) {
        Set tResponse = ..CurrentState.Handle($this, pRequest)
    } Else {
        Set tResponse = "No state set"
    }
    
    Quit tResponse
}

/// Get the current state name
/// 
/// @return %String The name of the current state
Method GetCurrentStateName() As %String
{
    If $IsObject(..CurrentState) {
        Quit ..CurrentState.GetStateName()
    }
    Quit ""
}

/// Rollback to previous state
/// 
/// @return %Status indicating success or failure
Method RollbackToPreviousState() As %Status
{
    Set tSC = $$$OK
    
    If '$IsObject(..PreviousState) {
        Quit $$$ERROR($$$GeneralError, "No previous state to rollback to")
    }
    
    Set tSC = ..TransitionTo(..PreviousState)
    
    Quit tSC
}

/// Reset state machine to initial state
/// 
/// @param pInitialState The initial state to reset to
/// @return %Status indicating success or failure
Method Reset(pInitialState As Patterns.GoF.Behavioral.State) As %Status
{
    Set tSC = $$$OK
    
    // Clear history
    Do ..StateHistory.Clear()
    
    // Clear state data
    Kill ..StateData
    
    // Reset counters
    Set ..TransitionCount = 0
    Set ..PreviousState = ""
    Set ..CurrentState = ""
    
    // Set initial state
    If $IsObject(pInitialState) {
        Set tSC = ..TransitionTo(pInitialState)
    }
    
    Quit tSC
}

/// Get state history as a string
/// 
/// @param pDelimiter The delimiter to use (default: " -> ")
/// @return %String The state history
Method GetHistoryString(pDelimiter As %String = " -> ") As %String
{
    Set tHistory = ""
    Set tCount = ..StateHistory.Count()
    
    For i = 1:1:tCount {
        If tHistory '= "" {
            Set tHistory = tHistory _ pDelimiter
        }
        Set tHistory = tHistory _ ..StateHistory.GetAt(i)
    }
    
    Quit tHistory
}

/// Save state to persistent storage
/// 
/// @param pKey The storage key
/// @return %Status indicating success or failure
Method SaveState(pKey As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Save current state name
        Set ^Patterns.State.Saved(pKey, "CurrentState") = ..GetCurrentStateName()
        
        // Save transition count
        Set ^Patterns.State.Saved(pKey, "TransitionCount") = ..TransitionCount
        
        // Save history
        Set tHistoryCount = ..StateHistory.Count()
        Set ^Patterns.State.Saved(pKey, "HistoryCount") = tHistoryCount
        For i = 1:1:tHistoryCount {
            Set ^Patterns.State.Saved(pKey, "History", i) = ..StateHistory.GetAt(i)
        }
        
        // Save state data
        Merge ^Patterns.State.Saved(pKey, "Data") = ..StateData
        
        // Save timestamp
        Set ^Patterns.State.Saved(pKey, "SavedAt") = $ZDATETIME($HOROLOG, 3)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Load state from persistent storage
/// 
/// @param pKey The storage key
/// @return %Status indicating success or failure
Method LoadState(pKey As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if saved state exists
        If '$DATA(^Patterns.State.Saved(pKey)) {
            Set tSC = $$$ERROR($$$GeneralError, "No saved state found for key: " _ pKey)
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Clear current state
        Do ..StateHistory.Clear()
        Kill ..StateData
        
        // Load transition count
        Set ..TransitionCount = $GET(^Patterns.State.Saved(pKey, "TransitionCount"), 0)
        
        // Load history
        Set tHistoryCount = $GET(^Patterns.State.Saved(pKey, "HistoryCount"), 0)
        For i = 1:1:tHistoryCount {
            Do ..StateHistory.Insert($GET(^Patterns.State.Saved(pKey, "History", i)))
        }
        
        // Load state data
        Merge ..StateData = ^Patterns.State.Saved(pKey, "Data")
        
        // Note: Current state must be recreated by the caller based on the saved state name
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PRIVATE METHODS =====

/// Record state transition in history
/// 
/// @param pStateName The name of the state being transitioned to
Method RecordTransition(pStateName As %String) [ Private ]
{
    // Add to history
    Do ..StateHistory.Insert(pStateName)
    
    // Trim history if needed
    If (..MaxHistorySize > 0) && (..StateHistory.Count() > ..MaxHistorySize) {
        Do ..StateHistory.RemoveAt(1)
    }
}

/// Log state transition
/// 
/// @param pStateName The name of the new state
Method LogTransition(pStateName As %String) [ Private ]
{
    Set tPrevState = ""
    If $IsObject(..PreviousState) {
        Set tPrevState = ..PreviousState.GetStateName()
    }
    
    Set tLogEntry = $ZDATETIME($HOROLOG, 3) _ " | Transition from [" _ tPrevState _ "] to [" _ pStateName _ "]"
    
    // Log to global
    Set tLogKey = $INCREMENT(^Patterns.State.TransitionLog)
    Set ^Patterns.State.TransitionLog(tLogKey) = tLogEntry
}

/// Check for timeout and handle if needed
Method CheckTimeout() [ Private ]
{
    // Skip if no timeout configured
    If ..TimeoutDuration <= 0 Quit
    
    // Skip if no current state
    If '$IsObject(..CurrentState) Quit
    
    // Skip if LastTransitionTime is empty
    If ..LastTransitionTime = "" Quit
    
    // Calculate elapsed time
    Set tCurrentTime = $HOROLOG
    
    Try {
        // Parse the LastTransitionTime timestamp string
        Set tLastTime = $ZDATETIMEH(..LastTransitionTime, 3)
        
        // Calculate elapsed seconds
        Set tElapsedSeconds = ($PIECE(tCurrentTime, ",", 1) - $PIECE(tLastTime, ",", 1)) * 86400
        Set tElapsedSeconds = tElapsedSeconds + ($PIECE(tCurrentTime, ",", 2) - $PIECE(tLastTime, ",", 2))
        
        // Check if timeout exceeded
        If tElapsedSeconds >= ..TimeoutDuration {
            // Call timeout handler
            Do ..CurrentState.OnTimeout($this)
            
            // Update last check time
            Set ..LastTimeoutCheck = $ZDATETIME(tCurrentTime, 3)
        }
    } Catch ex {
        // If any error in parsing timestamps, skip timeout check
        Quit
    }
}

/// Validate current state consistency
/// 
/// @return %Status indicating if state is valid
Method ValidateState() As %Status
{
    Set tSC = $$$OK
    
    If $IsObject(..CurrentState) {
        Set tSC = ..CurrentState.ValidateState($this)
    }
    
    Quit tSC
}

}
