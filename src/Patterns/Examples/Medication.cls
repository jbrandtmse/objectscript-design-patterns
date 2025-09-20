/// Healthcare Example - Medication as Flyweight
/// 
/// Represents medication reference data that is shared across multiple prescriptions.
/// The intrinsic state includes drug information that doesn't change per patient,
/// while extrinsic state (dosage, frequency) is passed in when needed.
/// 
/// Structure:
/// <example>
/// Set med = ##class(Patterns.Examples.MedicationFactory).GetMedication("Aspirin")
/// Set prescription = med.Prescribe("Patient123", "100mg", "Once daily")
/// </example>
/// 
/// @see Patterns.GoF.Structural.Flyweight
/// @see Patterns.Examples.MedicationFactory
/// @since 1.0.0
Class Patterns.Examples.Medication Extends Patterns.GoF.Structural.Flyweight
{

/// Drug name (brand name)
Property DrugName As %String;

/// Generic name of the drug
Property GenericName As %String;

/// Drug classification
Property DrugClass As %String;

/// Common drug interactions (semicolon-separated list)
Property Interactions As %String;

/// Standard dosage forms available
Property DosageForms As %String;

/// FDA approval date
Property ApprovalDate As %Date;

/// Manufacturer
Property Manufacturer As %String;

/// Initialize medication with intrinsic data
Method %OnNew(pDrugName As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pDrugName '= "" {
            Set ..DrugName = pDrugName
            Set ..IntrinsicState = pDrugName
            
            // Initialize with default reference data
            Do ..LoadReferenceData(pDrugName)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Load reference data for a specific medication
Method LoadReferenceData(pDrugName As %String) As %Status [ Private ]
{
    Set tSC = $$$OK
    
    Try {
        // Simulate loading reference data (would normally come from database)
        If pDrugName = "Aspirin" {
            Set ..GenericName = "Acetylsalicylic acid"
            Set ..DrugClass = "NSAID/Antiplatelet"
            Set ..Interactions = "Warfarin;Heparin;Ibuprofen;Alcohol"
            Set ..DosageForms = "81mg;325mg;500mg"
            Set ..Manufacturer = "Multiple"
            Set ..ApprovalDate = $ZDATEH("1950-06-01", 3)
        }
        ElseIf pDrugName = "Lisinopril" {
            Set ..GenericName = "Lisinopril"
            Set ..DrugClass = "ACE Inhibitor"
            Set ..Interactions = "Potassium;Lithium;NSAIDs;Diuretics"
            Set ..DosageForms = "2.5mg;5mg;10mg;20mg;40mg"
            Set ..Manufacturer = "Multiple"
            Set ..ApprovalDate = $ZDATEH("1987-12-29", 3)
        }
        ElseIf pDrugName = "Metformin" {
            Set ..GenericName = "Metformin hydrochloride"
            Set ..DrugClass = "Biguanide/Antidiabetic"
            Set ..Interactions = "Alcohol;Contrast dye;Diuretics;Steroids"
            Set ..DosageForms = "500mg;850mg;1000mg"
            Set ..Manufacturer = "Multiple"
            Set ..ApprovalDate = $ZDATEH("1995-03-03", 3)
        }
        ElseIf pDrugName = "Atorvastatin" {
            Set ..GenericName = "Atorvastatin calcium"
            Set ..DrugClass = "Statin"
            Set ..Interactions = "Grapefruit;Erythromycin;Warfarin;Digoxin"
            Set ..DosageForms = "10mg;20mg;40mg;80mg"
            Set ..Manufacturer = "Pfizer"
            Set ..ApprovalDate = $ZDATEH("1996-12-17", 3)
        }
        Else {
            // Default medication data
            Set ..GenericName = pDrugName
            Set ..DrugClass = "Unclassified"
            Set ..Interactions = "None documented"
            Set ..DosageForms = "Various"
            Set ..Manufacturer = "Generic"
            Set ..ApprovalDate = $HOROLOG
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Operation: Prescribe medication with extrinsic patient-specific data
/// 
/// @param pExtrinsicState Patient-specific prescription details
/// @return Prescription information combining intrinsic and extrinsic data
Method Operation(pExtrinsicState As %String) As %String
{
    Set tResult = ""
    
    Try {
        // Parse extrinsic state (format: "PatientID|Dosage|Frequency|StartDate")
        Set tPatientID = $PIECE(pExtrinsicState, "|", 1)
        Set tDosage = $PIECE(pExtrinsicState, "|", 2)
        Set tFrequency = $PIECE(pExtrinsicState, "|", 3)
        Set tStartDate = $PIECE(pExtrinsicState, "|", 4)
        
        // Combine intrinsic medication data with extrinsic prescription data
        Set tResult = "Prescription: "_..DrugName
        Set tResult = tResult_" ("_..GenericName_")"
        Set tResult = tResult_" for Patient "_tPatientID
        Set tResult = tResult_", "_tDosage
        Set tResult = tResult_", "_tFrequency
        Set tResult = tResult_", Starting "_tStartDate
    }
    Catch ex {
        Set tResult = "Error creating prescription: "_ex.Name
    }
    
    Quit tResult
}

/// Create prescription with structured parameters
Method Prescribe(pPatientID As %String, pDosage As %String, pFrequency As %String, pStartDate As %String = {+$HOROLOG}) As %String
{
    // Build extrinsic state and call Operation
    Set tExtrinsicState = pPatientID_"|"_pDosage_"|"_pFrequency_"|"
    
    If pStartDate = +$HOROLOG {
        Set tExtrinsicState = tExtrinsicState_$ZDATE(+$HOROLOG, 3)
    } Else {
        Set tExtrinsicState = tExtrinsicState_pStartDate
    }
    
    Quit ..Operation(tExtrinsicState)
}

/// Check for drug interactions with another medication
Method CheckInteraction(pOtherDrug As %String) As %Boolean
{
    Set tHasInteraction = 0
    
    Try {
        // Check if the other drug is in our interactions list
        Set tInteractionList = $ZCONVERT(..Interactions, "U")
        Set pOtherDrugUpper = $ZCONVERT(pOtherDrug, "U")
        
        If tInteractionList [ pOtherDrugUpper {
            Set tHasInteraction = 1
        }
    }
    Catch ex {
        // Log error but don't fail
    }
    
    Quit tHasInteraction
}

/// Get medication information as JSON string
Method GetMedicationInfo() As %String
{
    Set tInfo = "{"
    Set tInfo = tInfo_"""drugName"":"""_..DrugName_""""
    Set tInfo = tInfo_",""genericName"":"""_..GenericName_""""
    Set tInfo = tInfo_",""drugClass"":"""_..DrugClass_""""
    Set tInfo = tInfo_",""interactions"":"""_..Interactions_""""
    Set tInfo = tInfo_",""dosageForms"":"""_..DosageForms_""""
    Set tInfo = tInfo_",""manufacturer"":"""_..Manufacturer_""""
    
    If ..ApprovalDate '= "" {
        Set tInfo = tInfo_",""approvalDate"":"""_$ZDATE(..ApprovalDate, 3)_""""
    }
    
    Set tInfo = tInfo_"}"
    
    Quit tInfo
}

/// Display medication details
Method Display() As %String
{
    Set tDisplay = "Medication: "_..DrugName
    Set tDisplay = tDisplay_" (Generic: "_..GenericName_")"
    Set tDisplay = tDisplay_", Class: "_..DrugClass
    Set tDisplay = tDisplay_", Forms: "_..DosageForms
    Quit tDisplay
}

}
