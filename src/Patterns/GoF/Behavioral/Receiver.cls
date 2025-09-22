/// Gang of Four Command Pattern - Receiver Base Class
/// 
/// Purpose:
/// The Receiver knows how to perform the operations associated with carrying out a request.
/// Any class may serve as a Receiver. This base class provides standard interfaces for
/// state management, validation, and operation execution.
/// 
/// Responsibilities:
/// - Maintain object state for undo/redo support
/// - Provide state snapshot mechanism for command pattern
/// - Validate operations before execution
/// - Execute actual business operations
/// - Support state restoration for undo functionality
/// 
/// Usage:
/// <example>
/// // Create a concrete receiver
/// Class MyReceiver Extends Patterns.GoF.Behavioral.Receiver
/// {
///     Property Data As %String;
///     
///     Method SetData(pData As %String) As %Status
///     {
///         Set ..Data = pData
///         Quit $$$OK
///     }
///     
///     Method GetState() As %DynamicObject
///     {
///         Set state = ##super()
///         Set state.data = ..Data
///         Quit state
///     }
///     
///     Method RestoreState(pState As %DynamicObject) As %Status
///     {
///         Set tSC = ##super(pState)
///         If $$$ISOK(tSC) && pState.%IsDefined("data") {
///             Set ..Data = pState.data
///         }
///         Quit tSC
///     }
/// }
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Command
/// @see Patterns.GoF.Behavioral.CommandInvoker
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Receiver Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// Pattern role identifier
Parameter PATTERNROLE = "Receiver";

/// Version of the receiver implementation
Parameter VERSION = "1.0.0";

// ===== PROPERTIES =====

/// Current state version for tracking changes
Property StateVersion As %Integer [ InitialExpression = 0 ];

/// Timestamp of last state change
Property LastModified As %TimeStamp;

/// Flag indicating if receiver is in valid state
Property IsValid As %Boolean [ InitialExpression = 1 ];

/// History of state changes for audit trail
Property StateHistory As list Of %DynamicObject;

/// Maximum number of state history entries to keep
Property MaxHistorySize As %Integer [ InitialExpression = 10 ];

/// Lock for concurrent access control
Property LockId As %String [ InitialExpression = {$ZCONVERT($SYSTEM.Util.CreateGUID(), "L")} ];

/// Flag indicating if state tracking is enabled
Property StateTrackingEnabled As %Boolean [ InitialExpression = 1 ];

// ===== CONSTRUCTORS/DESTRUCTORS =====

/// Constructor - Initialize the receiver
/// 
/// @return Status code
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize properties
        Set ..StateVersion = 0
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        Set ..IsValid = 1
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Get the current state of the receiver as a dynamic object
/// This method should be overridden by concrete receivers to include
/// specific state properties
/// 
/// @return Dynamic object containing current state
Method GetState() As %DynamicObject
{
    Set tState = {}
    
    Try {
        // Base state information
        Set tState.stateVersion = ..StateVersion
        Set tState.lastModified = ..LastModified
        Set tState.isValid = ..IsValid
        Set tState.className = ..%ClassName(1)
        Set tState.timestamp = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Subclasses should call ##super() and add their own state
        
    } Catch ex {
        Set tState = {}
        Set tState.error = ex.Name
    }
    
    Quit tState
}

/// Restore the receiver to a previous state
/// This method should be overridden by concrete receivers to restore
/// specific state properties
/// 
/// @param pState The state to restore
/// @return Status code
Method RestoreState(pState As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate state object
        If '$ISOBJECT(pState) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid state object")
            Quit
        }
        
        // Restore base state information
        If pState.%IsDefined("stateVersion") {
            Set ..StateVersion = pState.stateVersion
        }
        If pState.%IsDefined("lastModified") {
            Set ..LastModified = pState.lastModified
        }
        If pState.%IsDefined("isValid") {
            Set ..IsValid = pState.isValid
        }
        
        // Subclasses should call ##super(pState) and restore their own state
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Create a snapshot of the current state
/// 
/// @return Dynamic object containing state snapshot
Method CreateSnapshot() As %DynamicObject
{
    Set tSnapshot = ..GetState()
    
    // Add snapshot metadata
    Set tSnapshot.snapshotId = $ZCONVERT($SYSTEM.Util.CreateGUID(), "L")
    Set tSnapshot.snapshotTime = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
    
    // Add to history if tracking is enabled
    If ..StateTrackingEnabled {
        Do ..AddToHistory(tSnapshot)
    }
    
    Quit tSnapshot
}

/// Restore from a snapshot
/// 
/// @param pSnapshot The snapshot to restore from
/// @return Status code
Method RestoreFromSnapshot(pSnapshot As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate snapshot
        If '$ISOBJECT(pSnapshot) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid snapshot object")
            Quit
        }
        
        If 'pSnapshot.%IsDefined("snapshotId") {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid snapshot - missing snapshot ID")
            Quit
        }
        
        // Restore the state
        Set tSC = ..RestoreState(pSnapshot)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate that an operation can be performed
/// This method should be overridden by concrete receivers
/// 
/// @param pOperation The operation to validate
/// @param pParameters Parameters for the operation
/// @return Boolean indicating if operation is valid
Method ValidateOperation(pOperation As %String, pParameters As %DynamicObject = "") As %Boolean
{
    // Default implementation - check basic validity
    If '..IsValid {
        Quit 0
    }
    
    If pOperation = "" {
        Quit 0
    }
    
    // Subclasses should override for specific validation
    Quit 1
}

/// Execute an operation on the receiver
/// This method should be overridden by concrete receivers
/// 
/// @param pOperation The operation to execute
/// @param pParameters Parameters for the operation
/// @return Status code
Method ExecuteOperation(pOperation As %String, pParameters As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate operation first
        If '..ValidateOperation(pOperation, pParameters) {
            Set tSC = $$$ERROR($$$GeneralError, "Operation validation failed: " _ pOperation)
            Quit
        }
        
        // Update state version and timestamp
        Set ..StateVersion = ..StateVersion + 1
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
        // Subclasses should override to perform actual operations
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Mark the receiver as invalid
/// 
/// @param pReason Reason for invalidation
/// @return Status code
Method Invalidate(pReason As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..IsValid = 0
        
        // Log the invalidation
        If pReason '= "" {
            Do ##class(Patterns.Utils.Logger).LogWarning($CLASSNAME(),
                "Invalidate", "Receiver invalidated: " _ pReason)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Reset the receiver to initial state
/// This method should be overridden by concrete receivers
/// 
/// @return Status code
Method Reset() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Reset base properties
        Set ..StateVersion = 0
        Set ..LastModified = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        Set ..IsValid = 1
        Do ..StateHistory.Clear()
        
        // Subclasses should override to reset specific state
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Lock the receiver for exclusive access
/// 
/// @param pTimeout Timeout in seconds
/// @return Boolean indicating if lock was acquired
Method Lock(pTimeout As %Integer = 5) As %Boolean
{
    // Use IRIS lock mechanism
    Lock +^Patterns.Receiver.Lock(..LockId):pTimeout
    
    Quit $TEST
}

/// Unlock the receiver
/// 
/// @return Status code
Method Unlock() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Lock -^Patterns.Receiver.Lock(..LockId)
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check if two states are equal
/// This method should be overridden by concrete receivers
/// 
/// @param pState1 First state to compare
/// @param pState2 Second state to compare
/// @return Boolean indicating if states are equal
Method StatesEqual(pState1 As %DynamicObject, pState2 As %DynamicObject) As %Boolean
{
    // Basic comparison - check state versions
    If '$ISOBJECT(pState1) || '$ISOBJECT(pState2) {
        Quit 0
    }
    
    If pState1.%IsDefined("stateVersion") && pState2.%IsDefined("stateVersion") {
        If pState1.stateVersion '= pState2.stateVersion {
            Quit 0
        }
    }
    
    // Subclasses should override for detailed comparison
    Quit 1
}

// ===== PRIVATE METHODS =====

/// Add a state to the history
/// 
/// @param pState State to add to history
Method AddToHistory(pState As %DynamicObject) [ Private ]
{
    // Add to history
    Do ..StateHistory.Insert(pState)
    
    // Manage history size
    While ..StateHistory.Count() > ..MaxHistorySize {
        Do ..StateHistory.RemoveAt(1)
    }
}

// ===== CLASS METHODS =====

/// Create a receiver with initial state
/// 
/// @param pInitialState Initial state for the receiver
/// @return New receiver instance
ClassMethod CreateWithState(pInitialState As %DynamicObject) As Receiver
{
    Set tReceiver = ..%New()
    
    If $ISOBJECT(pInitialState) {
        Do tReceiver.RestoreState(pInitialState)
    }
    
    Quit tReceiver
}

/// Get metadata about the receiver pattern role
/// 
/// @return Dynamic object with receiver information
ClassMethod GetReceiverInfo() As %DynamicObject
{
    Set tInfo = {}
    Set tInfo.role = ..#PATTERNROLE
    Set tInfo.version = ..#VERSION
    Set tInfo.class = $CLASSNAME()
    Set tInfo.abstract = 1
    Set tInfo.purpose = "Knows how to perform operations associated with carrying out a request"
    
    Quit tInfo
}

}
