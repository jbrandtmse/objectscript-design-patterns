/// Gang of Four Visitor Pattern - Abstract Visitor Base Class
/// 
/// Intent:
/// Represent an operation to be performed on the elements of an object structure.
/// Visitor lets you define a new operation without changing the classes of the
/// elements on which it operates.
/// 
/// Applicability:
/// - An object structure contains many classes of objects with differing interfaces
/// - Many distinct operations need to be performed on objects in an object structure
/// - The classes defining the object structure rarely change, but you often want
///   to define new operations over the structure
/// 
/// Structure:
/// The Visitor pattern uses double dispatch to call the appropriate method
/// based on both the visitor type and element type.
/// 
/// <example>
/// Set visitor = ##class(ConcreteVisitor).%New()
/// Set element = ##class(ConcreteElement).%New()
/// Do element.Accept(visitor)
/// </example>
/// 
/// @see Patterns.GoF.Behavioral.Element
/// @since 1.0.0
Class Patterns.GoF.Behavioral.Visitor Extends %RegisteredObject [ Abstract ]
{

/// Visit method for ConcreteElementA
/// This method is called when visiting an element of type ConcreteElementA
/// 
/// @param pElement The element being visited
/// @return %Status indicating success or failure
Method VisitConcreteElementA(pElement As Element) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Visit method for ConcreteElementB
/// This method is called when visiting an element of type ConcreteElementB
/// 
/// @param pElement The element being visited
/// @return %Status indicating success or failure
Method VisitConcreteElementB(pElement As Element) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Visit method for ConcreteElementC
/// This method is called when visiting an element of type ConcreteElementC
/// 
/// @param pElement The element being visited
/// @return %Status indicating success or failure
Method VisitConcreteElementC(pElement As Element) As %Status [ Abstract ]
{
    Quit $$$OK
}

/// Generic visit method for unknown element types
/// This provides a fallback for elements not explicitly handled
/// 
/// @param pElement The element being visited
/// @return %Status indicating success or failure
Method VisitGeneric(pElement As Element) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Default implementation - can be overridden
        Set tClassName = pElement.%ClassName(1)
        // Log: Visitor visiting generic element of type: "_tClassName
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
    Quit $$$OK
}

/// Finalize visitor after traversal
/// Called after all elements have been visited
/// 
/// @return %Status indicating success or failure
Method Finalize() As %Status
{
    Quit $$$OK
}

/// Get the result of the visitor's operation
/// Returns any accumulated result from visiting elements
/// 
/// @return %String The result (can be overridden to return other types)
Method GetResult() As %String
{
    Quit ""
}

}
