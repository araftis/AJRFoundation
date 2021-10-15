/*
NSObject+Extensions.swift
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

/**
 This is a dupicate of an Obj-C class, because the Obj-C class is failing under some circumstances when bridging to Swift.
 */

//private typealias AJRObserverBlock = (Any?, String?, [NSKeyValueChangeKey:Any]?) -> Void

private class AJRObjectObserver : NSObject, AJRInvalidation {

    weak var observedObject : AnyObject?
    var keyPath : String
    var options : NSKeyValueObservingOptions
    var block : AJRObserverBlock

    init(observedObject: AnyObject, keyPath: String, options: NSKeyValueObservingOptions, block: @escaping AJRObserverBlock) {
        self.observedObject = observedObject
        self.keyPath = keyPath
        self.options = options
        self.block = block

        super.init()

        self.observedObject?.addObserver(self, forKeyPath: keyPath, options: options, context:nil)
    }

    func invalidate() -> Void {
        print("invalidate")
        if let observedObject = observedObject {
            observedObject.removeObserver(self, forKeyPath: keyPath)
            self.observedObject = nil
        }
    }

    deinit {
        print("deinit")
        self.invalidate()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("change: \(keyPath!)")
        block(object, keyPath, change)
    }

    override var description : String {
        if let observedObject = observedObject {
            return "<\(self.descriptionPrefix): object: \(observedObject), keyPath: \(keyPath), block: \(String(describing: block))>"
        }
        return "<\(self.descriptionPrefix), object: <invalidated>, keyPath: \(keyPath), block: \(String(describing: block))>"
    }

}

@objc
public extension NSObject {
    
    var descriptionPrefix : String {
        get {
            return "\(Self.self): 0x\(String(unsafeBitCast(self, to:Int.self), radix:16))"
        }
    }

    func add(observer: AnyObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, block: @escaping AJRObserverBlock) -> AJRInvalidation {
        return AJRObjectObserver(observedObject: self, keyPath: keyPath, options: options, block: block)
    }

}
