/*
 AJRGateTests.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
        
        if let string = output.ajr_dataAsString(using: String.Encoding.utf8.rawValue) {
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
