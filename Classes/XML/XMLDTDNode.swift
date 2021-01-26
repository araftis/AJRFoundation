//
//  XMLDTDNode.swift
//  radar
//
//  Created by Alex Raftis on 8/4/18.
//

#if os(Linux) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation
import radar_core
import libxml2

public class XMLDTDNode : XMLNode {

    // MARK: - Enumerations
    
    public enum AttributeDefault : Int {
        case none = 1
        case required
        case implied
        case fixed
    }
    
    public enum DTDKind : Int, Strideable {
        
        public typealias Stride = Int
        
        case entityGeneral = 1
        case entityParsed
        case entityUnparsed
        case entityParameter
        case entityPredefined
        
        case attributeCDATA
        case attributeID
        case attributeIDRef
        case attributeIDRefs
        case attributeEntity
        case attributeEntities
        case attributeNMToken
        case attributeNMTokens
        case attributeEnumeration
        case attributeNotation
        
        case elementDeclarationUndefined
        case elementDeclarationEmpty
        case elementDeclarationAny
        case elementDeclarationMixed
        case elementDeclarationElement

        public func distance(to other: XMLDTDNode.DTDKind) -> Int {
            return Stride(other.rawValue) - Stride(self.rawValue)
        }
        
        public func advanced(by n: Int) -> XMLDTDNode.DTDKind {
            return DTDKind(rawValue: numericCast(Stride(self.rawValue) + n))!
        }
    }
    
    // MARK: - Properties

    public var dtdKind : DTDKind = .entityGeneral
    public var publicID : String?
    public var systemID : String?
    public override var objectValue: Any? {
        get {
            return super.objectValue
        }
        set(newValue) {
            if let objectValue = super.objectValue as? XMLDTDElementContent {
                objectValue.detach()
            }
            super.objectValue = newValue
            if let newValue = newValue as? XMLDTDElementContent {
                newValue.parent = self
            }
        }
    }
    
    // MARK: - Creation
    
    public convenience init(xmlString string: String) throws {
        self.init(kind: .DTDKind, options: .none)
    }
    
    public required init(kind: Kind, options: Options) {
        super.init(kind: kind, options: options)
    }
    
    public class func elementDeclarationNode(withXMLNode libraryNode: xmlNodePtr) -> XMLDTDNode {
        let node = XMLDTDNode(kind: .elementDeclaration, options: .none)
        
        libraryNode.asElement { elementNode in
            node.dtdKind = .elementDeclarationUndefined
            node.name = String(xml: libraryNode.pointee.name)
            switch elementNode.pointee.etype {
            case XML_ELEMENT_TYPE_UNDEFINED:
                node.dtdKind = .elementDeclarationUndefined
            case XML_ELEMENT_TYPE_ANY:
                node.dtdKind = .elementDeclarationAny
            case XML_ELEMENT_TYPE_EMPTY:
                node.dtdKind = .elementDeclarationEmpty
            case XML_ELEMENT_TYPE_MIXED:
                node.objectValue = XMLDTDElementContent(withElementDeclarationContent: elementNode.pointee.content)
                node.dtdKind = .elementDeclarationMixed
            case XML_ELEMENT_TYPE_ELEMENT:
                node.objectValue = XMLDTDElementContent(withElementDeclarationContent: elementNode.pointee.content)
                node.dtdKind = .elementDeclarationElement
            default:
                break
            }
        }
    
        return node
    }
    
    public class func attributeDeclarationNode(withXMLNode genericNode: xmlNodePtr) -> XMLDTDNode {
        let node = XMLDTDAttributeDeclarationNode(kind: .attributeDeclaration, options: .none)
        
        genericNode.asAttribute { attributeNode in
            if let prefix = attributeNode.pointee.prefix {
                node.name = "\(String(xml: prefix) ?? ""):\(String(xml: attributeNode.pointee.name) ?? "")"
            } else {
                node.name = String(xml: attributeNode.pointee.name)
            }
            node.elementName = String(xml: attributeNode.pointee.elem)
            switch attributeNode.pointee.atype {
            case XML_ATTRIBUTE_CDATA:
                node.dtdKind = .attributeCDATA
            case XML_ATTRIBUTE_ID:
                node.dtdKind = .attributeID
            case XML_ATTRIBUTE_IDREF:
                node.dtdKind = .attributeIDRef
            case XML_ATTRIBUTE_IDREFS:
                node.dtdKind = .attributeIDRefs
            case XML_ATTRIBUTE_ENTITY:
                node.dtdKind = .attributeEntity
            case XML_ATTRIBUTE_ENTITIES:
                node.dtdKind = .attributeEntities
            case XML_ATTRIBUTE_NMTOKEN:
                node.dtdKind = .attributeNMToken
            case XML_ATTRIBUTE_NMTOKENS:
                node.dtdKind = .attributeNMTokens
            case XML_ATTRIBUTE_ENUMERATION:
                node.dtdKind = .attributeEnumeration
                var enumeration = attributeNode.pointee.tree;
                while enumeration != nil {
                    if let name = enumeration?.pointee.name {
                        node.add(enumeration: String(xml: name)!)
                    }
                    enumeration = enumeration?.pointee.next
                }
            case XML_ATTRIBUTE_NOTATION:
                node.dtdKind = .attributeNotation
            default:
                break
            }
            if let defaultValue = attributeNode.pointee.defaultValue {
                node.defaultValue = String(xml: defaultValue)
            }
            switch attributeNode.pointee.def {
            case XML_ATTRIBUTE_NONE:
                node.defaultUsage = .none
            case XML_ATTRIBUTE_FIXED:
                node.defaultUsage = .fixed
            case XML_ATTRIBUTE_IMPLIED:
                node.defaultUsage = .implied
            case XML_ATTRIBUTE_REQUIRED:
                node.defaultUsage = .required
            default:
                break
            }
        }
        
        return node;
    }
    
    public class func entityDeclarationNode(withXMLNode genericNode: xmlNodePtr) -> XMLDTDNode {
        let node = XMLDTDNode(kind: .entityDeclaration, options: .none)
        
        genericNode.asEntity { entityNode in
            node.name = String(xml: entityNode.pointee.name)
            node.stringValue = String(xml: entityNode.pointee.content)
            if let systemID = entityNode.pointee.SystemID {
                node.systemID = String(xml: systemID)
            }
            if let externalID = entityNode.pointee.ExternalID {
                node.publicID = String(xml: externalID)
            }
            switch (entityNode.pointee.etype) {
            case XML_INTERNAL_GENERAL_ENTITY:
                node.dtdKind = .entityGeneral
            case XML_EXTERNAL_GENERAL_PARSED_ENTITY:
                node.dtdKind = .entityParsed
            case XML_EXTERNAL_GENERAL_UNPARSED_ENTITY:
                node.dtdKind = .entityUnparsed
            case XML_INTERNAL_PARAMETER_ENTITY:
                node.dtdKind = .entityParameter
            case XML_EXTERNAL_PARAMETER_ENTITY:
                node.dtdKind = .entityParameter
            case XML_INTERNAL_PREDEFINED_ENTITY:
                node.dtdKind = .entityPredefined
            default:
                break
            }
        }
        
        return node
    }
    
    public class func node(withXMLNode xmlNode: xmlNodePtr) throws -> XMLNode? {
        var node : XMLNode? = nil
        
        if xmlNode.pointee.type == XML_COMMENT_NODE {
            node = comment(withStringValue: String(xml: xmlNode.pointee.content) ?? "") as? XMLNode
        } else if xmlNode.pointee.type == XML_ELEMENT_DECL {
            node = elementDeclarationNode(withXMLNode: xmlNode)
        } else if xmlNode.pointee.type == XML_ATTRIBUTE_DECL {
            node = attributeDeclarationNode(withXMLNode: xmlNode)
        } else if xmlNode.pointee.type == XML_ENTITY_DECL {
            node = entityDeclarationNode(withXMLNode: xmlNode)
        } else {
            RadarCore.log.warn("we should handle: \(xmlNode.pointee.type)")
        }
        
        return node
    }
    
    // MARK: - Output
    
//    public override var stringValue : String? {
//        get {
//            var stringValue : String? = nil
//            
//            switch self.dtdKind {
//            case .entityGeneral ... .entityPredefined:
//                stringValue = super.stringValue
//                
//            case .attributeCDATA ... .attributeNotation:
//                stringValue = super.stringValue
//                
//            case .elementDeclarationUndefined:
//                stringValue = "UNDEFINED"
//            case .elementDeclarationEmpty:
//                stringValue = "EMPTY"
//            case .elementDeclarationAny:
//                stringValue = "ANY"
//            case .elementDeclarationElement:
//                fallthrough
//            case .elementDeclarationMixed:
//                if let content = self.objectValue as? XMLDTDElementContent {
//                    stringValue = content.stringValue
//                }
//            default:
//                break
//            }
//            
//            return stringValue ?? ""
//        }
//        set(newValue) {
//            super.stringValue = newValue
//        }
//    }
    
    public override func xmlString(options: XMLNode.Options = []) -> String {
        var string = ""
        if dtdKind >= .entityGeneral && dtdKind <= .entityPredefined {
            string += "<!ENTITY "
            if dtdKind == .entityParameter {
                string += "% "
            }
            string += self.name!
            string += " \""
            string += self.stringValue!
            string += "\">"
        } else if dtdKind >= .elementDeclarationUndefined && dtdKind <= .elementDeclarationElement {
            string += "<!ELEMENT "
            string += self.name!
            string += " "
            switch self.dtdKind {
            case .entityGeneral ... .entityPredefined:
                break
            case .attributeCDATA ... .attributeNotation:
                break
            case .elementDeclarationUndefined:
                string += "UNDEFINED"
            case .elementDeclarationEmpty:
                string += "EMPTY"
            case .elementDeclarationAny:
                string += "ANY"
            case .elementDeclarationElement:
                fallthrough
            case .elementDeclarationMixed:
                if let content = self.objectValue as? XMLDTDElementContent {
                    string += content.xmlString(options: options)
                }
            default:
                break
            }
            string += ">"
        }
        return string
    }

    // MARK: - Equatable
    
    public override func equal(toNode other: XMLNode) -> Bool {
        if let typed = other as? XMLDTDNode {
            return (super.equal(toNode: other)
                && Equal(dtdKind, typed.dtdKind)
                && Equal(publicID, typed.publicID)
                && Equal(systemID, typed.systemID)
            )
        }
        return false
    }
    
    public static func == (lhs: XMLDTDNode, rhs: XMLDTDNode) -> Bool {
        return lhs.untypedEqual(to:rhs)
    }
    
    // MARK: - Copying
    
    public override func copy() -> Any {
        let copy = super.copy() as! XMLDTDNode
        copy.dtdKind = dtdKind
        copy.publicID = publicID
        copy.systemID = systemID
        return copy
    }
    
}

public func > (lhs:XMLDTDNode.DTDKind, rhs:XMLDTDNode.DTDKind) -> Bool {
    return lhs.rawValue > rhs.rawValue
}

public func >= (lhs:XMLDTDNode.DTDKind, rhs:XMLDTDNode.DTDKind) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

public func < (lhs:XMLDTDNode.DTDKind, rhs:XMLDTDNode.DTDKind) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func <= (lhs:XMLDTDNode.DTDKind, rhs:XMLDTDNode.DTDKind) -> Bool {
    return lhs.rawValue <= rhs.rawValue
}

#endif
