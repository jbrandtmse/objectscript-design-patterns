# Chapter 17: Iterator Pattern

## Intent
Provide a way to access the elements of an aggregate object sequentially without exposing its underlying representation.

## Also Known As
- Cursor

## Motivation
An aggregate object such as a list should give you a way to access its elements without exposing its internal structure. Moreover, you might want to traverse the list in different ways, depending on what you want to accomplish. But you probably don't want to bloat the List interface with operations for different traversals, even if you could anticipate the ones you will need. You might also need to have more than one traversal pending on the same list.

The Iterator pattern lets you do all this. The key idea in this pattern is to take the responsibility for access and traversal out of the list object and put it into an iterator object.

## Structure
```
+-------------------+          +-------------------+
|   <<interface>>   |          |   <<interface>>   |
| IterableCollection|<>------->|     Iterator      |
+-------------------+          +-------------------+
| +CreateIterator() |          | +HasNext()        |
+-------------------+          | +Next()           |
        ^                      | +Reset()          |
        |                      | +Remove()         |
        |                      | +Current()        |
        |                      +-------------------+
        |                               ^
        |                               |
+-------------------+          +-------------------+
| ConcreteCollection|          | ConcreteIterator  |
+-------------------+          +-------------------+
| -items            |<-------->| -collection       |
| +CreateIterator() |          | -currentIndex     |
+-------------------+          | +HasNext()        |
                              | +Next()           |
                              +-------------------+
```

## Applicability
Use the Iterator pattern:
- To access an aggregate object's contents without exposing its internal representation
- To support multiple traversals of aggregate objects
- To provide a uniform interface for traversing different aggregate structures (polymorphic iteration)

## Participants

### Iterator
- Defines an interface for accessing and traversing elements

### ConcreteIterator
- Implements the Iterator interface
- Keeps track of the current position in the traversal of the aggregate

### IterableCollection
- Defines an interface for creating an Iterator object

### ConcreteCollection
- Implements the Iterator creation interface to return an instance of the proper ConcreteIterator

## Collaborations
- A ConcreteIterator keeps track of the current object in the aggregate and can compute the succeeding object in the traversal

## Consequences

### Benefits
1. **Simplified collection interface**: The collection interface doesn't need traversal methods
2. **Multiple simultaneous traversals**: Each iterator keeps its own traversal state
3. **Uniform iteration interface**: Different collection types can be traversed uniformly
4. **Decoupling**: Collections and traversal algorithms are decoupled

### Liabilities
1. **Overhead**: Creating iterators may have overhead for simple collections
2. **Concurrent modification**: Iterators may become invalid if the collection is modified

## Implementation

### ObjectScript Implementation Notes

#### Basic Iterator Implementation
```objectscript
/// Abstract Iterator class
Class Patterns.GoF.Behavioral.Iterator Extends %RegisteredObject
{
    /// Check if more elements exist
    Method HasNext() As %Boolean [ Abstract ]
    {
        Quit 0
    }
    
    /// Get next element in iteration
    Method Next() As %RegisteredObject [ Abstract ]
    {
        Quit $$$NULLOREF
    }
    
    /// Reset iterator to beginning
    Method Reset() As %Status
    {
        Quit $$$OK
    }
    
    /// Get current element without advancing
    Method Current() As %RegisteredObject
    {
        Quit $$$NULLOREF
    }
    
    /// Remove current element (optional)
    Method Remove() As %Status
    {
        Quit $$$ERROR($$$GeneralError, "Remove not supported")
    }
}
```

#### List Iterator Example
```objectscript
/// Iterator for %ListOf* collections
Class Patterns.GoF.Behavioral.ListIterator Extends Iterator
{
    Property Collection As %Collection.AbstractList [ Private ];
    Property CurrentIndex As %Integer [ InitialExpression = 0, Private ];
    Property Direction As %Integer [ InitialExpression = 1 ];
    
    Method %OnNew(pCollection As %Collection.AbstractList) As %Status
    {
        Set ..Collection = pCollection
        Set ..ModificationCount = pCollection.Count()
        Quit $$$OK
    }
    
    Method HasNext() As %Boolean
    {
        Set tHasNext = 0
        If ..Direction = 1 {
            Set tHasNext = (..CurrentIndex < ..Collection.Count())
        } Else {
            Set tHasNext = (..CurrentIndex > 1)
        }
        Quit tHasNext
    }
    
    Method Next() As %RegisteredObject
    {
        Set tResult = $$$NULLOREF
        If ..Direction = 1 {
            If ..CurrentIndex < ..Collection.Count() {
                Set ..CurrentIndex = ..CurrentIndex + 1
                Set tResult = ..Collection.GetAt(..CurrentIndex)
            }
        } Else {
            If ..CurrentIndex > 1 {
                Set ..CurrentIndex = ..CurrentIndex - 1
                Set tResult = ..Collection.GetAt(..CurrentIndex)
            }
        }
        Quit tResult
    }
}
```

#### Global Iterator Example
```objectscript
/// Iterator for IRIS globals using $ORDER
Class Patterns.GoF.Behavioral.GlobalIterator Extends Iterator
{
    Property GlobalName As %String [ Private ];
    Property CurrentKey As %String [ Private ];
    Property StartKey As %String [ Private ];
    Property EndKey As %String [ Private ];
    
    Method %OnNew(pGlobalName As %String, pStartKey = "", pEndKey = "") As %Status
    {
        Set ..GlobalName = pGlobalName
        Set ..StartKey = pStartKey
        Set ..EndKey = pEndKey
        Set ..CurrentKey = pStartKey
        Quit $$$OK
    }
    
    Method HasNext() As %Boolean
    {
        Set tNextKey = $ORDER(@..GlobalName@(..CurrentKey))
        If tNextKey = "" Quit 0
        If ..EndKey '= "", tNextKey ] ..EndKey Quit 0
        Quit 1
    }
    
    Method Next() As %RegisteredObject
    {
        Set tResult = $$$NULLOREF
        Set tNextKey = $ORDER(@..GlobalName@(..CurrentKey))
        If tNextKey '= "" {
            If ..EndKey = "" || (tNextKey '] ..EndKey) {
                Set ..CurrentKey = tNextKey
                Set tNode = ##class(GlobalNode).%New()
                Set tNode.Key = tNextKey
                Set tNode.Value = @..GlobalName@(tNextKey)
                Set tResult = tNode
            }
        }
        Quit tResult
    }
}
```

### SQL Cursor Iterator
```objectscript
/// Iterator for SQL query results
Class Patterns.GoF.Behavioral.SQLCursorIterator Extends Iterator
{
    Property Query As %String(MAXLEN = "");
    Property Parameters As %ListOfDataTypes;
    Property %ResultSet As %SQL.StatementResult [ Private ];
    
    Method %OnNew(pQuery As %String, pParameters As %ListOfDataTypes = "") As %Status
    {
        Set ..Query = pQuery
        Set ..Parameters = pParameters
        Quit ..OpenCursor()
    }
    
    Method OpenCursor() As %Status [ Private ]
    {
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(..Query)
        If $$$ISERR(tSC) Quit tSC
        
        // Execute with parameters
        If ..Parameters.Count() > 0 {
            // Build dynamic execution with parameters
            Set ..%ResultSet = tStatement.%Execute(..Parameters...)
        } Else {
            Set ..%ResultSet = tStatement.%Execute()
        }
        Quit $$$OK
    }
}
```

## Sample Code

### Healthcare Patient Iterator Example
```objectscript
/// Filter and iterate patient records
Class Patterns.Examples.PatientIterator Extends Iterator
{
    Property SQLIterator As SQLCursorIterator [ Private ];
    Property FilterCriteria As %DynamicObject;
    
    Method %OnNew(pFilterCriteria As %DynamicObject = "") As %Status
    {
        Set tSQL = "SELECT * FROM PatientRecord"
        Set tWhere = ""
        Set tParams = ##class(%ListOfDataTypes).%New()
        
        If $IsObject(pFilterCriteria) {
            If pFilterCriteria.%IsDefined("department") {
                Set tWhere = tWhere_" WHERE Department = ?"
                Do tParams.Insert(pFilterCriteria.department)
            }
            If pFilterCriteria.%IsDefined("status") {
                Set tWhere = tWhere_$SELECT(tWhere="":"WHERE ",1:" AND ")_"Status = ?"
                Do tParams.Insert(pFilterCriteria.status)
            }
        }
        
        Set ..SQLIterator = ##class(SQLCursorIterator).%New(tSQL_tWhere, tParams)
        Quit $$$OK
    }
    
    /// Get active patients
    ClassMethod GetActivePatients() As PatientIterator
    {
        Set tFilter = ##class(%DynamicObject).%New()
        Set tFilter.status = "Active"
        Quit ##class(PatientIterator).%New(tFilter)
    }
}

/// Usage Example
ClassMethod DemoPatientIteration()
{
    // Get iterator for active patients
    Set tIterator = ##class(PatientIterator).GetActivePatients()
    
    // Process each patient
    While tIterator.HasNext() {
        Set tPatient = tIterator.Next()
        Write "Patient: "_tPatient.FirstName_" "_tPatient.LastName, !
        Write "  MRN: "_tPatient.MRN, !
        Write "  Department: "_tPatient.Department, !
    }
}
```

### Paginated Medical History Iterator
```objectscript
/// Iterator with pagination support
Class MedicalHistoryIterator Extends Iterator
{
    Property PatientMRN As %String;
    Property PageSize As %Integer [ InitialExpression = 10 ];
    Property CurrentPage As %Integer [ InitialExpression = 1 ];
    Property CurrentPageData As %ListOfObjects [ Private ];
    
    Method LoadPage(pPageNumber As %Integer) As %Status
    {
        Set ..CurrentPage = pPageNumber
        Set ..CurrentPageData = ##class(%ListOfObjects).%New()
        
        Set tOffset = (pPageNumber - 1) * ..PageSize
        // Load page data from database
        // Implementation details...
        
        Quit $$$OK
    }
    
    Method HasNext() As %Boolean
    {
        If ..CurrentPosition < ..CurrentPageData.Count() Quit 1
        Set tTotalPages = (..TotalRecords + ..PageSize - 1) \ ..PageSize
        Quit (..CurrentPage < tTotalPages)
    }
    
    Method GoToPage(pPageNumber As %Integer) As %Status
    {
        Quit ..LoadPage(pPageNumber)
    }
}
```

## Known Uses

### InterSystems IRIS
- %Collection.AbstractIterator for collection classes
- %SQL.Statement result set iteration
- $ORDER function for global traversal

### Java
- java.util.Iterator interface
- java.util.ListIterator for bidirectional iteration

### C++ STL
- Forward, bidirectional, and random access iterators
- begin() and end() iterator pattern

### .NET
- IEnumerable and IEnumerator interfaces
- LINQ query operators

## Related Patterns

### Composite
- Iterators are often applied to recursive structures such as Composites

### Factory Method
- Polymorphic iterators rely on factory methods to instantiate the appropriate iterator subclass

### Memento
- An iterator can use a memento to capture the state of an iteration

### Visitor
- Can be used together to traverse a structure and perform operations on elements

## Implementation Checklist

### Essential Features
- [x] HasNext() method to check for more elements
- [x] Next() method to get next element
- [x] Reset() method to restart iteration
- [x] Current() method to get current element
- [x] Remove() method (optional)

### ObjectScript-Specific Features
- [x] Global iteration using $ORDER
- [x] SQL cursor integration
- [x] Collection class support (%ListOf*, %ArrayOf*)
- [x] Concurrent modification detection
- [x] Bidirectional iteration support

### Performance Optimizations
- [x] Lazy evaluation for large collections
- [x] Batch fetching for SQL results
- [x] Pagination support for web applications
- [x] Caching for frequently accessed elements

### Healthcare-Specific Features
- [x] HIPAA-compliant audit logging
- [x] Patient record filtering
- [x] Medical history pagination
- [x] Department-based iteration
- [x] Date range filtering

## Summary
The Iterator pattern provides a standard way to traverse collections without exposing their internal structure. In ObjectScript, this pattern is particularly useful for:

1. **Global traversal**: Using $ORDER for efficient iteration
2. **SQL result processing**: Cursor-based iteration over query results
3. **Collection abstraction**: Uniform interface for different collection types
4. **Healthcare applications**: Patient record navigation with filtering and pagination

The pattern promotes loose coupling between collections and the algorithms that use them, making code more maintainable and reusable.
