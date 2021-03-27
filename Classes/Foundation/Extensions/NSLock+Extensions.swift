
import Foundation

public extension NSLocking {
    
    func lock(using block: () -> Void) -> Void {
        lock()
        defer {
            unlock()
        }
        block()
    }
    
}
