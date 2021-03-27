
import XCTest

import AJRFoundation

class Dictionary_ExtensionsTests: XCTestCase {

    func testKeyPath() {
        let dictionary = ["one": ["two":2]]
        
        XCTAssert(AJRAnyEquals(dictionary.value(forKeyPath: "one.two"), 2))
    }
    
    func testDefaults() {
        let dictionary = ["one":1, "two":2]
        
        XCTAssert(AJRAnyEquals(dictionary["one", 1], 1))
        XCTAssert(AJRAnyEquals(dictionary["two", 2], 2))
        XCTAssert(AJRAnyEquals(dictionary["three", 3] as Int, 3))
    }

}
