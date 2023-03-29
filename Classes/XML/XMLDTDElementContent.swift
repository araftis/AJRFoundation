/*
 XMLDTDElementContent.swift
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
@objc(NSXMLDTDElementContent)
public class XMLDTDElementContent : XMLNode {
    
    // MARK: - Enumerations
    
    public enum Occurrance : Int {
        case once     = 1 // XML_ELEMENT_CONTENT_ONCE
        case optional = 2 // XML_ELEMENT_CONTENT_OPT
        case multiple = 3 // XML_ELEMENT_CONTENT_MULT
        case plus     = 4 // XML_ELEMENT_CONTENT_PLUS
        
        public init!(_ elementContentOccurance: xmlElementContentOccur) {
            self.init(rawValue:Int(elementContentOccurance.rawValue))
        }
    }
    
    public enum ElementContentType : Int {
        case processedData  = 1 // XML_ELEMENT_CONTENT_PCDATA
        case element        = 2 // XML_ELEMENT_CONTENT_ELEMENT
        case sequence       = 3 // XML_ELEMENT_CONTENT_SEQ
        case or             = 4 // XML_ELEMENT_CONTENT_OR
        
        public init!(_ elementContentType: xmlElementContentType) {
            self.init(rawValue:Int(elementContentType.rawValue))
        }
    }

    // MARK: - Properties
    
    public var occurance : Occurrance = .once
    public var elementType : ElementContentType = .processedData
    public var hasPCData : Bool {
        if elementType == .processedData {
            return true
        }
        if let currentChildren = _children {
            for child in currentChildren {
                if child.hasPCData {
                    return true
                }
            }
        }
        return false
    }
    public var _children : [XMLDTDElementContent]?
    public override var children : [XMLNode]? {
        get {
            return _children
        }
        set(newValue) {
            if let currentChildren = _children {
                for child in currentChildren {
                    child.detach()
                }
            }
            if let newChildren = newValue {
                if _children != nil {
                    _children!.removeAll()
                }
                for child in newChildren {
                    if let child = typedChild(child) {
                        addChild(child)
                    }
                }
            } else {
                _children = nil
            }
        }
    }

    // MARK: - Creation
    
    public init(withElementDeclarationContent elementContent: xmlElementContentPtr) {
        super.init(kind: .elementDeclarationContent, options: .none)
        
        switch elementContent.pointee.type {
        case XML_ELEMENT_CONTENT_PCDATA:
            self.name = "#PCDATA"
            self.elementType = ElementContentType(elementContent.pointee.type)
            self.occurance = Occurrance(elementContent.pointee.ocur)
        case XML_ELEMENT_CONTENT_SEQ:
            self.name = nil // We have no name?
            self.elementType = ElementContentType(elementContent.pointee.type)
            self.occurance = Occurrance(elementContent.pointee.ocur)
            var child = XMLDTDElementContent(withElementDeclarationContent:elementContent.pointee.c1)
            addChild(child)
            child = XMLDTDElementContent(withElementDeclarationContent: elementContent.pointee.c2)
            // Merge child that're sequences.
            if child.elementType == .sequence {
                if let grandchildren = child.children {
                    insertChildren(grandchildren, at: childCount)
                }
            } else {
                addChild(child)
            }
        case XML_ELEMENT_CONTENT_OR:
            self.name = nil; // We have no name?
            self.elementType = ElementContentType(elementContent.pointee.type)
            self.occurance = Occurrance(elementContent.pointee.ocur)
            var child = XMLDTDElementContent(withElementDeclarationContent: elementContent.pointee.c1)
            addChild(child)
            child = XMLDTDElementContent(withElementDeclarationContent: elementContent.pointee.c2)
            // Merge child that're ors.
            if child.elementType == .or {
                if let grandchildren = child.children {
                    insertChildren(grandchildren, at: childCount)
                }
            } else {
                addChild(child)
            }
        case XML_ELEMENT_CONTENT_ELEMENT:
            self.name = String(xml: elementContent.pointee.name)
            self.elementType = ElementContentType(elementContent.pointee.type)
            self.occurance = Occurrance(elementContent.pointee.ocur)
            break;
        default:
            break
        }
    }
    
    public required init(kind: Kind, options: Options) {
        super.init(kind: kind, options: options)
    }

    // MARK: - Children
    
    private func checkChildren() {
        if _children == nil {
            _children = [XMLDTDElementContent]()
        }
    }
    
    internal func typedChild(_ child : XMLNode) -> XMLDTDElementContent? {
        if let child = child as? XMLDTDElementContent {
            return child
        }
        AJRLog.warning("Attempt to add a child to a a XMLDTDElementContent that isn't an XMLDTDElementContent: \(child)")
        return nil
    }
    
    public func insertChild(_ child: XMLNode, at index:Int) {
        if let child = typedChild(child) {
            checkChildren()
            _children!.insert(child, at: index)
            child.parent = self
        }
    }
    
    public func insertChildren(_ children: [XMLNode], at index: Int) {
        for (childIndex, child) in children.enumerated() {
            insertChild(child, at: index + childIndex)
        }
    }
    
    public func removeChild(at index: Int) {
        if _children != nil {
            let child = _children![index]
            child.detach()
            _children!.remove(at: index)
        } else {
            preconditionFailure("node has no children")
        }
    }
    
    public func addChild(_ child: XMLNode) {
        insertChild(child, at: childCount)
    }
    
    public func replaceChild(at index: Int, with node: XMLNode) {
        if let node = typedChild(node) {
            removeChild(at: index)
            insertChild(node, at: index)
        }
    }
    
    // MARK: - Strings
    
    internal func shouldEnclose() -> Bool {
        let parent = self.parent as? XMLDTDElementContent
        return parent == nil || (parent!.elementType != .sequence && parent!.elementType != .or)
    }
    
    public override func xmlString(options: XMLNode.Options = []) -> String {
        var string = ""
        
        switch self.elementType {
        case .processedData:
            if shouldEnclose() {
                string += "(#PCDATA)"
            } else {
                string += "#PCDATA"
            }
        case .element:
            if shouldEnclose() {
                string += "("
                string += self.name!
                string += ")"
            } else {
                string += self.name!
            }
        case .sequence:
            string += "("
            if let currentChildren = _children {
                for (index, child) in currentChildren.enumerated() {
                    if (index > 0) {
                        string += ", "
                    }
                    string += child.xmlString(options: options)
                }
            }
            string += ")"
        case .or:
            string += "("
            if let currentChildren = _children {
                for (index, child) in currentChildren.enumerated() {
                    if (index > 0) {
                        string += " | "
                    }
                    string += child.xmlString(options: options)
                }
            }
            string += ")"
        }
        switch self.occurance {
        case .once:
            break;
        case .plus:
            string += "+"
            break;
        case .multiple:
            string += "*"
            break;
        case .optional:
            string += "?"
            break;
        }
        
        return string;
    }

    // MARK: - Equatable
    
    /*
     public var occurance : Occurrance = .once
     public var elementType : ElementContentType = .processedData
     public var _children : [XMLDTDElementContent]?
     */
    public override func isEequal(_ other: Any?) -> Bool {
        if let typed = other as? XMLDTDElementContent {
            return (super.equal(toNode: other)
                && AJRAnyEquals(occurance, typed.occurance)
                && AJRAnyEquals(elementType, typed.elementType)
                && AJRAnyEquals(_children, typed._children)
            )
        }
        return false
    }
    
    public static func == (lhs: XMLDTDElementContent, rhs: XMLDTDElementContent) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    // MARK: - Copying
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy() as! XMLDTDElementContent
        if let children = _children {
            copy._children = children.map { return $0.copy() as! XMLDTDElementContent }
        }
        copy.occurance = occurance
        copy.elementType = elementType
        return copy
    }
    
}

#endif
