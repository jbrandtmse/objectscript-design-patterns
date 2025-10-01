/// Gang of Four Visitor Pattern - Abstract Element Base Class
/// 
/// Intent:
/// Defines an interface for elements that can accept visitors.
/// Elements implement the Accept method to enable double dispatch.
/// 
/// The Element hierarchy represents the object structure that visitors
/// can traverse and perform operations on.
/// 
/// Double Dispatch:
/// The Accept method implements double dispatch by calling the appropriate
/// Visit method on the visitor, passing itself as a parameter.
/// 
/// <example>
/// Set element = ##class(ConcreteElement).%New()
/// Set visitor = ##class(ConcreteVisitor).%New()
/// Set status = element.Accept(visitor)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Visitor
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Element Extends %RegisteredObject [ Abstract ]
{

/// Accept a visitor - implements double dispatch
/// This method must be implemented by concrete elements to call
/// the appropriate Visit method on the visitor
/// 
/// @param pVisitor The visitor to accept
/// @return %Status indicating success or failure
Method Accept(pVisitor As Patterns.GoF.Behavioral.Visitor) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Get the name or identifier of the element
/// Used for debugging and logging purposes
/// 
/// @return %String The element's name or identifier
Method GetName() As %String
{
    Quit $this.%ClassName(1)
}

/// Get the element's data or value
/// Can be overridden to return element-specific data
/// 
/// @return %String The element's data
Method GetData() As %String
{
    Quit ""
}

/// Check if this element has child elements
/// Used for composite structures
/// 
/// @return %Boolean True if element has children, False otherwise
Method HasChildren() As %Boolean
{
    Quit 0
}

/// Get the child elements
/// Returns a list of child elements for composite structures
/// 
/// @return %ListOfObjects List of child elements
Method GetChildren() As %ListOfObjects
{
    Quit ##class(%ListOfObjects).%New()
}

/// Add a child element
/// Used for building composite structures
/// 
/// @param pChild The child element to add
/// @return %Status indicating success or failure
Method AddChild(pChild As Element) As %Status
{
    Quit $$$ERROR($$$GeneralError, "This element does not support children")
}

/// Remove a child element
/// Used for modifying composite structures
/// 
/// @param pChild The child element to remove
/// @return %Status indicating success or failure
Method RemoveChild(pChild As Element) As %Status
{
    Quit $$$ERROR($$$GeneralError, "This element does not support children")
}

/// Clone this element
/// Creates a copy of the element
/// 
/// @return Element A clone of this element
Method Clone() As Element
{
    Quit $$$NULLOREF
}

}
