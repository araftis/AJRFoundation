
@objcMembers
open class AJRNullTransformer : ValueTransformer {

    open override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    open override class func transformedValueClass() -> AnyClass {
        return NSObject.self
    }
    
    open override func transformedValue(_ value: Any?) -> Any? {
        if value == nil || (value as AnyObject) === NSNull() {
            return nil
        }
        return value
    }

    open override func reverseTransformedValue(_ value: Any?) -> Any? {
        return value
    }
    
}
