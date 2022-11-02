/*
 AJRActivityTests.swift
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
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

extension AJRActivityIdentifier {
    
    static let test = AJRActivityIdentifier("test")
    
}

class AJRTestActivity : AJRActivity {
    
}

class AJRActivityTests: XCTestCase, AJRActivityDelegate {

    var observerToken : AJRActivityObserverToken!
    var addSemaphore : AJRSemaphore = AJRBasicSemaphore()
    var removeSemaphore : AJRSemaphore = AJRBasicSemaphore()
    var didCallAddMessage : Bool = false
    var messageSemaphore : AJRSemaphore?
    var progressSemaphore : AJRSemaphore?
    var returnValueForStopRequest : Bool = true

    override func setUp() {
        AJRActivity.instanceClass = AJRTestActivity.self
        observerToken = AJRActivity.addObserver({ (action, activity, activities) in
            switch action {
            case .added:
                self.addSemaphore.signal()
            case .removed:
                self.removeSemaphore.signal()
            @unknown default:
                break
            }
        })
    }
    
    override func tearDown() {
        AJRActivity.removeObserver(observerToken!)
    }
    
    func testCreation() {
        var activity : AJRActivity? = nil
        
        activity = AJRActivity()
        XCTAssert(activity != nil)
        XCTAssert(activity?.identifier == nil)
        
        // Just a simple check for when AJRInterface isn't involved.
        XCTAssert(activity!.view == nil)
    }
    
    func testActivities() {
        let activity = AJRActivity(identifier: .test)
        
        // We have to observe the activity to actually hit all the code.
        activity.addObserver(self, forKeyPath: "message", options: [], context: nil)
        
        XCTAssert(AJRActivity.instanceClass == AJRTestActivity.self)
        XCTAssert(activity is AJRTestActivity)
        
        AJRActivity.add(toActivities: activity)
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: addSemaphore)
        XCTAssert(AJRActivity.activities.contains(activity))
        
        messageSemaphore = AJRBasicSemaphore()
        activity.addDelegate(self)
        activity.message = "Test 1"
        XCTAssert(activity.message == "Test 1")
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: messageSemaphore)
        XCTAssert(didCallAddMessage)
        XCTAssert(activity.messages.count == 1)
        
        messageSemaphore = AJRBasicSemaphore()
        didCallAddMessage = false;
        activity.message = "Test 2"
        XCTAssert(activity.message == "Test 2")
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: messageSemaphore)
        XCTAssert(didCallAddMessage)
        XCTAssert(activity.messages.count == 1)

        messageSemaphore = AJRBasicSemaphore()
        didCallAddMessage = false;
        activity.addMessage("Test 3")
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: messageSemaphore)
        XCTAssert(activity.message == "Test 3")
        XCTAssert(didCallAddMessage)
        XCTAssert(activity.messages.count == 2)
        
        messageSemaphore = AJRBasicSemaphore()
        activity.popMessage()
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: messageSemaphore)
        XCTAssert(activity.message == "Test 2")
        XCTAssert(activity.messages.count == 1)

        XCTAssert(activity.ellapsedTime > 0)
        
        activity.progressMin = 0
        XCTAssert(activity.progressMin == 0)
        activity.progressMax = 100
        XCTAssert(activity.progressMax == 100)
        for x in stride(from: 0, to: 100, by: 10) {
            progressSemaphore = AJRBasicSemaphore()
            activity.progress = CGFloat(x)
            RunLoop.current.spinRunLoop(inMode: .default, waitingFor: progressSemaphore)
            progressSemaphore = nil
        }
        
        returnValueForStopRequest = false
        activity.stop()
        XCTAssert(activity.isStopRequested == false)
        returnValueForStopRequest = true
        activity.stop()
        XCTAssert(activity.isStopRequested == true)
        
        AJRActivity.remove(fromActivities: activity)
        RunLoop.current.spinRunLoop(inMode: .default, waitingFor: removeSemaphore)
        XCTAssert(!AJRActivity.activities.contains(activity))

        activity.removeDelegate(self)
    }
    
    func activity(_ activity: AJRActivity, willDisplayMessage message: String) {
        didCallAddMessage = true
    }
    
    func activity(_ activity: AJRActivity, didDisplayMessage message: String) {
        messageSemaphore?.signal()
    }
    
    func activity(_ activity: AJRActivity, willRemoveMessage message: String) {
        messageSemaphore?.signal()
    }
    
    func activity(_ activity: AJRActivity, didSetProgress percent: Double) {
        progressSemaphore?.signal()
    }
    
    func activityWillStop(_ activity: AJRActivity) -> Bool {
        return returnValueForStopRequest
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    }
    
}
