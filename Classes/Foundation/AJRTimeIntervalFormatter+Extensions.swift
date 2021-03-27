
import Foundation

public extension AJRTimeIntervalFormatter {
    
    class func timeInterval(from string: String) throws -> TimeInterval {
        var timeInterval : TimeInterval = 0
        
        try getTimeInterval(&timeInterval, from: string)
        
        return timeInterval
    }
    
}
