/// Gang of Four Memento Pattern - Checkpoint History Management
/// 
/// Purpose:
/// Advanced memento management with checkpoint support
/// 
/// Features:
/// - Named checkpoints with metadata
/// - Timestamp-based organization
/// - Pruning strategies (age-based, count-based)
/// - Checkpoint comparison and diff
/// - Branch support for alternate timelines
Class Patterns.GoF.Behavioral.MementoHistory Extends %RegisteredObject
{

/// Map of checkpoints by name
Property Checkpoints [ MultiDimensional, Private ];

/// Ordered list of checkpoint names
Property CheckpointOrder As %ListOfDataTypes [ Private ];

/// Maximum number of checkpoints to keep
Property MaxCheckpoints As %Integer [ InitialExpression = 50 ];

/// Maximum age of checkpoints in days (0 = no limit)
Property MaxAgeInDays As %Integer [ InitialExpression = 30 ];

/// Current branch name
Property CurrentBranch As %String [ InitialExpression = "main" ];

/// Branches map
Property Branches [ MultiDimensional, Private ];

/// Constructor
Method %OnNew(pMaxCheckpoints As %Integer = 50, pMaxAgeInDays As %Integer = 30) As %Status
{
    Set ..MaxCheckpoints = pMaxCheckpoints
    Set ..MaxAgeInDays = pMaxAgeInDays
    Set ..CheckpointOrder = ##class(%ListOfDataTypes).%New()
    
    // Initialize main branch
    Set ..Branches(..CurrentBranch) = $LISTBUILD()
    
    Quit $$$OK
}

/// Add checkpoint with metadata
Method AddCheckpoint(pMemento As Patterns.GoF.Behavioral.Memento, pName As %String = "", pMetadata As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    // Generate name if not provided
    If pName = "" {
        Set pName = "checkpoint_" _ $REPLACE($ZDATETIME($HOROLOG, 3), " ", "_")
    }
    
    // Create checkpoint entry
    Set tCheckpoint = {}
    Set tCheckpoint.memento = pMemento
    Set tCheckpoint.name = pName
    Set tCheckpoint.timestamp = $ZDATETIME($HOROLOG, 3)
    Set tCheckpoint.branch = ..CurrentBranch
    Set tCheckpoint.size = pMemento.GetSize()
    
    If $IsObject(pMetadata) {
        Set tCheckpoint.metadata = pMetadata
    }
    
    // Store checkpoint
    Set ..Checkpoints(pName) = tCheckpoint
    Do ..CheckpointOrder.Insert(pName)
    
    // Add to current branch
    Set tBranchList = ..Branches(..CurrentBranch)
    Set tBranchList = tBranchList _ $LISTBUILD(pName)
    Set ..Branches(..CurrentBranch) = tBranchList
    
    // Apply pruning strategies
    Do ..PruneByCount()
    Do ..PruneByAge()
    
    Quit tSC
}

/// Get checkpoint by name
Method GetCheckpoint(pName As %String) As Patterns.GoF.Behavioral.Memento
{
    If $DATA(..Checkpoints(pName)) {
        Set tCheckpoint = ..Checkpoints(pName)
        Quit tCheckpoint.memento
    }
    Quit $$$NULLOREF
}

/// Remove checkpoint
Method RemoveCheckpoint(pName As %String) As %Status
{
    If '$DATA(..Checkpoints(pName)) {
        Quit $$$ERROR($$$GeneralError, "Checkpoint not found: " _ pName)
    }
    
    Kill ..Checkpoints(pName)
    
    // Remove from order list
    For i=1:1:..CheckpointOrder.Count() {
        If ..CheckpointOrder.GetAt(i) = pName {
            Do ..CheckpointOrder.RemoveAt(i)
            Quit
        }
    }
    
    // Remove from branches
    Set tBranch = ""
    For {
        Set tBranch = $ORDER(..Branches(tBranch))
        Quit:tBranch=""
        
        Set tList = ..Branches(tBranch)
        Set tNewList = $LISTBUILD()
        For j=1:1:$LISTLENGTH(tList) {
            Set tItem = $LISTGET(tList, j)
            If tItem '= pName {
                Set tNewList = tNewList _ $LISTBUILD(tItem)
            }
        }
        Set ..Branches(tBranch) = tNewList
    }
    
    Quit $$$OK
}

/// Prune checkpoints by count limit
Method PruneByCount() As %Status [ Private ]
{
    While (..MaxCheckpoints > 0) && (..CheckpointOrder.Count() > ..MaxCheckpoints) {
        Set tOldest = ..CheckpointOrder.GetAt(1)
        Do ..RemoveCheckpoint(tOldest)
    }
    Quit $$$OK
}

/// Prune checkpoints by age
Method PruneByAge() As %Status [ Private ]
{
    If ..MaxAgeInDays <= 0 Quit $$$OK
    
    Set tCutoffDate = $SYSTEM.SQL.DATEADD("day", -..MaxAgeInDays, $HOROLOG)
    
    Set tToRemove = ##class(%ListOfDataTypes).%New()
    For i=1:1:..CheckpointOrder.Count() {
        Set tName = ..CheckpointOrder.GetAt(i)
        If $DATA(..Checkpoints(tName)) {
            Set tCheckpoint = ..Checkpoints(tName)
            Set tTimestamp = tCheckpoint.timestamp
            // Convert timestamp to $HOROLOG for comparison
            Set tDate = $ZDATEH($PIECE(tTimestamp, " ", 1), 3)
            If tDate < tCutoffDate {
                Do tToRemove.Insert(tName)
            }
        }
    }
    
    For i=1:1:tToRemove.Count() {
        Do ..RemoveCheckpoint(tToRemove.GetAt(i))
    }
    
    Quit $$$OK
}

/// Compare two checkpoints
Method CompareCheckpoints(pName1 As %String, pName2 As %String) As %DynamicObject
{
    Set tResult = {}
    
    If '$DATA(..Checkpoints(pName1)) {
        Set tResult.error = "Checkpoint not found: " _ pName1
        Quit tResult
    }
    
    If '$DATA(..Checkpoints(pName2)) {
        Set tResult.error = "Checkpoint not found: " _ pName2
        Quit tResult
    }
    
    Set tCheckpoint1 = ..Checkpoints(pName1)
    Set tCheckpoint2 = ..Checkpoints(pName2)
    
    Set tMemento1 = tCheckpoint1.memento
    Set tMemento2 = tCheckpoint2.memento
    
    // Compare basic properties
    Set tResult.checkpoint1 = pName1
    Set tResult.checkpoint2 = pName2
    Set tResult.timestamp1 = tCheckpoint1.timestamp
    Set tResult.timestamp2 = tCheckpoint2.timestamp
    Set tResult.sizeDiff = tMemento2.GetSize() - tMemento1.GetSize()
    
    // Compare states
    Set tResult.statesEqual = (tMemento1.GetState() = tMemento2.GetState())
    
    // Compare state data if available
    Set tData1 = tMemento1.GetStateData()
    Set tData2 = tMemento2.GetStateData()
    If $IsObject(tData1) && $IsObject(tData2) {
        Set tResult.dataEqual = (tData1.%ToJSON() = tData2.%ToJSON())
    } Else {
        Set tResult.dataEqual = 1
    }
    
    Quit tResult
}

/// Create a new branch from current checkpoint
Method CreateBranch(pBranchName As %String, pFromCheckpoint As %String = "") As %Status
{
    If $DATA(..Branches(pBranchName)) {
        Quit $$$ERROR($$$GeneralError, "Branch already exists: " _ pBranchName)
    }
    
    If pFromCheckpoint = "" {
        // Branch from current position
        Set ..Branches(pBranchName) = ..Branches(..CurrentBranch)
    } Else {
        // Branch from specific checkpoint
        Set tFound = 0
        Set tNewBranch = $LISTBUILD()
        Set tCurrentBranch = ..Branches(..CurrentBranch)
        
        For i=1:1:$LISTLENGTH(tCurrentBranch) {
            Set tName = $LISTGET(tCurrentBranch, i)
            Set tNewBranch = tNewBranch _ $LISTBUILD(tName)
            If tName = pFromCheckpoint {
                Set tFound = 1
                Quit
            }
        }
        
        If 'tFound {
            Quit $$$ERROR($$$GeneralError, "Checkpoint not found in current branch: " _ pFromCheckpoint)
        }
        
        Set ..Branches(pBranchName) = tNewBranch
    }
    
    Set ..CurrentBranch = pBranchName
    Quit $$$OK
}

/// Switch to a different branch
Method SwitchBranch(pBranchName As %String) As %Status
{
    If '$DATA(..Branches(pBranchName)) {
        Quit $$$ERROR($$$GeneralError, "Branch not found: " _ pBranchName)
    }
    
    Set ..CurrentBranch = pBranchName
    Quit $$$OK
}

/// Get list of all branches
Method GetBranches() As %ListOfDataTypes
{
    Set tList = ##class(%ListOfDataTypes).%New()
    Set tBranch = ""
    For {
        Set tBranch = $ORDER(..Branches(tBranch))
        Quit:tBranch=""
        Do tList.Insert(tBranch)
    }
    Quit tList
}

/// Get checkpoint metadata
Method GetCheckpointMetadata(pName As %String) As %DynamicObject
{
    If $DATA(..Checkpoints(pName)) {
        Set tCheckpoint = ..Checkpoints(pName)
        If tCheckpoint.%IsDefined("metadata") {
            Quit tCheckpoint.metadata
        }
    }
    Quit {}
}

/// Get total size of all checkpoints
Method GetTotalSize() As %Integer
{
    Set tTotal = 0
    For i=1:1:..CheckpointOrder.Count() {
        Set tName = ..CheckpointOrder.GetAt(i)
        If $DATA(..Checkpoints(tName)) {
            Set tCheckpoint = ..Checkpoints(tName)
            Set tTotal = tTotal + tCheckpoint.size
        }
    }
    Quit tTotal
}

/// Get checkpoint statistics
Method GetStatistics() As %DynamicObject
{
    Set tStats = {}
    Set tStats.totalCheckpoints = ..CheckpointOrder.Count()
    Set tStats.totalSize = ..GetTotalSize()
    Set tStats.branches = ..GetBranches().Count()
    Set tStats.currentBranch = ..CurrentBranch
    Set tStats.maxCheckpoints = ..MaxCheckpoints
    Set tStats.maxAgeInDays = ..MaxAgeInDays
    
    // Find oldest and newest
    If ..CheckpointOrder.Count() > 0 {
        Set tFirst = ..CheckpointOrder.GetAt(1)
        Set tLast = ..CheckpointOrder.GetAt(..CheckpointOrder.Count())
        
        If $DATA(..Checkpoints(tFirst)) {
            Set tStats.oldestCheckpoint = tFirst
            Set tStats.oldestTimestamp = ..Checkpoints(tFirst).timestamp
        }
        
        If $DATA(..Checkpoints(tLast)) {
            Set tStats.newestCheckpoint = tLast
            Set tStats.newestTimestamp = ..Checkpoints(tLast).timestamp
        }
    }
    
    Quit tStats
}

/// Save checkpoint - alias for AddCheckpoint for compatibility
Method SaveCheckpoint(pMemento As Patterns.GoF.Behavioral.Memento, pName As %String = "", pMetadata As %DynamicObject = "") As %Status
{
    Quit ..AddCheckpoint(pMemento, pName, pMetadata)
}

}
