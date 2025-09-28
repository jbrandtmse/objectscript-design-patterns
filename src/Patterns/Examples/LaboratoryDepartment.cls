/// Gang of Four Mediator Pattern - Laboratory Department Colleague
/// 
/// Purpose:
/// Represents the Laboratory Department in the hospital mediator system.
/// Handles lab test requests, processes samples, and provides results.
/// 
/// Features:
/// - Lab test processing
/// - Result reporting
/// - Critical value alerts
Class Patterns.Examples.LaboratoryDepartment Extends Patterns.GoF.Behavioral.Colleague
{

/// Department name
Property DepartmentName As %String [ InitialExpression = "Laboratory Department" ];

/// Test processing capacity
Property ProcessingCapacity As %Integer [ InitialExpression = 100 ];

/// Active tests being processed
Property ActiveTests As %Integer [ InitialExpression = 0 ];

/// Pending test queue
Property PendingTests As %ListOfObjects;

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Set ..ColleagueId = "LABORATORY"
    Set ..PendingTests = ##class(%ListOfObjects).%New()
    
    Quit tSC
}

/// Receive message from mediator
Method Receive(pEvent As %String, pData As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Log receipt
        Set ^LabDept.Messages($INCREMENT(^LabDept.Messages)) = 
            $LISTBUILD($ZDATETIME($HOROLOG, 3), pEvent, 
                       $SELECT($IsObject(pData):pData.%ToJSON(), 1:""))
        
        // Handle different message types
        If pEvent = "LAB_REQUEST" {
            Set tSC = ..HandleLabRequest(pData)
        } ElseIf pEvent = "EMERGENCY" {
            Set tSC = ..HandleEmergencyAlert(pData)
        } ElseIf pEvent = "CANCEL_TEST" {
            Set tSC = ..CancelTest(pData)
        } ElseIf pEvent = "STAT_REQUEST" {
            Set tSC = ..HandleStatRequest(pData)
        } Else {
            Do ..LogMessage(pEvent, pData)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle lab test request
Method HandleLabRequest(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Create test request
        Set tTestRequest = ##class(%DynamicObject).%New()
        Set tTestRequest.testId = $System.Util.CreateGUID()
        Set tTestRequest.patientId = pData.patientId
        Set tTestRequest.testType = pData.testType
        Set tTestRequest.requestingDept = pData.requestingDepartment
        Set tTestRequest.priority = pData.priority
        Set tTestRequest.requestTime = $ZDATETIME($HOROLOG, 3)
        Set tTestRequest.status = "PENDING"
        
        // Store test request
        Set ^LabDept.TestRequests(tTestRequest.testId) = tTestRequest.%ToJSON()
        
        // Process based on priority
        If pData.priority = "URGENT" || pData.priority = "CRITICAL" {
            Set tSC = ..ProcessStatTest(tTestRequest)
        } Else {
            // Add to regular queue
            Do ..PendingTests.Insert(tTestRequest)
            
            If ..ActiveTests < ..ProcessingCapacity {
                Do ..ProcessNextTest()
            }
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process STAT test
Method ProcessStatTest(pTestRequest As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        Set ..ActiveTests = ..ActiveTests + 1
        Set pTestRequest.status = "IN_PROGRESS"
        Set pTestRequest.startTime = $ZDATETIME($HOROLOG, 3)
        
        // Store active test
        Set ^LabDept.ActiveTests(pTestRequest.testId) = pTestRequest.%ToJSON()
        
        // Simulate test processing (30-60 seconds for STAT)
        Job ..ProcessTest(pTestRequest.testId, 1)::5
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process next test in queue
Method ProcessNextTest() [ Private ]
{
    Try {
        If ..PendingTests.Count() > 0 {
            Set tTestRequest = ..PendingTests.GetAt(1)
            Do ..PendingTests.RemoveAt(1)
            
            Set ..ActiveTests = ..ActiveTests + 1
            Set tTestRequest.status = "IN_PROGRESS"
            Set tTestRequest.startTime = $ZDATETIME($HOROLOG, 3)
            
            Set ^LabDept.ActiveTests(tTestRequest.testId) = tTestRequest.%ToJSON()
            
            // Simulate test processing
            Job ..ProcessTest(tTestRequest.testId, 0)::5
        }
    } Catch ex {
        // Log error
    }
}

/// Process test (simulated)
ClassMethod ProcessTest(pTestId As %String, pStat As %Boolean = 0) [ Private ]
{
    Try {
        // Simulate test duration
        If pStat {
            Hang $RANDOM(30) + 30  // 30-60 seconds for STAT
        } Else {
            Hang $RANDOM(120) + 60  // 60-180 seconds for routine
        }
        
        // Complete test
        If $Data(^LabDept.ActiveTests(pTestId)) {
            Set tTestJSON = ^LabDept.ActiveTests(pTestId)
            Set tTest = ##class(%DynamicObject).%FromJSON(tTestJSON)
            
            // Generate results
            Set tResults = ##class(%DynamicObject).%New()
            Set tResults.testId = pTestId
            Set tResults.patientId = tTest.patientId
            Set tResults.testType = tTest.testType
            Set tResults.results = ..GenerateMockResults(tTest.testType)
            Set tResults.critical = ($RANDOM(10) = 0)  // 10% critical values
            Set tResults.resultTime = $ZDATETIME($HOROLOG, 3)
            
            // Store results
            Set ^LabDept.Results(pTestId) = tResults.%ToJSON()
            Kill ^LabDept.ActiveTests(pTestId)
            
            // Send results through mediator
            Do ##class(LaboratoryDepartment).SendResults(pTestId, tResults)
        }
        
    } Catch ex {
        // Log error
    }
}

/// Generate mock results
ClassMethod GenerateMockResults(pTestType As %String) As %String [ Private ]
{
    Set tResults = "Test: "_pTestType_". "
    
    If pTestType = "CBC" {
        Set tResults = tResults_"WBC: "_($RANDOM(10)+5)_" K/uL, "
        Set tResults = tResults_"Hgb: "_($RANDOM(4)+12)_" g/dL, "
        Set tResults = tResults_"Plt: "_($RANDOM(200)+200)_" K/uL"
    } ElseIf pTestType = "BMP" {
        Set tResults = tResults_"Na: "_($RANDOM(10)+135)_" mmol/L, "
        Set tResults = tResults_"K: "_(3.5+($RANDOM(20)/10))_" mmol/L, "
        Set tResults = tResults_"Glucose: "_($RANDOM(50)+80)_" mg/dL"
    } Else {
        Set tResults = tResults_"Result: Within normal limits"
    }
    
    Quit tResults
}

/// Send test results
ClassMethod SendResults(pTestId As %String, pResults As %DynamicObject)
{
    Try {
        Set tDept = ##class(LaboratoryDepartment).%New()
        
        If $IsObject(tDept.Mediator) {
            Set tSC = tDept.Send("LAB_RESULT", pResults)
            
            // Send critical value alert if needed
            If pResults.critical {
                Set tAlert = ##class(%DynamicObject).%New()
                Set tAlert.patientId = pResults.patientId
                Set tAlert.testType = pResults.testType
                Set tAlert.criticalValue = pResults.results
                Set tAlert.department = "LABORATORY"
                
                Set tSC = tDept.Send("CRITICAL_VALUE_ALERT", tAlert)
            }
        }
        
    } Catch ex {
        // Log error
    }
}

/// Handle STAT request
Method HandleStatRequest(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    Set pData.priority = "URGENT"
    Set tSC = ..HandleLabRequest(pData)
    Quit tSC
}

/// Cancel test
Method CancelTest(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        Set tTestId = pData.testId
        
        // Check if test is in queue
        For i=..PendingTests.Count():-1:1 {
            Set tTest = ..PendingTests.GetAt(i)
            If tTest.testId = tTestId {
                Do ..PendingTests.RemoveAt(i)
                Set ^LabDept.CancelledTests(tTestId) = tTest.%ToJSON()
                Quit
            }
        }
        
        // Cannot cancel test in progress
        If $Data(^LabDept.ActiveTests(tTestId)) {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot cancel test in progress")
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle emergency alert
Method HandleEmergencyAlert(pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        Set ^LabDept.Emergencies($INCREMENT(^LabDept.Emergencies)) = pData.%ToJSON()
        
        If pData.type = "MASS_CASUALTY" {
            // Prepare for mass casualty blood work
            Do ..PrepareMassCasualtyProtocol()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Prepare mass casualty protocol
Method PrepareMassCasualtyProtocol() [ Private ]
{
    // Clear non-urgent tests
    Set tNewQueue = ##class(%ListOfObjects).%New()
    
    For i=1:1:..PendingTests.Count() {
        Set tTest = ..PendingTests.GetAt(i)
        If tTest.priority = "URGENT" || tTest.priority = "CRITICAL" {
            Do tNewQueue.Insert(tTest)
        }
    }
    
    Set ..PendingTests = tNewQueue
    Set ^LabDept.MassCasualty = $ZDATETIME($HOROLOG, 3)_" - Protocol activated"
}

/// Log message
Method LogMessage(pEvent As %String, pData As %DynamicObject) [ Private ]
{
    Set ^LabDept.GeneralMessages($INCREMENT(^LabDept.GeneralMessages)) = 
        $LISTBUILD($ZDATETIME($HOROLOG, 3), pEvent, 
                   $SELECT($IsObject(pData):pData.%ToJSON(), 1:""))
}

/// Get department status
Method GetStatus() As %String
{
    Set tStatus = ##class(%DynamicObject).%New()
    Set tStatus.department = "LABORATORY"
    Set tStatus.activeTests = ..ActiveTests_"/"_..ProcessingCapacity
    Set tStatus.queueLength = ..PendingTests.Count()
    Set tStatus.status = $SELECT(..ActiveTests >= ..ProcessingCapacity:"AT_CAPACITY",
                                 ..PendingTests.Count() > 20:"BACKLOG",
                                 1:"AVAILABLE")
    
    Quit tStatus.%ToJSON()
}

}
