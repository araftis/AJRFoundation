//
//  NSKeyValueChangeKey+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 6/22/19.
//

import Foundation

extension NSKeyValueChangeKey : CustomStringConvertible {
    
    public var description: String {
        return self.rawValue
    }
    
}
