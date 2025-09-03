/// Gang of Four Observer Pattern - Observer Abstract Class
/// <p>
/// Intent:
/// Define an interface for objects that should be notified of changes
/// in a Subject. Each concrete observer implements the Update method
/// to react to notifications from the subject.
/// </p>
/// <p>
/// Structure:
/// - This abstract class defines the interface for all concrete observers
/// - Concrete observers must implement the Update method
/// - The Update method is called by the Subject when its state changes
/// </p>
Class Patterns.GoF.Behavioral.Observer.Observer Extends %RegisteredObject [ Abstract ]
{

Parameter VERSION = "1.0.0";

Parameter PATTERNTYPE = "Behavioral";

Method Update(pSubject As Patterns.GoF.Behavioral.Observer.Subject, pData As %String = "") As %Status [ Abstract ]
{
    Quit 0
}

}
