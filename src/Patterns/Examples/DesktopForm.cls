/// Concrete form implementation for desktop interfaces
/// Part of the Abstract Factory Pattern healthcare example
Class Patterns.Examples.DesktopForm Extends Patterns.Examples.MedicalUIForm
{

Parameter MINWIDTH = "600px";

Parameter MINHEIGHT = "400px";

Parameter RESIZABLE = 1;

Parameter DRAGGABLE = 1;

Parameter MULTITAB = 1;

Parameter KEYBOARDNAVIGATION = 1;

Parameter AUTOSAVE = 1;

/// Unique identifier for this form instance
Property ID As %String;

/// CSS styling for the form
Property Style As %String;

/// List of form fields
Property Fields As list Of %String;

/// Platform identifier for desktop form
Property Platform As %String [ InitialExpression = "Desktop", ReadOnly ];

/// Tab navigation support for desktop forms
Property Tabs As list Of %String;

/// Current active tab
Property ActiveTab As %Integer [ InitialExpression = 1 ];

/// Window state (normal, minimized, maximized)
Property WindowState As %String [ InitialExpression = "normal" ];

/// Auto-save timer ID
Property AutoSaveTimer As %String;

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    // Initialize ID
    Set ..ID = "desktop-form-" _ $Random(10000)
    
    // Initialize style
    Set ..Style = "background: #fff; "
                _ "border: 1px solid #ccc; "
                _ "border-radius: 8px; "
                _ "box-shadow: 0 4px 6px rgba(0,0,0,0.1); "
                _ "font-family: 'Segoe UI', Arial, sans-serif; "
                _ "min-width: " _ ..#MINWIDTH _ "; "
                _ "min-height: " _ ..#MINHEIGHT _ "; "
                _ "padding: 20px; "
                _ "position: relative;"
    
    // Initialize fields list
    Do ..Fields.Clear()
    Do ..Fields.Insert("PatientID")
    Do ..Fields.Insert("Name")
    Do ..Fields.Insert("DateOfBirth")
    Do ..Fields.Insert("Diagnosis")
    Do ..Fields.Insert("Notes")
    
    // Initialize tabs list
    Do ..Tabs.Clear()
    Do ..Tabs.Insert("General")
    Do ..Tabs.Insert("Details")
    Do ..Tabs.Insert("Advanced")
    
    Quit $$$OK
}

/// Render the desktop form with full features
Method Render() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "<div id=""", ..ID, """ "
        Write "class=""desktop-form"" "
        Write "style=""", ..Style, """ "
        
        // Add resizable and draggable attributes
        If ..#RESIZABLE {
            Write "data-resizable=""true"" "
        }
        If ..#DRAGGABLE {
            Write "data-draggable=""true"" "
        }
        
        Write ">"
        
        // Add window controls (minimize, maximize, close)
        Write "<div class=""window-controls"">"
        Write "<button onclick=""minimizeForm('", ..ID, "')"">_</button>"
        Write "<button onclick=""maximizeForm('", ..ID, "')"">□</button>"
        Write "<button onclick=""closeForm('", ..ID, "')"">×</button>"
        Write "</div>"
        
        // Add form title
        Write "<h2>", ..Title, "</h2>"
        
        // Add tab navigation if multi-tab is enabled
        If ..#MULTITAB && (..Tabs.Count() > 0) {
            Write "<div class=""tabs"">"
            For i=1:1:..Tabs.Count() {
                Set tTabClass = $Select(i=..ActiveTab:"active", 1:"")
                Write "<button class=""tab ", tTabClass, """ "
                Write "onclick=""switchTab('", ..ID, "', ", i, ")"">"
                Write ..Tabs.GetAt(i), "</button>"
            }
            Write "</div>"
        }
        
        // Add form fields with proper desktop layout
        Write "<div class=""form-content"">"
        For i=1:1:..Fields.Count() {
            Set tField = ..Fields.GetAt(i)
            Write "<div class=""form-group"">"
            Write "<label for=""", tField, """>", tField, ":</label>"
            Write "<input type=""text"" id=""", tField, """ "
            Write "name=""", tField, """ "
            Write "class=""form-control"" "
            
            // Add keyboard navigation support
            If ..#KEYBOARDNAVIGATION {
                Write "tabindex=""", i, """ "
            }
            
            Write "/></div>"
        }
        
        // Add attached components
        If $IsObject(..AttachedButton) {
            Write "<div class=""form-actions"">"
            Set tSC = ..AttachedButton.Render()
            If $$$ISERR(tSC) Quit
            Write "</div>"
        }
        
        If $IsObject(..AttachedChart) {
            Write "<div class=""form-chart"">"
            Set tSC = ..AttachedChart.Render()
            If $$$ISERR(tSC) Quit
            Write "</div>"
        }
        
        Write "</div></div>"
        
        // Add auto-save indicator
        If ..#AUTOSAVE {
            Write "<div class=""autosave-indicator"">Auto-save enabled</div>"
        }
        
        Write !
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

/// Validate form with desktop-specific validation
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Basic form validation
        If ..Title = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Form title is required")
            Quit
        }
        
        If ..FormID = "" {
            Set tSC = $$$ERROR($$$GeneralError, "Form ID is required")
            Quit
        }
        
        // Check for keyboard shortcuts conflicts
        If ..#KEYBOARDNAVIGATION {
            // Desktop forms can have more complex validation
            If '..ValidateKeyboardShortcuts() {
                Set tSC = $$$ERROR($$$GeneralError, "Keyboard shortcut validation failed")
                Quit
            }
        }
        
        // If all validation passes, mark form as valid
        If $$$ISOK(tSC) {
            Set ..IsValid = 1
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Validate keyboard shortcuts don't conflict
Method ValidateKeyboardShortcuts() As %Boolean [ Private ]
{
    // Check for shortcut conflicts in attached components
    Set tIsValid = 1
    
    If $IsObject(..AttachedButton) {
        Try {
            // Check if button shortcuts are unique
            Set tShortcut = ..AttachedButton.Shortcuts
            If tShortcut '= "" {
                // Validation logic for shortcuts
                Set tIsValid = 1  // Simplified for now
            }
        }
        Catch ex {
            Set tIsValid = 0
        }
    }
    
    Quit tIsValid
}

/// Switch to a different tab
Method SwitchTab(pTabIndex As %Integer) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..#MULTITAB {
            If (pTabIndex > 0) && (pTabIndex <= ..Tabs.Count()) {
                Set ..ActiveTab = pTabIndex
                Set ^ClineDebug = ^ClineDebug _ "Switched to tab " _ ..Tabs.GetAt(pTabIndex) _ "; "
            }
            Else {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid tab index: " _ pTabIndex)
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle window state changes (minimize, maximize, restore)
Method SetWindowState(pState As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If $ListFind($ListBuild("normal", "minimized", "maximized"), pState) {
            Set ..WindowState = pState
            Set ^ClineDebug = ^ClineDebug _ "Window state changed to " _ pState _ "; "
        }
        Else {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid window state: " _ pState)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Enable auto-save functionality
Method EnableAutoSave(pInterval As %Integer = 60) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..#AUTOSAVE {
            // Set up auto-save timer (interval in seconds)
            Set ..AutoSaveTimer = "autosave_" _ ..ID _ "_" _ pInterval
            Set ^ClineDebug = ^ClineDebug _ "Auto-save enabled with " _ pInterval _ " second interval; "
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Save form data
Method Save() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Desktop forms support more sophisticated save operations
        Set ^ClineDebug = ^ClineDebug _ "Saving desktop form " _ ..Title _ "; "
        
        // Validate before saving
        Set validStatus = ..Validate()
        If $$$ISERR(validStatus) {
            Set tSC = $$$ERROR($$$GeneralError, "Form validation failed")
            Quit
        }
        
        // Simulate save operation
        For i=1:1:..Fields.Count() {
            Set tField = ..Fields.GetAt(i)
            Set ^ClineDebug = ^ClineDebug _ "Saved field " _ tField _ "; "
        }
        
        // Show save confirmation (desktop-specific)
        Set ^ClineDebug = ^ClineDebug _ "Form saved successfully with timestamp " _ $ZDateTime($Horolog, 3) _ "; "
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Export form data in various desktop formats
Method Export(pFormat As %String = "JSON") As %String
{
    Set tExport = ""
    
    Try {
        If pFormat = "JSON" {
            Set tExport = "{"
            Set tExport = tExport _ """form"":""" _ ..Title _ ""","
            Set tExport = tExport _ """platform"":""Desktop"","
            Set tExport = tExport _ """fields"":["
            
            For i=1:1:..Fields.Count() {
                If i > 1 Set tExport = tExport _ ","
                Set tExport = tExport _ """" _ ..Fields.GetAt(i) _ """"
            }
            
            Set tExport = tExport _ "],"
            Set tExport = tExport _ """windowState"":""" _ ..WindowState _ ""","
            Set tExport = tExport _ """activeTab"":" _ ..ActiveTab
            Set tExport = tExport _ "}"
        }
        ElseIf pFormat = "XML" {
            Set tExport = "<form platform=""Desktop"" title=""" _ ..Title _ """>"
            For i=1:1:..Fields.Count() {
                Set tExport = tExport _ "<field>" _ ..Fields.GetAt(i) _ "</field>"
            }
            Set tExport = tExport _ "</form>"
        }
    }
    Catch ex {
        Set tExport = ""
    }
    
    Quit tExport
}

}
