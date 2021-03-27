
import XCTest

import AJRFoundation

class AJRGateTests: XCTestCase {

    func testGates() {
        let gate = AJRGate()
        var preSemaphore = AJRCountdownSemaphore(count: 3)
        var postSemaphore = AJRCountdownSemaphore(count: 3)
        let output = OutputStream.toMemory()
        
        AJRLogSetOutputStream(output, .info)
        
        XCTAssert(!gate.isOpen)

        DispatchQueue.global(qos: .default).async {
            preSemaphore.signal()
            AJRLog.info("thread 1 will wait")
            gate.wait()
            AJRLog.info("thread 1 will exit")
            postSemaphore.signal()
        }
        DispatchQueue.global(qos: .default).async {
            preSemaphore.signal()
            AJRLog.info("thread 2 will wait")
            gate.wait()
            AJRLog.info("thread 2 will exit")
            postSemaphore.signal()
        }
        DispatchQueue.global(qos: .default).async {
            preSemaphore.signal()
            AJRLog.info("thread 3 will wait")
            gate.wait(forTimeInterval: 100000.0)
            AJRLog.info("thread 3 will exit")
            postSemaphore.signal()
        }
        
        // Make sure all three threads are running.
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: preSemaphore);
        
        Thread.sleep(until: Date(timeIntervalSinceNow: 2.0))
        XCTAssert(gate.waiting == 3)
        XCTAssert(gate.description.contains("3 threads waiting"))
        
        // Open the gate.
        gate.open()
        
        // Make sure all three threads continue.
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: postSemaphore);
        
        XCTAssert(gate.waiting == 0)
        
        if let string = output.ajr_dataAsString(usingEncoding: String.Encoding.utf8.rawValue) {
            for x in 1...3 {
                XCTAssert(string.contains("thread \(x) will wait"))
                XCTAssert(string.contains("thread \(x) will exit"))
            }
        }
        
        AJRLogSetOutputStream(nil, .info)
        
        XCTAssert(gate.close()) // Re-close the gate.
        XCTAssert(gate.waiting == 0)
        XCTAssert(!gate.isOpen)
        
        preSemaphore = AJRCountdownSemaphore(count: 1)
        postSemaphore = AJRCountdownSemaphore(count: 1)

        DispatchQueue.global(qos: .default).async {
            preSemaphore.signal()
            gate.wait()
            postSemaphore.signal()
        }

        // Make sure all three threads are running.
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: preSemaphore);
        
        Thread.sleep(until: Date(timeIntervalSinceNow: 2.0))
        XCTAssert(gate.waiting == 1)
        XCTAssert(gate.description.contains("1 thread waiting"))
        
        // Open the gate.
        gate.open()
        
        // Make sure all three threads continue.
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: postSemaphore);
        
        XCTAssert(gate.waiting == 0)
    }

}
