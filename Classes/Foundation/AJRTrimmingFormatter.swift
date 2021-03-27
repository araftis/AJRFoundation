
import Foundation

@objcMembers
open class AJRTrimmingFormatter : Formatter {
    
    public override init() {
        super.init()
    }

    open override func string(for obj: Any?) -> String? {
        if let untrimmedString = obj as? String {
            var string = untrimmedString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if let index = string.firstIndex(of: "\n") {
                string = String(string[string.startIndex ..< index])
            }
            
            return string
        } else if let object = obj {
            var string = String(describing: object).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if let index = string.firstIndex(of: "\n") {
                string = String(string[string.startIndex ..< index])
            }
            
            return string
        }
        return nil
    }

    open override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        return true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
    }

}
