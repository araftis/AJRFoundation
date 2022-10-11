//
//  BooleanConstants.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRTrueConstant : AJRConstant {

    open override var hashableValue: AnyHashable? { return true }
    
}

@objcMembers
open class AJRFalseConstant : AJRConstant {

    open override var hashableValue: AnyHashable? { return false }
    
}
