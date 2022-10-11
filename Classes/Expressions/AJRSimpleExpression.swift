//
//  AJRSimpleExpression.swift.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
public class AJRSimpleExpression : AJROperatorExpression {
    
    public var left: Any?
    public var right: Any?
    
    public init(left: Any?, operator anOperator: AJROperator, right: Any?) {
        super.init(anOperator)
        self.left = left
        self.right = right
    }

    public class func expression(left: Any?, operator anOperator: AJROperator, right: Any?) -> AJRSimpleExpression {
        return AJRSimpleExpression(left: left, operator: anOperator, right: right)
    }
    
    // MARK: - Actions
    
    public override func evaluate(with object: Any?) throws -> Any? {
        let left = try AJRExpression.evaluate(value: self.left, withObject:object)
        let right = try AJRExpression.evaluate(value: self.right, withObject:object)
        return try self.operator.performOperator(withLeft: left, andRight: right)
    }
    
    // MARK: - CustomStringConvertible
    
    public override var description : String {
        return "(\(left ?? "nil") \(self.operator.preferredToken) \(right ?? "nil"))"
    }
    
    public override func isEqual(to other: Any?) -> Bool {
        if let typed = other as? AJRSimpleExpression {
            return (super.isEqual(to: other)
                && AJREqual(left, typed.left)
                && AJREqual(right, typed.right)
            )
        }
        return false
    }

    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        self.left = coder.decodeObject(forKey: "left")
        self.right = coder.decodeObject(forKey: "right")
        super.init(coder: coder)
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(left, forKey:"left")
        coder.encode(right, forKey:"right")
    }

}
