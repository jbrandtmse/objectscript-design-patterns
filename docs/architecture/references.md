# References
- [1] Design Patterns: Elements of Reusable Object-Oriented Software
- [2] Patterns of Enterprise Application Architecture
```

### API Documentation Generation

**Documentation Generator Class:**
```objectscript
Class Patterns.Utils.DocGenerator Extends %RegisteredObject
{
    /// Generate HTML documentation for all patterns
    ClassMethod GenerateAPIDocs(pOutputDir As %String = "/docs/api") As %Status
    {
        Set sc = $$$OK
        
        // Create index page
        Set sc = ..GenerateIndexPage(pOutputDir)
        If $$$ISERR(sc) Return sc
        
        // Generate documentation for each pattern
        Set patterns = ##class(Patterns.Registry.Manager).GetAllPatterns()
        Set iter = patterns.%GetIterator()
        
        While iter.%GetNext(.key, .patternClass) {
            Set sc = ..GeneratePatternDoc(patternClass, pOutputDir)
            If $$$ISERR(sc) Return sc
        }
        
        // Generate search index
        Set sc = ..GenerateSearchIndex(pOutputDir)
        
        Return sc
    }
    
    /// Generate documentation for a single pattern
    ClassMethod GeneratePatternDoc(pClassName As %String, pOutputDir As %String) As %Status
    {
        Set doc = ##class(%Stream.FileCharacter).%New()
        Set doc.Filename = pOutputDir _ "/" _ $REPLACE(pClassName, ".", "/") _ ".html"
        
        // HTML header
        Do doc.WriteLine("<!DOCTYPE html>")
        Do doc.WriteLine("<html><head>")
        Do doc.WriteLine("<title>" _ pClassName _ " - ObjectScript Patterns</title>")
        Do doc.WriteLine("<link rel='stylesheet' href='/assets/style.css'>")
        Do doc.WriteLine("</head><body>")
        
        // Class documentation
        Do doc.WriteLine("<h1>" _ pClassName _ "</h1>")
        
        // Get class definition
        Set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(pClassName)
        If $IsObject(classDef) {
            Do doc.WriteLine("<div class='description'>" _ classDef.Description _ "</div>")
            
            // Document methods
            Do doc.WriteLine("<h2>Methods</h2>")
            Set key = ""
            For {
                Set method = classDef.Methods.GetNext(.key)
                Quit:key=""
                
                Do doc.WriteLine("<div class='method'>")
                Do doc.WriteLine("<h3>" _ method.Name _ "</h3>")
                Do doc.WriteLine("<p>" _ method.Description _ "</p>")
                Do doc.WriteLine("<pre class='signature'>" _ ..GetMethodSignature(method) _ "</pre>")
                Do doc.WriteLine("</div>")
            }
            
            // Document properties
            Do doc.WriteLine("<h2>Properties</h2>")
            Set key = ""
            For {
                Set prop = classDef.Properties.GetNext(.key)
                Quit:key=""
                
                Do doc.WriteLine("<div class='property'>")
                Do doc.WriteLine("<h3>" _ prop.Name _ "</h3>")
                Do doc.WriteLine("<p>Type: " _ prop.Type _ "</p>")
                Do doc.WriteLine("<p>" _ prop.Description _ "</p>")
                Do doc.WriteLine("</div>")
            }
        }
        
        // HTML footer
        Do doc.WriteLine("</body></html>")
        
        Return doc.%Save()
    }
}
```

### Documentation Comments Standard

**Class Documentation:**
```objectscript
/// <SHORT>Gang of Four Singleton Pattern</SHORT>
/// <DESCRIPTION>
/// The Singleton pattern ensures a class has only one instance
/// and provides a global point of access to it.
/// </DESCRIPTION>
/// <EXAMPLE>
/// Set instance = ##class(Patterns.GoF.Creational.Singleton).GetInstance()
/// </EXAMPLE>
/// <KEYWORDS>Singleton,Creational,GoF</KEYWORDS>
Class Patterns.GoF.Creational.Singleton
```

**Method Documentation:**
```objectscript
/// <METHOD>GetInstance</METHOD>
/// <DESCRIPTION>
/// Returns the single instance of the Singleton class.
/// Creates the instance if it doesn't exist.
/// </DESCRIPTION>
/// <RETURNVALUE>
/// The singleton instance
/// </RETURNVALUE>
/// <EXAMPLE>
/// Set singleton = ##class(Singleton).GetInstance()
/// </EXAMPLE>
ClassMethod GetInstance() As Singleton
```

### User Guide Structure

**Getting Started Guide:**
```markdown