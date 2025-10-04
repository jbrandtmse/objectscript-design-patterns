/// Unit Tests for Service Layer Pattern
/// 
/// Comprehensive test coverage for Service Layer pattern including:
/// - Service layer initialization
/// - Transaction boundary management
/// - Service operations coordination
/// - Clinical services workflows
/// - Error handling and rollback
/// - Service context and metadata
Class Patterns.Test.Unit.PoEAA.DomainLogic.ServiceLayerTest Extends %UnitTest.TestCase
{

/// Test service layer initialization
Method TestServiceLayerInitialization() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create service layer instance
        Set tService = ##class(Patterns.PoEAA.DomainLogic.ServiceLayer).%New()
        
        // Verify service layer was created
        Do $$$AssertTrue($IsObject(tService), "Service layer should be created")
        
        // Verify service context was initialized
        Do $$$AssertTrue($IsObject(tService.ServiceContext), "Service context should be initialized")
        
        // Verify transaction manager was initialized
        Do $$$AssertTrue($IsObject(tService.TransactionManager), "Transaction manager should be initialized")
        
        // Verify last operation result was initialized
        Do $$$AssertTrue($IsObject(tService.LastOperationResult), "Last operation result should be initialized")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test transaction level tracking
Method TestGetTransactionLevel() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initially should be 0
        Set tLevel = ##class(Patterns.PoEAA.DomainLogic.ServiceLayer).GetTransactionLevel()
        Do $$$AssertEquals(tLevel, 0, "Transaction level should be 0 initially")
        
        // Start transaction
        TSTART
        Set tLevel = ##class(Patterns.PoEAA.DomainLogic.ServiceLayer).GetTransactionLevel()
        Do $$$AssertEquals(tLevel, 1, "Transaction level should be 1 after TSTART")
        
        // Rollback
        TROLLBACK
        Set tLevel = ##class(Patterns.PoEAA.DomainLogic.ServiceLayer).GetTransactionLevel()
        Do $$$AssertEquals(tLevel, 0, "Transaction level should be 0 after TROLLBACK")
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test check if in transaction
Method TestIsInTransaction() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initially should be false
        Set tInTransaction = ##class(Patterns.PoEAA.DomainLogic.ServiceLayer).IsInTransaction()
        Do $$$AssertTrue('tInTransaction, "Should not be in transaction initially")
        
        // Start transaction
        TSTART
        Set tInTransaction = ##class(Patterns.PoEAA.DomainLogic.ServiceLayer).IsInTransaction()
        Do $$$AssertTrue(tInTransaction, "Should be in transaction after TSTART")
        
        // Commit
        TCOMMIT
        Set tInTransaction = ##class(Patterns.PoEAA.DomainLogic.ServiceLayer).IsInTransaction()
        Do $$$AssertTrue('tInTransaction, "Should not be in transaction after TCOMMIT")
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test service operation result creation
Method TestCreateResult() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Create success result
        Set tResult = ##class(Patterns.PoEAA.DomainLogic.ServiceLayer).CreateResult(1, "Success message", "data123")
        
        Do $$$AssertTrue($IsObject(tResult), "Result should be created")
        Do $$$AssertEquals(tResult.Success, 1, "Success flag should be set")
        Do $$$AssertEquals(tResult.Message, "Success message", "Message should be set")
        Do $$$AssertEquals(tResult.Data, "data123", "Data should be set")
        Do $$$AssertTrue(tResult.Timestamp '= "", "Timestamp should be set")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test service context initialization
Method TestServiceContextInitialization() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tContext = ##class(Patterns.PoEAA.DomainLogic.ServiceContext).%New()
        
        Do $$$AssertTrue($IsObject(tContext), "Service context should be created")
        Do $$$AssertTrue(tContext.RequestTimestamp '= "", "Request timestamp should be set")
        Do $$$AssertTrue(tContext.TraceId '= "", "Trace ID should be set")
        Do $$$AssertTrue($IsObject(tContext.Metadata), "Metadata should be initialized")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test service context metadata
Method TestServiceContextMetadata() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tContext = ##class(Patterns.PoEAA.DomainLogic.ServiceContext).%New()
        
        // Set metadata
        Set tSC = tContext.SetMetadata("key1", "value1")
        Do $$$AssertStatusOK(tSC, "SetMetadata should succeed")
        
        // Get metadata
        Set tValue = tContext.GetMetadata("key1")
        Do $$$AssertEquals(tValue, "value1", "Metadata should be retrieved")
        
        // Get non-existent metadata
        Set tValue = tContext.GetMetadata("nonexistent")
        Do $$$AssertEquals(tValue, "", "Non-existent metadata should return empty string")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test service operation result success
Method TestServiceOperationResultSuccess() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tResult = ##class(Patterns.PoEAA.DomainLogic.ServiceOperationResult).%New()
        
        // Set success
        Set tSC = tResult.SetSuccess("Operation successful", "result-data")
        Do $$$AssertStatusOK(tSC, "SetSuccess should succeed")
        
        Do $$$AssertEquals(tResult.Success, 1, "Success flag should be true")
        Do $$$AssertEquals(tResult.Message, "Operation successful", "Message should be set")
        Do $$$AssertEquals(tResult.Data, "result-data", "Data should be set")
        Do $$$AssertEquals(tResult.StatusCode, "SUCCESS", "Status code should be SUCCESS")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test service operation result failure
Method TestServiceOperationResultFailure() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tResult = ##class(Patterns.PoEAA.DomainLogic.ServiceOperationResult).%New()
        
        // Set failure
        Set tSC = tResult.SetFailure("Operation failed", "Error details here")
        Do $$$AssertStatusOK(tSC, "SetFailure should succeed")
        
        Do $$$AssertEquals(tResult.Success, 0, "Success flag should be false")
        Do $$$AssertEquals(tResult.Message, "Operation failed", "Message should be set")
        Do $$$AssertEquals(tResult.ErrorDetails, "Error details here", "Error details should be set")
        Do $$$AssertEquals(tResult.StatusCode, "FAILURE", "Status code should be FAILURE")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test service operation result to JSON
Method TestServiceOperationResultToJSON() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tResult = ##class(Patterns.PoEAA.DomainLogic.ServiceOperationResult).%New()
        Do tResult.SetSuccess("Test message", "test-data")
        
        Set tJSON = tResult.ToJSON()
        
        Do $$$AssertTrue($IsObject(tJSON), "JSON should be created")
        Do $$$AssertEquals(tJSON.%Get("success"), 1, "JSON should contain success flag")
        Do $$$AssertEquals(tJSON.%Get("message"), "Test message", "JSON should contain message")
        Do $$$AssertEquals(tJSON.%Get("data"), "test-data", "JSON should contain data")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test transaction manager begin transaction
Method TestTransactionManagerBegin() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tTM = ##class(Patterns.PoEAA.DomainLogic.TransactionManager).%New()
        
        // Begin transaction
        Set tSC = tTM.BeginTransaction()
        Do $$$AssertStatusOK(tSC, "BeginTransaction should succeed")
        
        // Verify transaction level
        Set tLevel = tTM.GetCurrentLevel()
        Do $$$AssertEquals(tLevel, 1, "Transaction level should be 1")
        
        // Verify in transaction
        Do $$$AssertTrue(tTM.IsInTransaction(), "Should be in transaction")
        
        // Rollback to clean up
        If $TLEVEL > 0 TROLLBACK
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test transaction manager commit transaction
Method TestTransactionManagerCommit() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tTM = ##class(Patterns.PoEAA.DomainLogic.TransactionManager).%New()
        
        // Begin and commit transaction
        Set tSC = tTM.BeginTransaction()
        Do $$$AssertStatusOK(tSC, "BeginTransaction should succeed")
        
        Set tSC = tTM.CommitTransaction()
        Do $$$AssertStatusOK(tSC, "CommitTransaction should succeed")
        
        // Verify not in transaction
        Do $$$AssertTrue('tTM.IsInTransaction(), "Should not be in transaction after commit")
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test transaction manager rollback transaction
Method TestTransactionManagerRollback() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tTM = ##class(Patterns.PoEAA.DomainLogic.TransactionManager).%New()
        
        // Begin and rollback transaction
        Set tSC = tTM.BeginTransaction()
        Do $$$AssertStatusOK(tSC, "BeginTransaction should succeed")
        
        Set tSC = tTM.RollbackTransaction()
        Do $$$AssertStatusOK(tSC, "RollbackTransaction should succeed")
        
        // Verify not in transaction
        Do $$$AssertTrue('tTM.IsInTransaction(), "Should not be in transaction after rollback")
        
    } Catch ex {
        If $TLEVEL > 0 TROLLBACK
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test transaction manager isolation level
Method TestTransactionManagerIsolationLevel() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tTM = ##class(Patterns.PoEAA.DomainLogic.TransactionManager).%New()
        
        // Set valid isolation level
        Set tSC = tTM.SetIsolationLevel("READ COMMITTED")
        Do $$$AssertStatusOK(tSC, "SetIsolationLevel should succeed for valid level")
        Do $$$AssertEquals(tTM.IsolationLevel, "READ COMMITTED", "Isolation level should be set")
        
        // Try invalid isolation level
        Set tSC = tTM.SetIsolationLevel("INVALID LEVEL")
        Do $$$AssertStatusNotOK(tSC, "SetIsolationLevel should fail for invalid level")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test patient admission service initialization
Method TestPatientAdmissionServiceInit() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tService = ##class(Patterns.Examples.Clinical.PatientAdmissionService).%New()
        
        Do $$$AssertTrue($IsObject(tService), "Patient admission service should be created")
        Do $$$AssertTrue($IsObject(tService.ServiceContext), "Service context should be initialized")
        Do $$$AssertTrue($IsObject(tService.TransactionManager), "Transaction manager should be initialized")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test admission request validation success
Method TestAdmissionValidationSuccess() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tService = ##class(Patterns.Examples.Clinical.PatientAdmissionService).%New()
        
        // Create valid patient data
        Set tPatientData = {
            "name": "John Doe",
            "dateOfBirth": "1980-01-15",
            "admissionType": "Emergency"
        }
        
        // Validate
        Set tSC = tService.ValidateAdmissionRequest(tPatientData)
        Do $$$AssertStatusOK(tSC, "Validation should succeed for valid data")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test admission request validation failure - missing name
Method TestAdmissionValidationFailureMissingName() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tService = ##class(Patterns.Examples.Clinical.PatientAdmissionService).%New()
        
        // Create patient data without name
        Set tPatientData = {
            "dateOfBirth": "1980-01-15",
            "admissionType": "Emergency"
        }
        
        // Validate
        Set tSC = tService.ValidateAdmissionRequest(tPatientData)
        Do $$$AssertStatusNotOK(tSC, "Validation should fail for missing name")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test admission request validation failure - invalid admission type
Method TestAdmissionValidationFailureInvalidType() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tService = ##class(Patterns.Examples.Clinical.PatientAdmissionService).%New()
        
        // Create patient data with invalid admission type
        Set tPatientData = {
            "name": "John Doe",
            "dateOfBirth": "1980-01-15",
            "admissionType": "InvalidType"
        }
        
        // Validate
        Set tSC = tService.ValidateAdmissionRequest(tPatientData)
        Do $$$AssertStatusNotOK(tSC, "Validation should fail for invalid admission type")
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test create admission record
Method TestCreateAdmissionRecord() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear test global
        Kill ^Patterns.Clinical.Admission
        
        Set tService = ##class(Patterns.Examples.Clinical.PatientAdmissionService).%New()
        
        // Create admission record
        Set tSC = tService.CreateAdmissionRecord("patient123", "Emergency")
        Do $$$AssertStatusOK(tSC, "CreateAdmissionRecord should succeed")
        
        // Verify global was updated
        Set tExists = $DATA(^Patterns.Clinical.Admission(1))
        Do $$$AssertTrue(tExists, "Admission record should exist in global")
        
        // Clean up
        Kill ^Patterns.Clinical.Admission
        
    } Catch ex {
        Kill ^Patterns.Clinical.Admission
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test create discharge record
Method TestCreateDischargeRecord() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear test global
        Kill ^Patterns.Clinical.Discharge
        
        Set tService = ##class(Patterns.Examples.Clinical.PatientAdmissionService).%New()
        
        // Create discharge record
        Set tSC = tService.CreateDischargeRecord("patient123", "Recovered")
        Do $$$AssertStatusOK(tSC, "CreateDischargeRecord should succeed")
        
        // Verify global was updated
        Set tExists = $DATA(^Patterns.Clinical.Discharge(1))
        Do $$$AssertTrue(tExists, "Discharge record should exist in global")
        
        // Clean up
        Kill ^Patterns.Clinical.Discharge
        
    } Catch ex {
        Kill ^Patterns.Clinical.Discharge
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test create transfer record
Method TestCreateTransferRecord() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear test global
        Kill ^Patterns.Clinical.Transfer
        
        Set tService = ##class(Patterns.Examples.Clinical.PatientAdmissionService).%New()
        
        // Create transfer record
        Set tSC = tService.CreateTransferRecord("patient123", "ICU")
        Do $$$AssertStatusOK(tSC, "CreateTransferRecord should succeed")
        
        // Verify global was updated
        Set tExists = $DATA(^Patterns.Clinical.Transfer(1))
        Do $$$AssertTrue(tExists, "Transfer record should exist in global")
        
        // Clean up
        Kill ^Patterns.Clinical.Transfer
        
    } Catch ex {
        Kill ^Patterns.Clinical.Transfer
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

/// Test service layer logging
Method TestServiceLayerLogging() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear audit global
        Kill ^Patterns.ServiceLayer.Audit
        
        Set tService = ##class(Patterns.PoEAA.DomainLogic.ServiceLayer).%New()
        Set tService.ServiceContext.UserId = "testuser"
        Set tService.ServiceContext.SessionId = "session123"
        
        // Log operation
        Set tSC = tService.LogOperation("TestOperation", $$$OK, "Test details")
        Do $$$AssertStatusOK(tSC, "LogOperation should succeed")
        
        // Verify audit log was created
        Set tExists = $DATA(^Patterns.ServiceLayer.Audit(1))
        Do $$$AssertTrue(tExists, "Audit log should exist")
        
        // Clean up
        Kill ^Patterns.ServiceLayer.Audit
        
    } Catch ex {
        Kill ^Patterns.ServiceLayer.Audit
        Set tSC = ex.AsStatus()
        Do $$$AssertStatusOK(tSC, "Test should not throw exception")
    }
    
    Quit $$$OK
}

}
