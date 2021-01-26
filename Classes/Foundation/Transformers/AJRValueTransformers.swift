//
//  AJRValueTransformers.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 6/1/19.
//

import Foundation

@objcMembers
open class AJRValueTransformers : NSObject {

    @objc(registerValueTransformer:properties:)
    internal class func register(valueTransformer: ValueTransformer.Type, properties: [String:Any]) -> Void {
        if let name = properties["name"] as? String {
            valueTransformer.setValueTransformer(valueTransformer.init(), forName: NSValueTransformerName(rawValue: name))
        }
    }
    
}
