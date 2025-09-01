# Data Models

### Core Data Structure Overview

The ObjectScript Design Patterns Library uses a hybrid approach combining registered classes for pattern implementations with persistent classes for metadata and examples.

### Pattern Registry Model

**Patterns.Registry.PatternInfo (Persistent)**
```objectscript
Class Patterns.Registry.PatternInfo Extends %Persistent
{
    Property PatternName As %String(MAXLEN = 100) [ Required ];
    Property Category As %String(VALUELIST = ",Creational,Structural,Behavioral,DataSource,DomainLogic,ObjectRelational,WebPresentation,Distribution,Offline,Session,Base");
    Property PatternType As %String(VALUELIST = ",GoF,PoEAA") [ Required ];
    Property ClassName As %String(MAXLEN = 200) [ Required ];
    Property Description As %String(MAXLEN = 500);
    Property Intent As %String(MAXLEN = 1000);
    Property Applicability As %String(MAXLEN = 2000);
    Property KnownUses As list of %String;
    Property RelatedPatterns As list of Patterns.Registry.PatternInfo;
    Property DateAdded As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];
    Property Version As %String [ InitialExpression = {"1.0.0"} ];
    
    Index NameIndex On PatternName [ Unique ];
    Index CategoryIndex On (PatternType, Category);
    Index ClassIndex On ClassName [ Unique ];
}
```

### Example Data Models

**Patterns.Examples.Person (Persistent)**
```objectscript
Class Patterns.Examples.Person Extends %Persistent
{
    Property FirstName As %String(MAXLEN = 50);
    Property LastName As %String(MAXLEN = 50);
    Property Email As %String(MAXLEN = 100);
    Property DateOfBirth As %Date;
    Property Address As Patterns.Examples.Address;
    Property PhoneNumbers As list of Patterns.Examples.PhoneNumber;
    
    Index NameIndex On (LastName, FirstName);
    Index EmailIndex On Email [ Unique ];
}
```

**Patterns.Examples.Address (Serial)**
```objectscript
Class Patterns.Examples.Address Extends %SerialObject
{
    Property Street As %String(MAXLEN = 100);
    Property City As %String(MAXLEN = 50);
    Property State As %String(MAXLEN = 2);
    Property ZipCode As %String(MAXLEN = 10);
    Property Country As %String(MAXLEN = 50);
}
```

**Patterns.Examples.Order (Persistent)**
```objectscript
Class Patterns.Examples.Order Extends %Persistent
{
    Property OrderNumber As %String(MAXLEN = 20) [ Required ];
    Property Customer As Patterns.Examples.Person;
    Property OrderDate As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];
    Property Status As %String(VALUELIST = ",Pending,Processing,Shipped,Delivered,Cancelled");
    Property Items As list of Patterns.Examples.OrderItem;
    Property TotalAmount As %Decimal(SCALE = 2);
    
    Index OrderNumberIndex On OrderNumber [ Unique ];
    Index CustomerIndex On Customer;
    Index DateIndex On OrderDate;
}
```

### Pattern Metadata Models

**Patterns.Metadata.PatternUsage (Persistent)**
```objectscript
Class Patterns.Metadata.PatternUsage Extends %Persistent
{
    Property Pattern As Patterns.Registry.PatternInfo;
    Property UsedInClass As %String(MAXLEN = 200);
    Property UsageType As %String(VALUELIST = ",Example,Test,Production");
    Property UsageDescription As %String(MAXLEN = 500);
    Property DateRecorded As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];
    
    Index PatternIndex On Pattern;
    Index ClassIndex On UsedInClass;
}
```

**Patterns.Metadata.PerformanceMetric (Persistent)**
```objectscript
Class Patterns.Metadata.PerformanceMetric Extends %Persistent
{
    Property Pattern As Patterns.Registry.PatternInfo;
    Property MetricName As %String(MAXLEN = 100);
    Property Value As %Decimal;
    Property Unit As %String(MAXLEN = 20);
    Property TestConditions As %String(MAXLEN = 500);
    Property DateMeasured As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];
    
    Index PatternMetricIndex On (Pattern, MetricName);
}
```

### Global Structures

**Pattern Registry Global (^Patterns.Registry)**
```
^Patterns.Registry = <total pattern count>
^Patterns.Registry("GoF", "Creational", "Singleton") = "Patterns.GoF.Creational.Singleton"
^Patterns.Registry("GoF", "Creational", "Factory") = "Patterns.GoF.Creational.Factory"
^Patterns.Registry("PoEAA", "DataSource", "TableDataGateway") = "Patterns.PoEAA.DataSource.TableDataGateway"
```

**Pattern Dependencies Global (^Patterns.Dependencies)**
```
^Patterns.Dependencies("Patterns.GoF.Structural.Composite") = 2
^Patterns.Dependencies("Patterns.GoF.Structural.Composite", 1) = "Patterns.GoF.Behavioral.Iterator"
^Patterns.Dependencies("Patterns.GoF.Structural.Composite", 2) = "Patterns.GoF.Behavioral.Visitor"
```

**Configuration Global (^Patterns.Config)**
```
^Patterns.Config("Version") = "1.0.0"
^Patterns.Config("Debug") = 0
^Patterns.Config("LogLevel") = "INFO"
^Patterns.Config("TestMode") = 0
```

### Data Access Patterns

1. **Repository Pattern** - Each major entity has a repository class for data access
2. **Data Mapper** - Separates domain logic from data access logic
3. **Unit of Work** - Tracks changes and coordinates writing to database
4. **Query Object** - Encapsulates database queries as objects
5. **Lazy Loading** - Delays loading of related objects until needed

### Data Validation Rules

1. **Pattern Names** - Must be unique, PascalCase, match class name suffix
2. **Class Names** - Must follow Patterns.{Type}.{Category}.{PatternName} convention
3. **Dates** - All timestamps in UTC, stored as %TimeStamp
4. **Version Numbers** - Semantic versioning (MAJOR.MINOR.PATCH)
5. **Status Values** - Restricted to defined VALUELIST options
