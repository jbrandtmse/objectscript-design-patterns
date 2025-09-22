/// <html>
/// <h1>ImagingOrderCommand</h1>
/// <p>Command implementation for ordering imaging studies (X-ray, CT, MRI, etc.).</p>
/// <p>This command demonstrates the Command Pattern for radiology workflow,
/// including modality selection, contrast requirements, and urgency levels.</p>
/// </html>
Class Patterns.Examples.ImagingOrderCommand Extends Patterns.GoF.Behavioral.Command
{

/// Type of imaging study (X-ray, CT, MRI, Ultrasound, PET, etc.)
Property ImagingType As %String;

/// Body part or region to be imaged
Property BodyPart As %String;

/// Whether contrast is required
Property WithContrast As %Boolean;

/// Imaging protocol or specific views
Property Protocol As %String;

/// Clinical indication for the study
Property Indication As %String;

/// Create a new imaging order command
Method %OnNew(pReceiver As Patterns.GoF.Behavioral.Receiver, pParameters As %DynamicObject = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Call parent constructor
        Set tSC = ##super(pReceiver, pParameters)
        If $$$ISERR(tSC) {
            Set tSC = $$$ERROR($$$GeneralError, "Failed to initialize parent Command: "_$System.Status.GetErrorText(tSC))
            Quit
        }
        
        // Extract parameters if provided
        If $ISOBJECT(pParameters) {
            If pParameters.%IsDefined("imagingType") {
                Set ..ImagingType = pParameters.imagingType
            }
            If pParameters.%IsDefined("bodyPart") {
                Set ..BodyPart = pParameters.bodyPart
            }
            If pParameters.%IsDefined("withContrast") {
                Set ..WithContrast = pParameters.withContrast
            } Else {
                Set ..WithContrast = 0
            }
            If pParameters.%IsDefined("protocol") {
                Set ..Protocol = pParameters.protocol
            }
            If pParameters.%IsDefined("indication") {
                Set ..Indication = pParameters.indication
            }
        }
        
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Execute the imaging order command
Method Execute() As %Status
{
    Set tSC = $$$OK
    Try {
        // Validate receiver is a ClinicalOrder
        If '..Receiver.%IsA("Patterns.Examples.ClinicalOrder") {
            Set tSC = $$$ERROR($$$GeneralError, "Receiver must be a ClinicalOrder")
            Quit
        }
        
        // Cast to ClinicalOrder
        Set tOrder = ..Receiver
        
        // Validate imaging type
        If ..ImagingType = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Imaging type is required")
            Quit
        }
        
        // Validate body part
        If ..BodyPart = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Body part is required")
            Quit
        }
        
        // Store current state for undo
        Set ..PreviousState = tOrder.GetState()
        
        // Build order description
        Set tDescription = ..ImagingType_" of "_..BodyPart
        If ..WithContrast {
            Set tDescription = tDescription_" with contrast"
        }
        If ..Protocol '= "" {
            Set tDescription = tDescription_" ("_..Protocol_")"
        }
        
        // Set order properties
        Set tOrder.OrderType = "Imaging"
        Set tOrder.Description = tDescription
        Set tOrder.OrderDetails = ..GetImagingDetails()
        Set tOrder.Status = "Pending"
        
        // Set appropriate priority based on imaging type
        If ..ImagingType = "STAT CT" || (..ImagingType = "STAT MRI") {
            Set tOrder.Priority = "STAT"
        }
        ElseIf (tOrder.Priority = "") {
            Set tOrder.Priority = "Routine"
        }
        
        // Update timestamps
        Set tOrder.OrderedDate = $ZDATETIME($HOROLOG, 3)
        Set tOrder.OrderedBy = $USERNAME
        
        // Add to audit log
        Do tOrder.AddToAuditLog("Imaging order placed: "_tDescription_" - Indication: "_..Indication)
        
        // Validate imaging prerequisites
        Set tSC = ..ValidateImagingPrerequisites()
        If $$$ISERR(tSC) Quit
        
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Undo the imaging order
Method Undo() As %Status
{
    Set tSC = $$$OK
    Try {
        If ..PreviousState = "" {
            Set tSC = $$$ERROR($$$GeneralError, "No previous state to restore")
            Quit
        }
        
        // Restore previous state
        Set tSC = ..Receiver.RestoreState(..PreviousState)
        If $$$ISERR(tSC) Quit
        
        // Add to audit log
        Do ..Receiver.AddToAuditLog("Imaging order undone")
        
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get imaging study details as JSON
Method GetImagingDetails() As %String
{
    Set tDetails = {}
    Set tDetails."imagingType" = ..ImagingType
    Set tDetails."bodyPart" = ..BodyPart
    Set tDetails."withContrast" = ..WithContrast
    Set tDetails."protocol" = ..Protocol
    Set tDetails."indication" = ..Indication
    Set tDetails."modalityWorkList" = ..GetModalityWorkList()
    
    Quit tDetails.%ToJSON()
}

/// Get modality work list entry
Method GetModalityWorkList() As %String
{
    // Generate modality work list identifier
    Set tModality = $CASE($PIECE(..ImagingType, " ", 1),
        "X-ray":"XR",
        "CT":"CT",
        "MRI":"MR",
        "Ultrasound":"US",
        "PET":"PT",
        "Nuclear":"NM",
        "Fluoroscopy":"RF",
        :"OT")
    
    Set tWorkList = tModality_"-"_$TRANSLATE($ZDATETIME($HOROLOG, 8), ":")
    Quit tWorkList
}

/// Validate imaging prerequisites
Method ValidateImagingPrerequisites() As %Status [ Private ]
{
    Set tSC = $$$OK
    
    // Check for contrast contraindications
    If ..WithContrast {
        // Check renal function for contrast studies
        If ..ImagingType [ "CT" || (..ImagingType [ "MRI") {
            // In real system, would check recent creatinine/eGFR
            // For demo, we'll just log the check
            Do ..Receiver.AddToAuditLog("Contrast prerequisites checked - Renal function review required")
        }
        
        // Check for contrast allergies
        If ..ImagingType [ "CT" {
            // In real system, would check allergy history
            Do ..Receiver.AddToAuditLog("Contrast allergy screening performed")
        }
    }
    
    // Check for MRI contraindications
    If ..ImagingType [ "MRI" {
        // Check for metal implants, pacemakers, etc.
        Do ..Receiver.AddToAuditLog("MRI safety screening required - Check for metallic implants")
    }
    
    // Check pregnancy status for radiation exposure
    If (..ImagingType [ "CT") || (..ImagingType [ "X-ray") || (..ImagingType [ "PET") {
        Do ..Receiver.AddToAuditLog("Radiation safety check - Pregnancy screening may be required")
    }
    
    Quit tSC
}

/// Create a common chest X-ray order
ClassMethod CreateChestXRay(pReceiver As Patterns.Examples.ClinicalOrder, pIndication As %String = "Chest pain") As ImagingOrderCommand
{
    Set tParams = {}
    Set tParams.imagingType = "X-ray"
    Set tParams.bodyPart = "Chest PA/Lateral"
    Set tParams.withContrast = 0
    Set tParams.protocol = "2 views"
    Set tParams.indication = pIndication
    Quit ##class(ImagingOrderCommand).%New(pReceiver, tParams)
}

/// Create a CT scan with contrast
ClassMethod CreateCTWithContrast(pReceiver As Patterns.Examples.ClinicalOrder, pBodyPart As %String, pIndication As %String) As ImagingOrderCommand
{
    Set tParams = {}
    Set tParams.imagingType = "CT"
    Set tParams.bodyPart = pBodyPart
    Set tParams.withContrast = 1
    Set tParams.protocol = "With IV contrast"
    Set tParams.indication = pIndication
    Quit ##class(ImagingOrderCommand).%New(pReceiver, tParams)
}

/// Create a STAT head CT (common for stroke protocol)
ClassMethod CreateSTATHeadCT(pReceiver As Patterns.Examples.ClinicalOrder) As ImagingOrderCommand
{
    Set tParams = {}
    Set tParams.imagingType = "STAT CT"
    Set tParams.bodyPart = "Head"
    Set tParams.withContrast = 0
    Set tParams.protocol = "Non-contrast"
    Set tParams.indication = "Rule out acute intracranial process"
    Quit ##class(ImagingOrderCommand).%New(pReceiver, tParams)
}

/// Create an MRI study
ClassMethod CreateMRI(pReceiver As Patterns.Examples.ClinicalOrder, pBodyPart As %String, pWithContrast As %Boolean = 0, pIndication As %String = "") As ImagingOrderCommand
{
    Set tParams = {}
    Set tParams.imagingType = "MRI"
    Set tParams.bodyPart = pBodyPart
    Set tParams.withContrast = pWithContrast
    Set tParams.protocol = $SELECT(pWithContrast:"With gadolinium", 1:"Non-contrast")
    Set tParams.indication = pIndication
    Quit ##class(ImagingOrderCommand).%New(pReceiver, tParams)
}

/// Create an ultrasound study
ClassMethod CreateUltrasound(pReceiver As Patterns.Examples.ClinicalOrder, pBodyPart As %String, pIndication As %String = "") As ImagingOrderCommand
{
    Set tParams = {}
    Set tParams.imagingType = "Ultrasound"
    Set tParams.bodyPart = pBodyPart
    Set tParams.withContrast = 0
    Set tParams.protocol = "Standard protocol"
    Set tParams.indication = pIndication
    Quit ##class(ImagingOrderCommand).%New(pReceiver, tParams)
}

}
