
import XCTest

class XMLElement_ExtensionsTests: XCTestCase {

    func testAttributes() {
        let element = XMLElement(name: "test", stringValue: "Some text");
        let attribute1 = XMLNode.attribute(withName: "a1", stringValue: "test1") as! XMLNode
        let attribute2 = XMLNode.attribute(withName: "a2", stringValue: "test2") as! XMLNode
        let attribute3 = XMLNode.attribute(withName: "a3", stringValue: "test3") as! XMLNode

        element.addAttribute(attribute1)
        XCTAssert(element.description == "<test a1=\"test1\">Some text</test>")
        element.addAttribute(attribute3)
        XCTAssert(element.description == "<test a1=\"test1\" a3=\"test3\">Some text</test>")
        element.replaceAttribute(attribute1, with: attribute2)
        XCTAssert(element.description == "<test a2=\"test2\" a3=\"test3\">Some text</test>")
    }

}
