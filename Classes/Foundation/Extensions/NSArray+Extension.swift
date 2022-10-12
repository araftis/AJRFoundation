//
//  NSArray+Extension.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/11/22.
//

import Foundation

extension NSArray : Collection {
    
    public func index(after i: Int) -> Int {
        return i + 1
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return count - 1
    }

}
