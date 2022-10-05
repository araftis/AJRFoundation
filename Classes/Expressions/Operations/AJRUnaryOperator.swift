//
//  UnaryOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objc
open class AJRUnaryOperator : AJROperator {
    
    open override var precedence: AJROperator.Precedence { return .unary }

}
