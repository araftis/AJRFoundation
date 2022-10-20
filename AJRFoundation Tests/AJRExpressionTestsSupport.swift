//
//  AJRExpressionTests.swift
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/8/22.
//

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
