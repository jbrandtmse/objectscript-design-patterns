/// Concrete chart implementation for desktop interfaces
/// Part of the Abstract Factory Pattern healthcare example
Class Patterns.Examples.DesktopChart Extends Patterns.Examples.MedicalUIChart
{

Parameter HIGHRESOLUTION = 1;

Parameter EXPORTFORMATS = "CSV,Excel,PDF,PNG,SVG";

Parameter ADVANCEDFILTERING = 1;

Parameter MULTIMONITOR = 1;

Parameter DRILLDOWN = 1;

// ===== PROPERTIES =====

/// Component ID
Property ID As %String;

/// Component style
Property Style As %String;

/// Data points collection
Property DataPoints As %Library.ListOfDataTypes;

/// X-axis label for the chart
Property XAxisLabel As %String;

/// Y-axis label for the chart
Property YAxisLabel As %String;

/// Zoom level for desktop viewing
Property ZoomLevel As %Integer [ InitialExpression = 100 ];

/// Whether grid lines are shown
Property ShowGrid As %Boolean [ InitialExpression = 1 ];

/// Selected export format
Property ExportFormat As %String [ InitialExpression = "PNG" ];

/// Constructor
Method %OnNew() As %Status
{
    Set tSC = $$$OK
    
    Set ..ID = "desktop-chart-" _ $Random(10000)
    Set ..Style = "background: #fff; "
                _ "border: 1px solid #ddd; "
                _ "box-shadow: 0 2px 4px rgba(0,0,0,0.1); "
                _ "border-radius: 4px; "
                _ "padding: 20px; "
                _ "margin: 10px; "
                _ "min-width: 600px; "
                _ "min-height: 400px;"
    
    Set ..DataPoints = ##class(%Library.ListOfDataTypes).%New()
    Set ..XAxisLabel = "X Axis"
    Set ..YAxisLabel = "Y Axis"
    
    Quit $$$OK
}

/// Get description of chart
Method GetDescription() As %String
{
    Quit "Desktop Chart: " _ ..Title _ " (" _ ..ChartType _ " chart on Desktop platform)"
}

/// Display the chart
Method Display() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write !, "Displaying desktop chart: ", ..Title
        Write !, "Chart type: ", ..ChartType
        Write !, "Data source: ", ..DataSource
        If ..RealTimeEnabled {
            Write !, "Real-time updates enabled (", ..RefreshInterval, " second intervals)"
        }
        Write !, "Zoom level: ", ..ZoomLevel, "%"
        If ..ShowGrid {
            Write !, "Grid lines: Enabled"
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Update chart data
Method UpdateData() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write !, "Updating data for desktop chart: ", ..Title
        Write !, "Fetching from data source: ", ..DataSource
        
        // Simulate data update with random values
        Do ..DataPoints.Clear()
        For i=1:1:10 {
            Do ..DataPoints.Insert($Random(100))
        }
        
        Write !, "Data updated with ", ..DataPoints.Count(), " data points"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Configure chart settings
Method Configure() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write !, "Configuring desktop chart with advanced settings"
        Write !, "High resolution: ", $Select(..#HIGHRESOLUTION:"Enabled",1:"Disabled")
        Write !, "Available export formats: ", ..#EXPORTFORMATS
        Write !, "Advanced filtering: ", $Select(..#ADVANCEDFILTERING:"Enabled",1:"Disabled")
        Write !, "Multi-monitor support: ", $Select(..#MULTIMONITOR:"Enabled",1:"Disabled")
        Write !, "Drill-down capability: ", $Select(..#DRILLDOWN:"Enabled",1:"Disabled")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get platform
Method GetPlatform() As %String
{
    Quit "Desktop"
}

/// Export chart data in various desktop formats
Method ExportData(pFormat As %String = "") As %Status
{
    Set tSC = $$$OK
    
    Try {
        If pFormat = "" {
            Set pFormat = ..ExportFormat
        }
        
        Set tExport = ""
        
        If pFormat = "CSV" {
            // Generate CSV export
            Set tExport = "Index,Value" _ $Char(13,10)
            For i=1:1:..DataPoints.Count() {
                Set tExport = tExport _ i _ "," _ ..DataPoints.GetAt(i) _ $Char(13,10)
            }
        }
        ElseIf pFormat = "Excel" {
            // Simulate Excel export
            Set tExport = "<?xml version=""1.0""?>" _ $Char(13,10)
            Set tExport = tExport _ "<Workbook>" _ $Char(13,10)
            Set tExport = tExport _ "  <Worksheet name=""Chart Data"">" _ $Char(13,10)
            For i=1:1:..DataPoints.Count() {
                Set tExport = tExport _ "    <Row>"
                Set tExport = tExport _ "<Cell>" _ i _ "</Cell>"
                Set tExport = tExport _ "<Cell>" _ ..DataPoints.GetAt(i) _ "</Cell>"
                Set tExport = tExport _ "</Row>" _ $Char(13,10)
            }
            Set tExport = tExport _ "  </Worksheet>" _ $Char(13,10)
            Set tExport = tExport _ "</Workbook>"
        }
        ElseIf pFormat = "PDF" {
            Set tExport = "%PDF-1.4 Chart Export: " _ ..Title
        }
        ElseIf pFormat = "PNG" {
            Set tExport = "PNG Image Export: " _ ..Title _ " (600dpi)"
        }
        ElseIf pFormat = "SVG" {
            Set tExport = "<svg><!-- Chart: " _ ..Title _ " --></svg>"
        }
        
        Write !, "Exporting chart as ", pFormat, " format"
        Write !, "Export data length: ", $Length(tExport), " bytes"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Render desktop chart with all controls
Method Render() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Write "<div id=""", ..ID, """ "
        Write "class=""desktop-chart"" "
        Write "style=""", ..Style, """ "
        Write "data-chart-type=""", ..ChartType, """>"
        
        // Chart header with title
        Write "<div class=""chart-header"">"
        Write "<h3>", ..Title, "</h3>"
        Write "</div>"
        
        // Desktop-specific toolbar
        Write "<div class=""chart-toolbar"">"
        
        // Zoom controls for desktop
        If ..#HIGHRESOLUTION {
            Write "<div class=""zoom-controls"">"
            Write "<button onclick=""zoomIn('", ..ID, "')"">🔍+</button>"
            Write "<button onclick=""zoomOut('", ..ID, "')"">🔍-</button>"
            Write "<button onclick=""resetZoom('", ..ID, "')"">Reset</button>"
            Write "<span>Zoom: ", ..ZoomLevel, "%</span>"
            Write "</div>"
        }
        
        // Export options dropdown
        Write "<div class=""export-controls"">"
        Write "<label>Export as: </label>"
        Write "<select onchange=""exportChart('", ..ID, "', this.value)"">"
        For i=1:1:$Length(..#EXPORTFORMATS,",") {
            Set tFormat = $Piece(..#EXPORTFORMATS,",",i)
            Write "<option value=""", tFormat, """"
            If tFormat = ..ExportFormat {
                Write " selected"
            }
            Write ">", tFormat, "</option>"
        }
        Write "</select>"
        Write "</div>"
        
        // Print button for desktop
        Write "<div class=""print-control"">"
        Write "<button onclick=""printChart('", ..ID, "')"">🖨 Print</button>"
        Write "</div>"
        
        // Grid toggle
        Write "<div class=""grid-control"">"
        Write "<button onclick=""toggleGrid('", ..ID, "')"">"
        Write $Select(..ShowGrid:"Hide Grid",1:"Show Grid")
        Write "</button>"
        Write "</div>"
        
        // Advanced filtering for desktop
        If ..#ADVANCEDFILTERING {
            Write "<div class=""filter-control"">"
            Write "<button onclick=""openFilterDialog('", ..ID, "')"">🔧 Filters</button>"
            Write "</div>"
        }
        
        Write "</div>" // End toolbar
        
        // Chart container with high-res support
        Write "<div class=""chart-container"" style=""position: relative;"">"
        
        If ..#HIGHRESOLUTION {
            // Use canvas for high-resolution rendering
            Write "<canvas id=""", ..ID, "_canvas"" "
            Write "width=""1200"" height=""800"" "
            Write "style=""width: 100%; height: 100%;"">"
            Write "</canvas>"
        }
        Else {
            // Use SVG for standard rendering
            Write "<svg id=""", ..ID, "_svg"" "
            Write "width=""100%"" height=""100%"">"
            Write "</svg>"
        }
        
        Write "</div>" // End chart container
        
        // Chart legend
        Write "<div class=""chart-legend"">"
        Write "<span>", ..XAxisLabel, " (X)</span> | "
        Write "<span>", ..YAxisLabel, " (Y)</span>"
        Write "</div>"
        
        // Status bar for desktop
        Write "<div class=""chart-status"">"
        If ..RealTimeEnabled {
            Write "🔴 Live (", ..RefreshInterval, "s) | "
        }
        Write "Data points: ", ..DataPoints.Count(), " | "
        Write "Last updated: ", $ZDateTime($Horolog,3)
        Write "</div>"
        
        Write "</div>", ! // End main chart div
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle zoom changes
Method SetZoom(pZoomLevel As %Integer) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If (pZoomLevel >= 25) && (pZoomLevel <= 400) {
            Set ..ZoomLevel = pZoomLevel
            Write !, "Zoom level set to ", pZoomLevel, "%"
        }
        Else {
            Set tSC = $$$ERROR($$$GeneralError, "Zoom level must be between 25% and 400%")
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Toggle grid display
Method ToggleGrid() As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..ShowGrid = '..ShowGrid
        Write !, "Grid lines ", $Select(..ShowGrid:"enabled",1:"disabled")
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Handle drill-down navigation
Method DrillDown(pDataPoint As %Integer) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If ..#DRILLDOWN {
            If (pDataPoint > 0) && (pDataPoint <= ..DataPoints.Count()) {
                Set tValue = ..DataPoints.GetAt(pDataPoint)
                Write !, "Drilling down into data point ", pDataPoint, " (value: ", tValue, ")"
                // Would open detailed view in real implementation
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

}
