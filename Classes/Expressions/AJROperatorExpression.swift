//
//  AJROperatorExpression.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
public class AJROperatorExpression : AJRExpression {
    
    public var `operator`: AJROperator
    
    public init(_ anOperator: AJROperator) {
        self.operator = anOperator
        super.init()
    }
    
    public override func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJROperatorExpression {
            return (super.isEqual(to: other)
                && self.operator == other.operator)
        }
        return false
    }
    
    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        if let op = coder.decodeObject(forKey: "operator") as? AJROperator {
            self.operator = op
        } else {
            return nil
        }
        super.init(coder: coder)
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(`operator`, forKey: "operator")
    }

}
