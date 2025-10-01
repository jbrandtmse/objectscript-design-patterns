/// Gang of Four Visitor Pattern - Concrete Element C Implementation
/// 
/// This concrete element represents a composite element that can contain other elements.
/// It implements the Accept method to enable double dispatch and supports
/// hierarchical structures by accepting visitors for itself and its children.
/// 
/// <example>
/// Set elementC = ##class(Patterns.GoF.Behavioral.ConcreteElementC).%New()
/// Do elementC.SetName("Container")
/// Do elementC.AddChild(elementA)
/// Do elementC.AddChild(elementB)
/// Set visitor = ##class(ConcreteVisitor).%New()
/// Do elementC.Accept(visitor)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Element
/// @see Patterns.GoF.Behavioral.Visitor
/// @since 1.0.0
Class Patterns.GoF.Behavioral.ConcreteElementC Extends Patterns.GoF.Behavioral.Element
{

/// Property for element name
Property Name As %String [ InitialExpression = "Composite" ];

/// Collection of child elements
Property Children As %ListOfObjects [ Private ];

/// Property to track processing state
Property ProcessingState As %String [ InitialExpression = "Unprocessed" ];

/// Constructor - initialize the children list
Method %OnNew(initvalue As %String = "") As %Status
{
    Set ..Children = ##class(%ListOfObjects).%New()
    Quit $$$OK
}

/// Accept a visitor - implements double dispatch
/// Calls the specific VisitConcreteElementC method on the visitor
/// Also traverses child elements
/// 
/// @param pVisitor The visitor to accept
/// @return %Status indicating success or failure
Method Accept(pVisitor As Patterns.GoF.Behavioral.Visitor) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // First, let the visitor visit this composite element
        Set tSC = pVisitor.VisitConcreteElementC($this)
        If $$$ISERR(tSC) Quit
        
        // Then, let the visitor visit all children
        For i=1:1:..Children.Count() {
            Set tChild = ..Children.GetAt(i)
            If $IsObject(tChild) {
                Set tSC = tChild.Accept(pVisitor)
                If $$$ISERR(tSC) Quit
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the element's name
/// 
/// @return %String The element's name
Method GetName() As %String
{
    Quit ..Name
}

/// Set the element's name
/// 
/// @param pName The name to set
/// @return %Status indicating success or failure
Method SetName(pName As %String) As %Status
{
    Set ..Name = pName
    Quit $$$OK
}

/// Get the element's data
/// Returns information about the composite
/// 
/// @return %String The element's data
Method GetData() As %String
{
    Quit "Composite: "_..Name_" with "_..Children.Count()_" children"
}

/// Check if this element has child elements
/// 
/// @return %Boolean True if element has children
Method HasChildren() As %Boolean
{
    Quit (..Children.Count() > 0)
}

/// Get the child elements
/// 
/// @return %ListOfObjects List of child elements
Method GetChildren() As %ListOfObjects
{
    Quit ..Children
}

/// Add a child element
/// 
/// @param pChild The child element to add
/// @return %Status indicating success or failure
Method AddChild(pChild As Patterns.GoF.Behavioral.Element) As %Status
{
    Set tSC = $$$OK
    
    Try {
        If '$IsObject(pChild) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid child element")
            Quit
        }
        
        Do ..Children.Insert(pChild)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Remove a child element
/// 
/// @param pChild The child element to remove
/// @return %Status indicating success or failure
Method RemoveChild(pChild As Patterns.GoF.Behavioral.Element) As %Status
{
    Set tSC = $$$OK
    
    Try {
        For i=1:1:..Children.Count() {
            If ..Children.GetAt(i) = pChild {
                Do ..Children.RemoveAt(i)
                Quit
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Remove all child elements
/// 
/// @return %Status indicating success or failure
Method RemoveAllChildren() As %Status
{
    Do ..Children.Clear()
    Quit $$$OK
}

/// Get the number of children
/// 
/// @return %Integer Number of children
Method GetChildCount() As %Integer
{
    Quit ..Children.Count()
}

/// Set the processing state
/// 
/// @param pState The state to set
/// @return %Status indicating success or failure
Method SetProcessingState(pState As %String) As %Status
{
    Set ..ProcessingState = pState
    Quit $$$OK
}

/// Get the processing state
/// 
/// @return %String The processing state
Method GetProcessingState() As %String
{
    Quit ..ProcessingState
}

/// Perform operation specific to ElementC
/// This is an operation that's part of the element itself
/// 
/// @return %String Result of the operation
Method OperationC() As %String
{
    Quit "ElementC Operation: "_..Name_" ("_..ProcessingState_") with "_..Children.Count()_" children"
}

/// Get element-specific information
/// 
/// @return %String Element information
Method GetElementInfo() As %String
{
    Set tInfo = "ConcreteElementC: Name="_..Name_", State="_..ProcessingState_", Children="_..Children.Count()
    
    // Add child info
    If ..Children.Count() > 0 {
        Set tInfo = tInfo_" ["
        For i=1:1:..Children.Count() {
            Set tChild = ..Children.GetAt(i)
            If $IsObject(tChild) {
                If i > 1 Set tInfo = tInfo_", "
                Set tInfo = tInfo_tChild.GetName()
            }
        }
        Set tInfo = tInfo_"]"
    }
    
    Quit tInfo
}

/// Clone this element (shallow clone - children are not cloned)
/// 
/// @return Element A clone of this element
Method Clone() As Patterns.GoF.Behavioral.Element
{
    Set tClone = ##class(Patterns.GoF.Behavioral.ConcreteElementC).%New()
    Do tClone.SetName(..Name)
    Do tClone.SetProcessingState(..ProcessingState)
    
    // Note: This is a shallow clone - children are referenced, not cloned
    For i=1:1:..Children.Count() {
        Do tClone.AddChild(..Children.GetAt(i))
    }
    
    Quit tClone
}

}
