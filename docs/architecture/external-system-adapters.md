# External System Adapter Patterns

## Overview

This document provides best practices and examples for implementing the Adapter pattern when integrating InterSystems IRIS with external systems including REST APIs, SOAP services, databases, and legacy systems.

## Purpose

The Adapter pattern is essential for enterprise integration, allowing IRIS applications to interact with external systems without being tightly coupled to their specific interfaces. This promotes maintainability, testability, and flexibility in system architecture.

## Best Practices for External API Adaptation

### 1. Interface Segregation

Create specific adapter interfaces for each external system integration point:

```objectscript
/// Abstract base for all external API adapters
Class Patterns.Integration.ExternalAPIAdapter Extends %RegisteredObject [ Abstract ]
{
    /// Connection timeout in seconds
    Parameter TIMEOUT = 30;
    
    /// Base URL for the API
    Property BaseURL As %String;
    
    /// Authentication credentials
    Property Credentials As %String;
    
    /// Execute API request
    Method ExecuteRequest(pMethod As %String, pEndpoint As %String, pPayload As %String = "") As %String [ Abstract ]
    {
        Quit ""
    }
    
    /// Handle authentication
    Method Authenticate() As %Status [ Abstract ]
    {
        Quit $$$OK
    }
    
    /// Parse response based on content type
    Method ParseResponse(pResponse As %String, pContentType As %String) As %DynamicObject [ Abstract ]
    {
        Quit ""
    }
}
```

### 2. Error Handling and Resilience

Implement robust error handling with retry logic:

```objectscript
/// Retry mechanism for failed requests
Method ExecuteWithRetry(pRequest As %String, pMaxRetries As %Integer = 3) As %Status
{
    Set tSC = $$$OK
    Set tAttempt = 0
    
    While (tAttempt < pMaxRetries) {
        Set tAttempt = tAttempt + 1
        
        Try {
            Set tResult = ..ExecuteRequest("POST", pRequest)
            // Successful execution
            Quit
        }
        Catch ex {
            If (tAttempt >= pMaxRetries) {
                Set tSC = ex.AsStatus()
            } Else {
                // Exponential backoff
                Hang (2 ** tAttempt)
            }
        }
    }
    
    Quit tSC
}
```

### 3. Response Caching

Implement caching for frequently accessed data:

```objectscript
Property CacheTimeout As %Integer [ InitialExpression = 300 ]; // 5 minutes
Property ResponseCache [ MultiDimensional ];

Method GetCachedResponse(pKey As %String) As %String
{
    If $Data(..ResponseCache(pKey)) {
        Set tCacheData = ..ResponseCache(pKey)
        Set tTimestamp = $Piece(tCacheData, "||", 1)
        Set tResponse = $Piece(tCacheData, "||", 2)
        
        If (($ZTimestamp - tTimestamp) < ..CacheTimeout) {
            Quit tResponse
        }
    }
    
    Quit ""
}
```

## REST API Adapter Example

### Basic REST Adapter Implementation

```objectscript
/// REST API Adapter implementation
Class Patterns.Integration.RESTAdapter Extends Patterns.Integration.ExternalAPIAdapter
{
    /// HTTP client instance
    Property HTTPClient As %Net.HttpRequest;
    
    /// Constructor
    Method %OnNew(pBaseURL As %String) As %Status
    {
        Set tSC = $$$OK
        Try {
            Set ..BaseURL = pBaseURL
            Set ..HTTPClient = ##class(%Net.HttpRequest).%New()
            Set ..HTTPClient.Server = $Piece(pBaseURL, "//", 2)
            Set ..HTTPClient.Https = ($Find(pBaseURL, "https") > 0)
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        Quit tSC
    }
    
    /// Execute REST API request
    Method ExecuteRequest(pMethod As %String, pEndpoint As %String, pPayload As %String = "") As %String
    {
        Set tResponse = ""
        
        Try {
            // Set headers
            Do ..HTTPClient.SetHeader("Content-Type", "application/json")
            Do ..HTTPClient.SetHeader("Accept", "application/json")
            
            // Add authentication if configured
            If (..Credentials '= "") {
                Do ..HTTPClient.SetHeader("Authorization", "Bearer "_..Credentials)
            }
            
            // Execute request based on method
            If (pMethod = "GET") {
                Do ..HTTPClient.Get(pEndpoint)
            }
            ElseIf (pMethod = "POST") {
                Do ..HTTPClient.EntityBody.Write(pPayload)
                Do ..HTTPClient.Post(pEndpoint)
            }
            ElseIf (pMethod = "PUT") {
                Do ..HTTPClient.EntityBody.Write(pPayload)
                Do ..HTTPClient.Put(pEndpoint)
            }
            ElseIf (pMethod = "DELETE") {
                Do ..HTTPClient.Delete(pEndpoint)
            }
            
            // Get response
            Set tResponse = ..HTTPClient.HttpResponse.Data.Read()
        }
        Catch ex {
            Set tResponse = "{""error"":"""_ex.DisplayString()_"""}"
        }
        
        Quit tResponse
    }
    
    /// Parse JSON response
    Method ParseResponse(pResponse As %String, pContentType As %String = "application/json") As %DynamicObject
    {
        Set tResult = ""
        
        Try {
            If (pContentType [ "json") {
                Set tResult = ##class(%DynamicObject).%FromJSON(pResponse)
            }
            ElseIf (pContentType [ "xml") {
                // XML parsing would go here
                Set tResult = ##class(%DynamicObject).%New()
                Set tResult.xml = pResponse
            }
            Else {
                Set tResult = ##class(%DynamicObject).%New()
                Set tResult.text = pResponse
            }
        }
        Catch ex {
            Set tResult = ##class(%DynamicObject).%New()
            Set tResult.error = ex.DisplayString()
        }
        
        Quit tResult
    }
    
    /// Authenticate with API
    Method Authenticate() As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Example OAuth2 authentication
            Set tAuthResponse = ..ExecuteRequest("POST", "/oauth/token", 
                "{""grant_type"":""client_credentials"",""client_id"":""id"",""client_secret"":""secret""}")
            
            Set tAuthData = ..ParseResponse(tAuthResponse)
            If tAuthData.%IsDefined("access_token") {
                Set ..Credentials = tAuthData."access_token"
            }
            Else {
                Set tSC = $$$ERROR($$$GeneralError, "Authentication failed")
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}
```

### Practical REST API Usage Example

```objectscript
/// Example: Weather API Adapter
Class Patterns.Examples.WeatherAPIAdapter Extends Patterns.Integration.RESTAdapter
{
    Parameter APIKEY = "your_api_key_here";
    
    /// Get current weather for a city
    Method GetWeather(pCity As %String) As %DynamicObject
    {
        // Check cache first
        Set tCacheKey = "weather_"_pCity
        Set tCached = ..GetCachedResponse(tCacheKey)
        If (tCached '= "") {
            Quit ..ParseResponse(tCached)
        }
        
        // Make API call
        Set tEndpoint = "/weather?q="_pCity_"&appid="_..#APIKEY
        Set tResponse = ..ExecuteRequest("GET", tEndpoint)
        
        // Cache the response
        Set ..ResponseCache(tCacheKey) = $ZTimestamp_"||"_tResponse
        
        Quit ..ParseResponse(tResponse)
    }
    
    /// Get weather forecast
    Method GetForecast(pCity As %String, pDays As %Integer = 5) As %DynamicObject
    {
        Set tEndpoint = "/forecast?q="_pCity_"&cnt="_pDays_"&appid="_..#APIKEY
        Set tResponse = ..ExecuteRequest("GET", tEndpoint)
        Quit ..ParseResponse(tResponse)
    }
}
```

## SOAP Service Adapter Pattern

### SOAP Adapter Implementation

```objectscript
/// SOAP Web Service Adapter
Class Patterns.Integration.SOAPAdapter Extends Patterns.Integration.ExternalAPIAdapter
{
    /// WSDL URL
    Property WSDLURL As %String;
    
    /// SOAP Action
    Property SOAPAction As %String;
    
    /// SOAP Namespace
    Property SOAPNamespace As %String;
    
    /// Build SOAP envelope
    Method BuildSOAPEnvelope(pBody As %String) As %String
    {
        Set tEnvelope = "<?xml version=""1.0"" encoding=""UTF-8""?>"
        Set tEnvelope = tEnvelope_"<soap:Envelope "
        Set tEnvelope = tEnvelope_"xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"" "
        Set tEnvelope = tEnvelope_"xmlns:ns="""_..SOAPNamespace_""">"
        Set tEnvelope = tEnvelope_"<soap:Header/>"
        Set tEnvelope = tEnvelope_"<soap:Body>"
        Set tEnvelope = tEnvelope_pBody
        Set tEnvelope = tEnvelope_"</soap:Body>"
        Set tEnvelope = tEnvelope_"</soap:Envelope>"
        
        Quit tEnvelope
    }
    
    /// Execute SOAP request
    Method ExecuteRequest(pMethod As %String, pEndpoint As %String, pPayload As %String = "") As %String
    {
        Set tResponse = ""
        
        Try {
            Set tHTTP = ##class(%Net.HttpRequest).%New()
            Set tHTTP.Server = $Piece(..BaseURL, "//", 2)
            Set tHTTP.Https = ($Find(..BaseURL, "https") > 0)
            
            // Set SOAP headers
            Do tHTTP.SetHeader("Content-Type", "text/xml; charset=utf-8")
            Do tHTTP.SetHeader("SOAPAction", ..SOAPAction)
            
            // Build and send SOAP envelope
            Set tEnvelope = ..BuildSOAPEnvelope(pPayload)
            Do tHTTP.EntityBody.Write(tEnvelope)
            Do tHTTP.Post(pEndpoint)
            
            // Get response
            Set tResponse = tHTTP.HttpResponse.Data.Read()
        }
        Catch ex {
            Set tResponse = "<error>"_ex.DisplayString()_"</error>"
        }
        
        Quit tResponse
    }
    
    /// Parse SOAP response
    Method ParseSOAPResponse(pResponse As %String) As %DynamicObject
    {
        Set tResult = ##class(%DynamicObject).%New()
        
        Try {
            // Extract SOAP body content (simplified)
            Set tBodyStart = $Find(pResponse, "<soap:Body>")
            Set tBodyEnd = $Find(pResponse, "</soap:Body>")
            
            If (tBodyStart && tBodyEnd) {
                Set tBody = $Extract(pResponse, tBodyStart, tBodyEnd - 12)
                Set tResult.body = tBody
                Set tResult.success = 1
            }
            Else {
                Set tResult.error = "Invalid SOAP response"
                Set tResult.success = 0
            }
        }
        Catch ex {
            Set tResult.error = ex.DisplayString()
            Set tResult.success = 0
        }
        
        Quit tResult
    }
}
```

### SOAP Service Usage Example

```objectscript
/// Example: Healthcare SOAP Service Adapter
Class Patterns.Examples.PatientSOAPAdapter Extends Patterns.Integration.SOAPAdapter
{
    /// Constructor
    Method %OnNew() As %Status
    {
        Set tSC = ##super("https://healthcare.example.com/soap")
        Set ..SOAPNamespace = "http://healthcare.example.com/patient"
        Set ..WSDLURL = "https://healthcare.example.com/soap?wsdl"
        Quit tSC
    }
    
    /// Get patient information
    Method GetPatient(pPatientId As %String) As %DynamicObject
    {
        Set ..SOAPAction = "GetPatient"
        
        Set tBody = "<ns:GetPatient>"
        Set tBody = tBody_"<ns:PatientId>"_pPatientId_"</ns:PatientId>"
        Set tBody = tBody_"</ns:GetPatient>"
        
        Set tResponse = ..ExecuteRequest("POST", "/PatientService", tBody)
        Quit ..ParseSOAPResponse(tResponse)
    }
    
    /// Update patient record
    Method UpdatePatient(pPatientId As %String, pData As %DynamicObject) As %Status
    {
        Set ..SOAPAction = "UpdatePatient"
        
        Set tBody = "<ns:UpdatePatient>"
        Set tBody = tBody_"<ns:PatientId>"_pPatientId_"</ns:PatientId>"
        Set tBody = tBody_"<ns:FirstName>"_pData.firstName_"</ns:FirstName>"
        Set tBody = tBody_"<ns:LastName>"_pData.lastName_"</ns:LastName>"
        Set tBody = tBody_"<ns:DateOfBirth>"_pData.dob_"</ns:DateOfBirth>"
        Set tBody = tBody_"</ns:UpdatePatient>"
        
        Set tResponse = ..ExecuteRequest("POST", "/PatientService", tBody)
        Set tResult = ..ParseSOAPResponse(tResponse)
        
        Quit $Select(tResult.success:$$$OK,1:$$$ERROR($$$GeneralError, tResult.error))
    }
}
```

## Database Adapter Examples

### Generic Database Adapter

```objectscript
/// Database Adapter for external database connections
Class Patterns.Integration.DatabaseAdapter Extends %RegisteredObject
{
    /// Connection string
    Property ConnectionString As %String;
    
    /// Database type (MySQL, PostgreSQL, Oracle, etc.)
    Property DatabaseType As %String;
    
    /// Connection object
    Property Connection As %SQL.Connection;
    
    /// Establish database connection
    Method Connect() As %Status
    {
        Set tSC = $$$OK
        
        Try {
            Set ..Connection = ##class(%SQL.Connection).%New()
            
            // Configure based on database type
            If (..DatabaseType = "MySQL") {
                Set tSC = ..Connection.Connect("MySQL", ..ConnectionString)
            }
            ElseIf (..DatabaseType = "PostgreSQL") {
                Set tSC = ..Connection.Connect("PostgreSQL", ..ConnectionString)
            }
            ElseIf (..DatabaseType = "Oracle") {
                Set tSC = ..Connection.Connect("Oracle", ..ConnectionString)
            }
            Else {
                Set tSC = $$$ERROR($$$GeneralError, "Unsupported database type")
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Execute query and return results
    Method ExecuteQuery(pSQL As %String, pParameters... As %String) As %SQL.Statement
    {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(pSQL)
        
        If $$$ISOK(tSC) {
            Set tResultSet = tStatement.%Execute(pParameters...)
            Quit tResultSet
        }
        
        Quit ""
    }
    
    /// Execute non-query command (INSERT, UPDATE, DELETE)
    Method ExecuteNonQuery(pSQL As %String, pParameters... As %String) As %Status
    {
        Set tSC = $$$OK
        
        Try {
            Set tStatement = ##class(%SQL.Statement).%New()
            Set tSC = tStatement.%Prepare(pSQL)
            
            If $$$ISOK(tSC) {
                Set tResult = tStatement.%Execute(pParameters...)
                If (tResult.%SQLCODE '= 0) {
                    Set tSC = $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)
                }
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
    
    /// Map external data to IRIS objects
    Method MapToObject(pResultSet As %SQL.Statement, pClassName As %String) As %RegisteredObject
    {
        Set tObject = ""
        
        Try {
            If pResultSet.%Next() {
                Set tObject = $ClassMethod(pClassName, "%New")
                
                // Map columns to properties
                Set tMetadata = pResultSet.%GetMetadata()
                Set tColCount = tMetadata.columns.Count()
                
                For i=1:1:tColCount {
                    Set tColName = tMetadata.columns.GetAt(i).colName
                    Set tValue = pResultSet.%GetData(i)
                    
                    // Set property if it exists
                    If ##class(%Dictionary.PropertyDefinition).%ExistsId(pClassName_"||"_tColName) {
                        Set $Property(tObject, tColName) = tValue
                    }
                }
            }
        }
        Catch ex {
            // Log error but continue
        }
        
        Quit tObject
    }
    
    /// Disconnect from database
    Method Disconnect() As %Status
    {
        Set tSC = $$$OK
        
        Try {
            If $IsObject(..Connection) {
                Set tSC = ..Connection.Disconnect()
            }
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}
```

### Specific Database Adapter Example

```objectscript
/// MongoDB Adapter Example
Class Patterns.Examples.MongoDBAdapter Extends Patterns.Integration.DatabaseAdapter
{
    /// MongoDB specific properties
    Property Database As %String;
    Property Collection As %String;
    
    /// Constructor
    Method %OnNew(pHost As %String, pPort As %Integer, pDatabase As %String) As %Status
    {
        Set ..DatabaseType = "MongoDB"
        Set ..ConnectionString = pHost_":"_pPort
        Set ..Database = pDatabase
        Quit $$$OK
    }
    
    /// Find documents in collection
    Method Find(pCollection As %String, pQuery As %DynamicObject) As %DynamicArray
    {
        Set tResults = ##class(%DynamicArray).%New()
        
        Try {
            // Simulate MongoDB find operation
            Set tSQL = "SELECT * FROM "_pCollection_" WHERE "
            Set tIterator = pQuery.%GetIterator()
            Set tFirst = 1
            
            While tIterator.%GetNext(.tKey, .tValue) {
                If 'tFirst Set tSQL = tSQL_" AND "
                Set tSQL = tSQL_tKey_" = ?"
                Set tParams(tKey) = tValue
                Set tFirst = 0
            }
            
            Set tResultSet = ..ExecuteQuery(tSQL, tParams...)
            
            While tResultSet.%Next() {
                Set tDoc = ##class(%DynamicObject).%New()
                // Map result to dynamic object
                Do tResults.%Push(tDoc)
            }
        }
        Catch ex {
            // Handle error
        }
        
        Quit tResults
    }
    
    /// Insert document into collection
    Method Insert(pCollection As %String, pDocument As %DynamicObject) As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Convert document to SQL INSERT
            Set tSQL = "INSERT INTO "_pCollection_" ("
            Set tValues = ") VALUES ("
            Set tIterator = pDocument.%GetIterator()
            Set tFirst = 1
            
            While tIterator.%GetNext(.tKey, .tValue) {
                If 'tFirst {
                    Set tSQL = tSQL_", "
                    Set tValues = tValues_", "
                }
                Set tSQL = tSQL_tKey
                Set tValues = tValues_"?"
                Set tParams($Increment(tParams)) = tValue
                Set tFirst = 0
            }
            
            Set tSQL = tSQL_tValues_")"
            Set tSC = ..ExecuteNonQuery(tSQL, tParams...)
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}
```

## Performance Considerations for Adapters

### 1. Connection Pooling

Implement connection pooling to avoid connection overhead:

```objectscript
/// Connection pool manager
Class Patterns.Integration.ConnectionPool Extends %RegisteredObject
{
    /// Pool of available connections
    Property AvailableConnections As list Of %RegisteredObject;
    
    /// Pool of active connections
    Property ActiveConnections As list Of %RegisteredObject;
    
    /// Maximum pool size
    Parameter MAXPOOLSIZE = 10;
    
    /// Get connection from pool
    Method GetConnection() As %RegisteredObject
    {
        Set tConnection = ""
        
        // Check for available connection
        If (..AvailableConnections.Count() > 0) {
            Set tConnection = ..AvailableConnections.GetAt(1)
            Do ..AvailableConnections.RemoveAt(1)
            Do ..ActiveConnections.Insert(tConnection)
        }
        ElseIf (..ActiveConnections.Count() < ..#MAXPOOLSIZE) {
            // Create new connection
            Set tConnection = ..CreateNewConnection()
            Do ..ActiveConnections.Insert(tConnection)
        }
        
        Quit tConnection
    }
    
    /// Return connection to pool
    Method ReturnConnection(pConnection As %RegisteredObject)
    {
        Do ..ActiveConnections.RemoveAt(..ActiveConnections.Find(pConnection))
        Do ..AvailableConnections.Insert(pConnection)
    }
}
```

### 2. Async Processing

Implement asynchronous processing for long-running operations:

```objectscript
/// Async adapter base class
Class Patterns.Integration.AsyncAdapter Extends %RegisteredObject
{
    /// Process request asynchronously
    Method ProcessAsync(pRequest As %String) As %String
    {
        // Generate unique job ID
        Set tJobId = $System.Util.CreateGUID()
        
        // Queue the job
        Job ..ProcessJob(tJobId, pRequest)
        
        Quit tJobId
    }
    
    /// Background job processor
    ClassMethod ProcessJob(pJobId As %String, pRequest As %String)
    {
        // Store job status
        Set ^AdapterJobs(pJobId, "status") = "processing"
        Set ^AdapterJobs(pJobId, "startTime") = $ZDateTime($ZTimestamp, 3)
        
        Try {
            // Process the request
            Set tResult = ..ProcessRequest(pRequest)
            
            // Store result
            Set ^AdapterJobs(pJobId, "result") = tResult
            Set ^AdapterJobs(pJobId, "status") = "completed"
        }
        Catch ex {
            Set ^AdapterJobs(pJobId, "status") = "failed"
            Set ^AdapterJobs(pJobId, "error") = ex.DisplayString()
        }
        
        Set ^AdapterJobs(pJobId, "endTime") = $ZDateTime($ZTimestamp, 3)
    }
    
    /// Check job status
    Method GetJobStatus(pJobId As %String) As %DynamicObject
    {
        Set tStatus = ##class(%DynamicObject).%New()
        
        If $Data(^AdapterJobs(pJobId)) {
            Set tStatus.jobId = pJobId
            Set tStatus.status = $Get(^AdapterJobs(pJobId, "status"))
            Set tStatus.startTime = $Get(^AdapterJobs(pJobId, "startTime"))
            Set tStatus.endTime = $Get(^AdapterJobs(pJobId, "endTime"))
            
            If (tStatus.status = "completed") {
                Set tStatus.result = $Get(^AdapterJobs(pJobId, "result"))
            }
            ElseIf (tStatus.status = "failed") {
                Set tStatus.error = $Get(^AdapterJobs(pJobId, "error"))
            }
        }
        Else {
            Set tStatus.status = "not found"
        }
        
        Quit tStatus
    }
}
```

### 3. Batch Processing

Optimize for batch operations:

```objectscript
/// Batch processing adapter
Class Patterns.Integration.BatchAdapter Extends %RegisteredObject
{
    /// Batch size for processing
    Parameter BATCHSIZE = 100;
    
    /// Process items in batches
    Method ProcessBatch(pItems As %ListOfDataTypes) As %Status
    {
        Set tSC = $$$OK
        Set tBatch = ##class(%ListOfDataTypes).%New()
        
        For i=1:1:pItems.Count() {
            Do tBatch.Insert(pItems.GetAt(i))
            
            // Process batch when size is reached
            If (tBatch.Count() >= ..#BATCHSIZE) {
                Set tSC = ..ExecuteBatch(tBatch)
                If $$$ISERR(tSC) Quit
                
                // Clear batch for next set
                Set tBatch = ##class(%ListOfDataTypes).%New()
            }
        }
        
        // Process remaining items
        If (tBatch.Count() > 0) {
            Set tSC = ..ExecuteBatch(tBatch)
        }
        
        Quit tSC
    }
    
    /// Execute batch operation
    Method ExecuteBatch(pBatch As %ListOfDataTypes) As %Status
    {
        Set tSC = $$$OK
        
        Try {
            // Build batch request
            Set tRequest = ##class(%DynamicArray).%New()
            
            For i=1:1:pBatch.Count() {
                Do tRequest.%Push(pBatch.GetAt(i))
            }
            
            // Send batch request
            Set tResponse = ..SendBatchRequest(tRequest)
            
            // Process batch response
            Set tSC = ..ProcessBatchResponse(tResponse)
        }
        Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
    }
}
```

## Monitoring and Logging

### Performance Metrics Collection

```objectscript
/// Adapter with performance monitoring
Class Patterns.Integration.MonitoredAdapter Extends %RegisteredObject
{
    /// Track performance metrics
    Property Metrics As %ArrayOfDataTypes;
    
    /// Execute with monitoring
    Method ExecuteMonitored(pOperation As %String, pRequest As %String) As %String
    {
        Set tStartTime = $ZH
        Set tResult = ""
        
        Try {
            // Execute operation
            Set tResult = ..Execute(pOperation, pRequest)
            
            // Record success metrics
            Do ..RecordMetric(pOperation, "success", $ZH - tStartTime)
        }
        Catch ex {
            // Record failure metrics
            Do ..RecordMetric(pOperation, "failure", $ZH - tStartTime)
            Set tResult = ""
        }
        
        Quit tResult
    }
    
    /// Record performance metric
    Method RecordMetric(pOperation As %String, pStatus As %String, pDuration As %Decimal)
    {
        Set tMetric = ##class(%DynamicObject).%New()
        Set tMetric.operation = pOperation
        Set tMetric.status = pStatus
        Set tMetric.duration = pDuration
        Set tMetric.timestamp = $ZDateTime($ZTimestamp, 3)
        
        // Store in global for analysis
        Set tKey = $ZDate($Horolog, 3)_"_"_pOperation
        Set ^AdapterMetrics(tKey, $Increment(^AdapterMetrics(tKey))) = tMetric.%ToJSON()
    }
    
    /// Get performance statistics
    Method GetStatistics(pOperation As %String, pDate As %String = "") As %DynamicObject
    {
        If (pDate = "") Set pDate = $ZDate($Horolog, 3)
        
        Set tStats = ##class(%DynamicObject).%New()
        Set tStats.operation = pOperation
        Set tStats.date = pDate
        Set tStats.totalCalls = 0
        Set tStats.successCount = 0
        Set tStats.failureCount = 0
        Set tStats.averageDuration = 0
        Set tTotalDuration = 0
        
        Set tKey = pDate_"_"_pOperation
        Set i = ""
        For {
            Set i = $Order(^AdapterMetrics(tKey, i))
            Quit:i=""
            
            Set tMetric = ##class(%DynamicObject).%FromJSON(^AdapterMetrics(tKey, i))
            Set tStats.totalCalls = tStats.totalCalls + 1
            
            If (tMetric.status = "success") {
                Set tStats.successCount = tStats.successCount + 1
            }
            Else {
                Set tStats.failureCount = tStats.failureCount + 1
            }
            
            Set tTotalDuration = tTotalDuration + tMetric.duration
        }
        
        If (tStats.totalCalls > 0) {
            Set tStats.averageDuration = tTotalDuration / tStats.totalCalls
            Set tStats.successRate = (tStats.successCount / tStats.totalCalls) * 100
        }
        
        Quit tStats
    }
}
```

## Best Practices Summary

### 1. Design Principles
- **Single Responsibility**: Each adapter should handle one external system
- **Interface Segregation**: Define clear interfaces for different integration types
- **Dependency Inversion**: Depend on abstractions, not concrete implementations

### 2. Error Handling
- Implement retry mechanisms with exponential backoff
- Use circuit breaker pattern for failing services
- Log all errors with context for debugging

### 3. Performance Optimization
- Use connection pooling to reduce overhead
- Implement caching for frequently accessed data
- Process large datasets in batches
- Use asynchronous processing for long-running operations

### 4. Security Considerations
- Never hardcode credentials in adapter code
- Use secure storage for API keys and passwords
- Implement proper authentication mechanisms
- Validate all input and output data

### 5. Testing Strategies
- Create mock adapters for unit testing
- Use test doubles for external dependencies
- Implement integration tests with test endpoints
- Monitor adapter performance in production

### 6. Documentation Requirements
- Document all adapter interfaces clearly
- Provide usage examples for each adapter type
- Include error codes and handling instructions
- Maintain version compatibility documentation

## Conclusion

The Adapter pattern is essential for enterprise integration in IRIS applications. By following these best practices and examples, developers can create maintainable, performant, and secure integrations with external systems while maintaining loose coupling and flexibility in their architecture.

## Related Documentation

- [Adapter Pattern Implementation](../patterns/gof/Chapter07-Adapter.md)
- [IRIS Integration Documentation](https://docs.intersystems.com/iris/csp/docbook/DocBook.UI.Page.cls)
- [Enterprise Integration Patterns](https://www.enterpriseintegrationpatterns.com/)
