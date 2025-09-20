/// Healthcare Example - Prescribed Medication Context
/// 
/// Represents the context for a medication prescription, containing the extrinsic
/// state (patient-specific information) that works with the shared medication flyweights.
/// 
/// Structure:
/// <example>
/// Set prescription = ##class(Patterns.Examples.PrescribedMedication).%New()
/// Set prescription.PatientID = "P12345"
/// Set prescription.Medication = ##class(Patterns.Examples.MedicationFactory).GetMedication("Aspirin")
/// Set prescription.Dosage = "81mg"
/// Set prescription.Frequency = "Once daily"
/// Write prescription.Display()
/// </example>
/// 
/// @see Patterns.Examples.Medication
/// @see Patterns.Examples.MedicationFactory
/// @since 1.0.0
Class Patterns.Examples.PrescribedMedication Extends %RegisteredObject
{

/// Patient identifier (extrinsic state)
Property PatientID As %String;

/// Reference to shared medication flyweight (intrinsic state)
Property Medication As Patterns.Examples.Medication;

/// Prescribed dosage (extrinsic state)
Property Dosage As %String;

/// Frequency of administration (extrinsic state)
Property Frequency As %String;

/// Prescription start date (extrinsic state)
Property StartDate As %Date [ InitialExpression = {+$HOROLOG} ];

/// Prescription end date (extrinsic state)
Property EndDate As %Date;

/// Prescribing physician (extrinsic state)
Property Prescriber As %String;

/// Refills remaining (extrinsic state)
Property RefillsRemaining As %Integer [ InitialExpression = 0 ];

/// Special instructions (extrinsic state)
Property Instructions As %String;

/// Initialize a new prescription
Method %OnNew(pPatientID As %String = "", pMedicationName As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pPatientID '= "" {
            Set ..PatientID = pPatientID
        }
        
        If pMedicationName '= "" {
            // Get shared medication flyweight from factory
            Set ..Medication = ##class(Patterns.Examples.MedicationFactory).GetMedication(pMedicationName)
        }
        
        // Set default start date to today
        Set ..StartDate = +$HOROLOG
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Set medication using medication name (gets from factory)
Method SetMedication(pMedicationName As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..Medication = ##class(Patterns.Examples.MedicationFactory).GetMedication(pMedicationName)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Display prescription information
Method Display() As %String
{
    Set tDisplay = ""
    
    Try {
        If $ISOBJECT(..Medication) {
            // Build extrinsic state string for medication operation
            Set tExtrinsicState = ..PatientID_"|"_..Dosage_"|"_..Frequency_"|"_$ZDATE(..StartDate, 3)
            Set tDisplay = ..Medication.Operation(tExtrinsicState)
            
            // Add additional prescription details
            If ..Prescriber '= "" {
                Set tDisplay = tDisplay_", Prescribed by: "_..Prescriber
            }
            
            If ..RefillsRemaining > 0 {
                Set tDisplay = tDisplay_", Refills: "_..RefillsRemaining
            }
            
            If ..EndDate '= "" {
                Set tDisplay = tDisplay_", Until: "_$ZDATE(..EndDate, 3)
            }
            
            If ..Instructions '= "" {
                Set tDisplay = tDisplay_", Instructions: "_..Instructions
            }
        }
        Else {
            Set tDisplay = "No medication specified for patient "_..PatientID
        }
    }
    Catch ex {
        Set tDisplay = "Error displaying prescription: "_ex.Name
    }
    
    Quit tDisplay
}

/// Get prescription as JSON
Method ToJSON() As %String
{
    Set tJSON = "{"
    Set tJSON = tJSON_"""patientId"":"""_..PatientID_""""
    
    If $ISOBJECT(..Medication) {
        Set tJSON = tJSON_",""medicationName"":"""_..Medication.DrugName_""""
        Set tJSON = tJSON_",""genericName"":"""_..Medication.GenericName_""""
    }
    
    Set tJSON = tJSON_",""dosage"":"""_..Dosage_""""
    Set tJSON = tJSON_",""frequency"":"""_..Frequency_""""
    Set tJSON = tJSON_",""startDate"":"""_$ZDATE(..StartDate, 3)_""""
    
    If ..EndDate '= "" {
        Set tJSON = tJSON_",""endDate"":"""_$ZDATE(..EndDate, 3)_""""
    }
    
    If ..Prescriber '= "" {
        Set tJSON = tJSON_",""prescriber"":"""_..Prescriber_""""
    }
    
    Set tJSON = tJSON_",""refillsRemaining"":"_..RefillsRemaining
    
    If ..Instructions '= "" {
        Set tJSON = tJSON_",""instructions"":"""_..Instructions_""""
    }
    
    Set tJSON = tJSON_"}"
    
    Quit tJSON
}

/// Check if prescription is active
Method IsActive() As %Boolean
{
    Set tActive = 0
    
    Try {
        Set tToday = +$HOROLOG
        
        // Check if started
        If ..StartDate > tToday {
            Quit  // Not started yet
        }
        
        // Check if ended
        If (..EndDate '= "") && (..EndDate < tToday) {
            Quit  // Already ended
        }
        
        Set tActive = 1
    }
    Catch ex {
        // Error checking, assume inactive
    }
    
    Quit tActive
}

/// Check for drug interactions with another prescription
Method CheckInteractionWith(pOtherPrescription As PrescribedMedication) As %Boolean
{
    Set tHasInteraction = 0
    
    Try {
        If $ISOBJECT(..Medication) && $ISOBJECT(pOtherPrescription) && $ISOBJECT(pOtherPrescription.Medication) {
            // Check if this medication interacts with the other
            Set tHasInteraction = ..Medication.CheckInteraction(pOtherPrescription.Medication.DrugName)
        }
    }
    Catch ex {
        // Error checking interaction
    }
    
    Quit tHasInteraction
}

/// Calculate days remaining in prescription
Method DaysRemaining() As %Integer
{
    Set tDays = -1
    
    Try {
        If ..EndDate '= "" {
            Set tToday = +$HOROLOG
            Set tDays = ..EndDate - tToday
            If tDays < 0 Set tDays = 0
        }
    }
    Catch ex {
        // Error calculating
    }
    
    Quit tDays
}

/// Get memory size estimate (demonstrates flyweight benefit)
Method GetMemoryEstimate() As %Integer
{
    Set tSize = 0
    
    Try {
        // Extrinsic state size (stored per prescription)
        Set tSize = $LENGTH(..PatientID) + $LENGTH(..Dosage) + $LENGTH(..Frequency)
        Set tSize = tSize + $LENGTH(..Prescriber) + $LENGTH(..Instructions)
        Set tSize = tSize + 20  // Dates and integers
        
        // Only add reference size for medication, not full object
        Set tSize = tSize + 8  // Object reference size
        
        // Without flyweight, would need to add all medication data
        // which could be 200+ bytes per prescription
    }
    Catch ex {
        Set tSize = 0
    }
    
    Quit tSize
}

}
