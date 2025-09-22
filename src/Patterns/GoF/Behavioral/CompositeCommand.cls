/// Gang of Four Command Pattern - Composite Command Implementation
/// 
/// Purpose:
/// CompositeCommand represents a macro command that groups multiple commands together.
/// It allows executing, undoing, and redoing a batch of commands as a single unit.
/// 
/// Responsibilities:
/// - Manage a collection of commands
/// - Execute all commands in sequence
/// - Support atomic undo/redo of the entire batch
/// - Provide transactional semantics for grouped operations
/// 
/// Usage:
/// <example>
/// // Create composite command
/// Set composite = ##class(CompositeCommand).%New()
/// Set composite.Description = "Complex Operation"
/// 
/// // Add individual commands
/// Do composite.AddCommand(command1)
/// Do composite.AddCommand(command2)
/// Do composite.AddCommand(command3)
/// 
/// // Execute all commands
/// Set status = composite.Execute()
/// 
/// // Undo all commands in reverse order
/// Set status = composite.Undo()
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Command
/// @see Patterns.GoF.Behavioral.CommandInvoker
/// @since 1.0.0
Class Patterns.GoF.Behavioral.CompositeCommand Extends Command
{

// ===== PROPERTIES =====

/// Collection of commands in this composite
Property Commands As list Of Command;

/// Number of commands successfully executed
Property ExecutedCount As %Integer [ InitialExpression = 0 ];

/// Flag indicating if all commands should be treated as atomic
Property IsAtomic As %Boolean [ InitialExpression = 1 ];

/// Flag to stop on first error
Property StopOnError As %Boolean [ InitialExpression = 1 ];

// ===== CONSTRUCTORS/DESTRUCTORS =====

/// Constructor - Initialize the composite command
/// 
/// @param pReceiver The receiver object (optional for composite)
/// @param pParameters Parameters for the composite command
/// @return Status code
Method %OnNew(pReceiver As Receiver = "", pParameters As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Call parent constructor
        Set tSC = ##super(pReceiver, pParameters)
        If $$$ISERR(tSC) Quit
        
        // Initialize properties
        If $ISOBJECT(pParameters) && pParameters.%IsDefined("description") {
            Set ..Description = pParameters.description
        } Else {
            Set ..Description = "Composite Command"
        }
        Set ..IsUndoable = 1
        Set ..ExecutedCount = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Add a command to the composite
/// 
/// @param pCommand The command to add
/// @return Status code
Method AddCommand(pCommand As Command) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '$ISOBJECT(pCommand) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid command object")
            Quit
        }
        
        // Add to commands list
        Do ..Commands.Insert(pCommand)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Remove a command from the composite
/// 
/// @param pIndex Index of the command to remove
/// @return Status code
Method RemoveCommand(pIndex As %Integer) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If (pIndex < 1) || (pIndex > ..Commands.Count()) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid command index")
            Quit
        }
        
        Do ..Commands.RemoveAt(pIndex)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Execute all commands in the composite
/// 
/// @return Status code
Method Execute() As %Status
{
    Set tSC = $$$OK
    Set ..ExecutedCount = 0
    
    Try {
        // Check if we can execute
        If ..IsExecuted {
            Set tSC = $$$ERROR($$$GeneralError, "Composite command already executed")
            Quit
        }
        
        If ..Commands.Count() = 0 {
            Set tSC = $$$ERROR($$$GeneralError, "No commands in composite")
            Quit
        }
        
        // Capture initial state
        Set tSC = ..CaptureState()
        If $$$ISERR(tSC) Quit
        
        // Execute each command
        For i = 1:1:..Commands.Count() {
            Set tCommand = ..Commands.GetAt(i)
            
            // Check if command can execute
            If 'tCommand.CanExecute() {
                If ..StopOnError {
                    Set tSC = $$$ERROR($$$GeneralError, "Command " _ i _ " cannot execute: " _ tCommand.Description)
                    // Rollback if atomic
                    If ..IsAtomic {
                        Do ..RollbackExecuted()
                    }
                    Quit
                }
                Continue
            }
            
            // Capture state and execute
            Set tSC = tCommand.CaptureState()
            If $$$ISERR(tSC) && ..StopOnError {
                If ..IsAtomic {
                    Do ..RollbackExecuted()
                }
                Quit
            }
            
            Set tSC = tCommand.Execute()
            If $$$ISERR(tSC) {
                If ..StopOnError {
                    // Rollback if atomic
                    If ..IsAtomic {
                        Do ..RollbackExecuted()
                    }
                    Quit
                }
            } Else {
                Set tSC = tCommand.SaveCurrentState()
                Set ..ExecutedCount = ..ExecutedCount + 1
            }
        }
        
        // Mark as executed if we executed at least one command
        If ..ExecutedCount > 0 {
            Set ..IsExecuted = 1
            Set ..ExecutedAt = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
            Set tSC = ..SaveCurrentState()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        If ..IsAtomic {
            Do ..RollbackExecuted()
        }
    }
    
    Quit tSC
}

/// Undo all executed commands in reverse order
/// 
/// @return Status code
Method Undo() As %Status
{
    Set tSC = $$$OK
    Set tUndoneCount = 0
    
    Try {
        // Check if we can undo
        If '..IsExecuted {
            Set tSC = $$$ERROR($$$GeneralError, "Composite command not executed")
            Quit
        }
        
        If '..IsUndoable {
            Set tSC = $$$ERROR($$$GeneralError, "Composite command is not undoable")
            Quit
        }
        
        // Undo commands in reverse order
        For i = ..Commands.Count():-1:1 {
            Set tCommand = ..Commands.GetAt(i)
            
            // Only undo if command was executed
            If tCommand.IsExecuted && tCommand.CanUndo() {
                Set tSC = tCommand.Undo()
                If $$$ISERR(tSC) && ..StopOnError {
                    Quit
                }
                If $$$ISOK(tSC) {
                    Set tUndoneCount = tUndoneCount + 1
                }
            }
        }
        
        // Mark as not executed if we undid everything
        If tUndoneCount = ..ExecutedCount {
            Set ..IsExecuted = 0
            Set ..ExecutedCount = 0
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check if the composite can execute
/// 
/// @return Boolean indicating if composite can execute
Method CanExecute() As %Boolean
{
    Set tCanExecute = 0
    
    // Check base conditions
    If ..IsExecuted {
        Quit 0
    }
    
    If ..Commands.Count() = 0 {
        Quit 0
    }
    
    // Check if at least one command can execute
    For i = 1:1:..Commands.Count() {
        Set tCommand = ..Commands.GetAt(i)
        If tCommand.CanExecute() {
            Set tCanExecute = 1
            Quit
        }
    }
    
    Quit tCanExecute
}

/// Check if the composite can be undone
/// 
/// @return Boolean indicating if composite can be undone
Method CanUndo() As %Boolean
{
    Set tCanUndo = 0
    
    // Check base conditions
    If '..IsExecuted || '..IsUndoable {
        Quit 0
    }
    
    // Check if at least one command can be undone
    For i = 1:1:..Commands.Count() {
        Set tCommand = ..Commands.GetAt(i)
        If tCommand.IsExecuted && tCommand.CanUndo() {
            Set tCanUndo = 1
            Quit
        }
    }
    
    Quit tCanUndo
}

/// Clear all commands from the composite
/// 
/// @return Status code
Method Clear() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Do ..Commands.Clear()
        Set ..ExecutedCount = 0
        Set ..IsExecuted = 0
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the number of commands in the composite
/// 
/// @return Number of commands
Method GetCommandCount() As %Integer
{
    Quit ..Commands.Count()
}

/// Get a command at a specific index
/// 
/// @param pIndex The index of the command
/// @return Command object or empty string
Method GetCommand(pIndex As %Integer) As Command
{
    If (pIndex < 1) || (pIndex > ..Commands.Count()) {
        Quit ""
    }
    
    Quit ..Commands.GetAt(pIndex)
}

// ===== PRIVATE METHODS =====

/// Rollback executed commands
Method RollbackExecuted() [ Private ]
{
    Try {
        // Undo in reverse order of execution
        For i = ..ExecutedCount:-1:1 {
            Set tCommand = ..Commands.GetAt(i)
            If tCommand.IsExecuted && tCommand.CanUndo() {
                Do tCommand.Undo()
            }
        }
        Set ..ExecutedCount = 0
        
    } Catch ex {
        // Silently ignore rollback errors
    }
}

// ===== CLASS METHODS =====

/// Create a composite command from an array of commands
/// 
/// @param pCommands Array of command objects
/// @param pDescription Description of the composite
/// @return New composite command instance
ClassMethod CreateFromArray(pCommands As %ListOfObjects, pDescription As %String = "") As CompositeCommand
{
    Set tComposite = ..%New(pDescription)
    
    If $ISOBJECT(pCommands) {
        For i = 1:1:pCommands.Count() {
            Do tComposite.AddCommand(pCommands.GetAt(i))
        }
    }
    
    Quit tComposite
}

}
