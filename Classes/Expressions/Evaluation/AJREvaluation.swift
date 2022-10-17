//
//  AJREvaluation.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/13/22.
//

import Foundation

@objc
public protocol AJREvaluation : NSCoding {

    /**
     This is a front end for Obj-C, because we break the normal error semantics due to the fact that our method can succeed when it returns nil.

     - parameter context Contextual information about the evaluation.

     - returns The result of the evaluation. If the result in `nil`, returns `NSNull()`.
     */
    @objc(evaluateWithContext:error:)
    func evaluate(with context: AJREvaluationContext) throws -> Any

    var description : String { get }

}

public extension AJREvaluation {

    static func evaluate(value: Any?, with context: AJREvaluationContext) throws -> Any? {
        var returnValue = value
        while returnValue is AJREvaluation {
            returnValue = try (returnValue! as! AJREvaluation).evaluate(with: context)
        }
        return returnValue
    }

}

//public protocol AJREvaluation : AJREvaluationObjC {
//
//    /**
//     Evaluates the receiver, return a result.
//
//     - parameter context Contextual information about the evaluation.
//
//     - returns The result of the evaluation. The result may be `nil`.
//     */
//    func evaluate(with context: AJREvaluationContext) throws -> Any?
//
//}
//
//extension AJREvaluation {
//
//    public func evaluate(with context: AJREvaluationContext, error errorPtr: NSErrorPointer) -> Any? {
//        var result: Any? = nil
//
//        do {
//            result = try evaluate(with: context)
//        } catch {
//            errorPtr?.pointee = error as NSError
//        }
//
//        return result
//    }
//
//
//}
