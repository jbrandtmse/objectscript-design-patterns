/// Unit test class for Gang of Four Abstract Factory Pattern
/// Tests factory creation, product families, and compatibility
Class Patterns.Test.Unit.GoF.Creational.AbstractFactoryTest Extends %UnitTest.TestCase
{

/// Constructor - properly handle initvalue parameter from parent
Method %OnNew(initvalue As %String = "") As %Status
{
    // Call parent constructor with initvalue parameter - REQUIRED
    Set tSC = ##super(initvalue)
    If $$$ISERR(tSC) Quit tSC
    
    Quit $$$OK
}

/// Test creation of Factory 1 (Modern style) products
Method TestFactory1ProductCreation()
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Create Factory 1 (Modern style)
    Set factory1 = ##class(Patterns.GoF.Creational.ConcreteFactory1).%New()
    Do $$$AssertTrue($ISOBJECT(factory1), "Factory1 created successfully")
    
    // Create products from Factory 1
    Set productA1 = factory1.CreateProductA()
    Set productB1 = factory1.CreateProductB()
    
    Do $$$AssertTrue($ISOBJECT(productA1), "ProductA1 created from Factory1")
    Do $$$AssertTrue($ISOBJECT(productB1), "ProductB1 created from Factory1")
    
    // Verify product descriptions
    Set descA1 = productA1.GetDescription()
    Do $$$AssertTrue(descA1 [ "Modern", "ProductA1 has Modern style in description")
    
    Set descB1 = productB1.GetDescription()
    Do $$$AssertTrue(descB1 [ "Modern", "ProductB1 has Modern style in description")
    
    // Verify product families
    Set familyA1 = productA1.GetProductFamily()
    Do $$$AssertEquals(familyA1, "1", "ProductA1 belongs to Family 1")
    
    Set familyB1 = productB1.GetProductFamily()
    Do $$$AssertEquals(familyB1, "1", "ProductB1 belongs to Family 1")
    
    // Debug output
    Set ^ClineDebug = ^ClineDebug _ "Factory1 test complete; "
}

/// Test creation of Factory 2 (Classic style) products
Method TestFactory2ProductCreation()
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Create Factory 2 (Classic style)
    Set factory2 = ##class(Patterns.GoF.Creational.ConcreteFactory2).%New()
    Do $$$AssertTrue($ISOBJECT(factory2), "Factory2 created successfully")
    
    // Create products from Factory 2
    Set productA2 = factory2.CreateProductA()
    Set productB2 = factory2.CreateProductB()
    
    Do $$$AssertTrue($ISOBJECT(productA2), "ProductA2 created from Factory2")
    Do $$$AssertTrue($ISOBJECT(productB2), "ProductB2 created from Factory2")
    
    // Verify product descriptions
    Set descA2 = productA2.GetDescription()
    Do $$$AssertTrue(descA2 [ "Classic", "ProductA2 has Classic style in description")
    
    Set descB2 = productB2.GetDescription()
    Do $$$AssertTrue(descB2 [ "Classic", "ProductB2 has Classic style in description")
    
    // Verify product families
    Set familyA2 = productA2.GetProductFamily()
    Do $$$AssertEquals(familyA2, "2", "ProductA2 belongs to Family 2")
    
    Set familyB2 = productB2.GetProductFamily()
    Do $$$AssertEquals(familyB2, "2", "ProductB2 belongs to Family 2")
    
    // Debug output
    Set ^ClineDebug = ^ClineDebug _ "Factory2 test complete; "
}

/// Test that products from the same factory work together
Method TestSameFactoryCompatibility()
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Create Factory 1 and its products
    Set factory1 = ##class(Patterns.GoF.Creational.ConcreteFactory1).%New()
    Set productA1 = factory1.CreateProductA()
    Set productB1 = factory1.CreateProductB()
    
    // Test compatibility - products from same factory should be compatible
    Set isCompatible = productB1.IsCompatibleWith(productA1)
    Do $$$AssertTrue(isCompatible, "ProductB1 is compatible with ProductA1 (same factory)")
    
    // Test interaction - should succeed for compatible products
    Set tSC = productB1.InteractWithProductA(productA1)
    Do $$$AssertStatusOK(tSC, "ProductB1 successfully interacts with ProductA1")
    
    // Create Factory 2 and its products
    Set factory2 = ##class(Patterns.GoF.Creational.ConcreteFactory2).%New()
    Set productA2 = factory2.CreateProductA()
    Set productB2 = factory2.CreateProductB()
    
    // Test compatibility - products from same factory should be compatible
    Set isCompatible = productB2.IsCompatibleWith(productA2)
    Do $$$AssertTrue(isCompatible, "ProductB2 is compatible with ProductA2 (same factory)")
    
    // Test interaction - should succeed for compatible products
    Set tSC = productB2.InteractWithProductA(productA2)
    Do $$$AssertStatusOK(tSC, "ProductB2 successfully interacts with ProductA2")
    
    // Debug output
    Set ^ClineDebug = ^ClineDebug _ "Same factory compatibility test complete; "
}

/// Test that products from different factories are incompatible
Method TestDifferentFactoryIncompatibility()
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Create products from different factories
    Set factory1 = ##class(Patterns.GoF.Creational.ConcreteFactory1).%New()
    Set productA1 = factory1.CreateProductA()
    
    Set factory2 = ##class(Patterns.GoF.Creational.ConcreteFactory2).%New()
    Set productB2 = factory2.CreateProductB()
    
    // Test compatibility - products from different factories should be incompatible
    Set isCompatible = productB2.IsCompatibleWith(productA1)
    Do $$$AssertTrue('isCompatible, "ProductB2 is not compatible with ProductA1 (different factories)")
    
    // Test interaction - should fail for incompatible products
    Set tSC = productB2.InteractWithProductA(productA1)
    Do $$$AssertTrue($$$ISERR(tSC), "Should return error status for incompatible products")
    
    // Test opposite direction
    Set productA2 = factory2.CreateProductA()
    Set productB1 = factory1.CreateProductB()
    
    Set isCompatible = productB1.IsCompatibleWith(productA2)
    Do $$$AssertTrue('isCompatible, "ProductB1 is not compatible with ProductA2 (different factories)")
    
    // Debug output
    Set ^ClineDebug = ^ClineDebug _ "Different factory incompatibility test complete; "
}

/// Test factory demonstration method
Method TestFactoryDemonstration()
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Test Factory 1 demonstration
    Set factory1 = ##class(Patterns.GoF.Creational.ConcreteFactory1).%New()
    Set tSC = factory1.DemonstrateProductFamily()
    Do $$$AssertStatusOK(tSC, "Factory1 demonstration executed successfully")
    
    // Test Factory 2 demonstration
    Set factory2 = ##class(Patterns.GoF.Creational.ConcreteFactory2).%New()
    Set tSC = factory2.DemonstrateProductFamily()
    Do $$$AssertStatusOK(tSC, "Factory2 demonstration executed successfully")
    
    // Debug output
    Set ^ClineDebug = ^ClineDebug _ "Factory demonstration test complete; "
}

/// Test healthcare example - Medical Device UI Factory
Method TestMedicalDeviceUIFactory()
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Test Tablet UI Factory
    Set tabletFactory = ##class(Patterns.Examples.TabletUIFactory).%New()
    Do $$$AssertTrue($ISOBJECT(tabletFactory), "TabletUIFactory created successfully")
    
    Set tabletButton = tabletFactory.CreateButton()
    Set tabletForm = tabletFactory.CreateForm()
    Set tabletChart = tabletFactory.CreateChart()
    
    Do $$$AssertTrue($ISOBJECT(tabletButton), "Tablet button created")
    Do $$$AssertTrue($ISOBJECT(tabletForm), "Tablet form created")
    Do $$$AssertTrue($ISOBJECT(tabletChart), "Tablet chart created")
    
    Do $$$AssertEquals(tabletButton.GetPlatform(), "Tablet", "Button platform is Tablet")
    Do $$$AssertEquals(tabletForm.GetPlatform(), "Tablet", "Form platform is Tablet")
    Do $$$AssertEquals(tabletChart.GetPlatform(), "Tablet", "Chart platform is Tablet")
    
    // Test Desktop UI Factory
    Set desktopFactory = ##class(Patterns.Examples.DesktopUIFactory).%New()
    Do $$$AssertTrue($ISOBJECT(desktopFactory), "DesktopUIFactory created successfully")
    
    Set desktopButton = desktopFactory.CreateButton()
    Set desktopForm = desktopFactory.CreateForm()
    Set desktopChart = desktopFactory.CreateChart()
    
    Do $$$AssertTrue($ISOBJECT(desktopButton), "Desktop button created")
    Do $$$AssertTrue($ISOBJECT(desktopForm), "Desktop form created")
    Do $$$AssertTrue($ISOBJECT(desktopChart), "Desktop chart created")
    
    Do $$$AssertEquals(desktopButton.GetPlatform(), "Desktop", "Button platform is Desktop")
    Do $$$AssertEquals(desktopForm.GetPlatform(), "Desktop", "Form platform is Desktop")
    Do $$$AssertEquals(desktopChart.GetPlatform(), "Desktop", "Chart platform is Desktop")
    
    // Test Mobile UI Factory
    Set mobileFactory = ##class(Patterns.Examples.MobileUIFactory).%New()
    Do $$$AssertTrue($ISOBJECT(mobileFactory), "MobileUIFactory created successfully")
    
    Set mobileButton = mobileFactory.CreateButton()
    Set mobileForm = mobileFactory.CreateForm()
    Set mobileChart = mobileFactory.CreateChart()
    
    Do $$$AssertTrue($ISOBJECT(mobileButton), "Mobile button created")
    Do $$$AssertTrue($ISOBJECT(mobileForm), "Mobile form created")
    Do $$$AssertTrue($ISOBJECT(mobileChart), "Mobile chart created")
    
    Do $$$AssertEquals(mobileButton.GetPlatform(), "Mobile", "Button platform is Mobile")
    Do $$$AssertEquals(mobileForm.GetPlatform(), "Mobile", "Form platform is Mobile")
    Do $$$AssertEquals(mobileChart.GetPlatform(), "Mobile", "Chart platform is Mobile")
    
    // Debug output
    Set ^ClineDebug = ^ClineDebug _ "Medical Device UI Factory test complete; "
}

/// Test platform validation in medical UI factories
Method TestMedicalUIFactoryValidation()
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Create tablet factory and components
    Set tabletFactory = ##class(Patterns.Examples.TabletUIFactory).%New()
    Set tabletButton = tabletFactory.CreateButton()
    Set tabletForm = tabletFactory.CreateForm()
    Set tabletChart = tabletFactory.CreateChart()
    
    // Validate tablet components are from same platform
    Set buttonPlatform = tabletButton.GetPlatform()
    Set formPlatform = tabletForm.GetPlatform()
    Set chartPlatform = tabletChart.GetPlatform()
    
    Set isValid = ((buttonPlatform = formPlatform) && (formPlatform = chartPlatform))
    Do $$$AssertTrue(isValid, "Tablet components are from same platform")
    Do $$$AssertEquals(buttonPlatform, "Tablet", "All components are Tablet platform")
    
    // Create desktop factory and components
    Set desktopFactory = ##class(Patterns.Examples.DesktopUIFactory).%New()
    Set desktopButton = desktopFactory.CreateButton()
    
    // Test validation with mixed platforms
    Set desktopPlatform = desktopButton.GetPlatform()
    Set isMixed = (desktopPlatform '= formPlatform)
    Do $$$AssertTrue(isMixed, "Desktop button has different platform than tablet form")
    
    // Test form attachment validation (forms can attach buttons)
    Set tSC = tabletForm.AttachButton(tabletButton)
    Do $$$AssertStatusOK(tSC, "Tablet form accepts tablet button")
    
    // Test incompatible attachment
    Set tSC = tabletForm.AttachButton(desktopButton)
    Do $$$AssertTrue($$$ISERR(tSC), "Tablet form correctly rejects desktop button")
    
    // Debug output
    Set ^ClineDebug = ^ClineDebug _ "Medical UI validation test complete; "
}

/// Test medical UI component rendering
Method TestMedicalUIComponentRendering()
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Test tablet component rendering
    Set tabletFactory = ##class(Patterns.Examples.TabletUIFactory).%New()
    Set tabletButton = tabletFactory.CreateButton()
    Set tSC = tabletButton.Render()
    Do $$$AssertStatusOK(tSC, "Tablet button rendered successfully")
    
    Set tabletForm = tabletFactory.CreateForm()
    Set tSC = tabletForm.Render()
    Do $$$AssertStatusOK(tSC, "Tablet form rendered successfully")
    
    Set tabletChart = tabletFactory.CreateChart()
    Set tSC = tabletChart.Render()
    Do $$$AssertStatusOK(tSC, "Tablet chart rendered successfully")
    
    // Test desktop component rendering
    Set desktopFactory = ##class(Patterns.Examples.DesktopUIFactory).%New()
    Set desktopChart = desktopFactory.CreateChart()
    Set tSC = desktopChart.Render()
    Do $$$AssertStatusOK(tSC, "Desktop chart rendered successfully")
    
    // Test mobile component rendering
    Set mobileFactory = ##class(Patterns.Examples.MobileUIFactory).%New()
    Set mobileForm = mobileFactory.CreateForm()
    Set tSC = mobileForm.Render()
    Do $$$AssertStatusOK(tSC, "Mobile form rendered successfully")
    
    // Debug output
    Set ^ClineDebug = ^ClineDebug _ "Medical UI rendering test complete; "
}

/// Test factory method polymorphism
Method TestFactoryPolymorphism()
{
    // Clear debug global
    Set ^ClineDebug = ""
    
    // Create array of different factories
    Set factories(1) = ##class(Patterns.GoF.Creational.ConcreteFactory1).%New()
    Set factories(2) = ##class(Patterns.GoF.Creational.ConcreteFactory2).%New()
    
    // Test polymorphic behavior
    For i=1:1:2 {
        Set factory = factories(i)
        
        // Test that factory can create products
        Set productA = factory.CreateProductA()
        Set productB = factory.CreateProductB()
        
        Do $$$AssertTrue($ISOBJECT(productA), "Factory " _ i _ " created ProductA")
        Do $$$AssertTrue($ISOBJECT(productB), "Factory " _ i _ " created ProductB")
        
        // Test product interaction
        Set isCompatible = productB.IsCompatibleWith(productA)
        Do $$$AssertTrue(isCompatible, "Factory " _ i _ " products are compatible")
    }
    
    // Debug output
    Set ^ClineDebug = ^ClineDebug _ "Factory polymorphism test complete; "
}

/// Cleanup method after each test
Method OnAfterOneTest() As %Status
{
    // Clean up any test data if needed
    Quit $$$OK
}

}
