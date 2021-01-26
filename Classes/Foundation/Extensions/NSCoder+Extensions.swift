//
//  NSCoder+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 2/8/19.
//

import Foundation

public extension NSCoder {
    
    func decodeObject<T>(forKey key: String) -> T? {
        let object : Any? = decodeObject(forKey: key)
        return object as? T
    }
    
    subscript<T>(key: String) -> T? {
        get {
            return decodeObject(forKey: key) as? T
        }
        set {
            encode(newValue, forKey: key)
        }
    }
    
}
