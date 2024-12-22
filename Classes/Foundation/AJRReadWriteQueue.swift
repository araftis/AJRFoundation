//
//  AJRReadWriteQueue.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 12/8/23.
//

import Foundation

@objcMembers
open class AJRReadWriteQueue : NSObject {

    internal var queue : DispatchQueue

    public init(label: String? = nil) {
        queue = DispatchQueue(label: label ?? "AJRReadWriteQueue", attributes: .concurrent)
    }

    public override convenience init() {
        self.init(label: nil)
    }

    // MARK: Accessing the Queue

    @objc(executeForRead:)
    open func executeForRead(_ block: @escaping () -> Void) -> Void {
        queue.sync(execute: block)
    }

    @objc(executeForReadAndReturnValue:)
    open func executeForReadAndReturnValue(_ block: @escaping () -> Any?) -> Any? {
        var returnValue : Any? = nil;

        queue.sync(execute: {
            returnValue = block()
        })

        return returnValue
    }

    open func executeForRead<T>(_ block: @escaping () -> T) -> T {
        var returnValue : T? = nil

        queue.sync(execute: {
            returnValue = block()
        })

        return returnValue!
    }

    @objc(executeForWrite:)
    open func executeForWrite(_ block: @escaping () -> Void) -> Void {
        queue.async(flags: [.barrier], execute: block)
    }

    @objc(executeAndWaitForWrite:)
    open func executeAndWaitForWrite(_ block: @escaping () -> Void) -> Void {
        let semaphore = DispatchSemaphore(value: 0)
        queue.async(flags: [.barrier]) {
            block()
            semaphore.signal()
        }
        semaphore.wait()
    }

    open func executeForWrite<T>(_ block: @escaping () -> T) -> T {
        let semaphore = DispatchSemaphore(value: 0)
        var returnValue: T? = nil

        queue.async(flags: [.barrier]) {
            returnValue = block()
            semaphore.signal()
        }

        return returnValue!
    }

}
