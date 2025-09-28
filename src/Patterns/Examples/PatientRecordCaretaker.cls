/// Healthcare-specific caretaker for patient record versioning
/// Manages version history with HIPAA compliance and audit trail
Class Patterns.Examples.PatientRecordCaretaker Extends %RegisteredObject
{

/// Collection of patient record mementos indexed by version
Property VersionHistory As list Of Patterns.Examples.PatientRecordMemento;

/// Maximum number of versions to retain in memory
Property MaxVersions As %Integer [ InitialExpression = 100 ];

/// Current version pointer
Property CurrentVersion As %Integer [ InitialExpression = 0 ];

/// Patient ID for this caretaker
Property PatientID As %String;

/// Archive location for old versions
Property ArchivePath As %String [ InitialExpression = "^Patterns.PatientArchive" ];

/// Retention policy in days
Property RetentionDays As %Integer [ InitialExpression = 2555 ];

/// Enable automatic archival
Property AutoArchive As %Boolean [ InitialExpression = 1 ];

/// Enable compression for archived versions
Property UseCompression As %Boolean [ InitialExpression = 1 ];

/// Version index for fast lookup
Property VersionIndex [ MultiDimensional ];

/// Regulatory snapshots that cannot be deleted
Property RegulatoryVersions [ MultiDimensional ];

/// Constructor
Method %OnNew(pPatientID As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..PatientID = pPatientID
        // Initialize version tracking
        Set ..CurrentVersion = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Add a new version (memento) to history
Method AddVersion(pMemento As PatientRecordMemento, pAutoSnapshot As %Boolean = 0) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..CurrentVersion = ..CurrentVersion + 1
        Set pMemento.Version = ..CurrentVersion
        
        // Mark as regulatory if needed
        If pAutoSnapshot || pMemento.IsRegulatorySnapshot {
            Set ..RegulatoryVersions(..CurrentVersion) = 1
            Do pMemento.MarkAsRegulatorySnapshot()
        }
        
        // Add to version history
        Do ..VersionHistory.Insert(pMemento)
        
        // Update version index
        Set ..VersionIndex(..CurrentVersion) = ..VersionHistory.Count()
        Set ..VersionIndex("timestamp", pMemento.Timestamp) = ..CurrentVersion
        Set ..VersionIndex("user", pMemento.CreatedBy, ..CurrentVersion) = pMemento.Timestamp
        
        // Enforce version limit by removing oldest non-regulatory versions
        While ..VersionHistory.Count() > ..MaxVersions {
            Set tFound = 0
            For i=1:1:..VersionHistory.Count() {
                Set tOldestMemento = ..VersionHistory.GetAt(i)
                If $IsObject(tOldestMemento) && '$Get(..RegulatoryVersions(tOldestMemento.Version)) {
                    // Archive or remove the oldest non-regulatory version
                    If ..AutoArchive {
                        // Archive to global
                        Set tData = ""
                        If tOldestMemento.%IsA("Patterns.Examples.PatientRecordMemento") {
                            Set tData = tOldestMemento.GetState()
                        }
                        If ..UseCompression && (tData '= "") {
                            Set tData = ..CompressData(tData)
                        }
                        If tData '= "" {
                            Set @..ArchivePath@(..PatientID, tOldestMemento.Version) = tData
                            Set @..ArchivePath@(..PatientID, tOldestMemento.Version, "metadata") = tOldestMemento.GetMetadata().%ToJSON()
                        }
                    }
                    // Remove from memory
                    Do ..VersionHistory.RemoveAt(i)
                    Set tFound = 1
                    Quit
                }
            }
            // If no non-regulatory version found, stop trying
            If 'tFound {
                Quit
            }
        }
        
        // Log audit trail
        Do ..LogAuditTrail("ADD", ..CurrentVersion, pMemento.CreatedBy, pMemento.ChangeReason)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get a specific version
Method GetVersion(pVersion As %Integer = 0) As PatientRecordMemento
{
    Set tMemento = ""
    
    If pVersion = 0 {
        // Get current version
        Set tMemento = ..VersionHistory.GetAt(..VersionHistory.Count())
    }
    ElseIf $Data(..VersionIndex(pVersion)) {
        Set tIndex = ..VersionIndex(pVersion)
        If tIndex > 0 && tIndex <= ..VersionHistory.Count() {
            Set tMemento = ..VersionHistory.GetAt(tIndex)
        }
        Else {
            // Try to restore from archive
            Set tMemento = ..RestoreFromArchive(pVersion)
        }
    }
    
    Quit tMemento
}

/// Get version by timestamp
Method GetVersionByTimestamp(pTimestamp As %TimeStamp) As PatientRecordMemento
{
    Set tMemento = ""
    Set tVersion = $Order(..VersionIndex("timestamp", pTimestamp), -1)
    If tVersion '= "" {
        Set tMemento = ..GetVersion($Get(..VersionIndex("timestamp", tVersion)))
    }
    Quit tMemento
}

/// Get versions created by a specific user
Method GetVersionsByUser(pUser As %String, Output pVersions As %ListOfObjects) As %Status
{
    Set tSC = $$$OK
    Set pVersions = ##class(%ListOfObjects).%New()
    
    Try {
        Set tVersion = ""
        For {
            Set tVersion = $Order(..VersionIndex("user", pUser, tVersion))
            Quit:tVersion=""
            
            Set tMemento = ..GetVersion(tVersion)
            If $IsObject(tMemento) {
                Do pVersions.Insert(tMemento)
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Compare two versions
Method CompareVersions(pVersion1 As %Integer, pVersion2 As %Integer) As %DynamicObject
{
    Set tDiff = {}
    
    Set tMemento1 = ..GetVersion(pVersion1)
    Set tMemento2 = ..GetVersion(pVersion2)
    
    If $IsObject(tMemento1) && $IsObject(tMemento2) {
        Set tDiff = tMemento1.CompareWith(tMemento2)
        Set tDiff.version1 = pVersion1
        Set tDiff.version2 = pVersion2
    }
    Else {
        Set tDiff.error = "One or both versions not found"
    }
    
    Quit tDiff
}

/// Create a regulatory snapshot (cannot be deleted)
Method CreateRegulatorySnapshot(pMemento As PatientRecordMemento, pReason As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Do pMemento.MarkAsRegulatorySnapshot()
        Set pMemento.ChangeReason = pMemento.ChangeReason _ " [REGULATORY: " _ pReason _ "]"
        Set tSC = ..AddVersion(pMemento, 1)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Archive old versions to global storage
Method ArchiveOldVersions() As %Status [ Private ]
{
    Set tSC = $$$OK
    Set tArchiveCount = 0
    
    Try {
        While ..VersionHistory.Count() > ..MaxVersions {
            Set tMemento = ..VersionHistory.GetAt(1)
            If $IsObject(tMemento) {
                // Don't archive regulatory versions
                If '$Get(..RegulatoryVersions(tMemento.Version)) {
                    // Archive to global
                    If ..UseCompression {
                        Set tData = ..CompressData(tMemento.GetPatientData())
                    }
                    Else {
                        Set tData = tMemento.GetPatientData()
                    }
                    
                    Set @..ArchivePath@(..PatientID, tMemento.Version) = tData
                    Set @..ArchivePath@(..PatientID, tMemento.Version, "metadata") = tMemento.GetMetadata().%ToJSON()
                    
                    // Remove from memory
                    Do ..VersionHistory.RemoveAt(1)
                    Set tArchiveCount = tArchiveCount + 1
                }
                Else {
                    // Can't remove regulatory version, stop archiving
                    Quit
                }
            }
        }
        
        If tArchiveCount > 0 {
            Do ..LogAuditTrail("ARCHIVE", tArchiveCount, $USERNAME, "Auto-archive old versions")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Restore version from archive
Method RestoreFromArchive(pVersion As %Integer) As PatientRecordMemento [ Private ]
{
    Set tMemento = ""
    
    Try {
        If $Data(@..ArchivePath@(..PatientID, pVersion)) {
            Set tData = @..ArchivePath@(..PatientID, pVersion)
            If ..UseCompression {
                Set tData = ..DecompressData(tData)
            }
            
            Set tMetadata = @..ArchivePath@(..PatientID, pVersion, "metadata")
            Set tMeta = {}.%FromJSON(tMetadata)
            
            Set tMemento = ##class(PatientRecordMemento).%New(tData, tMeta.createdBy, tMeta.reason)
            Set tMemento.Version = pVersion
            Set tMemento.Timestamp = tMeta.timestamp
        }
    }
    Catch ex {
        // Log error but don't throw
        Do ..LogAuditTrail("RESTORE_ERROR", pVersion, $USERNAME, ex.DisplayString())
    }
    
    Quit tMemento
}

/// Compress data for storage
Method CompressData(pData As %String) As %String [ Private ]
{
    // Simple compression simulation - in production use proper compression
    Set tStream = ##class(%Stream.GlobalCharacter).%New()
    Do tStream.Write(pData)
    Do tStream.Compress()
    Set tCompressed = ""
    Do tStream.Rewind()
    While 'tStream.AtEnd {
        Set tCompressed = tCompressed _ tStream.Read(32000)
    }
    Quit tCompressed
}

/// Decompress data from storage
Method DecompressData(pData As %String) As %String [ Private ]
{
    // Simple decompression simulation
    Set tStream = ##class(%Stream.GlobalCharacter).%New()
    Do tStream.Write(pData)
    Do tStream.Decompress()
    Set tDecompressed = ""
    Do tStream.Rewind()
    While 'tStream.AtEnd {
        Set tDecompressed = tDecompressed _ tStream.Read(32000)
    }
    Quit tDecompressed
}

/// Apply retention policy
Method ApplyRetentionPolicy() As %Status
{
    Set tSC = $$$OK
    Set tDeleteCount = 0
    
    Try {
        Set tCutoffDate = $ZDATETIME($HOROLOG - ..RetentionDays, 3)
        
        // Check archived versions
        Set tVersion = ""
        For {
            Set tVersion = $Order(@..ArchivePath@(..PatientID, tVersion))
            Quit:tVersion=""
            
            Set tMetadata = $Get(@..ArchivePath@(..PatientID, tVersion, "metadata"))
            If tMetadata '= "" {
                Set tMeta = {}.%FromJSON(tMetadata)
                If tMeta.timestamp < tCutoffDate && '$Get(..RegulatoryVersions(tVersion)) {
                    // Delete old non-regulatory version
                    Kill @..ArchivePath@(..PatientID, tVersion)
                    Set tDeleteCount = tDeleteCount + 1
                }
            }
        }
        
        If tDeleteCount > 0 {
            Do ..LogAuditTrail("RETENTION", tDeleteCount, $USERNAME, "Applied retention policy")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Log audit trail
Method LogAuditTrail(pAction As %String, pVersion As %String, pUser As %String, pReason As %String) [ Private ]
{
    Set ^Patterns.PatientAudit(..PatientID, $INCREMENT(^Patterns.PatientAudit)) = $ListBuild(
        $ZDATETIME($HOROLOG, 3),
        pAction,
        pVersion,
        pUser,
        pReason,
        $JOB
    )
}

/// Get audit trail for this patient
Method GetAuditTrail(Output pTrail As %DynamicArray) As %Status
{
    Set tSC = $$$OK
    Set pTrail = []
    
    Try {
        Set tIndex = ""
        For {
            Set tIndex = $Order(^Patterns.PatientAudit(..PatientID, tIndex))
            Quit:tIndex=""
            
            Set tEntry = $Get(^Patterns.PatientAudit(..PatientID, tIndex))
            If tEntry '= "" {
                Set tAudit = {}
                Set tAudit.timestamp = $ListGet(tEntry, 1)
                Set tAudit.action = $ListGet(tEntry, 2)
                Set tAudit.version = $ListGet(tEntry, 3)
                Set tAudit.user = $ListGet(tEntry, 4)
                Set tAudit.reason = $ListGet(tEntry, 5)
                Set tAudit.process = $ListGet(tEntry, 6)
                Do pTrail.%Push(tAudit)
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Schedule automatic snapshot
Method ScheduleSnapshot(pCronExpression As %String = "0 0 * * *") As %Status
{
    // Placeholder for scheduled snapshot functionality
    // Would integrate with Task Manager in production
    Quit $$$OK
}

/// Rollback to a specific version
Method RollbackToVersion(pVersion As %Integer, pReason As %String) As PatientRecordMemento
{
    Set tRollbackMemento = ""
    Set tMemento = ..GetVersion(pVersion)
    If $IsObject(tMemento) {
        // Create new version with old data
        Set tRollbackMemento = ##class(PatientRecordMemento).CreateWithMetadata(
            tMemento.GetPatientData(),
            $USERNAME,
            "ROLLBACK to version " _ pVersion _ ": " _ pReason
        )
        Do ..AddVersion(tRollbackMemento)
        Do ..LogAuditTrail("ROLLBACK", pVersion, $USERNAME, pReason)
    }
    Quit tRollbackMemento
}

/// Get version history summary
Method GetVersionSummary() As %DynamicObject
{
    Set tSummary = {}
    Set tSummary.total = ..CurrentVersion
    Set tSummary."in_memory" = ..VersionHistory.Count()
    Set tSummary.archived = ..CurrentVersion - ..VersionHistory.Count()
    Set tSummary.regulatory = 0
    
    Set tVersion = ""
    For {
        Set tVersion = $Order(..RegulatoryVersions(tVersion))
        Quit:tVersion=""
        Set tSummary.regulatory = tSummary.regulatory + 1
    }
    
    Set tSummary."retention_days" = ..RetentionDays
    Set tSummary."max_versions" = ..MaxVersions
    Set tSummary."patient_id" = ..PatientID
    
    Quit tSummary
}

/// Clean up old versions and audit logs
Method Cleanup() As %Status
{
    Set tSC = $$$OK
    Try {
        // Apply retention policy
        Set tSC = ..ApplyRetentionPolicy()
        
        // Clean up orphaned indices
        Kill ..VersionIndex
        Kill ..RegulatoryVersions
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
