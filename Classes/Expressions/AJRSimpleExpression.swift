//
//  AJRSimpleExpression.swift.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

public class AJRSimpleExpression : AJROperatorExpression {
    
    public var left: Any?
    public var right: Any?
    
    public init(left: Any?, operator anOperator: AJROperator, right: Any?) {
        super.init(anOperator)
        self.left = left
        self.right = right
    }
    
    // MARK: - Actions
    
    public override func evaluate(withObject object: Any?) throws -> Any? {
        let left = try AJRExpression.evaluate(value: self.left, withObject:object)
        let right = try AJRExpression.evaluate(value: self.right, withObject:object)
        return try self.operator.performOperator(withLeft: left, andRight: right)
    }
    
    // MARK: - CustomStringConvertible
    
    public override var description : String {
        return "(\(left ?? "nil") \(type(of:self.operator).preferredToken) \(right ?? "nil"))"
    }
    
    public override func isEqual(to other: Any) -> Bool {
        if let typed = other as? AJRSimpleExpression {
            return (super.isEqual(to: other)
                && AJREqual(left, typed.left)
                && AJREqual(right, typed.right)
            )
        }
        return false
    }

}
