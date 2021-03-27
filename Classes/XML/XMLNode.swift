
#if os(Linux) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation
import radar_core

open class XMLNode: CustomStringConvertible, Equatable, Copying, UntypedEquatable {
    public enum Kind : UInt {
        
        case invalid
        case document
        case element
        case attribute
        case namespace
        case processingInstruction
        case comment
        case text
        case DTDKind
        case entityDeclaration
        case attributeDeclaration
        case elementDeclaration
        case notationDeclaration
        
        case elementDeclarationContent
    }
    
    public struct Options : OptionSet {
        public let rawValue: Int

        public static let none = Options(rawValue: 0)

        // Init
        public static let nodeIsCDATA                            = Options(rawValue: 1 << 0)
        public static let nodeExpandEmptyElement                 = Options(rawValue: 1 << 1) // <a></a>
        public static let nodeCompactEmptyElement                = Options(rawValue: 1 << 2) // <a/>
        public static let nodeUseSingleQuotes                    = Options(rawValue: 1 << 3)
        public static let nodeUseDoubleQuotes                    = Options(rawValue: 1 << 4)
        public static let nodeNeverEscapeContents                = Options(rawValue: 1 << 5)

        // Tidy
        public static let documentTidyHTML                       = Options(rawValue: 1 << 9)
        public static let documentTidyXML                        = Options(rawValue: 1 << 10)
        public static let documentInjectHTMLDocType              = Options(rawValue: 1 << 11) // When reading a document, this adds the HTML <!DOCTYPE> element to the top, which helps a little when parsing HTML documents. It'll probably get removed in the future, because we should recognize that we're parsing HTML and switch to the actual HTML parser in libxml2.

        // Validate
        public static let documentValidate                       = Options(rawValue: 1 << 13)
        
        // External Entity Loading
        // Choose only zero or one option. Choosing none results in system-default behavior.
        public static let nodeLoadExternalEntitiesAlways         = Options(rawValue: 1 << 14)
        public static let nodeLoadExternalEntitiesSameOriginOnly = Options(rawValue: 1 << 15)
        public static let nodeLoadExternalEntitiesNever          = Options(rawValue: 1 << 19)
        
        // Parse
        public static let documentXInclude                       = Options(rawValue: 1 << 16)
        
        // Output
        public static let nodePrettyPrint                        = Options(rawValue: 1 << 17)
        public static let documentIncludeContentTypeDeclaration  = Options(rawValue: 1 << 18)
        
        // Fidelity
        public static let nodePreserveNamespaceOrder             = Options(rawValue: 1 << 20)
        public static let nodePreserveAttributeOrder             = Options(rawValue: 1 << 21)
        public static let nodePreserveEntities                   = Options(rawValue: 1 << 22)
        public static let nodePreservePrefixes                   = Options(rawValue: 1 << 23)
        public static let nodePreserveCDATA                      = Options(rawValue: 1 << 24)
        public static let nodePreserveWhitespace                 = Options(rawValue: 1 << 25)
        public static let nodePreserveDTD                        = Options(rawValue: 1 << 26)
        public static let nodePreserveCharacterReferences        = Options(rawValue: 1 << 27)
        public static let nodePromoteSignificantWhitespace       = Options(rawValue: 1 << 28)
        public static let nodePreserveEmptyElements: Options     = [.nodeExpandEmptyElement, .nodeCompactEmptyElement]
        public static let nodePreserveQuotes: Options            = [.nodeUseSingleQuotes, .nodeUseDoubleQuotes]
        public static let nodePreserveAll: Options               = [.nodePreserveNamespaceOrder,
                                                                    .nodePreserveAttributeOrder,
                                                                    .nodePreserveEntities,
                                                                    .nodePreservePrefixes,
                                                                    .nodePreserveCDATA,
                                                                    .nodePreserveEmptyElements,
                                                                    .nodePreserveQuotes,
                                                                    .nodePreserveWhitespace,
                                                                    .nodePreserveDTD,
                                                                    .nodePreserveCharacterReferences,
                                                                    Options(rawValue:0xFFF00000)] // high 12 bits
        
        public init(rawValue: Int) { self.rawValue = rawValue }
    }
    
    public internal(set) var parent : XMLNode? = nil
    public var options : Options
    public var kind : Kind
    public var name: String? = nil
    public var prefix : String? { return name == nil ? nil : XMLNode.prefix(forName: name!) }
    public var objectValue : Any? = nil
    // This allows us to know if we really have a string value, or if a subclass is overriding stringValue to return something else.
    private var _stringValue : String?
    open var stringValue : String? { get { return _stringValue } set(newValue) { _stringValue = newValue } }
    private var escapeEntitiesOnSave : Bool = true;
    public var uri : String? = nil
    public var children : [XMLNode]? {
        get {
            if let childBearer = self as? XMLNodeWithChildren {
                var children : [XMLNode]? = nil
                childBearer.manipulateChildren { (actualChildren) in
                    children = actualChildren
                }
                return children
            }
            return nil
        }
        set(newValue) {
            if let childBearer = self as? XMLNodeWithChildren {
                childBearer.set(children: newValue)
            } else {
                // Does nothing.
            }
        }
    }
    public var childCount : Int {
        return children?.count ?? 0
    }

    public convenience init(kind:Kind) {
        self.init(kind:kind, options:.none)
    }
    
    required public init(kind:Kind, options:Options) {
        self.kind = kind
        self.options = options
    }

    public convenience init(kind:Kind, stringValue: String) {
        self.init(kind: kind, options: .none)
        self.stringValue = stringValue
    }
    
    public class func document() -> Any {
        return XMLDocument()
    }
    
    public class func document(withRootElement element:XMLElement) -> Any {
        return XMLDocument(rootElement: element)
    }
    
    public class func element(withName name:String) -> Any {
        return XMLElement(name: name)
    }
    
    public class func element(withName name: String, uri: String) -> Any {
        return XMLElement(name:name, uri:uri)
    }
    
    public class func element(withName name: String, stringValue: String) -> Any {
        return XMLElement(name:name, stringValue: stringValue)
    }
    
    public class func element(withName name: String, children: [XMLNode]?, attributes: [XMLNode]?) -> Any {
        let element = XMLElement(name: name)
        if let children = children {
            element.children = children
        }
        if let attributes = attributes {
            element.attributes = attributes
        }
        return element
    }
    
    public class func attribute(withName name: String, stringValue: String? = nil) -> Any {
        var kind = XMLNode.Kind.attribute
        var resolvedName = name

        if name == "xmlns" || name.hasPrefix("xmlns:") {
            kind = .namespace
            if name.hasPrefix("xmlns:") {
                resolvedName = String(name.suffix(from: name.index(name.startIndex, offsetBy: 6)))
            } else {
                resolvedName = ""
            }
        }
        return XMLNamedNode(kind:kind, name:resolvedName, stringValue:stringValue)
    }
    
    public class func attribute(withName name: String, uri: String, stringValue: String) -> Any {
        return XMLNamedNode(kind: .attribute, name:name, uri:uri, stringValue:stringValue)
    }
    
    public class func namespace(withName name: String, stringValue: String) -> Any {
        return XMLNamedNode(kind:.namespace, name:name, stringValue:stringValue)
    }
    
    public class func processingInstruction(withName name: String, stringValue: String) -> Any {
        return XMLNamedNode(kind: .processingInstruction, name:name, stringValue:stringValue)
    }
    
    public class func comment(withStringValue stringValue: String) -> Any {
        return XMLNode(kind: .comment, stringValue:stringValue)
    }
    
    public class func text(withStringValue stringValue: String) -> Any {
        return XMLNode(kind: .text, stringValue:stringValue)
    }
    
    public class func dtdNode(xmlString string: String) -> Any? {
        return nil
    }
    
    // MARK: - Tree Navigation
    
    public func child(at index: Int) -> XMLNode? {
        if let children = children {
            return children[index]
        }
        return nil
    }
    
    internal func detach() -> Void {
        parent = nil
    }
    
    // MARK: - Properties
    
    public var rootDocument : XMLDocument? {
        return self.parent?.rootDocument
    }
    
    public func setStringValue(_ string: String, resolvingEntities resolve: Bool) -> Void {
        if (resolve) {
            if let stringValue = try? XMLStringByResolvingEntities(input: string, document: self.rootDocument) {
                self.stringValue = stringValue
                escapeEntitiesOnSave = true
            } else {
                self.stringValue = nil
                escapeEntitiesOnSave = false
            }
        } else {
            stringValue = string
        }
    }
    
    // MARK: - QNames
    
    public class func localName(forName name: String) -> String {
        let range = name.range(of: ":")
        return range == nil ? name : String(name.suffix(from: range!.upperBound))
    }

    public class func prefix(forName name: String) -> String? {
        let range = name.range(of:":")
        return range == nil ? "" : String(name.prefix(upTo:range!.lowerBound))
    }
    
    static let predefinedNamespaces : [String:XMLNode] = [
        "xml":XMLNode.namespace(withName:"xml", stringValue:"http://www.w3.org/XML/1998/namespace") as! XMLNode,
        "xs" :XMLNode.namespace(withName:"xs",  stringValue:"http://www.w3.org/2001/XMLSchema") as! XMLNode,
        "xsi":XMLNode.namespace(withName:"xsi", stringValue:"http://www.w3.org/2001/XMLSchema-instance") as! XMLNode,
        ]
    
    public class func predefinedNamespace(forPrefix name: String) -> XMLNode? {
        return predefinedNamespaces[name]
    }
    
    // MARK: - Output
    
    public var description : String { return xmlString(options: [.none]) }
    
    public func xmlString(options: XMLNode.Options = []) -> String {
        var result = ""
        
        if kind == .comment {
            result += "<!--"
            if let stringValue = stringValue {
                result += stringValue
            } else {
                result += " "
            }
            result += "-->"
        } else if kind == .text {
            if let stringValue = stringValue {
                result += XMLEscapedString(stringValue, document: self.rootDocument, kind: kind)
            }
        }
        
        return result
    }
    
    public func canonicalXMLString(preservingComments comments: Bool) -> String {
        return xmlString(options:.nodePreserveAll)
    }
    
    // MARK: - Equatable
    
    public func equal(toNode other: XMLNode) -> Bool {
        return (Equal(name, other.name)
            && Equal(uri, other.uri)
            && Equal(kind, other.kind)
            && Equal(objectValue, other.objectValue)
        )
    }
    
    public func untypedEqual(to other: Any) -> Bool {
        if Self.self == type(of:other) {
            return equal(toNode: other as! XMLNode)
        }
        return false
    }
    
    public static func == (lhs: XMLNode, rhs: XMLNode) -> Bool {
        return lhs.untypedEqual(to:rhs)
    }
    
    // MARK: - Copying
    
    public func copy() -> Any {
        let copy = Self.init(kind: kind, options: options)
        copy.uri = uri
        copy.name = name
        if let objectValue = objectValue as? Copying {
            copy.objectValue = objectValue.copy()
        } else {
            copy.objectValue = objectValue
        }
        copy._stringValue = _stringValue
        copy.escapeEntitiesOnSave = escapeEntitiesOnSave
        return copy
    }
    
    // MARK: - Internal Utilities
    
    internal func mergeWithAdjacentTextNode(_ nextChild: XMLNode) -> Void {
        assert(kind == .text && nextChild.kind == .text, "Only adjacent text nodes can be merged.")
        if let value = nextChild._stringValue, value.count > 0 {
            if _stringValue == nil {
                _stringValue = value
            } else {
                _stringValue! += value
            }
            escapeEntitiesOnSave = !(escapeEntitiesOnSave || nextChild.escapeEntitiesOnSave);
        }
    }
    
}

#endif
