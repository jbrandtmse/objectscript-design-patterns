/// Gang of Four Command Pattern - Command Invoker
/// 
/// Purpose:
/// The CommandInvoker acts as the controller that invokes commands, manages command history,
/// and provides undo/redo functionality. It decouples the sender of a request from its receiver.
/// 
/// Responsibilities:
/// - Execute commands through a uniform interface
/// - Maintain command history for undo/redo operations
/// - Support command batching and macro commands
/// - Manage command queues for deferred execution
/// - Provide transaction-like command grouping
/// 
/// Usage:
/// <example>
/// // Create invoker
/// Set invoker = ##class(CommandInvoker).%New()
/// 
/// // Execute a command
/// Set command = ##class(MyCommand).%New(receiver)
/// Set status = invoker.ExecuteCommand(command)
/// 
/// // Undo last command
/// Set status = invoker.UndoLastCommand()
/// 
/// // Redo last undone command
/// Set status = invoker.RedoLastCommand()
/// 
/// // Execute batch of commands
/// Do invoker.BeginBatch()
/// Do invoker.ExecuteCommand(command1)
/// Do invoker.ExecuteCommand(command2)
/// Set status = invoker.EndBatch()
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Command
/// @since 1.0.0
Class Patterns.GoF.Behavioral.CommandInvoker Extends %RegisteredObject
{

// ===== PARAMETERS =====

/// Maximum number of commands to keep in history
Parameter MAXHISTORYSIZE = 100;

/// Default timeout for command execution (seconds)
Parameter DEFAULTTIMEOUT = 30;

// ===== PROPERTIES =====

/// Stack of executed commands for undo support
Property UndoStack As list Of Command;

/// Stack of undone commands for redo support
Property RedoStack As list Of Command;

/// Queue of commands waiting to be executed
Property CommandQueue As list Of Command;

/// Currently executing batch of commands
Property CurrentBatch As list Of Command;

/// Flag indicating if we're in batch mode
Property InBatchMode As %Boolean [ InitialExpression = 0 ];

/// Flag to enable/disable command history
Property HistoryEnabled As %Boolean [ InitialExpression = 1 ];

/// Current history size
Property HistorySize As %Integer [ InitialExpression = 0 ];

/// Maximum history size (configurable)
Property MaxHistorySize As %Integer [ InitialExpression = {..#MAXHISTORYSIZE} ];

/// Flag to enable command logging
Property LoggingEnabled As %Boolean [ InitialExpression = 1 ];

/// Transaction ID for grouped commands
Property TransactionId As %String;

// ===== CONSTRUCTORS/DESTRUCTORS =====

/// Constructor - Initialize the invoker
/// 
/// @param pMaxHistorySize Maximum number of commands to keep in history
/// @return Status code
Method %OnNew(pMaxHistorySize As %Integer = {..#MAXHISTORYSIZE}) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize properties
        Set ..MaxHistorySize = pMaxHistorySize
        Set ..HistorySize = 0
        Set ..InBatchMode = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Execute a command
/// 
/// @param pCommand The command to execute
/// @return Status code
Method ExecuteCommand(pCommand As Command) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate command
        If '$ISOBJECT(pCommand) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid command object")
            Quit
        }
        
        // Check if command can execute
        If 'pCommand.CanExecute() {
            Set tSC = $$$ERROR($$$GeneralError, "Command cannot be executed in current state")
            Quit
        }
        
        // Capture state before execution
        Set tSC = pCommand.CaptureState()
        If $$$ISERR(tSC) Quit
        
        // Execute the command
        Set tSC = pCommand.Execute()
        If $$$ISERR(tSC) {
            // Execution failed - don't add to history
            Quit
        }
        
        // Save state after execution
        Set tSC = pCommand.SaveCurrentState()
        If $$$ISERR(tSC) Quit
        
        // If in batch mode, add to current batch
        If ..InBatchMode {
            Do ..CurrentBatch.Insert(pCommand)
        } Else {
            // Add to undo stack if history is enabled
            If ..HistoryEnabled {
                Do ..AddToUndoStack(pCommand)
                // Clear redo stack when new command is executed
                Do ..RedoStack.Clear()
            }
        }
        
        // Log command execution
        If ..LoggingEnabled {
            Do ..LogCommandExecution(pCommand, "EXECUTED")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        If ..LoggingEnabled {
            Do ..LogCommandExecution(pCommand, "FAILED: " _ ex.Name)
        }
    }
    
    Quit tSC
}

/// Undo the last executed command
/// 
/// @return Status code
Method UndoLastCommand() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if there are commands to undo
        If ..UndoStack.Count() = 0 {
            Set tSC = $$$ERROR($$$GeneralError, "No commands to undo")
            Quit
        }
        
        // Get last command from undo stack
        Set tCommand = ..UndoStack.GetAt(..UndoStack.Count())
        
        // Check if command can be undone
        If 'tCommand.CanUndo() {
            Set tSC = $$$ERROR($$$GeneralError, "Command cannot be undone")
            Quit
        }
        
        // Undo the command
        Set tSC = tCommand.Undo()
        If $$$ISERR(tSC) Quit
        
        // Move from undo to redo stack
        Do ..UndoStack.RemoveAt(..UndoStack.Count())
        Do ..RedoStack.Insert(tCommand)
        Set ..HistorySize = ..HistorySize - 1
        
        // Log undo operation
        If ..LoggingEnabled {
            Do ..LogCommandExecution(tCommand, "UNDONE")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Redo the last undone command
/// 
/// @return Status code
Method RedoLastCommand() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if there are commands to redo
        If ..RedoStack.Count() = 0 {
            Set tSC = $$$ERROR($$$GeneralError, "No commands to redo")
            Quit
        }
        
        // Get last command from redo stack
        Set tCommand = ..RedoStack.GetAt(..RedoStack.Count())
        
        // Check if command can execute
        If 'tCommand.CanExecute() {
            Set tSC = $$$ERROR($$$GeneralError, "Command cannot be re-executed")
            Quit
        }
        
        // Re-execute the command
        Set tSC = tCommand.Execute()
        If $$$ISERR(tSC) Quit
        
        // Move from redo to undo stack
        Do ..RedoStack.RemoveAt(..RedoStack.Count())
        Do ..AddToUndoStack(tCommand)
        
        // Log redo operation
        If ..LoggingEnabled {
            Do ..LogCommandExecution(tCommand, "REDONE")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Begin a batch of commands (macro)
/// Commands executed while in batch mode are grouped together
/// 
/// @param pDescription Description of the batch operation
/// @return Status code
Method BeginBatch(pDescription As %String = "Batch Command") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..InBatchMode {
            Set tSC = $$$ERROR($$$GeneralError, "Already in batch mode")
            Quit
        }
        
        // Enter batch mode
        Set ..InBatchMode = 1
        Do ..CurrentBatch.Clear()
        
        // Generate transaction ID for this batch
        Set ..TransactionId = $ZCONVERT($SYSTEM.Util.CreateGUID(), "L")
        
        // Logging disabled - Logger class not available
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// End the current batch and create a composite command
/// 
/// @return Status code
Method EndBatch() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '..InBatchMode {
            Set tSC = $$$ERROR($$$GeneralError, "Not in batch mode")
            Quit
        }
        
        // Exit batch mode
        Set ..InBatchMode = 0
        
        // Create composite command if we have commands
        If ..CurrentBatch.Count() > 0 {
            Set tComposite = ##class(CompositeCommand).%New()
            Set tComposite.Description = "Batch of " _ ..CurrentBatch.Count() _ " commands"
            
            // Add all commands to composite
            For i = 1:1:..CurrentBatch.Count() {
                Do tComposite.AddCommand(..CurrentBatch.GetAt(i))
            }
            
            // Mark composite as executed since its contained commands are already executed
            Set tComposite.IsExecuted = 1
            Set tComposite.ExecutedAt = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
            Set tComposite.ExecutedCount = ..CurrentBatch.Count()
            
            // Add composite to undo stack
            If ..HistoryEnabled {
                Do ..AddToUndoStack(tComposite)
                Do ..RedoStack.Clear()
            }
        }
        
        // Clear current batch
        Do ..CurrentBatch.Clear()
        Set ..TransactionId = ""
        
        // Logging disabled - Logger class not available
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Cancel the current batch without executing
/// 
/// @return Status code
Method CancelBatch() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '..InBatchMode {
            Set tSC = $$$ERROR($$$GeneralError, "Not in batch mode")
            Quit
        }
        
        // Undo all commands in current batch
        For i = ..CurrentBatch.Count():-1:1 {
            Set tCommand = ..CurrentBatch.GetAt(i)
            If tCommand.IsExecuted && tCommand.CanUndo() {
                Do tCommand.Undo()
            }
        }
        
        // Exit batch mode and clear
        Set ..InBatchMode = 0
        Do ..CurrentBatch.Clear()
        Set ..TransactionId = ""
        
        // Logging disabled - Logger class not available
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Queue a command for later execution
/// 
/// @param pCommand The command to queue
/// @return Status code
Method QueueCommand(pCommand As Command) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '$ISOBJECT(pCommand) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid command object")
            Quit
        }
        
        // Add to command queue
        Do ..CommandQueue.Insert(pCommand)
        
        If ..LoggingEnabled {
            Do ..LogCommandExecution(pCommand, "QUEUED")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Execute all queued commands
/// 
/// @return Status code
Method ExecuteQueuedCommands() As %Status
{
    Set tSC = $$$OK
    Set tExecutedCount = 0
    
    Try {
        While ..CommandQueue.Count() > 0 {
            Set tCommand = ..CommandQueue.GetAt(1)
            Do ..CommandQueue.RemoveAt(1)
            
            // Execute the command
            Set tSC = ..ExecuteCommand(tCommand)
            If $$$ISOK(tSC) {
                Set tExecutedCount = tExecutedCount + 1
            }
        }
        
        // Logging disabled - Logger class not available
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clear all command history
/// 
/// @return Status code
Method ClearHistory() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Do ..UndoStack.Clear()
        Do ..RedoStack.Clear()
        Set ..HistorySize = 0
        
        // Logging disabled - Logger class not available
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the number of commands that can be undone
/// 
/// @return Number of undoable commands
Method GetUndoCount() As %Integer
{
    Quit ..UndoStack.Count()
}

/// Get the number of commands that can be redone
/// 
/// @return Number of redoable commands
Method GetRedoCount() As %Integer
{
    Quit ..RedoStack.Count()
}

/// Check if undo is available
/// 
/// @return Boolean indicating if undo is available
Method CanUndo() As %Boolean
{
    Quit (..UndoStack.Count() > 0)
}

/// Check if redo is available
/// 
/// @return Boolean indicating if redo is available
Method CanRedo() As %Boolean
{
    Quit (..RedoStack.Count() > 0)
}

// ===== PRIVATE METHODS =====

/// Add a command to the undo stack with size management
/// 
/// @param pCommand The command to add
Method AddToUndoStack(pCommand As Command) [ Private ]
{
    // Add to undo stack
    Do ..UndoStack.Insert(pCommand)
    Set ..HistorySize = ..HistorySize + 1
    
    // Manage history size
    While ..HistorySize > ..MaxHistorySize {
        // Remove oldest command
        Do ..UndoStack.RemoveAt(1)
        Set ..HistorySize = ..HistorySize - 1
    }
}

/// Log command execution
/// 
/// @param pCommand The command being logged
/// @param pAction The action performed
Method LogCommandExecution(pCommand As Command, pAction As %String) [ Private ]
{
    // Logging disabled - Logger class not available
    // Would log: pAction _ ": " _ pCommand.ToString()
}

// ===== CLASS METHODS =====

/// Create a global shared invoker instance
/// 
/// @return CommandInvoker instance
ClassMethod GetSharedInvoker() As CommandInvoker
{
    // Use process-private global for shared instance
    If '$DATA(^||Patterns.CommandInvoker) {
        Set ^||Patterns.CommandInvoker = ..%New()
    }
    
    Quit ^||Patterns.CommandInvoker
}

}
