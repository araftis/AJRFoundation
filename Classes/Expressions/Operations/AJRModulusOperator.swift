//
//  ModulusOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRModulusOperator : AJROperator, AJRIntegerOperator {
    
    public func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any? {
        if right == 0 {
            throw AJRFunctionError.invalidArgument("Attempt to divide by 0.")
        }
        return left % right
    }
    
}
