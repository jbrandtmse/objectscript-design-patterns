/// Gang of Four Visitor Pattern - Concrete Element B Implementation
/// 
/// This concrete element represents another type of element in the object structure.
/// It implements the Accept method to enable double dispatch by calling the
/// appropriate VisitConcreteElementB method on the visitor.
/// 
/// <example>
/// Set elementB = ##class(Patterns.GoF.Behavioral.ConcreteElementB).%New()
/// Do elementB.SetValue(42)
/// Set visitor = ##class(ConcreteVisitor).%New()
/// Do elementB.Accept(visitor)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Element
/// @see Patterns.GoF.Behavioral.Visitor
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ConcreteElementB Extends Patterns.GoF.Behavioral.Element
{

/// Property specific to ConcreteElementB - numeric value
Property NumericValue As %Integer [ InitialExpression = 0 ];

/// Property for element status
Property Status As %String [ InitialExpression = "Active" ];

/// Accept a visitor - implements double dispatch
/// Calls the specific VisitConcreteElementB method on the visitor
/// 
/// @param pVisitor The visitor to accept
/// @return %Status indicating success or failure
Method Accept(pVisitor As Patterns.GoF.Behavioral.Visitor) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Double dispatch - element tells visitor its specific type
        Set tSC = pVisitor.VisitConcreteElementB($this)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the element's data
/// Returns the numeric value as a string
/// 
/// @return %String The element's data
Method GetData() As %String
{
    Quit ..NumericValue
}

/// Set the numeric value for this element
/// 
/// @param pValue The value to set
/// @return %Status indicating success or failure
Method SetValue(pValue As %Integer) As %Status
{
    Set ..NumericValue = pValue
    Quit $$$OK
}

/// Get the numeric value
/// 
/// @return %Integer The numeric value
Method GetValue() As %Integer
{
    Quit ..NumericValue
}

/// Set the status of this element
/// 
/// @param pStatus The status to set
/// @return %Status indicating success or failure
Method SetStatus(pStatus As %String) As %Status
{
    Set ..Status = pStatus
    Quit $$$OK
}

/// Get the status
/// 
/// @return %String The status
Method GetStatus() As %String
{
    Quit ..Status
}

/// Perform operation specific to ElementB
/// This is an operation that's part of the element itself
/// 
/// @return %String Result of the operation
Method OperationB() As %String
{
    Quit "ElementB Operation: Value="_ ..NumericValue_", Status="_..Status
}

/// Calculate something based on the numeric value
/// Example of element-specific functionality
/// 
/// @return %Integer Calculated result
Method Calculate() As %Integer
{
    Quit ..NumericValue * 2
}

/// Get element-specific information
/// 
/// @return %String Element information
Method GetElementInfo() As %String
{
    Quit "ConcreteElementB: Value="_ ..NumericValue_", Status="_..Status_", Calc="_..Calculate()
}

/// Clone this element
/// Creates a copy of the element with the same data
/// 
/// @return Element A clone of this element
Method Clone() As Patterns.GoF.Behavioral.Element
{
    Set tClone = ##class(Patterns.GoF.Behavioral.ConcreteElementB).%New()
    Do tClone.SetValue(..NumericValue)
    Do tClone.SetStatus(..Status)
    Quit tClone
}

}
