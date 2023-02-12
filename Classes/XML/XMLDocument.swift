/*
 XMLDocument.swift
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
import libxml2

@objcMembers
@objc(NSXMLDocument)
open class XMLDocument : XMLNode, XMLParserDelegate, XMLNodeWithChildren {
    
    public enum DocumentKind : Int {
        case xml
        case xhtml
        case html
        case text
    }
    
    private var injectedDTD = false
    
    public var characterEncoding: String? = nil
    public var isStandalone: Bool = false
    private var _documentContentKind: DocumentKind? = nil
    public var documentContentKind: DocumentKind? {
        get {
            if let documentContentKind = _documentContentKind {
                return documentContentKind
            }
            if let root = _rootElement {
                if root.name == "html" {
                    return .html
                }
            }
            return .xml
        }
        set(newValue) {
            _documentContentKind = newValue
        }
    }
    public var mimeType: String? = nil
    public var version: String? = nil
    public var baseURL : URL? = nil
    private var _dtds : [XMLDTD]?
    public var dtds : [XMLDTD]? {
        get {
            return _dtds
        }
        set(newValue) {
            if let currentDTDs = _dtds {
                for dtd in currentDTDs {
                    dtd.detach()
                }
            }
            if let newDTDs = newValue {
                _dtds = [XMLDTD]()
                for node in newDTDs {
                    node.parent = self
                }
            } else {
                _dtds = nil
            }
        }
    }
    public var dtd : XMLDTD? {
        get {
            if let dtds = _dtds, dtds.count > 0 {
                return dtds[0]
            }
            return nil
        }
        set(newValue) {
            if let newValue = newValue {
                dtds = [newValue]
            } else {
                dtds = []
            }
        }
    }

    // MARK: - Parsing
    
    // Adds the child either to us, the receiver, or to the current node on the element stack.
    private func add(processedChild child: XMLNode) -> Void {
        if let stackChild = elementStack?.last {
            stackChild.addChild(child)
        } else {
            self.addChild(child)
        }
    }
    
    private func processElement(from reader:XMLReader) throws -> Void {
        if let name = reader.name {
            let element = XMLNode.element(withName: name) as! XMLElement
            let isEmpty = reader.isEmptyElement // This means the element was immediate terminate, i.e. <br />
            
            add(processedChild: element)
            elementStack?.append(element)
            
            while reader.moveToNextAttribute() {
                let attributeNodeType = reader.nodeType
                if attributeNodeType == .attribute {
                    let attributeName = reader.name!
                    var value = ""
                    if reader.hasValue {
                        value = reader.value!
                    }
                    let node = XMLNode.attribute(withName:attributeName, stringValue:value) as! XMLNode
                    if node.kind == .namespace {
                        element.addNamespace(node)
                    } else {
                        element.addAttribute(node)
                    }
                } else {
                    AJRLog.warning("Hum, didn't handle node type \(attributeNodeType) when parsing attributes.")
                }
            }
            if isEmpty {
                try processElementClose(byName: name)
            }
        }
    }
    
    private func processProcessingInstruction(from reader: XMLReader) throws -> Void {
        if let name = reader.name {
            let value = reader.value ?? ""
            let node = XMLNamedNode(kind:.processingInstruction, name:name, stringValue:value)
            add(processedChild:node)
        }
    }
    
    private func processElementClose(byName name:String?) throws -> Void {
        // Nothing to really do here, really. We should just pop the last node. That being said, let's do a little validation.
        if let currentNode = elementStack?.last {
            if !AJRAnyEquals(name, currentNode.name) {
                AJRLog.warning("Found close tag for \(name ?? "*UNKNOWN*"), but expected to be closing: \(currentNode.name ?? "*UNKNOWN*").")
            } else {
                currentNode.normalizeAdjacentTextNodesPreservingCDATA(true)
                elementStack?.removeLast()
            }
        }
    }
    
    private func processElementClose(from reader: XMLReader) throws -> Void {
        // Nothing to really do here, really. We should just pop the last node. That being said, let's do a little validation.
        return try processElementClose(byName:reader.name)
    }
    
    private func processComment(from reader: XMLReader) throws -> Void {
        var value : String
        if let rawValue = reader.value {
            value = rawValue
        } else {
            value = ""
        }
        self.add(processedChild: XMLNode.comment(withStringValue: value) as! XMLNode)
    }

    private func processDocumentType(from reader: XMLReader) throws -> Void {
        if let node = reader.currentNode {
            try node.asDtdNode {
                let dtd = try XMLDTD(withXMLNode: $0, options: [])
                if _dtds == nil {
                    _dtds = [XMLDTD]()
                }
                _dtds?.append(dtd)
                dtd.parent = self
            }
        }
    }

    private func processEntityReference(from reader: XMLReader) throws -> Void {
        if options.contains(.nodePreserveEntities) {
            if let entityName = reader.name {
                let child = XMLNode(kind: .text, options: options)
                child.setStringValue("&\(entityName);", resolvingEntities: false)
                add(processedChild: child)
            }
        } else {
            if let entityName = reader.name {
                if let value = try XMLStringForEntity(rawEntity: entityName, document: self) {
                    add(processedChild: XMLNode.text(withStringValue:value) as! XMLNode)
                } else {
                    throw XMLError.invalidEntity(entityName)
                }
            }
        }
    }
    
    private func processCData(from reader: XMLReader) throws -> Void {
        if let rawValue = reader.value {
            if let value = String(xml: rawValue) {
                add(processedChild: XMLNode.text(withStringValue: value) as! XMLNode)
            } else {
                throw XMLError.invalidCData(rawValue)
            }
        }
    }
    
    private func processText(from reader: XMLReader) throws -> Void {
        if let rawValue = reader.value {
            if let value = String(xml:rawValue) {
                add(processedChild: XMLNode.text(withStringValue: value) as! XMLNode)
            } else {
                throw XMLError.invalidText(rawValue)
            }
        }
    }
    
    private func processNode(from reader: XMLReader) throws -> Void {
        let name = reader.name
        let type = reader.nodeType
        
//        #if DEBUG_XML_PARSING
//        const xmlChar *value = xmlTextReaderConstValue(reader);
//        AJRPrintf(@"name:%s, depth:%d, type:%@ (%d), isEmpty:%B, hasAttributes:%B, hasValue:%B",
//                   (char *)name ?: "--",
//            xmlTextReaderDepth(reader),
//            AJRStringFromNodeType(type), type,
//            xmlTextReaderIsEmptyElement(reader),
//            xmlTextReaderHasAttributes(reader),
//            xmlTextReaderHasValue(reader));
//
//        if (value == NULL) {
//            printf("\n");
//        } else {
//            NSString *nsValue = [[NSString stringWithUTF8String:(char *)value] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
//            if (xmlStrlen(value) > 40) {
//                AJRPrintf(@", value:%.40@...\n", nsValue);
//            } else {
//                AJRPrintf(@", value:%@\n", nsValue);
//            }
//        }
//        #endif
        
        if type == .element {
            try processElement(from: reader)
        } else if type == .processingInstruction {
            try processProcessingInstruction(from: reader)
        } else if type == .comment {
            try processComment(from: reader)
        } else if type == .elementDeclaration {
            try processElementClose(from: reader)
        } else if type == .documentType {
            try processDocumentType(from: reader)
        } else if type == .entityReference {
            try processEntityReference(from: reader)
        } else if type == .cdataSection {
            try processCData(from: reader)
        } else if type == .text {
            try processText(from: reader)
        } else if type == .dtd && name == "#text" {
            try processText(from: reader)
        }
    }
    
    private func parse(data dataIn: Data) throws -> Void {
        var data : Data
        
        if options.contains(.documentInjectHTMLDocType) {
            let docType = HTMLEntities.htmlDocType
            data = docType.data(using: .utf8)! // If this fails, we did something wrong in htmlDocType
            data.append(dataIn)
            injectedDTD = true // Because we don't want to output this at document write time.
        } else {
            data = dataIn
        }
        
        // Don't pass an encoding here. Let libxml2 figure it out.
        if let reader = XMLReader(withData: data, baseURL: baseURL, encoding: nil, options: 0, delegate: self) {
            var hasSetVersion = false
            var hasSetEncoding = false
            elementStack = [XMLElement]()
            isStandalone = true
            while reader.read() {
                if !hasSetVersion {
                    if let rawVersion = reader.xmlVersion {
                        version = rawVersion
                        hasSetVersion = true
                    }
                }
                if !hasSetEncoding {
                    if let rawEncoding = reader.encoding {
                        characterEncoding = rawEncoding
                        hasSetEncoding = true
                    }
                }
                try processNode(from: reader)
                if let parseError = parseError {
                    throw XMLError.generic(parseError)
                }
            }
            
            if let parseError = parseError {
                throw XMLError.generic(parseError)
            }

            // Grab some final, potential information.
            isStandalone = reader.isStandalone
            
            // We're done with these.
            elementStack = nil;
            
            // And close down the reader
            reader.close()
        }
    }
    
    internal func parser(reader: xmlTextReaderLocatorPtr, parseErrorOccurred error: String?) {
        parseError = error
    }
    
    private var parseError: String?
    private var elementStack: [XMLElement]?
    
    // MARK: - Creation
    
    public init() {
        super.init(kind: .document, options: .none)
    }
    
    public required init(kind: Kind, options: Options) {
        super.init(kind: kind, options: options)
    }

    public convenience init(contentsOf url: URL, options mask: XMLNode.Options = []) throws {
        let data = try Data(contentsOf: url)
        try self.init(data:data, options:mask)
        baseURL = url
    }

    @objc(initWithContentsOfURL:options:error:)
    public convenience init(contentsOf url: URL, options: NSXMLNodeOptions) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data, options: XMLNode.Options(rawValue: options))
        baseURL = url
    }

    public init(data: Data, options mask: XMLNode.Options = []) throws {
        super.init(kind: .document, options: mask)
        try parse(data:data)
    }
    
    public convenience init(xmlString string: String, options mask: XMLNode.Options = []) throws {
        if let data = string.data(using: .utf8) {
            try self.init(data: data, options: mask)
        } else {
            throw XMLError.invalidText("Input to \(#function) couldn't be encoding to utf8")
        }
        if self.characterEncoding == nil {
            self.characterEncoding = "UTF-8"
        }
    }
    
    public convenience init(rootElement:XMLElement) {
        self.init()
        self._rootElement = rootElement
    }
    
    // MARK: - Properties
    
    open override var rootDocument : XMLDocument? {
        return self
    }
    
    private var _rootElement : XMLElement? {
        get {
            return _children?.first(where: { (object) -> Bool in
                return object is XMLElement
            }) as? XMLElement
        }
        set(newValue) {
            if let newValue = newValue {
                self.children = [newValue]
            } else {
                self.children = []
            }
        }
    }
    // Because this is how you match the NSXML API
    open func rootElement() -> XMLElement? {
        return _rootElement
    }
    
    open func setRootElement(rootElement: XMLElement) -> Void {
        _rootElement = rootElement
    }
    
    // MARK: - Children
    
    private var _children : [XMLNode]?
    public func manipulateChildren(_ block: (inout [XMLNode]?) -> Void) {
        block(&_children)
    }

    // MARK: - Output
    
    open var xmlData : Data {
        return xmlData(options:.none)
    }
    
    open func xmlData(options: XMLNode.Options = []) -> Data {
        let encoding = String.Encoding.utf8
        /* Not sure how to do this yet.
        if let characterEncoding = characterEncoding {
            let possible = CFStringConvertIANACharSetNameToEncoding(characterEncoding)
        } else {
            encoding = .utf8
        }
        CFStringEncoding encoding = _characterEncoding ? CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)_characterEncoding) : kCFStringEncodingASCII;
        */
        let string = xmlString(options: options)
        return string.data(using: encoding)!
    }
    
    open override var stringValue: String? {
        get {
            var string = ""
            
            if let children = children {
                for child in children {
                    if let stringValue = child.stringValue {
                        string += stringValue
                    }
                }
            }
            
            return string
        }
        set(newValue) {
            removeAllChildren()
            if let newValue = newValue {
                addChild(XMLNode.text(withStringValue:newValue) as! XMLNode)
            }
        }
    }
    
    open override func xmlString(options: XMLNode.Options = []) -> String {
        var string = ""
        
        if (_children != nil && children!.count > 0) || (_dtds != nil && _dtds!.count > 0) {
            if (version != nil || characterEncoding != nil || isStandalone) && documentContentKind != .html {
                string += "<?xml"
                if let version = version {
                    string += " version=\""
                    string += version
                    string += "\""
                }
                if let characterEncoding = characterEncoding {
                    string += " encoding=\""
                    // Try to match the input file, if possible, otherwise lookup the correct string.
                    string += characterEncoding
                    string += "\""
                }
                if isStandalone {
                    string += " standalone=\"yes\""
                }
                string += "?>"
            }
            if var dtds = _dtds {
                if injectedDTD {
                    dtds.removeFirst()
                }
                if dtds.count > 0 {
                    string += "\n"
                }
                for child in dtds {
                    string += child.xmlString(options: options)
                    string += "\n"
                }
            }
            if let children = _children {
                for child in children {
                    if options.contains(.nodePrettyPrint) && !string.isEmpty {
                        string += "\n"
                    }
                    string += child.xmlString(options: options)
                }
            }
        }
        
        return string;
    }
    
    // MARK: - XSLT
    
    open func object(byApplyingXSLT xslt: Data, arguments:[String:String]) throws -> Any? {
        throw XMLError.unimplementedFeature("\(#file): \(#function)")
    }
    
    open func object(byApplyingXSLTString xslt: String, arguments: [String:String]) throws -> Any? {
        throw XMLError.unimplementedFeature("\(#file): \(#function)")
    }
    
    open func object(byApplyingXSLTAtURL xsltURL: URL, arguments: [String:String]) throws -> Any? {
        throw XMLError.unimplementedFeature("\(#file): \(#function)")
    }
    
    // MARK: - Validation
    
    open func validate() throws -> Void {
        throw XMLError.unimplementedFeature("\(#file): \(#function)")
    }
    
    // MARK: - Extensions
    
    public convenience init(string: String, options : XMLNode.Options = []) throws {
        if let data = string.data(using: .utf8, allowLossyConversion: true) {
            try self.init(data: data, options: options)
        }
        throw XMLError.invalidInput("Couldn't convert input string to utf8")
    }
    
    // MARK: - Equatable
    
    open override func equal(toNode other: XMLNode) -> Bool {
        if let typed = other as? XMLDocument {
            return (super.equal(toNode: other)
                && AJRAnyEquals(characterEncoding, typed.characterEncoding)
                && AJRAnyEquals(isStandalone, typed.isStandalone)
                && AJRAnyEquals(_documentContentKind, typed._documentContentKind)
                && AJRAnyEquals(mimeType, typed.mimeType)
                && AJRAnyEquals(version, typed.version)
                && AJRAnyEquals(baseURL, typed.baseURL)
                && AJRAnyEquals(_children, typed._children)
                && AJRAnyEquals(_dtds, typed._dtds)
            )
        }
        return false
    }
    
    public static func == (lhs: XMLDocument, rhs: XMLDocument) -> Bool {
        return lhs.isEqual(to:rhs)
    }
    
    // MARK: - Copying
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy() as! XMLDocument
        copy.characterEncoding = characterEncoding
        copy.isStandalone = isStandalone
        copy._documentContentKind = _documentContentKind
        copy.mimeType = mimeType
        copy.version = version
        copy.baseURL = baseURL
        copy.children = copyChildren() // Convenience provided by XMLNodeWithChildren
        if let dtds = _dtds {
            copy._dtds = dtds.map {
                let copy = $0.copy() as! XMLDTD
                copy.parent = self
                return copy
            }
        }
        return copy
    }
    
}

#endif
