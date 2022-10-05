//
//  AJRUnaryExpression.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

public class AJRUnaryExpression : AJROperatorExpression {

    public var value : Any?
    
    // MARK: - Creation
    
    public init(value: Any?, operator anOperator: AJROperator) {
        assert(anOperator is AJRUnaryOperator || anOperator.canActAsUnary)
        super.init(anOperator)
        self.value = value
    }
    
    // MARK: - Actions
    
    public override func evaluate(withObject object: Any?) throws -> Any? {
        let value = try AJRExpression.evaluate(value: self.value, withObject: object)
        return try self.operator.performOperator(withValue: value)
    }
    
    // MARK: - NSObject
    
    public override var description : String {
        return "\(type(of:self.operator).preferredToken)\(value ?? "nil")"
    }
    
    // MARK: - Equatable
    
    public override func isEqual(to other: Any) -> Bool {
        if let other = other as? AJRUnaryExpression {
            return (super.isEqual(to: other)
                && AJREqual(self.value, other.value)
            )
        }
        return false
    }

}
