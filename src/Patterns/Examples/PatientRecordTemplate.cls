/// Base class for patient record templates using the Prototype pattern.
/// <p>Provides template-based creation of patient records with cloning capabilities
/// for efficient creation of similar patient records.</p>
Class Patterns.Examples.PatientRecordTemplate Extends (Patterns.GoF.Creational.Prototype, %Persistent)
{

/// Patient identifier
Property PatientID As %String;

/// Type of admission (e.g., "Emergency", "Scheduled", "Walk-in")
Property AdmissionType As %String;

/// List of required tests for this type of patient
Property RequiredTests As list Of %String;

/// Default medications for this patient type
Property DefaultMedications As list Of %String;

/// Priority level (1-5, with 1 being highest priority)
Property PriorityLevel As %Integer;

/// Department assignment
Property Department As %String;

/// Template name for identification
Property TemplateName As %String;

/// Constructor - initialize patient record template
Method %OnNew(initvalue As %String = "") As %Status
{
    // Initialize collections
    If '..RequiredTests.%Extends("%Collection.AbstractList") {
        Set ..RequiredTests = ##class(%ListOfDataTypes).%New()
    }
    If '..DefaultMedications.%Extends("%Collection.AbstractList") {
        Set ..DefaultMedications = ##class(%ListOfDataTypes).%New()
    }
    
    Quit $$$OK
}

/// Implementation of Clone method using shallow copy
Method Clone() As Patterns.GoF.Creational.Prototype
{
    Set clone = ..%ConstructClone()
    If $IsObject(clone) {
        Do clone.InitializeAfterClone()
    }
    Quit clone
}

/// Implementation of DeepClone method using serialization
Method DeepClone() As Patterns.GoF.Creational.Prototype
{
    // Use serialization for deep cloning
    Set stream = ##class(%Stream.GlobalCharacter).%New()
    Do ..%SerializeObject(stream)
    Do stream.Rewind()
    
    Set clone = ..%New()
    Do clone.%DeserializeObject(stream)
    
    // Deep clone the collections
    Set clone.RequiredTests = ##class(%ListOfDataTypes).%New()
    Set key = ""
    For {
        Set test = ..RequiredTests.GetNext(.key)
        Quit:key=""
        Do clone.RequiredTests.Insert(test)
    }
    
    Set clone.DefaultMedications = ##class(%ListOfDataTypes).%New()
    Set key = ""
    For {
        Set med = ..DefaultMedications.GetNext(.key)
        Quit:key=""
        Do clone.DefaultMedications.Insert(med)
    }
    
    Do clone.InitializeAfterClone()
    Quit clone
}

/// Initialize common properties
Method InitializeCommon() [ Private ]
{
    Set ..PatientID = ""
    Set ..AdmissionType = ""
    Set ..PriorityLevel = 3
    Set ..Department = ""
    Set ..TemplateName = ""
}

/// Set template values for testing
Method SetTemplateValues(pName As %String, pAdmissionType As %String, pPriority As %Integer, pDept As %String)
{
    Set ..TemplateName = pName
    Set ..AdmissionType = pAdmissionType
    Set ..PriorityLevel = pPriority
    Set ..Department = pDept
}

/// Add a required test to the template
Method AddRequiredTest(pTest As %String)
{
    Do ..RequiredTests.Insert(pTest)
}

/// Add a default medication to the template
Method AddDefaultMedication(pMedication As %String)
{
    Do ..DefaultMedications.Insert(pMedication)
}

}
