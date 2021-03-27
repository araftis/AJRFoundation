
import XCTest

import AJRFoundation

class AJRTrimmingFormatterTests: XCTestCase {

    func testTrimmingFormatter() {
        let formatter = AJRTrimmingFormatter()
        
        XCTAssert(formatter.string(for: "   This\nis\na\ntest") == "This")
        XCTAssert(formatter.string(for: 10) == "10")
        XCTAssert(formatter.string(for: [10]) == "(")
        XCTAssert(formatter.string(for: nil) == nil)
        
        var test : AnyObject?
        var error : NSString?
        
        XCTAssert(formatter.getObjectValue(&test, for: "  test  ", errorDescription: &error))
        XCTAssert(test is String && (test as! String) == "test")
    }
    
    func testCoding() {
        let formatter = AJRTrimmingFormatter()
        let new = AJRCopyCodableObject(formatter, nil);
        
        XCTAssert(new is AJRTrimmingFormatter)
    }
    
}
