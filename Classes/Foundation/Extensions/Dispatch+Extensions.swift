
import Foundation

public extension DispatchQueue {
    
    /**
     Runs or dispatches the block to the main thread.
     
     Checks to see if we're on the main thread, and if we are, then execute the block immediately. If we're not on the main thread, asynchronously dispatch the block to the main thread.
     
     - parameter block: The block to execute.
     */
    static func asyncOrImmediatelyOnMainThread(execute block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
    
}

