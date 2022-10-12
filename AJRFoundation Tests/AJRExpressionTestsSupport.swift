//
//  AJRExpressionTests.swift
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/8/22.
//

import AJRFoundation

class AJRIntegerFunction : AJRFunction {

    override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let integer : Int = try integer(at: 0, withObject: object)
        return integer
    }
    
}

class AJRBrokenFunction : AJRFunction {

}

class AJRBrokenOperator : AJROperator {

}

class AJRBrokenUnaryOperator : AJRUnaryOperator {

}

class AJROddStartOperator : AJROperator, AJRIntOperator, AJRDoubleOperator {

    public func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any? {
        return left + right
    }

    public func performDoubleOperator(withLeft left: Double, andRight right: Double) throws -> Any? {
        return left + right
    }

}

enum AJRExpressionTestingError : Error {
    case correct
}

class AJRArgCountCheckerFunction : AJRFunction {

    override func evaluate(with object: Any?) throws -> Any? {
        do {
            try check(argumentCountMin: 2)
        } catch AJRFunctionError.invalidArgumentCount(let message) {
            if message == "AJRFunction ajr_arg_count_checker expects at least 2 arguments" {
                throw AJRExpressionTestingError.correct
            }
        }

        do {
            try check(argumentCountMax: 10)
        } catch AJRFunctionError.invalidArgumentCount(let message) {
            if message == "AJRFunction ajr_arg_count_checker expects at most 10 arguments" {
                throw AJRExpressionTestingError.correct
            }
        }

        do {
            if let string = try? string(at: 0, withObject: object),
               string == "one" {
                try check(argumentCountMax: 1)
                //if (localError && [[localError localizedDescription] isEqualToString:@"Function ajr_arg_count_checker expects at most 1 argument"]) {
                //    localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:@"Correct"];
                //}
            }
        }

        return nil
    }

}
