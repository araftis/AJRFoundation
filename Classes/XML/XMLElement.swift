
#if os(Linux) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation
import radar_core
import libxml2

public class XMLElement : XMLNode, XMLParserDelegate, XMLNodeWithChildren {
    
    private var _attributes = OrderedDictionary<String, XMLNode>()
    public var attributes : [XMLNode]? {
        get {
            return Array(_attributes.values)
        }
        set(newValue) {
            _attributes.removeAll()
            if let newValue = newValue {
                for node in newValue {
                    if let name = node.name {
                        _attributes[name] = node
                    }
                }
            }
        }
    }
    public var _namespaces = OrderedDictionary<String, XMLNode>()
    public var namespaces : [XMLNode]? {
        get {
            return Array(_namespaces.values)
        }
        set(newValue) {
            _namespaces.removeAll()
            if let newValue = newValue {
                for node in newValue {
                    if let name = node.name {
                        _namespaces[name] = node
                    }
                }
            }
        }
    }
    
    // MARK: - Parsing

    // These two variables are tansient and only used during xml parsing
    private var parseError: String? = nil
    private var elementStack: [XMLElement]? = nil
    
    private func processElement(from reader: XMLReader) throws -> Void {
        if let name = reader.name {
            var element: XMLElement? = nil
            let isEmpty = reader.isEmptyElement // This means the element was immediate terminate, i.e. <br />
            
            if elementStack?.count == 0 {
                self.name = name;
                self.children = []
                element = self
            } else {
                element = XMLNode.element(withName:name) as? XMLElement
                elementStack?.last?.addChild(element!)
            }
            elementStack?.append(element!)
            
            while reader.moveToNextAttribute(){
                let attributeNodeType = reader.nodeType
                if attributeNodeType == .attribute {
                    if let attributeName = reader.name {
                        element?.addAttribute(XMLNode.attribute(withName: attributeName, stringValue: reader.value) as! XMLNode)
                    }
                } else {
                    RadarCore.log.warn("Hum, didn't handle node type \(attributeNodeType) when parsing attributes.")
                }
            }
            if isEmpty {
                try processElementClose(byName:name)
            }
        }
    }
    
    private func processElementClose(byName name: String) throws -> Void {
        // Nothing to really do here, really. We should just pop the last node. That being said, let's do a little validation.
        let currentNode = elementStack?.last
        if !Equal(name, currentNode?.name) {
            RadarCore.log.warn("Found close tag for \(name), but expected to be closing: \(currentNode?.name ?? "UNKNOWN")")
        } else {
            currentNode?.normalizeAdjacentTextNodesPreservingCDATA(true)
            elementStack?.removeLast()
        }
    }
    
    private func processElementClose(from reader: XMLReader) throws -> Void {
        try processElementClose(byName: reader.name!)
    }
    
    private func processComment(from reader: XMLReader) throws -> Void {
        var value = ""
        // We normally expect it to have a value, but you never know.
        if let rawValue = reader.value {
            value = rawValue
        }
        let comment = XMLNode.comment(withStringValue:value) as! XMLNode
        elementStack?.last?.addChild(comment)
    }
    
    private func processEntityReference(from reader: XMLReader) throws -> Void {
        if let entityName = reader.name {
            if let value = try XMLStringForEntity(rawEntity: entityName, document: nil) {
                let child = XMLNode.text(withStringValue:value) as! XMLNode
                elementStack?.last?.addChild(child)
            } else {
                throw XMLError.invalidEntity(entityName)
            }
        }
    }
    
    private func processCData(from reader: XMLReader) throws -> Void {
        if let rawValue = reader.value {
            if let value = String(xml: rawValue) {
                elementStack?.last?.addChild(XMLNode.text(withStringValue: value) as! XMLNode)
            } else {
                throw XMLError.invalidCData(rawValue)
            }
        }
    }
    
    private func processText(from reader: XMLReader) throws -> Void {
        if let rawValue = reader.value {
            if let value = String(xml:rawValue) {
                elementStack?.last?.addChild(XMLNode.text(withStringValue: value) as! XMLNode)
            } else {
                throw XMLError.invalidText(rawValue)
            }
        }
    }
    
    private func processNode(from reader: XMLReader) throws -> Void {
        let type = reader.nodeType
        let name = reader.name
        
        if type == .element {
            try processElement(from: reader)
        } else if type == .comment {
            try processComment(from: reader)
        } else if type == .elementDeclaration {
            try processElementClose(from: reader)
        } else if type == .entityReference {
            try processEntityReference(from: reader)
        } else if type == .cdataSection {
            try processCData(from: reader)
        } else if type == .text {
            try processText(from: reader)
        } else if type == .dtd && name == "#text" {
            try processText(from: reader)
        } else {
            throw XMLError.invalidNodeType("\(type)")
        }
    }
    
    private func parse(data: Data) throws -> Void {
        if let reader = XMLReader(withData: data, baseURL: nil, encoding: "utf8", options: 0, delegate: self) {
            defer {
                // And close down the reader
                reader.close()
                
                // For everything to potentially garbage collect.
                elementStack = nil
            }
            
            elementStack = [XMLElement]()
            
            while reader.read() {
                try processNode(from: reader)
                if let parseError = parseError {
                    throw XMLError.generic(parseError)
                }
            }
        }
    }

    public func parser(reader: xmlTextReaderLocatorPtr, parseErrorOccurred error: String?) {
        parseError = error
    }
    
    // MARK: - Creation
    
    public init(name: String, uri: String? = nil, stringValue: String? = nil) {
        super.init(kind: .element, options: .none)
        self.name = name
        self.uri = uri
        if let stringValue = stringValue {
            addChild(XMLNode.text(withStringValue: stringValue) as! XMLNode)
        }
    }
    
    public convenience init?(xmlString string: String) throws {
        self.init(kind: .element, options: .none)
        if let data = string.data(using: .utf8) {
            try parse(data: data)
        } else {
            throw XMLError.invalidInput("Could not convert string \"\(string)\" to UTF-8 data.")
        }
    }
    
    public required init(kind: XMLNode.Kind, options: XMLNode.Options) {
        super.init(kind: kind, options: options)
        self.name = ""
        self.uri = nil
    }
    
    // MARK: - Elements by name
    
    public func elements(forName name: String) -> [XMLElement]? {
        return _children?.filter { (object) -> Bool in
                return object.kind == .element && Equal(object.name, name)
            } as! [XMLElement]?
    }

    public func elements(forLocalName localName: String, url: String?) -> [XMLElement]? {
        return _children?.filter { (object) -> Bool in
                return object.kind == .element && Equal(XMLNode.localName(forName: object.name!), localName)
            } as! [XMLElement]?
    }
    
    // MARK: - String Value
    
    public override var stringValue : String? {
        get {
            var string = ""

            if let currentChildren = _children {
                for child in currentChildren {
                    if let childString = child.stringValue {
                        if !childString.isEmpty {
                            string += childString
                        }
                    }
                }
            }
            
            return string
        }
        set(newValue) {
            super.stringValue = newValue
        }
    }
    
    // MARK: - Attributes
    
    public func addAttribute(_ attribute: XMLNode) {
        assert(attribute.name != nil)
        assert(attribute.kind == .attribute)
        _attributes[attribute.name!] = attribute
    }
    
    public func removeAttribute(forName name: String) {
        _attributes.removeValue(forKey: name)
    }
    
    public func setAttributesWith(_ attributes: [String:String]) {
        _attributes.removeAll()
        for (key, value) in attributes {
            _attributes[key] = XMLNode.attribute(withName: key, stringValue: value) as? XMLNode
        }
    }
    
    public func attribute(forName name: String) -> XMLNode? {
        return _attributes[name]
    }
    
    public func attribute(forLocalName localName: String, uri: String?) -> XMLNode? {
        if let attributes = self.attributes {
            return attributes.find(predicate: { (value) -> Bool in
                return Equal(XMLNode.localName(forName: value.name!), localName) && Equal(value.uri, uri)
            })
        }
        return nil
    }
    
    @discardableResult public func replaceAttribute(_ attribute: XMLNode, with newAttribute: XMLNode) -> XMLNode? {
        return _attributes.updateValue(forKey: attribute.name!, withNewKey: newAttribute.name!, andValue: newAttribute)
    }
    
    // MARK: - Namespaces
    
    public func addNamespace(_ namespace: XMLNode) -> Void {
        assert(namespace.name != nil)
        assert(namespace.kind == .namespace)
        _namespaces[namespace.name!] = namespace
    }
    
    public func removeNamespace(forPrefix name:String) -> Void {
        _namespaces.removeValue(forKey: name)
    }
    
    public func namespace(forPrefix name: String) -> XMLNode? {
        return _namespaces[name]
    }
    
    public func resolveNamespace(forName name: String) -> XMLNode? {
        let range = name.range(of: ":")
        var namespaceName: String
        if let range = range {
            namespaceName = String(name.prefix(upTo: range.lowerBound))
        } else {
            namespaceName = ""
        }
        return _namespaces[namespaceName] ?? XMLNode.predefinedNamespace(forPrefix:namespaceName)
    }
    
    public func resolvePrefix(forNamespaceURI namespaceURI: String) -> String? {
        var prefix : String? = nil;
        
        var namespaces = _namespaces
        for (key, value) in XMLNode.predefinedNamespaces {
            namespaces[key] = value
        }
        for (_, namespace) in namespaces {
            if namespace.stringValue == namespaceURI {
                prefix = namespace.name
                break
            }
        }
        
        return prefix;
    }
    
    // MARK: - Children
    
    public var _children : [XMLNode]?
    public func manipulateChildren(_ block: (inout [XMLNode]?) -> Void) {
        block(&_children)
    }

    public func normalizeAdjacentTextNodesPreservingCDATA(_ preserve: Bool) -> Void {
        if _children != nil {
            var count = _children!.count
            var x = 0
            while x < count - 1 {
                let child = _children![x]
                if child.kind == .text {
                    var nextChild : XMLNode = _children![x + 1]
                    while x < count - 1 && nextChild.kind == .text {
                        let value = nextChild.stringValue
                        if value != nil && !value!.isEmpty {
                            child.stringValue = child.stringValue! + value!
                        }
                        _children!.remove(at:x + 1)
                        count -= 1
                        if x < count - 1 {
                            nextChild = _children![x + 1]
                        }
                    }
                }
                x += 1
            }
            // OK, we've merged nodes, now lets see if we should delete any blank nodes
            if _children!.count > 0 {
                x = 0
                while x < _children!.count {
                    let child = _children![x]
                    if child.kind == .text && child.stringValue?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
                        removeChild(at: x)
                        x -= 1
                    }
                    x += 1
                }
            }
            // Do we trim off the end, too?
        }
    }
    
    // MARK: - XML Strings
    
    private func depthToRoot() -> Int {
        var node : XMLNode? = self.parent
        var depth = 0
        
        while node != nil {
            depth += 1
            node = node?.parent
        }
        
        return depth
    }
    
    private func allChildrenAreText() -> Bool {
        if let children = _children {
            for child in children {
                if child.kind != .text {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    public override func xmlString(options: XMLNode.Options = []) -> String {
        var string = ""
        var indent = 0
        let allChildrenAreText = self.allChildrenAreText()
        
        if options.contains(.nodePrettyPrint) {
            indent = self.depthToRoot()
        }
        
        string += "<"
        string += self.name!
        for (_, namespace) in _namespaces {
            string += " "
            string += namespace.xmlString(options:options)
        }
        for (_, attribute) in _attributes {
            string += " "
            string += attribute.xmlString(options:options)
        }
        string += ">"
        if let children = _children {
            for child in children {
                if indent > 0 && !allChildrenAreText {
                    if !string.hasSuffix("\n") {
                        // Only append a newline if our previous child didn't provide a newline.
                        string += "\n"
                    }
                    string += "".padding(toLength: indent * 4, withPad: " ", startingAt: 0)
                }
                string += child.xmlString(options:options)
            }
        }
        if indent > 0 && (_children != nil && _children!.count > 0) && !allChildrenAreText {
            if !string.hasSuffix("\n") {
                // Only append a newline if our last child didn't provide a newline.
                string += "\n"
            }
            string += "".padding(toLength: (indent - 1) * 4, withPad: " ", startingAt: 0)
        }
        string += "</"
        string += self.name!
        string += ">"
        
        return string
    }
    
    // MARK: - Additions to Foundation API
    
    public func addAttribute(withName name: String, stringValue value: String) {
        addAttribute(XMLNode.attribute(withName: name, stringValue: value) as! XMLNode)
    }
    
    // MARK: - Equatable
    
    public override func equal(toNode other: XMLNode) -> Bool {
        if let typed = other as? XMLElement {
            return (super.equal(toNode: other)
                && Equal(_children, typed._children)
                && Equal(_attributes, typed._attributes)
                && Equal(_namespaces, typed._namespaces)
            )
        }
        return false
    }
    
    public static func == (lhs: XMLElement, rhs: XMLElement) -> Bool {
        return lhs.untypedEqual(to:rhs)
    }
    
    // MARK: - Copying
    
    public override func copy() -> Any {
        let copy = super.copy() as! XMLElement
        copy.children = copyChildren() // Convenience provided by XMLNodeWithChildren
        copy._attributes = _attributes.copy() as! OrderedDictionary<String, XMLNode>
        copy._namespaces = _namespaces.copy() as! OrderedDictionary<String, XMLNode>
        return copy
    }
    
}

#endif
