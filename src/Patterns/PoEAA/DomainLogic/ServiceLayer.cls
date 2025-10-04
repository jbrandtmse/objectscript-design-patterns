/// PoEAA Service Layer Pattern - Application Boundary Definition
/// 
/// Intent:
/// Define an application's boundary with a set of available operations from the 
/// perspective of interfacing client layers. Encapsulate the application's business 
/// logic, controlling transactions and coordinating responses in the implementation 
/// of its operations.
/// 
/// Structure:
/// Service Layer defines coarse-grained operations that coordinate domain objects
/// and manage transaction boundaries. Each service operation represents a complete
/// use case from the client's perspective.
/// 
/// Key Responsibilities:
/// - Define application boundary with coarse-grained API
/// - Manage transaction boundaries (TSTART/TCOMMIT/TROLLBACK)
/// - Coordinate domain model and table module operations
/// - Handle service-level validation and error handling
/// - Provide consistent service operation results
/// 
/// Example:
/// <example>
/// Set service = ##class(PatientAdmissionService).%New()
/// Set status = service.AdmitPatient(patientData)
/// If $$$ISOK(status) {
///     Write "Patient admitted successfully"
/// }
/// </example>
/// 
/// @see Patterns.PoEAA.DomainLogic.TransactionScript
/// @see Patterns.PoEAA.DomainLogic.DomainModel
/// @see Patterns.PoEAA.DomainLogic.TableModule
/// @since 1.0.0
Class Patterns.PoEAA.DomainLogic.ServiceLayer Extends %RegisteredObject
{

/// Service name for logging and identification
Parameter SERVICENAME = "BaseService";

/// Default transaction isolation level
Parameter DEFAULTISOLATIONLEVEL = "READ COMMITTED";

/// Maximum transaction timeout in seconds
Parameter MAXTRANSACTIONTIMEOUT = 300;

/// Current service context for request metadata
Property ServiceContext As Patterns.PoEAA.DomainLogic.ServiceContext;

/// Transaction manager for handling transaction lifecycle
Property TransactionManager As Patterns.PoEAA.DomainLogic.TransactionManager;

/// Service operation result for consistent responses
Property LastOperationResult As Patterns.PoEAA.DomainLogic.ServiceOperationResult;

/// Constructor - Initialize service layer components
Method %OnNew(pServiceContext As Patterns.PoEAA.DomainLogic.ServiceContext = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize service context
        If $IsObject(pServiceContext) {
            Set ..ServiceContext = pServiceContext
        } Else {
            Set ..ServiceContext = ##class(Patterns.PoEAA.DomainLogic.ServiceContext).%New()
        }
        
        // Initialize transaction manager
        Set ..TransactionManager = ##class(Patterns.PoEAA.DomainLogic.TransactionManager).%New()
        
        // Initialize last operation result
        Set ..LastOperationResult = ##class(Patterns.PoEAA.DomainLogic.ServiceOperationResult).%New()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Execute operation within transaction boundary
/// 
/// @param pOperation Operation name to execute
/// @param pArgs Variable arguments to pass to operation
/// @return %Status indicating success or failure
ClassMethod ExecuteInTransaction(pOperation As %String, pArgs... As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Begin transaction
        TSTART
        
        // Execute operation using $METHOD
        Set tSC = $METHOD($THIS, pOperation, pArgs...)
        
        // Commit if successful, otherwise rollback
        If $$$ISOK(tSC) {
            TCOMMIT
        } Else {
            If $TLEVEL > 0 TROLLBACK
        }
        
    } Catch ex {
        // Rollback on exception
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Execute operation within transaction boundary (instance method version)
/// 
/// @param pOperation Operation method name
/// @param pArgs Variable arguments
/// @return %Status
Method ExecuteOperation(pOperation As %String, pArgs... As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Begin transaction
        TSTART
        
        // Execute operation
        Set tSC = $METHOD($THIS, pOperation, pArgs...)
        
        // Commit or rollback based on result
        If $$$ISOK(tSC) {
            TCOMMIT
        } Else {
            If $TLEVEL > 0 TROLLBACK
        }
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate service request before processing
/// 
/// @param pRequest Request object to validate
/// @return %Status indicating validation success or failure
ClassMethod ValidateRequest(pRequest As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if request object exists
        If '$IsObject(pRequest) {
            Set tSC = $$$ERROR($$$GeneralError, "Request object is required")
            Quit
        }
        
        // Subclasses should override to add specific validation
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get current transaction level
/// 
/// @return Current $TLEVEL value
ClassMethod GetTransactionLevel() As %Integer
{
    Quit $TLEVEL
}

/// Check if currently in transaction
/// 
/// @return 1 if in transaction, 0 otherwise
ClassMethod IsInTransaction() As %Boolean
{
    Quit ($TLEVEL > 0)
}

/// Create service operation result
/// 
/// @param pSuccess Success flag
/// @param pMessage Result message
/// @param pData Optional result data
/// @return ServiceOperationResult object
ClassMethod CreateResult(pSuccess As %Boolean, pMessage As %String, pData As %String = "") As Patterns.PoEAA.DomainLogic.ServiceOperationResult
{
    Set result = ##class(Patterns.PoEAA.DomainLogic.ServiceOperationResult).%New()
    Set result.Success = pSuccess
    Set result.Message = pMessage
    Set result.Data = pData
    Set result.Timestamp = $ZDATETIME($HOROLOG, 3)
    
    Quit result
}

/// Log service operation for audit trail
/// 
/// @param pOperation Operation name
/// @param pStatus Operation status
/// @param pDetails Optional details
Method LogOperation(pOperation As %String, pStatus As %Status, pDetails As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create audit log entry
        Set tLogEntry = {
            "service": (..#SERVICENAME),
            "operation": (pOperation),
            "status": ($SELECT($$$ISOK(pStatus): "SUCCESS", 1: "FAILURE")),
            "timestamp": ($ZDATETIME($HOROLOG, 3)),
            "details": (pDetails),
            "context": {
                "userId": (..ServiceContext.UserId),
                "sessionId": (..ServiceContext.SessionId)
            }
        }
        
        // Store in audit global
        Set tAuditId = $INCREMENT(^Patterns.ServiceLayer.Audit)
        Set ^Patterns.ServiceLayer.Audit(tAuditId) = tLogEntry.%ToJSON()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
