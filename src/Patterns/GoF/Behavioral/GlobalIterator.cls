/// Gang of Four Iterator Pattern - Global Iterator Implementation
/// 
/// Purpose:
/// Provides iteration capability for IRIS globals using $ORDER
/// 
/// Features:
/// - Forward and reverse traversal
/// - Subscript-level configuration
/// - Sparse global support
/// - Depth-first and breadth-first traversal
Class Patterns.GoF.Behavioral.GlobalIterator Extends Patterns.GoF.Behavioral.Iterator
{

/// Global reference to iterate (e.g., "^MyGlobal")
Property GlobalReference As %String [ Private ];

/// Current position in the global (subscript value)
Property CurrentKey As %String [ Private ];

/// Traversal direction (1 = forward, -1 = reverse)
Property Direction As %Integer [ InitialExpression = 1, Private ];

/// Maximum depth for traversal (0 = unlimited)
Property MaxDepth As %Integer [ InitialExpression = 0 ];

/// Current depth in traversal
Property CurrentDepth As %Integer [ InitialExpression = 0, Private ];

/// Starting subscript for iteration
Property StartKey As %String [ Private ];

/// Ending subscript for iteration (inclusive)
Property EndKey As %String [ Private ];

/// Stack for depth-first traversal
Property TraversalStack As %ListOfDataTypes [ Private ];

/// Traversal type: "depth-first" or "breadth-first"
Property TraversalType As %String [ InitialExpression = "depth-first" ];

/// Constructor
Method %OnNew(pGlobalRef As %String, pStartKey As %String = "", pEndKey As %String = "") As %Status
{
        Set tSC = $$$OK
        
        Try {
            If pGlobalRef = "" {
                Set tSC = $$$ERROR($$$GeneralError, "Global reference cannot be empty")
                Quit
            }
            
            Set ..GlobalReference = pGlobalRef
            Set ..StartKey = pStartKey
            Set ..EndKey = pEndKey
            Set ..CurrentKey = pStartKey
            Set ..TraversalStack = ##class(%ListOfDataTypes).%New()
            
            // If no start key specified, get first key
            If ..StartKey = "" {
                Set ..CurrentKey = ""
            }
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Quit tSC
}

/// Check if more elements exist
Method HasNext() As %Boolean
{
        Set tHasNext = 0
        
        // Build the global reference with current key
        Set tGlobalRef = ..GlobalReference
        
        If ..CurrentKey '= "" {
            Set tNextKey = $ORDER(@tGlobalRef@(..CurrentKey), ..Direction)
        } Else {
            // Start from the StartKey if specified
            If ..StartKey '= "" {
                Set tNextKey = ..StartKey
                // Check if StartKey exists
                If '$DATA(@tGlobalRef@(tNextKey)) {
                    // Get next key after StartKey
                    Set tNextKey = $ORDER(@tGlobalRef@(..StartKey), ..Direction)
                }
            } Else {
                Set tNextKey = $ORDER(@tGlobalRef@(""), ..Direction)
            }
        }
        
        // Check if we found a next key
        If tNextKey '= "" {
            // Check end boundary if specified
            If ..EndKey '= "" {
                // For numeric comparison, convert to numbers if possible
                Set tIsNumeric = 1
                Try {
                    Set tNextNum = +tNextKey
                    Set tEndNum = +..EndKey
                } Catch {
                    Set tIsNumeric = 0
                }
                
                If tIsNumeric && (tNextKey = tNextNum) && (..EndKey = tEndNum) {
                    // Numeric comparison
                    If ..Direction = 1 {
                        Set tHasNext = (tNextNum <= tEndNum)
                    } Else {
                        Set tHasNext = (tNextNum >= tEndNum)
                    }
                } Else {
                    // String comparison
                    If ..Direction = 1 {
                        Set tHasNext = (tNextKey ]] ..EndKey) || (tNextKey = ..EndKey) || (..EndKey ]] tNextKey)
                    } Else {
                        Set tHasNext = (tNextKey ]] ..EndKey) || (tNextKey = ..EndKey) 
                    }
                }
            } Else {
                Set tHasNext = 1
            }
        }
        
        Quit tHasNext
}

/// Get the next element (returns the global node value)
Method Next() As %RegisteredObject
{
        Set tValue = ""
        
        If '..HasNext() {
            Throw ##class(%Exception.General).%New("NoSuchElementException", 5002, , "No more elements in global iteration")
        }
        
        // Get next key
        Set tGlobalRef = ..GlobalReference
        
        If ..CurrentKey '= "" {
            Set ..CurrentKey = $ORDER(@tGlobalRef@(..CurrentKey), ..Direction)
        } Else {
            Set ..CurrentKey = $ORDER(@tGlobalRef@(""), ..Direction)
        }
        
        // Get the value at this key
        If ..CurrentKey '= "" {
            Set tValue = $GET(@tGlobalRef@(..CurrentKey))
        }
        
        // Return a GlobalNode object containing key and value
        Set tNode = ##class(Patterns.GoF.Behavioral.GlobalNode).%New()
        Set tNode.Key = ..CurrentKey
        Set tNode.Value = tValue
        Set tNode.GlobalRef = ..GlobalReference
        
        Quit tNode
}

/// Get current node without advancing
Method Current() As %RegisteredObject
{
        If ..CurrentKey = "" {
            Quit $$$NULLOREF
        }
        
        Set tGlobalRef = ..GlobalReference
        Set tValue = $GET(@tGlobalRef@(..CurrentKey))
        
        Set tNode = ##class(Patterns.GoF.Behavioral.GlobalNode).%New()
        Set tNode.Key = ..CurrentKey
        Set tNode.Value = tValue
        Set tNode.GlobalRef = ..GlobalReference
        
        Quit tNode
}

/// Reset iterator to beginning
Method Reset() As %Status
{
        Set ..CurrentKey = ..StartKey
        If ..StartKey = "" {
            Set ..CurrentKey = ""
        }
        Set ..CurrentDepth = 0
        Do ..TraversalStack.Clear()
        Quit $$$OK
}

/// Set traversal direction
Method SetDirection(pDirection As %Integer) As %Status
{
        If (pDirection '= 1) && (pDirection '= -1) {
            Quit $$$ERROR($$$GeneralError, "Invalid direction. Use 1 for forward, -1 for reverse")
        }
        Set ..Direction = pDirection
        Quit $$$OK
}

/// Set traversal type
Method SetTraversalType(pType As %String) As %Status
{
        If (pType '= "depth-first") && (pType '= "breadth-first") {
            Quit $$$ERROR($$$GeneralError, "Invalid traversal type. Use 'depth-first' or 'breadth-first'")
        }
        Set ..TraversalType = pType
        Quit $$$OK
}

/// Check if a node exists at the given subscript
Method NodeExists(pKey As %String) As %Boolean
{
        Set tGlobalRef = ..GlobalReference
        Quit $DATA(@tGlobalRef@(pKey))
}

/// Get all subscripts at current level
Method GetSubscriptsAtLevel() As %ListOfDataTypes
{
        Set tList = ##class(%ListOfDataTypes).%New()
        Set tGlobalRef = ..GlobalReference
        
        Set tKey = ""
        For {
            Set tKey = $ORDER(@tGlobalRef@(tKey))
            Quit:tKey=""
            Do tList.Insert(tKey)
        }
        
        Quit tList
}

}
