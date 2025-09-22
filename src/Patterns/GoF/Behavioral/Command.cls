/// Gang of Four Command Pattern - Abstract Base Class
/// 
/// Intent:
/// Encapsulate a request as an object, thereby letting you parameterize clients with different
/// requests, queue or log requests, and support undoable operations.
/// 
/// Motivation:
/// The Command pattern turns a request into a stand-alone object containing all information
/// about the request. This transformation lets you parameterize methods with different requests,
/// delay or queue a request's execution, and support undoable operations.
/// 
/// Applicability:
/// Use the Command pattern when you want to:
/// - Parameterize objects with operations
/// - Queue operations, schedule their execution, or execute them remotely
/// - Implement reversible operations (undo/redo)
/// - Structure a system around high-level operations built on primitive operations
/// 
/// Structure:
/// <example>
/// // Create receiver
/// Set receiver = ##class(MyReceiver).%New()
/// 
/// // Create command with receiver
/// Set command = ##class(ConcreteCommand).%New(receiver)
/// 
/// // Create invoker and execute
/// Set invoker = ##class(CommandInvoker).%New()
/// Do invoker.ExecuteCommand(command)
/// 
/// // Undo last command
/// Do invoker.UndoLastCommand()
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.CommandInvoker
/// @see Patterns.GoF.Behavioral.Receiver
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Command Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// Pattern type for registry
Parameter PATTERNTYPE = "Behavioral";

/// Pattern name for identification
Parameter PATTERNNAME = "Command";

/// Version of the implementation
Parameter VERSION = "1.0.0";

// ===== PROPERTIES =====

/// Reference to the receiver object that performs the actual work
Property Receiver As Receiver;

/// Dynamic object containing command parameters
Property Parameters As %DynamicObject;

/// Timestamp of when the command was executed
Property ExecutedAt As %TimeStamp;

/// Previous state captured before execution for undo support
Property PreviousState As %DynamicObject;

/// Current state captured after execution for redo support
Property CurrentState As %DynamicObject;

/// Indicates whether the command has been executed
Property IsExecuted As %Boolean [ InitialExpression = 0 ];

/// Indicates whether the command can be undone
Property IsUndoable As %Boolean [ InitialExpression = 1 ];

/// Command description for logging and display
Property Description As %String(MAXLEN = 500);

/// Unique identifier for the command
Property CommandId As %String [ InitialExpression = {$ZCONVERT($SYSTEM.Util.CreateGUID(), "L")} ];

// ===== CONSTRUCTORS/DESTRUCTORS =====

/// Constructor - Initialize command with optional receiver and parameters
/// 
/// @param pReceiver The receiver object that will perform the action
/// @param pParameters JSON string or DynamicObject with command parameters
/// @return Status code
Method %OnNew(pReceiver As Receiver = "", pParameters As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Set receiver if provided
        If $ISOBJECT(pReceiver) {
            Set ..Receiver = pReceiver
        }
        
        // Set parameters if provided
        If $ISOBJECT(pParameters) {
            Set ..Parameters = pParameters
        } ElseIf pParameters '= "" {
            // If string, try to parse as JSON
            Set ..Parameters = {}.%FromJSON(pParameters)
        } Else {
            Set ..Parameters = {}
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Execute the command
/// Must be implemented by concrete command classes
/// 
/// @return Status code indicating success or failure
Method Execute() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Undo the command, reverting to previous state
/// Must be implemented by concrete command classes
/// 
/// @return Status code indicating success or failure
Method Undo() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Check if the command can be executed in the current context
/// Can be overridden by concrete commands for custom validation
/// 
/// @return Boolean indicating if command can execute
Method CanExecute() As %Boolean
{
    // Default implementation - check basic prerequisites
    If '..IsExecuted {
        // Not yet executed - check if we have a receiver
        If $ISOBJECT(..Receiver) {
            Quit 1
        }
        // No receiver - cannot execute
        Quit 0
    }
    
    // Already executed - cannot execute again
    Quit 0
}

/// Check if the command can be undone in the current state
/// 
/// @return Boolean indicating if command can be undone
Method CanUndo() As %Boolean
{
    // Check if command is undoable and has been executed
    If ..IsUndoable && ..IsExecuted {
        // Check if we have previous state saved
        If $ISOBJECT(..PreviousState) {
            Quit 1
        }
    }
    
    Quit 0
}

/// Capture the current state before execution
/// Should be called before Execute() to enable undo
/// 
/// @return Status code
Method CaptureState() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $ISOBJECT(..Receiver) {
            // Ask receiver for its current state
            If ##class(%Dictionary.CompiledMethod).%ExistsId(..Receiver.%ClassName(1)_"||GetState") {
                Set ..PreviousState = ..Receiver.GetState()
            } Else {
                // Receiver doesn't support state capture
                Set ..PreviousState = {}
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Save the state after execution
/// Should be called after successful Execute()
/// 
/// @return Status code
Method SaveCurrentState() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $ISOBJECT(..Receiver) {
            // Ask receiver for its current state after execution
            If ##class(%Dictionary.CompiledMethod).%ExistsId(..Receiver.%ClassName(1)_"||GetState") {
                Set ..CurrentState = ..Receiver.GetState()
            }
        }
        
        // Mark as executed and set timestamp
        Set ..IsExecuted = 1
        Set ..ExecutedAt = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clone the command for replay or history
/// Creates a new instance with the same parameters
/// 
/// @return New command instance or empty string on error
Method Clone() As Command
{
    Set tClone = ""
    
    Try {
        // Create new instance of the same class
        Set tClone = $CLASSMETHOD(..%ClassName(1), "%New", ..Receiver, ..Parameters)
        
        // Copy additional properties
        Set tClone.Description = ..Description
        Set tClone.IsUndoable = ..IsUndoable
        
    } Catch ex {
        Set tClone = ""
    }
    
    Quit tClone
}

/// Get a string representation of the command
/// Useful for logging and debugging
/// 
/// @return String description of the command
Method ToString() As %String
{
    Set tString = ..%ClassName(1) _ " [ID: " _ ..CommandId _ "]"
    
    If ..Description '= "" {
        Set tString = tString _ " - " _ ..Description
    }
    
    If ..IsExecuted {
        Set tString = tString _ " (Executed: " _ ..ExecutedAt _ ")"
    } Else {
        Set tString = tString _ " (Not executed)"
    }
    
    Quit tString
}

/// Validate the command parameters
/// Can be overridden by concrete commands for specific validation
/// 
/// @return Status code
Method ValidateParameters() As %Status
{
    Set tSC = $$$OK
    
    // Default implementation - just check that parameters exist
    If '$ISOBJECT(..Parameters) {
        Set tSC = $$$ERROR($$$GeneralError, "No parameters set for command")
    }
    
    Quit tSC
}

// ===== CLASS METHODS =====

/// Get pattern metadata for registry
/// 
/// @return Dynamic object with pattern information
ClassMethod GetPatternInfo() As %DynamicObject
{
    Set tInfo = {}
    Set tInfo.type = ..#PATTERNTYPE
    Set tInfo.name = ..#PATTERNNAME
    Set tInfo.version = ..#VERSION
    Set tInfo.class = $CLASSNAME()
    Set tInfo.abstract = 1
    
    Quit tInfo
}

}
