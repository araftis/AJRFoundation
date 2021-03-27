
import Foundation

public extension AJRTranslator {
    
    subscript(key: String) -> String {
        get {
            return value(forKey: key) as! String
        }
    }
    
}

public extension NSObject {

    class var translator : AJRTranslator  {
        return AJRTranslator(for: self)
    }
    
    var translator : AJRTranslator {
        return ajr_translator
    }

}
