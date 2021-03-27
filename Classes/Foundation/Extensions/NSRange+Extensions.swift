
import Foundation

public extension NSRange {
    
    static var notFound : NSRange {
        return NSRange(location: NSNotFound, length: 0)
    }
    
    var isNotFound : Bool {
        return location == NSNotFound
    }
    
}
