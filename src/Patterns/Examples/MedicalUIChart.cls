/// Abstract Medical UI Chart Component
/// 
/// Base class for chart components across different medical device platforms.
/// Each platform (Tablet, Desktop, Mobile) will have its own concrete implementation.
/// Charts are used to display medical data visualizations.
/// 
/// @see Patterns.Examples.MedicalDeviceUIFactory
/// @since 1.0.0
Class Patterns.Examples.MedicalUIChart Extends %RegisteredObject [ Abstract ]
{

// ===== PARAMETERS =====

/// Component type identifier
Parameter COMPONENTTYPE = "Chart";

// ===== PROPERTIES =====

/// Chart title
Property Title As %String;

/// Chart type (e.g., "Line", "Bar", "Pie", "Vital Signs")
Property ChartType As %String;

/// Data source identifier
Property DataSource As %String;

/// Whether real-time updates are enabled
Property RealTimeEnabled As %Boolean [ InitialExpression = 0 ];

/// Refresh interval in seconds for real-time data
Property RefreshInterval As %Integer [ InitialExpression = 5 ];

// ===== PUBLIC METHODS =====

/// Gets the description of this chart component
/// 
/// @return Component description string
Method GetDescription() As %String [ Abstract ]
{
    Quit ""
}

/// Displays the chart on the device display
/// 
/// @return %Status indicating success or failure
Method Display() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Updates the chart with new data
/// 
/// @return %Status indicating success or failure
Method UpdateData() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Configures the chart appearance
/// 
/// @return %Status indicating success or failure
Method Configure() As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Gets the platform this chart is designed for
/// 
/// @return Platform name string
Method GetPlatform() As %String [ Abstract ]
{
    Quit ""
}

/// Renders the chart (alias for Display for consistency)
/// 
/// @return %Status indicating success or failure
Method Render() As %Status
{
    Quit ..Display()
}

/// Sets the chart title
/// 
/// @param pTitle New chart title
/// @return %Status indicating success or failure
Method SetTitle(pTitle As %String) As %Status
{
    Set ..Title = pTitle
    Quit $$$OK
}

/// Sets the chart type
/// 
/// @param pChartType Chart type identifier
/// @return %Status indicating success or failure
Method SetChartType(pChartType As %String) As %Status
{
    Set ..ChartType = pChartType
    Quit $$$OK
}

/// Sets the data source
/// 
/// @param pDataSource Data source identifier
/// @return %Status indicating success or failure
Method SetDataSource(pDataSource As %String) As %Status
{
    Set ..DataSource = pDataSource
    Quit $$$OK
}

/// Enables or disables real-time updates
/// 
/// @param pEnabled True to enable real-time updates
/// @param pInterval Optional refresh interval in seconds
/// @return %Status indicating success or failure
Method SetRealTime(pEnabled As %Boolean, pInterval As %Integer = 5) As %Status
{
    Set ..RealTimeEnabled = pEnabled
    If pEnabled {
        Set ..RefreshInterval = pInterval
    }
    Quit $$$OK
}

}
