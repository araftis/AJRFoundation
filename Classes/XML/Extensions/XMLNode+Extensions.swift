//
//  XMLNodeExtensions.swift
//  radar-core
//
//  Created by Alex Raftis on 9/6/18.
//

import Foundation

public protocol XMLDebug {
    // Methods defined by XMLNode that we'll be using.
    var childCount : Int { get }
    var children : [XMLNode]? { get }
    var kind : XMLNode.Kind { get }
    
    func debugTree(indent: Int) -> String
    var debugTreeDescription : String { get }
    var debugTree: String { get }
}

public extension XMLDebug {

    func debugTree(indent: Int) -> String {
        var string = ""
        
        string += debugTreeDescription
        if let children = children, childCount > 0 {
            string += "\n"
            for child in children {
                string += "".padding(toLength: (indent + 1) * 4, withPad: " ", startingAt: 0)
                string += child.debugTree(indent: indent + 1)
                string += "\n"
            }
        }
        
        return string
    }
    
    var debugTree: String {
        return debugTree(indent: 0)
    }
    
}

extension XMLNode : XMLDebug {

    public var debugTreeDescription : String {
        get {
            if kind == .text {
                return "<\(self.kind): \(stringValue ?? "")>"
            } else if kind == .element {
                return "<\(kind): \(name ?? "???")>"
            }
            return "<\(self.kind)>"
        }
    }
    
}

extension XMLNode.Kind : CustomStringConvertible {

    public static var allCases : [XMLNode.Kind] {
        return [
            .invalid,
            .document,
            .element,
            .attribute,
            .namespace,
            .processingInstruction,
            .comment,
            .text,
            .DTDKind,
            .entityDeclaration,
            .attributeDeclaration,
            .elementDeclaration,
            .notationDeclaration,
        ]
    }
    
    public var description : String {
        switch self {
        case .invalid:
            return "invalid"
        case .document:
            return "document"
        case .element:
            return "element"
        case .attribute:
            return "attribute"
        case .namespace:
            return "namespace"
        case .processingInstruction:
            return "processingInstruction"
        case .comment:
            return "comment"
        case .text:
            return "text"
        case .DTDKind:
            return "DTDKind"
        case .entityDeclaration:
            return "entityDeclaration"
        case .attributeDeclaration:
            return "attributeDeclaration"
        case .elementDeclaration:
            return "elementDeclaration"
        case .notationDeclaration:
            return "notationDeclaration"
        #if os (Linux)
        case .elementDeclarationContent:
            return "elementDeclarationContent"
        #endif
        @unknown default:
            AJRLog.warning("Unknown XMLNode.Kind: \(self.rawValue)")
            return "unknown(\(self.rawValue))"
        }
    }
    
}

public extension XMLNode {

    func findNode(name: String, value: String? = nil, forAttribute attributeName: String? = nil) -> XMLNode? {
        var found : XMLNode? = nil
        
        enumerateDescendants { (node, done) in
            if let node = node as? XMLElement,
                node.name?.lowercased() == name {
                let attribute : XMLNode? = (attributeName != nil) ? node.attribute(forName: attributeName!.lowercased()) : nil
                if attributeName == nil
                    || (attribute != nil && attribute!.stringValue == value) {
                    found = node
                    done = true
                }
            }
        }
        
        return found
    }
    
#if os(iOS) || os(tvOS) || os(watchOS)
    func enumerateChildren(using block: (_ node: XMLNode, _ stop: inout Bool) -> Void) -> Void {
        if let children = children {
            for child in children {
                var stop = false
                block(child, &stop)
                if stop {
                    break
                }
            }
        }
    }
#endif
    
    func enumerateDescendants(using block: @escaping (_ node: XMLNode, _ stop: inout Bool) -> Void) -> Void {
        var done = false
        
        block(self, &done)
        if !done, let children = children {
            for node in children {
                node.enumerateDescendants { (innerNode, innerStop) in
                    block(innerNode, &innerStop)
                    done = innerStop
                }
                if done {
                    break
                }
            }
        }
    }

// Seems like they decided to define this in Foundation. If it's not on iOS, add this code back in for that platform.
//    var nextSibling : XMLNode? {
//        if let children = self.parent?.children,
//            let index = children.firstIndex(of: self),
//            index + 1 < children.count {
//            return children[index + 1]
//        }
//        return nil
//    }

}
