/// Gang of Four Visitor Pattern - Concrete Visitor Implementation
/// 
/// This concrete visitor demonstrates the Visitor pattern by implementing
/// specific operations for each element type. It shows how new operations
/// can be added without modifying the element classes.
/// 
/// <example>
/// Set visitor = ##class(Patterns.GoF.Behavioral.ConcreteVisitor).%New()
/// Set elementA = ##class(Patterns.GoF.Behavioral.ConcreteElementA).%New()
/// Do elementA.Accept(visitor)
/// Write visitor.GetResult()
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Visitor
/// @see Patterns.GoF.Behavioral.Element
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ConcreteVisitor Extends Patterns.GoF.Behavioral.Visitor
{

/// Property to accumulate results from visits
Property Results As %String [ Private ];

/// Property to track visit count
Property VisitCount As %Integer [ Private ];

/// Constructor - initialize properties
Method %OnNew(initvalue As %String = "") As %Status
{
    Set ..Results = ""
    Set ..VisitCount = 0
    Quit $$$OK
}

/// Visit ConcreteElementA - performs specific operation for this element type
/// 
/// @param pElement The ConcreteElementA being visited
/// @return %Status indicating success or failure
Method VisitConcreteElementA(pElement As Patterns.GoF.Behavioral.Element) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..VisitCount = ..VisitCount + 1
        
        // Perform operation specific to ConcreteElementA
        Set tData = pElement.GetData()
        Set tInfo = pElement.GetElementInfo()
        Set tOperation = "Processing ElementA: "_tData_" | "_tInfo
        
        // Accumulate result
        If ..Results '= "" Set ..Results = ..Results_"; "
        Set ..Results = ..Results_tOperation
        
        // Log: ConcreteVisitor visited ElementA: "_tData
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Visit ConcreteElementB - performs specific operation for this element type
/// 
/// @param pElement The ConcreteElementB being visited  
/// @return %Status indicating success or failure
Method VisitConcreteElementB(pElement As Patterns.GoF.Behavioral.Element) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..VisitCount = ..VisitCount + 1
        
        // Perform operation specific to ConcreteElementB
        Set tValue = pElement.GetValue()
        Set tStatus = pElement.GetStatus()
        Set tCalc = pElement.Calculate()
        Set tOperation = "Processing ElementB: Value="_tValue_", Status="_tStatus_", Calculated="_tCalc
        
        // Accumulate result
        If ..Results '= "" Set ..Results = ..Results_"; "
        Set ..Results = ..Results_tOperation
        
        // Log: ConcreteVisitor visited ElementB: Value="_tValue
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Visit ConcreteElementC - performs specific operation for this element type
/// 
/// @param pElement The ConcreteElementC being visited
/// @return %Status indicating success or failure  
Method VisitConcreteElementC(pElement As Patterns.GoF.Behavioral.Element) As %Status
{
    Set tSC = $$$OK
    
    Try {
        Set ..VisitCount = ..VisitCount + 1
        
        // Perform operation specific to ConcreteElementC (composite)
        Set tName = pElement.GetName()
        Set tChildCount = pElement.GetChildCount()
        Set tState = pElement.GetProcessingState()
        Set tOperation = "Processing ElementC: Name="_tName_", Children="_tChildCount_", State="_tState
        
        // Accumulate result
        If ..Results '= "" Set ..Results = ..Results_"; "
        Set ..Results = ..Results_tOperation
        
        // Log: ConcreteVisitor visited ElementC: "_tName_" with "_tChildCount_" children"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Initialize visitor before traversal
/// Called before starting to visit elements
/// 
/// @return %Status indicating success or failure
Method Initialize() As %Status
{
    Set ..Results = ""
    Set ..VisitCount = 0
    // Log: ConcreteVisitor initialized
    Quit $$$OK
}

/// Finalize visitor after traversal
/// Called after all elements have been visited
/// 
/// @return %Status indicating success or failure
Method Finalize() As %Status
{
    // Log: ConcreteVisitor finalized. Visited "_..VisitCount_" elements"
    Quit $$$OK
}

/// Get the result of the visitor's operation
/// Returns the accumulated results from visiting elements
/// 
/// @return %String The accumulated results
Method GetResult() As %String
{
    Quit "Visited "_..VisitCount_" elements: "_..Results
}

/// Get the visit count
/// 
/// @return %Integer Number of elements visited
Method GetVisitCount() As %Integer
{
    Quit ..VisitCount
}

/// Clear accumulated results
/// Resets the visitor to its initial state
/// 
/// @return %Status indicating success or failure
Method ClearResults() As %Status
{
    Set ..Results = ""
    Set ..VisitCount = 0
    Quit $$$OK
}

/// Check if visitor has any results
/// 
/// @return %Boolean True if visitor has accumulated results
Method HasResults() As %Boolean
{
    Quit (..Results '= "")
}

}
