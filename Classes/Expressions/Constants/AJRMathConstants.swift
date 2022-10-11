//
//  MathConstants.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRPIConstant : AJRConstant {

    open override var hashableValue: AnyHashable? { return Double.pi }

}

@objcMembers
open class AJREConstant : AJRConstant {

    open override var hashableValue: AnyHashable? { return M_E }

}

@objcMembers
open class AJRNilConstant : AJRConstant {

    open override var hashableValue: AnyHashable? { return 0 }

}
