/*
 XMLNode.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#if os(Linux) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation

// For Obj-C Support
public typealias NSXMLNodeOptions = UInt

public let NSXMLNodeIsCDATA = UInt(XMLNode.Options.nodeIsCDATA.rawValue)
public let NSXMLNodeExpandEmptyElement
 = UInt(XMLNode.Options.nodeExpandEmptyElement.rawValue)
public let NSXMLNodeCompactEmptyElement
 = UInt(XMLNode.Options.nodeCompactEmptyElement.rawValue)
public let NSXMLNodeUseSingleQuotes
 = UInt(XMLNode.Options.nodeUseSingleQuotes.rawValue)
public let NSXMLNodeUseDoubleQuotes
 = UInt(XMLNode.Options.nodeUseDoubleQuotes.rawValue)
public let NSXMLNodeNeverEscapeContents = UInt(XMLNode.Options.nodeNeverEscapeContents.rawValue)
public let NSXMLDocumentTidyHTML
 = UInt(XMLNode.Options.documentTidyHTML.rawValue)
public let NSXMLDocumentTidyXML
 = UInt(XMLNode.Options.documentTidyXML.rawValue)
public let NSXMLNodeDocumentInjectHTMLDocType = UInt(XMLNode.Options.documentInjectHTMLDocType.rawValue)
public let NSXMLDocumentValidate
 = UInt(XMLNode.Options.documentValidate.rawValue)
public let NSXMLNodeLoadExternalEntitiesAlways
 = UInt(XMLNode.Options.nodeLoadExternalEntitiesAlways.rawValue)
public let NSXMLNodeLoadExternalEntitiesSameOriginOnly
 = UInt(XMLNode.Options.nodeLoadExternalEntitiesSameOriginOnly.rawValue)
public let NSXMLNodeLoadExternalEntitiesNever
 = UInt(XMLNode.Options.nodeLoadExternalEntitiesNever.rawValue)
public let NSXMLDocumentXInclude
 = UInt(XMLNode.Options.documentXInclude.rawValue)
public let NSXMLNodePrettyPrint
 = UInt(XMLNode.Options.nodePrettyPrint.rawValue)
public let NSXMLDocumentIncludeContentTypeDeclaration
 = UInt(XMLNode.Options.documentIncludeContentTypeDeclaration.rawValue)
public let NSXMLNodePreserveNamespaceOrder
 = UInt(XMLNode.Options.nodePreserveNamespaceOrder.rawValue)
public let NSXMLNodePreserveAttributeOrder
 = UInt(XMLNode.Options.nodePreserveAttributeOrder.rawValue)
public let NSXMLNodePreserveEntities
 = UInt(XMLNode.Options.nodePreserveEntities.rawValue)
public let NSXMLNodePreservePrefixes
 = UInt(XMLNode.Options.nodePreservePrefixes.rawValue)
public let NSXMLNodePreserveCDATA
 = UInt(XMLNode.Options.nodePreserveCDATA.rawValue)
public let NSXMLNodePreserveWhitespace
 = UInt(XMLNode.Options.nodePreserveWhitespace.rawValue)
public let NSXMLNodePreserveDTD
 = UInt(XMLNode.Options.nodePreserveDTD.rawValue)
public let NSXMLNodePreserveCharacterReferences
 = UInt(XMLNode.Options.nodePreserveCharacterReferences.rawValue)
public let NSXMLNodePromoteSignificantWhitespace = UInt(XMLNode.Options.nodePromoteSignificantWhitespace.rawValue)
public let NSXMLNodePreserveEmptyElements
 = UInt(XMLNode.Options.nodePreserveEmptyElements.rawValue)
public let NSXMLNodePreserveQuotes
 = UInt(XMLNode.Options.nodePreserveQuotes.rawValue)
public let NSXMLNodePreserveAll = UInt(XMLNode.Options.nodePreserveAll.rawValue)

@objcMembers
@objc(NSXMLNode)
open class XMLNode: NSObject, NSCopying, AJREquatable {

    @objc
    public enum Kind : UInt {
        
        @objc(NSXMLInvalidKind)
        case invalid
        @objc(NSXMLDocumentKind)
        case document
        @objc(NSXMLElementKind)
        case element
        @objc(NSXMLAttributeKind)
        case attribute
        @objc(NSXMLNamespaceKind)
        case namespace
        @objc(NSXMLProcessingInstructionKind)
        case processingInstruction
        @objc(NSXMLCommentKind)
        case comment
        @objc(NSXMLTextKind)
        case text
        @objc(NSXMLDTDKnd)
        case DTDKind
        @objc(NSXMLEntityDeclarationKind)
        case entityDeclaration
        @objc(NSXMLAttributeDeclarationKind)
        case attributeDeclaration
        @objc(NSXMLElementDeclaractionKind)
        case elementDeclaration
        @objc(NSXMLNotationDeclarationKind)
        case notationDeclaration
        
        case elementDeclarationContent
    }

    public struct Options : OptionSet {
        public let rawValue: UInt

        public static let none: Options = []

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
        
        public init(rawValue: UInt) { self.rawValue = rawValue }
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
    
    public override var description : String { return xmlString(options: [.none]) }
    
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

    // MARK: - Query

    @objc(nodesForXPath:error:)
    public func nodes(xPath: String) throws -> [XMLNode] {
        return []
    }
    
    // MARK: - Equatable
    
    public func equal(toNode other: XMLNode) -> Bool {
        return (AJRAnyEquals(name, other.name)
            && AJRAnyEquals(uri, other.uri)
            && AJRAnyEquals(kind, other.kind)
            && AJRAnyEquals(objectValue, other.objectValue)
        )
    }
    
    public func isEqual(to other: Any) -> Bool {
        if Self.self == type(of:other) {
            return equal(toNode: other as! XMLNode)
        }
        return false
    }
    
    public static func == (lhs: XMLNode, rhs: XMLNode) -> Bool {
        return lhs.isEqual(to:rhs)
    }
    
    // MARK: - Copying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Self.init(kind: kind, options: options)
        copy.uri = uri
        copy.name = name
        if let objectValue = objectValue as? NSCopying {
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
