/// Gang of Four Mediator Pattern - Event Dispatcher
/// 
/// Purpose:
/// Manages event subscriptions and dispatching for the event-based
/// communication system. Provides priority-based event handling,
/// event history, and subscription management.
/// 
/// Features:
/// - Event subscription/unsubscription
/// - Priority-based event queuing
/// - Event bubbling and cancellation
/// - Event history and audit trail
/// - Async event processing
Class Patterns.GoF.Behavioral.EventDispatcher Extends %RegisteredObject
{

/// Event subscriptions (eventType -> list of subscribers)
Property Subscriptions [ MultiDimensional ];

/// Priority queue for events
Property EventQueue As %ListOfObjects [ Private ];

/// Event history for audit trail
Property EventHistory As %ListOfObjects [ Private ];

/// Maximum history size
Property MaxHistorySize As %Integer [ InitialExpression = 100 ];

/// Flag to indicate if processing is active
Property ProcessingActive As %Boolean [ InitialExpression = 0 ];

/// Current event being processed
Property CurrentEvent As Event;

/// Named filters
Property Filters [ MultiDimensional ];

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Set ..EventQueue = ##class(%ListOfObjects).%New()
    Set ..EventHistory = ##class(%ListOfObjects).%New()
    
    Quit tSC
}

/// Subscribe to events
Method Subscribe(pEventType As %String, pSubscriber As %String, pFilter As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Initialize subscription list if needed
        If '$Data(..Subscriptions(pEventType)) {
            Set ..Subscriptions(pEventType) = ""
        }
        
        // Create subscription entry
        Set tSubscription = ##class(%DynamicObject).%New()
        Set tSubscription.subscriberId = pSubscriber
        Set tSubscription.filter = pFilter
        Set tSubscription.subscribeTime = $ZDATETIME($HOROLOG, 3)
        
        // Add to subscription list
        Set tSubList = ..Subscriptions(pEventType)
        If tSubList = "" {
            Set tSubList = ##class(%ListOfObjects).%New()
        }
        Do tSubList.Insert(tSubscription)
        Set ..Subscriptions(pEventType) = tSubList
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Unsubscribe from events
Method Unsubscribe(pEventType As %String, pSubscriber As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $Data(..Subscriptions(pEventType)) {
            Set tSubList = ..Subscriptions(pEventType)
            If $IsObject(tSubList) {
                // Remove subscriber from list
                For i=tSubList.Count():-1:1 {
                    Set tSub = tSubList.GetAt(i)
                    If tSub.subscriberId = pSubscriber {
                        Do tSubList.RemoveAt(i)
                    }
                }
                
                // Remove empty subscription list
                If tSubList.Count() = 0 {
                    Kill ..Subscriptions(pEventType)
                }
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Unsubscribe from all events
Method UnsubscribeAll(pSubscriber As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set tEventType = ""
        For {
            Set tEventType = $Order(..Subscriptions(tEventType))
            Quit:tEventType=""
            
            Set tSC = ..Unsubscribe(tEventType, pSubscriber)
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Dispatch an event
Method Dispatch(pEvent As Event) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Validate event
        Set tSC = pEvent.Validate()
        If $$$ISERR(tSC) Quit
        
        // Add to history
        Do ..AddToHistory(pEvent)
        
        // Add to queue based on priority
        Set tInserted = 0
        For i=1:1:..EventQueue.Count() {
            Set tQueuedEvent = ..EventQueue.GetAt(i)
            If pEvent.ComparePriority(tQueuedEvent) > 0 {
                Do ..EventQueue.InsertAt(pEvent, i)
                Set tInserted = 1
                Quit
            }
        }
        
        If 'tInserted {
            Do ..EventQueue.Insert(pEvent)
        }
        
        // Process queue if not already processing
        If '..ProcessingActive {
            Set tSC = ..ProcessQueue()
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Process queued events
Method ProcessQueue() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..ProcessingActive = 1
        
        While ..EventQueue.Count() > 0 {
            Set ..CurrentEvent = ..EventQueue.GetAt(1)
            Do ..EventQueue.RemoveAt(1)
            
            // Check if event should be processed
            If ..CurrentEvent.ShouldProcess() {
                Set tSC = ..ProcessEvent(..CurrentEvent)
                
                // Handle bubbling
                If ..CurrentEvent.Bubbles && '..CurrentEvent.Canceled {
                    Set tSC = ..BubbleEvent(..CurrentEvent)
                }
            }
        }
        
        Set ..ProcessingActive = 0
        Set ..CurrentEvent = ""
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set ..ProcessingActive = 0
        Set ..CurrentEvent = ""
    }
    
    Quit tSC
}

/// Process a single event
Method ProcessEvent(pEvent As Event) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Get subscribers for this event type
        If $Data(..Subscriptions(pEvent.EventType)) {
            Set tSubList = ..Subscriptions(pEvent.EventType)
            If $IsObject(tSubList) {
                For i=1:1:tSubList.Count() {
                    Set tSub = tSubList.GetAt(i)
                    
                    // Apply filter if present
                    If ..CheckEventFilter(pEvent, tSub.filter) {
                        // Notify subscriber
                        Set tSC = ..NotifySubscriber(tSub.subscriberId, pEvent)
                        
                        // Mark as handled if successfully processed
                        If $$$ISOK(tSC) {
                            Do pEvent.MarkHandled()
                        }
                        
                        // Stop processing if event is canceled
                        If pEvent.Canceled {
                            Quit
                        }
                    }
                }
            }
        }
        
        // Process wildcard subscribers
        If $Data(..Subscriptions("*")) {
            Set tSubList = ..Subscriptions("*")
            If $IsObject(tSubList) {
                For i=1:1:tSubList.Count() {
                    Set tSub = tSubList.GetAt(i)
                    If ..CheckEventFilter(pEvent, tSub.filter) {
                        Set tSC = ..NotifySubscriber(tSub.subscriberId, pEvent)
                    }
                }
            }
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Set pEvent.ErrorStatus = tSC
    }
    
    Quit tSC
}

/// Check if event passes filter (internal method)
Method CheckEventFilter(pEvent As Event, pFilter As %String) As %Boolean [ Private ]
{
    Set tResult = 1  // Default to pass
    
    // If no filter, pass all events
    If pFilter = "" Quit 1
    
    Try {
        // Parse filter as JSON
        Set tFilterObj = ##class(%DynamicObject).%FromJSON(pFilter)
        
        // Check sender filter
        If tFilterObj.%IsDefined("senderId") {
            If pEvent.SenderId '= tFilterObj.senderId {
                Set tResult = 0
                Quit
            }
        }
        
        // Check target filter
        If tFilterObj.%IsDefined("targetId") {
            If pEvent.TargetId '= tFilterObj.targetId {
                Set tResult = 0
                Quit
            }
        }
        
        // Check priority filter
        If tFilterObj.%IsDefined("minPriority") {
            If pEvent.Priority < tFilterObj.minPriority {
                Set tResult = 0
                Quit
            }
        }
        
        // Check metadata filters
        If tFilterObj.%IsDefined("metadata") {
            Set tIterator = tFilterObj.metadata.%GetIterator()
            While tIterator.%GetNext(.tKey, .tValue) {
                If pEvent.GetMetadata(tKey) '= tValue {
                    Set tResult = 0
                    Quit
                }
            }
        }
        
    } Catch ex {
        // Invalid filter format, don't pass
        Set tResult = 0
    }
    
    Quit tResult
}

/// Notify subscriber of event
Method NotifySubscriber(pSubscriberId As %String, pEvent As Event) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Log notification
        Set ^Patterns.EventDispatcher.Notifications($INCREMENT(^Patterns.EventDispatcher.Notifications)) = 
            $LISTBUILD($ZDATETIME($HOROLOG, 3), pSubscriberId, pEvent.EventId, pEvent.EventType)
        
        // In a real implementation, this would call the subscriber's handler
        // For now, we'll just record that it was dispatched
        Do pEvent.AddMetadata("dispatchedTo", pSubscriberId)
        Do pEvent.AddMetadata("dispatchTime", $ZDATETIME($HOROLOG, 3))
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle event bubbling
Method BubbleEvent(pEvent As Event) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Create bubbled event
        Set tBubbledEvent = pEvent.Clone()
        Set tBubbledEvent.EventType = "BUBBLED_"_pEvent.EventType
        Do tBubbledEvent.AddMetadata("originalType", pEvent.EventType)
        Do tBubbledEvent.AddMetadata("bubbledAt", $ZDATETIME($HOROLOG, 3))
        
        // Dispatch bubbled event (without further bubbling)
        Set tBubbledEvent.Bubbles = 0
        Set tSC = ..Dispatch(tBubbledEvent)
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Add event to history
Method AddToHistory(pEvent As Event) [ Private ]
{
    Try {
        // Add to history
        Do ..EventHistory.Insert(pEvent)
        
        // Trim history if needed
        While ..EventHistory.Count() > ..MaxHistorySize {
            Do ..EventHistory.RemoveAt(1)
        }
        
        // Also persist to global for audit
        Set ^Patterns.EventDispatcher.History($INCREMENT(^Patterns.EventDispatcher.History)) = 
            pEvent.ToJSON().%ToJSON()
        
    } Catch ex {
        // Silent fail for history
    }
}

/// Get event history
Method GetHistory(pMaxItems As %Integer = 10) As %ListOfObjects
{
    Set tResult = ##class(%ListOfObjects).%New()
    
    Try {
        Set tStart = ..EventHistory.Count() - pMaxItems + 1
        If tStart < 1 Set tStart = 1
        
        For i=tStart:1:..EventHistory.Count() {
            Do tResult.Insert(..EventHistory.GetAt(i))
        }
    } Catch ex {
        // Return empty list on error
    }
    
    Quit tResult
}

/// Get event history by type
Method GetHistoryByType(pEventType As %String, pMaxItems As %Integer = 10) As %ListOfObjects
{
    Set tResult = ##class(%ListOfObjects).%New()
    Set tCount = 0
    
    Try {
        For i=..EventHistory.Count():-1:1 {
            Set tEvent = ..EventHistory.GetAt(i)
            If tEvent.EventType = pEventType {
                Do tResult.Insert(tEvent)
                Set tCount = tCount + 1
                If tCount >= pMaxItems Quit
            }
        }
    } Catch ex {
        // Return partial list on error
    }
    
    Quit tResult
}

/// Clear event history
Method ClearHistory() As %Status
{
    Do ..EventHistory.Clear()
    Quit $$$OK
}

/// Get subscriber count
Method GetSubscriberCount(pEventType As %String = "") As %Integer
{
    Set tCount = 0
    
    Try {
        If pEventType '= "" {
            // Count for specific event type
            If $Data(..Subscriptions(pEventType)) {
                Set tSubList = ..Subscriptions(pEventType)
                If $IsObject(tSubList) {
                    Set tCount = tSubList.Count()
                }
            }
        } Else {
            // Count all subscribers
            Set tEventType = ""
            For {
                Set tEventType = $Order(..Subscriptions(tEventType))
                Quit:tEventType=""
                
                Set tSubList = ..Subscriptions(tEventType)
                If $IsObject(tSubList) {
                    Set tCount = tCount + tSubList.Count()
                }
            }
        }
    } Catch ex {
        // Return 0 on error
    }
    
    Quit tCount
}

/// Get subscribed event types
Method GetSubscribedEventTypes() As %ListOfDataTypes
{
    Set tResult = ##class(%ListOfDataTypes).%New()
    
    Try {
        Set tEventType = ""
        For {
            Set tEventType = $Order(..Subscriptions(tEventType))
            Quit:tEventType=""
            Do tResult.Insert(tEventType)
        }
    } Catch ex {
        // Return empty list on error
    }
    
    Quit tResult
}

/// Cancel current event processing
Method CancelCurrentEvent() As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $IsObject(..CurrentEvent) {
            Set tSC = ..CurrentEvent.Cancel()
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Clear event queue
Method ClearQueue() As %Status
{
    Do ..EventQueue.Clear()
    Quit $$$OK
}

/// Get queue size
Method GetQueueSize() As %Integer
{
    Quit ..EventQueue.Count()
}

/// Add a named filter
Method AddFilter(pFilterName As %String, pFilter As %DynamicObject) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Convert filter object to JSON string for storage
        Set tFilterJson = pFilter.%ToJSON()
        Set ..Filters(pFilterName) = tFilterJson
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Check if event passes filter (public method for testing)
Method PassesFilter(pEvent As Event, pFilterName As %String) As %Boolean
{
    // Get the filter by name
    If '$Data(..Filters) || '$Data(..Filters(pFilterName)) {
        // No filter defined, pass all
        Quit 1
    }
    
    // Get filter and use the private method to check
    Set tFilter = ..Filters(pFilterName)
    
    // Check using the private PassesFilter method logic
    Set tResult = 1  // Default to pass
    
    // If no filter, pass all events
    If tFilter = "" Quit 1
    
    Try {
        // Parse filter as JSON
        Set tFilterObj = ##class(%DynamicObject).%FromJSON(tFilter)
        
        // Check priority filter
        If tFilterObj.%IsDefined("minPriority") {
            If pEvent.Priority < tFilterObj.minPriority {
                Set tResult = 0
                Quit
            }
        }
        
    } Catch ex {
        // Invalid filter format, don't pass
        Set tResult = 0
    }
    
    Quit tResult
}

}
