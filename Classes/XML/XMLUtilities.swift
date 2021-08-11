/*
XMLUtilities.swift
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

public enum XMLError : Error {
    
    case generic(String)
    case invalidEntity(String)
    case invalidNodeType(String)
    case invalidCData(String)
    case invalidText(String)
    case unimplementedFeature(String)
    case invalidDTD(String)
    case invalidInput(String)

}

internal extension String {
    
    init?(xml:UnsafePointer<xmlChar>) {
        var castedXML : UnsafePointer<Int8>? = nil
        xml.withMemoryRebound(to: Int8.self, capacity: 20) { input in
            castedXML = input
        }
        self.init(validatingUTF8:castedXML!)
    }
    
}

internal var xmlSpecials : CharacterSet = {
    return CharacterSet(charactersIn: "<>&\"'")
}()

internal func XMLEscapedString(_ string:String, document : XMLDocument?, kind : XMLNode.Kind) -> String {
    var newString = ""
    var range: Range<String.Index>?
    var searchRange: Range<String.Index> = Range(uncheckedBounds: (lower: string.startIndex, upper: string.endIndex))
    repeat {
        range = string.rangeOfCharacter(from: xmlSpecials, options: .caseInsensitive, range: searchRange)
        if let range = range {
            newString += string[searchRange.lowerBound ..< range.lowerBound]
            for character in string[range] {
                switch character {
                case "\"":
                    if kind == .text {
                        newString += "\""
                    } else {
                        newString += "&quot;"
                    }
                case "'":
                    if kind == .text || kind == .attribute {
                        newString += "'"
                    } else {
                        newString += "&apos;"
                    }
                case "<":
                    newString += "&lt;"
                case ">":
                    newString += "&gt;"
                case "&":
                    newString += "&amp;"
                default:
                    newString += String(character)
                }
            }
            searchRange = Range(uncheckedBounds: (lower: range.upperBound, upper: string.endIndex))
        }
    } while range != nil && range!.lowerBound < string.endIndex

    if searchRange.lowerBound < string.endIndex {
        newString += string[searchRange.lowerBound ..< string.endIndex]
    }
    
    return newString
}

internal func XMLStringForEntity(rawEntity: String, document: XMLDocument?) throws -> String? {
    var result : String?
    
    if rawEntity.hasPrefix("#") {
        var character : Int?
        if rawEntity.hasPrefix("#x") && rawEntity.count > 2 {
            character = Int(rawEntity.dropFirst(2), radix:16)
        } else if rawEntity.count > 1 {
            character = Int(rawEntity.dropFirst(1), radix:10)
        }
        if let character = character {
            if let scalar = UnicodeScalar(character) {
                result = String(scalar)
            } else {
                throw XMLError.invalidEntity(rawEntity)
            }
        } else {
            result = "&\(rawEntity);"
        }
    } else {
        if let entity = XMLDTD.predefinedEntityDeclaration(forName: rawEntity) {
            // This means the entity is predefined, so just get it's string value, because these won't "recurse" to more resolutions.
            result = entity.stringValue
            // I don't think this code is needed, because it turns out we inject all the html entities into's the Doc's DTD, which means the above case should resolve things just fine.
//        } else if document?.documentContentKind == .html, let entity = HTMLEntities.predefinedHTMLEntityDeclaration(forName: rawEntity) {
//            result = entity.stringValue
        } else {
            if let dtds = document?.dtds {
                for dtd in dtds {
                    if let entity = dtd.entityDeclaration(forName: rawEntity) {
                        // These can contain references to additional entities, so we have to resolve those as well
                        if let stringValue = entity.stringValue {
                            result = try XMLStringByResolvingEntities(input: stringValue, document: document)
                            break
                        }
                    }
                }
            }
        }
    }
    
    return result
}

internal func XMLStringByResolvingEntities(input string: String, document: XMLDocument?) throws -> String? {
    var newString = ""
    var range: Range<String.Index>?
    var searchRange: Range<String.Index> = Range(uncheckedBounds: (lower: string.startIndex, upper: string.endIndex))
    
    repeat {
        range = string.range(of:"&", options:String.CompareOptions(rawValue:0), range:searchRange)
        if let range = range {
            let semicolonRange: Range<String.Index>?
            
            newString += string[searchRange.lowerBound ..< range.lowerBound]
            
            semicolonRange = string.range(of:";", options:String.CompareOptions(rawValue:0), range:Range(uncheckedBounds: (lower: range.upperBound, upper: searchRange.upperBound)))
            if let semicolonRange = semicolonRange {
                let rawEntity = string[range.upperBound ..< semicolonRange.lowerBound]
                if let entity = try XMLStringForEntity(rawEntity: String(rawEntity), document: document) {
                    newString += entity
                } else {
                    // Hum, the docs implied we should just include the raw entity, but that's not the behavior I see from NSXMLNode, so we'll match it.
//                   // Couldn't find an entity, so leave it alone.
//                   newString += "&"
//                   newString += rawEntity
//                   newString += ";"
                }
                searchRange = Range(uncheckedBounds: (lower: semicolonRange.upperBound, upper: string.endIndex))
            } else {
                newString += "&"
                searchRange = Range(uncheckedBounds: (lower: range.upperBound, upper: string.endIndex))
            }
        }
    } while range != nil && searchRange.lowerBound < string.endIndex
    
    if searchRange.lowerBound < string.endIndex {
        // Any remaining part of the input string.
        newString += string[searchRange.lowerBound ..< string.endIndex]
    }
    
    return newString
}

internal func XMLParseDTDNode(from data:Data) throws -> xmlDtdPtr? {
    var dtd : xmlDtdPtr?
    let unsafeData = UnsafeMutablePointer<Int8>.allocate(capacity: data.count)
    unsafeData.withMemoryRebound(to: UInt8.self, capacity: data.count) { retypedData in
        data.copyBytes(to: retypedData, count: data.count)
    }

    if let buf = xmlParserInputBufferCreateMem(unsafeData, Int32(data.count), XML_CHAR_ENCODING_NONE) {
        dtd = xmlIOParseDTD(nil, buf, XML_CHAR_ENCODING_NONE);
    }
    return dtd
}

internal extension UnsafeMutablePointer where Pointee == xmlNode {
    
    func asDtdNode(_  body: (xmlDtdPtr) throws -> Void) rethrows -> Void {
        try self.withMemoryRebound(to: xmlDtd.self, capacity: MemoryLayout.size(ofValue: xmlDtd.self)) { dtdNode in
            try body(dtdNode)
        }
    }
    
    func asElement(_  body: (xmlElementPtr) throws -> Void) rethrows -> Void {
        try self.withMemoryRebound(to: xmlElement.self, capacity: MemoryLayout.size(ofValue: xmlElement.self)) { elementNode in
            try body(elementNode)
        }
    }
    
    func asAttribute(_  body: (xmlAttributePtr) throws -> Void) rethrows -> Void {
        try self.withMemoryRebound(to: xmlAttribute.self, capacity: MemoryLayout.size(ofValue: xmlAttribute.self)) { attributeNode in
            try body(attributeNode)
        }
    }
    
    func asEntity(_  body: (xmlEntityPtr) throws -> Void) rethrows -> Void {
        try self.withMemoryRebound(to: xmlEntity.self, capacity: MemoryLayout.size(ofValue: xmlEntity.self)) { entityNode in
            try body(entityNode)
        }
    }
    
}

#endif
