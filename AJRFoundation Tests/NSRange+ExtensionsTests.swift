
import XCTest

class NSRange_ExtensionsTests: XCTestCase {

    func testNotFound() {
        let notFound = NSRange.notFound
        XCTAssert(notFound.isNotFound)
    }

}
