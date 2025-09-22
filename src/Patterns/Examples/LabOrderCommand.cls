/// Healthcare Example - Lab Order Command
/// 
/// Purpose:
/// Concrete command that encapsulates a lab order request, including the ability
/// to create, execute, and undo lab orders in a healthcare system.
/// 
/// Responsibilities:
/// - Encapsulate lab order creation parameters
/// - Execute lab order on the clinical order receiver
/// - Support undo by reverting order state
/// - Validate lab-specific requirements
/// 
/// @see Patterns.GoF.Behavioral.Command
/// @see Patterns.Examples.ClinicalOrder
/// @since 1.0.0
Class Patterns.Examples.LabOrderCommand Extends Patterns.GoF.Behavioral.Command
{

// ===== PROPERTIES =====

/// Lab test codes to order
Property LabTests As list Of %String;

/// Specimen type (Blood, Urine, etc.)
Property SpecimenType As %String;

/// Fasting required flag
Property FastingRequired As %Boolean [ InitialExpression = 0 ];

/// STAT order flag
Property IsSTAT As %Boolean [ InitialExpression = 0 ];

/// Special instructions
Property SpecialInstructions As %String(MAXLEN = 1000);

// ===== CONSTRUCTORS/DESTRUCTORS =====

/// Constructor - Initialize the lab order command
/// 
/// @param pReceiver The receiver object (ClinicalOrder)
/// @param pParameters Dynamic object with lab order parameters
/// @return Status code
Method %OnNew(pReceiver As Patterns.GoF.Behavioral.Receiver, pParameters As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Call parent constructor
        Set tSC = ##super(pReceiver, pParameters)
        If $$$ISERR(tSC) Quit
        
        // Extract parameters if provided
        If $ISOBJECT(pParameters) {
            // Get lab tests
            If pParameters.%IsDefined("labTests") {
                Set tLabTests = pParameters.labTests
                If tLabTests '= "" {
                    For i = 1:1:$LENGTH(tLabTests, ",") {
                        Set tTest = $ZSTRIP($PIECE(tLabTests, ",", i), "<>W")
                        If tTest '= "" {
                            Do ..LabTests.Insert(tTest)
                        }
                    }
                }
            }
            
            // Get specimen type
            If pParameters.%IsDefined("specimenType") {
                Set ..SpecimenType = pParameters.specimenType
            } Else {
                Set ..SpecimenType = "Blood"
            }
            
            // Get fasting requirement
            If pParameters.%IsDefined("fastingRequired") {
                Set ..FastingRequired = pParameters.fastingRequired
            }
            
            // Get STAT flag
            If pParameters.%IsDefined("isSTAT") {
                Set ..IsSTAT = pParameters.isSTAT
            }
            
            // Get special instructions
            If pParameters.%IsDefined("specialInstructions") {
                Set ..SpecialInstructions = pParameters.specialInstructions
            }
            
            // Set description
            If pParameters.%IsDefined("labTests") {
                Set ..Description = "Lab Order: " _ pParameters.labTests
            } Else {
                Set ..Description = "Lab Order"
            }
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== PUBLIC METHODS =====

/// Execute the lab order command
/// 
/// @return Status code
Method Execute() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if already executed
        If ..IsExecuted {
            Set tSC = $$$ERROR($$$GeneralError, "Lab order command already executed")
            Quit
        }
        
        // Validate we have a receiver
        If '$ISOBJECT(..Receiver) {
            Set tSC = $$$ERROR($$$GeneralError, "No clinical order receiver specified")
            Quit
        }
        
        // Capture state before execution
        Set tSC = ..CaptureState()
        If $$$ISERR(tSC) Quit
        
        // Cast receiver to ClinicalOrder
        Set tOrder = ..Receiver
        
        // Set order type if not already set
        If tOrder.OrderType = "" {
            Set tOrder.OrderType = "Lab"
        }
        
        // Build order description
        Set tDescription = "Lab Order"
        If ..LabTests.Count() > 0 {
            Set tDescription = tDescription _ ": "
            For i = 1:1:..LabTests.Count() {
                If i > 1 { Set tDescription = tDescription _ ", " }
                Set tDescription = tDescription _ ..LabTests.GetAt(i)
            }
        }
        Set tOrder.Description = tDescription
        
        // Add lab tests as order items
        For i = 1:1:..LabTests.Count() {
            Set tTest = ..LabTests.GetAt(i)
            Do tOrder.AddOrderItem(tTest _ " (" _ ..SpecimenType _ ")")
        }
        
        // Set priority based on STAT flag
        If ..IsSTAT {
            Set tSC = tOrder.SetPriority("STAT")
            If $$$ISERR(tSC) Quit
        }
        
        // Add special instructions to clinical notes
        If ..SpecialInstructions '= "" {
            If tOrder.ClinicalNotes '= "" {
                Set tOrder.ClinicalNotes = tOrder.ClinicalNotes _ " | "
            }
            Set tOrder.ClinicalNotes = tOrder.ClinicalNotes _ "Lab Instructions: " _ ..SpecialInstructions
        }
        
        // Add fasting requirement note
        If ..FastingRequired {
            If tOrder.ClinicalNotes '= "" {
                Set tOrder.ClinicalNotes = tOrder.ClinicalNotes _ " | "
            }
            Set tOrder.ClinicalNotes = tOrder.ClinicalNotes _ "FASTING REQUIRED"
        }
        
        // Auto-submit the order if in Draft state
        If tOrder.State = tOrder.#STATEDRAFT {
            Set tSC = tOrder.Submit()
            If $$$ISERR(tSC) Quit
        }
        
        // Save current state after execution
        Set tSC = ..SaveCurrentState()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Undo the lab order command
/// 
/// @return Status code
Method Undo() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if we can undo
        If '..CanUndo() {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot undo lab order command")
            Quit
        }
        
        // Restore previous state
        If $ISOBJECT(..Receiver) && $ISOBJECT(..PreviousState) {
            Set tSC = ..Receiver.RestoreState(..PreviousState)
            If $$$ISERR(tSC) Quit
            
            // Mark as not executed
            Set ..IsExecuted = 0
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate the command can be executed
/// 
/// @return Boolean indicating if command can execute
Method CanExecute() As %Boolean
{
    // Check base conditions
    If ..IsExecuted {
        Quit 0
    }
    
    // Must have receiver
    If '$ISOBJECT(..Receiver) {
        Quit 0
    }
    
    // Must have at least one lab test
    If ..LabTests.Count() = 0 {
        Quit 0
    }
    
    // Check if order is in a state that allows modification
    Set tOrder = ..Receiver
    If tOrder.State = tOrder.#STATECOMPLETED || tOrder.State = tOrder.#STATECANCELLED {
        Quit 0
    }
    
    Quit 1
}

/// Add a lab test to the order
/// 
/// @param pTestCode The lab test code to add
/// @return Status code
Method AddLabTest(pTestCode As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..IsExecuted {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot modify executed command")
            Quit
        }
        
        If pTestCode '= "" {
            Do ..LabTests.Insert(pTestCode)
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Set STAT priority for urgent lab order
/// 
/// @param pIsSTAT Boolean flag for STAT order
/// @return Status code
Method SetSTAT(pIsSTAT As %Boolean = 1) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..IsExecuted {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot modify executed command")
            Quit
        }
        
        Set ..IsSTAT = pIsSTAT
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

// ===== CLASS METHODS =====

/// Create a CBC panel command
/// 
/// @param pReceiver The clinical order receiver
/// @return New lab order command for CBC
ClassMethod CreateCBCPanel(pReceiver As Patterns.Examples.ClinicalOrder) As LabOrderCommand
{
    Set tParams = {}
    Set tParams.labTests = "Complete Blood Count,WBC Differential"
    Set tParams.specimenType = "Blood"
    Quit ##class(LabOrderCommand).%New(pReceiver, tParams)
}

/// Create a BMP panel command
/// 
/// @param pReceiver The clinical order receiver
/// @return New lab order command for BMP
ClassMethod CreateBMPPanel(pReceiver As Patterns.Examples.ClinicalOrder) As LabOrderCommand
{
    Set tParams = {}
    Set tParams.labTests = "Glucose,BUN,Creatinine,Sodium,Potassium,Chloride,CO2"
    Set tParams.specimenType = "Blood"
    Quit ##class(LabOrderCommand).%New(pReceiver, tParams)
}

/// Create a CMP panel command
/// 
/// @param pReceiver The clinical order receiver
/// @return New lab order command for CMP
ClassMethod CreateCMPPanel(pReceiver As Patterns.Examples.ClinicalOrder) As LabOrderCommand
{
    Set tParams = {}
    Set tParams.labTests = "Glucose,BUN,Creatinine,Sodium,Potassium,Chloride,CO2,Calcium,Total Protein,Albumin,AST,ALT,Alkaline Phosphatase,Bilirubin"
    Set tParams.specimenType = "Blood"
    Quit ##class(LabOrderCommand).%New(pReceiver, tParams)
}

/// Create a standard lab panel command
/// 
/// @param pOrder The clinical order receiver
/// @param pPanelType Type of panel (CBC, BMP, CMP, etc.)
/// @return New lab order command
ClassMethod CreateLabPanel(pOrder As ClinicalOrder, pPanelType As %String) As LabOrderCommand
{
    Set tCommand = ""
    
    Try {
        Set tParams = {}
        
        // Define standard panels
        If pPanelType = "CBC" {
            Set tParams.labTests = "Complete Blood Count,WBC Differential"
        } ElseIf pPanelType = "BMP" {
            Set tParams.labTests = "Glucose,BUN,Creatinine,Sodium,Potassium,Chloride,CO2"
        } ElseIf pPanelType = "CMP" {
            Set tParams.labTests = "Glucose,BUN,Creatinine,Sodium,Potassium,Chloride,CO2,Calcium,Total Protein,Albumin,AST,ALT,Alkaline Phosphatase,Bilirubin"
        } ElseIf pPanelType = "Lipid" {
            Set tParams.labTests = "Total Cholesterol,HDL,LDL,Triglycerides"
        } ElseIf pPanelType = "Thyroid" {
            Set tParams.labTests = "TSH,T3,T4,Free T4"
        }
        
        Set tParams.specimenType = "Blood"
        
        // Create command with panel tests
        Set tCommand = ##class(LabOrderCommand).%New(pOrder, tParams)
        Set tCommand.Description = pPanelType _ " Panel"
        
    } Catch ex {
        Set tCommand = ""
    }
    
    Quit tCommand
}

}
