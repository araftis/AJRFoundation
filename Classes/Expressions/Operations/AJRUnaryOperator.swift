//
//  UnaryOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRUnaryOperator : AJROperator {
    
    open override var precedence: AJROperator.Precedence { return .unary }

}
