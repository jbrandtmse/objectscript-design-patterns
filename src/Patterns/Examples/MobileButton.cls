/// Mobile button implementation for medical UI
/// Optimized for touch interaction with haptic feedback and gesture support
Class Patterns.Examples.MobileButton Extends Patterns.Examples.MedicalUIButton
{

/// Platform identifier
Parameter PLATFORM = "Mobile";

/// Mobile button specifications
Parameter MINWIDTH = "48px";

Parameter MINHEIGHT = "48px";

Parameter TOUCHAREA = "Minimum 48x48px";

Parameter HAPTICFEEDBACK = 1;

/// Get the button description
Method GetDescription() As %String
{
    Quit "Mobile Touch Button with haptic feedback and gesture support"
}

/// Get the platform type
Method GetPlatform() As %String
{
    Quit ..#PLATFORM
}

/// Render the mobile button
Method Render() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "Mobile Button Rendered:", !
        Write "  - Touch-optimized size: " _ ..#TOUCHAREA, !
        Write "  - Haptic feedback: " _ $Select(..#HAPTICFEEDBACK:"Enabled", 1:"Disabled"), !
        Write "  - Gesture support: Tap, Long Press, Swipe", !
        Write "  - Accessibility: Large touch target, voice control", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle tap gesture
Method OnTap() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "Button tapped - triggering haptic feedback", !
        Set tSC = ..TriggerHapticFeedback()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle long press gesture
Method OnLongPress() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "Button long-pressed - showing context menu", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Trigger haptic feedback
Method TriggerHapticFeedback() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "Haptic feedback triggered (vibration pattern: 10ms)", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Enable offline mode for button
Method EnableOfflineMode() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "Button offline mode enabled - actions queued for sync", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
