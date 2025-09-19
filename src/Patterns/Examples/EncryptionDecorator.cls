/// Gang of Four Decorator Pattern - Encryption Decorator for Patient Records
/// 
/// <p>Intent:
/// Adds encryption capabilities to patient records, ensuring data security
/// during storage and transmission.</p>
/// 
/// <p>Motivation:
/// Healthcare data requires strong encryption to protect patient privacy
/// and meet compliance requirements. This decorator adds encryption
/// transparently to any patient record component.</p>
/// 
/// <p>Structure:
/// Extends PatientRecordComponent and wraps another record component,
/// adding encryption to data operations while maintaining the same interface.</p>
/// 
/// <p>Participants:
/// - Encrypts data before saving
/// - Decrypts data when retrieving
/// - Increases security level
/// - Adds computational cost for encryption operations</p>
/// 
/// @since 1.0.0
/// @see Patterns.Examples.PatientRecordComponent
/// @see Patterns.Examples.BasicPatientRecord
Class Patterns.Examples.EncryptionDecorator Extends Patterns.Examples.PatientRecordComponent
{

/// The wrapped patient record component
Property Component As Patterns.Examples.PatientRecordComponent;

/// Encryption algorithm used
Property EncryptionAlgorithm As %String [ InitialExpression = "AES-256" ];

/// Encryption key (in production, this would be securely managed)
Property EncryptionKey As %String [ Private ];

/// Additional cost for encryption operations
Property AdditionalCost As %Numeric [ InitialExpression = 25 ];

/// Track number of encryption operations
Property EncryptionCount As %Integer [ InitialExpression = 0 ];

/// Track number of decryption operations
Property DecryptionCount As %Integer [ InitialExpression = 0 ];

/// Constructor accepting component to wrap
/// 
/// @param pComponent The patient record component to decorate
/// @param pAlgorithm Optional encryption algorithm
/// @return %Status indicating success or failure
Method %OnNew(pComponent As Patterns.Examples.PatientRecordComponent, pAlgorithm As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate component
        If '$ISOBJECT(pComponent) {
            Set tSC = $$$ERROR($$$GeneralError, "EncryptionDecorator requires a component to wrap")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Set ..Component = pComponent
        
        If pAlgorithm '= "" {
            Set ..EncryptionAlgorithm = pAlgorithm
        }
        
        // Generate a mock encryption key (in production, use secure key management)
        Set ..EncryptionKey = $SYSTEM.Encryption.Base64Encode($SYSTEM.Util.CreateGUID())
        
        // Adjust cost based on algorithm
        If ..EncryptionAlgorithm = "AES-512" {
            Set ..AdditionalCost = 40
        } ElseIf ..EncryptionAlgorithm = "AES-128" {
            Set ..AdditionalCost = 15
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get patient data with decryption
/// 
/// @param pDataType Type of data to retrieve
/// @return Decrypted patient data
Method GetData(pDataType As %String = "All") As %String
{
    Set ..DecryptionCount = ..DecryptionCount + 1
    
    // Get encrypted data from wrapped component
    Set tEncryptedData = ..Component.GetData(pDataType)
    
    // Simulate decryption (in production, use real encryption)
    Set tDecryptedData = ..DecryptData(tEncryptedData)
    
    // Add decryption indicator
    Set tResult = "[DECRYPTED-" _ ..EncryptionAlgorithm _ "] " _ tDecryptedData
    
    Quit tResult
}

/// Save patient data with encryption
/// 
/// @param pData Data to save
/// @param pDataType Type of data being saved
/// @return %Status indicating success or failure
Method SaveData(pData As %String, pDataType As %String = "General") As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..EncryptionCount = ..EncryptionCount + 1
        
        // Encrypt the data
        Set tEncryptedData = ..EncryptData(pData)
        
        // Save encrypted data through wrapped component
        Set tSC = ..Component.SaveData(tEncryptedData, pDataType)
        
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get enhanced description
/// 
/// @return Description including encryption details
Method GetDescription() As %String
{
    Set tDescription = ..Component.GetDescription()
    Set tDescription = tDescription _ " + Encryption(" _ ..EncryptionAlgorithm _ ")"
    
    Quit tDescription
}

/// Get total cost including encryption overhead
/// 
/// @return Total cost value
Method GetCost() As %Numeric
{
    Set tBaseCost = ..Component.GetCost()
    Quit tBaseCost + ..AdditionalCost
}

/// Check HIPAA compliance
/// 
/// <p>Encryption significantly improves HIPAA compliance.</p>
/// 
/// @return %Boolean indicating compliance
Method IsHIPAACompliant() As %Boolean
{
    // Encryption is a key requirement for HIPAA compliance
    Quit 1
}

/// Get enhanced security level
/// 
/// @return Security level including encryption indicator
Method GetSecurityLevel() As %String
{
    Set tBaseLevel = ..Component.GetSecurityLevel()
    
    // Add encryption indicator to the security level
    If tBaseLevel [ "Encrypted" {
        // Already encrypted, just return it
        Quit tBaseLevel
    } Else {
        // Add encrypted prefix to show encryption is active
        Quit "Encrypted(" _ tBaseLevel _ ")"
    }
}

/// Check for critical values
/// 
/// @param pThresholds Optional custom thresholds
/// @return %Boolean from wrapped component
Method HasCriticalValues(pThresholds As %String = "") As %Boolean
{
    // Delegate to wrapped component
    Quit ..Component.HasCriticalValues(pThresholds)
}

/// Get audit trail with encryption events
/// 
/// @param pStartDate Optional start date
/// @param pEndDate Optional end date
/// @return Enhanced audit trail
Method GetAuditTrail(pStartDate As %Date = "", pEndDate As %Date = "") As %String
{
    Set tAudit = ..Component.GetAuditTrail(pStartDate, pEndDate)
    
    // Add encryption audit information
    Set tAudit = tAudit _ $CHAR(13,10)
    Set tAudit = tAudit _ "=== Encryption Audit ===" _ $CHAR(13,10)
    Set tAudit = tAudit _ "Algorithm: " _ ..EncryptionAlgorithm _ $CHAR(13,10)
    Set tAudit = tAudit _ "Encryption Operations: " _ ..EncryptionCount _ $CHAR(13,10)
    Set tAudit = tAudit _ "Decryption Operations: " _ ..DecryptionCount
    
    Quit tAudit
}

/// Simulate data encryption
/// 
/// @param pData Data to encrypt
/// @return Encrypted data
Method EncryptData(pData As %String) As %String [ Private ]
{
    // In production, use real encryption
    // For demo, we'll reverse and encode
    Set tReversed = $REVERSE(pData)
    Set tEncrypted = $SYSTEM.Encryption.Base64Encode(tReversed)
    
    // Add encryption marker
    Set tEncrypted = "[ENC:" _ $EXTRACT(..EncryptionAlgorithm, 1, 3) _ "]" _ tEncrypted
    
    Quit tEncrypted
}

/// Simulate data decryption
/// 
/// @param pData Encrypted data
/// @return Decrypted data
Method DecryptData(pData As %String) As %String [ Private ]
{
    Set tData = pData
    
    // Remove encryption marker if present
    If $EXTRACT(tData, 1, 5) = "[ENC:" {
        Set tPos = $FIND(tData, "]")
        If tPos > 0 {
            Set tData = $EXTRACT(tData, tPos, *)
        }
    }
    
    // In production, use real decryption
    // For demo, decode and reverse back
    Try {
        Set tDecoded = $SYSTEM.Encryption.Base64Decode(tData)
        Set tDecrypted = $REVERSE(tDecoded)
    } Catch {
        // If decryption fails, return original
        Set tDecrypted = tData
    }
    
    Quit tDecrypted
}

/// Display decorator information
Method Display()
{
    Write "=== Encryption Decorator ===" , !
    Write "Algorithm: ", ..EncryptionAlgorithm, !
    Write "Encryption Count: ", ..EncryptionCount, !
    Write "Decryption Count: ", ..DecryptionCount, !
    Write "Additional Cost: $", ..AdditionalCost, !
    Write "Total Cost: $", ..GetCost(), !
    Write "Security Level: ", ..GetSecurityLevel(), !
    Write "HIPAA Compliant: Yes", !
    Write "==========================", !
    
    // Display wrapped component
    If $ISOBJECT(..Component) {
        Do ..Component.Display()
    }
}

/// Get encryption statistics
/// 
/// @return Statistics string
Method GetStatistics() As %String
{
    Set tStats = "Encryption Statistics: "
    Set tStats = tStats _ "Algorithm=" _ ..EncryptionAlgorithm
    Set tStats = tStats _ ", Encryptions=" _ ..EncryptionCount
    Set tStats = tStats _ ", Decryptions=" _ ..DecryptionCount
    Set tTotalOps = ..EncryptionCount + ..DecryptionCount
    If tTotalOps > 0 {
        Set tRatio = $FNUMBER(..EncryptionCount / tTotalOps * 100, "", 1)
        Set tStats = tStats _ ", EncryptionRatio=" _ tRatio _ "%"
    }
    
    Quit tStats
}

/// Reset encryption counters
Method ResetCounters()
{
    Set ..EncryptionCount = 0
    Set ..DecryptionCount = 0
}

}
