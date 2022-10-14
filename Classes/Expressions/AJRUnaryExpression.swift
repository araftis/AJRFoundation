//
//  AJRUnaryExpression.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
public class AJRUnaryExpression : AJROperatorExpression {

    public var value : Any?
    
    // MARK: - Creation
    
    public init(value: Any?, operator anOperator: AJROperator) {
        assert(anOperator is AJRUnaryOperator || anOperator.canActAsUnary)
        super.init(anOperator)
        self.value = value
    }
    
    // MARK: - Actions
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        let value = try AJRExpression.evaluate(value: self.value, with: context)
        return try self.operator.performOperator(value: value, context: context)
    }
    
    // MARK: - NSObject
    
    public override var description : String {
        return "\(self.operator.preferredToken)\(value ?? "nil")"
    }
    
    // MARK: - Equatable
    
    public override func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUnaryExpression {
            return (super.isEqual(to: other)
                && AJREqual(self.value, other.value)
            )
        }
        return false
    }

    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        if let value = coder.decodeObject(forKey: "value") as? AJRExpression {
            self.value = value
        } else {
            return nil
        }
        super.init(coder: coder)
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(value, forKey:"value")
    }

}
