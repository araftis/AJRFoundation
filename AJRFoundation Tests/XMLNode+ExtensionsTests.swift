//
//  XMLNodeTests.swift
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 9/14/19.
//

import XCTest
import AJRFoundation

class XMLNodeTests: XCTestCase {

    func testDebug() {
        let document = XMLDocument()
        let child = XMLElement(name: "child")
        
        child.addAttribute("value", forName: "test")
        document.addChild(child)
        
        XCTAssert(document.debugTree == "<document>\n    <element: child>\n")
        
        var text : XMLNode = XMLNode.text(withStringValue: "Test") as! XMLNode
        XCTAssert(text.debugTree == "<text: Test>")
        
        text = XMLNode(kind: .text)
        XCTAssert(text.debugTree == "<text: >")
        
        text = XMLNode(kind: .element)
        XCTAssert(text.debugTree == "<element: ???>")
    }

    func testFinding() -> Void {
        let element = XMLElement(name: "p")
        let thisIs = XMLNode.text(withStringValue: "This is ") as! XMLNode
        let b = XMLElement(name: "b")
        let bold = XMLNode.text(withStringValue: "bold") as! XMLNode
        let period = XMLNode.text(withStringValue: ".") as! XMLNode
        
        XCTAssert(element.description == "<p></p>")
        element.addChild(thisIs)
        XCTAssert(element.description == "<p>This is </p>")
        element.insertChild(period, after: thisIs)
        XCTAssert(element.description == "<p>This is .</p>")
        element.insertChild(b, before: period)
        XCTAssert(element.description == "<p>This is <b></b>.</p>")
        b.addChild(bold)
        XCTAssert(element.description == "<p>This is <b>bold</b>.</p>")
        b.addAttribute("heavy", forName: "weight")
        XCTAssert(element.description == "<p>This is <b weight=\"heavy\">bold</b>.</p>")

        XCTAssert(element.findNode(name: "b") == b)
        XCTAssert(element.findNode(name: "b", value: "heavy", forAttribute: "weight") == b)
        XCTAssert(thisIs.nextSibling == b)
        
        var all = Set<XMLNode>(element.children!)
        element.enumerateChildren { (node, stop) in
            XCTAssert(all.contains(node))
            all.remove(node)
        }
        XCTAssert(all.count == 0)
        
        element.enumerateDescendants { (node, stop) in
            if node == bold {
                stop = true
            }
            XCTAssert(node != period)
        }
    }
    
    func testDescriptions() -> Void {
        for kind in XMLNode.Kind.allCases {
            XCTAssert(!kind.description.hasPrefix("unknown"))
        }
        XCTAssert(XMLNode.Kind(rawValue: 500)!.description.hasPrefix("unknown"))
        
        XCTAssert(XMLNode(kind: .text).debugTreeDescription == "<text: >", "String should have equaled: \(XMLNode(kind: .text).debugTreeDescription)");
    }
}
