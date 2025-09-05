/// Healthcare Example - FHIR Patient Resource
/// 
/// Concrete implementation of FHIRResource for Patient resources
/// Represents patient demographics and identification information in FHIR format
/// 
/// @see Patterns.Examples.FHIRResource
/// @see Patterns.Examples.HL7ToFHIRAdapter
/// @since 1.0.0
Class Patterns.Examples.FHIRPatient Extends Patterns.Examples.FHIRResource
{

// ===== PROPERTIES =====

/// Patient medical record number
Property MRN As %String;

/// Patient full name
Property FullName As %String;

/// Given name (first name)
Property GivenName As %String;

/// Family name (last name)
Property FamilyName As %String;

/// Date of birth
Property BirthDate As %String;

/// Gender (male, female, other, unknown)
Property Gender As %String;

/// Phone number
Property Phone As %String;

/// Email address
Property Email As %String;

/// Street address
Property Street As %String;

/// City
Property City As %String;

/// State or Province
Property State As %String;

/// Postal code
Property PostalCode As %String;

/// Country
Property Country As %String;

// ===== CONSTRUCTORS =====

/// Initialize FHIR Patient resource
Method %OnNew() As %Status
{
    Set tSC = ##super("Patient")
    Quit tSC
}

// ===== IMPLEMENTED ABSTRACT METHODS =====

/// Convert patient to FHIR JSON representation
Method ToJSON() As %DynamicObject
{
    Set tJSON = {}
    
    // Set resource type and ID
    Set tJSON.resourceType = "Patient"
    Set tJSON.id = ..ResourceID
    
    // Add metadata
    Set tJSON.meta = {}
    Set tJSON.meta.lastUpdated = ..LastUpdated
    Set tJSON.meta.versionId = ..Version
    
    // Add identifiers (MRN)
    If ..MRN '= "" {
        Set tJSON.identifier = []
        Set tIdentifier = {}
        Set tIdentifier.use = "official"
        Set tIdentifier.type = {}
        Set tIdentifier.type.coding = []
        Set tCoding = {}
        Set tCoding.system = "http://terminology.hl7.org/CodeSystem/v2-0203"
        Set tCoding.code = "MR"
        Set tCoding.display = "Medical record number"
        Do tIdentifier.type.coding.%Push(tCoding)
        Set tIdentifier.value = ..MRN
        Do tJSON.identifier.%Push(tIdentifier)
    }
    
    // Add name
    If (..GivenName '= "") || (..FamilyName '= "") {
        Set tJSON.name = []
        Set tName = {}
        Set tName.use = "official"
        If ..FamilyName '= "" Set tName.family = ..FamilyName
        If ..GivenName '= "" {
            Set tName.given = []
            Do tName.given.%Push(..GivenName)
        }
        If ..FullName '= "" Set tName.text = ..FullName
        Do tJSON.name.%Push(tName)
    }
    
    // Add gender
    If ..Gender '= "" {
        Set tJSON.gender = ..Gender
    }
    
    // Add birth date
    If ..BirthDate '= "" {
        Set tJSON.birthDate = ..BirthDate
    }
    
    // Add telecom (phone and email)
    Set tJSON.telecom = []
    If ..Phone '= "" {
        Set tPhone = {}
        Set tPhone.system = "phone"
        Set tPhone.value = ..Phone
        Set tPhone.use = "home"
        Do tJSON.telecom.%Push(tPhone)
    }
    If ..Email '= "" {
        Set tEmail = {}
        Set tEmail.system = "email"
        Set tEmail.value = ..Email
        Set tEmail.use = "home"
        Do tJSON.telecom.%Push(tEmail)
    }
    
    // Add address
    If (..Street '= "") || (..City '= "") || (..State '= "") || (..PostalCode '= "") {
        Set tJSON.address = []
        Set tAddress = {}
        Set tAddress.use = "home"
        If ..Street '= "" {
            Set tAddress.line = []
            Do tAddress.line.%Push(..Street)
        }
        If ..City '= "" Set tAddress.city = ..City
        If ..State '= "" Set tAddress.state = ..State
        If ..PostalCode '= "" Set tAddress.postalCode = ..PostalCode
        If ..Country '= "" Set tAddress.country = ..Country
        Do tJSON.address.%Push(tAddress)
    }
    
    Quit tJSON
}

/// Validate patient resource against FHIR specifications
Method Validate() As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Basic validation rules
        If ..ResourceType '= "Patient" {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
                $$$ERROR($$$GeneralError, "Invalid resource type for Patient"))
        }
        
        // Validate gender if specified
        If ..Gender '= "" {
            Set tValidGenders = ",male,female,other,unknown,"
            If tValidGenders '[ (","_$ZCONVERT(..Gender, "L")_",") {
                Throw ##class(%Exception.StatusException).CreateFromStatus(
                    $$$ERROR($$$GeneralError, "Invalid gender value: "_..Gender))
            }
        }
        
        // Validate birth date format if specified (YYYY-MM-DD)
        If ..BirthDate '= "" {
            If '..BirthDate?4N1"-"2N1"-"2N {
                Throw ##class(%Exception.StatusException).CreateFromStatus(
                    $$$ERROR($$$GeneralError, "Invalid birth date format (expected YYYY-MM-DD): "_..BirthDate))
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Get patient summary
Method GetSummary() As %String
{
    Set tSummary = "Patient: "
    
    If ..FullName '= "" {
        Set tSummary = tSummary _ ..FullName
    } ElseIf (..GivenName '= "") || (..FamilyName '= "") {
        Set tSummary = tSummary _ ..GivenName _ " " _ ..FamilyName
    }
    
    If ..MRN '= "" {
        Set tSummary = tSummary _ " (MRN: " _ ..MRN _ ")"
    }
    
    If ..BirthDate '= "" {
        Set tSummary = tSummary _ ", DOB: " _ ..BirthDate
    }
    
    If ..Gender '= "" {
        Set tSummary = tSummary _ ", Gender: " _ ..Gender
    }
    
    Quit tSummary
}

// ===== PUBLIC METHODS =====

/// Set patient data from HL7 PID segment
Method SetFromPIDSegment(pPIDSegment As %String) As %Status
{
    Set tSC = $$$OK
    
    Try {
        // Parse PID segment fields (pipe-delimited)
        // PID|1|MRN|...|Name|...|DOB|Sex|...
        
        // Field 3: Patient ID (MRN)
        // The MRN field may be in format: MRN^^^System^Type
        Set tMRNField = $PIECE(pPIDSegment, "|", 4)
        If tMRNField '= "" {
            // Extract just the MRN number part
            Set ..MRN = $PIECE(tMRNField, "^", 1)
        }
        
        // Field 5: Patient Name (last^first^middle)
        Set tName = $PIECE(pPIDSegment, "|", 6)
        If tName '= "" {
            Set ..FamilyName = $PIECE(tName, "^", 1)
            Set ..GivenName = $PIECE(tName, "^", 2)
            Set ..FullName = ..GivenName _ " " _ ..FamilyName
        }
        
        // Field 7: Date of Birth (YYYYMMDD -> YYYY-MM-DD)
        Set tDOB = $PIECE(pPIDSegment, "|", 8)
        If tDOB '= "" {
            If $LENGTH(tDOB) = 8 {
                Set ..BirthDate = $EXTRACT(tDOB, 1, 4) _ "-" _ 
                                 $EXTRACT(tDOB, 5, 6) _ "-" _ 
                                 $EXTRACT(tDOB, 7, 8)
            }
        }
        
        // Field 8: Gender
        Set tGender = $PIECE(pPIDSegment, "|", 9)
        If tGender '= "" {
            Set ..Gender = $CASE(tGender,
                "M":"male",
                "F":"female",
                "O":"other",
                "U":"unknown",
                :"unknown")
        }
        
        // Field 11: Patient Address
        Set tAddress = $PIECE(pPIDSegment, "|", 12)
        If tAddress '= "" {
            Set ..Street = $PIECE(tAddress, "^", 1)
            Set ..City = $PIECE(tAddress, "^", 3)
            Set ..State = $PIECE(tAddress, "^", 4)
            Set ..PostalCode = $PIECE(tAddress, "^", 5)
            Set ..Country = $PIECE(tAddress, "^", 6)
        }
        
        // Field 13: Home Phone
        Set ..Phone = $PIECE(pPIDSegment, "|", 14)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    
    Quit tSC
}

/// Create sample patient for testing
ClassMethod CreateSamplePatient() As Patterns.Examples.FHIRPatient
{
    Set tPatient = ##class(Patterns.Examples.FHIRPatient).%New()
    
    Set tPatient.MRN = "MRN123456"
    Set tPatient.GivenName = "John"
    Set tPatient.FamilyName = "Doe"
    Set tPatient.FullName = "John Doe"
    Set tPatient.BirthDate = "1980-05-15"
    Set tPatient.Gender = "male"
    Set tPatient.Phone = "555-123-4567"
    Set tPatient.Email = "john.doe@example.com"
    Set tPatient.Street = "123 Main Street"
    Set tPatient.City = "Boston"
    Set tPatient.State = "MA"
    Set tPatient.PostalCode = "02101"
    Set tPatient.Country = "USA"
    
    Quit tPatient
}

}
