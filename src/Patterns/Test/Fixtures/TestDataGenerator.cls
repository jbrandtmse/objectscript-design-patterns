/// Test data generator for unit and integration tests
/// Provides methods to generate consistent test data for various pattern tests
Class Patterns.Test.Fixtures.TestDataGenerator Extends %RegisteredObject
{

/// Random number generator seed for reproducible tests
Property Seed As %Integer [ InitialExpression = 12345 ];

/// Counter for unique ID generation
Property IDCounter As %Integer [ InitialExpression = 0 ];

/// Initialize generator with optional seed
Method %OnNew(pSeed As %Integer = "") As %Status
{
    If pSeed '= "" {
        Set ..Seed = pSeed
    }
    
    // Initialize random seed for reproducibility
    Do $SYSTEM.SQL.SetRandomSeed(..Seed)
    
    Return $$$OK
}

/// Generate test person records
/// pCount: Number of person records to generate
/// Returns: %DynamicArray of person objects
Method GeneratePersons(pCount As %Integer = 5) As %DynamicArray
{
    Set persons = []
    
    For i = 1:1:pCount {
        Set person = {}
        Set person.id = ..GetNextID()
        Set person.firstName = ..GetRandomFirstName()
        Set person.lastName = ..GetRandomLastName()
        Set person.email = person.firstName _ "." _ person.lastName _ "@test.com"
        Set person.age = ..GetRandomInteger(18, 80)
        Set person.active = ..GetRandomBoolean()
        Set person.createdAt = ..GetRandomDateTime()
        
        Do persons.%Push(person)
    }
    
    Return persons
}

/// Generate complex order graph with related entities
/// Returns: %DynamicObject containing order with items, customer, and shipping info
Method GenerateOrderGraph() As %DynamicObject
{
    Set order = {}
    
    // Generate order header
    Set order.orderId = ..GetNextID()
    Set order.orderDate = ..GetRandomDateTime()
    Set order.status = ..GetRandomOrderStatus()
    Set order.priority = ..GetRandomInteger(1, 5)
    
    // Generate customer
    Set customer = {}
    Set customer.customerId = ..GetNextID()
    Set customer.name = ..GetRandomFirstName() _ " " _ ..GetRandomLastName()
    Set customer.email = customer.name _ "@test.com"
    Set customer.creditLimit = ..GetRandomDecimal(1000, 50000)
    Set customer.customerSince = ..GetRandomDateTime(-365, -30)
    Set order.customer = customer
    
    // Generate order items
    Set items = []
    Set itemCount = ..GetRandomInteger(1, 10)
    Set totalAmount = 0
    
    For i = 1:1:itemCount {
        Set item = {}
        Set item.itemId = ..GetNextID()
        Set item.productCode = ..GetRandomProductCode()
        Set item.productName = ..GetRandomProductName()
        Set item.quantity = ..GetRandomInteger(1, 100)
        Set item.unitPrice = ..GetRandomDecimal(10, 1000)
        Set item.lineTotal = item.quantity * item.unitPrice
        Set totalAmount = totalAmount + item.lineTotal
        Do items.%Push(item)
    }
    Set order.items = items
    Set order.totalAmount = totalAmount
    
    // Generate shipping info
    Set shipping = {}
    Set shipping.addressLine1 = ..GetRandomInteger(100, 9999) _ " " _ ..GetRandomStreetName()
    Set shipping.city = ..GetRandomCity()
    Set shipping.state = ..GetRandomState()
    Set shipping.zipCode = ..GetRandomZipCode()
    Set shipping.country = "USA"
    Set shipping.shippingMethod = ..GetRandomShippingMethod()
    Set shipping.trackingNumber = ..GetRandomTrackingNumber()
    Set order.shipping = shipping
    
    Return order
}

/// Get next unique ID
Method GetNextID() As %Integer [ Private ]
{
    Set ..IDCounter = ..IDCounter + 1
    Return ..IDCounter
}

/// Generate random integer in range
Method GetRandomInteger(pMin As %Integer = 0, pMax As %Integer = 100) As %Integer
{
    Return $RANDOM(pMax - pMin + 1) + pMin
}

/// Generate random decimal in range
Method GetRandomDecimal(pMin As %Numeric = 0, pMax As %Numeric = 100) As %Numeric
{
    Set integer = ..GetRandomInteger(pMin, pMax)
    Set decimal = $RANDOM(100) / 100
    Return integer + decimal
}

/// Generate random boolean
Method GetRandomBoolean() As %Boolean
{
    Return $RANDOM(2)
}

/// Generate random string of specified length
Method GetRandomString(pLength As %Integer = 10, pCharset As %String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") As %String
{
    Set result = ""
    Set charsetLen = $LENGTH(pCharset)
    
    For i = 1:1:pLength {
        Set pos = $RANDOM(charsetLen) + 1
        Set result = result _ $EXTRACT(pCharset, pos)
    }
    
    Return result
}

/// Generate random GUID
Method GetRandomGUID() As %String
{
    Return $SYSTEM.Util.CreateGUID()
}

/// Generate random date/time within specified days from now
Method GetRandomDateTime(pDaysFromNow As %Integer = -30, pDaysToNow As %Integer = 0) As %String
{
    Set currentDate = $HOROLOG
    Set daysPart = $PIECE(currentDate, ",", 1)
    Set randomDays = ..GetRandomInteger(pDaysFromNow, pDaysToNow)
    Set newDaysPart = daysPart + randomDays
    
    // Generate random time
    Set randomTime = $RANDOM(86400)  // Seconds in a day
    
    Set randomHorolog = newDaysPart _ "," _ randomTime
    Return $ZDATETIME(randomHorolog, 3)
}

/// Generate random first name
Method GetRandomFirstName() As %String [ Private ]
{
    Set names = $LISTBUILD("John", "Jane", "Michael", "Sarah", "David", 
                           "Emma", "Robert", "Lisa", "James", "Mary",
                           "William", "Patricia", "Richard", "Jennifer", "Thomas",
                           "Linda", "Charles", "Elizabeth", "Christopher", "Barbara")
    Set index = $RANDOM($LISTLENGTH(names)) + 1
    Return $LIST(names, index)
}

/// Generate random last name
Method GetRandomLastName() As %String [ Private ]
{
    Set names = $LISTBUILD("Smith", "Johnson", "Williams", "Brown", "Jones",
                           "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
                           "Anderson", "Taylor", "Thomas", "Hernandez", "Moore",
                           "Martin", "Jackson", "Thompson", "White", "Lopez")
    Set index = $RANDOM($LISTLENGTH(names)) + 1
    Return $LIST(names, index)
}

/// Generate random street name
Method GetRandomStreetName() As %String [ Private ]
{
    Set streets = $LISTBUILD("Main St", "Oak Ave", "Elm St", "Park Blvd", "First Ave",
                            "Second St", "Third Ave", "Maple Dr", "Cedar Ln", "Pine St",
                            "Washington Ave", "Lake Dr", "Hill Rd", "Forest Ave", "River Rd")
    Set index = $RANDOM($LISTLENGTH(streets)) + 1
    Return $LIST(streets, index)
}

/// Generate random city name
Method GetRandomCity() As %String [ Private ]
{
    Set cities = $LISTBUILD("New York", "Los Angeles", "Chicago", "Houston", "Phoenix",
                           "Philadelphia", "San Antonio", "San Diego", "Dallas", "Austin",
                           "Boston", "Seattle", "Denver", "Portland", "Miami")
    Set index = $RANDOM($LISTLENGTH(cities)) + 1
    Return $LIST(cities, index)
}

/// Generate random state code
Method GetRandomState() As %String [ Private ]
{
    Set states = $LISTBUILD("NY", "CA", "TX", "FL", "IL", "PA", "OH", "GA", "NC", "MI",
                           "NJ", "VA", "WA", "AZ", "MA", "TN", "IN", "MO", "MD", "WI")
    Set index = $RANDOM($LISTLENGTH(states)) + 1
    Return $LIST(states, index)
}

/// Generate random zip code
Method GetRandomZipCode() As %String [ Private ]
{
    Return ..GetRandomInteger(10000, 99999)
}

/// Generate random product code
Method GetRandomProductCode() As %String [ Private ]
{
    Set prefix = $LISTBUILD("PRD", "ITM", "SKU", "ART", "GDS")
    Set index = $RANDOM($LISTLENGTH(prefix)) + 1
    Return $LIST(prefix, index) _ "-" _ ..GetRandomInteger(1000, 9999)
}

/// Generate random product name
Method GetRandomProductName() As %String [ Private ]
{
    Set adjectives = $LISTBUILD("Premium", "Standard", "Deluxe", "Basic", "Professional")
    Set products = $LISTBUILD("Widget", "Gadget", "Device", "Tool", "Component")
    Set adj = $RANDOM($LISTLENGTH(adjectives)) + 1
    Set prod = $RANDOM($LISTLENGTH(products)) + 1
    Return $LIST(adjectives, adj) _ " " _ $LIST(products, prod)
}

/// Generate random order status
Method GetRandomOrderStatus() As %String [ Private ]
{
    Set statuses = $LISTBUILD("Pending", "Processing", "Shipped", "Delivered", "Cancelled")
    Set index = $RANDOM($LISTLENGTH(statuses)) + 1
    Return $LIST(statuses, index)
}

/// Generate random shipping method
Method GetRandomShippingMethod() As %String [ Private ]
{
    Set methods = $LISTBUILD("Standard", "Express", "Overnight", "2-Day", "Economy")
    Set index = $RANDOM($LISTLENGTH(methods)) + 1
    Return $LIST(methods, index)
}

/// Generate random tracking number
Method GetRandomTrackingNumber() As %String [ Private ]
{
    Return "TRK" _ ..GetRandomString(12, "0123456789ABCDEF")
}

/// Generate test collection with various data types
/// pSize: Size of collection
/// Returns: %DynamicArray with mixed data types
Method GenerateTestCollection(pSize As %Integer = 10) As %DynamicArray
{
    Set collection = []
    
    For i = 1:1:pSize {
        Set type = $RANDOM(5)
        
        If type = 0 {
            Do collection.%Push(..GetRandomInteger(1, 1000))
        } ElseIf type = 1 {
            Do collection.%Push(..GetRandomString(10))
        } ElseIf type = 2 {
            Do collection.%Push(..GetRandomBoolean())
        } ElseIf type = 3 {
            Do collection.%Push(..GetRandomDecimal(1, 100))
        } Else {
            // Add nested object
            Set obj = {}
            Set obj.id = ..GetNextID()
            Set obj.value = ..GetRandomString(5)
            Do collection.%Push(obj)
        }
    }
    
    Return collection
}

/// Generate sample XML document for testing
/// Returns: XML string
Method GenerateXMLDocument() As %String
{
    Set xml = "<?xml version=""1.0"" encoding=""UTF-8""?>"
    Set xml = xml _ "<root>"
    Set xml = xml _ "<person>"
    Set xml = xml _ "<id>" _ ..GetNextID() _ "</id>"
    Set xml = xml _ "<name>" _ ..GetRandomFirstName() _ " " _ ..GetRandomLastName() _ "</name>"
    Set xml = xml _ "<email>" _ ..GetRandomString(8) _ "@test.com</email>"
    Set xml = xml _ "</person>"
    Set xml = xml _ "</root>"
    
    Return xml
}

/// Generate sample JSON document for testing
/// Returns: JSON string
Method GenerateJSONDocument() As %String
{
    Set obj = {}
    Set obj.id = ..GetNextID()
    Set obj.name = ..GetRandomFirstName() _ " " _ ..GetRandomLastName()
    Set obj.email = ..GetRandomString(8) _ "@test.com"
    Set obj.active = ..GetRandomBoolean()
    Set obj.score = ..GetRandomDecimal(0, 100)
    
    Return obj.%ToJSON()
}

/// Reset the generator to initial state
Method Reset()
{
    Set ..IDCounter = 0
    Do $SYSTEM.SQL.SetRandomSeed(..Seed)
}

}
