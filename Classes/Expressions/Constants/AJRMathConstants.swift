//
//  MathConstants.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objc
open class AJRPIConstant : AJRConstant {

    open override var hashableValue: AnyHashable? { return Double.pi }

}

@objc
open class AJREConstant : AJRConstant {

    open override var hashableValue: AnyHashable? { return M_E }

}

@objc
open class AJRNilConstant : AJRConstant {

    open override var hashableValue: AnyHashable? { return 0 }

}
