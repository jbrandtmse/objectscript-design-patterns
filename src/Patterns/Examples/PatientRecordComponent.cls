/// Gang of Four Decorator Pattern - Healthcare Patient Record Component
/// 
/// <p>Intent:
/// Defines the abstract interface for patient records that can be enhanced
/// with various features like encryption, audit logging, privacy controls,
/// and critical value alerts through the decorator pattern.</p>
/// 
/// <p>Motivation:
/// Healthcare systems require flexible ways to add features to patient records
/// based on compliance requirements, security needs, and clinical workflows.
/// The decorator pattern allows these features to be added dynamically.</p>
/// 
/// <p>Structure:
/// This abstract class defines the interface that both basic patient records
/// and decorators must implement, ensuring type compatibility throughout the
/// decorator chain.</p>
/// 
/// <p>Applicability:
/// Use this pattern when:
/// - Different patient records need different combinations of features
/// - Features need to be added or removed at runtime
/// - Compliance requirements vary by department or region
/// - You want to avoid a combinatorial explosion of subclasses</p>
/// 
/// @since 1.0.0
/// @see Patterns.Examples.BasicPatientRecord
/// @see Patterns.Examples.EncryptionDecorator
Class Patterns.Examples.PatientRecordComponent Extends %RegisteredObject [ Abstract ]
{

/// Get patient data from the record
/// 
/// <p>Retrieves patient data, potentially with enhancements
/// like decryption, decompression, or access logging.</p>
/// 
/// @param pDataType Type of data to retrieve (Demographics, Vitals, Labs, etc.)
/// @return Patient data as a string
Method GetData(pDataType As %String = "All") As %String [ Abstract ]
{
    Quit ""
}

/// Save patient data to the record
/// 
/// <p>Saves patient data, potentially with enhancements
/// like encryption, compression, audit logging, or validation.</p>
/// 
/// @param pData Data to save
/// @param pDataType Type of data being saved
/// @return %Status indicating success or failure
Method SaveData(pData As %String, pDataType As %String = "General") As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Get record description
/// 
/// <p>Returns a description of the record and all applied enhancements.</p>
/// 
/// @return Description string
Method GetDescription() As %String [ Abstract ]
{
    Quit ""
}

/// Get the cost/overhead of this record configuration
/// 
/// <p>Returns the computational or storage cost associated
/// with this record configuration.</p>
/// 
/// @return Numeric cost value
Method GetCost() As %Numeric
{
    Quit 0
}

/// Check if the record is HIPAA compliant
/// 
/// <p>Validates whether the current configuration meets
/// HIPAA compliance requirements.</p>
/// 
/// @return %Boolean indicating compliance
Method IsHIPAACompliant() As %Boolean
{
    Quit 0
}

/// Get security level
/// 
/// <p>Returns the security level of the record configuration.</p>
/// 
/// @return Security level (Basic, Standard, Enhanced, Maximum)
Method GetSecurityLevel() As %String
{
    Quit "Basic"
}

/// Check if critical values are present
/// 
/// <p>Checks for critical lab values or vital signs that
/// require immediate attention.</p>
/// 
/// @param pThresholds Optional custom thresholds
/// @return %Boolean indicating presence of critical values
Method HasCriticalValues(pThresholds As %String = "") As %Boolean
{
    Quit 0
}

/// Get audit trail
/// 
/// <p>Returns the audit trail for this record.</p>
/// 
/// @param pStartDate Optional start date for audit entries
/// @param pEndDate Optional end date for audit entries
/// @return Audit trail as a string
Method GetAuditTrail(pStartDate As %Date = "", pEndDate As %Date = "") As %String
{
    Quit ""
}

/// Display record information
/// 
/// <p>Utility method to display record details.</p>
Method Display()
{
    Write "=== Patient Record Component ===", !
    Write "Description: ", ..GetDescription(), !
    Write "Security Level: ", ..GetSecurityLevel(), !
    Write "HIPAA Compliant: ", $SELECT(..IsHIPAACompliant():"Yes", 1:"No"), !
    Write "Cost: ", ..GetCost(), !
    Write "================================", !
}

}
