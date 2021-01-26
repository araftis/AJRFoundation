//
//  NSLock+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 6/23/19.
//

import Foundation

public extension NSLocking {
    
    func lock(using block: () -> Void) -> Void {
        lock()
        defer {
            unlock()
        }
        block()
    }
    
}
