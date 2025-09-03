/// Concrete button implementation for desktop interfaces
/// Part of the Abstract Factory Pattern healthcare example
Class Patterns.Examples.DesktopButton Extends Patterns.Examples.MedicalUIButton
{

Parameter MINWIDTH = "100px";

Parameter MINHEIGHT = "40px";

Parameter FONTSIZE = "14pt";

Parameter HOVEREFFECT = 1;

Parameter KEYBOARDNAVIGATION = 1;

Parameter TOOLTIPSUPPORT = 1;

Parameter RIGHTCLICKMENU = 1;

// ===== PROPERTIES =====

/// Component ID
Property ID As %String;

/// Component style
Property Style As %String;

/// Click handler
Property OnClick As %String;

/// Platform identifier for desktop button
Property Platform As %String [ InitialExpression = "Desktop", ReadOnly ];

/// Keyboard shortcuts support
Property Shortcuts As %String;

/// Tooltip text for hover help
Property Tooltip As %String;

/// Focus state for keyboard navigation
Property HasFocus As %Boolean [ InitialExpression = 0 ];

/// Constructor - no parameters needed
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Set ..ID = "desktop-button-" _ $Random(10000)
    Set ..Style = "background: linear-gradient(#f0f0f0, #e0e0e0); "
                _ "border: 1px solid #999; "
                _ "border-radius: 4px; "
                _ "box-shadow: 0 1px 2px rgba(0,0,0,0.1); "
                _ "font-family: 'Segoe UI', Arial, sans-serif; "
                _ "font-size: " _ ..#FONTSIZE _ "; "
                _ "min-width: " _ ..#MINWIDTH _ "; "
                _ "min-height: " _ ..#MINHEIGHT _ "; "
                _ "padding: 6px 12px; "
                _ "cursor: pointer; "
                _ "transition: all 0.2s;"
    
    Set ..OnClick = "handleDesktopButtonClick('" _ ..ID _ "')"
    Set ..Tooltip = "Click to execute action"
    Set ..Shortcuts = ""
    
    Quit $$$OK
}

/// Get description of button
Method GetDescription() As %String
{
    Quit "Desktop Button: " _ ..Label _ " (Platform: Desktop)"
}

/// Handle button click
Method HandleClick() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write !, "Desktop button '", ..Label, "' clicked with action: ", ..ActionID
        // Log the click event
        Set ^ClineDebug = $Get(^ClineDebug) _ "Desktop button """ _ ..Label _ """ clicked; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Render the desktop button with full desktop features
Method Render() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "<button id=""", ..ID, """ "
        Write "style=""", ..Style, """ "
        Write "onclick=""", ..OnClick, """ "
        
        // Add tooltip if available
        If ..Tooltip '= "" {
            Write "title=""", ..Tooltip, """ "
        }
        
        // Add keyboard shortcut if defined
        If ..Shortcuts '= "" {
            Write "data-shortcut=""", ..Shortcuts, """ "
        }
        
        // Add accessibility attributes for keyboard navigation
        If ..#KEYBOARDNAVIGATION {
            Write "tabindex=""0"" "
            Write "role=""button"" "
            Write "aria-label=""", ..Label, """ "
        }
        
        // Add right-click context menu support
        If ..#RIGHTCLICKMENU {
            Write "oncontextmenu=""handleDesktopContext(event, '", ..ID, "')"" "
        }
        
        Write ">"
        Write ..Label
        
        // Add keyboard shortcut display if defined
        If ..Shortcuts '= "" {
            Write " <span class=""shortcut"">(", ..Shortcuts, ")</span>"
        }
        
        Write "</button>", !
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get platform for compatibility checking
Method GetPlatform() As %String
{
    Quit "Desktop"
}

/// Check compatibility with other components
Method IsCompatibleWith(pComponent As %RegisteredObject) As %Boolean
{
    Set tResult = 0
    
    If '$IsObject(pComponent) {
        Quit tResult
    }
    
    Try {
        Set tPlatform = pComponent.GetPlatform()
        Set tResult = (tPlatform = "Desktop")
    }
    Catch ex {
        Set tResult = 0
    }
    
    Quit tResult
}

/// Handle keyboard shortcuts
Method HandleKeyboardShortcut(pKeyCombo As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pKeyCombo = ..Shortcuts {
            // Simulate button click when shortcut is pressed
            Set tSC = ..HandleClick()
            If $$$ISOK(tSC) {
                Set ^ClineDebug = $Get(^ClineDebug) _ "Desktop button """ _ ..Label _ """ activated via keyboard shortcut " _ pKeyCombo _ "; "
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle hover state for desktop
Method HandleHover(pIsHovering As %Boolean) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..#HOVEREFFECT {
            If pIsHovering {
                // Apply hover style
                Set ..Style = ..Style _ " background: linear-gradient(#f5f5f5, #e5e5e5); "
                              _ "border-color: #666; "
                              _ "box-shadow: 0 2px 4px rgba(0,0,0,0.15);"
            }
            Else {
                // Restore normal style
                Do ..%OnNew()  // Reset to default style
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle focus for keyboard navigation
Method HandleFocus(pHasFocus As %Boolean) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..#KEYBOARDNAVIGATION {
            Set ..HasFocus = pHasFocus
            If pHasFocus {
                // Apply focus style
                Set ..Style = ..Style _ " outline: 2px solid #0066cc; "
                              _ "outline-offset: 2px;"
            }
            Else {
                // Remove focus style
                Do ..%OnNew()  // Reset to default style
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Set tooltip text for better desktop UX
Method SetTooltip(pTooltip As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..Tooltip = pTooltip
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Set keyboard shortcut
Method SetShortcut(pShortcut As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..Shortcuts = pShortcut
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
