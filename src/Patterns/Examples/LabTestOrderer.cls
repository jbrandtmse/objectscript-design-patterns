/// Healthcare Lab System - Test Orderer Subsystem
/// Complex subsystem for ordering laboratory tests
/// Handles test validation, patient verification, and order management
Class Patterns.Examples.LabTestOrderer Extends %RegisteredObject
{

/// Patient database (simulated)
Property PatientDatabase [ MultiDimensional ];

/// Available test catalog
Property TestCatalog [ MultiDimensional ];

/// Order tracking
Property OrderCounter As %Integer [ InitialExpression = 1000 ];

/// Insurance verification cache
Property InsuranceCache [ MultiDimensional ];

/// Initialize test orderer with complex setup
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Initialize patient database
        Set ..PatientDatabase("P001", "name") = "John Doe"
        Set ..PatientDatabase("P001", "dob") = "1980-05-15"
        Set ..PatientDatabase("P001", "insurance") = "INS-12345"
        Set ..PatientDatabase("P002", "name") = "Jane Smith"
        Set ..PatientDatabase("P002", "dob") = "1975-10-22"
        Set ..PatientDatabase("P002", "insurance") = "INS-67890"
        
        // Initialize test catalog with complexity
        Set ..TestCatalog("CBC", "name") = "Complete Blood Count"
        Set ..TestCatalog("CBC", "code") = "85025"
        Set ..TestCatalog("CBC", "requirements") = "Purple top tube, 2ml"
        Set ..TestCatalog("CBC", "turnaround") = "4 hours"
        
        Set ..TestCatalog("CMP", "name") = "Comprehensive Metabolic Panel"
        Set ..TestCatalog("CMP", "code") = "80053"
        Set ..TestCatalog("CMP", "requirements") = "Gold/Red top, fasting 8hrs"
        Set ..TestCatalog("CMP", "turnaround") = "6 hours"
        
        Set ..TestCatalog("TSH", "name") = "Thyroid Stimulating Hormone"
        Set ..TestCatalog("TSH", "code") = "84443"
        Set ..TestCatalog("TSH", "requirements") = "Red top tube, 1ml"
        Set ..TestCatalog("TSH", "turnaround") = "24 hours"
        
        Set ..TestCatalog("HBA1C", "name") = "Hemoglobin A1C"
        Set ..TestCatalog("HBA1C", "code") = "83036"
        Set ..TestCatalog("HBA1C", "requirements") = "Lavender top, no fasting"
        Set ..TestCatalog("HBA1C", "turnaround") = "24 hours"
        
        // Initialize insurance cache
        Set ..InsuranceCache("initialized") = $HOROLOG
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Complex order creation with multiple validation steps
Method CreateTestOrder(pPatientId As %String, pTestCode As %String, pPriority As %String = "ROUTINE") As %String
{
    Set tOrderInfo = ""
    
    // Step 1: Validate patient exists
    If '$DATA(..PatientDatabase(pPatientId)) {
        Quit "ERROR:PATIENT_NOT_FOUND:"_pPatientId
    }
    
    // Step 2: Validate test code
    If '$DATA(..TestCatalog(pTestCode)) {
        Quit "ERROR:INVALID_TEST_CODE:"_pTestCode
    }
    
    // Step 3: Check insurance authorization (complex process)
    Set tAuthResult = ..checkInsuranceAuthorization(pPatientId, pTestCode)
    If tAuthResult '= "APPROVED" {
        Quit "ERROR:INSURANCE_AUTH_FAILED:"_tAuthResult
    }
    
    // Step 4: Check for contraindications
    Set tContraCheck = ..checkContraindications(pPatientId, pTestCode)
    If tContraCheck '= "" {
        Quit "ERROR:CONTRAINDICATION:"_tContraCheck
    }
    
    // Step 5: Generate order ID
    Set ..OrderCounter = ..OrderCounter + 1
    Set tOrderId = "LAB-"_$ZDATE($HOROLOG, 8)_"-"_..OrderCounter
    
    // Step 6: Build complex order information
    Set tOrderInfo = "ORDER:"_tOrderId
    Set tOrderInfo = tOrderInfo_"|PATIENT:"_pPatientId
    Set tOrderInfo = tOrderInfo_"|TEST:"_pTestCode
    Set tOrderInfo = tOrderInfo_"|NAME:"_..TestCatalog(pTestCode, "name")
    Set tOrderInfo = tOrderInfo_"|PRIORITY:"_pPriority
    Set tOrderInfo = tOrderInfo_"|REQUIREMENTS:"_..TestCatalog(pTestCode, "requirements")
    Set tOrderInfo = tOrderInfo_"|CREATED:"_$ZDATETIME($HOROLOG, 3)
    
    // Step 7: Calculate collection time based on priority
    Set tCollectionTime = ..calculateCollectionTime(pPriority)
    Set tOrderInfo = tOrderInfo_"|COLLECTION:"_tCollectionTime
    
    Quit tOrderInfo
}

/// Validate order with complex business rules
Method ValidateOrderDetails(pOrderString As %String) As %Boolean
{
    // Complex validation logic
    If pOrderString = "" Quit 0
    If pOrderString '[ "ORDER:" Quit 0
    If pOrderString '[ "PATIENT:" Quit 0
    If pOrderString '[ "TEST:" Quit 0
    
    // Extract and validate components
    Set tOrderId = $PIECE($PIECE(pOrderString, "ORDER:", 2), "|", 1)
    If tOrderId = "" Quit 0
    
    Set tPatientId = $PIECE($PIECE(pOrderString, "PATIENT:", 2), "|", 1)
    If '$DATA(..PatientDatabase(tPatientId)) Quit 0
    
    Quit 1
}

/// Get patient information
Method GetPatientInfo(pPatientId As %String) As %String
{
    If '$DATA(..PatientDatabase(pPatientId)) {
        Quit "ERROR:PATIENT_NOT_FOUND"
    }
    
    Set tInfo = "ID:"_pPatientId
    Set tInfo = tInfo_"|NAME:"_..PatientDatabase(pPatientId, "name")
    Set tInfo = tInfo_"|DOB:"_..PatientDatabase(pPatientId, "dob")
    Set tInfo = tInfo_"|INSURANCE:"_..PatientDatabase(pPatientId, "insurance")
    
    Quit tInfo
}

/// Complex insurance authorization check
Method checkInsuranceAuthorization(pPatientId As %String, pTestCode As %String) As %String [ Private ]
{
    // Simulate complex insurance verification
    Set tInsurance = ..PatientDatabase(pPatientId, "insurance")
    
    // Check cache first
    Set tCacheKey = pPatientId_":"_pTestCode
    If $DATA(..InsuranceCache(tCacheKey)) {
        Set tCachedResult = ..InsuranceCache(tCacheKey)
        Set tCacheTime = $PIECE(tCachedResult, ":", 1)
        // Cache valid for 1 hour (3600 seconds)
        If ($PIECE($HOROLOG, ",", 2) - tCacheTime) < 3600 {
            Quit $PIECE(tCachedResult, ":", 2)
        }
    }
    
    // Simulate authorization logic
    Set tApproved = 1
    
    // Some tests require pre-authorization
    If pTestCode = "MRI" Set tApproved = 0
    If pTestCode = "CT" Set tApproved = 0
    
    // Cache the result
    Set tResult = $SELECT(tApproved:"APPROVED", 1:"DENIED")
    Set ..InsuranceCache(tCacheKey) = $PIECE($HOROLOG, ",", 2)_":"_tResult
    
    Quit tResult
}

/// Check for test contraindications
Method checkContraindications(pPatientId As %String, pTestCode As %String) As %String [ Private ]
{
    // Simulate contraindication checking
    Set tContraindication = ""
    
    // Example: Check for pregnancy contraindications
    If pTestCode = "XRAY" {
        // Would check patient conditions in real system
        Set tContraindication = ""
    }
    
    // Example: Check for allergy contraindications
    If pTestCode = "CONTRAST" {
        // Would check patient allergies in real system
        Set tContraindication = ""
    }
    
    Quit tContraindication
}

/// Calculate collection time based on priority
Method calculateCollectionTime(pPriority As %String) As %String [ Private ]
{
    Set tCurrentTime = $PIECE($HOROLOG, ",", 2)
    Set tCollectionTime = tCurrentTime
    
    If pPriority = "STAT" {
        // Immediate collection
        Set tCollectionTime = tCurrentTime + 300  // 5 minutes
    } ElseIf pPriority = "URGENT" {
        // Within 1 hour
        Set tCollectionTime = tCurrentTime + 3600
    } Else {
        // Routine - within 4 hours
        Set tCollectionTime = tCurrentTime + 14400
    }
    
    // Convert to readable time
    Set tTime = $ZTIME(tCollectionTime)
    Quit tTime
}

/// Get test requirements
Method GetTestRequirements(pTestCode As %String) As %String
{
    If '$DATA(..TestCatalog(pTestCode)) {
        Quit "ERROR:TEST_NOT_FOUND"
    }
    
    Set tReq = "TEST:"_pTestCode
    Set tReq = tReq_"|NAME:"_..TestCatalog(pTestCode, "name")
    Set tReq = tReq_"|CODE:"_..TestCatalog(pTestCode, "code")
    Set tReq = tReq_"|REQUIREMENTS:"_..TestCatalog(pTestCode, "requirements")
    Set tReq = tReq_"|TURNAROUND:"_..TestCatalog(pTestCode, "turnaround")
    
    Quit tReq
}

/// Get available tests
Method GetAvailableTests() As %String
{
    Set tTests = ""
    Set tTestCode = ""
    
    For {
        Set tTestCode = $ORDER(..TestCatalog(tTestCode))
        Quit:tTestCode=""
        
        If tTests '= "" Set tTests = tTests_";"
        Set tTests = tTests_tTestCode_":"_..TestCatalog(tTestCode, "name")
    }
    
    Quit tTests
}

/// Get order statistics
Method GetStatistics() As %String
{
    Set tStats = "OrdersCreated:"_..OrderCounter
    Set tStats = tStats_"|PatientsRegistered:"_..countPatients()
    Set tStats = tStats_"|TestsAvailable:"_..countTests()
    Set tStats = tStats_"|CacheEntries:"_..countCacheEntries()
    
    Quit tStats
}

/// Count registered patients
Method countPatients() As %Integer [ Private ]
{
    Set tCount = 0
    Set tPatientId = ""
    
    For {
        Set tPatientId = $ORDER(..PatientDatabase(tPatientId))
        Quit:tPatientId=""
        Set tCount = tCount + 1
    }
    
    Quit tCount
}

/// Count available tests
Method countTests() As %Integer [ Private ]
{
    Set tCount = 0
    Set tTestCode = ""
    
    For {
        Set tTestCode = $ORDER(..TestCatalog(tTestCode))
        Quit:tTestCode=""
        Set tCount = tCount + 1
    }
    
    Quit tCount
}

/// Count cache entries
Method countCacheEntries() As %Integer [ Private ]
{
    Set tCount = 0
    Set tKey = ""
    
    For {
        Set tKey = $ORDER(..InsuranceCache(tKey))
        Quit:tKey=""
        If tKey '= "initialized" Set tCount = tCount + 1
    }
    
    Quit tCount
}

}
