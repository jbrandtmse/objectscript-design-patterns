/// Gang of Four Template Method Pattern - Define Algorithm Skeleton
/// <p>The Template Method pattern defines the skeleton of an algorithm in a base class,
/// letting subclasses override specific steps of the algorithm without changing
/// the algorithm's structure.</p>
/// 
/// <p>This pattern is particularly useful when you have multiple classes that
/// share the same algorithm structure but differ in the implementation of certain steps.</p>
Class Patterns.GoF.Behavioral.TemplateMethod Extends %RegisteredObject [ Abstract ]
{

/// <p>The template method defines the algorithm skeleton.
/// This method is marked [ Final ] to prevent subclasses from overriding it,
/// ensuring the algorithm structure remains intact.</p>
/// 
/// <p>The algorithm consists of:
/// <ol>
///   <li>Initialize - Hook method for setup</li>
///   <li>PrimitiveOperation1 - Abstract method that must be implemented</li>
///   <li>ConcreteOperation - Shared implementation</li>
///   <li>PrimitiveOperation2 - Abstract method that must be implemented</li>
///   <li>Optional step controlled by hook</li>
///   <li>Finalize - Hook method for cleanup</li>
/// </ol></p>
/// 
/// <returns>%Status indicating success or failure of the algorithm execution</returns>
Method Execute() As %Status [ Final ]
{
    Set tSC = $$$OK
    
    Try {
        // Step 1: Initialize (hook method - optional override)
        Do ..Initialize()
        
        // Step 2: Primitive operation (abstract - must override)
        Set tSC = ..PrimitiveOperation1()
        If $$$ISERR(tSC) Quit
        
        // Step 3: Concrete operation (provided by base class)
        Do ..%ConcreteOperation()
        
        // Step 4: Primitive operation (abstract - must override)
        Set tSC = ..PrimitiveOperation2()
        If $$$ISERR(tSC) Quit
        
        // Step 5: Hook method for conditional behavior
        If ..Hook() {
            Do ..OptionalOperation()
        }
        
        // Step 6: Finalize (hook method)
        Do ..Finalize()
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>Hook method called at the beginning of the algorithm.
/// Subclasses can override this to perform initialization.</p>
/// 
/// <p>Default implementation is empty - subclasses are not required to override.</p>
Method Initialize()
{
    // Default implementation (can be empty)
    // Subclasses can override to add initialization logic
}

/// <p>Abstract primitive operation - first required step.
/// Subclasses MUST implement this method.</p>
/// 
/// <p>This is a primitive operation that forms part of the algorithm skeleton.
/// The implementation should perform the first major step of the algorithm.</p>
/// 
/// <returns>%Status indicating success or failure of the operation</returns>
Method PrimitiveOperation1() As %Status [ Abstract ]
{
    // Abstract methods in ObjectScript must have a body with return value
    Quit $$$OK
}

/// <p>Concrete operation shared by all subclasses.
/// This method is marked [ Private ] to prevent direct access.</p>
/// 
/// <p>This operation contains implementation that is common to all
/// subclasses and should not vary.</p>
Method %ConcreteOperation() [ Private ]
{
    // Implementation that all subclasses share
    // This could be logging, validation, or other common operations
    
    // For demonstration, we'll just set a timestamp
    Set ..%LastExecutionTime = $ZDATETIME($HOROLOG, 3)
}

/// <p>Abstract primitive operation - second required step.
/// Subclasses MUST implement this method.</p>
/// 
/// <p>This is another primitive operation that forms part of the algorithm skeleton.
/// The implementation should perform the second major step of the algorithm.</p>
/// 
/// <returns>%Status indicating success or failure of the operation</returns>
Method PrimitiveOperation2() As %Status [ Abstract ]
{
    // Abstract methods in ObjectScript must have a body with return value
    Quit $$$OK
}

/// <p>Hook method that controls optional behavior.
/// Returns a boolean to determine if the optional operation should execute.</p>
/// 
/// <p>Default implementation returns 1 (true). Subclasses can override
/// to provide conditional logic.</p>
/// 
/// <returns>%Boolean - 1 to execute optional operation, 0 to skip</returns>
Method Hook() As %Boolean
{
    Quit 1  // Default is true - execute optional operation
}

/// <p>Optional operation controlled by the Hook() method.
/// This method is only executed if Hook() returns true.</p>
/// 
/// <p>Subclasses can override this to add optional behavior to the algorithm.</p>
Method OptionalOperation()
{
    // Default implementation for optional step
    // Subclasses can override to add specific optional behavior
}

/// <p>Hook method called at the end of the algorithm.
/// Subclasses can override this to perform cleanup.</p>
/// 
/// <p>Default implementation is empty - subclasses are not required to override.</p>
Method Finalize()
{
    // Default cleanup (can be empty)
    // Subclasses can override to add finalization logic
}

/// <p>Property to track the last execution time of the template method.</p>
/// <p>This is set automatically by the concrete operation.</p>
Property %LastExecutionTime As %String [ Private ];

/// <p>Get the last execution time of the template method.</p>
/// 
/// <returns>String containing the timestamp of last execution</returns>
Method GetLastExecutionTime() As %String
{
    Quit ..%LastExecutionTime
}

/// <p>Validate that the template method implementation is correct.
/// This can be used by unit tests to verify the pattern structure.</p>
/// 
/// <returns>%Status indicating if the validation passed</returns>
ClassMethod ValidateImplementation(pClassName As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Check if class exists and extends TemplateMethod
        If '##class(%Dictionary.ClassDefinition).%ExistsId(pClassName) {
            Set tSC = $$$ERROR($$$GeneralError, "Class " _ pClassName _ " does not exist")
            Quit
        }
        
        // Create instance to check if it's properly instantiable
        Set tObj = $CLASSMETHOD(pClassName, "%New")
        If '$IsObject(tObj) {
            Set tSC = $$$ERROR($$$GeneralError, "Cannot instantiate " _ pClassName)
            Quit
        }
        
        // Check if it extends TemplateMethod
        If '(tObj.%IsA("Patterns.GoF.Behavioral.TemplateMethod")) {
            Set tSC = $$$ERROR($$$GeneralError, pClassName _ " does not extend TemplateMethod")
            Quit
        }
        
        // Check that Execute method cannot be overridden (it's Final)
        Set tMethodDef = ##class(%Dictionary.MethodDefinition).%OpenId(pClassName _ "||Execute")
        If $IsObject(tMethodDef) {
            // If Execute exists in subclass, it's an error (should be Final in base)
            Set tSC = $$$ERROR($$$GeneralError, "Execute method should not be overridden in " _ pClassName)
            Quit
        }
        
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// <p>Factory method to create instances of template method implementations.</p>
/// 
/// <param name="pClassName">The full class name of the implementation to create</param>
/// <returns>Instance of the specified template method implementation, or empty string on error</returns>
ClassMethod CreateInstance(pClassName As %String) As Patterns.GoF.Behavioral.TemplateMethod
{
    Set tInstance = ""
    
    Try {
        // Validate the class name first
        If ##class(%Dictionary.ClassDefinition).%ExistsId(pClassName) {
            Set tInstance = $CLASSMETHOD(pClassName, "%New")
            
            // Verify it's a proper TemplateMethod subclass
            If '$IsObject(tInstance) || '(tInstance.%IsA("Patterns.GoF.Behavioral.TemplateMethod")) {
                Set tInstance = ""
            }
        }
    } Catch ex {
        Set tInstance = ""
    }
    
    Quit tInstance
}

/// <p>Helper method to demonstrate the Hollywood Principle:
/// "Don't call us, we'll call you"</p>
/// 
/// <p>This method explains how the template method pattern implements
/// inversion of control.</p>
/// 
/// <returns>String explaining the Hollywood Principle in this context</returns>
ClassMethod ExplainHollywoodPrinciple() As %String
{
    Set tExplanation = "The Hollywood Principle states 'Don't call us, we'll call you.' "
    Set tExplanation = tExplanation _ "In the Template Method pattern, the base class (TemplateMethod) "
    Set tExplanation = tExplanation _ "controls the algorithm flow and calls the subclass methods when needed. "
    Set tExplanation = tExplanation _ "Subclasses don't control when their methods are called - "
    Set tExplanation = tExplanation _ "they simply provide implementations that the base class orchestrates."
    
    Quit tExplanation
}

}
