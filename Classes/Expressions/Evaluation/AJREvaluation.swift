//
//  AJREvaluation.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/13/22.
//

import Foundation

public protocol AJREvaluationObjC {

    /**
     This is a front end for Obj-C, because we break the normal error semantics due to the fact that our method can succeed when it returns nil.

     - parameter context Contextual information about the evaluation.
     - parameter error An in/out pointer to a NSError object.

     - returns The result of the evaluation. The result may be `nil`.
     */
    func evaluate(with context: AJREvaluationContext, error: NSErrorPointer) -> Any?

}

public protocol AJREvaluation : AJREvaluationObjC {

    /**
     Evaluates the receiver, return a result.

     - parameter context Contextual information about the evaluation.

     - returns The result of the evaluation. The result may be `nil`.
     */
    func evaluate(with context: AJREvaluationContext) throws -> Any?

}

extension AJREvaluation {

    public func evaluate(with context: AJREvaluationContext, error errorPtr: NSErrorPointer) -> Any? {
        var result: Any? = nil

        do {
            result = try evaluate(with: context)
        } catch {
            errorPtr?.pointee = error as NSError
        }

        return result
    }


}
