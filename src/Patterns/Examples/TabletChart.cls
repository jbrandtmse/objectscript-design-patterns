/// Concrete implementation of a medical chart component for tablet devices
/// Optimized for touch interaction and responsive display
Class Patterns.Examples.TabletChart Extends Patterns.Examples.MedicalUIChart
{

/// Tablet-specific chart configuration parameters
Parameter MINWIDTH = "400px";

Parameter MINHEIGHT = "300px";

Parameter TOUCHSENSITIVITY = "High";

Parameter GESTURESUPPORT = 1;

Parameter DEFAULTCHARTTYPE = "Line";

Parameter DEFAULTREFRESHRATE = 5000;

Parameter MAXDATAPOINTS = 100;

Parameter ANIMATIONENABLED = 1;

/// X-axis label for the chart
Property XAxisLabel As %String;

/// Y-axis label for the chart
Property YAxisLabel As %String;

/// Initialize tablet-specific chart settings
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    Try {
        // Set default chart properties for tablet
        Set ..ChartType = ..#DEFAULTCHARTTYPE
        Set ..DataSource = ""
        Set ..RealTimeEnabled = 0
        Set ..RefreshInterval = ..#DEFAULTREFRESHRATE
        Set ..Title = "Tablet Medical Chart"
        Set ..XAxisLabel = "Time"
        Set ..YAxisLabel = "Value"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get platform-specific description
Method GetDescription() As %String
{
    Quit "Tablet Chart - " _ ..ChartType _ " (Touch-optimized, " _ ..#MINWIDTH _ " x " _ ..#MINHEIGHT _ ")"
}

/// Render the chart with tablet-specific optimizations
Method Render() As %Status
{
    Set tSC = $$$OK
    Try {
        Write !, "=== Rendering Tablet Chart ==="
        Write !, "Type: ", ..ChartType
        Write !, "Title: ", ..Title
        Write !, "Dimensions: ", ..#MINWIDTH, " x ", ..#MINHEIGHT
        Write !, "Touch Sensitivity: ", ..#TOUCHSENSITIVITY
        
        If ..#GESTURESUPPORT {
            Write !, "Gesture Support: Enabled (Pinch to zoom, swipe to scroll)"
        }
        
        If ..#ANIMATIONENABLED {
            Write !, "Animations: Enabled (Smooth transitions)"
        }
        
        Write !, "Axes: X=", ..XAxisLabel, ", Y=", ..YAxisLabel
        
        If ..RealTimeEnabled {
            Write !, "Real-time Updates: Every ", ..RefreshInterval, "ms"
            Write !, "Max Data Points: ", ..#MAXDATAPOINTS
        } Else {
            Write !, "Real-time Updates: Disabled"
        }
        
        Write !, "Data Source: ", $Select(..DataSource'="":..DataSource, 1:"Not configured")
        Write !, "==========================="
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Update chart data with tablet-specific handling
Method UpdateData(pData As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Write !, "Updating tablet chart data..."
        Write !, "  - Processing touch-friendly data visualization"
        Write !, "  - Optimizing for tablet screen resolution"
        
        If ..#ANIMATIONENABLED {
            Write !, "  - Applying smooth animation transition"
        }
        
        // Check data point limit for performance
        Write !, "  - Ensuring data points within limit (", ..#MAXDATAPOINTS, ")"
        
        Write !, "Chart data updated successfully"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Configure real-time updates with tablet optimization
Method ConfigureRealTime(pEnabled As %Boolean, pInterval As %Integer = 5000) As %Status
{
    Set tSC = $$$OK
    Try {
        Set ..RealTimeEnabled = pEnabled
        
        // Ensure interval is appropriate for tablet performance
        If pInterval < 1000 {
            Write !, "Warning: Interval too low for tablet, setting to 1000ms"
            Set ..RefreshInterval = 1000
        } ElseIf pInterval > 30000 {
            Write !, "Warning: Interval very high, consider lower value for better UX"
            Set ..RefreshInterval = pInterval
        } Else {
            Set ..RefreshInterval = pInterval
        }
        
        If pEnabled {
            Write !, "Real-time updates enabled for tablet chart"
            Write !, "  - Refresh interval: ", ..RefreshInterval, "ms"
            Write !, "  - Touch interactions will pause updates temporarily"
        } Else {
            Write !, "Real-time updates disabled for tablet chart"
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Handle touch interactions specific to tablet charts
Method HandleTouch(pGesture As %String, pX As %Float, pY As %Float) As %Status
{
    Set tSC = $$$OK
    Try {
        Write !, "Handling tablet touch gesture: ", pGesture
        Write !, "  - Coordinates: (", pX, ", ", pY, ")"
        
        If pGesture = "pinch" {
            Write !, "  - Zooming chart..."
        } ElseIf pGesture = "swipe" {
            Write !, "  - Scrolling through data..."
        } ElseIf pGesture = "tap" {
            Write !, "  - Showing data point details..."
        } ElseIf pGesture = "longtap" {
            Write !, "  - Opening chart options menu..."
        }
        
        // Pause real-time updates during interaction
        If ..RealTimeEnabled {
            Write !, "  - Pausing real-time updates during interaction"
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Export chart data in tablet-friendly format
Method Export(pFormat As %String = "PNG") As %Status
{
    Set tSC = $$$OK
    Try {
        Write !, "Exporting tablet chart..."
        Write !, "  - Format: ", pFormat
        Write !, "  - Resolution optimized for tablet display"
        Write !, "  - Including touch-friendly annotations"
        Write !, "Chart exported successfully"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Get the platform identifier
Method GetPlatform() As %String
{
    Quit "Tablet"
}

}
