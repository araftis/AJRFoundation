/*
 XMLReader.swift
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

internal protocol XMLParserDelegate {

    func parser(reader: xmlTextReaderLocatorPtr, parseErrorOccurred error: String?)

}

internal enum XMLNodeType : UInt8 {

    case element = 1 // XML_ELEMENT_NODE
    case attribute = 2 // XML_ATTRIBUTE_NODE
    case text = 3 // XML_TEXT_NODE
    case cdataSection = 4 // XML_CDATA_SECTION_NODE
    case entityReference = 5 // XML_ENTITY_REF_NODE
    case entity = 6 // XML_ENTITY_NODE
    case processingInstruction = 7 // XML_PI_NODE
    case comment = 8 // XML_COMMENT_NODE
    case document = 9 // XML_DOCUMENT_NODE
    case documentType = 10 // XML_DOCUMENT_TYPE_NODE
    case documentFragment = 11 // XML_DOCUMENT_FRAG_NODE
    case notation = 12 // XML_NOTATION_NODE
    case htmlDocument = 13 // XML_HTML_DOCUMENT_NODE
    case dtd = 14 // XML_DTD_NODE
    case elementDeclaration = 15 // XML_ELEMENT_DECL
    case attributeDeclaration = 16 // XML_ATTRIBUTE_DECL
    case entityDeclaration = 17 // XML_ENTITY_DECL
    case namespaceDeclaration = 18 // XML_NAMESPACE_DECL
    case xIncludeStart = 19 // XML_XINCLUDE_START
    case xIncludeEnd = 20 // XML_XINCLUDE_END
    
}

internal var XMLParserErrorHandler : xmlTextReaderErrorFunc = { (arg, messageIn, severity, locator) in
    var reader : XMLReader? = nil
    
    if let arg = arg {
        // Note that we take the value "unretained", otherwise we consume it as retained, so we release it, but causes us to free our reader.
        reader = Unmanaged<XMLReader>.fromOpaque(arg).takeUnretainedValue()
    }
    
    let message : String?
    if let messageIn = messageIn {
        message = String(validatingUTF8:messageIn)
    } else {
        message = ""
    }
    
    var baseURI : String? = nil
    if let rawBaseURI = xmlTextReaderLocatorBaseURI(locator) {
        baseURI = String(xml: rawBaseURI)
    }
    let lineNumber = xmlTextReaderLocatorLineNumber(locator)
    let formattedMessage = "\(baseURI ?? "UNKNOWN"):\(lineNumber): \(message!)"
    
    if severity == XML_PARSER_SEVERITY_ERROR {
        reader?.parser(reader:locator!, parseErrorOccurred: message!)
    } else {
        AJRLog.warning(message!)
    }
}

internal class XMLReader : XMLParserDelegate {
    
    var reader : xmlTextReaderPtr?
    var unsafeData : UnsafeMutablePointer<Int8>? // A pointer to the data passed to us.
    var delegate : XMLParserDelegate? = nil
    
    internal init?(withData data: Data, baseURL: URL? = nil, encoding: String? = "utf8", options: Int = 0, delegate: XMLParserDelegate? = nil) {
        let count = data.count
        self.unsafeData = UnsafeMutablePointer<Int8>.allocate(capacity: data.count)
        self.unsafeData?.withMemoryRebound(to: UInt8.self, capacity: count) { retypedData in
            data.copyBytes(to: retypedData, count: count)
        }
        self.delegate = delegate
        self.reader = xmlReaderForMemory(self.unsafeData, Int32(count), baseURL?.absoluteString, encoding, Int32(options | Int(XML_PARSE_RECOVER.rawValue)))
        print("\(xmlTextReaderGetParserProp(self.reader, Int32(XML_PARSER_SUBST_ENTITIES.rawValue)))")
        if let reader = reader {
            xmlTextReaderSetErrorHandler(reader, XMLParserErrorHandler, Unmanaged.passRetained(self).toOpaque())
        } else {
            return nil
        }
    }
    
    deinit {
        unsafeData?.deallocate()
    }
    
    func read() -> Bool {
        let result = xmlTextReaderRead(reader)
//        if result < 0 {
//            print("hard failure: \(result)")
//        }
        return result == 1
    }
    
    var nodeType : XMLNodeType {
        return XMLNodeType(rawValue:UInt8(xmlTextReaderNodeType(reader)))!
    }
    
    var name : String? {
        return String(xml:xmlTextReaderConstName(reader))
    }
    
    var hasValue : Bool {
        return xmlTextReaderHasValue(reader) != 0
    }
    
    var value : String? {
        return hasValue ? String(xml:xmlTextReaderConstValue(reader)!) : nil
    }
    
    var isEmptyElement : Bool {
        return xmlTextReaderIsEmptyElement(reader) != 0
    }
    
    func moveToNextAttribute() -> Bool {
        return xmlTextReaderMoveToNextAttribute(reader) == 1
    }
    
    var isStandalone : Bool {
        return xmlTextReaderStandalone(reader) != 0
    }
    
    var xmlVersion : String? {
        if let raw = xmlTextReaderConstXmlVersion(reader) {
            return String(xml: raw)
        }
        return nil
    }
    
    var encoding : String? {
        if let raw = xmlTextReaderConstEncoding(reader) {
            return String(xml: raw)
        }
        return nil
    }
    
    var currentNode : xmlNodePtr? {
        return xmlTextReaderCurrentNode(reader)
    }
    
    func close() -> Void {
        xmlTextReaderClose(reader)
    }
    
    func parser(reader: xmlTextReaderLocatorPtr, parseErrorOccurred error: String?) {
        delegate?.parser(reader: reader, parseErrorOccurred: error)
    }
    
}

#endif
