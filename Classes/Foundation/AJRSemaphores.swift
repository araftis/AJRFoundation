
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
