
import XCTest

import AJRFoundation

class Collection_ExtensionsTests: XCTestCase {

    func testJoining() {
        XCTAssert([1].componentsJoinedByString(separator: ", ", twoValueSeparator: " and ", finalSeparator: ", and ") == "1")
        XCTAssert([1, 2].componentsJoinedByString(separator: ", ", twoValueSeparator: " and ", finalSeparator: ", and ") == "1 and 2")
        XCTAssert([1, 2, 3].componentsJoinedByString(separator: ", ", twoValueSeparator: " and ", finalSeparator: ", and ") == "1, 2, and 3")
    }
    
    func testJSON() {
        var string = [1].jsonString
        XCTAssert(string == "[\n  1\n]")
        string = ["one":1].jsonString
        XCTAssert(string == "{\n  \"one\" : 1\n}")
        string = ["one":Collection_ExtensionsTests()].jsonString
        XCTAssert(string == nil)
    }

}
