/*
XMLDTD.swift
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
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
@objc(NSXMLDTD)
open class XMLDTD : XMLNode, XMLNodeWithChildren {
    
    // MARK: - Properties
    
    internal var entityDeclarations = OrderedDictionary<String, XMLDTDNode>()
    internal var notationDeclarations = OrderedDictionary<String, XMLDTDNode>()
    internal var elementDeclarations = OrderedDictionary<String, XMLDTDNode>()
    internal var attributeDeclarations = OrderedDictionary<String, OrderedDictionary<String, XMLDTDNode>>()

    public var publicID : String?
    public var systemID : String?

    // MARK: - Creation
    
    public convenience init(contentsOf url : URL, options: XMLNode.Options) throws {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        try self.init(withData:data, options:options)
    }
    
    internal init(withXMLNode xmlNode:xmlDtdPtr, options: XMLNode.Options) throws {
        super.init(kind: .DTDKind, options: options)

        if let name = xmlNode.pointee.name {
            self.name = String(xml:name)
        }
        
        var node = xmlNode.pointee.children
        while node != nil {
            if let child = try XMLDTDNode.node(withXMLNode:node!) {
                addChild(child)
            }
            node = node?.pointee.next
        }
        
        if let systemID = xmlNode.pointee.SystemID {
            self.systemID = String(xml:systemID)
        }
        if let externalID = xmlNode.pointee.ExternalID {
            self.publicID = String(xml: externalID)
        }
    }
    
    public convenience init(withData data: Data, options: XMLNode.Options) throws {
        if let dtd = try XMLParseDTDNode(from: data) {
            try self.init(withXMLNode:dtd, options:options)
        } else {
            throw XMLError.invalidDTD("Unable to parse DTD")
        }
    }
    
    public required init(kind: Kind, options: Options) {
        super.init(kind: kind, options: options)
    }
    
    // MARK: - Children
    
    public var _children : [XMLNode]?
    public func manipulateChildren(_ block: (inout [XMLNode]?) -> Void) {
        block(&_children)
    }
    
    public func insertChild(_ child: XMLNode, at index: Int) -> Void {
        manipulateChildren { (children) in
            if children == nil {
                children = [XMLNode]()
            }
            children?.insert(child, at: index)
            child.parent = self
        }

        if let dtdChild = child as? XMLDTDNode {
            if dtdChild.dtdKind >= .entityGeneral && dtdChild.dtdKind <= .entityPredefined {
                entityDeclarations[child.name!] = dtdChild
            } else if dtdChild.dtdKind >= .attributeCDATA && dtdChild.dtdKind <= .attributeNotation {
                let node = child as! XMLDTDAttributeDeclarationNode
                var elementChildren = attributeDeclarations[node.elementName!]
                if elementChildren == nil {
                    elementChildren = OrderedDictionary<String, XMLDTDNode>()
                    attributeDeclarations[node.elementName!] = elementChildren
                }
                elementChildren![node.name!] = dtdChild
                attributeDeclarations[node.elementName!] = elementChildren
            } else if dtdChild.dtdKind >= .elementDeclarationUndefined && dtdChild.dtdKind <= .elementDeclarationElement {
                elementDeclarations[child.name!] = dtdChild
            }
        }
    }
    
    private func detach(child: XMLNode) -> Void {
        child.detach()
        if let dtdChild = child as? XMLDTDNode {
            // Just try to remove from any / all of our indexes
            if let name = dtdChild.name {
                if dtdChild.dtdKind >= .entityGeneral && dtdChild.dtdKind <= .entityPredefined {
                    entityDeclarations.removeValue(forKey: name)
                } else if dtdChild.dtdKind >= .attributeCDATA && dtdChild.dtdKind <= .attributeNotation {
                    attributeDeclarations.removeValue(forKey:name)
                } else if dtdChild.dtdKind >= .elementDeclarationUndefined && dtdChild.dtdKind <= .elementDeclarationElement {
                    elementDeclarations.removeValue(forKey:name)
                } else {
                    notationDeclarations.removeValue(forKey: name)
                }
            }
        }
    }

    // MARK: - AJRXMLNode
    
    public override func xmlString(options: XMLNode.Options = []) -> String {
        var string = ""
        if let name = self.name {
            string += "<!DOCTYPE "
            string += name
            if let publicID = publicID {
                string += " PUBLIC \""
                string += XMLEscapedString(publicID, document: self.rootDocument, kind: .DTDKind)
                string += "\""
                if let systemID = systemID {
                    string += " \""
                    string += XMLEscapedString(systemID, document: self.rootDocument, kind: .DTDKind)
                    string += "\""
                }
            } else if let systemID = self.systemID {
                string += " SYSTEM \""
                string += XMLEscapedString(systemID, document: self.rootDocument, kind: .DTDKind)
                string += "\""
            }
            if let currentChildren = _children {
                if currentChildren.count > 0 {
                    string += " [\n"
                    for child in currentChildren {
                        string += "    "
                        string += child.xmlString(options: options)
                        string += "\n"
                    }
                    string += "]"
                }
            }
            string += ">"
        } else {
            if let currentChildren = _children {
                for child in currentChildren {
                    if let dtdNode = child as? XMLDTDNode {
                        string += "    "
                        string += dtdNode.xmlString(options: options)
                        string += "\n"
                    }
                }
            }
        }
        return string;
    }
    
    // MARK: - Accessors
    
    public func entityDeclaration(forName name: String) -> XMLDTDNode? {
        return entityDeclarations[name]
    }
    
    public func notationDeclaration(forName name: String) -> XMLDTDNode? {
        return notationDeclarations[name]
    }
    
    public func elementDeclaration(forName name: String) -> XMLDTDNode? {
        return elementDeclarations[name]
    }
    
    public func attributeDeclaration(forName name: String, elementName: String) -> XMLDTDNode? {
        return attributeDeclarations[elementName]?[name]
    }
    
    private static var predefinedEntities : [String:XMLDTDNode] {
        var entities = [String:XMLDTDNode]()
        var node : XMLDTDNode
        
        node = XMLDTDNode(kind: .DTDKind, options: .none)
        node.dtdKind = .entityPredefined
        node.name = "amp"
        node.stringValue = "&"
        entities[node.name!] = node
        
        node = XMLDTDNode(kind: .DTDKind, options: .none)
        node.dtdKind = .entityPredefined
        node.name = "lt"
        node.stringValue = "<"
        entities[node.name!] = node
        
        node = XMLDTDNode(kind: .DTDKind, options: .none)
        node.dtdKind = .entityPredefined
        node.name = "gt"
        node.stringValue = ">"
        entities[node.name!] = node

        node = XMLDTDNode(kind: .DTDKind, options: .none)
        node.dtdKind = .entityPredefined
        node.name = "apos"
        node.stringValue = "'"
        entities[node.name!] = node
        
        node = XMLDTDNode(kind: .DTDKind, options: .none)
        node.dtdKind = .entityPredefined
        node.name = "quot"
        node.stringValue = "\""
        entities[node.name!] = node
        
        return entities
    }
    
    public class func predefinedEntityDeclaration(forName name: String) -> XMLDTDNode? {
        return XMLDTD.predefinedEntities[name]
    }
    
    // MARK: - Equatable
    
    /*
     private var _children : [XMLNode]?
    internal var entityDeclarations = OrderedDictionary<String, XMLDTDNode>()
    internal var notationDeclarations = OrderedDictionary<String, XMLDTDNode>()
    internal var elementDeclarations = OrderedDictionary<String, XMLDTDNode>()
    internal var attributeDeclarations = OrderedDictionary<String, OrderedDictionary<String, XMLDTDNode>>()

    public var publicID : String?
    public var systemID : String?
*/
    public override func equal(toNode other: XMLNode) -> Bool {
        if let typed = other as? XMLDTD {
            return (super.equal(toNode: other)
                && AJRAnyEquals(_children, typed._children)
                && AJRAnyEquals(entityDeclarations, typed.entityDeclarations)
                && AJRAnyEquals(notationDeclarations, typed.notationDeclarations)
                && AJRAnyEquals(elementDeclarations, typed.elementDeclarations)
                && AJRAnyEquals(attributeDeclarations, typed.attributeDeclarations)
                && AJRAnyEquals(publicID, typed.publicID)
                && AJRAnyEquals(systemID, typed.systemID)
            )
        }
        return false
    }
    
    public static func == (lhs: XMLDTD, rhs: XMLDTD) -> Bool {
        return lhs.isEqual(to:rhs)
    }
    
    // MARK: - Copying
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy() as! XMLDTD
        copy.children = copyChildren() // Convenience provided by XMLNodeWithChildren
        copy.entityDeclarations = entityDeclarations
        copy.notationDeclarations = notationDeclarations
        copy.elementDeclarations = elementDeclarations
        copy.attributeDeclarations = attributeDeclarations
        copy.publicID = publicID
        copy.systemID = systemID
        
        return copy
    }
    
}

#endif
