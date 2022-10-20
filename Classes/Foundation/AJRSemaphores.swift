/*
AJRSemaphores.swift
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

import Foundation

@objcMembers
public class AJRBasicSemaphore : NSObject, AJRSemaphore {
    
    internal var semaphore : DispatchSemaphore
    
    public override init() {
        self.semaphore = DispatchSemaphore(value: 0)
        super.init()
    }
    
    public init(value: Int) {
        self.semaphore = DispatchSemaphore(value: value)
        super.init()
    }
    
    public class func semaphore() -> AJRBasicSemaphore {
        return AJRBasicSemaphore()
    }
    
    public class func semaphore(value: Int) -> AJRBasicSemaphore {
        return AJRBasicSemaphore(value: value)
    }
    
    @discardableResult
    public func signal() -> Int {
        return semaphore.signal()
    }
    
    public func wait() -> Void {
        semaphore.wait()
    }
    
    @discardableResult
    public func wait(timeout: TimeInterval) -> Bool {
        return semaphore.wait(timeout: .now() + .milliseconds(Int(timeout * 1000))) == .success
    }
    
}

@objcMembers
public class AJRCountdownSemaphore : NSObject, AJRSemaphore {

    internal var count : Int
    internal var condition : NSCondition
    
    public init(count: Int) {
        self.count = count
        self.condition = NSCondition()
        super.init()
    }
    
    @discardableResult
    public func signal() -> Int {
        var newCount : Int = 0
        
        condition.lock()
        if count >= 0 {
            count -= 1
            newCount = count
            if count == 0 {
                condition.broadcast()
            }
        }
        condition.unlock()
        
        return newCount
    }
    
    public func wait() -> Void {
        wait(timeout: Date.distantFuture.timeIntervalSinceNow)
    }
    
    @discardableResult
    public func wait(timeout: TimeInterval) -> Bool {
        let deadline = Date(timeIntervalSinceNow: timeout)

        condition.lock()
        defer {
            condition.unlock()
        }
        while count > 0 {
            if !condition.wait(until: deadline) && Date() > deadline {
                return false
            }
        }
        
        return true
    }
    
}
