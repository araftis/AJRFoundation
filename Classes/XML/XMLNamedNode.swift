
#if os(Linux) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation
import radar_core

public class XMLNamedNode : XMLNode {
    
    internal var prefixIndex: String.Index? = nil

//    public convenience init(kind kind: XMLNode.Kind, name: String) {
//        self.init(kind: kind, name, name:name, URI:nil, stringValue:nil)
//    }
//
//    - (instancetype)initWithKind:(ASXMLNodeKind)kind name:(NSString *)name stringValue:(NSString *)stringValue {
//        return [self initWithKind:(ASXMLNodeKind)kind name:name URI:nil stringValue:stringValue];
//        }
//
//        - (instancetype)initWithKind:(ASXMLNodeKind)kind name:(NSString *)name URI:(NSString *)URI stringValue:(NSString *)stringValue {
//            return [self initWithKind:(ASXMLNodeKind)kind name:name prefix:nil URI:URI stringValue:stringValue];
//            }
        
    public init(kind: XMLNode.Kind, name: String? = nil, prefix: String? = nil, uri: String? = nil,  stringValue: String? = nil) {
        super.init(kind: kind, options: .none)

        self.name = name;
        self.uri = uri
        self.stringValue = stringValue
    }
    
    public required init(kind: Kind, options: Options) {
        super.init(kind: kind, options: options)
    }
    
    // MARK: - Properties
    
    public override var name: String? {
        get {
            return super.name
        }
        set(newValue) {
            super.name = newValue
            prefixIndex = name?.range(of: ":")?.lowerBound
        }
    }
    
    public override var prefix : String? {
        if let prefixIndex = prefixIndex {
            if let name = name {
                return String(name.prefix(upTo: prefixIndex))
            }
        }
        return ""
    }
    
    // MARK: - Output

    public override func xmlString(options: XMLNode.Options = []) -> String {
        var string = ""
        
        if kind == .attribute {
            if let name = name {
                if !name.isEmpty {
                    string += name
                }
            }
            if let stringValue = stringValue {
                if !string.isEmpty {
                    string += "="
                }
                string += "\""
                string += XMLEscapedString(stringValue, document: self.rootDocument, kind: kind)
                string += "\""
            }
        } else if kind == .processingInstruction {
            string += "<?"
            if let name = name {
                string += name
            }
            if let stringValue = stringValue {
                if string.count > 0 {
                    string += " "
                }
                string += stringValue
            }
            string += "?>"
        } else if kind == .namespace {
            string += "xmlns"
            if let name = name {
                if !name.isEmpty {
                    string += ":"
                    string += name
                }
            }
            string += "=\""
            string += stringValue!
            string += "\""
        }
        
        return string
    }
    
    // MARK: - Equatable
    
    public override func equal(toNode other: XMLNode) -> Bool {
        return super.equal(toNode: other) && Equal(stringValue, other.stringValue)
    }
    
    public static func == (lhs: XMLNamedNode, rhs: XMLNamedNode) -> Bool {
        return lhs.untypedEqual(to:rhs)
    }
    
    // MARK: - Copying
    
    public override func copy() -> Any {
        let copy = super.copy() as! XMLNamedNode
        copy.stringValue = stringValue
        return copy 
    }
    
}

#endif
