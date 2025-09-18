# Chapter 03: The Observer Pattern

## What is the Observer Pattern?

Imagine you're in a hospital where multiple medical staff need to be notified when a patient's vital signs change. The patient monitor acts like a news broadcaster - when something important happens (like heart rate spiking), it automatically sends updates to all the people who signed up to receive alerts: nurses at their station, doctors on their pagers, and the medical records system that logs everything. That's exactly how the Observer pattern works in programming!

The Observer pattern creates a one-to-many relationship between objects. When one object changes (the "subject"), all its dependents (the "observers") are automatically notified and updated.

## Intent

The Observer pattern defines a dependency between objects so that when one object changes state, all its dependents are notified and updated automatically. It's like a subscription service where observers sign up to receive updates from a subject they're interested in.

**Implementation Location:** `/src/Patterns/GoF/Behavioral/Observer/Subject.cls`

## When Should You Use It? (Applicability)

Use the Observer pattern when:

• You have an object that needs to notify multiple other objects about its state changes
• The number of observers may vary during runtime (observers can subscribe and unsubscribe)
• You want to decouple the subject from its observers (they don't need to know about each other's implementation details)
• Changes to one object require changing others, and you don't know how many objects need to be changed
• An object should be able to notify other objects without making assumptions about who those objects are

**Real-world healthcare examples:**
• Patient monitoring systems alerting multiple medical staff
• Lab results triggering notifications to doctors, nurses, and billing
• Medication schedules updating pharmacy, nursing stations, and patient apps
• Emergency alerts broadcasting to all relevant departments

## How It Works (Structure)

```
     +------------------+
     |     Subject      |
     +------------------+
     | - observers: List|
     | - state          |
     +------------------+
     | + Attach()       |
     | + Detach()       |
     | + Notify()       |
     +------------------+
              △
              |
              | notifies
              |
     +------------------+
     |    Observer      |  <<interface>>
     +------------------+
     | + Update()       |
     +------------------+
              △
              |
     +--------+--------+
     |                 |
+--------------------+ +--------------------+
| ConcreteObserverA  | | ConcreteObserverB  |
+--------------------+ +--------------------+
| - observerState    | | - observerState    |
+--------------------+ +--------------------+
| + Update()         | | + Update()         |
+--------------------+ +--------------------+
```

**Step-by-step code walkthrough:**

1. **Subject Class** (`Subject.cls`):
```objectscript
Class Patterns.GoF.Behavioral.Observer.Subject Extends %RegisteredObject
{
    Parameter PATTERNTYPE = "Behavioral";
    Parameter VERSION = "1.0.0";
    
    Property Observers As %ListOfObjects;
    Property State As %String;
    
    Method %OnNew() As %Status
    {
        Set ..Observers = ##class(%Library.ListOfObjects).%New()
        Quit $$$OK
    }
    
    Method Attach(pObserver As Observer) As %Status
    {
        // Validate and prevent duplicates
        If '$IsObject(pObserver) {
            Quit $$$ERROR($$$GeneralError, "Observer must be a valid object")
        }
        
        // Check if already attached
        For i=1:1:..Observers.Count() {
            If ..Observers.GetAt(i) = pObserver Quit
        }
        
        Do ..Observers.Insert(pObserver)
        Quit $$$OK
    }
    
    Method Notify(pData As %String = "") As %Status
    {
        // Notify all observers with optional data
        For i=1:1:..Observers.Count() {
            Set observer = ..Observers.GetAt(i)
            If $IsObject(observer) {
                Do observer.Update($this, pData)
            }
        }
        Quit $$$OK
    }
    
    Method SetState(pNewState As %String, pNotify As %Boolean = 1) As %Status
    {
        Set ..State = pNewState
        If pNotify {
            Do ..Notify(pNewState)
        }
        Quit $$$OK
    }
    
    Method Detach(pObserver As Observer) As %Status
    {
        // Find and remove the observer
        For i=1:1:..Observers.Count() {
            If ..Observers.GetAt(i) = pObserver {
                Do ..Observers.RemoveAt(i)
                Quit
            }
        }
        Quit $$$OK
    }
    
    Method GetState() As %String
    {
        Quit ..State
    }
    
    Method GetObserverCount() As %Integer
    {
        Quit ..Observers.Count()
    }
}
```

2. **Observer Interface** (`Observer.cls`):
```objectscript
Class Patterns.GoF.Behavioral.Observer.Observer [ Abstract ]
{
    Parameter PATTERNTYPE = "Behavioral";
    
    /// Update method with optional data parameter
    Method Update(pSubject As Subject, pData As %String = "") As %Status [ Abstract ]
    {
        Quit $$$OK
    }
}
```

3. **Concrete Observer** (example from `NurseStation.cls`):
```objectscript
Method Update(pSubject As Subject, pData As %String = "") As %Status
{
    Set tSC = $$$OK
    Try {
        // Check if subject is VitalSignsMonitor
        If pSubject.%IsA("Patterns.Examples.VitalSignsMonitor") {
            Set monitor = pSubject
            Set alertLevel = monitor.GetAlertLevel()
            
            // Process based on alert level
            If alertLevel = "Critical" {
                Set ..CriticalAlerts = ..CriticalAlerts + 1
                Do ..AlertQueue.Insert($ZDateTime($H, 3) _ " - CRITICAL: Patient " _ monitor.PatientID)
                Write "[NurseStation][" _ ..StationID _ "] CRITICAL ALERT!", !
            }
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}
```

## What Happens When You Use It (Consequences)

### The Good Parts ✅

**1. Loose Coupling:**
Subjects and observers are loosely coupled - they can interact without knowing each other's concrete types.

```objectscript
// Subject doesn't need to know about specific observer types
Set monitor = ##class(VitalSignsMonitor).%New()
Set anyObserver = ##class(NurseStation).%New()  // Could be any observer type
Do monitor.Attach(anyObserver)
```

**2. Dynamic Subscription:**
Observers can be added or removed at runtime.

```objectscript
// Add observers as needed
Do monitor.Attach(nurseStation)
Do monitor.Attach(doctorPager)
// Remove when no longer needed
Do monitor.Detach(doctorPager)
```

**3. Broadcast Communication:**
One subject can notify many observers efficiently.

```objectscript
// One notification reaches all observers
Set monitor.HeartRate = 150  // Critical!
Do monitor.Notify()  // All attached observers are alerted
```

### The Challenging Parts ⚠️

**1. Update Overhead:**
Observers might receive updates they don't care about.

```objectscript
// Solution: Implement filtering in observers
If alertLevel '= "Critical" { Quit }  // Ignore non-critical
```

**2. Memory Management:**
Observers that aren't properly detached can cause memory leaks.

```objectscript
// Always detach observers when done
Method %OnClose() As %Status
{
    Do ..Subject.Detach($this)
}
```

**3. Update Order:**
The order of observer notifications may matter in some cases.

## Real Example: Hospital Vital Signs Monitoring

Here's our complete healthcare example showing how different parts of a hospital respond to patient vital sign changes:

```objectscript
// Create the patient monitor (Subject)
Set monitor = ##class(Patterns.Examples.VitalSignsMonitor).%New("PATIENT-123")

// Create observers for different hospital departments
Set nurseStation = ##class(Patterns.Examples.NurseStation).%New("ICU-Station-1", "ICU")
Set doctorPager = ##class(Patterns.Examples.DoctorPager).%New("DR-5555", "Dr. Smith")
Set medicalRecord = ##class(Patterns.Examples.MedicalRecord).%New("PATIENT-123", "ICU Staff")

// Subscribe all observers to the monitor
Do monitor.Attach(nurseStation)
Do monitor.Attach(doctorPager)
Do monitor.Attach(medicalRecord)

// Normal vital signs - everyone gets notified but reacts differently
Set monitor.HeartRate = 75
Set monitor.BloodPressure = "120/80"
Set monitor.Temperature = 98.6
Set monitor.OxygenSaturation = 98
Do monitor.Notify()
// Result: Nurse station shows green, doctor not paged, medical record logs entry

// Patient condition deteriorates - critical alert!
Set monitor.HeartRate = 145
Set monitor.OxygenSaturation = 85
Do monitor.Notify()
// Result: 
// - Nurse station triggers alarm and shows red alert
// - Doctor gets paged immediately
// - Medical record logs critical event and notifies compliance
// All from one Notify() call!
```

**What makes this powerful:**
- The monitor doesn't need to know who's listening or how they'll react
- Each observer handles the notification in its own way
- New observers (like a family notification system) can be added without changing existing code

## Testing the Pattern

**Test Class:** `/src/Patterns/Test/Unit/GoF/Behavioral/ObserverTest.cls`

Key test scenarios covered:
- **TestSubjectAttachDetach:** Verifies observers can be attached and detached
- **TestObserverNotification:** Confirms all observers receive updates
- **TestSelectiveNotification:** Tests filtered notifications (ConcreteObserverB)
- **TestVitalSignsMonitor:** Validates healthcare example alert levels
- **TestCompleteHealthcareScenario:** Full integration test with all observers

Example test:
```objectscript
// Test that detached observers stop receiving notifications
Set observer = ##class(ConcreteObserverA).%New()
Do subject.Attach(observer)
Do subject.Notify()  // Observer receives update
Do subject.Detach(observer)
Do subject.Notify()  // Observer does NOT receive update
```

## Summary

The Observer pattern is perfect when you need automatic notifications across multiple objects. Think of it as a subscription system where:

1. **Subjects** maintain a list of interested observers
2. **Observers** register themselves to receive updates
3. **Notifications** are broadcast to all registered observers automatically
4. **Each observer** decides how to react to the notification

In healthcare systems, this pattern is invaluable for:
- Real-time patient monitoring and alerts
- Coordinating responses across departments
- Maintaining audit trails and compliance
- Enabling flexible, scalable notification systems

The pattern keeps your code flexible and maintainable by ensuring that subjects and observers can evolve independently.

## Try It Yourself

1. **Basic Exercise:** Create a `BloodPressureMonitor` subject that notifies observers when readings exceed normal ranges.

2. **Intermediate Exercise:** Add a `PharmacyObserver` that gets notified when certain vital signs indicate medication adjustments might be needed.

3. **Advanced Exercise:** Implement a priority system where critical observers get notified before others.

4. **Challenge:** Create a `FilteredObserver` that only receives notifications for specific types of changes (like only temperature changes).

Start with the existing code in `/src/Patterns/Examples/` and extend it with your own observer implementations!
