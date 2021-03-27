
import Foundation

public extension URL {
    
    init!(parsableString string: String) {
        if let nsURL = NSURL(parsableString: string) {
            self.init(string: nsURL.absoluteString!)
        } else {
            return nil
        }
    }
    
    // I'm going with [String:String] until it's proven I need to go with AnyHashable:Any.
    var queryDictionary: [String:String]? {
        return (self as NSURL).queryDictionary
    }
    
    func appendingQueryValue(_ value: String, key: String) -> URL {
        return (self as NSURL).appendingQueryValue(value, forKey: key)
    }
    
    var pathUTI : String? {
        return (self as NSURL).pathUTI
    }
    
}
