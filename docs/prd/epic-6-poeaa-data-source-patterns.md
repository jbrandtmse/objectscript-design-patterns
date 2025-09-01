# Epic 6: PoEAA Data Source Patterns

Implement data source architectural patterns for database interaction.

### Story 6.1: Table Data Gateway Pattern Implementation

As a developer,
I want the Table Data Gateway pattern implemented,
so that I can encapsulate database table access.

#### Acceptance Criteria
1: Table Data Gateway for CRUD operations
2: SQL queries encapsulated in gateway
3: Unit tests for data operations
4: Documentation on IRIS SQL usage
5: Healthcare example for patient data gateway

### Story 6.2: Row Data Gateway Pattern Implementation

As a developer,
I want the Row Data Gateway pattern implemented,
so that I can have one object per database row.

#### Acceptance Criteria
1: Row Data Gateway with instance per row
2: Finder methods for row retrieval
3: Unit tests for row operations
4: Documentation on ObjectScript persistence
5: Healthcare example for individual patient records

### Story 6.3: Active Record Pattern Implementation

As a developer,
I want the Active Record pattern implemented,
so that domain objects handle their own persistence.

#### Acceptance Criteria
1: Active Record with business logic and data access
2: CRUD methods on domain objects
3: Unit tests for active record operations
4: Documentation on %Persistent class usage
5: Healthcare example for self-persisting patient class

### Story 6.4: Data Mapper Pattern Implementation

As a developer,
I want the Data Mapper pattern implemented,
so that I can separate domain objects from database.

#### Acceptance Criteria
1: Data Mapper handling object-relational mapping
2: Complete separation of domain and persistence
3: Unit tests for mapping operations
4: Documentation on complex mapping scenarios
5: Healthcare example for clinical data mapping

### Story 6.5: Unit of Work Pattern Implementation

As a developer,
I want the Unit of Work pattern implemented,
so that I can track changes and coordinate updates.

#### Acceptance Criteria
1: Unit of Work tracking object changes
2: Batch database updates supported
3: Unit tests for change tracking
4: Documentation on transaction optimization
5: Healthcare example for clinical documentation updates
