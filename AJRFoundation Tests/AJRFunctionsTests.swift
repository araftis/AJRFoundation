
import XCTest

import AJRFoundation

class AJRFunctionsTests: XCTestCase {

    func testClamp() {
        XCTAssert(AJRClamp(50, min: 0, max: 100) == 50)
        XCTAssert(AJRClamp(-50, min: 0, max: 100) == 0)
        XCTAssert(AJRClamp(150, min: 0, max: 100) == 100)
    }
    
    func testFileNameMatching() {
        XCTAssert(AJRFileNameMatch(pattern: "*.*", in: "test.txt", options: []))
    }
    
    func testForceRetains() {
        autoreleasepool {
            // NOTE: This code is a little dicey, because we're testing code that's a little iffy. It's possible this could break in the future. In fact, it's likely, if you notice that the numbers in the asserts are somewhat contrived based on observing what retain/release calls the compiler is putting on the object automatically.
            let object = NSObject()
            let baseRetainCount = AJRGetRetainCount(object)
            
            XCTAssert(baseRetainCount > 0)
            
            AJRForceRetain(object)
            XCTAssert(AJRGetRetainCount(object) == baseRetainCount + 2)
            
            AJRForceRetain(object)
            XCTAssert(AJRGetRetainCount(object) == baseRetainCount + 3)
            
            AJRForceRelease(object)
            XCTAssert(AJRGetRetainCount(object) == baseRetainCount + 2)
            
            autoreleasepool {
                AJRForceAutorelease(object)
            }
            XCTAssert(AJRGetRetainCount(object) == baseRetainCount + 1)
        }
    }

}
