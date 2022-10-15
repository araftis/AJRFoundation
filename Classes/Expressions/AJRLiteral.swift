//
//  AJRLiteral.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/14/22.
//

import Foundation

@objcMembers
open class AJRLiteral : NSObject, AJREvaluation {

    open var name : String
    open var value : AJREvaluation? = nil

    public init(name: String, value: AJREvaluation?) {
        self.name = name
        self.value = value
    }

    // MARK: - AJREvaluation

    open func evaluate(with context: AJREvaluationContext) throws -> Any? {
        return try value?.evaluate(with: context)
    }

}
