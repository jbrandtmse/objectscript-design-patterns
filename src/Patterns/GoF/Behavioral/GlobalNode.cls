/// Gang of Four Iterator Pattern - Global Node Helper Class
/// 
/// Purpose:
/// Represents a single node in a global structure with key, value, and reference
/// 
/// Features:
/// - Encapsulates global node information
/// - Provides helper methods for node inspection
Class Patterns.GoF.Behavioral.GlobalNode Extends %RegisteredObject
{

/// The subscript key
Property Key As %String;

/// The value at this node
Property Value As %String;

/// The global reference
Property GlobalRef As %String;

/// Check if this node has children
Method HasChildren() As %Boolean
{
        Set tHasChildren = 0
        
        If (..GlobalRef '= "") && (..Key '= "") {
            Set tChildKey = $ORDER(@..GlobalRef@(..Key, ""))
            If tChildKey '= "" {
                Set tHasChildren = 1
            }
        }
        
        Quit tHasChildren
}

/// Get the full global reference including subscript
Method GetFullReference() As %String
{
        If ..Key = "" {
            Quit ..GlobalRef
        }
        Quit ..GlobalRef _ "(" _ ..Key _ ")"
}

/// Get the node depth (number of subscript levels)
Method GetDepth() As %Integer
{
        If ..Key = "" {
            Quit 0
        }
        // Count commas in the key to determine depth
        Set tDepth = 1
        For i=1:1:$Length(..Key) {
            If $Extract(..Key, i) = "," {
                Set tDepth = tDepth + 1
            }
        }
        Quit tDepth
}

/// Convert node to display string
Method ToString() As %String
{
        Quit ..GetFullReference() _ " = " _ ..Value
}

}
