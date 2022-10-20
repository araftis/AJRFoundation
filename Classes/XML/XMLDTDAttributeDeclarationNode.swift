/*
XMLDTDAttributeDeclarationNode.swift
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

import Foundation

#if os(Linux) || os(iOS) || os(tvOS) || os(watchOS)

@objcMembers
@objc(NSXMLDTDAttributeDeclarationNode)
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
        if let index = enumerations.firstIndex(of:enumeration) {
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
                && AJRAnyEquals(enumerations, typed.enumerations)
                && AJRAnyEquals(elementName, typed.elementName)
                && AJRAnyEquals(defaultUsage, typed.defaultUsage)
            )
        }
        return false
    }
    
    public static func == (lhs: XMLDTDAttributeDeclarationNode, rhs: XMLDTDAttributeDeclarationNode) -> Bool {
        return lhs.isEqual(to:rhs)
    }
    
    // MARK: - Copying
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy() as! XMLDTDAttributeDeclarationNode
        copy.enumerations = enumerations
        copy.elementName = elementName
        copy.defaultUsage = defaultUsage
        return copy
    }
    
}

#endif
