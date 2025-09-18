# Chapter 9: Composite Pattern

## Intent
Compose objects into tree structures to represent part-whole hierarchies. Composite lets clients treat individual objects and compositions of objects uniformly. The pattern allows you to build complex tree structures while treating both individual elements (leaves) and groups of elements (composites) through the same interface.

## Also Known As
- Part-Whole
- Object Tree

## Motivation
Graphics applications like drawing editors and schematic capture systems let users build complex diagrams out of simple components. The user can group components to form larger components, which in turn can be grouped to form still larger components. A simple implementation could define classes for graphical primitives such as Text and Lines plus other classes that act as containers for these primitives.

But there's a problem with this approach: Code that uses these classes must treat primitive and container objects differently, even if most of the time the user treats them identically. Having to distinguish these objects makes the application more complex. The Composite pattern describes how to use recursive composition so that clients don't have to make this distinction.

Consider a hospital organizational structure. A hospital consists of various departments (Emergency, Surgery, Pediatrics), and each department contains medical units (ICU, Operating Rooms, Recovery Rooms). Some operations, like calculating total budget or counting staff, need to work uniformly whether applied to the entire hospital, a specific department, or an individual unit. The Composite pattern lets us treat all these organizational levels uniformly while maintaining their hierarchical relationships.

The key to the Composite pattern is an abstract class that represents both primitives and their containers. In our hospital example, this would be an OrganizationalUnit class that can represent hospitals, departments, and individual medical units. This class declares operations like CalculateBudget() and GetStaffCount() that are meaningful for both composite objects (hospitals, departments) and leaf objects (medical units).

## Applicability
Use the Composite pattern when:
- You want to represent part-whole hierarchies of objects
- You want clients to be able to ignore the difference between compositions of objects and individual objects
- The structure can have any level of complexity and is dynamic
- You want to be able to treat all objects in the composite structure uniformly

## Structure
```
        Component
        +-----------------+
        |                 |
        |Add(Component)   |
        |Remove(Component)|
        |GetChild(int)    |
        |Operation()      |
        +-----------------+
              ^
              |
     +--------+--------+
     |                 |
   Leaf           Composite
   +-----+        +------------------+
   |     |        |children           |
   |Operation()   |Add(Component)    |
   +-----+        |Remove(Component) |
                  |GetChild(int)     |
                  |Operation()       |
                  |  for each child: |
                  |    child.Operation()|
                  +------------------+
```

## Participants
- **Component** (OrganizationalUnit)
  - Declares the interface for objects in the composition
  - Implements default behavior for the interface common to all classes
  - Declares an interface for accessing and managing child components
  - (Optional) Defines an interface for accessing a component's parent

- **Leaf** (MedicalUnit)
  - Represents leaf objects in the composition that have no children
  - Defines behavior for primitive objects in the composition

- **Composite** (Hospital, Department)
  - Defines behavior for components having children
  - Stores child components
  - Implements child-related operations in the Component interface

- **Client**
  - Manipulates objects in the composition through the Component interface

## Collaborations
- Clients use the Component class interface to interact with objects in the composite structure
- If the recipient is a Leaf, then the request is handled directly
- If the recipient is a Composite, it usually forwards requests to its child components, possibly performing additional operations before and/or after forwarding

## Consequences
The Composite pattern has the following benefits and liabilities:

### Benefits
1. **Defines class hierarchies consisting of primitive and composite objects** - Primitives can be composed into more complex objects, which in turn can be composed, and so on recursively
2. **Makes the client simple** - Clients can treat composite structures and individual objects uniformly
3. **Makes it easier to add new kinds of components** - Newly defined Composite or Leaf subclasses work automatically with existing structures and client code
4. **Provides a flexible structure** - The pattern provides a manageable interface for a tree structure

### Liabilities
1. **Can make your design overly general** - The disadvantage of making it easy to add new components is that it makes it harder to restrict the components of a composite
2. **May make it harder to restrict component types** - Sometimes you want a composite to have only certain types of components

## Implementation
Consider the following implementation issues:

### 1. Explicit Parent References
Maintaining references from child components to their parent can simplify the traversal and management of a composite structure. Parent references are essential for supporting operations like removing a component from all composites that contain it.

### 2. Sharing Components
It's often useful to share components, for example, to reduce storage requirements. But when a component has only one parent, sharing becomes difficult. A possible solution is to use reference counting.

### 3. Maximizing the Component Interface
One of the goals of the Composite pattern is to make clients unaware of the specific Leaf or Composite classes they're using. To attain this goal, the Component class should define as many common operations for Composite and Leaf classes as possible.

### 4. Declaring the Child Management Operations
An important issue is where to declare the Add and Remove operations. The decision involves a trade-off between safety and transparency:
- **Transparency** - Defining child management in Component gives you transparency but costs safety
- **Safety** - Defining child management in Composite gives you safety but costs transparency

### 5. Child Ordering
Many designs specify an ordering on the children of Composite. When child ordering is an issue, you must design the child management interface carefully to manage the sequence of children.

### 6. ObjectScript-Specific Considerations
- Use %Collection.ListOfObj for efficient child storage
- Implement circular reference detection using parent chain traversal
- Use %Status return values for all operations that can fail
- Consider using globals for persistent tree storage
- Leverage %RegisteredObject for automatic memory management

## Sample Code
Here's the ObjectScript implementation of the Composite pattern:

### Core Pattern Classes
```objectscript
/// Component abstract class for Composite pattern
Class Patterns.GoF.Structural.Component Extends %RegisteredObject [ Abstract ]
{
    Property Name As %String;
    Property Parent As Component;
    
    /// Perform operation on component
    Method Operation() As %String [ Abstract ]
    {
        Quit ""
    }
    
    /// Add child component
    Method Add(pComponent As Component) As %Status
    {
        Quit $$$ERROR($$$GeneralError, "Cannot add to leaf")
    }
    
    /// Remove child component
    Method Remove(pComponent As Component) As %Status
    {
        Quit $$$ERROR($$$GeneralError, "Cannot remove from leaf")
    }
    
    /// Get child at index
    Method GetChild(pIndex As %Integer) As Component
    {
        Quit ""
    }
    
    /// Check if this is a leaf node
    Method IsLeaf() As %Boolean
    {
        Quit 1
    }
}

/// Composite class managing child components
Class Patterns.GoF.Structural.Composite Extends Component
{
    Property Children As %ListOfObjects [ Private ];
    
    Method %OnNew() As %Status
    {
        Set ..Children = ##class(%ListOfObjects).%New()
        Quit $$$OK
    }
    
    Method Add(pComponent As Component) As %Status
    {
        // Check for null
        If '$IsObject(pComponent) {
            Quit $$$ERROR($$$GeneralError, "Cannot add null")
        }
        
        // Prevent circular references
        Set tParent = ..Parent
        While $IsObject(tParent) {
            If tParent = pComponent {
                Quit $$$ERROR($$$GeneralError, "Circular reference")
            }
            Set tParent = tParent.Parent
        }
        
        Do ..Children.Insert(pComponent)
        Set pComponent.Parent = $this
        Quit $$$OK
    }
    
    Method Operation() As %String
    {
        Set tResult = "Composite[" _ ..Name _ "]{"
        Set tFirst = 1
        
        For tIndex = 1:1:..Children.Count() {
            Set tChild = ..Children.GetAt(tIndex)
            If tChild '= "" {
                If 'tFirst {
                    Set tResult = tResult _ ", "
                }
                Set tResult = tResult _ tChild.Operation()
                Set tFirst = 0
            }
        }
        
        Set tResult = tResult _ "}"
        Quit tResult
    }
    
    Method IsLeaf() As %Boolean
    {
        Quit 0
    }
}
```

### Healthcare Example
```objectscript
/// Hospital organizational unit base class
Class Patterns.Examples.OrganizationalUnit Extends Component [ Abstract ]
{
    Property Budget As %Numeric;
    Property StaffCount As %Integer;
    
    /// Calculate total budget including children
    Method CalculateBudget() As %Numeric [ Abstract ]
    {
        Quit 0
    }
    
    /// Get total staff count including children
    Method GetTotalStaffCount() As %Integer [ Abstract ]
    {
        Quit 0
    }
}

/// Hospital composite class
Class Patterns.Examples.Hospital Extends OrganizationalUnit
{
    Property Departments As %ListOfObjects [ Private ];
    Property Location As %String;
    Property BedCount As %Integer;
    Property AccreditationStatus As %String;
    
    Method CalculateBudget() As %Numeric
    {
        Set tTotal = ..Budget
        For i = 1:1:..Departments.Count() {
            Set tDept = ..Departments.GetAt(i)
            If $IsObject(tDept) {
                Set tTotal = tTotal + tDept.CalculateBudget()
            }
        }
        Quit tTotal
    }
    
    Method GetTotalStaffCount() As %Integer
    {
        Set tTotal = ..StaffCount
        For i = 1:1:..Departments.Count() {
            Set tDept = ..Departments.GetAt(i)
            If $IsObject(tDept) {
                Set tTotal = tTotal + tDept.GetTotalStaffCount()
            }
        }
        Quit tTotal
    }
}

/// Medical unit leaf class
Class Patterns.Examples.MedicalUnit Extends OrganizationalUnit
{
    Property BedCapacity As %Integer;
    Property CurrentOccupancy As %Integer;
    
    Method CalculateBudget() As %Numeric
    {
        Quit ..Budget
    }
    
    Method GetTotalStaffCount() As %Integer
    {
        Quit ..StaffCount
    }
    
    Method GetOccupancyRate() As %Numeric
    {
        If ..BedCapacity = 0 Quit 0
        Quit (..CurrentOccupancy / ..BedCapacity) * 100
    }
}
```

### Tree Traversal Example
```objectscript
/// Pre-order traversal
Method TraversePreOrder() As %String
{
    Set tResult = ..Name
    If '..IsLeaf() {
        For i = 1:1:..Children.Count() {
            Set tChild = ..Children.GetAt(i)
            Set tResult = tResult _ "," _ tChild.TraversePreOrder()
        }
    }
    Quit tResult
}

/// Level-order traversal using queue
Method TraverseLevelOrder() As %String
{
    Set tQueue = ##class(%Collection.ListOfObj).%New()
    Do tQueue.Insert($this)
    Set tResult = ""
    
    While tQueue.Count() > 0 {
        Set tNode = tQueue.GetAt(1)
        Do tQueue.RemoveAt(1)
        
        If tResult '= "" Set tResult = tResult _ ","
        Set tResult = tResult _ tNode.Name
        
        If 'tNode.IsLeaf() {
            For i = 1:1:tNode.Children.Count() {
                Do tQueue.Insert(tNode.Children.GetAt(i))
            }
        }
    }
    Quit tResult
}
```

### Usage Example
```objectscript
// Create hospital structure
Set hospital = ##class(Hospital).%New()
Set hospital.Name = "City General"
Set hospital.Budget = 5000000

Set emergency = ##class(Department).%New()
Set emergency.Name = "Emergency"
Set emergency.Budget = 2000000

Set icu = ##class(MedicalUnit).%New()
Set icu.Name = "ICU"
Set icu.Budget = 500000
Set icu.BedCapacity = 20

// Build hierarchy
Do hospital.Add(emergency)
Do emergency.Add(icu)

// Calculate total budget
Set totalBudget = hospital.CalculateBudget()
Write "Total Budget: $", totalBudget, !

// Traverse the structure
Set structure = hospital.TraversePreOrder()
Write "Structure: ", structure, !
```

## Known Uses
- GUI frameworks use Composite for widgets and containers
- Compilers use the pattern for abstract syntax trees
- File systems use it for directories and files
- Document processors use it for document structure (chapters, sections, paragraphs)
- Healthcare systems use it for organizational hierarchies
- XML/HTML DOM represents document structure as a composite

## Related Patterns
- **Chain of Responsibility** is often used with Composite. When a request is made to a composite, it can be passed along the chain of components
- **Decorator** is often used with Composite. When decorators and composites are used together, they usually have a common parent class
- **Flyweight** lets you share components, but they can no longer refer to their parents
- **Iterator** can be used to traverse composites
- **Visitor** localizes operations and behavior that would otherwise be distributed across Composite and Leaf classes

## Healthcare Context
In healthcare systems, the Composite pattern is invaluable for:
- Hospital organizational structures (hospital → departments → units → rooms)
- Medical record hierarchies (patient record → episodes → encounters → observations)
- Treatment plans (plan → phases → interventions → activities)
- Clinical pathways (pathway → stages → steps → actions)
- Healthcare facility networks (network → regions → facilities → departments)
- Billing structures (invoice → categories → items → charges)

The pattern ensures that operations like calculating costs, counting resources, or generating reports can work uniformly across all levels of these hierarchies, from individual items to entire organizational structures.

## Tree Persistence with Globals
ObjectScript globals provide an efficient way to persist tree structures:

```objectscript
// Global structure for tree storage
^TreeStorage(treeName, nodeId) = $listbuild(name, type, parentId)
^TreeStorage(treeName, nodeId, "children") = $listbuild(childId1, childId2, ...)
^TreeStorage(treeName, nodeId, "data", property) = value

// Save tree
Method SaveTree(root, treeName) As %Status
{
    Kill ^TreeStorage(treeName)
    Set ^TreeStorage(treeName, "metadata", "created") = $ZDateTime($H, 3)
    Do ..SaveNodeRecursive(root, treeName, 1, "")
    Quit $$$OK
}

// Load tree
Method LoadTree(treeName) As Component
{
    If '$Data(^TreeStorage(treeName, 1)) {
        Quit ""
    }
    Quit ..LoadNodeRecursive(treeName, 1)
}
```

This approach provides:
- Efficient hierarchical data storage
- Fast tree traversal using global subscripts
- Natural support for sparse trees
- Built-in persistence without external databases
- Easy tree cloning and versioning
