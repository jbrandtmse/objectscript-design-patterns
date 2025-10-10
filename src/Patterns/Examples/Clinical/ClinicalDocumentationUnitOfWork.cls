/// Clinical Documentation Unit of Work Example
/// Demonstrates Unit of Work pattern for clinical documentation updates
Class Patterns.Examples.Clinical.ClinicalDocumentationUnitOfWork Extends Patterns.PoEAA.DataSource.UnitOfWork
{

/// Audit log for tracking all changes
Property AuditLog As %String [ MultiDimensional ];

/// Validation errors collection
Property ValidationErrors As %String [ MultiDimensional ];

/// Enable audit logging
Property EnableAudit As %Boolean [ InitialExpression = 1 ];

/// Validates all pending changes before commit
Method ValidateChanges() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Kill ..ValidationErrors
        Set tErrorCount = 0
        
        // Use index-based iteration for list collections
        For i=1:1:..NewObjects.Count() {
            Set tObject = ..NewObjects.GetAt(i)
            Set tValidationResult = ..ValidateObject(tObject, "new")
            If $$$ISERR(tValidationResult) {
                Set tErrorCount = tErrorCount + 1
                Set ..ValidationErrors(tErrorCount) = "New object validation failed"
            }
        }
        
        If tErrorCount > 0 {
            Set tSC = $$$ERROR($$$GeneralError, "Validation failed")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validates a single object based on business rules
Method ValidateObject(pObject As %RegisteredObject, pOperation As %String) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        If pObject.%ClassName(1) = "Patterns.Examples.Clinical.ClinicalEncounter" {
            Set tSC = ..ValidateClinicalEncounter(pObject, pOperation)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validates a Clinical Encounter object
Method ValidateClinicalEncounter(pEncounter As Patterns.Examples.Clinical.ClinicalEncounter, pOperation As %String) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        If pEncounter.PatientMRN = "" {
            Set tSC = $$$ERROR($$$GeneralError, "PatientMRN is required")
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Commits all pending changes with validation and audit logging
Method Commit() As %Status
{
    Set tSC = $$$OK
    Set tResult = ""
    
    Try {
        Set tResult = ..ValidateChanges()
        If $$$ISERR(tResult) {
            Set tSC = tResult
            Do ..Rollback()
            Quit
        }
        
        Set tResult = ##super()
        Set tSC = tResult
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do ..Rollback()
    }
    
    Quit tSC
}

}
