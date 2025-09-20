/// Gang of Four Proxy Pattern - Real Subject Implementation
/// 
/// Intent:
/// Defines the real object that the proxy represents.
/// This is the actual implementation that performs the real work.
/// 
/// The RealSubject contains the actual business logic and resources
/// that may be expensive to create or require access control.
/// 
/// Structure:
/// <example>
/// // Direct usage (without proxy)
/// Set realSubject = ##class(Patterns.GoF.Structural.RealSubject).%New()
/// Set result = realSubject.Request()
/// 
/// // Through proxy (controlled access)
/// Set proxy = ##class(Patterns.GoF.Structural.ProtectionProxy).%New()
/// Set result = proxy.Request()  // Proxy checks access then delegates
/// </example>
Class Patterns.GoF.Structural.RealSubject Extends Patterns.GoF.Structural.Subject
{

/// Property Data - Internal data managed by the real subject
Property Data As %String [ InitialExpression = "RealSubject Data" ];

/// Property LoadTime - Timestamp when object was loaded (for demonstration)
Property LoadTime As %TimeStamp [ InitialExpression = {$ZDateTime($Horolog, 3)} ];

/// Property OperationCount - Track number of operations performed
Property OperationCount As %Integer [ InitialExpression = 0 ];

/// Constructor - Simulates expensive object creation
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    // Simulate expensive initialization (e.g., loading large data, network connection)
    // In real scenarios, this might load large files, connect to databases, etc.
    Set ..Data = "Expensive data loaded at " _ $ZDateTime($Horolog, 3)
    Set ..LoadTime = $ZDateTime($Horolog, 3)
    Set ..OperationCount = 0
    
    // Creation complete
    
    Quit tSC
}

/// Implementation of the Request method
/// Performs the actual business logic
/// 
/// @return Result of the request operation
Method Request() As %String
{
    Set ..OperationCount = ..OperationCount + 1
    
    Set tResult = "RealSubject: Handling request #" _ ..OperationCount _ " with data [" _ ..Data _ "]"
    
    // Request processed
    
    Quit tResult
}

/// Implementation of DoOperation with parameters
/// Performs specific operations based on the operation type
/// 
/// @param pOperation The operation to perform (READ, WRITE, DELETE, etc.)
/// @param pData The data to process
/// @return Status of the operation
Method DoOperation(pOperation As %String, pData As %String = "") As %Status
{
    Set tSC = $$$OK
    Set ..OperationCount = ..OperationCount + 1
    
    Try {
        If pOperation = "READ" {
            // Simulate read operation
            // READ operation: accessing data
        } ElseIf pOperation = "WRITE" {
            // Simulate write operation
            Set ..Data = pData
            // WRITE operation: data updated
        } ElseIf pOperation = "DELETE" {
            // Simulate delete operation
            Set ..Data = ""
            // DELETE operation: data cleared
        } ElseIf pOperation = "COMPUTE" {
            // Simulate expensive computation
            // This might be complex calculations, data processing, etc.
            // COMPUTE operation: processing data
            Hang 0.1  // Simulate processing time
        } Else {
            Set tSC = $$$ERROR($$$GeneralError, "Unknown operation: " _ pOperation)
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
        // Operation failed
    }
    
    Quit tSC
}

/// Get information about the resource
/// Used by virtual proxy to display info before loading
/// 
/// @return Information about the resource
Method GetInfo() As %String
{
    Set tInfo = "RealSubject Information: "
    Set tInfo = tInfo _ "LoadTime=" _ ..LoadTime _ ", "
    Set tInfo = tInfo _ "Operations=" _ ..OperationCount _ ", "
    Set tInfo = tInfo _ "DataSize=" _ $Length(..Data) _ " bytes"
    
    Quit tInfo
}

/// Simulate an expensive operation
/// Used to demonstrate performance benefits of virtual proxy
/// 
/// @param pComplexity Level of complexity (1-10)
/// @return Result of the expensive operation
Method PerformExpensiveOperation(pComplexity As %Integer = 5) As %String
{
    Set tStartTime = $Piece($Now(), ",", 2)
    
    // Simulate complex processing based on complexity level
    Set tIterations = pComplexity * 1000
    Set tResult = ""
    
    For i = 1:1:tIterations {
        Set tResult = $Reverse($Extract($ZConvert($System.Encryption.Base64Encode($Random(99999)), "L"), 1, 10))
    }
    
    Set tEndTime = $Piece($Now(), ",", 2)
    Set tDuration = tEndTime - tStartTime
    
    Set tResult = "Expensive operation completed in " _ tDuration _ " ms with complexity " _ pComplexity
    // Operation completed
    
    Quit tResult
}

/// Clean up resources when object is destroyed
Method %OnClose() As %Status
{
    Set tSC = $$$OK
    
    // Clean up any resources (close connections, release memory, etc.)
    // RealSubject destroyed
    
    Quit tSC
}

/// Class method to simulate static resource access
/// 
/// @param pResourceId The ID of the resource to access
/// @return Resource data or error message
ClassMethod AccessStaticResource(pResourceId As %String) As %String
{
    // Simulate accessing a shared resource
    If pResourceId = "" {
        Quit "Error: Resource ID required"
    }
    
    // In real implementation, might access database, file system, etc.
    Set tResourceData = "Static Resource [" _ pResourceId _ "] accessed at " _ $ZDateTime($Horolog, 3)
    
    // Static resource accessed
    
    Quit tResourceData
}

}
