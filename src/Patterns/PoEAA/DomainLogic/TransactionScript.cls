/// PoEAA Transaction Script Pattern - Organize Business Logic by Procedures
/// 
/// Intent:
/// Organize business logic by procedures where each procedure handles a single request from the presentation.
/// 
/// Applicability:
/// - Domain logic is simple with minimal business rules
/// - Application is data-centric with table-oriented operations
/// - Rapid development is prioritized
/// - Team is familiar with procedural programming
/// 
/// Structure:
/// Each business operation is implemented as a single procedure that:
/// - Accepts input parameters
/// - Manages transaction boundaries
/// - Executes database operations
/// - Returns results or status
/// 
/// Example:
/// <example>
/// Set script = ##class(Patterns.PoEAA.DomainLogic.TransactionScript).%New()
/// Set status = script.Execute(inputData)
/// </example>
/// 
/// @see Patterns.PoEAA.DomainLogic.DomainModel
/// @since 1.0.0
Class Patterns.PoEAA.DomainLogic.TransactionScript Extends %RegisteredObject
{

/// Version of the pattern implementation
Parameter VERSION = "1.0.0";

/// Pattern type classification
Parameter PATTERNTYPE = "Domain Logic";

/// Transaction state tracking (INACTIVE, ACTIVE, COMMITTED, ROLLEDBACK)
Property TransactionState As %String [ InitialExpression = "INACTIVE" ];

/// Transaction nesting level
Property TransactionLevel As %Integer [ InitialExpression = 0 ];

/// Last error message
Property LastError As %String;

/// Transaction log for debugging
Property TransactionLog As %String [ MultiDimensional ];

/// Constructor - Initialize transaction script
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize transaction state
        Set ..TransactionState = "INACTIVE"
        Set ..TransactionLevel = 0
        Set ..LastError = ""
        
        // Clear transaction log
        Kill ..TransactionLog
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Begin a new transaction
/// @return Status indicating success or failure
Method StartTransaction() As %Status
{
    Set tSC = $$$OK
    Try {
        // Start database transaction
        TSTART
        
        // Update state
        Set ..TransactionState = "ACTIVE"
        Set ..TransactionLevel = $TLEVEL
        
        // Log transaction start
        Set ..TransactionLog("start", $HOROLOG) = "Transaction started at level "_..TransactionLevel
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..LastError = "Failed to start transaction: "_ex.DisplayString()
    }
    Quit tSC
}

/// Commit the current transaction
/// @return Status indicating success or failure
Method CommitTransaction() As %Status
{
    Set tSC = $$$OK
    Try {
        // Verify transaction is active
        If ..TransactionState '= "ACTIVE" {
            Set tSC = $$$ERROR($$$GeneralError, "No active transaction to commit")
            Quit
        }
        
        // Commit database transaction
        TCOMMIT
        
        // Update state
        Set ..TransactionState = "COMMITTED"
        Set ..TransactionLevel = $TLEVEL
        
        // Log transaction commit
        Set ..TransactionLog("commit", $HOROLOG) = "Transaction committed"
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..LastError = "Failed to commit transaction: "_ex.DisplayString()
    }
    Quit tSC
}

/// Rollback the current transaction
/// @return Status indicating success or failure
Method RollbackTransaction() As %Status
{
    Set tSC = $$$OK
    Try {
        // Verify transaction is active
        If ..TransactionState '= "ACTIVE" {
            Set tSC = $$$ERROR($$$GeneralError, "No active transaction to rollback")
            Quit
        }
        
        // Rollback database transaction
        TROLLBACK
        
        // Update state
        Set ..TransactionState = "ROLLEDBACK"
        Set ..TransactionLevel = $TLEVEL
        
        // Log transaction rollback
        Set ..TransactionLog("rollback", $HOROLOG) = "Transaction rolled back"
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..LastError = "Failed to rollback transaction: "_ex.DisplayString()
    }
    Quit tSC
}

/// Execute a procedure within a transaction
/// @param pProcedure Procedure to execute (implemented in subclasses)
/// @param pData Input data for the procedure
/// @return Status indicating success or failure
Method Execute(pProcedure As %String = "", pData As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    Set tResult = ""
    
    Try {
        // Start transaction
        Set tSC = ..StartTransaction()
        If $$$ISERR(tSC) Quit
        
        // Execute the procedure (to be implemented in subclasses)
        Set tResult = ..ExecuteProcedure(pProcedure, pData)
        
        // Commit if successful
        Set tSC = ..CommitTransaction()
        
    } Catch ex {
        // Rollback on error
        Do ..RollbackTransaction()
        Set tSC = ex.AsStatus()
        Set ..LastError = "Procedure execution failed: "_ex.DisplayString()
    }
    
    Quit tSC
}

/// Execute the actual procedure logic (override in subclasses)
/// @param pProcedure Name of the procedure to execute
/// @param pData Input data for the procedure
/// @return Result of the procedure execution
Method ExecuteProcedure(pProcedure As %String, pData As %DynamicObject) As %String
{
    // Default implementation - override in subclasses
    Quit "NOT_IMPLEMENTED"
}

/// Get current transaction level from IRIS
/// @return Current transaction nesting level
Method GetTransactionLevel() As %Integer
{
    Quit $TLEVEL
}

/// Check if transaction is active
/// @return 1 if active, 0 otherwise
Method IsTransactionActive() As %Boolean
{
    Quit (..TransactionState = "ACTIVE")
}

/// Get transaction state description
/// @return Human-readable transaction state
Method GetTransactionState() As %String
{
    Quit ..TransactionState
}

/// Get last error message
/// @return Last error message or empty string
Method GetLastError() As %String
{
    Quit ..LastError
}

/// Clear error state
Method ClearError()
{
    Set ..LastError = ""
}

/// Get transaction log entries
/// @return Array of log entries
Method GetTransactionLog() As %DynamicArray
{
    Set logArray = []
    
    Set key = ""
    For {
        Set key = $ORDER(..TransactionLog(key))
        Quit:key=""
        
        Set subkey = ""
        For {
            Set subkey = $ORDER(..TransactionLog(key, subkey))
            Quit:subkey=""
            
            Set entry = {}
            Set entry.type = key
            Set entry.timestamp = subkey
            Set entry.message = ..TransactionLog(key, subkey)
            Do logArray.%Push(entry)
        }
    }
    
    Quit logArray
}

/// Clean up resources
Method Cleanup()
{
    // Rollback any active transaction
    If ..IsTransactionActive() {
        Do ..RollbackTransaction()
    }
    
    // Clear transaction log
    Kill ..TransactionLog
    
    // Reset state
    Set ..TransactionState = "INACTIVE"
    Set ..TransactionLevel = 0
    Set ..LastError = ""
}

/// Destructor - ensure cleanup
Method %OnClose() As %Status
{
    Do ..Cleanup()
    Quit $$$OK
}

}
