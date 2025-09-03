/// Tablet Button Component - Concrete Implementation
/// 
/// Button component optimized for tablet touchscreen interfaces with
/// larger touch targets and visual feedback for medical device usage.
/// 
/// @see Patterns.Examples.MedicalUIButton
/// @see Patterns.Examples.TabletUIFactory
/// @since 1.0.0
Class Patterns.Examples.TabletButton Extends Patterns.Examples.MedicalUIButton
{

// ===== PARAMETERS =====

/// Platform this component is designed for
Parameter PLATFORM = "Tablet";

/// Button design specifications
Parameter MINWIDTH = "120px";

Parameter MINHEIGHT = "60px";

Parameter FONTSIZE = "18pt";

Parameter TOUCHMARGIN = "10px";

// ===== PUBLIC METHODS =====

/// Gets the description of this tablet button
/// 
/// @return Component description string
Method GetDescription() As %String
{
    Quit "Tablet Button - Large touch-optimized button with " _ ..#MINWIDTH _ " x " _ ..#MINHEIGHT _ " minimum size"
}

/// Renders the button on the tablet display
/// 
/// @return %Status indicating success or failure
Method Render() As %Status
{
    Set tSC = $$$OK
    Try {
        Write !, "Rendering Tablet Button: '", ..Label, "'"
        Write !, "  - Touch target size: ", ..#MINWIDTH, " x ", ..#MINHEIGHT
        Write !, "  - Font size: ", ..#FONTSIZE
        Write !, "  - Touch margin: ", ..#TOUCHMARGIN
        Write !, "  - Action: ", ..ActionID
        Write !, "  - Enabled: ", $Select(..Enabled:"Yes", 1:"No")
        Write !, "  - Visual feedback: Ripple effect on touch"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Handles button touch event (tablet-specific)
/// 
/// @return %Status indicating success or failure
Method HandleClick() As %Status
{
    Set tSC = $$$OK
    Try {
        If '..Enabled {
            Write !, "Button is disabled - touch ignored"
            Quit
        }
        
        Write !, "Tablet button touched with haptic feedback"
        Write !, "Executing action: ", ..ActionID
        
        // Simulate tablet-specific touch handling
        Write !, "  - Touch coordinates captured"
        Write !, "  - Gesture type: Tap"
        Write !, "  - Visual feedback: Button pressed animation"
        Write !, "  - Haptic feedback: Light vibration"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Gets the platform this button is designed for
/// 
/// @return Platform name string
Method GetPlatform() As %String
{
    Quit ..#PLATFORM
}

}
