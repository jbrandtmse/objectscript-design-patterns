/// Abstract Medical UI Button Component
/// 
/// Base class for button components across different medical device platforms.
/// Each platform (Tablet, Desktop, Mobile) will have its own concrete implementation.
/// 
/// @see Patterns.Examples.MedicalDeviceUIFactory
/// @since 1.0.0
Class Patterns.Examples.MedicalUIButton Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// Component type identifier
Parameter COMPONENTTYPE = "Button";

// ===== PROPERTIES =====

/// Button label text
Property Label As %String;

/// Button action identifier
Property ActionID As %String;

/// Whether the button is enabled
Property Enabled As %Boolean [ InitialExpression = 1 ];

// ===== PUBLIC METHODS =====

/// Gets the description of this button component
/// 
/// @return Component description string
Method GetDescription() As %String [ Abstract ]
{
    Quit ""
}

/// Renders the button on the device display
/// 
/// @return %Status indicating success or failure
Method Render() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Handles button click event
/// 
/// @return %Status indicating success or failure
Method HandleClick() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Gets the platform this button is designed for
/// 
/// @return Platform name string
Method GetPlatform() As %String [ Abstract ]
{
    Quit ""
}

/// Sets the button label
/// 
/// @param pLabel New label text
/// @return %Status indicating success or failure
Method SetLabel(pLabel As %String) As %Status
{
    Set ..Label = pLabel
    Quit $$$OK
}

/// Sets the button action
/// 
/// @param pActionID Action identifier
/// @return %Status indicating success or failure
Method SetAction(pActionID As %String) As %Status
{
    Set ..ActionID = pActionID
    Quit $$$OK
}

/// Enables or disables the button
/// 
/// @param pEnabled True to enable, False to disable
/// @return %Status indicating success or failure
Method SetEnabled(pEnabled As %Boolean) As %Status
{
    Set ..Enabled = pEnabled
    Quit $$$OK
}

}
