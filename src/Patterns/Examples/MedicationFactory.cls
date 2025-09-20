/// Healthcare Example - Medication Factory
/// 
/// Factory for managing shared medication flyweights. Ensures that medication
/// reference data is shared across all prescriptions, significantly reducing
/// memory usage when dealing with thousands of prescriptions.
/// 
/// Structure:
/// <example>
/// // Initialize standard medications
/// Do ##class(Patterns.Examples.MedicationFactory).LoadStandardMedications()
/// 
/// // Get shared medication instances
/// Set aspirin = ##class(Patterns.Examples.MedicationFactory).GetMedication("Aspirin")
/// Set aspirin2 = ##class(Patterns.Examples.MedicationFactory).GetMedication("Aspirin")
/// // aspirin and aspirin2 reference the same object
/// 
/// // Display statistics
/// Write ##class(Patterns.Examples.MedicationFactory).GetStatistics()
/// </example>
/// 
/// @see Patterns.Examples.Medication
/// @see Patterns.GoF.Structural.FlyweightFactory
/// @since 1.0.0
Class Patterns.Examples.MedicationFactory Extends %RegisteredObject
{

/// Static pool of medication flyweights
Property MedicationPool [ MultiDimensional, Private ];

/// Singleton instance of the factory
Property %Instance As MedicationFactory [ Private ];

/// Statistics tracking
Property TotalRequests As %Integer [ InitialExpression = 0 ];

Property CacheHits As %Integer [ InitialExpression = 0 ];

Property CacheMisses As %Integer [ InitialExpression = 0 ];

Property MemorySaved As %Integer [ InitialExpression = 0 ];

/// Get or create medication flyweight
/// 
/// @param pMedicationName Name of the medication
/// @return Shared Medication instance
ClassMethod GetMedication(pMedicationName As %String) As Medication
{
    Set tMedication = ""
    
    Try {
        // Use process-level cache since globals can't store object references
        If '$DATA(%MedicationCache) {
            Set %MedicationCache = ##class(%ArrayOfObjects).%New()
        }
        
        // Check cache first
        If %MedicationCache.IsDefined(pMedicationName) {
            Set tMedication = %MedicationCache.GetAt(pMedicationName)
            Set ^Patterns.Examples.MedicationStats("Hits") = $GET(^Patterns.Examples.MedicationStats("Hits"), 0) + 1
        } Else {
            // Create new medication and cache it
            Set tMedication = ##class(Medication).%New(pMedicationName)
            Do %MedicationCache.SetAt(tMedication, pMedicationName)
            Set ^Patterns.Examples.MedicationStats("Misses") = $GET(^Patterns.Examples.MedicationStats("Misses"), 0) + 1
            // Track keys in global for statistics
            Set ^Patterns.Examples.MedicationPool(pMedicationName) = 1
        }
        
        // Track total requests
        Set ^Patterns.Examples.MedicationStats("TotalRequests") = $GET(^Patterns.Examples.MedicationStats("TotalRequests"), 0) + 1
    }
    Catch ex {
        // Log error but don't fail
    }
    
    Quit tMedication
}

/// Load standard medications into the pool
ClassMethod LoadStandardMedications() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Clear existing pool and cache
        Kill ^Patterns.Examples.MedicationPool
        Kill ^Patterns.Examples.MedicationStats
        If $DATA(%MedicationCache) {
            Kill %MedicationCache
        }
        Set %MedicationCache = ##class(%ArrayOfObjects).%New()
        
        // List of common medications to preload
        Set tMedications = $LISTBUILD("Aspirin", "Lisinopril", "Metformin", "Atorvastatin",
                                      "Amoxicillin", "Omeprazole", "Simvastatin", "Levothyroxine",
                                      "Azithromycin", "Metoprolol", "Albuterol", "Losartan",
                                      "Gabapentin", "Hydrochlorothiazide", "Sertraline")
        
        // Load each medication into cache
        For i = 1:1:$LISTLENGTH(tMedications) {
            Set tMedName = $LISTGET(tMedications, i)
            Set tMed = ##class(Medication).%New(tMedName)
            Do %MedicationCache.SetAt(tMed, tMedName)
            // Track in global for statistics
            Set ^Patterns.Examples.MedicationPool(tMedName) = 1
        }
        
        // Initialize statistics
        Set ^Patterns.Examples.MedicationStats("Initialized") = $ZDATETIME($ZTIMESTAMP, 3, 1, 3)
        Set ^Patterns.Examples.MedicationStats("PreloadedCount") = $LISTLENGTH(tMedications)
        Set ^Patterns.Examples.MedicationStats("TotalRequests") = 0
        Set ^Patterns.Examples.MedicationStats("Hits") = 0
        Set ^Patterns.Examples.MedicationStats("Misses") = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get pool statistics
ClassMethod GetStatistics() As %String
{
    Set tStats = "Medication Factory Statistics:"
    
    Try {
        Set tTotal = $GET(^Patterns.Examples.MedicationStats("TotalRequests"), 0)
        Set tHits = $GET(^Patterns.Examples.MedicationStats("Hits"), 0)
        Set tMisses = $GET(^Patterns.Examples.MedicationStats("Misses"), 0)
        
        // Count pool size
        Set tCount = 0
        Set tKey = ""
        For {
            Set tKey = $ORDER(^Patterns.Examples.MedicationPool(tKey))
            Quit:tKey=""
            Set tCount = tCount + 1
        }
        
        Set tStats = tStats_" Pool Size="_tCount
        Set tStats = tStats_", Total Requests="_tTotal
        Set tStats = tStats_", Cache Hits="_tHits
        Set tStats = tStats_", Cache Misses="_tMisses
        
        If tTotal > 0 {
            Set tHitRate = $FNUMBER((tHits / tTotal) * 100, "", 2)
            Set tStats = tStats_", Hit Rate="_tHitRate_"%"
        }
        
        If $DATA(^Patterns.Examples.MedicationStats("Initialized")) {
            Set tStats = tStats_", Initialized: "_^Patterns.Examples.MedicationStats("Initialized")
        }
    }
    Catch ex {
        Set tStats = tStats_" (Error reading statistics)"
    }
    
    Quit tStats
}

/// Clear the medication pool
ClassMethod ClearPool() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Kill ^Patterns.Examples.MedicationPool
        Kill ^Patterns.Examples.MedicationStats
        If $DATA(%MedicationCache) {
            Kill %MedicationCache
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// List all medications in the pool
ClassMethod ListMedications() As %String
{
    Set tList = ""
    
    Try {
        Set tKey = ""
        For {
            Set tKey = $ORDER(^Patterns.Examples.MedicationPool(tKey))
            Quit:tKey=""
            If tList '= "" Set tList = tList_", "
            Set tList = tList_tKey
        }
    }
    Catch ex {
        Set tList = "Error listing medications"
    }
    
    Quit tList
}

/// Demonstrate memory savings with large number of prescriptions
ClassMethod DemonstrateMemorySavings() As %String
{
    Set tResult = ""
    
    Try {
        // Clear pools
        Do ..ClearPool()
        Do ..LoadStandardMedications()
        
        // Create 1000 prescriptions
        Set tPrescriptions = ##class(%ListOfObjects).%New()
        Set tPatientCount = 100
        Set tPrescriptionsPerPatient = 10
        
        // Track memory usage
        Set tMemoryWithFlyweight = 0
        Set tMemoryWithoutFlyweight = 0
        
        For i = 1:1:tPatientCount {
            Set tPatientID = "P"_$JUSTIFY(i, 5, 0)
            
            For j = 1:1:tPrescriptionsPerPatient {
                // Randomly select a medication
                Set tMedIndex = $RANDOM(15) + 1
                Set tMedName = $LISTGET($LISTBUILD("Aspirin", "Lisinopril", "Metformin", "Atorvastatin",
                                                  "Amoxicillin", "Omeprazole", "Simvastatin", "Levothyroxine",
                                                  "Azithromycin", "Metoprolol", "Albuterol", "Losartan",
                                                  "Gabapentin", "Hydrochlorothiazide", "Sertraline"), tMedIndex)
                
                // Create prescription using flyweight
                Set tPrescription = ##class(PrescribedMedication).%New(tPatientID, tMedName)
                Set tPrescription.Dosage = $LISTGET($LISTBUILD("100mg", "200mg", "500mg"), $RANDOM(3) + 1)
                Set tPrescription.Frequency = $LISTGET($LISTBUILD("Once daily", "Twice daily", "Three times daily"), $RANDOM(3) + 1)
                Set tPrescription.Prescriber = "Dr. Smith"
                Do tPrescriptions.Insert(tPrescription)
                
                // Calculate memory usage
                Set tMemoryWithFlyweight = tMemoryWithFlyweight + tPrescription.GetMemoryEstimate()
                
                // Estimate memory without flyweight (all medication data duplicated)
                Set tMemoryWithoutFlyweight = tMemoryWithoutFlyweight + tPrescription.GetMemoryEstimate() + 200 // ~200 bytes per medication object
            }
        }
        
        // Calculate savings
        Set tTotalPrescriptions = tPatientCount * tPrescriptionsPerPatient
        Set tMemorySaved = tMemoryWithoutFlyweight - tMemoryWithFlyweight
        Set tSavingsPercent = $FNUMBER((tMemorySaved / tMemoryWithoutFlyweight) * 100, "", 2)
        
        // Build result string
        Set tResult = "Memory Savings Demonstration:"
        Set tResult = tResult_" Total Prescriptions="_tTotalPrescriptions
        Set tResult = tResult_", Unique Medications="_15
        Set tResult = tResult_", Memory with Flyweight="_tMemoryWithFlyweight_" bytes"
        Set tResult = tResult_", Memory without Flyweight="_tMemoryWithoutFlyweight_" bytes"
        Set tResult = tResult_", Memory Saved="_tMemorySaved_" bytes ("_tSavingsPercent_"%)"
        Set tResult = tResult_". "_..GetStatistics()
    }
    Catch ex {
        Set tResult = "Error demonstrating memory savings: "_ex.Name
    }
    
    Quit tResult
}

/// Verify that multiple prescriptions share the same medication object
ClassMethod VerifySharing() As %String
{
    Set tResult = ""
    
    Try {
        // Get the same medication twice
        Set tMed1 = ..GetMedication("Aspirin")
        Set tMed2 = ..GetMedication("Aspirin")
        
        // Check if they're the same object
        If tMed1 = tMed2 {
            Set tResult = "SUCCESS: Same medication name returns same object reference. "
        } Else {
            Set tResult = "WARNING: Different objects returned for same medication. "
        }
        
        // Create prescriptions using the same medication
        Set tPrescription1 = ##class(PrescribedMedication).%New("P001", "Aspirin")
        Set tPrescription2 = ##class(PrescribedMedication).%New("P002", "Aspirin")
        
        If tPrescription1.Medication = tPrescription2.Medication {
            Set tResult = tResult_"Prescriptions share the same medication flyweight."
        } Else {
            Set tResult = tResult_"Prescriptions have different medication objects."
        }
    }
    Catch ex {
        Set tResult = "Error verifying sharing: "_ex.Name
    }
    
    Quit tResult
}

/// Get medication count in pool
ClassMethod GetPoolSize() As %Integer
{
    Set tCount = 0
    
    Try {
        Set tKey = ""
        For {
            Set tKey = $ORDER(^Patterns.Examples.MedicationPool(tKey))
            Quit:tKey=""
            Set tCount = tCount + 1
        }
    }
    Catch ex {
        Set tCount = -1
    }
    
    Quit tCount
}

/// Remove medication from pool
ClassMethod RemoveMedication(pMedicationName As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $DATA(^Patterns.Examples.MedicationPool(pMedicationName)) {
            Kill ^Patterns.Examples.MedicationPool(pMedicationName)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
