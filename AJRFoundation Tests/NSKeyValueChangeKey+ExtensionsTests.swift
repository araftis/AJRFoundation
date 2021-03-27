
import XCTest

class NSKeyValueChangeKeyTests: XCTestCase {

    func testDescriptions() {
        XCTAssert("\(NSKeyValueChangeKey.indexesKey)" == "indexes")
    }

}
