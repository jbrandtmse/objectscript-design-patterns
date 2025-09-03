/// Concrete factory for creating desktop medical UI components
/// Implements the Abstract Factory pattern for desktop platform
Class Patterns.Examples.DesktopUIFactory Extends Patterns.Examples.MedicalDeviceUIFactory
{

/// Platform identifier for desktop devices
Parameter PLATFORM = "Desktop";

Parameter DESCRIPTION = "High-resolution desktop medical interface factory";

Parameter SCREENSIZE = "1920x1080+";

Parameter INPUTMETHOD = "Mouse and Keyboard";

/// Create a desktop-specific button
Method CreateButton() As Patterns.Examples.MedicalUIButton
{
    Set button = ##class(Patterns.Examples.DesktopButton).%New()
    Quit button
}

/// Create a desktop-specific form
Method CreateForm() As Patterns.Examples.MedicalUIForm
{
    Set form = ##class(Patterns.Examples.DesktopForm).%New()
    Quit form
}

/// Create a desktop-specific chart
Method CreateChart() As Patterns.Examples.MedicalUIChart
{
    Set chart = ##class(Patterns.Examples.DesktopChart).%New()
    Quit chart
}

/// Demonstrate desktop UI component family working together
Method DemonstrateUIFamily() As %Status
{
    Set tSC = $$$OK
    Try {
        Write !, "=== Desktop Medical UI Factory Demonstration ==="
        Write !, "Platform: ", ..#PLATFORM
        Write !, "Screen Size: ", ..#SCREENSIZE
        Write !, "Input Method: ", ..#INPUTMETHOD
        Write !, ""
        
        // Create desktop UI components
        Set button = ..CreateButton()
        Set form = ..CreateForm()
        Set chart = ..CreateChart()
        
        // Configure components
        Set button.Label = "Desktop Submit"
        Set button.ActionID = "desktop_submit"
        Set button.Enabled = 1
        
        Set form.FormID = "desktop_patient_form"
        Set form.Title = "Desktop Patient Registration"
        
        Set chart.ChartType = "Area"
        Set chart.Title = "Desktop Vital Signs Monitor"
        
        // Demonstrate rendering
        Write !, "1. Rendering Desktop Components:"
        Do button.Render()
        Write !
        Do form.Render()
        Write !
        Do chart.Render()
        Write !
        
        // Demonstrate interactions
        Write !, "2. Testing Component Interactions:"
        Do form.AttachButton(button)
        Do form.AttachChart(chart)
        Write !
        
        // Test high-resolution features
        Write !, "3. Desktop-Specific Features:"
        Write !, "  - Multi-window support enabled"
        Write !, "  - Keyboard shortcuts configured"
        Write !, "  - High-DPI display optimization active"
        Write !, "  - Advanced data visualization available"
        Write !
        
        Write !, "Desktop UI family demonstration completed successfully"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "Error in desktop demonstration: ", $System.Status.GetErrorText(tSC)
    }
    Quit tSC
}

/// Get platform-specific capabilities
Method GetCapabilities() As %String
{
    Quit "Multi-window, Keyboard shortcuts, High-resolution, Advanced visualizations"
}

}
