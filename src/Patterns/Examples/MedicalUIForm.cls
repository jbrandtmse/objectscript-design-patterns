/// Abstract Medical UI Form Component
/// 
/// Base class for form components across different medical device platforms.
/// Each platform (Tablet, Desktop, Mobile) will have its own concrete implementation.
/// Forms can contain buttons and charts as child components.
/// 
/// @see Patterns.Examples.MedicalDeviceUIFactory
/// @since 1.0.0
Class Patterns.Examples.MedicalUIForm Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// Component type identifier
Parameter COMPONENTTYPE = "Form";

// ===== PROPERTIES =====

/// Form title
Property Title As %String;

/// Form identifier
Property FormID As %String;

/// Attached button component
Property AttachedButton As Patterns.Examples.MedicalUIButton;

/// Attached chart component
Property AttachedChart As Patterns.Examples.MedicalUIChart;

/// Form validation state
Property IsValid As %Boolean [ InitialExpression = 0 ];

// ===== PUBLIC METHODS =====

/// Gets the description of this form component
/// 
/// @return Component description string
Method GetDescription() As %String [ Abstract ]
{
    Quit ""
}

/// Renders the form on the device display
/// 
/// @return %Status indicating success or failure
Method Render() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Validates the form data
/// 
/// @return %Status indicating success or failure
Method Validate() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Submits the form data
/// 
/// @return %Status indicating success or failure
Method Submit() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Gets the platform this form is designed for
/// 
/// @return Platform name string
Method GetPlatform() As %String [ Abstract ]
{
    Quit ""
}

/// Attaches a button to the form
/// 
/// @param pButton Button component to attach
/// @return %Status indicating success or failure
Method AttachButton(pButton As Patterns.Examples.MedicalUIButton) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$IsObject(pButton) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid button object")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Check platform compatibility
        If (..GetPlatform() '= pButton.GetPlatform()) {
            Set tSC = $$$ERROR($$$GeneralError, "Button platform '"_pButton.GetPlatform()_"' incompatible with form platform '"_..GetPlatform()_"'")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Set ..AttachedButton = pButton
        Write !, "Button attached to form successfully"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Attaches a chart to the form
/// 
/// @param pChart Chart component to attach
/// @return %Status indicating success or failure
Method AttachChart(pChart As Patterns.Examples.MedicalUIChart) As %Status
{
    Set tSC = $$$OK
    Try {
        If '$IsObject(pChart) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid chart object")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        // Check platform compatibility
        If (..GetPlatform() '= pChart.GetPlatform()) {
            Set tSC = $$$ERROR($$$GeneralError, "Chart platform '"_pChart.GetPlatform()_"' incompatible with form platform '"_..GetPlatform()_"'")
            Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        
        Set ..AttachedChart = pChart
        Write !, "Chart attached to form successfully"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Sets the form title
/// 
/// @param pTitle New form title
/// @return %Status indicating success or failure
Method SetTitle(pTitle As %String) As %Status
{
    Set ..Title = pTitle
    Quit $$$OK
}

/// Sets the form ID
/// 
/// @param pFormID Form identifier
/// @return %Status indicating success or failure
Method SetFormID(pFormID As %String) As %Status
{
    Set ..FormID = pFormID
    Quit $$$OK
}

}
