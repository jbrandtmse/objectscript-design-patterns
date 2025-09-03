/// Concrete factory for mobile platform medical UI components
/// This factory creates UI components optimized for mobile medical devices
/// with touch interfaces and responsive layouts
Class Patterns.Examples.MobileUIFactory Extends Patterns.Examples.MedicalDeviceUIFactory
{

/// Platform identifier for this factory
Parameter PLATFORM = "Mobile";

/// Device characteristics for mobile platform
Parameter TOUCHENABLED = 1;

Parameter LANDSCAPESUPPORT = 1;

Parameter PORTRAITSUPPORT = 1;

Parameter GESTURES = "Tap,Swipe,Pinch,Rotate";

/// Create a mobile-optimized button
Method CreateButton() As Patterns.Examples.MedicalUIButton
{
    Quit ##class(Patterns.Examples.MobileButton).%New()
}

/// Create a mobile-optimized form
Method CreateForm() As Patterns.Examples.MedicalUIForm
{
    Quit ##class(Patterns.Examples.MobileForm).%New()
}

/// Create a mobile-optimized chart
Method CreateChart() As Patterns.Examples.MedicalUIChart
{
    Quit ##class(Patterns.Examples.MobileChart).%New()
}

/// Get the platform description
Method GetPlatform() As %String
{
    Quit ..#PLATFORM
}

/// Get mobile-specific capabilities
Method GetCapabilities() As %String
{
    Set capabilities = "Touch Interface"
    Set capabilities = capabilities _ ", Portrait/Landscape Support"
    Set capabilities = capabilities _ ", Gesture Controls (" _ ..#GESTURES _ ")"
    Set capabilities = capabilities _ ", Responsive Layout"
    Set capabilities = capabilities _ ", Offline Mode"
    Set capabilities = capabilities _ ", Push Notifications"
    
    Quit capabilities
}

/// Validate components are mobile-optimized
Method ValidateComponents(pButton As Patterns.Examples.MedicalUIButton, pForm As Patterns.Examples.MedicalUIForm, pChart As Patterns.Examples.MedicalUIChart) As %Boolean
{
    // Ensure all components are mobile-optimized
    If (pButton.GetPlatform() '= ..#PLATFORM) {
        Quit 0
    }
    If (pForm.GetPlatform() '= ..#PLATFORM) {
        Quit 0
    }
    If (pChart.GetPlatform() '= ..#PLATFORM) {
        Quit 0
    }
    
    Quit 1
}

/// Demonstrate mobile UI component creation
Method DemonstrateMobileUI() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "Mobile Medical UI Factory Demonstration", !
        Write "========================================", !
        
        // Create mobile components
        Set button = ..CreateButton()
        Set form = ..CreateForm()
        Set chart = ..CreateChart()
        
        Write "Created Mobile UI Components:", !
        Write "- Button: " _ button.GetDescription(), !
        Write "- Form: " _ form.GetDescription(), !  
        Write "- Chart: " _ chart.GetDescription(), !
        
        Write !, "Mobile Capabilities:", !
        Write ..GetCapabilities(), !
        
        Write !, "Component Validation:", !
        If ..ValidateComponents(button, form, chart) {
            Write "✓ All components are mobile-optimized", !
        } Else {
            Write "✗ Component platform mismatch detected", !
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
