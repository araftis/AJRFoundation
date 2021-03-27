
import XCTest

import AJRFoundation

class Dispatch_ExtensionsTests: XCTestCase {

    func testDispatch() {
        var value = 0
        
        DispatchQueue.asyncOrImmediatelyOnMainThread {
            value = 1
        }
        
        XCTAssert(value == 1)
        
        let outerSemaphore = AJRBasicSemaphore()
        DispatchQueue.global(qos: .default).async {
            let innerSemaphore = AJRBasicSemaphore()
            DispatchQueue.asyncOrImmediatelyOnMainThread {
                value = 2
                innerSemaphore.signal() // Signal thread can exit run loop
                outerSemaphore.signal() // Signal main thread can exit run loop
            }
            RunLoop.current.spinRunLoop(inMode: .default, waitingFor: innerSemaphore)
        }
        
        // Value should still equal 1, because the above code can't execute until we ping the run loop.
        XCTAssert(value == 1)
        
        // This should allow the above code to run
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: outerSemaphore)
        
        // And then our value should be equal to 2.
        XCTAssert(value == 2)
    }

}
