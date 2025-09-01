# Database Schema

### Schema Design Overview

The ObjectScript Design Patterns Library uses a minimal database schema focused on metadata, examples, and performance tracking rather than runtime data storage.

### Core Tables

**Patterns.Registry.PatternInfo**
```sql
CREATE TABLE Patterns_Registry.PatternInfo (
    ID INTEGER PRIMARY KEY,
    PatternName VARCHAR(100) NOT NULL UNIQUE,
    Category VARCHAR(50),
    PatternType VARCHAR(10) NOT NULL,
    ClassName VARCHAR(200) NOT NULL UNIQUE,
    Description VARCHAR(500),
    Intent VARCHAR(1000),
    Applicability VARCHAR(2000),
    DateAdded TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Version VARCHAR(20) DEFAULT '1.0.0'
)
```

**Patterns.Registry.PatternRelationship**
```sql
CREATE TABLE Patterns_Registry.PatternRelationship (
    ID INTEGER PRIMARY KEY,
    SourcePattern INTEGER REFERENCES Patterns_Registry.PatternInfo(ID),
    TargetPattern INTEGER REFERENCES Patterns_Registry.PatternInfo(ID),
    RelationshipType VARCHAR(50), -- 'uses', 'extends', 'similar', 'alternative'
    Description VARCHAR(500)
)
```

**Patterns.Metadata.PatternUsage**
```sql
CREATE TABLE Patterns_Metadata.PatternUsage (
    ID INTEGER PRIMARY KEY,
    Pattern INTEGER REFERENCES Patterns_Registry.PatternInfo(ID),
    UsedInClass VARCHAR(200),
    UsageType VARCHAR(20),
    UsageDescription VARCHAR(500),
    DateRecorded TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Patterns.Metadata.PerformanceMetric**
```sql
CREATE TABLE Patterns_Metadata.PerformanceMetric (
    ID INTEGER PRIMARY KEY,
    Pattern INTEGER REFERENCES Patterns_Registry.PatternInfo(ID),
    MetricName VARCHAR(100),
    Value DECIMAL(15,5),
    Unit VARCHAR(20),
    TestConditions VARCHAR(500),
    DateMeasured TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### Example Data Tables

**Patterns.Examples.Person**
```sql
CREATE TABLE Patterns_Examples.Person (
    ID INTEGER PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE,
    DateOfBirth DATE,
    Address VARCHAR(500), -- Serialized Address object
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Patterns.Examples.Order**
```sql
CREATE TABLE Patterns_Examples.Order (
    ID INTEGER PRIMARY KEY,
    OrderNumber VARCHAR(20) NOT NULL UNIQUE,
    Customer INTEGER REFERENCES Patterns_Examples.Person(ID),
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(20),
    TotalAmount DECIMAL(10,2)
)
```

**Patterns.Examples.OrderItem**
```sql
CREATE TABLE Patterns_Examples.OrderItem (
    ID INTEGER PRIMARY KEY,
    OrderID INTEGER REFERENCES Patterns_Examples.Order(ID),
    ProductName VARCHAR(100),
    Quantity INTEGER,
    UnitPrice DECIMAL(10,2),
    LineTotal DECIMAL(10,2)
)
```

### Indexes

```sql
-- Performance indexes
CREATE INDEX idx_pattern_category ON Patterns_Registry.PatternInfo(PatternType, Category);
CREATE INDEX idx_pattern_name ON Patterns_Registry.PatternInfo(PatternName);
CREATE INDEX idx_usage_pattern ON Patterns_Metadata.PatternUsage(Pattern);
CREATE INDEX idx_metric_pattern ON Patterns_Metadata.PerformanceMetric(Pattern, MetricName);
CREATE INDEX idx_person_name ON Patterns_Examples.Person(LastName, FirstName);
CREATE INDEX idx_order_customer ON Patterns_Examples.Order(Customer);
CREATE INDEX idx_order_date ON Patterns_Examples.Order(OrderDate);
```

### Database Constraints

1. **Referential Integrity** - All foreign keys enforced
2. **Unique Constraints** - Pattern names and class names must be unique
3. **Check Constraints** - Valid enum values for categories and types
4. **Not Null** - Required fields enforced at database level
5. **Cascade Rules** - Delete cascades for dependent records

### Data Retention Policy

1. **Pattern Metadata** - Permanent retention
2. **Performance Metrics** - 90-day rolling window
3. **Usage Statistics** - 180-day retention
4. **Example Data** - Refreshed with each release
5. **Test Data** - Cleared after each test run
