//
//  NSScanner+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/3/23.
//

import Foundation

public extension Scanner {

    struct Tag {
        public var name: String
        public var attributes: [String:String]
        public var type: AJRTagType
    }

    func scanTag() -> Tag? {
        var name : NSString? = nil
        var attribtues : NSDictionary? = nil
        var type = AJRTagType.open

        if scanTag(into: &name, attributesInto: &attribtues, type: &type) {
            if let name, let attribtues = attribtues as? [String : String] {
                return Tag(name: name as String, attributes: attribtues, type: type)
            }
        }
        return nil
    }

}
