//
//  AJRNullTransformer.m
//
//  Created by A.J. Raftis on 1/2/12.
//  Copyright (c) 2012 A.J. Raftis. All rights reserved.
//

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
