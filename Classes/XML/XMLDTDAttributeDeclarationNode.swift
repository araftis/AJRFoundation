//
//  XMLDTDAttributeDeclarationNode.swift
//  radar
//
//  Created by Alex Raftis on 8/4/18.
//

import Foundation

#if os(Linux) || os(iOS) || os(tvOS) || os(watchOS)

public class XMLDTDAttributeDeclarationNode : XMLDTDNode {
    
    var enumerations = [String]()
    var elementName : String?
    var defaultUsage : XMLDTDNode.AttributeDefault = .none
    
    // MARK: - Properties
    
    var defaultValue : String? {
        set(newValue) {
            objectValue = newValue
        }
        get {
            return objectValue as? String
        }
    }
    
    // MARK: - Enumerations
    
    func insert(enumeration: String, at index: Int) -> Void {
        enumerations.insert(enumeration, at: index)
    }
    
    func add(enumeration: String) -> Void {
        insert(enumeration: enumeration,  at:enumerations.count)
    }
    
    func remove(enumeration: String) -> Void {
        if let index = enumerations.index(of:enumeration) {
            remove(enumerationAt: index)
        }
    }
    
    func remove(enumerationAt index: Int) {
        enumerations.remove(at: index)
    }
    
    func replace(enumeration: String, at index: Int) {
        remove(enumerationAt: index)
        insert(enumeration: enumeration, at: index)
    }
    
    // MARK: - Strings
    
    override public func xmlString(options: XMLNode.Options = []) -> String {
        var string = ""
        
        string += "<!ATTLIST "
        string += self.elementName!
        string += " "
        string += self.name!
        string += " "
        switch self.dtdKind {
        case .attributeCDATA:
            string += "CDATA"
        case .attributeID:
            string += "ID"
        case .attributeIDRef:
            string += "IDREF"
        case .attributeIDRefs:
            string += "IDREFS"
        case .attributeEntity:
            string += "ENTITY"
        case .attributeEntities:
            string += "ENTITIES"
        case .attributeNMToken:
            string += "NMTOKEN"
        case .attributeNMTokens:
            string += "NMTOKENS"
        case .attributeEnumeration:
            string += "("
            for (index, enumeration) in enumerations.enumerated() {
                if index > 0 {
                    string += "|"
                }
                string += enumeration
            }
            string += ")"
        case .attributeNotation:
            string += "NOTATION"
        default:
            preconditionFailure("We shouldn't be here.")
        }
        if self.dtdKind != .attributeEnumeration {
            string += " "
            switch (self.defaultUsage) {
            case .none:
                string += "#NONE"
            case .fixed:
                string += "#FIXED"
            case .implied:
                string += "#IMPLIED"
            case .required:
                string += "#REQUIRED"
            }
        }
        if let defaultValue = self.defaultValue {
            string += " \""
            string += defaultValue
            string += "\""
        }
        string += ">"
        
        return string
    }
    
    // MARK: - Equatable
    
    public override func equal(toNode other: XMLNode) -> Bool {
        if let typed = other as? XMLDTDAttributeDeclarationNode {
            return (super.equal(toNode: other)
                && Equal(enumerations, typed.enumerations)
                && Equal(elementName, typed.elementName)
                && Equal(defaultUsage, typed.defaultUsage)
            )
        }
        return false
    }
    
    public static func == (lhs: XMLDTDAttributeDeclarationNode, rhs: XMLDTDAttributeDeclarationNode) -> Bool {
        return lhs.untypedEqual(to:rhs)
    }
    
    // MARK: - Copying
    
    public override func copy() -> Any {
        let copy = super.copy() as! XMLDTDAttributeDeclarationNode
        copy.enumerations = enumerations
        copy.elementName = elementName
        copy.defaultUsage = defaultUsage
        return copy
    }
    
}

#endif
