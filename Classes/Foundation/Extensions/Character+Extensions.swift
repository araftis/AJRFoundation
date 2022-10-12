//
//  Character+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/11/22.
//

import Foundation

extension Character : AJREquatable {

    public func isEqual(to other: Any?) -> Bool {
        if let other = other as? Character {
            return self == other
        }
        return false
    }

}
