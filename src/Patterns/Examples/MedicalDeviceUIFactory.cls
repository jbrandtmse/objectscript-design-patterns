/// Abstract Factory for Medical Device UI Components
/// 
/// This factory defines interfaces for creating families of related UI components
/// for different medical device platforms (Tablet, Desktop, Mobile)
/// 
/// @see Patterns.Examples.TabletUIFactory
/// @see Patterns.Examples.DesktopUIFactory
/// @see Patterns.Examples.MobileUIFactory
/// @since 1.0.0
Class Patterns.Examples.MedicalDeviceUIFactory Extends %RegisteredObject [ Abstract ]
{

// ===== PUBLIC METHODS =====

/// Creates a button component appropriate for the device platform
/// 
/// @return MedicalUIButton implementation for the platform
Method CreateButton() As Patterns.Examples.MedicalUIButton [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Creates a form component appropriate for the device platform
/// 
/// @return MedicalUIForm implementation for the platform
Method CreateForm() As Patterns.Examples.MedicalUIForm [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Creates a chart component for displaying medical data
/// 
/// @return MedicalUIChart implementation for the platform
Method CreateChart() As Patterns.Examples.MedicalUIChart [ Abstract ]
{
    Quit $$$NULLOREF
}

/// Returns the name of the platform this factory creates components for
/// 
/// @return Platform name string
Method GetPlatformName() As %String [ Abstract ]
{
    Quit ""
}

/// Demonstrates creating a complete UI suite for the platform
/// 
/// @return %Status indicating success or failure
Method CreateUIDemo() As %Status
{
    Set tSC = $$$OK
    Try {
        Write !, "Creating UI components for medical device platform..."
        
        // Create button component
        Set tButton = ..CreateButton()
        Write !, "Button: ", tButton.GetDescription()
        Set tSC = tButton.Render()
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        // Create form component
        Set tForm = ..CreateForm()
        Write !, "Form: ", tForm.GetDescription()
        Set tSC = tForm.Render()
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        // Create chart component
        Set tChart = ..CreateChart()
        Write !, "Chart: ", tChart.GetDescription()
        Set tSC = tChart.Display()
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        // Demonstrate interaction between components
        Write !, "Testing component interactions..."
        Set tSC = tForm.AttachButton(tButton)
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        Set tSC = tForm.AttachChart(tChart)
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
        
        Write !, "UI suite created successfully for platform: ", ..GetPlatformName()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
        Write !, "Error creating UI demo: ", $System.Status.GetErrorText(tSC)
    }
    Quit tSC
}

}
