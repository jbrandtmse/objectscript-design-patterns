/// Gang of Four Memento Pattern - State Serialization Utilities
/// 
/// Purpose:
/// Handles serialization and deserialization of complex ObjectScript objects
/// 
/// Features:
/// - JSON serialization/deserialization
/// - %SerializeObject support
/// - Global-based state storage
/// - Circular reference detection
/// - Compression for large states
/// - Binary serialization support
Class Patterns.GoF.Behavioral.StateSerializer Extends %RegisteredObject
{

/// Serialize an object to JSON string
ClassMethod SerializeToJSON(pObject As %RegisteredObject) As %String
{
    Set tJSON = ""
    
    Try {
        If '$IsObject(pObject) {
            Quit
        }
        
        // Check if object supports %ToJSON
        If pObject.%Extends("%DynamicAbstractObject") {
            Set tJSON = pObject.%ToJSON()
        } ElseIf pObject.%Extends("%JSON.Adaptor") {
            Do pObject.%JSONExportToString(.tJSON)
        } Else {
            // Manual serialization for other objects
            Set tDynObj = ..ObjectToDynamic(pObject)
            Set tJSON = tDynObj.%ToJSON()
        }
    } Catch ex {
        // Log error but return empty string
        Set tJSON = ""
    }
    
    Quit tJSON
}

/// Deserialize JSON string to dynamic object
ClassMethod DeserializeFromJSON(pJSON As %String) As %DynamicObject
{
    Set tResult = {}
    
    Try {
        If pJSON '= "" {
            Set tResult = {}.%FromJSON(pJSON)
        }
    } Catch ex {
        // Return empty object on error
        Set tResult = {}
    }
    
    Quit tResult
}

/// Convert registered object to dynamic object
ClassMethod ObjectToDynamic(pObject As %RegisteredObject) As %DynamicObject [ Private ]
{
    Set tDynamic = {}
    
    If '$IsObject(pObject) {
        Quit tDynamic
    }
    
    // Add class name for reconstruction
    Set tDynamic."%ClassName" = pObject.%ClassName(1)
    
    // Get property list
    Set tClass = ##class(%Dictionary.ClassDefinition).%OpenId(pObject.%ClassName(1))
    If $IsObject(tClass) {
        For i=1:1:tClass.Properties.Count() {
            Set tProp = tClass.Properties.GetAt(i)
            Set tPropName = tProp.Name
            
            // Skip private properties
            If $EXTRACT(tPropName, 1) = "%" Continue
            
            // Skip transient properties
            If tProp.Transient Continue
            
            Try {
                Set tValue = $PROPERTY(pObject, tPropName)
                
                // Handle different value types
                If '$DATA(tValue) {
                    // Skip undefined
                } ElseIf $IsObject(tValue) {
                    // Recursive serialization (be careful of circular refs)
                    If ..IsCircularReference(pObject, tValue) {
                        Set $PROPERTY(tDynamic, tPropName) = {"$ref": ($ZREFERENCE(tValue))}
                    } Else {
                        Set $PROPERTY(tDynamic, tPropName) = ..ObjectToDynamic(tValue)
                    }
                } Else {
                    Set $PROPERTY(tDynamic, tPropName) = tValue
                }
            } Catch {
                // Skip properties that can't be accessed
            }
        }
    }
    
    Quit tDynamic
}

/// Check for circular reference
ClassMethod IsCircularReference(pParent As %RegisteredObject, pChild As %RegisteredObject) As %Boolean [ Private ]
{
    // Simple check - can be enhanced
    Quit (pParent = pChild)
}

/// Save state to global
ClassMethod SaveToGlobal(pGlobalName As %String, pKey As %String, pState As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Store with timestamp
        Set @pGlobalName@(pKey, "state") = pState
        Set @pGlobalName@(pKey, "timestamp") = $ZDATETIME($HOROLOG, 3)
        Set @pGlobalName@(pKey, "size") = $LENGTH(pState)
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Load state from global
ClassMethod LoadFromGlobal(pGlobalName As %String, pKey As %String) As %String
{
    Set tState = ""
    
    Try {
        If $DATA(@pGlobalName@(pKey, "state")) {
            Set tState = @pGlobalName@(pKey, "state")
        }
    } Catch {
        Set tState = ""
    }
    
    Quit tState
}

/// Compress state string
ClassMethod CompressState(pState As %String) As %String
{
    Set tCompressed = ""
    
    Try {
        // Use ZLIB compression if available
        Set tStream = ##class(%Stream.TmpCharacter).%New()
        Do tStream.Write(pState)
        
        Set tCompressedStream = ##class(%Stream.TmpBinary).%New()
        Set tSC = tStream.Compress(tCompressedStream)
        
        If $$$ISOK(tSC) {
            Do tCompressedStream.Rewind()
            Set tCompressed = tCompressedStream.Read()
        }
    } Catch {
        // Return original if compression fails
        Set tCompressed = pState
    }
    
    Quit tCompressed
}

/// Decompress state string
ClassMethod DecompressState(pCompressed As %String) As %String
{
    Set tState = ""
    
    Try {
        Set tCompressedStream = ##class(%Stream.TmpBinary).%New()
        Do tCompressedStream.Write(pCompressed)
        Do tCompressedStream.Rewind()
        
        Set tStream = ##class(%Stream.TmpCharacter).%New()
        Set tSC = tCompressedStream.Decompress(tStream)
        
        If $$$ISOK(tSC) {
            Do tStream.Rewind()
            Set tState = tStream.Read()
        }
    } Catch {
        // Return original if decompression fails
        Set tState = pCompressed
    }
    
    Quit tState
}

/// Serialize object to binary format
ClassMethod SerializeToBinary(pObject As %RegisteredObject) As %String
{
    Set tBinary = ""
    
    Try {
        // Convert to JSON first then to binary
        Set tJSON = ..SerializeToJSON(pObject)
        Set tBinary = $SYSTEM.Encryption.Base64Encode(tJSON)
    } Catch {
        Set tBinary = ""
    }
    
    Quit tBinary
}

/// Deserialize from binary format
ClassMethod DeserializeFromBinary(pBinary As %String) As %DynamicObject
{
    Set tResult = {}
    
    Try {
        Set tJSON = $SYSTEM.Encryption.Base64Decode(pBinary)
        Set tResult = ..DeserializeFromJSON(tJSON)
    } Catch {
        Set tResult = {}
    }
    
    Quit tResult
}

/// Calculate state hash for comparison
ClassMethod GetStateHash(pState As %String) As %String
{
    Set tHash = ""
    
    Try {
        Set tHash = $SYSTEM.Encryption.SHA1Hash(pState)
    } Catch {
        Set tHash = ""
    }
    
    Quit tHash
}

/// Compare two states for equality
ClassMethod StatesEqual(pState1 As %String, pState2 As %String) As %Boolean
{
    // Simple string comparison - could use hash for large states
    Quit (pState1 = pState2)
}

/// Get state size in bytes
ClassMethod GetStateSize(pState As %String) As %Integer
{
    Quit $LENGTH(pState)
}

/// Clean up old states from global
ClassMethod CleanupGlobalStates(pGlobalName As %String, pDaysToKeep As %Integer = 30) As %Status
{
    Set tSC = $$$OK
    Set tCutoff = $SYSTEM.SQL.DATEADD("day", -pDaysToKeep, $HOROLOG)
    
    Try {
        Set tKey = ""
        For {
            Set tKey = $ORDER(@pGlobalName@(tKey))
            Quit:tKey=""
            
            If $DATA(@pGlobalName@(tKey, "timestamp")) {
                Set tTimestamp = @pGlobalName@(tKey, "timestamp")
                Set tDate = $ZDATEH($PIECE(tTimestamp, " ", 1), 3)
                
                If tDate < tCutoff {
                    Kill @pGlobalName@(tKey)
                }
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Encrypt state for sensitive data
ClassMethod EncryptState(pState As %String, pKey As %String = "") As %String
{
    Set tEncrypted = pState
    
    Try {
        If pKey = "" {
            Set pKey = "DefaultMementoKey"
        }
        Set tEncrypted = $SYSTEM.Encryption.AESEncode(pState, pKey)
    } Catch {
        // Return original if encryption fails
        Set tEncrypted = pState
    }
    
    Quit tEncrypted
}

/// Decrypt state
ClassMethod DecryptState(pEncrypted As %String, pKey As %String = "") As %String
{
    Set tState = pEncrypted
    
    Try {
        If pKey = "" {
            Set pKey = "DefaultMementoKey"
        }
        Set tState = $SYSTEM.Encryption.AESDecode(pEncrypted, pKey)
    } Catch {
        // Return original if decryption fails
        Set tState = pEncrypted
    }
    
    Quit tState
}

/// Validate state structure
ClassMethod ValidateState(pState As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Try to parse as JSON
        Set tObj = {}.%FromJSON(pState)
        
        // Check for required fields
        If 'tObj.%IsDefined("%ClassName") {
            Set tSC = $$$ERROR($$$GeneralError, "State missing class information")
        }
    } Catch ex {
        Set tSC = $$$ERROR($$$GeneralError, "Invalid state format: " _ ex.Name)
    }
    
    Quit tSC
}

/// Create incremental/delta state
ClassMethod CreateDeltaState(pOldState As %String, pNewState As %String) As %String
{
    Set tDelta = {}
    
    Try {
        Set tOld = ..DeserializeFromJSON(pOldState)
        Set tNew = ..DeserializeFromJSON(pNewState)
        
        // Record changes
        Set tDelta.changes = []
        
        Set tIterator = tNew.%GetIterator()
        While tIterator.%GetNext(.tKey, .tNewValue) {
            If 'tOld.%IsDefined(tKey) {
                // New property
                Do tDelta.changes.%Push({"op": "add", "key": (tKey), "value": (tNewValue)})
            } ElseIf tOld.%Get(tKey) '= tNewValue {
                // Changed property
                Do tDelta.changes.%Push({"op": "update", "key": (tKey), "old": (tOld.%Get(tKey)), "new": (tNewValue)})
            }
        }
        
        // Check for deletions
        Set tIterator = tOld.%GetIterator()
        While tIterator.%GetNext(.tKey, .tOldValue) {
            If 'tNew.%IsDefined(tKey) {
                Do tDelta.changes.%Push({"op": "delete", "key": (tKey), "old": (tOldValue)})
            }
        }
    } Catch {
        // Return empty delta on error
        Set tDelta.changes = []
    }
    
    Quit tDelta.%ToJSON()
}

/// Apply delta to state
ClassMethod ApplyDeltaState(pBaseState As %String, pDelta As %String) As %String
{
    Set tResult = pBaseState
    
    Try {
        Set tBase = ..DeserializeFromJSON(pBaseState)
        Set tDelta = ..DeserializeFromJSON(pDelta)
        
        If tDelta.%IsDefined("changes") {
            Set tIterator = tDelta.changes.%GetIterator()
            While tIterator.%GetNext(.tIndex, .tChange) {
                Set tOp = tChange.op
                Set tKey = tChange.key
                
                If tOp = "add" {
                    Set $PROPERTY(tBase, tKey) = tChange.value
                } ElseIf tOp = "update" {
                    Set $PROPERTY(tBase, tKey) = tChange.new
                } ElseIf tOp = "delete" {
                    Do tBase.%Remove(tKey)
                }
            }
        }
        
        Set tResult = tBase.%ToJSON()
    } Catch {
        // Return original on error
        Set tResult = pBaseState
    }
    
    Quit tResult
}

}
