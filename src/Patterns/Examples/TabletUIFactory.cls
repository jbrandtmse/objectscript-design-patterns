/// Tablet UI Factory - Concrete Factory for Tablet Medical Devices
/// 
/// Creates UI components optimized for tablet touchscreen interfaces.
/// All components follow tablet design guidelines with larger touch targets
/// and gesture-based interactions.
/// 
/// @see Patterns.Examples.MedicalDeviceUIFactory
/// @since 1.0.0
Class Patterns.Examples.TabletUIFactory Extends Patterns.Examples.MedicalDeviceUIFactory
{

// ===== PARAMETERS =====

/// Platform identifier
Parameter PLATFORM = "Tablet";

/// Device specifications
Parameter SCREENSIZE = "10-12 inch";

Parameter INPUTMETHOD = "Touch";

Parameter ORIENTATION = "Portrait/Landscape";

// ===== PUBLIC METHODS =====

/// Creates a button component for tablet interface
/// 
/// @return TabletButton implementation
Method CreateButton() As Patterns.Examples.MedicalUIButton
{
    Quit ##class(Patterns.Examples.TabletButton).%New()
}

/// Creates a form component for tablet interface
/// 
/// @return TabletForm implementation
Method CreateForm() As Patterns.Examples.MedicalUIForm
{
    Quit ##class(Patterns.Examples.TabletForm).%New()
}

/// Creates a chart component for tablet interface
/// 
/// @return TabletChart implementation
Method CreateChart() As Patterns.Examples.MedicalUIChart
{
    Quit ##class(Patterns.Examples.TabletChart).%New()
}

/// Returns the platform name for this factory
/// 
/// @return Platform name string
Method GetPlatformName() As %String
{
    Quit ..#PLATFORM
}

}
