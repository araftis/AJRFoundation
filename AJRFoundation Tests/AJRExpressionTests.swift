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

class AJROddStartOperator : AJROperator {

    public func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any? {
        return left + right
    }

    public func performDoubleOperator(withLeft left: Double, andRight right: Double) throws -> Any? {
        return left + right
    }

}

class AJRArgCountCheckerFunction : AJRFunction {

    override func evaluate(with object: Any?) throws -> Any? {
        do {
            try check(argumentCountMin: 2)
        } catch {
            //if (localError && [[localError localizedDescription] isEqualToString:@"Function ajr_arg_count_checker expects at least 2 arguments"]) {
            //   localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:@"Correct"];
            //}
        }

        do {
            try check(argumentCountMax: 10)
        } catch {
            //if (localError && [[localError localizedDescription] isEqualToString:@"Function ajr_arg_count_checker expects at most 10 arguments"]) {
            //    localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:@"Correct"];
            //}
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

class AJRBrokenConstant : AJRConstant {
    
    // Broken because we don't implement -[AJRConstant value].
    
}

