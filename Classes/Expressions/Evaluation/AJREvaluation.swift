/*
 AJREvaluation.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

@objc
public protocol AJREvaluation : NSCoding, AJRXMLCoding, NSCopying {

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
