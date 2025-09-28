/// Gang of Four Mediator Pattern - Concrete Mediator Implementation
/// 
/// Purpose:
/// Concrete implementation of the Mediator pattern that manages
/// communication between colleagues with message routing, filtering,
/// and asynchronous event handling.
/// 
/// Features:
/// - Message routing with filtering
/// - Broadcast and targeted messaging
/// - Event queue for async processing
/// - Error handling and recovery
/// - Message transformation
Class Patterns.GoF.Behavioral.ConcreteMediator Extends Patterns.GoF.Behavioral.Mediator
{

/// Message routing rules (colleague ID -> list of event types)
Property RoutingRules As %ArrayOfDataTypes [ Private ];

/// Event queue for asynchronous processing
Property EventQueue As %ListOfObjects [ Private ];

/// Flag to indicate if async processing is enabled
Property AsyncEnabled As %Boolean [ InitialExpression = 0 ];

/// Message filters for specific colleagues
Property MessageFilters As %ArrayOfDataTypes [ Private ];

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) Quit tSC
    
    Set ..RoutingRules = ##class(%ArrayOfDataTypes).%New()
    Set ..EventQueue = ##class(%ListOfObjects).%New()
    Set ..MessageFilters = ##class(%ArrayOfDataTypes).%New()
    
    Quit $$$OK
}

/// Notify mediator of an event from a colleague
Method Notify(pSender As Patterns.GoF.Behavioral.Colleague, pEvent As %String, pData As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Log the event
        Do ..LogEvent(pSender, pEvent, pData)
        
        // Apply message transformation if needed
        Set tTransformedData = ..TransformMessage(pEvent, pData)
        
        // Route based on event type
        If pEvent = "BROADCAST" {
            Set tSC = ..BroadcastMessage(pSender, pEvent, tTransformedData)
        } ElseIf pEvent = "REQUEST" {
            Set tSC = ..RouteRequest(pSender, tTransformedData)
        } ElseIf pEvent = "RESPONSE" {
            Set tSC = ..RouteResponse(pSender, tTransformedData)
        } ElseIf pEvent = "NOTIFICATION" {
            Set tSC = ..RouteNotification(pSender, tTransformedData)
        } ElseIf pEvent = "EMERGENCY" {
            Set tSC = ..HandleEmergency(pSender, tTransformedData)
        } Else {
            // Default routing based on rules
            Set tSC = ..RouteByRules(pSender, pEvent, tTransformedData)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Do ..HandleError(pSender, pEvent, tSC)
    }
    
    Quit tSC
}

/// Route request to appropriate colleague
Method RouteRequest(pSender As Patterns.GoF.Behavioral.Colleague, pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Extract target from data
        If $IsObject(pData) && pData.%IsDefined("targetId") {
            Set tTargetId = pData.targetId
            
            // Find target colleague
            For i=1:1:..Colleagues.Count() {
                Set tColleague = ..Colleagues.GetAt(i)
                If tColleague.ColleagueId = tTargetId {
                    Set tSC = tColleague.Receive("REQUEST", pData)
                    Quit
                }
            }
        } Else {
            // No specific target, broadcast to all
            Set tSC = ..BroadcastMessage(pSender, "REQUEST", pData)
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Route response to original requester
Method RouteResponse(pSender As Patterns.GoF.Behavioral.Colleague, pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Extract original requester from data
        If $IsObject(pData) && pData.%IsDefined("requesterId") {
            Set tRequesterId = pData.requesterId
            
            // Find requester colleague
            For i=1:1:..Colleagues.Count() {
                Set tColleague = ..Colleagues.GetAt(i)
                If tColleague.ColleagueId = tRequesterId {
                    Set tSC = tColleague.Receive("RESPONSE", pData)
                    Quit
                }
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Route notification to interested colleagues
Method RouteNotification(pSender As Patterns.GoF.Behavioral.Colleague, pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Get notification type
        Set tNotificationType = ""
        If $IsObject(pData) && pData.%IsDefined("type") {
            Set tNotificationType = pData.type
        }
        
        // Send to all colleagues interested in this notification type
        For i=1:1:..Colleagues.Count() {
            Set tColleague = ..Colleagues.GetAt(i)
            If tColleague '= pSender {
                // Check if colleague has filter for this notification
                If ..ShouldReceiveNotification(tColleague, tNotificationType) {
                    Set tSC = tColleague.Receive("NOTIFICATION", pData)
                }
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle emergency broadcast
Method HandleEmergency(pSender As Patterns.GoF.Behavioral.Colleague, pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Emergency broadcasts go to all colleagues immediately
        For i=1:1:..Colleagues.Count() {
            Set tColleague = ..Colleagues.GetAt(i)
            Set tSC = tColleague.Receive("EMERGENCY", pData)
            // Continue even if one fails
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Route by configured routing rules
Method RouteByRules(pSender As Patterns.GoF.Behavioral.Colleague, pEvent As %String, pData As %DynamicObject) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Check routing rules for this event type
        Set tKey = ""
        For {
            Set tKey = ..RoutingRules.Next(tKey)
            Quit:tKey=""
            
            Set tEventTypes = ..RoutingRules.GetAt(tKey)
            If tEventTypes[pEvent {
                // Find colleague with this ID
                For i=1:1:..Colleagues.Count() {
                    Set tColleague = ..Colleagues.GetAt(i)
                    If tColleague.ColleagueId = tKey {
                        Set tSC = tColleague.Receive(pEvent, pData)
                        // Don't quit, may route to multiple colleagues
                    }
                }
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Transform message data if needed
Method TransformMessage(pEvent As %String, pData As %DynamicObject) As %DynamicObject [ Private ]
{
    Set tResult = pData
    
    Try {
        // Add timestamp if not present
        If $IsObject(pData) && '$D(pData.timestamp) {
            Set pData.timestamp = $ZDATETIME($HOROLOG, 3)
        }
        
        // Add event type if not present
        If $IsObject(pData) && '$D(pData.eventType) {
            Set pData.eventType = pEvent
        }
        
        // Apply any custom transformations based on event type
        If pEvent = "REQUEST" {
            // Add request ID if not present
            If '$D(pData.requestId) {
                Set pData.requestId = $System.Util.CreateGUID()
            }
        }
        
        Set tResult = pData
        
    } Catch ex {
        // Return original on error
        Set tResult = pData
    }
    
    Quit tResult
}

/// Check if colleague should receive notification
Method ShouldReceiveNotification(pColleague As Patterns.GoF.Behavioral.Colleague, pNotificationType As %String) As %Boolean [ Private ]
{
    Set tResult = 1  // Default to true
    
    Try {
        // Check if colleague has filters set
        If ..MessageFilters.IsDefined(pColleague.ColleagueId) {
            Set tFilters = ..MessageFilters.GetAt(pColleague.ColleagueId)
            If tFilters '= "" {
                // Check if notification type matches filter
                Set tResult = (tFilters[pNotificationType)
            }
        }
    } Catch ex {
        Set tResult = 1  // Default to true on error
    }
    
    Quit tResult
}

/// Add routing rule
Method AddRoutingRule(pColleagueId As %String, pEventType As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tEventTypes = ""
        If ..RoutingRules.IsDefined(pColleagueId) {
            Set tEventTypes = ..RoutingRules.GetAt(pColleagueId)
        }
        
        If tEventTypes '[ pEventType {
            Set tEventTypes = tEventTypes_","_pEventType
        }
        
        Do ..RoutingRules.SetAt(tEventTypes, pColleagueId)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Add message filter
Method AddMessageFilter(pColleagueId As %String, pFilter As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Do ..MessageFilters.SetAt(pFilter, pColleagueId)
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Queue event for async processing
Method QueueEvent(pSender As Patterns.GoF.Behavioral.Colleague, pEvent As %String, pData As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tQueueItem = ##class(%DynamicObject).%New()
        Set tQueueItem.sender = pSender.ColleagueId
        Set tQueueItem.event = pEvent
        Set tQueueItem.data = pData
        Set tQueueItem.timestamp = $ZDATETIME($HOROLOG, 3)
        
        Do ..EventQueue.Insert(tQueueItem)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process queued events
Method ProcessEventQueue() As %Status
{
    Set tSC = $$$OK
    
    Try {
        While ..EventQueue.Count() > 0 {
            Set tQueueItem = ..EventQueue.GetAt(1)
            Do ..EventQueue.RemoveAt(1)
            
            // Find sender colleague
            Set tSender = ""
            For i=1:1:..Colleagues.Count() {
                Set tColleague = ..Colleagues.GetAt(i)
                If tColleague.ColleagueId = tQueueItem.sender {
                    Set tSender = tColleague
                    Quit
                }
            }
            
            If $IsObject(tSender) {
                Set tSC = ..Notify(tSender, tQueueItem.event, tQueueItem.data)
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Log event for audit trail
Method LogEvent(pSender As Patterns.GoF.Behavioral.Colleague, pEvent As %String, pData As %DynamicObject) [ Private ]
{
    Try {
        Set ^Patterns.Mediator.Log($INCREMENT(^Patterns.Mediator.Log)) = $LISTBUILD(
            $ZDATETIME($HOROLOG, 3),
            pSender.ColleagueId,
            pEvent,
            $SELECT($IsObject(pData):pData.%ToJSON(),1:pData)
        )
    } Catch ex {
        // Silent fail for logging
    }
}

/// Handle communication error
Method HandleError(pSender As Patterns.GoF.Behavioral.Colleague, pEvent As %String, pError As %Status) [ Private ]
{
    Try {
        Set ^Patterns.Mediator.Errors($INCREMENT(^Patterns.Mediator.Errors)) = $LISTBUILD(
            $ZDATETIME($HOROLOG, 3),
            pSender.ColleagueId,
            pEvent,
            $System.Status.GetErrorText(pError)
        )
        
        // Notify sender of error
        Set tErrorData = ##class(%DynamicObject).%New()
        Set tErrorData.error = $System.Status.GetErrorText(pError)
        Set tErrorData.originalEvent = pEvent
        
        Do pSender.Receive("ERROR", tErrorData)
        
    } Catch ex {
        // Silent fail for error handling
    }
}

/// Enable async processing
Method EnableAsync(pEnabled As %Boolean = 1) As %Status
{
    Set ..AsyncEnabled = pEnabled
    Quit $$$OK
}

/// Clear all routing rules
Method ClearRoutingRules() As %Status
{
    Do ..RoutingRules.Clear()
    Quit $$$OK
}

/// Clear all message filters
Method ClearMessageFilters() As %Status
{
    Do ..MessageFilters.Clear()
    Quit $$$OK
}

}
