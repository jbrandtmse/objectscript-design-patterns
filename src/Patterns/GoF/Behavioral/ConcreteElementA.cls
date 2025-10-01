/// Gang of Four Visitor Pattern - Concrete Element A Implementation
/// 
/// This concrete element represents one type of element in the object structure.
/// It implements the Accept method to enable double dispatch by calling the
/// appropriate VisitConcreteElementA method on the visitor.
/// 
/// <example>
/// Set elementA = ##class(Patterns.GoF.Behavioral.ConcreteElementA).%New()
/// Do elementA.SetOperationData("Data for A")
/// Set visitor = ##class(ConcreteVisitor).%New()
/// Do elementA.Accept(visitor)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Element
/// @see Patterns.GoF.Behavioral.Visitor
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ConcreteElementA Extends Patterns.GoF.Behavioral.Element
{

/// Property specific to ConcreteElementA
Property OperationDataA As %String [ InitialExpression = "Default A Data" ];

/// Property to track visit count
Property VisitCount As %Integer [ InitialExpression = 0 ];

/// Accept a visitor - implements double dispatch
/// Calls the specific VisitConcreteElementA method on the visitor
/// 
/// @param pVisitor The visitor to accept
/// @return %Status indicating success or failure
Method Accept(pVisitor As Patterns.GoF.Behavioral.Visitor) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Increment visit count
        Set ..VisitCount = ..VisitCount + 1
        
        // Double dispatch - element tells visitor its specific type
        Set tSC = pVisitor.VisitConcreteElementA($this)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the element's data
/// Returns the specific operation data for this element
/// 
/// @return %String The element's data
Method GetData() As %String
{
    Quit ..OperationDataA
}

/// Set the operation data for this element
/// 
/// @param pData The data to set
/// @return %Status indicating success or failure
Method SetOperationData(pData As %String) As %Status
{
    Set ..OperationDataA = pData
    Quit $$$OK
}

/// Perform operation specific to ElementA
/// This is an operation that's part of the element itself
/// 
/// @return %String Result of the operation
Method OperationA() As %String
{
    Quit "ElementA Operation Result: "_..OperationDataA
}

/// Get element-specific information
/// 
/// @return %String Element information
Method GetElementInfo() As %String
{
    Quit "ConcreteElementA with data: "_..OperationDataA_" (visited "_..VisitCount_" times)"
}

/// Clone this element
/// Creates a copy of the element with the same data
/// 
/// @return Element A clone of this element
Method Clone() As Patterns.GoF.Behavioral.Element
{
    Set tClone = ##class(Patterns.GoF.Behavioral.ConcreteElementA).%New()
    Do tClone.SetOperationData(..OperationDataA)
    Quit tClone
}

}
