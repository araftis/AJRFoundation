
import Foundation

public extension Dictionary {
    
    func value(forKeyPath keyPath:String) -> Any? {
        return self._bridgeToObjectiveC().value(forKeyPath:keyPath)
    }
    
    subscript<T>(key: Key, defaultValue: T) -> T {
        if let value = self[key] as? T {
            return value
        }
        return defaultValue
    }
    
}
