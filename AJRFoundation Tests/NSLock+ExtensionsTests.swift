
import XCTest

import AJRFoundation

class NSLock_ExtensionsTests: XCTestCase {

    func testLocking() {
        let lock = NSLock()
        
        lock.lock {
            // We shouldn't be able to re-acquire the lock, since we not using an NSRecursiveLock.
            XCTAssert(!lock.try())
        }
        
        // Now we should be able to get the lock.
        XCTAssert(lock.try())
        lock.unlock()
    }

}
