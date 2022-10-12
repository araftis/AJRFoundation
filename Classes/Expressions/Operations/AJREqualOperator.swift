//
//  EqualOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJREqualOperator : AJROperator {
    
    public override func performOperator(withLeft left: Any?, andRight right: Any?) throws -> Any? {
        return AJRAnyEquals(left, right)
    }
    
}
