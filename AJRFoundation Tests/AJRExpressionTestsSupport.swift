/*
AJRExpressionTestsSupport.swift
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
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

import AJRFoundation

class AJRIntegerFunction : AJRFunction {

    override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let integer : Int = try context.integer(at: 0)
        return integer
    }
    
}

class AJRBrokenFunction : AJRFunction {

}

class AJRBrokenOperator : AJROperator {

}

class AJRBrokenUnaryOperator : AJRUnaryOperator {

}

class AJROddStartOperator : AJROperator, AJRIntegerOperator, AJRFloatingPointOperator {

    public func performIntegerOperator(left: Int, right: Int) throws -> Any? {
        return left + right
    }

    public func performFloatingPointOperator(left: Double, right: Double) throws -> Any? {
        return left + right
    }

}

enum AJRExpressionTestingError : Error {
    case correct
}

class AJRArgCountCheckerFunction : AJRFunction {

    override func evaluate(with context: AJREvaluationContext) throws -> Any {
        do {
            try context.check(argumentCountMin: 2)
        } catch AJRFunctionError.invalidArgumentCount(let message) {
            if message == "AJRFunction ajr_arg_count_checker expects at least 2 arguments" {
                throw AJRExpressionTestingError.correct
            }
        }

        do {
            try context.check(argumentCountMax: 10)
        } catch AJRFunctionError.invalidArgumentCount(let message) {
            if message == "AJRFunction ajr_arg_count_checker expects at most 10 arguments" {
                throw AJRExpressionTestingError.correct
            }
        }

        do {
            if let string = try? context.string(at: 0),
               string == "one" {
                try context.check(argumentCountMax: 1)
                //if (localError && [[localError localizedDescription] isEqualToString:@"Function ajr_arg_count_checker expects at most 1 argument"]) {
                //    localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:@"Correct"];
                //}
            }
        }

        return NSNull()
    }

}
